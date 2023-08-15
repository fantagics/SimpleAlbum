//
//  PictureDetailVC.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit
import Photos

class PictureDetailVC: UIViewController {
    var asset: PHAsset!
    private let imageManager: PHImageManager = PHImageManager()
    private var popoverController: UIPopoverPresentationController?
    
    private let titleVM = TitleViews()
    
    private let zoomableScrollView = UIScrollView()
    private let imageView  = UIImageView()
    private let toolBar = UIToolbar()
    private let shareItem = UIBarButtonItem()
    private let favoriteItem = UIBarButtonItem()
    private let trashItem = UIBarButtonItem()
    
    private var deletedAsset = false
    private var toolbarHidden = false{
        didSet{
            self.navigationController?.isNavigationBarHidden = toolbarHidden
            self.toolBar.isHidden = toolbarHidden
//            self.zoomableScrollView.backgroundColor = toolbarHidden ? .black : .white
            self.view.backgroundColor = toolbarHidden ? .black : .white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewConfig()
        setTitleView()
        updateFavorite()
        loadImage()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)  //옵저버 해제
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let popoverController = self.popoverController{
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: size.width*0.5, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
    }
}

//MARK: - UIScrollViewDelegate
extension PictureDetailVC: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        toolbarHidden = true
    }
}
    
//MARK: - Photos
extension PictureDetailVC: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: asset) else{return}
        
        DispatchQueue.main.async {
            if changes.objectAfterChanges == nil{ //현재 사진이 외부로부터 삭제된다면
                self.navigationController?.popViewController(animated: true)
            }else{
                self.asset = changes.objectAfterChanges
                if self.deletedAsset{  //현재 앱에서 현재 사진을 직접 삭제하는 경우
                    self.navigationController?.popViewController(animated: true)
                }else{  //그외: favorite,..
//                    self.loadImage()
                    self.updateFavorite()
                }
            }
        }
    }
}

//MARK: - Function
extension PictureDetailVC{
    private func setTitleView(){
        if let creationDate = asset.creationDate{
            self.navigationItem.titleView = titleVM.dateTitleView(date: creationDate)
        }
    }
    private func updateFavorite(){
        favoriteItem.tintColor = asset.isFavorite ? .red : .black
    }
//    private func loadImage()-> UIImage{
//        var img = UIImage()
//        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
//            img = image ?? UIImage()
//        })
//        return img
//    }
    private func loadImage(){
        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
            self.imageView.image = image
        })
    }
    
    @objc private func didTapGesture(_ sender: UITapGestureRecognizer){
        toolbarHidden.toggle()
    }
    
    @objc private func didTapShareItem(_ sender: UIBarButtonItem){
        guard let img = imageView.image else{
            print("Share Image Fail..")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activity, success, items, error) in
            if success{
                print("Share Success")
            }else{
                print("Share Cancel")
            }
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
        present(activityVC, animated: true)
    }
    
    @objc private func didTapFavoriteItem(_ sender: UIBarButtonItem){
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest(for: self.asset)
            req.isFavorite = !self.asset.isFavorite
        }){ (success, error) in
            if success { print("Favorite Changed: \(self.asset.isFavorite)") }
        }
        updateFavorite()
    }
    
    @objc private func didTapTrashItem(_ sender: UIBarButtonItem){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([self.asset!] as NSArray)
        }, completionHandler: {success, error in
            if success {
                self.deletedAsset = true
            }
        })
    }
}

//MARK: - SETUP
extension PictureDetailVC{
    private func setViewConfig(){
        setAttribute()
        setUI()
    }
    
    private func setAttribute(){
        self.view.backgroundColor = .white
        
        [zoomableScrollView].forEach{
            $0.backgroundColor = .clear
            $0.delegate = self
            $0.minimumZoomScale = 1.0
            $0.maximumZoomScale = 2.0
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGesture(_:)))
            $0.addGestureRecognizer(tapGesture)
        }
        
        [imageView].forEach{
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFit
        }
        
        toolBar.backgroundColor = .white
        
        [shareItem].forEach{
            $0.image = UIImage(systemName: "square.and.arrow.up")
            $0.target = self
            $0.action = #selector(didTapShareItem(_:))
        }
        
        [favoriteItem].forEach{
            $0.image = UIImage(systemName: "heart.fill")
            $0.target = self
            $0.action = #selector(didTapFavoriteItem(_:))
        }
        
        [trashItem].forEach{
            $0.image = UIImage(systemName: "trash")
            $0.target = self
            $0.action = #selector(didTapTrashItem(_:))
            
        }
    }
    
    private func setUI(){
        [toolBar, zoomableScrollView, imageView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        self.view.addSubview(zoomableScrollView)
        zoomableScrollView.addSubview(imageView)
        self.view.addSubview(toolBar)
        
        toolBar.items = [shareItem,
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         favoriteItem,
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         trashItem]
        
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            zoomableScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            zoomableScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            zoomableScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            zoomableScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: zoomableScrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: zoomableScrollView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: zoomableScrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: zoomableScrollView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: zoomableScrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: zoomableScrollView.heightAnchor),
        ])
    }
}
