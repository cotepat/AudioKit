// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKFlatFrequencyResponseReverbDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKFlatFrequencyResponseReverbDSP : public AKSoundpipeDSPBase {
private:
    sp_allpass *allpass0;
    sp_allpass *allpass1;
    float loopDuration = 0.1;
    ParameterRamper reverbDurationRamp;

public:
    AKFlatFrequencyResponseReverbDSP() {
        parameters[AKFlatFrequencyResponseReverbParameterReverbDuration] = &reverbDurationRamp;
    }

    void setLoopDuration(float duration) {
        loopDuration = duration;
        reset();
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_allpass_create(&allpass0);
        sp_allpass_init(sp, allpass0, loopDuration);
        sp_allpass_create(&allpass1);
        sp_allpass_init(sp, allpass1, loopDuration);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_allpass_destroy(&allpass0);
        sp_allpass_destroy(&allpass1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_allpass_init(sp, allpass0, loopDuration);
        sp_allpass_init(sp, allpass1, loopDuration);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float reverbDuration = reverbDurationRamp.getAndStep();
            allpass0->revtime = reverbDuration;
            allpass1->revtime = reverbDuration;

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
                    sp_allpass_compute(sp, allpass0, in, out);
                } else {
                    sp_allpass_compute(sp, allpass1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createFlatFrequencyResponseReverbDSP() {
    return new AKFlatFrequencyResponseReverbDSP();
}

extern "C" void setLoopDurationFlatFrequencyResponseDSP(AKDSPRef dspRef, float duration) {
    auto dsp = dynamic_cast<AKFlatFrequencyResponseReverbDSP *>(dspRef);
    assert(dsp);
    dsp->setLoopDuration(duration);
}
