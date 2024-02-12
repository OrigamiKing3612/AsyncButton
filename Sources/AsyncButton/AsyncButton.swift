import SwiftUI

public struct AsyncButton<Label: View>: View {
    @Environment(\.onMainThread) private var onMainThread
    @Environment(\.disableButton) private var disableButton
    
    public var role: ButtonRole?
    public var action: () async -> Void
    @ViewBuilder public var label: () -> Label
    
    @State private var task: Task<Void, Never>?
    
    public init(role: ButtonRole? = nil, action: @escaping () async -> Void, label: @escaping () -> Label) { //TODO: instead of nil to ... sf symbol
        self.action = action
        self.label = label
        self.role = role
    }
    
    public var body: some View {
        Button(role: role) {
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
            label()
        }
        .disabled(disabled)
    }
    public var disabled: Bool {
        if disableButton { task != nil } else { false }
    }
}

extension AsyncButton where Label == Text {
    public init<S: StringProtocol>(_ title: S, role: ButtonRole? = nil, action: @escaping () async -> Void) {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () async -> Void) {
        self.init(role: role, action: action) {
            Text(titleKey)
        }
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
