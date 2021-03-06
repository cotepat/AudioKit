// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKScheduledAction {

    private var interval: TimeInterval
    private var block: (() -> Void)
    private var timer: Timer?

    @objc public init(interval: TimeInterval, block: @escaping () -> Void) {
        self.interval = interval
        self.block = block
        start()
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(fire(timer:)),
                                     userInfo: nil,
                                     repeats: false)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private dynamic func fire(timer: Timer) {
        guard timer.isValid else {
            return
        }
        self.block()
    }

    deinit {
        stop()
    }
}
