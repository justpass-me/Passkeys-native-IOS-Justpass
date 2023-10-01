//
// UserProfileView.swift
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
import FirebaseAnalyticsSwift

struct UserProfileView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var sceneDelegate: SceneDelegate

  @State var presentingConfirmationDialog = false

  private func deleteAccount() {
    Task {
      if await viewModel.deleteAccount() == true {
        dismiss()
      }
    }
  }

  private func signOut() {
    viewModel.signOut()
  }

  private func registerPasskeys() {
      Task {
         await viewModel.registerPasskeys(window: sceneDelegate.window! )
      }
  }

  var body: some View {
    Form {
      Section {
        VStack {
          HStack {
            Spacer()
            Image(systemName: "person.fill")
              .resizable()
              .frame(width: 100 , height: 100)
              .aspectRatio(contentMode: .fit)
              .clipShape(Circle())
              .clipped()
              .padding(4)
              .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
            Spacer()
          }
          Button(action: {}) {
            Text("edit")
          }
        }
      }
      .listRowBackground(Color(UIColor.systemGroupedBackground))
      Section {
        Button(role: .cancel, action: registerPasskeys) {
          HStack {
            Spacer()
            switch viewModel.registrationState {
            case .idle:
                Text("Register Passkey")

            case .registering:
                ProgressView() // Spinning wheel
                Text("Registering Passkey")

            case .registered:
                Image(systemName: "checkmark") // Success check
                Text("Passkey Registered")
            }
            Spacer()
          }
        }
        .disabled(viewModel.registrationState != .idle)
        if !viewModel.errorMessage.isEmpty {
          HStack {
            Spacer()
              Text(viewModel.errorMessage)
                  .foregroundColor(viewModel.errorMessage.isEmpty ? Color(UIColor.systemGray): Color(UIColor.systemRed))
                .multilineTextAlignment(.center)
                .font(.footnote)
            Spacer()
          }
            .listRowBackground(Color.clear)
        }
      }
      Section("Email") {
        VStack(alignment: .leading) {
          Text("Email")
            .font(.caption)
          Text(viewModel.displayName)
        }
        VStack(alignment: .leading) {
          Text("UID")
            .font(.caption)
          Text(viewModel.user?.uid ?? "(unknown)")
        }
        VStack(alignment: .leading) {
          Text("Provider")
            .font(.caption)
          Text(viewModel.user?.providerData[0].providerID ?? "(unknown)")
        }
        VStack(alignment: .leading) {
          Text("Anonymous / Guest user")
            .font(.caption)
          Text(viewModel.isGuestUser ? "Yes" : "No")
        }
        VStack(alignment: .leading) {
          Text("Verified")
            .font(.caption)
          Text(viewModel.isVerified ? "Yes" : "No")
        }
      }
      Section {
        Button(role: .cancel, action: signOut) {
          HStack {
            Spacer()
            Text("Sign out")
            Spacer()
          }
        }
      }
      Section {
        Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
          HStack {
            Spacer()
            Text("Delete Account")
            Spacer()
          }
        }
      }
    }
    .navigationTitle("Profile")
    .navigationBarTitleDisplayMode(.inline)
    .analyticsScreen(name: "\(Self.self)")
    .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                        isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
      Button("Delete Account", role: .destructive, action: deleteAccount)
      Button("Cancel", role: .cancel, action: { })
    }
  }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      UserProfileView()
        .environmentObject(AuthenticationViewModel())
    }
  }
}
