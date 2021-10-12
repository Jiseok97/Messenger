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
    private let conversationId : String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    private func listenForMessage(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        // self?.messagesCollectionView.scrollToBottom()
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
                
            case .failure(let error):
                print("메세지를 가져오는데 실패하였습니다.")
                print("오류 내역 → \(error)")
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Did Load
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
        
        if let conversationId = conversationId {
            listenForMessage(id: conversationId, shouldScrollToBottom: true)
        }
    }
}


// MARK: Extension InputBarAccessory
extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
            
        }
        // text → 유저가 친 메세지
        
        print("문자: \(text)")
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                             sentDate: Date(),
                             kind: .text(text))
        
        // 메세지 보내기
        if isNewConversation {
            // DB에 새 채팅 만들기

            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "사용자", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("메세지 보내기 성공!")
                    self?.isNewConversation = false
                } else {
                    print("메세지 보내기 실패!")
                }
            })
            
        } else {
            // 기존 대화 데이터 추가
            DatabaseManager.shared.sendMessage(to: otherUserEmail, message: message, completion: { success in
                if success {
                    print("메세지를 보냅니다. → ChatVC")
                } else {
                    print("메세지 보내기 실패하였습니다. → ChatVC")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        
        // guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else { return nil }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return ""
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("만들어진 메세지 ID: \(newIdentifier)")
        
        return newIdentifier
    }
    
}


// MARK: Extension MessageKit
extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // 발신자가 누구인지?
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender이 nil 값입니다.")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
