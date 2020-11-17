# HFNetworking

Highly inspired by [SENetworking](https://github.com/kudoleh/SENetworking) and [this blog post by Flawless iOS](https://medium.com/flawless-app-stories/writing-network-layer-in-swift-protocol-oriented-approach-4fa40ef1f908)

This (which supposed to be a library, later) is (currently) wrapping Alamofire ~v4.9.0 to simplify multiple route request. Supporting Codable.

Todo:
- [x] Send basic ReST Request
- [x] Upload using Alamofire's multipart form data
- [x] simple example usage
- [ ] example post request using codable
- [ ] example upload multipart using codable
- [ ] (inline) documentation
- [ ] Remove Alamofire dependency
- [ ] Handle multipart upload with proper naming and mimetypes
- [ ] better error handling
- [ ] cancel request
- [ ] testing codes


---

### Basic Usage

```swift
lazy var basicNetworkRouter: NetworkRouter = {
    let headers = [
        "Content-type": "multipart/form-data"
    ]

    let config = ApiDataNetworkConfig(
                      baseURL: URL(string: "https://jsonplaceholder.typicode.com")!, 
                      headers: headers, 
                      queryParameters: [:]
                 )

    return DefaultNetworkRouter(config: config)
}()
```

```swift
struct Todo: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
    
    private enum CodingKeys: String, CodingKey {
        case userId, id, title, completed
    }
}
```

```swift
struct Endpoints {
    static func getTodo(at index: Int) -> Endpoint<Todo> {
        return Endpoint(path: "todos/\(index)", method: .get, bodyEncoding: .jsonSerializationData )
    }
}
```

```swift
func getTodo(at index: Int) {
    let endpoint = Endpoints.getTodo(at: index)
    networkRouter.request(with: endpoint, completion: { (result) in
        switch result {
        case .success(let fmResponseDTO):
            // TODO: handle response upload
            break
        case .failure(let error):
            // TODO: handle response error
            break
        case .onProgress(let progress):
            // TODO: handle progress
            break
        }
    })
}
```
