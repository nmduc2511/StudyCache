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
        loadingView.isHidden = true
    }

    override func prepareForReuse() {
        imgView.image = nil
    }

    func custom(_ model: ImageModel) {
        image = model
        imgView.setASImage(model.url, cacheType: .onlyDisk)
    }
    
    func pinCache(_ model: ImageModel) {
        image = model

        if let data = PINCacheManager.shared
            .object(forKey: model.url) as? Data {
            loadingView.isHidden = true
            loadingView.stopAnimating()
            imgView.image = UIImage(data: data)
        } else if let url = URL(string: model.url) {
            loadingView.isHidden = false
            loadingView.startAnimating()

            API.shared.getImage(
                url: url,
                onNext: { [weak self] data in
                    guard
                        let self = self,
                        let image = UIImage(data: data)
                    else { return }

                    PINCacheManager.shared
                        .setData(data, forKey: url.absoluteString)

                    DispatchQueue.main.async {
                        self.loadingView.isHidden = true
                        self.loadingView.stopAnimating()
                        self.imgView.image = image
                    }
                },
                onError: { error in })
        }
    }
}
