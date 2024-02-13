import SwiftUI

public struct EllipsisAsyncButtonStyle: AsyncButtonStyle {
    public func makeLabel(configuration: AsyncLabelConfiguration) -> some View {
        configuration.label
            .opacity(configuration.isLoading ? 0 : 1)
            .overlay {
                Image(systemName: "ellipsis")
                    .symbolEffect(.variableColor.iterative.dimInactiveLayers, options: .repeating, value: configuration.isLoading)
                    .foregroundStyle(Color.accentColor)
                    .font(.title)
                    .opacity(configuration.isLoading ? 1 : 0)
            }
            .animation(.default, value: configuration.isLoading)
    }
}

extension AsyncButtonStyle where Self == EllipsisAsyncButtonStyle {
    public static var ellipsis: EllipsisAsyncButtonStyle {
        EllipsisAsyncButtonStyle()
    }
}

public struct OverlayAsyncButtonStyle: AsyncButtonStyle {
    public func makeLabel(configuration: AsyncLabelConfiguration) -> some View {
        configuration.label
            .opacity(configuration.isLoading ? 0 : 1)
            .overlay {
                if configuration.isLoading {
                    ProgressView()
                }
            }
            .animation(.default, value: configuration.isLoading)
    }
}

extension AsyncButtonStyle where Self == OverlayAsyncButtonStyle {
    public static var overlay: OverlayAsyncButtonStyle {
        OverlayAsyncButtonStyle()
    }
}

public struct NoneAsyncButtonStyle: AsyncButtonStyle {}

extension AsyncButtonStyle where Self == NoneAsyncButtonStyle {
    public static var none: NoneAsyncButtonStyle {
        NoneAsyncButtonStyle()
    }
}
