import SwiftUI
import Combine

struct ContentView: View {
    @StateObject
    private var viewModel = ViewModel()
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "doc.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
                .frame(width: 80)
                .padding(.top, 40)
            Text("You've got a document that needs to be notarized\n\nSince we've partnered with Notarize, you can easily get it done from within our app!")
                .font(.system(size: 22))
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            Spacer()
            Button(action: {
                viewModel.getNotarizeSDKToken()
            }) {
                if viewModel.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else {
                    Text("Notarize Document")
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .disabled(viewModel.loading)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
        .padding(32)
        .fullScreenCover(item: $viewModel.activeSheet) { target in
            switch target {
            case .notarization(let token):
                NotarizeDocumentView(token: token) { result in
                    //handle result here
                }
            }
        }
        
        
    }
}

extension ContentView {
    class ViewModel: ObservableObject {
        @Published
        var loading = false
        @Published
        var activeSheet: SheetTarget?
        private var cancellables = Set<AnyCancellable>()
        
        func getNotarizeSDKToken() {
            self.loading = true
            let signer = SignerRequestInfo(firstName: "<SIGNER_FIRST_NAME>",
                                           lastName: "<SIGNER_LAST_NAME>",
                                           email: "<SIGNER_EMAIL>",
                                           phone: PhoneNumberInfo(countryCode: "<SIGNER_COUNTRY_CODE>",
                                                                  number: "<SIGNER_PHONE_NUMBER>"))
            NotarizeApi.createTransaction(apiKey: "<API_KEY>", signer: signer)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        debugPrint("an error occurred \(error.localizedDescription)")
                        self.loading = false
                    case .finished:
                        break
                    }
                } receiveValue: { sdkToken in
                    self.loading = false
                    self.activeSheet = .notarization(token: sdkToken)
                }
                .store(in: &cancellables)
        }
    }
    
    enum SheetTarget: Identifiable {
        case notarization(token: String)
        
        var id: String {
            switch self {
            case .notarization(let token):
                return "notarization-\(token)"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
