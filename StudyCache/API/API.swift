//
//  API.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 15/12/2023.
//

import Foundation

enum OtherError: Error {
    case unowned
}

final class API: NSObject {
    static let shared = API()
    private let session: URLSession
    private var cacheUrl: [String: URLSessionDataTask]

    override init() {
        session = URLSession(configuration: .default)
        cacheUrl = [:]
        super.init()
    }

    func cancelAll() {
        cacheUrl.values.forEach { task in
            task.cancel()
        }
    }

    func cancel(_ url: URL?) {
        guard let url = url else { return }
        cacheUrl[url.absoluteString]?.cancel()
    }

    func cacheURL(value: URLSessionDataTask, key: String) {
        if let task = cacheUrl[key] {
            task.cancel()
        }

        cacheUrl[key] = value
    }


    func getData(url: URL,
                 onNext: (([[String: Any]]) -> Void)?,
                 onError: ((Error) -> Void)?) {
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60)
        let task = session.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let error = error {
                    onError?(error)
                } else if let data = data {
                    if let dict = try? JSONSerialization
                        .jsonObject(with: data, 
                                    options: .mutableContainers)
                        as? [[String: Any]] {
                        onNext?(dict)
                    }
                } else {
                    onError?(OtherError.unowned)
                }
            })

        task.resume()
    }

    func getImage(url: URL,
                  onNext: ((Data) -> Void)?,
                  onError: ((Error) -> Void)?) {
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60)
        let task = session.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let error = error {
                    onError?(error)
                } else if let data = data {
                    onNext?(data)
                } else {
                    onError?(OtherError.unowned)
                }
            })

        cacheURL(value: task, key: url.absoluteString)
        task.resume()
    }
}
