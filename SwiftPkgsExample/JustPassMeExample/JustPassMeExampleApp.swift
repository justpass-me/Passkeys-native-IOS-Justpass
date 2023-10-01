//
//  JustPassMeExampleApp.swift
//  JustPassMeExample
//
//  Created by MahmoudFares on 26/09/2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      FirebaseApp.configure()
      let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
      if connectingSceneSession.role == .windowApplication {
          configuration.delegateClass = SceneDelegate.self
      }
      return configuration
  }
}

class SceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate {
    var window: UIWindow?   // << contract of `UIWindowSceneDelegate`

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = windowScene.keyWindow   // << store !!!
    }
}

@main
struct FavouritesApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      NavigationView {
        AuthenticatedView {
          Image(systemName: "number.circle.fill")
            .resizable()
            .frame(width: 100 , height: 100)
            .foregroundColor(Color(.systemPink))
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .clipped()
            .padding(4)
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
          Text("Welcome to Favourites!")
            .font(.title)
        } content: {
          FavouriteNumberView()
          Spacer()
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
