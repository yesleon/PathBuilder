import XCTest
@testable import PathBuilder

protocol DoNotLowercase: PathComponentProviding { }

extension DoNotLowercase {
    
    static var pathComponent: String { "\(self)" }
}


extension String: PathComponentAppending {
    
    public func appendingPathComponent(_ pathComponent: String) -> String {
        return self + "/" + pathComponent
    }
}

enum Paths {
    
    static let motcV2: PathBuilder<URLRequest, MOTCV2> = {
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
}

struct MOTCV2 {
    var bike: Bike
}

struct Bike: DoNotLowercase {
    var availability: Availability
}

struct Availability: DoNotLowercase {
    var city: City
}

enum City: String {
    case tainan = "Tainan"
}

extension City: DecodableEndpoint {
    
    typealias Value = [ValueItem]
    
    static var defaultDecoder: JSONDecoder {
        return JSONDecoder()
    }
}

struct ValueItem: Codable {
    let stationUID, stationID: String
    let serviceAvailable, availableRentBikes, availableReturnBikes: Int
    let srcUpdateTime, updateTime: String

    enum CodingKeys: String, CodingKey {
        case stationUID = "StationUID"
        case stationID = "StationID"
        case serviceAvailable = "ServiceAvailable"
        case availableRentBikes = "AvailableRentBikes"
        case availableReturnBikes = "AvailableReturnBikes"
        case srcUpdateTime = "SrcUpdateTime"
        case updateTime = "UpdateTime"
    }
}

final class PathBuilderTests: XCTestCase {
    
    var sub: Any?
    
    func testExample() {
        
        let expectation = XCTestExpectation(description: "test")
        
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
        let motcV2 = PathBuilder(path: request, modelType: MOTCV2.self)

        let endpointRequest: URLRequest = motcV2.bike.availability.city(.tainan)
        
        sub = URLSession.shared
            .dataTaskPublisher(for: motcV2.bike.availability.city(.tainan))
            .sink { completion in
                
                print(completion)
                expectation.fulfill()
                
            } receiveValue: { value in
                
                print(value)
            }
        
        wait(for: [expectation], timeout: 3)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}



