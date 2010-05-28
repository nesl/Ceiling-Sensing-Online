#!/usr/bin/env python

# For Websockets
import sys, time, string, signal, serial

# For Serial Interface
import socket, threading, time

# import msg from parent directory
sys.path.append("..")

#tos stuff
import OscilloscopeMsg
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

# Set SENSING THRESHOLD GLOBAL
SENSING_THRESHOLD = 200

class OscilloscopeApp:
    def __init__(self, motestring):
        # Setup Serial Interface
 #       self.ser = serial.Serial(motestring, 57600, timeout=1)
        self.output = ''
        ### start tos mote interface
        self.mif = MoteIF.MoteIF()
        self.tos_source = self.mif.addSource(motestring)
        self.mif.addListener(self, OscilloscopeMsg.OscilloscopeMsg)
        self.start = 0;

        # Setup Socket
        self.s = socket.socket()
        self.s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.s.bind(('', 9876));
        self.s.listen(1);

        # Accept Connection and send initial Websocket message
        self.t,_ = self.s.accept();
        print "Websocket Connection Established"
        self.t.send('''
HTTP/1.1 101 Web Socket Protocol Handshake\r
Upgrade: WebSocket\r
Connection: Upgrade\r
WebSocket-Origin: http://localhost:8888\r
WebSocket-Location: ws://localhost:9876/\r
WebSocket-Protocol: sample
        '''.strip() + '\r\n\r\n')
        self.start = 1;

    def receive(self, src, msg):
        """ This is the registered listener function for TinyOS messages.
        """
        if self.start == 1:
            # Read data from Serial
            print msg.getAddr(), msg

            # Assign values based on position of index
            mote_num = msg.get_id()
            print mote_num
            if msg.getElement_readings(0) > SENSING_THRESHOLD:
                red = 0
                green = 1
                # min((msg.getElement_readings(0) >> 4), 0xFF)
                blue = 0
            else:
                red = 1
                green = 1
                blue = 1

            # For Debugging
            ##############################################

            # Convert colors to simpler coloring scheme

            if mote_num == 1:
                x = 0
                y = 0
            elif mote_num == 2:
                x = 1
                y = 0
            elif mote_num == 6:
                x = 0
                y = 1
            elif mote_num == 7:
                x = 1
                y = 1
            elif mote_num == 8:
                x = 2
                y = 1

            # MOTE_NUMS 11, 12, 16, and 17
            elif mote_num == 11:
                x = 0
                y = 2
            elif mote_num == 12:
                x = 1
                y = 2
            elif mote_num == 16:
                x = 1
                y = 3
            elif mote_num == 17:
                x = 2
                y = 3


            # Set the output into a string
            self.output = "\x00" + str(x) + str(y)+ str(red) + str(green)\
                    + str(blue) + "\xff"

            # Send output through websocket
            self.t.send(self.output)

    def main_loop():
        # Wait for everything to start up
        while 1:
            time.sleep(1)


def main():

    if '-h' in sys.argv:
        print "Usage:", sys.argv[0], "serial@/dev/ttyUSB0:telosb"
        sys.exit()

    cf = OscilloscopeApp(sys.argv[1])
    cf.main_loop()

if __name__ == "__main__":
    main()
