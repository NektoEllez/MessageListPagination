//
//  SceneDelegate.swift
//  MessageListPagination
//
//  Created by Иван Марин on 30.09.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /// Создание нового UIWindow с использованием UIWindowScene
        let window = UIWindow(windowScene: windowScene)
        
        /// Создание экземпляра  основного контроллера
        let mainController = MessageListViewController()
        
        /// Настройка UINavigationController
        let navigationController = UINavigationController(rootViewController: mainController)
        
        window.rootViewController = navigationController
        
        window.makeKeyAndVisible()
        
        /// Сохранение UIWindow в свойстве window SceneDelegate
        self.window = window
    }
}

