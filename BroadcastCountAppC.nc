#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "BroadcastCount.h"

configuration BroadcastCountAppC
{
}

implementation
{
  components MainC, PrintfC, SerialStartC, BroadcastCountC, LedsC;
  components new TimerMilliC() as Timer;

  // Radio components
  components new AMSenderC(6);
  components new AMReceiverC(6);
  components ActiveMessageC;

  BroadcastCountC -> MainC.Boot;

  BroadcastCountC.Leds -> LedsC;
  BroadcastCountC.Timer -> Timer;

  // Radio wiring
  BroadcastCountC.Receive -> AMReceiverC;
  BroadcastCountC.AMSend -> AMSenderC;
  BroadcastCountC.AMControl -> ActiveMessageC;
  BroadcastCountC.Packet -> AMSenderC;
}
