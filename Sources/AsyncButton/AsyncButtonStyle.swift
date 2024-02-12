import SwiftUI

private struct AsyncButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyAsyncButtonStyle = AnyAsyncButtonStyle(.ellipsis)
}
extension View {
    public func asyncButtonStyle<S: AsyncButtonStyle>(_ style: S) -> some View {
        environment(\.asyncButtonStyle, AnyAsyncButtonStyle(style))
    }
}
extension EnvironmentValues {
    public var asyncButtonStyle: AnyAsyncButtonStyle {
        get { self[AsyncButtonStyleKey.self] }
        set { self[AsyncButtonStyleKey.self] = newValue }
    }
}

public struct AnyAsyncButtonStyle: AsyncButtonStyle {
    private let _makeAsyncBody: (AsyncButtonStyle.AsyncConfiguration) -> AnyView
    
    public init<S: AsyncButtonStyle>(_ style: S) {
        self._makeAsyncBody = style.makeAsyncButtonTypeErased
    }
    
    public func makeAsyncBody(configuration: AsyncConfiguration) -> AnyView {
        self._makeAsyncBody(configuration)
    }
}

extension AsyncButtonStyle {
    public func makeAsyncButtonTypeErased(configuration: AsyncConfiguration) -> AnyView {
        AnyView(makeAsyncBody(configuration: configuration))
    }
}

public protocol AsyncButtonStyle {
    associatedtype Body: View
    typealias AsyncConfiguration = AsyncButtonStyleConfiguration
    
    @ViewBuilder func makeAsyncBody(configuration: AsyncConfiguration) -> Body
}

public struct AsyncButtonStyleConfiguration {
    typealias Label = AnyView
    typealias Button = AnyView
    
    let isLoading: Bool
    let label: Label
    let button: Button
    let cancel: () -> Void
}

fileprivate struct Test: View {
    var body: some View {
        AsyncButton {
            
        } label: {
            Text("Async Button")
        }
        .asyncButtonStyle(.ellipsis)
    }
}
