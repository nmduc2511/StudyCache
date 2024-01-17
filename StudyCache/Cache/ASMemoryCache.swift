import Foundation

class ASMemoryCache: NSObject {
    // MARK: - private variable
    private var objects: [String: Any]
    private var accessDates: [String: Date]
    private var costs: [String: Int]
    private var total: Int = 0
    private var queues: OperationQueue
    private var nslock: NSLock

    // MARK: - public variable
    var costLimit: Int = 0 * 1024 * 1024
    var ageLimit: Int = 0 * 60 * 60

    override init() {
        objects = [:]
        accessDates = [:]
        costs = [:]
        queues = OperationQueue()
        nslock = NSLock()
        super.init()
    }

    // MARK: - NSLock
    private func lock() {
        nslock.lock()
    }

    private func unlock() {
        nslock.unlock()
    }

    // MARK: - public function
    func saveObject(_ obj: Any, key: String) {
        let operation = BlockOperation { [weak self] in
            self?.setObject(obj, key: key, cost: 0)
        }
        queues.addOperation(operation)
    }

    func saveObject(_ obj: Any, key: String, cost: Int) {
        let operation = BlockOperation { [weak self] in
            self?.setObject(obj, key: key, cost: cost)
        }
        queues.addOperation(operation)
    }

    func object(key: String) -> Any? {
        lock()
        let now = Date()
        accessDates[key] = now
        let object = objects[key]
        unlock()
        return object
    }

    // MARK: - private function
    private func setObject(_ obj: Any, key: String, cost: Int) {
        lock()

        let now = Date()
        objects[key] = obj
        accessDates[key] = now
        costs[key] = cost

        if costLimit > 0 {
            total += cost
        }
        unlock()

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
}
