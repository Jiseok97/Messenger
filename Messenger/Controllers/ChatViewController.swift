//
//  ChatViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/24.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType   // 발신자
    var messageId: String   // 중복 제거를 위한 시벽자
    var sentDate: Date      // 보낸 날짜
    var kind: MessageKind    // 사진, 이모지, 음성메세지 등등 여러타입 존재
}

struct Sender: SenderType {
    var photoURL : String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "지석이")

    override func viewDidLoad() {
        super.viewDidLoad()

        messages.append(Message(sender: selfSender,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("안녕하세요 !! 반가워요 !!")))
        
        messages.append(Message(sender: selfSender,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("완전 반가워요 !!!")))
        
        
        view.backgroundColor = .link
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}


extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // 발신자가 누구인지?
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
