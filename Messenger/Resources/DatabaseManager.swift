//
//  DatabaseManager.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/16.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: 계정 관리
extension DatabaseManager {
    
    // DB에서 데이터를 가져오는 함수가 동기식으로 완료가 필요 -> 완료 핸들러 넣어줌
    // 사용자 이메일이 존재하지 않으면 true 반환
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        // 특수기호 에러를 없애기 위해...
        // . & @가 에러를 발생시킴으로 - 이걸로 대체
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                // 이메일이 존재하지 않는 경우
                completion(false)
                return
            }
            
            completion(true)
            
        })
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("데이터 베이스를 읽는데 실패하였습니다.")
                completion(false)
                return
            }
            
            /*
             users => [
                [
                    "name":
                    "safe_email":
                ],
                [
                    "name":
                    "safe_email":
                ]
             ]
             */
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // 유저를 딕셔너리 형식으로 append
                    let newElement = [
                        "name": user.firstName + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    // array 생성
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }

    public enum DatabaseError: Error {
        case failedToFetch
    }
}


// MARK: - 보내는 메세지 / 채팅
extension DatabaseManager {
    /// 새로운 채팅방을 만들기
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    /// 이메일을 통해 해당 사용자와의 모든 대화를 반환
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    
    /// 해당 채팅의 모든 메세지(채팅 내역)을 가져옴
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    
    
    /// 상대방에게 메세지를 보내는 기능
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}



struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    // 특수기호 에러를 없애기 위해...
    // . & @가 에러를 발생시킴으로 - 이걸로 대체
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        // /images/js-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
