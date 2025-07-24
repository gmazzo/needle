class MyChildComponent: Component<My2Dependency> {
    @SingletonInstance(Book())
    var book: Book
}
