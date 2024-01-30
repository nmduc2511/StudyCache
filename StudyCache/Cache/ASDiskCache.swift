import Foundation

struct ASDiskAttribute: Codable {
    var size: Int
    var createDates: Date
    var modifiDates: Date

    var string: String {
        return "create: \(createDates) - modifi: \(modifiDates) - size: \(size)"
    }
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
    private let domain = Bundle.main.bundleIdentifier!
    private lazy var cacheURL: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
            .appendingPathComponent(domain)
            .appendingPathComponent("asCache")
    }()

    // MARK: - public variable
    var costLimit: Int = 0 * 1024 * 1024
    var ageLimit: Int = 0 * 60 * 60

    override init() {
        objects = [:]
        accessDates = [:]
        costs = [:]
        attributes = [:]
        queues = OperationQueue()
        queues.maxConcurrentOperationCount = 10
        nslock = NSLock()
        super.init()
        setupDirectory()
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
            print("ASDiskError ===> getObject: \(error.localizedDescription)")
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
    private func setupDirectory() {
        print("Connected ===> Directory: \(cacheURL.absoluteString)")
        if fileManager.fileExists(atPath: cacheURL.path) {
            print("Status ===> Ready")
            syncAttributesFromDisk()
        } else {
            do {
                print("Create ===> Directory ......0%")
                try fileManager.createDirectory(
                    at: cacheURL,
                    withIntermediateDirectories: true
                )
                print("Create ===> Directory ......100%")
                print("Status ===> Ready")
            } catch {
                print("Create ===> Directory ......false")
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    private func syncAttributesFromDisk() {
        lock()
        
        fileManager
            .enumerator(atPath: cacheURL.path)?
            .filter({ ($0 as? String) != nil })
            .map({ $0 as! String })
            .forEach({ filePath in
                guard
                    let fileAttributes = try? fileManager.attributesOfItem(
                        atPath: cacheURL.appendingPathComponent(filePath).path)
                else { return }

                if let size = fileAttributes[.size] as? Int,
                   let cDate = fileAttributes[.creationDate] as? Date,
                   let mDate = fileAttributes[.modificationDate] as? Date {

                    let attribute = ASDiskAttribute(
                        size: size,
                        createDates: cDate,
                        modifiDates: mDate)
                    attributes[filePath] = attribute
                    total += size
                }
            })
        
        unlock()
    }

    private func setObject(_ obj: Any,
                           key: String,
                           cost: Int) {
        guard !attributes.keys.contains(key) else { return }
        
        lock()
        print("=====================================================================")
        print("Key: \(key)\nSize: \(cost)\nTotal: \(total)\n")
        print("Database Before:\n\(attributes.map({ [$0.key: $0.value.modifiDates] }))\n")

        let now = Date()
        attributes[key] = ASDiskAttribute(
            size: cost,
            createDates: now,
            modifiDates: now
        )
        costs[key] = cost
        print("Database After:\n\(attributes.map({ [$0.key: $0.value.modifiDates] }))\n")
        
        if costLimit > 0 {
            total += cost
        }

        unlock()

        writeToDisk(obj, key: key)

        if costLimit > 0,
           total > costLimit {
            print("Database Reach Maximum:\nLimit: \(costLimit)\nTotal: \(total)")
            deleteObjectsByDate()
        }
    }

    private func deleteObjectsByDate() {
        let block = BlockOperation { [weak self] in
            guard let self = self else { return }
            self.lock()
            print("=====================================================================")
            print("Start Delete ..............")
            let dates = Array(attributes)
                .sorted(by: { $0.value.modifiDates < $1.value.modifiDates })

            print("Database Before:\n\(dates.map({ [$0.key: $0.value.modifiDates] }))\n")
            for dict in dates {
                do {
                    let path = self.cacheURL.appendingPathComponent(dict.key.asTrim())
                    guard self.fileManager.fileExists(atPath: path.path) else {
                        return
                    }

                    try self.fileManager.removeItem(at: path)
                    let cost = attributes[dict.key]?.size ?? 0
                    self.costs.removeValue(forKey: dict.key)
                    self.attributes.removeValue(forKey: dict.key)
                    self.total -= cost
                    if self.total < self.costLimit {
                        break
                    }
                } catch {
                    print("Delete ===> Key: \(dict.key.asTrim()) ===> FALSE")
                    print("Error: \(error.localizedDescription)")
                }
            }

            let after = Array(attributes)
                .sorted(by: { $0.value.modifiDates < $1.value.modifiDates })
            print("Database After:\n\(after.map({ [$0.key: $0.value.modifiDates] }))\n")
            print("Delete Completed ..............")
            self.unlock()
        }
        queues.addOperation(block)
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
}
