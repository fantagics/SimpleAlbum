//
//  LayoutOfCollection.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit

func albumCompositionLayout()-> UICollectionViewLayout{
    let layout = UICollectionViewCompositionalLayout{
        (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)-> NSCollectionLayoutSection? in
        //Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets.zero
        
        //Group (row)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.fractionalWidth(5/8))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        //Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.zero
        
        return section
    }
    return layout
}

func pictureFlowLayout()-> UICollectionViewLayout{
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let length: CGFloat = (UIScreen.main.bounds.size.width - 40) / 3.0
    layout.itemSize = CGSize(width: length, height: length)
    return layout
}
