//
// LoginView.swift
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
import Combine
import FirebaseAnalyticsSwift

private enum FocusableField: Hashable {
  case email
}

struct LoginView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var sceneDelegate: SceneDelegate


  @FocusState private var focus: FocusableField?
  @State private var autoFillAuthorizationTask: Task<Void, Error>?


  private func signInWithEmailLink() {
    Task {
      await viewModel.sendSignInLink()
      dismiss()
    }
  }
    
  private func signInWithPasskeysAutofill () {
    autoFillAuthorizationTask = Task {
      await viewModel.loginPasskeys(window: sceneDelegate.window!, autofill: true)
    }
  }
    
  private func signInWithPasskeys () {
    Task {
      autoFillAuthorizationTask?.cancel()
      autoFillAuthorizationTask = nil
      await viewModel.loginPasskeys(window: sceneDelegate.window!, autofill: false)
    }
  }

  var body: some View {
    VStack {
      Image("Login")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(minHeight: 300, maxHeight: 400)
      Text("Login")
        .font(.largeTitle)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Image(systemName: "at")
        TextField("Email", text: $viewModel.email)
          .keyboardType(.emailAddress)
          .textContentType(.username)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .focused($focus, equals: .email)
          .onSubmit {
            signInWithEmailLink()
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 4)

      if !viewModel.errorMessage.isEmpty {
        VStack {
          Text(viewModel.errorMessage)
            .foregroundColor(Color(UIColor.systemRed))
        }
      }

      Button(action: signInWithEmailLink) {
        if viewModel.authenticationState != .authenticating {
          Text("Login")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
      }
      .disabled(!viewModel.isValid)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)

      Button(action: signInWithPasskeys) {
          Text("Login With Passkeys")
      }

    }
    .listStyle(.plain)
    .padding()
    .analyticsScreen(name: "\(Self.self)")
    .task {
      signInWithPasskeysAutofill()
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LoginView()
      LoginView()
        .preferredColorScheme(.dark)
    }
    .environmentObject(AuthenticationViewModel())
  }
}
