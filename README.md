# PathBuilder

Bring Type Safety of Swift to HTTP endpoints, file paths, and more.

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

extension City: Endpoint { }
```

Declare a builder:

```swift

let baseURL = URL(string: "https://ptx.transportdata.tw/MOTC/v2")!
let motcV2 = PathBuilder(path: baseURL, modelType: MOTCV2.self)
```

Now you can create URL like this:

```swift

let url: URL = motcV2.bike.availability.city(.tainan)

// Or...

let sub = URLSession.shared
    .dataTaskPublisher(for: motcV2.bike.availability.city(.tainan))
    .map(\.data)
    .sink { completion in

        print(completion)
        expectation.fulfill()

    } receiveValue: { data in

        print(data)
    }
```

If your endpoint is a `DecodableEndpoint`, you can create typed `URLSessionDataTask` and publishers like this:

```swift
extension City: DecodableEndpoint {
    
    typealias Value = [ValueItem]
    
    static var defaultDecoder: JSONDecoder {
        return JSONDecoder()
    }
}

let sub = URLSession.shared
    .decodedDataTaskPublisher(for: Paths.motcV2.bike.availability.city(.tainan))
    .sink { completion in

        print(completion)
        expectation.fulfill()

    } receiveValue: { decodedValue in

        print(decodedValue)
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
