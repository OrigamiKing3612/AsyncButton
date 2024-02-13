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
    private let _makeLabel: (AsyncButtonStyle.AsyncLabelConfiguration) -> AnyView
    private let _makeButton: (AsyncButtonStyle.AsyncButtonConfiguration) -> AnyView
    
    public init<S: AsyncButtonStyle>(_ style: S) {
        self._makeLabel = style.makeLabelTypeErased
        self._makeButton = style.makeButtonTypeErased
    }
    
    public func makeLabel(configuration: AsyncLabelConfiguration) -> AnyView {
        self._makeLabel(configuration)
    }
    
    public func makeButton(configuration: AsyncButtonConfiguration) -> AnyView {
        self._makeButton(configuration)
    }
}

extension AsyncButtonStyle {
    public func makeLabelTypeErased(configuration: AsyncLabelConfiguration) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration))
    }
    public func makeButtonTypeErased(configuration: AsyncButtonConfiguration) -> AnyView {
        AnyView(self.makeButton(configuration: configuration))
    }
}

public protocol AsyncButtonStyle {
    associatedtype AsyncLabel: View
    associatedtype AsyncButton: View
    typealias AsyncLabelConfiguration = AsyncButtonStyleLabelConfiguration
    typealias AsyncButtonConfiguration = AsyncButtonStyleButtonConfiguration
    
    @ViewBuilder func makeLabel(configuration: AsyncLabelConfiguration) -> AsyncLabel
    @ViewBuilder func makeButton(configuration: AsyncButtonConfiguration) -> AsyncButton
}
extension AsyncButtonStyle {
    public func makeLabel(configuration: AsyncLabelConfiguration) -> some View {
        configuration.label
    }
    public func makeButton(configuration: AsyncButtonConfiguration) -> some View {
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
