//
// AuthenticatedView.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2022 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

// see https://michael-ginn.medium.com/creating-optional-viewbuilder-parameters-in-swiftui-views-a0d4e3e1a0ae
extension AuthenticatedView where Unauthenticated == EmptyView {
  init(@ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = nil
    self.content = content
  }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()
  @State private var presentingLoginScreen = false
  @State private var presentingProfileScreen = false
  @EnvironmentObject var sceneDelegate: SceneDelegate
  
  var unauthenticated: Unauthenticated?
  @ViewBuilder var content: () -> Content
  
  public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated
    self.content = content
  }
  
  public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated()
    self.content = content
  }
  
  private func handleSignInLink(url: URL) {
    Task {
      await viewModel.handleSignInLink(url)
    }
  }
  
  func loginButton(_ title: String) -> some View {
    Button {
      viewModel.reset()
      presentingLoginScreen.toggle()
    } label: {
      Text(title)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    .buttonStyle(.bordered)
  }
  
  var body: some View {
    switch viewModel.authenticationState {
    case .unauthenticated, .authenticating:
      VStack {
        if let unauthenticated {
          unauthenticated
        }
        if !viewModel.errorMessage.isEmpty {
          VStack {
            Text(viewModel.errorMessage)
              .foregroundColor(Color(UIColor.systemRed))
          }
        }
        if viewModel.emailLinkStatus == .none {
          Text("You need to be logged in to use this app.")
          HStack{
            loginButton("Log in")
            SignInPassKeysButton(action: {
              Task {
                await viewModel.loginPasskeys(window: sceneDelegate.window!, autofill: false)
              }
            })
          }
          
        }
        else  {
          Text("Check your email!")
            .padding(.top, 16)
            .padding(.bottom, 6)
          if let emailLink = viewModel.emailLink {
            Text("To confirm your email address, tap the magic link in the email we sent to **\(emailLink)**.")
              .font(.footnote)
          }
          HStack {
            VStack { Divider() }
            Text("or")
            VStack { Divider() }
          }
          loginButton("Log in a different way")
        }
      }
      .padding(.horizontal, 16)
      .sheet(isPresented: $presentingLoginScreen) {
        AuthenticationView()
          .environmentObject(viewModel)
      }
      .onOpenURL { url in
        handleSignInLink(url: url)
      }
    case .authenticated:
      VStack {
        content()
        Text("You're logged in as \(viewModel.displayName).")
        Button("Tap here to view your profile") {
          presentingProfileScreen.toggle()
        }
      }
      .sheet(isPresented: $presentingProfileScreen) {
        NavigationView {
          UserProfileView()
            .environmentObject(viewModel)
        }
      }
    }
  }
}

struct AuthenticatedView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticatedView {
      Text("You're signed in.")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow)
    }
  }
}
