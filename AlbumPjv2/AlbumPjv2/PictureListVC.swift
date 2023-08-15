//
//  PictureListVC.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit
import Photos

class PictureListVC: UIViewController {
    var assetCollection: PHAssetCollection!  //selected AssetCollection
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var fetchResult: PHFetchResult<PHAsset>!  //Fetch Asset from AssetCollection
    private let fetchOptions = PHFetchOptions()  //fetchOptions
    
    private var popoverController: UIPopoverPresentationController?
    private var lastestOrder = true
    private var selectMode = false
    private var selectedList = [Int]()
    private var isDeleted = false

    @IBOutlet weak var picturesCollectionView: UICollectionView!
    @IBOutlet weak var selectModeItem: UIBarButtonItem!
    @IBOutlet weak var orderItem: UIBarButtonItem!
    @IBOutlet weak var shareItem: UIBarButtonItem!
    @IBOutlet weak var trashItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewConfig()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let popoverController = self.popoverController{
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: size.width*0.5, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        picturesCollectionView.collectionViewLayout = pictureFlowLayout()
    }
}

//MARK: - CollectiuonView DataSource & delegate
extension PictureListVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loadPictures()
        return PHAsset.fetchAssets(in: assetCollection, options: nil).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = picturesCollectionView.dequeueReusableCell(withReuseIdentifier: ImagePreviewCell.identifier, for: indexPath) as? ImagePreviewCell else{fatalError()}
        
        imageManager.requestImage(for: fetchResult.object(at: indexPath.item),
                                  targetSize: CGSize(width: 200, height: 200),
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: { img, _ in
            cell.preview.image = img
        })
        cell.preview.alpha = 1
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        return cell
    }
}
extension PictureListVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectMode{
            let cell = collectionView.cellForItem(at: indexPath) as? ImagePreviewCell
            if !selectedList.contains(indexPath.item){
                cell?.preview.alpha = 0.6
                cell?.layer.borderWidth = 3
                cell?.layer.borderColor = UIColor.black.cgColor
                selectedList.append(indexPath.item)
                if selectedList.count == 1{
                    shareItem.isEnabled = true
                    trashItem.isEnabled = true
                }
            }
            else{
                cell?.preview.alpha = 1
                cell?.layer.borderWidth = 0
                cell?.layer.borderColor = UIColor.clear.cgColor
                selectedList.remove(at: selectedList.firstIndex(of: indexPath.item)!)
                if selectedList.count < 1 {
                    shareItem.isEnabled = false
                    trashItem.isEnabled = false
                }
            }
            self.navigationItem.title = "\(selectedList.count)장 선택"
        }
        else{
            guard let nextvc = self.storyboard?.instantiateViewController(identifier: "PictureDetailSB") as? PictureDetailVC else{return}
            nextvc.asset = self.fetchResult[indexPath.item]
            self.navigationController?.pushViewController(nextvc, animated: true)
        }
    }
}

//MARK: - Photos
extension PictureListVC: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else{ return }
        fetchResult = changes.fetchResultAfterChanges
        DispatchQueue.main.async {
            if self.isDeleted {
                self.selectMode = false
                self.selectModeItem.title = "선택"
                self.navigationItem.title = self.assetCollection.localizedTitle
                self.orderItem.isEnabled = true
                self.selectedList.removeAll()
                self.shareItem.isEnabled = false
                self.trashItem.isEnabled = false
                self.isDeleted = false
            }
            self.picturesCollectionView.reloadData()
        }
    }
}

//MARK: - Function
extension PictureListVC{
    private func loadPictures(){
        self.fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !lastestOrder)]
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
    }
    //MARK: Button Action
    @objc private func didTapSelectButton(_ sender: UIBarButtonItem){
        if selectMode{
            selectModeItem.title = "선택"
            self.navigationItem.title = assetCollection.localizedTitle
            selectedList.removeAll()
            picturesCollectionView.reloadData()
            orderItem.isEnabled = true
            shareItem.isEnabled = false
            trashItem.isEnabled = false
        }
        else{
            selectModeItem.title = "취소"
            self.navigationItem.title = "항목 선택"
            orderItem.isEnabled = false
            shareItem.isEnabled = true
            trashItem.isEnabled = true
        }
        selectMode.toggle()
    }
    @objc private func didTapShareButton(_ sender: UIBarButtonItem){
        var shareAsset = [UIImage]()
        for item in selectedList {
            let asset: PHAsset = fetchResult.object(at: item)
            imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
                shareAsset.append(image!)
            })
        }
        
        let activityVC = UIActivityViewController(activityItems: shareAsset, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activity, success, items, error) in
            if success{
                self.selectModeItem.title = "선택"
                self.navigationItem.title = self.assetCollection.localizedTitle
                self.selectMode = false
                self.selectedList.removeAll()
                self.orderItem.isEnabled = true
                self.shareItem.isEnabled = false
                self.trashItem.isEnabled = false
                self.picturesCollectionView.reloadData()
            }else{ print("ActivityVC Completion Failed..") }
            if let error = error{
                print(error.localizedDescription)
            }
        }
        if let popoverController = activityVC.popoverPresentationController{
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            self.popoverController = popoverController
        }
        present(activityVC,animated: true)
    }
    @objc private func didTapOrderButton(_ sender: UIBarButtonItem){
        orderItem.title = lastestOrder ? "과거순" : "최신순"
        lastestOrder.toggle()
        self.picturesCollectionView.reloadData()
    }
    @objc private func didTapTrashButton(_ sender: UIBarButtonItem){
        var deleteAssets = [PHAsset]()
        selectedList.forEach{ deleteAssets.append(self.fetchResult[$0]) }
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(deleteAssets as NSArray)}){ (success, error) in
            if success{
                self.isDeleted = true
            }
        }
    }
}

//MARK: - SETUP
extension PictureListVC{
    private func setViewConfig(){
        setNavigation()
        setUI()
    }
    
    private func setNavigation(){
        self.title = assetCollection.localizedTitle
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setUI(){
        [picturesCollectionView].forEach{
            $0?.register(UINib(nibName: "ImagePreviewCell", bundle: nil), forCellWithReuseIdentifier: ImagePreviewCell.identifier)
            $0?.dataSource = self
            $0?.delegate = self
            $0?.collectionViewLayout = pictureFlowLayout()
        }
        
        [selectModeItem, shareItem, trashItem, orderItem].forEach{
            $0?.target = self
        }
        selectModeItem.action = #selector(didTapSelectButton(_:))
        shareItem.action = #selector(didTapShareButton(_:))
        trashItem.action = #selector(didTapTrashButton(_:))
        orderItem.action = #selector(didTapOrderButton(_:))
        shareItem.isEnabled = false
        trashItem.isEnabled = false
    }
}
