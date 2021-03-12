import XCTest
@testable import PathBuilder

protocol Uppercased: PathStringProviding { }
extension Uppercased {
    static var pathString: String { "\(self)" }
}

extension URL: PathStringAppendable {
    public func appendingPathString(_ string: String) -> URL {
        return self.appendingPathComponent(string)
    }
}
extension URLComponents: PathStringAppendable {
    public func appendingPathString(_ string: String) -> URLComponents {
        var components = self
        components.path.append("/")
        components.path.append(string)
        return components
    }
}

enum PathBuilders {
    static let motcV2 = PathBuilder(baseType: MOTCV2.self)
}
struct MOTCV2: Base {
    static var basePath: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "ptx.transportdata.tw"
        components.path = "/MOTC/v2"
        return components
    }
    
    var bus: Bus
    var bike: Bike
}
extension PathBuilder where Path == URLComponents, Model == MOTCV2 {
    static let base = PathBuilder(baseType: MOTCV2.self)
}

struct Bus: Uppercased {
    var route: Route
    var realTimeByFrequency: RealTimeByFrequency
}
struct Route: Uppercased {
    var city: City
    struct City: Uppercased {
        var cityID: CityID
        enum CityID: String, Endpoint {
            case tainan = "Tainan"
            typealias Value = [Welcome]
        }
    }
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

struct Bike {
    var availability: Availability
}

struct Availability {
    var city: City
    enum City: String, Endpoint {
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
        var components = PathBuilders.motcV2.bike.availability.city(.tainan).build()
        components.queryItems = [
            .init(name: "$top", value: "3")
        ]
        
        print(components.url!)
        
//        url.motc.v2.bus.route.city.cityID("Tainan")
//        let builder = URLBuilder<PTXBase>(url: url)
//        print(PathBuilders.ptx.motc.v2.bike.availability.city.build())
//        let a = PathBuilders.ptx[dynamicMember: \.motc]
//        let expectation = XCTestExpectation(description: "test")
//
//        sub = URLSession.shared
//            .dataTaskPublisher(
//                for: PathBuilders.ptx.motc.v2.bike.availability.city(.tainan),
//                queryItems: [.init(name: "$top", value: "3")]
//            ) {
//                $0.setValue(
//                    "Mozilla/5.0 (iPad; CPU OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1",
//                    forHTTPHeaderField: "User-Agent"
//                )
//            }
//            .sink {
//                print($0)
//                expectation.fulfill()
//            } receiveValue: {
//                print($0)
//
//            }
//
//
//        wait(for: [expectation], timeout: 5)
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}





// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let routeUID, routeID: String
    let hasSubRoutes: Bool
    let operators: [Operator]
    let authorityID, providerID: String
    let subRoutes: [SubRoute]
    let busRouteType: Int
    let routeName: Name
    let departureStopNameZh, departureStopNameEn, destinationStopNameZh, destinationStopNameEn: String
    let ticketPriceDescriptionZh, ticketPriceDescriptionEn: String
    let routeMapImageURL: String
    let city, cityCode: String
    let updateTime: String
    let versionID: Int
    
    enum CodingKeys: String, CodingKey {
        case routeUID = "RouteUID"
        case routeID = "RouteID"
        case hasSubRoutes = "HasSubRoutes"
        case operators = "Operators"
        case authorityID = "AuthorityID"
        case providerID = "ProviderID"
        case subRoutes = "SubRoutes"
        case busRouteType = "BusRouteType"
        case routeName = "RouteName"
        case departureStopNameZh = "DepartureStopNameZh"
        case departureStopNameEn = "DepartureStopNameEn"
        case destinationStopNameZh = "DestinationStopNameZh"
        case destinationStopNameEn = "DestinationStopNameEn"
        case ticketPriceDescriptionZh = "TicketPriceDescriptionZh"
        case ticketPriceDescriptionEn = "TicketPriceDescriptionEn"
        case routeMapImageURL = "RouteMapImageUrl"
        case city = "City"
        case cityCode = "CityCode"
        case updateTime = "UpdateTime"
        case versionID = "VersionID"
    }
}

// MARK: - Operator
struct Operator: Codable {
    let operatorID: String
    let operatorName: Name
    let operatorCode, operatorNo: String
    
    enum CodingKeys: String, CodingKey {
        case operatorID = "OperatorID"
        case operatorName = "OperatorName"
        case operatorCode = "OperatorCode"
        case operatorNo = "OperatorNo"
    }
}

// MARK: - Name
struct Name: Codable {
    let zhTw, en: String
    
    enum CodingKeys: String, CodingKey {
        case zhTw = "Zh_tw"
        case en = "En"
    }
}

// MARK: - SubRoute
struct SubRoute: Codable {
    let subRouteUID, subRouteID: String
    let operatorIDs: [String]
    let subRouteName: Name
    let direction: Int
    
    enum CodingKeys: String, CodingKey {
        case subRouteUID = "SubRouteUID"
        case subRouteID = "SubRouteID"
        case operatorIDs = "OperatorIDs"
        case subRouteName = "SubRouteName"
        case direction = "Direction"
    }
}
