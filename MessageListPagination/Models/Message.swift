//
//  Message.swift
//  MessageListPagination
//
//  Created by Иван Марин on 30.09.2023.
//

import Foundation

/// Структура, представляющая сообщение в чате.
struct Message: Equatable {
    
    // MARK: - Properties
    
    /// Идентификатор сообщения.
    let id: Int
    
    /// Текст сообщения.
    let text: String
    
    // MARK: - Equatable Protocol
    
    /// Сравнивает два сообщения на равенство.
    ///
    /// - Parameters:
    ///   - lhs: Первое сообщение для сравнения.
    ///   - rhs: Второе сообщение для сравнения.
    /// - Returns: `true` если сообщения равны, `false` в противном случае.
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
