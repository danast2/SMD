//
//  MainTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI
import Combine
import os.log

struct MainTabView: View {

    private let networkClient: NetworkClient
    private let categoriesService: any CategoriesServiceProtocol
    private let bankAccountService: any BankAccountServiceProtocol
    private let transactionsService: TransactionsServiceImpl

    @State private var selectedTab: TabType = .expenses
    @State private var activeRequests = 0
    @StateObject private var outcomeVM: TransactionsListViewModel
    @StateObject private var incomeVM: TransactionsListViewModel
    @StateObject private var accountVM: BankAccountViewModel
    @StateObject private var categoriesVM: CategoriesViewModel

    init() {

        Task {
                await Self.performMigrationIfNeeded()
            }

        guard let baseURL = URL(string: "https://shmr-finance.ru/api/v1") else {
            fatalError("Некорректный baseURL")
        }
        let client = NetworkClient(
            baseURL: baseURL,
            tokenProvider: { "lswBOfQyeYzKG85pohokqiUZ" }
        )
        self.networkClient = client

        let categoriesStorage   = StorageFactory.makeCategories()
        let accountsStorage     = StorageFactory.makeAccounts()
        let transactionsStorage = StorageFactory.makeTransactions()
        let transactionsBackup  = StorageFactory.makeTransactionsBackup()
        let accountBackup       = StorageFactory.makeAccountBackup()

        let catService = CategoriesServiceImpl(
            networkClient: client,
            localStorage: categoriesStorage
        )
        let accService = BankAccountServiceImpl(
            networkClient: client,
            localStorage: accountsStorage,
            backupStorage: accountBackup
        )
        let accountVMInstance = BankAccountViewModel(service: accService)

        let trxService = TransactionsServiceImpl(
            networkClient: client,
            accountIdProvider: { accountVMInstance.account?.id },
            localStorage: transactionsStorage,
            backupStorage: transactionsBackup,
            accountsLocalStorage: accountsStorage,
            accountBackupStorage: accountBackup
        )

        self.categoriesService   = catService
        self.bankAccountService  = accService
        self.transactionsService = trxService

        _accountVM = StateObject(wrappedValue: accountVMInstance)

        let accountDidLoad = accountVMInstance.didLoad.eraseToAnyPublisher()

        _outcomeVM = StateObject(
            wrappedValue: TransactionsListViewModel(
                direction: .outcome,
                transactionsService: trxService,
                accountDidLoad: accountDidLoad
            )
        )
        _incomeVM = StateObject(
            wrappedValue: TransactionsListViewModel(
                direction: .income,
                transactionsService: trxService,
                accountDidLoad: accountDidLoad
            )
        )
        _categoriesVM = StateObject(
            wrappedValue: CategoriesViewModel(service: catService)
        )

        UITabBar.appearance().tintColor = UIColor(named: "NewAccentColor")
        UITabBar.appearance().unselectedItemTintColor = .gray

        #if DEBUG
        print("Storage engine:", currentEngine())
        #endif
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            ExpensesTabView(
                categoriesService: categoriesService,
                bankAccountService: bankAccountService
            )
            .environmentObject(outcomeVM)
            .tag(TabType.expenses)

            IncomeTabView(
                categoriesService: categoriesService,
                bankAccountService: bankAccountService
            )
            .environmentObject(incomeVM)
            .tag(TabType.income)

            AccountTabView()
                .environmentObject(accountVM)
                .tag(TabType.account)

            ItemsTabView()
                .environmentObject(categoriesVM)
                .tag(TabType.items)

            SettingsTabView()
                .tag(TabType.settings)
        }
        .onReceive(
            NetworkActivity.counter
                .receive(on: DispatchQueue.main)  
        ) { activeRequests = $0 }
        .tint(Color("NewAccentColor"))
    }
}

extension MainTabView {

    static func performMigrationIfNeeded() async {
        let current = currentEngine()

        guard
            let previous = StorageEngine(
                rawValue: UserDefaults.standard.string(forKey: "lastStorage") ?? current.rawValue
            ),
            previous != current
        else {
            return
        }

        let log = Logger(subsystem: "FinApp", category: "Migration")
        log.info("Need migration \(previous.rawValue) -> \(current.rawValue)")

        do {
            try await Migrator.migrate(from: previous, to: current)
            UserDefaults.standard.set(current.rawValue, forKey: "lastStorage")
            log.info("Migration succeeded")
        } catch {
            log.error("Migration failed – \(error, privacy: .public)")
        }
    }

}
