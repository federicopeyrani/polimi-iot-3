#include "printf.h"
#include "Timer.h"
#include "BroadcastCount.h"

module BroadcastCountC @safe()
{
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as Timer;

    // Radio interfaces
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
  }
}

implementation
{

  uint16_t counter = 0;
  uint8_t led_status = 0;

  message_t packet;

  event void Boot.booted()
  {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) {
      printf("Error starting radio\n");
      call AMControl.start();
    } else {
      uint16_t period = 0;
      switch (TOS_NODE_ID)
      {
        case 1:
          period = NODE_1_TIMER;
          break;
        case 2:
          period = NODE_2_TIMER;
          break;
        case 3:
          period = NODE_3_TIMER;
          break;
      }

      call Timer.startPeriodic(period);
      printf("Started radio\n");
    }

    printfflush();
  }

  event void AMControl.stopDone(error_t err) {
    // skip
  }

  event void Timer.fired()
  {
    // build message
    broadcast_msg_t* msg = (broadcast_msg_t*) call Packet.getPayload(&packet, sizeof(broadcast_msg_t));
    if (msg == NULL) {
      return;
    }

    // inflate message payload
    msg->sender_id = TOS_NODE_ID;
    msg->counter = counter;

    // send message
    call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(broadcast_msg_t));
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    printf("Sent message with counter: %u\n", counter);
    printfflush();
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    if (len == sizeof(broadcast_msg_t)) {
      broadcast_msg_t* msg = (broadcast_msg_t*) payload;
      printf("Received (sender_id=%u, counter=%u)\n", msg->sender_id, msg->counter);

      if (msg->counter % 10 == 0) {
        // turn of all leds by setting the status to 0
        led_status = 0;
      } else {
        // Create a one-hot encoding mask by shifting the bit integer '00000001'
        // to the left depending on the sender_id field, and use it to XOR three
        // current led_status to produce the toggling effect. This is less
        // verbose than writing a switch statement with three cases, and will
        // scale to include more nodes if need be.
        led_status = led_status ^ (0x01 << (msg->sender_id - 1));
      }

      counter += 1;
      call Leds.set(led_status);

      // for debugging, print the counter and led status
      printf("New counter: %u\n", counter);
      printf("Led status: %c%c%c\n",
        (led_status & LEDS_LED2 ? '1' : '0'),
        (led_status & LEDS_LED1 ? '1' : '0'),
        (led_status & LEDS_LED0 ? '1' : '0')
      );
      printfflush();
    }

    return bufPtr;
  }
}
