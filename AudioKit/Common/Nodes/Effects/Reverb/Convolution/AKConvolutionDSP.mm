// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKConvolutionDSP.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKConvolutionDSP : public AKSoundpipeDSPBase {
private:
    sp_conv *conv0;
    sp_conv *conv1;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;
    int partitionLength = 2048;

public:
    AKConvolutionDSP() {}

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        sp_conv_create(&conv0);
        sp_conv_init(sp, conv0, ftbl, (float)partitionLength);
        sp_conv_create(&conv1);
        sp_conv_init(sp, conv1, ftbl, (float)partitionLength);
    }

    void setPartitionLength(int partLength) {
        partitionLength = partLength;
        reset();
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_conv_destroy(&conv0);
        sp_conv_destroy(&conv1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_conv_init(sp, conv0, ftbl, (float)partitionLength);
        sp_conv_init(sp, conv1, ftbl, (float)partitionLength);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                    continue;
                }

                if (channel == 0) {
                    sp_conv_compute(sp, conv0, in, out);
                } else {
                    sp_conv_compute(sp, conv1, in, out);
                }
                *out = *out * 0.05; // Hack
            }
        }
    }
};

extern "C" AKDSPRef createConvolutionDSP() {
    return new AKConvolutionDSP();
}

extern "C" void setPartitionLengthConvolutionDSP(AKDSPRef dsp, int length) {
    ((AKConvolutionDSP*)dsp)->setPartitionLength(length);
}
