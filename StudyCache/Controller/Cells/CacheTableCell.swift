import UIKit
import AssetsCaching

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
        imgView.setASImage(model.url)
    }
}
