import UIKit
import FirebaseAuth

class EmailViewController: UIViewController {

    @IBAction func didCreateAccount(_ sender: AnyObject) {
        let email = "user@example.com"
        let password = "password123"
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            strongSelf.hideSpinner {
                if let error = error {
                    strongSelf.showMessagePrompt(error.localizedDescription)
                    return
                }
                
                if let user = authResult?.user {
                    print("\(user.email ?? "No Email") created")
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    @IBAction func didTapEmailLogin(_ sender: AnyObject) {
        let email = "user@example.com"
        let password = "password123"

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            strongSelf.hideSpinner {
                if let error = error {
                    let authError = error as NSError

                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        // Multi-factor authentication required
                        if let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as? MultiFactorResolver {
                            strongSelf.handleMultiFactorSignIn(resolver: resolver)
                        }
                        return
                    } else {
                        strongSelf.showMessagePrompt(error.localizedDescription)
                        return
                    }
                }

                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func handleMultiFactorSignIn(resolver: MultiFactorResolver) {
        var displayNameString = resolver.hints.map { $0.displayName ?? "" }.joined(separator: " ")
        
        self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)") { [weak self] userPressedOK, displayName in
            guard let self = self else { return }
            
            guard let selectedHint = resolver.hints.first(where: { $0.displayName == displayName }) as? PhoneMultiFactorInfo else {
                print("Selected hint not found")
                return
            }

            PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                if let error = error {
                    print("Multi-factor start sign-in failed: \(error.localizedDescription)")
                    return
                }
                
                self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint.displayName ?? "")") { userPressedOK, verificationCode in
                    guard let verificationID = verificationID, let verificationCode = verificationCode else { return }

                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
                    let assertion = MultiFactorAssertion(assertion: credential)

                    resolver.resolveSignIn(with: assertion) { [weak self] authResult, error in
                        if let error = error {
                            print("Multi-factor finalize sign-in failed: \(error.localizedDescription)")
                        } else {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    // Dummy implementations of required functions for UI handling
    private func hideSpinner(completion: @escaping () -> Void) {
        // Hide the loading indicator and execute completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: completion)
    }

    private func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func showTextInputPrompt(withMessage message: String, completionBlock: @escaping (Bool, String?) -> Void) {
        let alert = UIAlertController(title: "Input Required", message: message, preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "Enter value" }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let input = alert.textFields?.first?.text
            completionBlock(true, input)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionBlock(false, nil) })
        self.present(alert, animated: true)
    }
}
