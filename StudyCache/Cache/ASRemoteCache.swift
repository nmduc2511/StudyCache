import Foundation
import UIKit

enum ASError: Error {
    case unowned
}

final class ASRemoteCache: NSObject {
    private let session: URLSession

    override init() {
        session = URLSession(configuration: .default)
        super.init()
    }

    func getImage(url: URL,
                  onNext: ((Data) -> Void)?,
                  onError: ((Error) -> Void)?) {
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 30)
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
        task.resume()
    }
}
