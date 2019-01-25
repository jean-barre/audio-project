###############################################################################
# TARGETS
###############################################################################
RECORD_BEAT_TARGET = record-beat
RECORD_CHROMA_TARGET = record-chroma
PLAY_TARGET = play

# common
CXXFLAGS=-g
SRCS_DIR=src
OBJS_DIR=build

all: $(RECORD_BEAT_TARGET) $(RECORD_CHROMA_TARGET) $(PLAY_TARGET)

clean:
	$(RM) $(RECORD_BEAT_OBJS) $(RECORD_CHROMA_OBJS) $(AUDIOF_OBJS) $(BTRACK_OBJS) $(CHROMA_OBJS) $(PLAY_OBJS)
distclean:
	$(RM) $(RECORD_BEAT_TARGET) $(RECORD_CHROMA_TARGET) $(PLAY_TARGET)

###############################################################################
# SOURCES AND OBJECTS
###############################################################################
# record-beat
RECORD_BEAT_SRCS=$(SRCS_DIR)/record_beat.cpp
RECORD_BEAT_OBJS=$(patsubst $(SRCS_DIR)/%.cpp,$(OBJS_DIR)/%.o,$(RECORD_BEAT_SRCS))
# record-chroma
RECORD_CHROMA_SRCS=$(SRCS_DIR)/record_chroma.cpp
RECORD_CHROMA_OBJS=$(patsubst $(SRCS_DIR)/%.cpp,$(OBJS_DIR)/%.o,$(RECORD_CHROMA_SRCS))
# play
PLAY_SRCS=$(SRCS_DIR)/play_file.cpp
PLAY_OBJS=$(patsubst $(SRCS_DIR)/%.cpp,$(OBJS_DIR)/%.o,$(PLAY_SRCS))

###############################################################################
# LIBRARIES
###############################################################################
# Adam Stark BTrack
BTRACK_SRCS_DIR=BTrack/src
BTRACK_OBJS_DIR=BTrack/build
BTRACK_SRCS=$(wildcard $(BTRACK_SRCS_DIR)/*.cpp)
BTRACK_OBJS=$(patsubst $(BTRACK_SRCS_DIR)/%.cpp,$(BTRACK_OBJS_DIR)/%.o,$(BTRACK_SRCS))
BTRACK_FLAG=-DUSE_FFTW
BTRACK_LIBS=-lfftw3 -lm -lsamplerate
# Adam Stark Chord Detector and Chromagram
CHROMA_SRCS_DIR=Chord-Detector-and-Chromagram/src
CHROMA_OBJS_DIR=Chord-Detector-and-Chromagram/build
CHROMA_SRCS=$(wildcard $(CHROMA_SRCS_DIR)/*.cpp)
CHROMA_OBJS=$(patsubst $(CHROMA_SRCS_DIR)/%.cpp,$(CHROMA_OBJS_DIR)/%.o,$(CHROMA_SRCS))
CHROMA_FLAG=$(BTRACK_FLAG)
CHROMA_LIBS=$(BTRACK_LIBS)
# Adam Stark AudioFile
AUDIOF_SRCS_DIR=AudioFile/src
AUDIOF_OBJS_DIR=AudioFile/build
AUDIOF_SRCS=$(wildcard $(AUDIOF_SRCS_DIR)/*.cpp)
AUDIOF_OBJS=$(patsubst $(AUDIOF_SRCS_DIR)/%.cpp,$(AUDIOF_OBJS_DIR)/%.o,$(AUDIOF_SRCS))
## Portaudio library
PORTAUDIO_LIBS=portaudio/lib/.libs/libportaudio.a -lrt -lm -lasound -ljack -pthread
## The following line is needed to build on MacOS
##export DYLD_LIBRARY_PATH=/System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/:portaudio/lib/.libs

###############################################################################
# RULES
###############################################################################
$(BTRACK_OBJS):
	$(MAKE) -C BTrack

$(CHROMA_OBJS):
	$(MAKE) -C Chord-Detector-and-Chromagram

$(AUDIOF_OBJS):
	$(MAKE) -C AudioFile

$(RECORD_BEAT_OBJS): $(RECORD_BEAT_SRCS)
	$(CXX) $(CXXFLAGS) $(BTRACK_FLAG) -c $< -o $@

$(RECORD_CHROMA_OBJS): $(RECORD_CHROMA_SRCS)
	$(CXX) $(CXXFLAGS) $(CHROMA_FLAG) -c $< -o $@

$(PLAY_OBJS): $(PLAY_SRCS)
	$(CXX) $(CXXFLAGS) $(BTRACK_FLAG) -c $< -o $@

$(RECORD_BEAT_TARGET): $(RECORD_BEAT_OBJS) $(BTRACK_OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(RECORD_BEAT_OBJS) $(BTRACK_OBJS) $(PORTAUDIO_LIBS) $(BTRACK_LIBS)

$(RECORD_CHROMA_TARGET): $(RECORD_CHROMA_OBJS) $(CHROMA_OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(RECORD_CHROMA_OBJS) $(CHROMA_OBJS) $(PORTAUDIO_LIBS) $(CHROMA_LIBS)

$(PLAY_TARGET): $(PLAY_OBJS) $(AUDIOF_OBJS) $(BTRACK_OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(PLAY_OBJS) $(AUDIOF_OBJS) $(BTRACK_OBJS) $(BTRACK_LIBS)
