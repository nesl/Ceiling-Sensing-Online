/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Oscilloscope demo application. See README.txt file in this directory.
 *
 * @author David Gay
 */
#include "Timer.h"
#include "Oscilloscope.h"

module OscilloscopeC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Read<uint16_t>;
    interface Leds;
    interface BlinkM;
  }
}

implementation
{
#define BUF_SIZE 32
#define SENSING_THRESHOLD 200
#define MAX(a, b)  (((a) > (b)) ? (a) : (b))
#define MIN(a, b)  (((a) < (b)) ? (a) : (b))

  message_t sendBuf;
  bool sendBusy;
  uint16_t buf[BUF_SIZE];
  uint8_t state;

  enum STATE
  {
    idle = 0,
    sensing,
    led_on,
    blind
  };

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */
  uint8_t samples; /* 0 to BUF_SIZE */ 

  bool suppressCountChange;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  event void Boot.booted() {
    local.interval = DEFAULT_INTERVAL;
    local.id = TOS_NODE_ID;
    call BlinkM.stop_script();
  }

  void startTimer() {
    call Timer.startPeriodic(local.interval);
    reading = 0;
    samples = 0;
    state = sensing;
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    oscilloscope_t *omsg = payload;

    report_received();

    /* If we receive a newer version, update our interval. 
       If we hear from a future count, jump ahead but suppress our own change
    */
    if (omsg->version > local.version)
      {
	local.version = omsg->version;
	local.interval = omsg->interval;
	startTimer();
      }
    if (omsg->count > local.count)
      {
	local.count = omsg->count;
	suppressCountChange = TRUE;
      }

    return msg;
  }

  uint16_t calcVariance(uint16_t *stream, uint16_t count)
  {
       uint16_t i;
       uint32_t mean;
       float var; 
 
       mean = 0;
       for(i=0; i < count; i++) mean += stream[i];
       mean /= count;
  
       var = 0;
       for(i=0; i < count; i++)
       {
         var += (stream[i]-mean)*(stream[i]-mean);
       }
       var /= count;

       return (uint16_t)var;
  }

  event void Timer.fired() {
    // If buffer is full, compute variance and put it into readings
    if (samples == BUF_SIZE)
    {
      uint16_t tmp;
      tmp = calcVariance(buf, BUF_SIZE);
      local.readings[reading++] = tmp;
      samples = 0;

      // Check if we need to trigger the led
      if (tmp > SENSING_THRESHOLD)
      {
        call Leds.led0On();
        // We reduce the span of tmp to make the BlinkM glow a little less
        // unless really loud
        call BlinkM.set_rgb_color(0, MIN((tmp>>4), 0xFF), 0);
        state = led_on;
      }
      else
      {
        call Leds.led0Off();
        call BlinkM.set_rgb_color(0, 0, 0);
        state = sensing;
      }
    }

    // If packet is full, send it out
    if (reading == NREADINGS)
    {
	  if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	  {
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
	      sendBusy = TRUE;
	  }
	  if (!sendBusy)
	    report_problem();

	  reading = 0;
	  /* Part 2 of cheap "time sync": increment our count if we didn't
	     jump ahead. */
	  if (!suppressCountChange)
	    local.count++;
	  suppressCountChange = FALSE;
    }

    // Get another sample
    if (call Read.read() != SUCCESS)
      report_problem();
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();

    sendBusy = FALSE;
  }

  event void Read.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
	data = 0xffff;
	report_problem();
      }
      buf[samples++] = data;
  }

  event void BlinkM.fade_to_rgb_colorDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.set_rgb_colorDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.set_fade_speedDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.fade_to_hsb_colorDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.stop_scriptDone(error_t error)
  {
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }
  async event void BlinkM.get_rgb_colorDone(error_t error, uint8_t red, uint8_t green, uint8_t blue)
  {
      //do nothing
  }
  
}
