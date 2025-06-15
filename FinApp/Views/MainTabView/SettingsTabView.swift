//
//  SettingsTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        Text(TabType.settings.title)
            .font(.largeTitle)
            .tabItem {
                Label {
                    Text(TabType.settings.title)
                } icon: {
                    TabType.settings.icon
                }
            }
    }
}
