//
//  ItemsTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct ItemsTabView: View {
    var body: some View {
        Text(TabType.items.title)
            .font(.largeTitle)
            .tabItem {
                Label {
                    Text(TabType.items.title)
                } icon: {
                    TabType.items.icon
                }
            }
    }
}
