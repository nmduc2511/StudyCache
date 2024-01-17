//
//  ViewController.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 12/12/2023.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    
    var images = [ImageModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshBtn = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(onTouchRefresh))
        navigationItem.rightBarButtonItem = refreshBtn
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CacheTableCell", bundle: nil),
                           forCellReuseIdentifier: "CacheTableCell")

        getImages()
    }

    private func getImages() {
        if let url = URL(string: "https://picsum.photos/v2/list?page=1&limit=100") {
            API.shared.getData(
                url: url,
                onNext: { dict in
                    self.images = dict.map({ ImageModel($0) })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }, onError: { error in
                    print("===> erorr: \(error.localizedDescription)")
                })
        }
    }

    @objc func onTouchRefresh() {
        NSCacheManager.shared.clearAll()
        PINCacheManager.shared.removeAllObjects()
        tableView.reloadData()
        getImages()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CacheTableCell", for: indexPath) as? CacheTableCell
        let image = images[indexPath.row]
        
        switch cachingType {
        case .custom:
            cell?.custom(image)
        case .pinCache:
            cell?.pinCache(image)
        }
        return cell ?? CacheTableCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
