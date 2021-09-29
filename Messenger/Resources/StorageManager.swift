//
//  StorageManager.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/26.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     이미지 형식
      /images/js-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    /// Firebase storage의 사진을 업로드 및 다운로드 url을 String으로 반환
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metaData, error in
            guard error == nil else {
                // 실패
                print("Fireabse에 사진 업로드를 실패하였습니다.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("다운로드 url을 가져오는데 실패하였습니다.")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("다운로드 url : \(urlString)")
                completion(.success(urlString))
            })
            
            
        })
        
    }
    
    
    public enum StorageErrors : Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
