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
    associatedtype AsyncBody: View
    typealias AsyncConfiguration = AsyncButtonStyleConfiguration
    
    @ViewBuilder func makeAsyncBody(configuration: AsyncConfiguration) -> AsyncBody
}

public struct AsyncButtonStyleConfiguration {
    public typealias Label = AnyView
    public typealias Button = AnyView
    
    public let isLoading: Bool
    public let label: Label
    public let button: Button
    public let cancel: () -> Void
    
    public init(isLoading: Bool, label: Label, button: Button, cancel: @escaping () -> Void) {
        self.isLoading = isLoading
        self.label = label
        self.button = button
        self.cancel = cancel
    }
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
