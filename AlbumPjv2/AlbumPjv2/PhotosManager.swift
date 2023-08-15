//
//  PhotosManager.swift
//  AlbumPjv2
//
//  Created by 이태형 on 2023/08/01.
//

import UIKit
import Photos

class PhotosManager{
    static let shared = PhotosManager()
    
    func authorization(completion: @escaping ()-> ()){
        switch PHPhotoLibrary.authorizationStatus(){
        case .notDetermined:
            print("아직 응답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in //사용자에게 허가 요청
                switch status {
                case .authorized:
                    print("사용자가 허용함")
                    completion()
                case .denied:
                    print("사용자가 불허함")
                default:
                    break
                }
            })
        case .authorized:
            print("접근 허가됨")
            completion()
        case .restricted:
            print("접근제한")
        case .denied:
            print("접근 불허")
        default:
            print("접근권한 에러")
        }
    }
    
}
