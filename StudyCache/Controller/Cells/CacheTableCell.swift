//
//  CacheTableCell.swift
//  StudyCache
//
//  Created by Nguyen Minh Duc on 13/12/2023.
//

import UIKit

class CacheTableCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    private var image: ImageModel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        if let url = image?.url {
            API.shared.cancel(URL(string: url))
            imgView.image = nil
        }
    }

    func bindingData(_ model: ImageModel) {
        image = model

//        if usingPinCache,
//           let data = PINCacheManager.shared
//            .object(forKey: model.url) as? Data {
//            loadingView.isHidden = true
//            loadingView.stopAnimating()
//            imgView.image = UIImage(data: data)
//        } else if !usingPinCache,
//                  let data = NSCacheManager.shared
//            .object(model.url) as? NSData {
//
//            loadingView.isHidden = true
//            loadingView.stopAnimating()
//            let image = UIImage(data: data as Data)
//            imgView.image = image
        if let image = AssetMemoryCache.shared
            .object(key: model.url) as? UIImage {
            loadingView.isHidden = true
            loadingView.stopAnimating()
            imgView.image = image
        } else if let url = URL(string: model.url) {
//        if let url = URL(string: model.url) {
            loadingView.isHidden = false
            loadingView.startAnimating()

            API.shared.getImage(
                url: url,
                onNext: { [weak self] data in
                    guard
                        let self = self,
                        let image = UIImage(data: data)
                    else { return }

                    AssetMemoryCache.shared
                        .saveObject(image, key: model.url, cost: data.count)

                    DispatchQueue.main.async {
                        self.loadingView.isHidden = true
                        self.loadingView.stopAnimating()
                        self.imgView.image = image
                    }
                },
                onError: { error in
                })
        }
    }
}
