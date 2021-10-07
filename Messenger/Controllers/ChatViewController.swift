//
//  ChatViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/24.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
   public var sender: SenderType   // 발신자
   public var messageId: String   // 중복 제거를 위한 시벽자
   public var sentDate: Date      // 보낸 날짜
   public var kind: MessageKind    // 사진, 이모지, 음성메세지 등등 여러타입 존재
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
            
        }
    }
}

struct Sender: SenderType {
   public var photoURL : String
   public var senderId: String
   public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        
        return formatter
    }()
    
    public let otherUserEmail : String
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        return Sender(photoURL: "",
               senderId: email,
               displayName: "지석이")
    }
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .link
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
            
        }
        // text → 유저가 친 메세지
        
        print("sending: \(text)")
        
        // 메세지 보내기
        if isNewConversation {
            // DB에 새 채팅 만들기
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                 sentDate: Date(),
                                 kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "사용자", firstMessage: message, completion: { success in
                if success {
                    print("메세지 보내기 성공!")
                } else {
                    print("메세지 보내기 실패!")
                }
            })
            
        } else {
            // 기존 대화 데이터 추가
            
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return ""
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("메세지 ID: \(newIdentifier)")
        
        return newIdentifier
    }
    
}


extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // 발신자가 누구인지?
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender이 nil 값입니다.")
        // 아래 Sender은 더미 데이터
        return Sender(photoURL: "", senderId: "", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
