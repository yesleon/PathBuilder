import XCTest
@testable import PathBuilder

protocol Uppercased: PathComponentProviding { }
extension Uppercased {
    static var pathComponent: String { "\(self)" }
}


extension String: PathComponentAppending {
    
    public func appendingPathComponent(_ pathComponent: String) -> String {
        return self + "/" + pathComponent
    }
}

enum PathBuilders {
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

struct RealTimeByFrequency {
    var streaming: Streaming
}
struct Streaming {
    var city: City
    struct City {
        var cityID: CityID
        enum CityID: String, Endpoint {
             
            typealias Value = String
            
            case hsinchu = "Hsinchu"
        }
    }
}

struct Bike: Uppercased {
    var availability: Availability
}

struct Availability: Uppercased {
    var city: City
    enum City: String, DecodableEndpoint {
        static var defaultDecoder: JSONDecoder {
            return JSONDecoder()
        }
        
        typealias Value = [ValueItem]
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
        
        case tainan = "Tainan"
    }
}


final class PathBuilderTests: XCTestCase {
    var sub: Any?
    func testExample() {
        
        let expectation = XCTestExpectation(description: "test")
        
        sub = URLSession.shared
            .dataTaskPublisher(for: PathBuilders.motcV2.bike.availability.city(.tainan))
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



