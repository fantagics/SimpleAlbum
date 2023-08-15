//
//  AlbumListCell.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit

class AlbumListCell: UICollectionViewCell {
    static let identifier = String(describing: AlbumListCell.self)
    
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
