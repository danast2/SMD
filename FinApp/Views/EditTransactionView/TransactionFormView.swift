//
//  TransactionFormView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 11.07.2025.
//

import SwiftUI

enum TransactionFormMode { case create, edit }

struct TransactionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var listVM: TransactionsListViewModel
    @StateObject private var vm: TransactionFormViewModel

    @State private var errorMessage: String?

    private let categoriesService: any CategoriesServiceProtocol

    init(
        mode: TransactionFormMode,
        transaction: Transaction? = nil,
        direction: Direction,
        transactionsService: any TransactionsServiceProtocol,
        bankAccountService: any BankAccountServiceProtocol,
        categoriesService: any CategoriesServiceProtocol
    ) {
        self.categoriesService = categoriesService
        _vm = StateObject(
            wrappedValue: TransactionFormViewModel(
                mode: mode,
                original: transaction,
                direction: direction,
                transactionsService: transactionsService,
                bankAccountService: bankAccountService,
                categoriesService: categoriesService
            )
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Picker("Статья", selection: $vm.selectedCategory) {
                    Text("— выберите —").tag(nil as Category?)
                    ForEach(vm.categories) { cat in
                        Text("\(cat.emoji) \(cat.name)")
                            .tag(cat as Category?)
                    }
                }
                .pickerStyle(.menu)

                HStack {
                    Text("Сумма")
                    Spacer()
                    TextField("0", text: $vm.amountString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: vm.amountString) { newValue in
                            let decSep = Locale.current.decimalSeparator ?? "."
                            var filtered = newValue.filter { $0.isNumber || String($0) == decSep }
                            if let first = filtered.firstIndex(of: Character(decSep)) {
                                let prefix = filtered[...first]
                                let suffix = filtered[filtered.index(after: first)...]
                                    .filter { String($0) != decSep }
                                filtered = String(prefix) + String(suffix)
                            }
                            vm.amountString = filtered
                        }
                }

                DatePicker("Дата",
                           selection: $vm.day,
                           in: ...Date(),
                           displayedComponents: .date)

                DatePicker("Время",
                           selection: $vm.time,
                           displayedComponents: .hourAndMinute)

                TextField("Комментарий", text: $vm.comment)
                    .foregroundColor(vm.comment.isEmpty ? .secondary : .primary)
            }
            .navigationTitle(vm.mode == .create ? "Новая операция" : "Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(vm.mode == .create ? "Создать" : "Сохранить") {
                        guard vm.isValid else { vm.showValidationAlert = true; return }
                        Task {
                            do {
                                try await vm.save()
                                listVM.loadTransactionsForListView()
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }
            .alert("Заполните все поля", isPresented: $vm.showValidationAlert) { }
            .alert("Ошибка", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) { } message: {
                Text(errorMessage ?? "Неизвестная ошибка")
            }
            .safeAreaInset(edge: .bottom) {
                if vm.mode == .edit {
                    Button {
                        Task {
                            do {
                                try await vm.delete()
                                listVM.loadTransactionsForListView()
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text(vm.direction == .income ? "Удалить доход" : "Удалить расход")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
