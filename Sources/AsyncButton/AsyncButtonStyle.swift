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
    private let _makeAsyncLabel: (AsyncButtonStyle.AsyncLabelConfiguration) -> AnyView
    private let _makeAsyncButton: (AsyncButtonStyle.AsyncButtonConfiguration) -> AnyView
    
    public init<S: AsyncButtonStyle>(_ style: S) {
        self._makeAsyncLabel = style.makeAsyncLabelTypeErased
        self._makeAsyncButton = style.makeAsyncButtonTypeErased
    }
    
    public func makeAsyncLabel(configuration: AsyncLabelConfiguration) -> AnyView {
        self._makeAsyncLabel(configuration)
    }
    
    public func makeAsyncButton(configuration: AsyncButtonConfiguration) -> AnyView {
        self._makeAsyncButton(configuration)
    }
}

extension AsyncButtonStyle {
    public func makeAsyncLabelTypeErased(configuration: AsyncLabelConfiguration) -> AnyView {
        AnyView(self.makeAsyncLabel(configuration: configuration))
    }
    public func makeAsyncButtonTypeErased(configuration: AsyncButtonConfiguration) -> AnyView {
        AnyView(self.makeAsyncButton(configuration: configuration))
    }
}

public protocol AsyncButtonStyle {
    associatedtype AsyncLabel: View
    associatedtype AsyncButton: View
    typealias AsyncLabelConfiguration = AsyncButtonStyleLabelConfiguration
    typealias AsyncButtonConfiguration = AsyncButtonStyleButtonConfiguration
    
    @ViewBuilder func makeAsyncLabel(configuration: AsyncLabelConfiguration) -> AsyncLabel
    @ViewBuilder func makeAsyncButton(configuration: AsyncButtonConfiguration) -> AsyncButton
}
extension AsyncButtonStyle {
    public func makeAsyncLabel(configuration: AsyncLabelConfiguration) -> some View {
        configuration.label
    }
    public func makeAsyncButton(configuration: AsyncButtonConfiguration) -> some View {
        configuration.button
    }
}

public struct AsyncButtonStyleLabelConfiguration {
    public typealias AsyncLabel = AnyView
    
    public let isLoading: Bool
    public let isPressed: Bool
    public let role: ButtonRole?
    public let label: AsyncLabel
    public let cancel: () -> Void
}

public struct AsyncButtonStyleButtonConfiguration {
    public typealias AsyncButton = AnyView
    
    public let isLoading: Bool
    public let isPressed: Bool
    public let role: ButtonRole?
    public let button: AsyncButton
    public let cancel: () -> Void
}

fileprivate struct Testing: View {
    var body: some View {
        VStack {
            button
                .asyncButtonStyle(.ellipsis)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
            button
                .asyncButtonStyle(.overlay)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
            button
                .asyncButtonStyle(.none)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
        }
    }
    var button: some View {
        AsyncButton {
            try? await Task.sleep(for: .seconds(5))
        } label: {
            Text("Label")
        }
    }
}
#Preview {
    Testing()
}
