//
//  RepositoryCell.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import UIKit
import Kingfisher

class RepositoryCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var avatarWrapperView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarContainerView.layer.cornerRadius = 6
        avatarView.layer.cornerRadius = 42
        avatarWrapperView.layer.cornerRadius = 42
    }
    
    func apply(_ user: User) {
        nameLabel.text = user.login
        urlLabel.text = user.url
        let url = URL(string: user.avatarURL)
        avatarView.kf.setImage(with: url)
    }

}
