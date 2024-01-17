import Foundation

class ASCache: NSObject {
    static let shared = ASCache()
    
    private let disk: ASDiskCache
    private let memory: ASMemoryCache
    private let remote: ASRemoteCache

    override init() {
        memory = ASMemoryCache()
        memory.costLimit = 50 * 1024 * 1024
        disk = ASDiskCache()
        disk.costLimit = 10 * 1024 * 1024
        remote = ASRemoteCache()
        super.init()
    }
    
    func getImage(_ url: URL,
                  cacheType type: ASCacheType,
                  completion: ((Data) -> Void)?) {

        switch type {
        case .ramAndDisk:
            if let data = memory
                .object(key: url.absoluteString) as? Data {
                completion?(data)
                return
            }
        case .onlyDisk:
            if let data = disk
                .object(key: url.absoluteString) as? Data {
                completion?(data)
                return
            }
        }

        
        remote.getImage(
            url: url,
            onNext: { [weak self] data in
                guard let self = self else { return }
                completion?(data)
                self.setData(data, key: url.absoluteString, cacheType: type)
            },
            onError: { error in
                print("ASImageError: \(error.localizedDescription) - url: \(url.absoluteString)")
            })
    }
    
    private func setData(_ data: Data,
                         key: String,
                         cacheType: ASCacheType) {
        switch cacheType {
        case .ramAndDisk:
            memory.saveObject(data, key: key, cost: data.count)
        case .onlyDisk:
            disk.saveObject(data, key: key, cost: data.count)
        }
    }
}
