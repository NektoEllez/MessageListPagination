import UIKit

// MARK: - MessageListViewController Class Definition

/**
 Класс `MessageListViewController` отвечает за отображение списка сообщений.
 Он управляет источником данных и представлением коллекции.
*/
class MessageListViewController: UIViewController {
    
    // MARK: - Public Properties
    
    /// Словарь, содержащий все загруженные сообщения.
    var messages: [Int: Message] = [:]
    
    // MARK: - Private Properties
    
    /// Менеджер пагинации для загрузки сообщений.
    private let paginationManager = PaginationManager()
    
    /// Менеджер скролла для управления прокруткой и переходами.
    private lazy var scrollManager: ScrollManager = {
        return ScrollManager(paginationManager: self.paginationManager)
    }()
    
    /// Коллекция для отображения сообщений.
    private var collectionView: UICollectionView!
    
    /// Минимальный загруженный идентификатор сообщения.
    private var minLoadedMessageID: Int = Int.max
    
    /// Максимальный загруженный идентификатор сообщения.
    private var maxLoadedMessageID: Int = Int.min
    
    /// Идентификатор сообщения, к которому нужно перейти.
    private var targetMessageID: Int = AppConstants.targetMessageID
    
    // MARK: - Lifecycle
    
    /**
     Вызывается при загрузке представления.
     Настраивает UI и загружает начальные сообщения.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialMessages()
        // Устанавливаем цвет навигационной панели в черный
        navigationController?.navigationBar.barTintColor = .black
        // Устанавливаем цвет текста в навигационной панели в белый
        navigationController?.navigationBar.tintColor = .white
        // Устанавливаем стиль текста для навигационной панели
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}

// MARK: - UI Setup

private extension MessageListViewController {
    
    /// Настраивает пользовательский интерфейс.
    func setupUI() {
        setupCollectionView()
        setupNavigationBar()
    }
    
    /// Настраивает представление коллекции.
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 5

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "MessageCell")

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        collectionView.isPagingEnabled = false
    }
    
    /// Настраивает панель навигации.
    func setupNavigationBar() {
        // Создаем UIButton и настраиваем его внешний вид
        let customButton = UIButton(type: .custom)
        customButton.setTitle("Scroll to 1000", for: .normal)
        customButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // Устанавливаем цвет текста
        customButton.setTitleColor(.black, for: .normal)
        
        // Добавляем отступы
        customButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
  
        // Устанавливаем фон кнопки и бордер
        customButton.backgroundColor = .white
        customButton.layer.borderColor = UIColor.gray.cgColor
        customButton.layer.borderWidth = 3.0
        
        // Устанавливаем скругленные углы
        customButton.layer.cornerRadius = 10
        
        // Настроим действие для кнопки
        customButton.addTarget(self, action: #selector(scrollToMessage), for: .touchUpInside)
        
        // Создаем UIBarButtonItem с нашей настраиваемой кнопкой
        let customBarButtonItem = UIBarButtonItem(customView: customButton)
        
        // Создаем UIBarButtonItem с фиксированным пространством справа
        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceBarButtonItem.width = -16  // Установите желаемый отступ справа
        
        // Устанавливаем UIBarButtonItem с отступом и нашей настраиваемой кнопкой справа
        navigationItem.rightBarButtonItems = [spaceBarButtonItem, customBarButtonItem]
    }
}

// MARK: - Initial Message Loading

private extension MessageListViewController {
    
    /**
     Загружает начальный набор сообщений.
    */
    func loadInitialMessages() {
        paginationManager.loadMessagesInRange(start: 1, end: 20) { [weak self] newMessages in
            self?.appendNewMessages(newMessages)
            self?.paginationManager.setPages(lower: 0, upper: 1)
        }
    }
}

// MARK: - Scroll Handling and Pagination

