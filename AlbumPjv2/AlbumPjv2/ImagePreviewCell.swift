//
//  ImagePreviewCell.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit

class ImagePreviewCell: UICollectionViewCell {
    static let identifier = String(describing: ImagePreviewCell.self)
    
    @IBOutlet weak var preview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
