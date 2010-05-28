#!/usr/bin/env "python -W ignore::DeprecationWarning"

import sys
import time
import signal
import serial

# import msg from parent directory
sys.path.append("..")

#tos stuff
import OscilloscopeMsg
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

class OscilloscopeApp:

    def __init__(self, motestring):

        ### start tos mote interface
        self.mif = MoteIF.MoteIF()
        self.tos_source = self.mif.addSource(motestring)
        self.mif.addListener(self, OscilloscopeMsg.OscilloscopeMsg)

    def set_output(self,comm,red,green,blue,mote):
        bmsg = RadioCountMsg.RadioCountMsg()
        self.mif.sendMsg(self.tos_source, 0xFFFF, bmsg.get_amType(), 4001, bmsg)



    def receive(self, src, msg):
        """ This is the registered listener function for TinyOS messages.
        """
        print msg.getAddr(), msg


    def main_loop(self):
        # wait for everything to start up
        while 1:
            time.sleep(1)

def main():

    if '-h' in sys.argv:
        print "Usage:", sys.argv[0], "serial@/dev/ttyUSB0:telosb"
        sys.exit()

    cf = OscilloscopeApp(sys.argv[1])
    cf.main_loop()  # don't expect this to return...


if __name__ == "__main__":
    main()
