//
// AuthenticationViewModel.swift
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

import FirebaseAuth
import Foundation
import SwiftUI
import JustPassMeFramework

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

enum EmailLinkStatus {
    case none
    case pending
}

let justPassMeURL = "https://europe-west3-justpass-me-sdk-example.cloudfunctions.net/ext-justpass-me-oidc"
let authenticateURL = "\(justPassMeURL)/authenticate/"
let registerURL = "\(justPassMeURL)/register/"

@MainActor
class AuthenticationViewModel: ObservableObject {
    @AppStorage("email-link") var emailLink: String?
    @Published var email = ""

    @Published var flow: AuthenticationFlow = .login

    @Published var isValid = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var displayName = ""

    @Published var isGuestUser = false
    @Published var isVerified = false
    
    init() {
        registerAuthStateHandler()

        $email
            .map { email in
                !email.isEmpty
            }
            .assign(to: &$isValid)

        $user
            .compactMap { user in
                user?.isAnonymous
            }
            .assign(to: &$isGuestUser)

        $user
            .compactMap { user in
                user?.isEmailVerified
            }
            .assign(to: &$isVerified)
    }

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.email ?? ""
            }
        }
    }

    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }

    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1000000000)
            print("Done")
        } catch {
            print(error.localizedDescription)
        }
    }

    func reset() {
        flow = .login
        email = ""
        emailLink = nil
        errorMessage = ""
    }
}

// MARK: - Email and Link Authentication

extension AuthenticationViewModel {
    func sendSignInLink() async {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.url = URL(string: "https://justpassmeexample.page.link/email-link-login")

        do {
            try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
            emailLink = email
        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }

    var emailLinkStatus: EmailLinkStatus {
        emailLink == nil ? .none : .pending
    }

    func handleSignInLink(_ url: URL) async {
        guard let email = emailLink else {
            errorMessage = "Invalid email address. Most likely, the link you used has expired. Try signing in again."
            return
        }
        let link = url.absoluteString
        if Auth.auth().isSignIn(withEmailLink: link) {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, link: link)
                let user = result.user
                print("User \(user.uid) signed in with email \(user.email ?? "(unknown)"). The email is \(user.isEmailVerified ? "" : "NOT") verified")
                emailLink = nil
            } catch {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        } else {
            errorMessage = "error.localizedDescription"
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func registerPasskeys(window: UIWindow) async {
        do {
            let userToken = try await Auth.auth().currentUser?.getIDToken()
            let registerClient = JustPassMeClient(presentationAnchor: window)
            let result = try await registerClient.register(registrationURL: registerURL, extraClientHeaders: ["Authorization" : "Bearer \(userToken!)"])
            print("Response Data: \(result)")
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func loginPasskeys(window: UIWindow, autofill: Bool = false) async {
        do {
            let authenticateClient = JustPassMeClient(presentationAnchor: window)
            let result = try await authenticateClient.authenticate(authenticationURL: authenticateURL, autoFill: autofill)
            let token = result["token"] as? String
            if ((token) != nil){
                try await Auth.auth().signIn(withCustomToken: token!)
            }
            print("Response Data: \(result)")
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
