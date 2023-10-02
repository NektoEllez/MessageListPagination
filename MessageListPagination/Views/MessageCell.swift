//
//  MessageCell.swift
//  MessageListPagination
//
//  Created by Иван Марин on 30.09.2023.
//

import UIKit

// MARK: - MessageCell Class

/// Ячейка для отображения сообщения.
class MessageCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// Сообщение, которое будет отображаться в ячейке.
    var message: Message? {
        didSet {
            messageLabel.text = message?.text
        }
    }
    
    // MARK: - UI Elements
    
    /// Метка для отображения текста сообщения.
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 2.0
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
