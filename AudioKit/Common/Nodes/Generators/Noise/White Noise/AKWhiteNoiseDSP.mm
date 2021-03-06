// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKWhiteNoiseDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKWhiteNoiseDSP : public AKSoundpipeDSPBase {
private:
    sp_noise *noise;
    ParameterRamper amplitudeRamp;

public:
    AKWhiteNoiseDSP() {
        parameters[AKWhiteNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_noise_create(&noise);
        sp_noise_init(sp, noise);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_noise_destroy(&noise);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_noise_init(sp, noise);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            noise->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_noise_compute(sp, noise, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

extern "C" AKDSPRef createWhiteNoiseDSP() {
    return new AKWhiteNoiseDSP();
}
