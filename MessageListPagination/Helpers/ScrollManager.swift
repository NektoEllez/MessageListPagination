//
//  ScrollManager.swift
//  MessageListPagination
//
//  Created by Иван Марин on 30.09.2023.
//

import UIKit

// MARK: - ScrollManagerDelegate Protocol

/// Протокол для уведомления о загрузке новых сообщений.
protocol ScrollManagerDelegate: AnyObject {
    /// Вызывается, когда загружены новые сообщения.
    func didLoadNewMessages(_ newMessages: [Message])
}

// MARK: - ScrollManager Class

/// Управляет анимированным скроллингом и взаимодействует с PaginationManager для загрузки сообщений.
class ScrollManager {
    
    // MARK: - Properties
    
    /// Делегат для уведомления о загрузке новых сообщений.
    weak var delegate: ScrollManagerDelegate?
    
    /// Менеджер для управления пагинацией сообщений.
    var paginationManager: PaginationManager?
    
    // MARK: - Initialization
    
    /// Инициализация с передачей менеджера пагинации.
    init(paginationManager: PaginationManager) {
        self.paginationManager = paginationManager
    }
    
    // MARK: - Public Methods
    
    /// Анимированный скролл к сообщению с заданным идентификатором.
    ///
    /// - Parameters:
    ///   - targetID: Идентификатор целевого сообщения.
    ///   - messages: Словарь загруженных сообщений.
    ///   - collectionView: UICollectionView, в которой отображаются сообщения.
    func animatedScrollToMessage(withId targetID: Int, among messages: [Int: Message], in collectionView: UICollectionView) {
        if let _ = messages[targetID] {
            let indexPath = IndexPath(item: targetID, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        } else {
            let startID = max(targetID - 10, 1)
            let endID = targetID + 10
            paginationManager?.loadMessagesInRange(start: startID, end: endID) { [weak self] newMessages in
                self?.delegate?.didLoadNewMessages(newMessages)
                
                let indexPath = IndexPath(item: targetID, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        }
    }
}
