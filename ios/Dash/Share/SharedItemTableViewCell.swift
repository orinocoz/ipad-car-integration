//
//  SharedItemTableViewCell.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/02/04.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import UIKit
import PINRemoteImage

class SharedItemTableViewCell: UITableViewCell {
    enum IconType {
        case template
        case image
    }

    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    @IBOutlet weak var iconImageViewSmallWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewSmallHeightConstraint: NSLayoutConstraint!

    @IBOutlet var iconImageViewNoMarginConstraints: [NSLayoutConstraint]!

    override func awakeFromNib() {
        // Not sure why but constraints are reset to Storyboard's state when app goes background and back to foreground
        // https://stackoverflow.com/questions/58376388/constraints-resets-when-app-is-going-in-background-ios-13
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.setNeedsUpdateConstraints()
        }
    }

    var item: SharedItemProtocol? {
        didSet {
            switch item {
            case let location as Location:
                iconType = .template
                iconImageView.image = UIImage(systemName: "mappin")
                iconBackgroundView.backgroundColor = UIColor(named: "Location Icon Color")
                nameLabel.text = location.name
                detailLabel.text = location.url.absoluteString
            case let website as Website:
                if let iconURL = website.icon.url {
                    setRemoteImage(url: iconURL)
                } else {
                    iconType = .template
                    iconImageView.image = UIImage(systemName: "safari.fill")
                    iconBackgroundView.backgroundColor = .systemBlue

                    website.icon.getURL { (result) in
                        switch result {
                        case .success(let url):
                            self.setRemoteImage(url: url)
                        default:
                            break
                        }
                    }
                }

                nameLabel.text = website.title
                detailLabel.text = website.url.absoluteString
            default:
                iconType = .template
                iconImageView.image = UIImage(systemName: "questionmark")
                iconBackgroundView.backgroundColor = .gray
                nameLabel.text = "不明なアイテム"
                detailLabel.text = nil
            }
        }
    }

    func setRemoteImage(url: URL) {
        DispatchQueue.main.async {
            self.iconImageView.pin_setImage(from: url) { (result) in
                self.iconType = .image
                self.iconBackgroundView.backgroundColor = .white
            }
        }
    }

    var iconType: IconType = .template {
        didSet {
            switch iconType {
            case .template:
                iconImageView.contentMode = .scaleAspectFit
            case .image:
                iconImageView.contentMode = .scaleAspectFill
            }

            if iconType != oldValue {
                setNeedsUpdateConstraints()
            }
        }
    }

    override func updateConstraints() {
        switch iconType {
        case .template:
            NSLayoutConstraint.deactivate(iconImageViewNoMarginConstraints)
            iconImageViewSmallWidthConstraint.isActive = true
            iconImageViewSmallHeightConstraint.isActive = true
        case .image:
            iconImageViewSmallWidthConstraint.isActive = false
            iconImageViewSmallHeightConstraint.isActive = false
            NSLayoutConstraint.activate(iconImageViewNoMarginConstraints)
        }

        super.updateConstraints()
    }
}
