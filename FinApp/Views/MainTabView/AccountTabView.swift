//
//  AccountTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct AccountTabView: View {
    var body: some View {
        Text(TabType.account.title)
            .font(.largeTitle)
            .tabItem {
                Label {
                    Text(TabType.account.title)
                } icon: {
                    TabType.account.icon
                }
            }
    }
}
