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
    public func insertUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
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
}
