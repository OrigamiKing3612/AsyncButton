import SwiftUI

public struct AsyncButton<Label: View>: View {
    @Environment(\.onMainThread) private var onMainThread
    @Environment(\.disableButton) private var disableButton
    @Environment(\.asyncButtonStyle) private var asyncButtonStyle
    
    public var role: ButtonRole?
    public var action: () async -> Void
    @ViewBuilder public var label: () -> Label
    
    @State private var task: Task<Void, Never>?
    
    @GestureState private var isPressed = false
    
    public init(role: ButtonRole? = nil, action: @escaping () async -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
        self.role = role
    }
    
    public var body: some View {
        let asyncLabelConfiguration = AsyncButtonStyleLabelConfiguration(isLoading: task != nil, isPressed: isPressed, role: role, label: AnyView(label())) { task?.cancel() }
        let button = Button(role: role) {
            if onMainThread {
                task = Task {
                    await action()
                    task = nil
                }
            } else {
                task = Task { @MainActor in
                    await action()
                    task = nil
                }
            }
        } label: {
            asyncButtonStyle.makeAsyncLabel(configuration: asyncLabelConfiguration)
        }
        .simultaneousGesture(TapGesture().onEnded {})
        .gesture(
            LongPressGesture()
                .updating($isPressed) { value, state, _ in
                    state = value
                }
        )
        let asyncConfiguration = AsyncButtonStyleButtonConfiguration(isLoading: task != nil, isPressed: isPressed, role: role, button: AnyView(button)) { task?.cancel() }
        return asyncButtonStyle
            .makeAsyncButton(configuration: asyncConfiguration)
            .disabled(disabled)
    }
    public var isLoading: Bool { task != nil }
    public var disabled: Bool { disableButton && task != nil }
}

extension AsyncButton where Label == Text {
    public init<S: StringProtocol>(_ title: S, role: ButtonRole? = nil, action: @escaping () async -> Void) {
        self.init(role: role, action: action) { Text(title) }
    }
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () async -> Void) {
        self.init(role: role, action: action) { Text(titleKey) }
    }
    public init(verbatim: String, role: ButtonRole? = nil, action: @escaping () async -> Void) {
        self.init(role: role, action: action) { Text(verbatim: verbatim) }
    }
}

extension AsyncButton where Label == Image {
    public init(systemName: String, role: ButtonRole? = nil, action: @escaping () async -> Void) {
        self.init(role: role, action: action) { Image(systemName: systemName) }
    }
}


private struct OnMainThreadEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = true
}
private struct DisableButtonEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = true
}

extension View {
    public func onMainThread(_ onMain: Bool) -> some View {
        environment(\.onMainThread, onMain)
    }
    public func disableButton(_ disable: Bool) -> some View {
        environment(\.disableButton, disable)
    }
}

extension EnvironmentValues {
    public var onMainThread: Bool {
        get { self[OnMainThreadEnvironmentKey.self] }
        set { self[OnMainThreadEnvironmentKey.self] = newValue }
    }
    public var disableButton: Bool {
        get { self[DisableButtonEnvironmentKey.self] }
        set { self[DisableButtonEnvironmentKey.self] = newValue }
    }
}
