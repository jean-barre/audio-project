#include <iostream>
#include <math.h>
#include <string.h>

#include "AudioFile.h"
#include "BTrack.h"

using namespace std;

int main() {
    // Initialize AudioFile and load the resource
    AudioFile<double> audioFile;
    audioFile.load ("res/Eagles-Hotel_California_2.wav");
    audioFile.printSummary();
    // Initialize project variables
    // FIXME: the framesPerBuffer value is not correct.
    int framesPerBuffer = 512, numBeat = 0;
    int numChannel = audioFile.getNumChannels();
    int numSamplePerChannel = audioFile.getNumSamplesPerChannel();
    int subSampleNumber = floor((double)numSamplePerChannel/(double)framesPerBuffer);
    double *subSample = new double[framesPerBuffer * numChannel];
    // Initialize Beat Tracker
    BTrack b(framesPerBuffer, framesPerBuffer * numChannel);
    // Separate samples in chunk and apply Beat Tracker on it
    for (int i=0; i<subSampleNumber; i++) {
        for(int j=0; j<numChannel; j++) {
            memcpy(subSample + j*framesPerBuffer,
                    &audioFile.samples[j][i*framesPerBuffer], framesPerBuffer);
        }

        b.processAudioFrame(subSample);
        if (b.beatDueInCurrentFrame())
        {
            numBeat++;
        }
    }
    cout<<"Num Beat found: "<<numBeat<<endl;

    return 0;
}
