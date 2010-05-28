README for CeilingSensingOnline:
Author: Jason Tsao

For the CeilingSensingOnline App, you need to update microphone driver:
mv MicP.nc $TOSROOT/tos/sensorboards/mts300

To use CeilingSensingOnline:
1. Install CeilingSensing on all Motes:
    ./make for all micaz 
2. Put Basestation on micaz connected to computer: => Check LED toggles for send/receive
    make micaz install,N mib520,/dev/ttyUSB0   
   where N is > 17. 
3. Run Serial Forwarder:
      java net.tinyos.sf.SerialForwarder -no-gui -comm
      serial@/dev/ttyUSB1:micaz
4. Run read_serial.py using the Serial Forwarder
      ./read_serial.py sf@127.0.0.1:9002
5. Turn on the python SimpleServer: 
      python -m SimpleHTTPServer 8888
7. Open http://localhost:8888/NESL_lab.html in Google Chrome (as of now the only web
    browser that supports HTML 5 Websockets)

For information about the Oscilloscope, see the attached below.

README for Oscilloscope
Author/Contact: tinyos-help@millennium.berkeley.edu

Description:

Oscilloscope is a simple data-collection demo. It periodically samples
the default sensor and broadcasts a message over the radio every 10
readings. These readings can be received by a BaseStation mote and
displayed by the Java "Oscilloscope" application found in the java
subdirectory. The sampling rate starts at 4Hz, but can be changed from
the Java application.

You can compile Oscilloscope with a sensor board's default sensor by compiling
as follows:
  SENSORBOARD=<sensorboard name> make <mote>

You can change the sensor used by editing OscilloscopeAppC.nc.

Tools:

To display the readings from Oscilloscope motes, install the BaseStation
application on a mote connected to your PC's serial port. Then run the 
Oscilloscope display application found in the java subdirectory, as
follows:
  cd java
  make
  java net.tinyos.sf.SerialForwarder -comm serial@<serial port>:<mote>
  # e.g., java net.tinyos.sf.SerialForwarder -comm serial@/dev/ttyUSB0:mica2
  # or java net.tinyos.sf.SerialForwarder -comm serial@COM2:telosb
  ./run

The controls at the bottom of the screen allow you to zoom in or out the X
axis, change the range of the Y axis, and clear all received data. You can
change the color used to display a mote by clicking on its color in the
mote table.

Known bugs/limitations:

None.

$Id: README.txt,v 1.6 2008/07/25 03:01:45 regehr Exp $
