//
//  ViewController.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/07/31.
//

import UIKit
import Photos

class AlbumListVC: UIViewController {
    
    private var smartFetchResult:PHFetchResult<PHAssetCollection>!
    private var existIndex: [Int] = []
    private var albumFetchResult:PHFetchResult<PHAssetCollection>!
    private let imageManager: PHCachingImageManager = PHCachingImageManager()  //이미지 로드
    private let fetchOptions = PHFetchOptions()

    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewConfig()
        setPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.albumsCollectionView.collectionViewLayout = albumCompositionLayout()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)  //옵저버 해제
    }

}


//MARK: - CollectiuonView DataSource & delegate
extension AlbumListVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var albumCount = 0
        if let album = albumFetchResult{
            albumCount += album.count
        }
        return existIndex.count + albumCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: AlbumListCell.identifier, for: indexPath) as? AlbumListCell else{fatalError()}
        
        let fetchAsset = indexPath.item < existIndex.count ? PHAsset.fetchAssets(in: smartFetchResult[existIndex[indexPath.item]], options: fetchOptions) : PHAsset.fetchAssets(in: albumFetchResult[indexPath.item - existIndex.count], options: fetchOptions)
        if let asset = fetchAsset.firstObject{
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil, resultHandler: {image,_ in
                cell.preview.image = image
            })
        }
        cell.preview.layer.cornerRadius = 8
        cell.nameLabel.text = indexPath.item < existIndex.count ?  smartFetchResult[existIndex[indexPath.item]].localizedTitle : albumFetchResult[indexPath.item - existIndex.count].localizedTitle
        cell.countLabel.text = String(fetchAsset.count)
        
        return cell
    }
}

extension AlbumListVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextvc = self.storyboard?.instantiateViewController(identifier: "PictureListSB") as? PictureListVC else{return}
        nextvc.assetCollection = indexPath.item < existIndex.count ? self.smartFetchResult.object(at: existIndex[indexPath.item]) : self.albumFetchResult.object(at: indexPath.item - existIndex.count)
        
        self.navigationController?.pushViewController(nextvc, animated: true)
    }
}

//MARK: - Photos
extension AlbumListVC: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("Photo Library Changed")
        requestCollection() //2번째 실행되는 requestCollection, 초기에 실행시 범위 에러 => collection.reloadData 중복 오류
    }
}

//MARK: - Function
extension AlbumListVC{
    func setPhotos(){
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]  //최신순 정렬
        PhotosManager.shared.authorization(completion: {
            self.requestCollection()
        })
        PHPhotoLibrary.shared().register(self)  //옵저버 등록
    }

    func requestCollection(){
        smartFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        existIndex.removeAll()
        if smartFetchResult.count > 0 {
            for i in 0..<smartFetchResult.count {
                let fetchAsset = PHAsset.fetchAssets(in: smartFetchResult[i], options: nil)
                if fetchAsset.count > 0 {
                    existIndex.append(i)
                }
            }
        }
        albumFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        DispatchQueue.main.async(execute: {
            self.albumsCollectionView.reloadData()
        })
    }
}

//MARK: - SETUP
extension AlbumListVC{
    private func setViewConfig(){
        self.title = "앨범"
        navigationController?.navigationBar.prefersLargeTitles = true
        setCollectionView()
    }
    
    private func setCollectionView(){
        albumsCollectionView.register(UINib(nibName: "AlbumListCell", bundle: nil), forCellWithReuseIdentifier: AlbumListCell.identifier)
        albumsCollectionView.dataSource = self
        albumsCollectionView.delegate = self
        albumsCollectionView.collectionViewLayout = albumCompositionLayout()
    }
}
