//
//  ETActivityViewController.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/15.
//

import UIKit

extension UIActivityViewController{
    func picturesShareActivity(images: [UIImage], sourceView: UIView, completion: @escaping ()->())-> UIActivityViewController{
        let activityVC = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sourceView
//        activityVC.completionWithItemsHandler = completion
        
        return activityVC
    }
}
