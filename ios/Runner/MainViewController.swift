import UIKit
import FirebaseAuth

class MainViewController: UITableViewController {

    var handle: AuthStateDidChangeListenerHandle?
    var microsoftProvider: OAuthProvider?
    var twitterProvider: OAuthProvider?
    var gitHubProvider: OAuthProvider?
    var isMFAEnabled: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // [START auth_listener]
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.setTitleDisplay(user)
            self.tableView.reloadData()
        }
        // [END auth_listener]

        // Initialize OAuth Providers
        microsoftProvider = OAuthProvider(providerID: "microsoft.com")
        twitterProvider = OAuthProvider(providerID: "twitter.com")
        gitHubProvider = OAuthProvider(providerID: "github.com")

        // Uncomment to sign in with Game Center
        // self.authenticateGameCenterLocalPlayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // [START remove_auth_listener]
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        // [END remove_auth_listener]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = Auth.auth().currentUser else { return }

        let uid = user.uid
        let email = user.email
        let photoURL = user.photoURL

        var multiFactorString = "MultiFactor: "
        for info in user.multiFactor.enrolledFactors {
            multiFactorString += (info.displayName ?? "[DisplayName]") + " "
        }

        // Update UI elements
        if let cell = tableView.cellForRow(at: indexPath) {
            let emailLabel = cell.viewWithTag(1) as? UILabel
            let userIDLabel = cell.viewWithTag(2) as? UILabel
            let profileImageView = cell.viewWithTag(3) as? UIImageView
            let multiFactorLabel = cell.viewWithTag(4) as? UILabel

            emailLabel?.text = email
            userIDLabel?.text = uid
            multiFactorLabel?.text = multiFactorString
            multiFactorLabel?.isHidden = !isMFAEnabled

            // Load profile image
            struct LastImage {
                static var photoURL: URL? = nil
            }
            LastImage.photoURL = photoURL // Prevent earlier image from overwriting the latest

            if let photoURL = photoURL {
                DispatchQueue.global(qos: .default).async {
                    if let data = try? Data(contentsOf: photoURL), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if photoURL == LastImage.photoURL {
                                profileImageView?.image = image
                            }
                        }
                    }
                }
            } else {
                profileImageView?.image = UIImage(named: "ic_account_circle")
            }
        }
    }
}
