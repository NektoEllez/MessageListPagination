//
//  AppConstants.swift
//  MessageListPagination
//
//  Created by Иван Марин on 30.09.2023.
//

import Foundation

/// Структура для хранения констант приложения.
struct AppConstants {
    
    // MARK: - Pagination Constants
    
    /// Количество сообщений для начальной загрузки.
    static let initialLoadCount = 20
    
    /// Количество сообщений для подгрузки при пагинации.
    static let paginationLoadCount = 20
    
    // MARK: - Target Message
    
    /// Идентификатор сообщения, к которому нужно прокрутить при нажатии на кнопку.
    static let targetMessageID = 1000
}
