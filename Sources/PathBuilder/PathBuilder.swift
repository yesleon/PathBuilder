public protocol Base {
    associatedtype Path
    static var basePath: Path { get }
}
public protocol PathStringProviding {
    static var pathString: String { get }
}
public protocol Endpoint {
    associatedtype Value: Decodable
}

public protocol PathStringAppendable {
    func appendingPathString(_ string: String) -> Self
}
@dynamicMemberLookup
public struct PathBuilder<Path: PathStringAppendable, Model> {
    private let _path: Path
    public init(path: Path) {
        self._path = path
    }
    subscript<NewModel>(dynamicMember dynamicMember: KeyPath<Model, NewModel>) -> PathBuilder<Path, NewModel> {
        if let T = NewModel.self as? PathStringProviding.Type {
            return .init(path: _path.appendingPathString(T.pathString))
        }
        return .init(path: _path.appendingPathString("\(NewModel.self)".lowercased()))
    }
    subscript<NewModel: RawRepresentable>(dynamicMember dynamicMember: KeyPath<Model, NewModel>) -> (NewModel) -> PathBuilder<Path, NewModel> where NewModel.RawValue == String {
        return { newModel in
            return .init(path: _path.appendingPathString(newModel.rawValue))
        }
    }
}
extension PathBuilder where Model: Base {
    init(baseType: Model.Type) where Model.Path == Path {
        self.init(path: Model.basePath)
    }
}
extension PathBuilder where Model: Endpoint {
    func build() -> Path {
        return _path
    }
}