extension MessageListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height
        
        if offsetY > contentHeight - scrollViewHeight - 50 {
            let startMessageID = messages.keys.max() ?? 0
            let endMessageID = maxLoadedMessageID + 20 // Загружаем до максимального ID, который уже загружен
            paginationManager.loadMessagesInRange(start: startMessageID + 1, end: endMessageID) { [weak self] newMessages in
                self?.appendNewMessages(newMessages)
            }
        }

        if offsetY < 50 {
            if let firstVisibleIndexPath = collectionView.indexPathsForVisibleItems.min(),
               firstVisibleIndexPath.item > 0 {
                let startMessageID = minLoadedMessageID - 20 // Загружаем до минимального ID, который уже загружен
                let endMessageID = messages.keys.min() ?? 0
                paginationManager.loadMessagesInRange(start: startMessageID, end: endMessageID - 1) { [weak self] newMessages in
                    self?.prependNewMessages(newMessages)
                }
            }
        }

    }
}

// MARK: - Helper Methods

private extension MessageListViewController {
     func appendNewMessages(_ newMessages: [Message]) {
        for message in newMessages {
            messages[message.id] = message
            if maxLoadedMessageID == Int.min {
                maxLoadedMessageID = message.id
            } else {
                maxLoadedMessageID = max(maxLoadedMessageID, message.id)
            }
            
            // Обновляем minLoadedMessageID
            if minLoadedMessageID == Int.max {
                minLoadedMessageID = message.id
            } else {
                minLoadedMessageID = min(minLoadedMessageID, message.id)
            }
        }
        collectionView.reloadData()
    }

    func prependNewMessages(_ newMessages: [Message]) {
        for message in newMessages {
            messages[message.id] = message
            if minLoadedMessageID == Int.max {
                minLoadedMessageID = message.id
            } else {
                minLoadedMessageID = min(minLoadedMessageID, message.id)
            }
        }
        collectionView.reloadData()
        // TODO: Adjust the scroll position to maintain the current view
    }

    @objc func scrollToMessage() {
        if messages.keys.contains(targetMessageID) {
            DispatchQueue.main.async {
                self.scrollManager.animatedScrollToMessage(withId: self.targetMessageID, among: self.messages, in: self.collectionView)
            }
        } else {
            // Загружаем сообщения до указанного targetMessageID
            let startMessageID = min(targetMessageID - 10, 1) // Ограничиваем начальный ID до 1, чтобы избежать отрицательных значений
            let endMessageID = targetMessageID + 10
            paginationManager.loadMessagesInRange(start: startMessageID, end: endMessageID) { [weak self] newMessages in
                self?.appendNewMessages(newMessages)
                
                // Проверяем, не превышает ли targetMessageID количество доступных элементов
                if let totalCount = self?.collectionView.numberOfItems(inSection: 0), let targetMessageID = self?.targetMessageID, targetMessageID <= totalCount {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.scrollManager.animatedScrollToMessage(withId: targetMessageID, among: self!.messages, in: self!.collectionView)
                    }
                }
                
                self?.paginationManager.setPages(lower: max(startMessageID / 20, 0), upper: max(endMessageID / 20, 0))
            }
        }
    }
}

// MARK: - Collection View Data Source and Delegate

extension MessageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if minLoadedMessageID <= maxLoadedMessageID {
            return maxLoadedMessageID - minLoadedMessageID + 1
        } else {
            // Вернуть подходящее значение по умолчанию
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.message = messages[indexPath.item]
        return cell
    }
}

// MARK: - Collection View Flow Layout

extension MessageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = view.frame.width
        let contentWidth = collectionViewWidth - 16
        let message = messages[indexPath.item]

        if let message = message {
            let textHeight = message.text.height(withConstrainedWidth: contentWidth - 32, font: .systemFont(ofSize: 16, weight: .bold))
            return CGSize(width: contentWidth, height: textHeight + 16)
        } else {
            return CGSize(width: contentWidth, height: 0)
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
