// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKFrequencyTrackerAudioUnit.h"
#import "AKFrequencyTrackerDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKFrequencyTrackerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFrequencyTrackerDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (float)amplitude {
    return _kernel.trackedAmplitude;
}
- (float)frequency {
    return _kernel.trackedFrequency;
}

- (void)setHopSize:(UInt32)hopSize {
    _kernel.hopSize = hopSize;
}
- (void)setPeakCount:(UInt32)peakCount {
    _kernel.peakCount = peakCount;
}


- (void)createParameters {

    standardSetup(FrequencyTracker)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[]];

    parameterTreeBlock(FrequencyTracker)
}

AUAudioUnitOverrides(FrequencyTracker)


@end


