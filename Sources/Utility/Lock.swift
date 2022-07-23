//
//  Lock.swift
//  TweaKitTests
//
//  Created by cokile
//

import Foundation

final class Lock {
    private var mutex = pthread_mutex_t()

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    init() {
        var attr = pthread_mutexattr_t()
        var success = pthread_mutexattr_init(&attr) == 0
        precondition(success)

        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        success = pthread_mutex_init(&mutex, &attr) == 0
        precondition(success)
    }

    func lock() {
        let success = pthread_mutex_lock(&mutex) == 0
        precondition(success)
    }

    func unlock() {
        let success = pthread_mutex_unlock(&mutex) == 0
        precondition(success)
    }
}
