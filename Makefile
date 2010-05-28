COMPONENT=OscilloscopeAppC
PFLAGS += -DCC2420_DEF_CHANNEL=12
SENSORBOARD=mts300
BUILD_EXTRA_DEPS = OscilloscopeMsg.py 
CLEAN_EXTRA = OscilloscopeMsg.py 

OscilloscopeMsg.py: Oscilloscope.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=OscilloscopeMsg Oscilloscope.h oscilloscope -o $@

include $(MAKERULES)
