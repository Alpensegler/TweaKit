//
//  Debouncer.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

final class Debouncer {
    let dueTime: TimeInterval

    private var job: (() -> Void)?
    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }

    deinit {
        cancel()
    }

    init(dueTime: TimeInterval) {
        self.dueTime = max(dueTime, 0)
    }
}

extension Debouncer {
    func call(job: @escaping () -> Void) {
        if dueTime <= 0 {
            job()
            return
        }

        self.job = nil
        timer = Timer(timeInterval: dueTime, repeats: false) { [weak self] timer in
            guard timer.isValid else { return }
            self?.job?()
            self?.job = nil
        }
        RunLoop.current.add(timer!, forMode: .common)
        self.job = job
    }

    func cancel() {
        job = nil
        timer?.invalidate()
        timer = nil
    }
}
