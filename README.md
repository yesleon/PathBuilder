# PathBuilder

Model API endpoints with Swift types.

Instead of this:

```swift
let url = URL(string: "https://ptx.transportdata.tw/MOTC/v2/Bike/Availability/Tainan")!

```

Write this:

```swift
let motcV2 = PathBuilder(path: url, modelType: MOTCV2.self)

let endpoint: URL = motcV2.bike.availability.city(.tainan)
```

Autocomplete fully supported!

## Usage

For an endpoint like `https://ptx.transportdata.tw/MOTC/v2/Bike/Availability/Tainan`, define a root type first:

```swift

struct MOTCV2 {
    var bike: Bike
}
```

Define a new type for every URL component:

```swift

struct Bike {
    var availability: Availability
}

struct Availability {
    var city: City
}
```

For enums and string components, define a `RawRepresentable` type with `String` as `RawValue`:

```swift

enum City: String {
    case tainan = "Tainan"
}
```

Make the last type conform to `Endpoint` or `DecodableEndpoint`:

```swift

extension City: DecodableEndpoint {
    
    typealias Value = [ValueItem]
    
    static var defaultDecoder: JSONDecoder {
        return JSONDecoder()
    }
}
```

Declare a builder:

```swift

let motcV2: PathBuilder<URLRequest, MOTCV2> = {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "ptx.transportdata.tw"
    components.path = "/MOTC/v2"
    let url = components.url!
    var request = URLRequest(url: url)
    request.setValue(
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15",
        forHTTPHeaderField: "User-Agent"
    )
    return .init(path: request)
}()
```

Now you can create URL requests like this:

```swift

let request = motcV2.bike.availability.city(.tainan).build()
```

If your endpoint is a `DecodableEndpoint`, you can call create typed `URLSessionDataTask` and publishers like this:

```swift

let sub = URLSession.shared
    .dataTaskPublisher(for: Paths.motcV2.bike.availability.city(.tainan))
    .sink { completion in

        print(completion)
        expectation.fulfill()

    } receiveValue: { value in

        print(value)
    }
```

`PathBuilder` will use the lowercased type name as its url component string. If you want to use other things, conform the type to `PathComponentProviding`:

```swift

struct Bike: PathComponentProviding {
    
    static var pathComponent: String {
        return "\(self)"
    }
    
    var availability: Availability
}
```
