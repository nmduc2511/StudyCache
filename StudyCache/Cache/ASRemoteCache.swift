import Foundation
import UIKit

enum ASError: Error {
    case unowned
}

final class ASRemoteCache: NSObject {
    static let shared = ASRemoteCache()
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

    func getImage(url: URL,
                  onNext: ((Data) -> Void)?,
                  onError: ((Error) -> Void)?) {
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60)
        let task = session.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let data = data {
                    onNext?(data)
                } else if let error = error {
                    onError?(error)
                } else {
                    onError?(ASError.unowned)
                }
            })

        cacheURL(value: task, key: url.absoluteString)
        task.resume()
    }
}
