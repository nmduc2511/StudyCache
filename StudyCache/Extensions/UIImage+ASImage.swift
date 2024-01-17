import UIKit

enum ASCacheType {
    case ramAndDisk
    case onlyDisk
}

extension UIImageView {
    func setASImage(_ url: String?,
                    cacheType: ASCacheType = .ramAndDisk) {
        guard
            let path = url,
            !path.isEmpty,
            let _url = URL(string: path)
        else { return }
        
        switch cacheType {
        case .ramAndDisk:
            setASImageInRamAndDisk(_url)
        case .onlyDisk:
            setASImageInOnlyDisk(_url)
        }
    }
    
    private func setASImageInRamAndDisk(_ url: URL) {
        func setImage(from data: Data) {
            DispatchQueue.global(qos: .background).asyncAndWait {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        
        ASCache.shared
            .getImage(url, cacheType: .ramAndDisk) { data in
                setImage(from: data)
            }
    }
    
    private func setASImageInOnlyDisk(_ url: URL) {
        func setImage(from data: Data) {
            DispatchQueue.global(qos: .background).asyncAndWait {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }

        ASCache.shared
            .getImage(url, cacheType: .onlyDisk) { data in
                setImage(from: data)
            }
    }
}
