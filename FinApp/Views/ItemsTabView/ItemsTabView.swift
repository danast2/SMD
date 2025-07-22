//
//  ItemsTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct ItemsTabView: View {

    @EnvironmentObject var viewModel: CategoriesViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchField

                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("title.items".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 12)

                    categoriesList
                }
            }
            .padding()
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("title.myItems".localized)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
        .loading(viewModel.isLoading)
        .alert("Ошибка", isPresented:
                .constant(viewModel.error != nil),
               presenting: viewModel.error) { _ in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
        .tabItem {
            Label {
                Text(TabType.items.title)
            } icon: {
                TabType.items.icon
            }
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("title.search".localized, text: $viewModel.searchQuery)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(Color(.systemGray5))
        .cornerRadius(15)
        .padding(.vertical, 8)
    }

    private var categoriesList: some View {
        List {
            ForEach(Array(viewModel.filteredCategories.enumerated()),
                    id: \.element.id) { index, category in
                CategoryRowView(category: category)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                            .padding(.top, index == 0 ? 0 : -16)
                            .padding(.bottom,
                                     index == viewModel.filteredCategories.count - 1
                                     ? 0 : -16)
                            .clipShape(Rectangle())
                    )
                    .listRowSeparator(
                        viewModel.filteredCategories.count == 1
                        ? .hidden
                        : index == 0
                        ? .hidden
                        : index == viewModel.filteredCategories.count - 1
                        ? .hidden
                        : .visible,
                        edges: viewModel.filteredCategories.count == 1
                        ? .all
                        : index == 0
                        ? .top
                        : index == viewModel.filteredCategories.count - 1
                        ? .bottom
                        : .all
                    )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }
}
