//
//  titleView.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/15.
//

import UIKit

class TitleViews{
    
    func dateTitleView(date: Date)-> UIView{
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "a hh:mm:ss"
        
        let titleLabel = UILabel()
        titleLabel.text = dateFormatter.string(from: date)
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = timeFormatter.string(from: date)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .gray
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical
        
        return stackView
    }
}
