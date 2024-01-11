//
//  ThreadSafeCounter.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 20/12/2023.
//

import Foundation

// Import module pthread
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

// Tạo một lớp đơn giản để minh họa tính đồng bộ của luồng
class ThreadSafeCounter {
    private var counter = 0
    private var mutex = pthread_mutex_t()

    init() {
        // Khởi tạo mutex
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        // Hủy bỏ mutex khi đối tượng bị giải phóng
        pthread_mutex_destroy(&mutex)
    }

    func increment() {
//         Khóa mutex trước khi truy cập nguồn chia sẻ
        pthread_mutex_lock(&mutex)
        defer {
            // Đảm bảo mutex luôn được mở, ngay cả khi có lỗi
            pthread_mutex_unlock(&mutex)
        }
        
        // Truy cập nguồn chia sẻ
        print("~~~ thread1: \(Thread.current)")
        counter += 1
        print("Counter tăng lên \(counter)")
    }

    func getValue() -> Int {
        // Khóa mutex trước khi truy cập nguồn chia sẻ
        pthread_mutex_lock(&mutex)
        defer {
            // Đảm bảo mutex luôn được mở, ngay cả khi có lỗi
            pthread_mutex_unlock(&mutex)
        }

        // Truy cập nguồn chia sẻ
        return counter
    }
}
