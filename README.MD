# Notarize iOS SDK Quick Start

> NOTE: The Notarize iOS SDK is currently in closed beta. If you are interested in using the SDK for your app please contact sales@notarize.com

## Setup

This repository contains example code written in Swift and SwiftUI. In order to run the project, you need to have a full-access [API Key](https://dev.notarize.com/docs/authentication) generated.

The SDK is available via Swift Package Manager.

You can add the NotarizeSigner framework to your project by adding the following package:

```
https://github.com/notarize/NotarizeSigner-SPM.git
```

The NotarizeSigner framework utilizes a few third party dependencies which are required for the framework to compile and run. These dependencies can be added to your project by adding the following package:

```
https://github.com/notarize/notarize-deps-ios
```
When prompted, please add all libraries to the target hosting the NotarizeSigner framework

## Quickstart

### Running the quickstart project

The project contains a convenient networking class for creating transactions via the Notarize API. Ideally, the process of creating transactions and retrieving it's corresponding  `sdk_token` should be done on the server.

Prior to running the app, you need to specify signer details and an API Key in the `ContentView.Swift` file:
```
func getNotarizeSDKToken() {
    // ...
    let signer = SignerRequestInfo(firstName: "<SIGNER_FIRST_NAME>",
                                   lastName: "<SIGNER_LAST_NAME>",
                                   email: "<SIGNER_EMAIL>",
                                   phone: PhoneNumberInfo(countryCode: "<SIGNER_COUNTRY_CODE>",
                                                          number: "<SIGNER_MOBILE_NUMBER>"))
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
```
The above code will generate a transaction using the `API Key`, and retrieve an `sdk_token` which is used to instantiate a signing flow using the NotarizeSigner framework.

Run the app on a device or simulator

<img width="562px" src="images/quickstart/contentview.png"/>

Tapping on the Notarize Document should load the token and launch the experience.

The NotrizeSigner framework provides the capability to respond to results from the signing experience. This can be done via the `SigningResultCallback` parameter when building the signing viewcontroller:
```
let controller = NotarizeSigner.buildSigning(token: token) { (result) in
    switch result {
    case .signingCompleted(let context):
        debugPrint("notarization has completed.")
    case .userCancelled:
        debugPrint("user has exited the flow prior to completion")
    case .notaryTerminated:
        debugPrint("notary was unable to complete the notarization due to missing requirements")
    case .error(let error):
        debugPrint("a non recoverable error has occurred during the signing process")
    }
}
```

### Troubleshooting

Depending on your project settings, you may need to set `Validate Workspace` setting in the target's `Build Settings` to `YES`

When running on a physical device, you could potentially experience a crash due to code signing inconsistencies. To solve this issue, insure that that the project's `Build Phases` has a run script after the `Embed Frameworks` step that runs the following:
```
find "${CODESIGNING_FOLDER_PATH}" -name '*.framework' -print0 | while read -d $'\0' framework
do
    codesign --force --deep --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements --timestamp=none "${framework}"
done

```
