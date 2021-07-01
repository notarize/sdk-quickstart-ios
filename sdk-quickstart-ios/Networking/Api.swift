import Foundation
import Combine

enum ApiError: Error {
    case unableToGenerateRequestBody
}

class NotarizeApi {
    public static func createTransaction(apiKey: String, signer: SignerRequestInfo) -> AnyPublisher<String, Error> {
        return generateRequestBody(signer: signer)
            .flatMap { requestData -> AnyPublisher<String, Error> in
                let session = URLSession(configuration: .default)
                let url = URL(string: "https://api-internal-mirror.notarize.com/v1/transactions/")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = requestData
                return session.dataTaskPublisher(for: request)
                    .tryMap { data, response -> Data in
                        guard let httpResponse = response as? HTTPURLResponse,
                              (200...299).contains(httpResponse.statusCode) else {
                            throw URLError(.badServerResponse)
                        }
                        return data
                    }
                    .decode(type: CreateTransactionResponse.self, decoder: JSONDecoder.ApiDecoder)
                    .map({ $0.signers.first!.sdkToken })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private static func generateRequestBody(signer: SignerRequestInfo) -> AnyPublisher<Data, Error> {
        Deferred {
            Future { promise in
                guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf"),
                      let pdfResource = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                    promise(.failure(ApiError.unableToGenerateRequestBody))
                    return
                }
                let request = CreateTransactionRequest(documents: [DocumentResource(resource: pdfResource.base64EncodedString())],
                                                       signers: [signer],
                                                       requireSecondaryPhotoId: false)
                guard let requestData = try? JSONEncoder.ApiEncoder.encode(request) else {
                    promise(.failure(ApiError.unableToGenerateRequestBody))
                    return
                }
                promise(.success(requestData))
            }
        }
        .eraseToAnyPublisher()
    }
}


struct CreateTransactionRequest: Codable {
    let documents: [DocumentResource]
    let signers: [SignerRequestInfo]
    let requireSecondaryPhotoId: Bool
    var requireNewSignerVerification: Bool = false
}

struct DocumentResource: Codable {
    let resource: String
    var customerCanAnnotate: Bool = true
}

struct SignerRequestInfo: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: PhoneNumberInfo
}

struct PhoneNumberInfo: Codable {
    let countryCode: String
    let number: String
}

struct CreateTransactionResponse: Codable {
    let signers: [SignerResponseInfo]
}

struct SignerResponseInfo: Codable {
    let sdkToken: String
}


extension JSONDecoder {
    static var ApiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

extension JSONEncoder {
    static var ApiEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
