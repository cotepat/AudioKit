// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKToneComplementFilterDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKToneComplementFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_atone *atone0;
    sp_atone *atone1;
    ParameterRamper halfPowerPointRamp;

public:
    AKToneComplementFilterDSP() {
        parameters[AKToneComplementFilterParameterHalfPowerPoint] = &halfPowerPointRamp;
        bCanProcessInPlace = false;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_atone_create(&atone0);
        sp_atone_init(sp, atone0);
        sp_atone_create(&atone1);
        sp_atone_init(sp, atone1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_atone_destroy(&atone0);
        sp_atone_destroy(&atone1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_atone_init(sp, atone0);
        sp_atone_init(sp, atone1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float halfPowerPoint = halfPowerPointRamp.getAndStep();
            atone0->hp = halfPowerPoint;
            atone1->hp = halfPowerPoint;

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
                    sp_atone_compute(sp, atone0, in, out);
                } else {
                    sp_atone_compute(sp, atone1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createToneComplementFilterDSP() {
    return new AKToneComplementFilterDSP();
}
