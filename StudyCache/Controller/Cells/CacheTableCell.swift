import UIKit
import SDWebImage
import Kingfisher

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

    func bindingData(_ model: ImageModel) {
        image = model
        imgView.setASImage(model.url, cacheType: .onlyDisk)
    }

    func sdWebImage(_ model: ImageModel) {
        let url = URL(string: model.url)
        imgView?.sd_setImage(with: url)
    }

    func kingfisher(_ model: ImageModel) {
        let url = URL(string: model.url)
        imgView?.kf.setImage(with: url)
    }
}
