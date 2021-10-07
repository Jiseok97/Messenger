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

// MARK: - 보내는 메세지 / 채팅
extension DatabaseManager {
    
    /*
     // RDB에 들어가는 데이터 형식
     
        "UserId" {
            "messages" : [
                {
                    "id" : String,
                    "type" : text, photo, video,
                    "content" : Date(),
                    "sender_email" : String,
                    "isRead" : true / false
                }
            ]
        }
     
         conversation => [
            [
                "conversation_id" : "UserId
                "other_user__email":
                "latest_message": => {
                    "date": Date()
                    "latest_message": "message"
                    "is_read" : true / false
                }
            ]
         ]
     */
    
    /// 새로운 채팅방을 만들기
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String : Any] else {
                completion(false)
                print("사용자를 찾지 못했습니다.")
                return
            }
            // Date() 값
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData : [String: Any] = [
                "id" : conversationId,
                "other_user_email": otherUserEmail,
                "name" : name,
                "latest_message" : [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // 최근 유저와의 채팅 배열이 존재함
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                   conversationID: conversationId,
                                                   firstMessage: firstMessage,
                                                   completion: completion)
                })
            } else {
                // 같은 채팅방이 존재하지 않음
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name,
                                                   conversationID: conversationId,
                                                   firstMessage: firstMessage,
                                                   completion: completion)
                    completion(true)
                })
            }
            
        })
        
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id" : String,
//            "type" : text, photo, video,
//            "content" : Date(),
//            "sender_email" : String,
//            "isRead" : true / false
//        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name" : name
        ]
        
        let value : [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// 이메일을 통해 해당 사용자와의 모든 대화를 반환
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        })
    }
    
    
    /// 해당 채팅의 모든 메세지(채팅 내역)을 가져옴
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            })
            
            completion(.success(messages))
        })
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
