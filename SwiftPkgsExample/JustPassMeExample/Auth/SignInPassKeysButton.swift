//
//  SignInPassKeysButton.swift
//  JustPassMeExample
//
//  Created by Sameh Galal on 10/25/23.
//

import SwiftUI
import LocalAuthentication

struct SignInPassKeysButton: View {
  
  let action: () -> Void

  private var biometryType: LABiometryType {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      return context.biometryType
    } else {
      return .none
    }
  }
  
  init(action: @escaping () -> Void) {
    self.action = action
  }
    var body: some View {
      Button(action: action) {
        Image(systemName: self.biometryType == .faceID
              ? "faceid"
              : "touchid")
          .font(.title)
          .foregroundColor(biometryType == .faceID
                           ? Color.blue
                           : Color.red.opacity(0.5))
      }
    }
}

#Preview {
  SignInPassKeysButton(action: {})
}
