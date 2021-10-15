import SwiftUI
import NotarizeSigner

struct NotarizeDocumentView: UIViewControllerRepresentable {
    let token: String
    let signingResultCallback: (NTRSigningResult) -> Void
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = NotarizeSignerSDK.buildSigning(token: token, callback: signingResultCallback)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
