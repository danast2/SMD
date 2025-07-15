//
//  LoadingOverlay.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import SwiftUI
import Combine

private struct LoadingOverlay: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isLoading {
                        loadingHUD()
                            .transition(.opacity
                                        .combined(with: .scale(scale: 0.9)))
                    }
                }
            )
            .animation(.easeInOut(duration: 0.25), value: isLoading)
    }

    @ViewBuilder
    private func loadingHUD() -> some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.automatic)
                .controlSize(.large)
                .frame(width: 250, height: 60)
                .tint(.black)
        }
    }
}

extension View {
    func loading(_ flag: Bool) -> some View {
        modifier(LoadingOverlay(isLoading: flag))
    }
}

public enum NetworkActivity {
    public static let counter = CurrentValueSubject<Int, Never>(0)
}
