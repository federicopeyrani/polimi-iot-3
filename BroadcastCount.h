#ifndef BROADCAST_COUNT_H
#define BROADCAST_COUNT_H

#define NODE_1_TIMER 1000
#define NODE_2_TIMER 333
#define NODE_3_TIMER 200

typedef nx_struct broadcast_msg {
  nx_uint8_t sender_id;
  nx_uint16_t counter;
} broadcast_msg_t;

#endif
