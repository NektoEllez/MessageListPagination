import Foundation
/// Управляет пагинацией и загрузкой сообщений.
class PaginationManager {
    
    // MARK: - Properties
    
    /// Нижний индекс страницы для пагинации.
    var lowerPage = 0
    
    /// Верхний индекс страницы для пагинации.
    var upperPage = 0
    
    /// Флаг, указывающий, идет ли загрузка в данный момент.
    var isLoading = false
    
    /// Завершающий блок для операций загрузки.
    private var loadCompletion: (([Message]) -> Void)?
}
    

extension PaginationManager {
    // MARK: - Public Methods
    /// Загружает сообщения в заданном диапазоне.
    ///
    /// - Parameters:
    ///   - start: Начальный индекс сообщения.
    ///   - end: Конечный индекс сообщения.
    ///   - completion: Завершающий блок с массивом новых сообщений.
    func loadMessagesInRange(start: Int, end: Int, completion: @escaping ([Message]) -> Void) {
        guard !isLoading else {
            loadCompletion = completion
            return
        }
        
        isLoading = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let newMessages = self.createMessages(startingFrom: start, count: end - start + 1)
            
            DispatchQueue.main.async {
                self.isLoading = false
                completion(newMessages)
                self.executeLoadCompletionIfNecessary(messages: newMessages)
            }
        }
    }
    
    /// Загружает дополнительные сообщения в указанном направлении.
    ///
    /// - Parameters:
    ///   - startID: Идентификатор, начиная с которого нужно загрузить сообщения.
    ///   - direction: Направление для загрузки (вверх или вниз).
    ///   - completion: Завершающий блок с массивом новых сообщений.
    func loadMoreMessages(startingFrom startID: Int?, direction: ScrollDirection, completion: @escaping ([Message]) -> Void) {
        guard !isLoading else {
            loadCompletion = completion
            return
        }
        
        isLoading = true
        
        var startID = startID ?? 0
        let count = 20  // количество сообщений для загрузки
        
        if direction == .up {
            // Загружаем сообщения, даже если startID меньше нуля
            startID = max(startID - count, 0)
        } else {
            startID = startID + 1
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let newMessages = self.createMessages(startingFrom: startID, count: count)
            
            DispatchQueue.main.async {
                self.isLoading = false
                completion(newMessages)
                self.executeLoadCompletionIfNecessary(messages: newMessages)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    /// Создает массив сообщений с заданными параметрами.
    ///
    /// - Parameters:
    ///   - startID: Начальный идентификатор.
    ///   - count: Количество сообщений.
    /// - Returns: Массив новых сообщений.
    private func createMessages(startingFrom startID: Int, count: Int) -> [Message] {
        var newMessages: [Message] = []
        for i in 0..<count {
            let id = startID + i
            
            // Создаем сообщения с разной высотой
            let text: String
            if id % 19 == 0 {  // одно из каждых 19 сообщений будет иметь большую высоту
                text = "Сообщения с текстом \nСообщения с текстом \nСообщения с текстом \nСообщения с текстом"
            } else {
                text = "Пример сообщения \(id)"
            }
            
            newMessages.append(Message(id: id, text: text))
        }
        return newMessages
    }
    
    /// Выполняет сохраненный завершающий блок, если он есть.
    ///
    /// - Parameter messages: Массив новых сообщений.
    private func executeLoadCompletionIfNecessary(messages: [Message]) {
        if let loadCompletion = self.loadCompletion {
            self.loadCompletion = nil
            loadCompletion(messages)
        }
    }
    // MARK: - State Management
    
    /// Устанавливает нижний и верхний индексы страниц для пагинации.
    ///
    /// - Parameters:
    ///   - lower: Нижний индекс.
    ///   - upper: Верхний индекс.
    func setPages(lower: Int, upper: Int) {
        self.lowerPage = lower
        self.upperPage = upper
    }
}
/// Определяет направление прокрутки для пагинации.
enum ScrollDirection {
    case up
    case down
}
