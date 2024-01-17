import Foundation

struct ASDiskAttribute: Codable {
    var size: Int
    var data: Data
    var createDates: Date
}

class ASDiskCache: NSObject {
    // MARK: - private variable
    private var objects: [String: Any]
    private var accessDates: [String: Date]
    private var costs: [String: Int]
    private var attributes: [String: ASDiskAttribute]
    private var total: Int = 0
    private var queues: OperationQueue
    private var nslock: NSLock

    private let fileManager = FileManager.default
    private let domain = "com.duc.StudyCache"
    private lazy var cacheURL: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
            .appendingPathComponent(domain)
            .appendingPathComponent("asCache")
    }()

    // MARK: - public variable
    var costLimit: Int = 0 * 1024 * 1024 {
        didSet {
//            clearDiskIfNeed()
        }
    }
    var ageLimit: Int = 0 * 60 * 60

    override init() {
        objects = [:]
        accessDates = [:]
        costs = [:]
        attributes = [:]
        queues = OperationQueue()
        nslock = NSLock()
        super.init()
        createDirectory()
        clearDiskIfNeed()
    }

    // MARK: - NSLock
    private func lock() {
        nslock.lock()
    }

    private func unlock() {
        nslock.unlock()
    }

    func object(key: String) -> Any? {
        let path = cacheURL.appendingPathComponent(key.asTrim())
        guard let data = try? Data(contentsOf: path) else { return nil }
        do {
            try self.fileManager.setAttributes(
                [.modificationDate : Date()],
                ofItemAtPath: path.path)

        } catch {
            print("Attribute: \(error.localizedDescription)")
        }

        return data
    }

    func saveObject(_ obj: Any, key: String, cost: Int) {
        let block = BlockOperation {
            self.setObject(obj, key: key, cost: cost)
        }
        queues.addOperation(block)
    }

    // MARK: - private function
    private func createDirectory() {
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
    }

    private func clearDiskIfNeed() {
        var totalSize: Int = 0
        var datas = [String: Data]()
        fileManager
            .enumerator(atPath: cacheURL.path)?
            .filter({ ($0 as? String) != nil })
            .map({ $0 as! String })
            .forEach({ filePath in
                guard
                    let fileAttributes = try? fileManager.attributesOfItem(
                        atPath: cacheURL.appendingPathComponent(filePath).path),
                    let data = try? Data(
                        contentsOf: cacheURL.appendingPathComponent(filePath))
                else { return }

                if let fileSize = fileAttributes[.size] as? Int {
                    totalSize += fileSize
                }

                if let date = fileAttributes[.modificationDate] as? Date {
                    print("~~~ date: \(date)")
                }

                datas[filePath] = data
            })

//        guard totalSize > costLimit else { return }
//        for (key, value) in datas {
//            do {
//                try fileManager.removeItem(
//                    at: cacheURL.appendingPathComponent(key))
//
//                totalSize -= value.count
//                if totalSize < costLimit {
//                    total = totalSize
////                    print("~~~ storageTotal2: \(totalSize)")
//                    break
//                }
////                print("~~~ storageTotal1: \(totalSize)")
//            } catch {
////                print("~~~ clearDiskIfNeed: \(error.localizedDescription)")
//            }
//        }
    }

    private func setObject(_ obj: Any, key: String, cost: Int) {
        lock()

        let now = Date()
        objects[key] = obj
        accessDates[key] = now
        costs[key] = cost

        if costLimit > 0 {
            total += cost
        }

//        print("~~~ diskTotal: \(total)")
        unlock()

        writeToDisk(obj, key: key)

        if costLimit > 0 {
            deleteObjectsByDate()
        }
    }

    private func deleteObject(byKey key: String) {
        lock()

        let cost = costs[key] ?? 0
        objects.removeValue(forKey: key)
        accessDates.removeValue(forKey: key)
        costs.removeValue(forKey: key)

        removeFromDisk(key: key)

        if costLimit > 0 {
            total -= cost
        }

        unlock()
    }

    private func deleteObjectsByDate() {
        guard total > costLimit else { return }

        lock()
        let dates = accessDates.sorted(by: { $0.value < $1.value })
        unlock()

        for dict in dates {
            self.deleteObject(byKey: dict.key)

            if total < costLimit {
                break
            }
        }
    }

    private func writeToDisk(_ obj: Any, key: String) {
        guard let data = obj as? Data else { return }

        let block = BlockOperation {
            do {
                self.lock()
                let path = self.cacheURL.appendingPathComponent(key.asTrim())

                try data.write(to: path, options: .withoutOverwriting)
                self.unlock()
            } catch {
                self.unlock()
                print("ASDiskError ===> Write: \(error.localizedDescription) - url: \(key)")
            }
        }

        queues.addOperation(block)
    }

    private func removeFromDisk(key: String) {
        let block = BlockOperation {
            do {
                self.lock()
                let edit = key
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "/", with: "-")
                let path = self.cacheURL.appendingPathComponent(edit)

                try self.fileManager.removeItem(at: path)
                self.unlock()
            } catch {
//                print("ASDiskError ===> Remove: \(error.localizedDescription) - url: \(key)")
            }
        }

        queues.addOperation(block)
    }
}
