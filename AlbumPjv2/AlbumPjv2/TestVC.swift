//
//  TestVC.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit

class TestVC: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewConfig()
    }
    

}

//MARK: - UICollectionViewDataSource
extension TestVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: AlbumListCell.identifier, for: indexPath) as? AlbumListCell else{fatalError()}
        
        cell.backgroundColor = .brown
        
        return cell
    }
}
//MARK: - Function
extension TestVC{
    
}

//MARK: - SETUP
extension TestVC{
    private func setViewConfig(){
        myCollectionView.register(UINib(nibName: "AlbumListCell", bundle: nil), forCellWithReuseIdentifier: AlbumListCell.identifier)
        myCollectionView.dataSource = self
        myCollectionView.collectionViewLayout = albumCompositionLayout()
    }
}
