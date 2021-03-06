// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBandRejectButterworthFilterDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKBandRejectButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_butbr *butbr0;
    sp_butbr *butbr1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    AKBandRejectButterworthFilterDSP() {
        parameters[AKBandRejectButterworthFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKBandRejectButterworthFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butbr_create(&butbr0);
        sp_butbr_init(sp, butbr0);
        sp_butbr_create(&butbr1);
        sp_butbr_init(sp, butbr1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_butbr_destroy(&butbr0);
        sp_butbr_destroy(&butbr1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butbr_init(sp, butbr0);
        sp_butbr_init(sp, butbr1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float centerFrequency = centerFrequencyRamp.getAndStep();
            butbr0->freq = centerFrequency;
            butbr1->freq = centerFrequency;

            float bandwidth = bandwidthRamp.getAndStep();
            butbr0->bw = bandwidth;
            butbr1->bw = bandwidth;

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
                    sp_butbr_compute(sp, butbr0, in, out);
                } else {
                    sp_butbr_compute(sp, butbr1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createBandRejectButterworthFilterDSP() {
    return new AKBandRejectButterworthFilterDSP();
}