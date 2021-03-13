

public protocol PathComponentAppending {
    func appendingPathComponent(_ pathComponent: String) -> Self
}

public protocol PathComponentProviding {
    static var pathComponent: String { get }
}

public protocol Endpoint { }

@dynamicMemberLookup
public struct PathBuilder<P: PathComponentAppending, Model> {
    
    private let _path: P
    
    public init(path: P, modelType: Model.Type = Model.self) {
        self._path = path
    }
    
    public subscript<NewModel>(
        dynamicMember dynamicMember: KeyPath<Model, NewModel>
    ) -> PathBuilder<P, NewModel> {
        
        let pathComponent: String
        if let T = NewModel.self as? PathComponentProviding.Type {
            pathComponent = T.pathComponent
        } else {
            pathComponent = "\(NewModel.self)".lowercased()
        }
        let newPath = _path.appendingPathComponent(pathComponent)
        return PathBuilder<P, NewModel>(path: newPath)
    }
    
    public subscript<NewModel: RawRepresentable>(
        dynamicMember dynamicMember: KeyPath<Model, NewModel>
    ) -> (NewModel) -> PathBuilder<P, NewModel> where NewModel.RawValue == String {
        
        return { newModel in
            let newPath = _path.appendingPathComponent(newModel.rawValue)
            return PathBuilder<P, NewModel>(path: newPath)
        }
    }
    
    public subscript<NewModel: Endpoint>(
        dynamicMember dynamicMember: KeyPath<Model, NewModel>
    ) -> P {
        
        let pathComponent: String
        if let T = NewModel.self as? PathComponentProviding.Type {
            pathComponent = T.pathComponent
        } else {
            pathComponent = "\(NewModel.self)".lowercased()
        }
        let newPath = _path.appendingPathComponent(pathComponent)
        return newPath
    }
    
    public subscript<NewModel: RawRepresentable & Endpoint>(
        dynamicMember dynamicMember: KeyPath<Model, NewModel>
    ) -> (NewModel) -> P where NewModel.RawValue == String {
        
        return { newModel in
            let newPath = _path.appendingPathComponent(newModel.rawValue)
            return newPath
        }
    }
}

extension PathBuilder where Model: Endpoint {
    
    public func build() -> P {
        return _path
    }
}


