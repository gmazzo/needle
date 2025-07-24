import Foundation

public extension Component {

  class BaseSingleton<Value> {
    private let lock = NSRecursiveLock()
    private var value: Value?

    func resolve(initializer: () -> Value) -> Value {
      if let existing = self.value { return existing }

      self.lock.lock()
      defer { self.lock.unlock() }

      if let existing = self.value { return existing }

      let valueInstance = initializer()
      self.value = valueInstance
      return valueInstance
    }

  }

  @propertyWrapper
  class SingletonInstance<Value> : BaseSingleton<Value> {
    private let initializer: () -> Value
    
    public init(_ initializer: @autoclosure @escaping () -> Value) {
      self.initializer = initializer
    }

    public var wrappedValue: Value {
      return resolve(initializer: self.initializer)
    }

  }

  @propertyWrapper
  class Singleton<ComponentModule : Component, Value> : BaseSingleton<Value> {
    private let initializer: (ComponentModule) -> Value

    public init(_ initializer: @escaping (ComponentModule) -> Value) {
      self.initializer = initializer
    }

    public static subscript(
      _enclosingInstance component: ComponentModule,
      wrapped _: KeyPath<ComponentModule, Value>,
      storage storageKeyPath: KeyPath<ComponentModule, Singleton>
    ) -> Value {
      let wrapper = component[keyPath: storageKeyPath]
      return wrapper.resolve(initializer: {
        return wrapper.initializer(component)
      })
    }

    @available(*, unavailable, message: "Singleton can only be applied to Component")
    public var wrappedValue: Value { fatalError("Singleton can only be applied to Component") }

  }

}
