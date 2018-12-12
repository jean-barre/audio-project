TARGET=record

SRCS_DIR=src
BTRACK_SRCS_DIR=BTrack/src
OBJS_DIR=build

SRCS=$(wildcard $(SRCS_DIR)/*.cpp)
OBJS=$(patsubst $(SRCS_DIR)/%.cpp,$(OBJS_DIR)/%.o,$(SRCS))

LDLIBS=-L./portaudio/lib/.libs -lsamplerate -lportaudio -lfftw3
INC_FLAGS=-I./portaudio/include -I./$(BTRACK_SRCS_DIR)
CPPFLAGS=$(INC_FLAGS) -DUSE_FFTW

all: $(TARGET)

$(TARGET): $(OBJS)
	export DYLD_LIBRARY_PATH=/System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/:portaudio/lib/.libs
	$(CXX) -o $@ $(OBJS) $(LDLIBS)

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

clean:
	rm $(OBJS_DIR)/*
