//
//  ViewController.swift
//  justpass-me
//
//  Created by sameh@justpass.me on 05/12/2023.
//  Copyright (c) 2023 sameh@justpass.me. All rights reserved.
//

import UIKit
import JustPassMeFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func Login(_ sender: UIButton) {
        if #available(iOS 16.0, *) {
            Task { @MainActor in
                do {
                    guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
                    let JustPassMeClient = JustPassMeClient(presentationAnchor: window);
                    let result = try await JustPassMeClient.authenticate(authenticationURL: "https://europe-west3-justpass-me-sdk-example.cloudfunctions.net/ext-justpass-me-oidc/authenticate/");
                    print("Response Data: \(result)")
                } catch {
                    let nsError = error as NSError
                    let customError = error as? JustPassMeClient.JustPassMeClientError
                    let errorMessage: String
                    switch customError {
                    case .badURL:
                        errorMessage = "Bad URL"
                    case .badResponse:
                        errorMessage = "Bad response"
                    case .noPublicKey:
                        errorMessage = "No public key"
                    case .runtimeError(let description):
                        errorMessage = description
                    case .none:
                        errorMessage = nsError.localizedDescription
                    }
                    let errorAlert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

