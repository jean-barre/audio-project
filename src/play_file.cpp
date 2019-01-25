#include <iostream>
#include <iomanip>
#include <math.h>
#include <string.h>

#include "../AudioFile/src/AudioFile.h"
#include "../BTrack/src/BTrack.h"

#define NUM_SAMPLES_PER_CHUNK 512

using namespace std;

int main() {
    int sampleRate, bitDepth, numChannel, numSamplesPerChannel;
    double lengthInMinutes = 0;
    double remainingSeconds = 0;
    int numBeat = 0;
    // Be careful, song's BPM must be comprised between 80 and 160
    const char* filename  = "Eagles-Hotel_California.wav";
    //const char* filename  = "Gorillaz-Clint_Eastwood.wav";
    //const char* filename  = "Bee_Gees-Stayin_Alive.wav";
    //const char* filename  = "Bob_Marley-Redemption_Song.wav";
    char filepath[100];
    strcpy(filepath, "res/");
    strcat(filepath, filename);
    cout << "Player running on file: " << filename << endl;

    // Initialize AudioFile and load the resource
    AudioFile<double> audioFile;
    audioFile.load (filepath);
    audioFile.printSummary();
    cout << "File loaded." << endl;

    // Print duration in several formats.
    lengthInMinutes = audioFile.getLengthInSeconds() / 60;
    cout << "Length in Minutes: " << fixed << setprecision(3) << lengthInMinutes << endl;
    cout << resetiosflags(cout.flags());
    remainingSeconds = lengthInMinutes - floor(lengthInMinutes);
    cout << "Length: " << floor(lengthInMinutes) << "min ";
    cout << floor(remainingSeconds * 60) << "sec" << endl;
    cout << "Beat Tracker algorithm running..." << endl;

    // Initialize project variables.
    // Sample Rate is the number of sample per seconds.
    sampleRate = audioFile.getSampleRate();
    // Bit Depth is the number of bite per sample.
    bitDepth = audioFile.getBitDepth();
    // Nomber of Channel is 1 if mono or 2 if stereo.
    numChannel = audioFile.getNumChannels();
    numSamplesPerChannel = audioFile.getNumSamplesPerChannel();
    if (numChannel != 2) {
        cout << "This program only handle stereo music files for now" << endl;
        return -1;
    }
    // Initialize the frame to give to Beat Tracker.
    double frame[NUM_SAMPLES_PER_CHUNK * numChannel];

    // Initialize Beat Tracker.
    BTrack b(NUM_SAMPLES_PER_CHUNK);
    // Reconstitute frames from samples,
    // Fill the array with chunks,
    // and apply Beat Tracker on it.
    for (int i=0; i<floor(numSamplesPerChannel/NUM_SAMPLES_PER_CHUNK); i++) {
        for (int j=0; j<NUM_SAMPLES_PER_CHUNK; j++) {
            frame[2*j] = audioFile.samples[0][NUM_SAMPLES_PER_CHUNK*i+j];
            frame[2*j+1] = audioFile.samples[1][NUM_SAMPLES_PER_CHUNK*i+j];
        }
        b.processAudioFrame(frame);
        if (b.beatDueInCurrentFrame()) {
            numBeat++;
//            if ((numBeat % 50) == 0) {
//                cout << b.getLatestCumulativeScoreValue() << endl;
//            }
        }
    }
    // Print results.
    cout << "Num Beat found: " << numBeat << endl;
    cout << "BPM: " << floor(numBeat / lengthInMinutes) << endl;
    return 0;
}
