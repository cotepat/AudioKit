//
//  AKParameterAutomationTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/16/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKParameterAutomationTests: AKTestCase {

    func observerTest(events: [AKAutomationEvent],
                      sampleTime: Float64,
                      startTime: Double = 0) -> ([AUParameterAddress], [AUValue], [AUAudioFrameCount]) {

        let address = AUParameterAddress(42)

        var addresses: [AUParameterAddress] = []
        var values: [AUValue] = []
        var durations: [AUAudioFrameCount] = []

        let scheduleParameterBlock: AUScheduleParameterBlock = { (sampleTime, rampDuration, address, value) in
            addresses.append(address)
            values.append(value)
            durations.append(rampDuration)
        }

        let observer: AURenderObserver = events.withUnsafeBufferPointer { automationPtr in
            AKParameterAutomationGetRenderObserver(address,
                                                   scheduleParameterBlock,
                                                   44100,
                                                   startTime, // start time
                                                   automationPtr.baseAddress!,
                                                   events.count)
        }

        var timeStamp = AudioTimeStamp()
        timeStamp.mSampleTime = sampleTime

        observer(.unitRenderAction_PreRender, &timeStamp, 256, 0)

        return (addresses, values, durations)
    }

    func testSimpleAutomation() throws {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 0)

        // order is: taper, skew, offset, value
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomation() {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 0, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomationTwo() {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 0, rampDuration: 0.1),
                       AKAutomationEvent(targetValue: 440, startTime: 0.1, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [440.0])

    }

    func testFutureAutomation() {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 1, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 0)

        // If the automation is in the future, we should not get anything.
        XCTAssertEqual(addresses, [])
        XCTAssertEqual(values, [])
    }

    func testAutomationMiddle() {

        // Start automating in the middle of a segment.

        let events = [AKAutomationEvent(targetValue: 1, startTime: 0, rampDuration: 1.0)]

        let (addresses, values, durations) = observerTest(events: events, sampleTime: 128)

        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [1.0])
        XCTAssertEqual(durations, [UInt32(44100-128)])
    }

    func testRecord() {

        let osc = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.0)
        AKManager.output = osc
        try! AKManager.start()
        osc.start()

        var values:[AUValue] = []

        osc.$frequency.recordAutomation { (event) in
            values.append(event.value)
        }

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        osc.frequency = 800

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        XCTAssertEqual(values, [800])

        osc.$frequency.stopRecording()

        osc.frequency = 500

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        XCTAssertEqual(values, [800])
    }

    func testReplaceAutomation() {

        {
            let points = [ AKParameterAutomationPoint(targetValue: 440, startTime: 0, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 880, startTime: 1, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 440, startTime: 2, rampDuration: 0.1)]

            let events: [(Double, AUValue)] = [ (0.5, 100), (1.5, 200) ]

            let newPoints = AKReplaceAutomation(points: points,
                                                newPoints: events,
                                                startTime: 0.25,
                                                stopTime: 1.75)

            let expected = [ AKParameterAutomationPoint(targetValue: 440, startTime: 0, rampDuration: 0.1),
                             AKParameterAutomationPoint(targetValue: 100, startTime: 0.5, rampDuration: 0.01),
                             AKParameterAutomationPoint(targetValue: 200, startTime: 1.5, rampDuration: 0.01),
                             AKParameterAutomationPoint(targetValue: 440, startTime: 2, rampDuration: 0.1)]

            XCTAssertEqual(newPoints.count, 4)
            XCTAssertEqual(newPoints, expected)
        }();


        {
            let points = [ AKParameterAutomationPoint(targetValue: 440, startTime: 0, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 880, startTime: 1, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 440, startTime: 2, rampDuration: 0.1)]

            let events: [(Double, AUValue)] = [ ]

            let newPoints = AKReplaceAutomation(points: points,
                                                newPoints: events,
                                                startTime: 0,
                                                stopTime: 2)

            XCTAssertEqual(newPoints, [])
        }();

        {
            let points: [AKParameterAutomationPoint] = [ ]

            let events: [(Double, AUValue)] = [ (0.5, 100), (1.5, 200) ]

            let newPoints = AKReplaceAutomation(points: points,
                                                newPoints: events,
                                                startTime: 0,
                                                stopTime: 2)

            let expected = [ AKParameterAutomationPoint(targetValue: 100, startTime: 0.5, rampDuration: 0.01),
                             AKParameterAutomationPoint(targetValue: 200, startTime: 1.5, rampDuration: 0.01)]

            XCTAssertEqual(newPoints, expected)
        }()
    }

    func testEvaluateAutomationLinear() {
        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0)]

        let newPoints = AKEvaluateAutomation(initialValue: 0, points: points, resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0)
        XCTAssertEqual(newPoints[0].targetValue, 1)
        XCTAssertEqual(newPoints[0].rampDuration, 1)
    }


    func testEvaluateAutomationAlmostLinear() {

        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0, rampTaper: 1.0, rampSkew: 0.000001)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssert(fabs(newPoints[0].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[1].startTime, 0.5)
        XCTAssertEqual(newPoints[1].targetValue, 1.0)
    }

    func testEvaluateAutomationSlightTaper() {

        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0, rampTaper: 1.00001, rampSkew: 0.0)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssert(fabs(newPoints[0].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[1].startTime, 0.5)
        XCTAssertEqual(newPoints[1].targetValue, 1.0)
    }

    func testEvaluateAutomationCurved() {

        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0, rampTaper: 0.5, rampSkew: 0.1)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.1)

        XCTAssertEqual(newPoints.count, 10)

    }

    func testEvaluateAutomationTwoSegment() {

        // One linear, one curved segment.
        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0),
                      AKParameterAutomationPoint(targetValue: 0, startTime: 1.0, rampDuration: 1.0, rampTaper: 1.0, rampSkew: 0.000001)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssertEqual(newPoints[0].targetValue, 1.0)

        XCTAssertEqual(newPoints[1].startTime, 1.0)
        XCTAssert(fabs(newPoints[1].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[2].startTime, 1.5)
        XCTAssert(abs(newPoints[2].targetValue) < 0.0001)

    }

    func testEvaluateAutomationTwoSegment2() {

        // Curved segment cut off by linear segment.
        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 2.0, rampTaper: 1.0, rampSkew: 0.000001),
                      AKParameterAutomationPoint(targetValue: 1, startTime: 1, rampDuration: 0.0)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssertEqual(newPoints[0].rampDuration, 0.5)
        XCTAssertEqual(newPoints[0].targetValue, 0.25)

        XCTAssertEqual(newPoints[1].startTime, 0.5)
        XCTAssert(fabs(newPoints[1].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[2].startTime, 1.0)
        XCTAssertEqual(newPoints[2].targetValue, 1.0)
        XCTAssertEqual(newPoints[2].rampDuration, 0.0)

    }
}
