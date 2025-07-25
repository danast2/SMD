//
//  AnalysisViewController.swift
//  FinApp
//
//  Created by Даниил Дементьев on 10.07.2025.
//

import UIKit
import Combine
import PieChart

final class AnalysisViewController: UIViewController {

    private let viewModel: TransactionsStoryViewModel
    private var cancellables = Set<AnyCancellable>()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "title.myAnalisys".localized
        label.font = .preferredFont(forTextStyle: .largeTitle).bold()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let separator1 = AnalysisViewController.makeSeparator()
    private let separator2 = AnalysisViewController.makeSeparator()

    private lazy var startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor(named: "NewAccentColor")?.withAlphaComponent(0.65)
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        picker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        return picker
    }()

    private lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor(named: "NewAccentColor")?.withAlphaComponent(0.65)
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        picker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        return picker
    }()

    private let startLabel = makeLeftTitle(text: "title.start".localized)
    private let endLabel   = makeLeftTitle(text: "title.end".localized)
    private let sumLabel   = makeLeftTitle(text: "title.summ".localized)

    private let sumValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pieChartView: PieChartView = {
        let view = PieChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var sortControl: UISegmentedControl = {
        let items = TransactionsStoryViewModel.SortOption.allCases.map { $0.localizedTitle }
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        return control
    }()

    private let operationsHeader: UILabel = {
        let label = UILabel()
        label.text = "title.operations".localized.uppercased()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .systemGray6
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TransactionCell.self,
                       forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        return table
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.hidesWhenStopped = true
        ind.translatesAutoresizingMaskIntoConstraints = false
        return ind
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: TransactionsStoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable, message: "Use init(viewModel:) instead")
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
        tableView.rowHeight = 66
        view.backgroundColor = .systemGray6
        setupLayout()
        bindViewModel()
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupLayout() {
        view.addSubview(headerLabel)
        view.addSubview(infoCardView)
        view.addSubview(sortControl)
        view.addSubview(operationsHeader)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)

        [startLabel, startDatePicker, separator1,
         endLabel, endDatePicker, separator2,
         sumLabel, sumValueLabel]
            .forEach { infoCardView.addSubview($0) }

        infoCardView.addSubview(pieChartView)

        let pad: CGFloat = 16

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.topAnchor,
                                             constant: pad),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            infoCardView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: pad),
            infoCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            infoCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            startLabel.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: pad),
            startLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: pad),
            startDatePicker.centerYAnchor.constraint(equalTo: startLabel.centerYAnchor),
            startDatePicker.trailingAnchor.constraint(equalTo:
                                                        infoCardView.trailingAnchor,
                                                      constant: -pad),

            separator1.topAnchor.constraint(equalTo: startLabel.bottomAnchor, constant: 12),
            separator1.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 20),
            separator1.trailingAnchor.constraint(equalTo:
                                                    infoCardView.trailingAnchor, constant: -20),
            separator1.heightAnchor.constraint(equalToConstant: 1),

            endLabel.topAnchor.constraint(equalTo: separator1.bottomAnchor, constant: 12),
            endLabel.leadingAnchor.constraint(equalTo: startLabel.leadingAnchor),
            endDatePicker.centerYAnchor.constraint(equalTo: endLabel.centerYAnchor),
            endDatePicker.trailingAnchor.constraint(equalTo: startDatePicker.trailingAnchor),

            separator2.topAnchor.constraint(equalTo: endLabel.bottomAnchor, constant: 12),
            separator2.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 20),
            separator2.trailingAnchor.constraint(equalTo:
                                                    infoCardView.trailingAnchor, constant: -20),
            separator2.heightAnchor.constraint(equalToConstant: 1),

            sumLabel.topAnchor.constraint(equalTo: separator2.bottomAnchor, constant: 12),
            sumLabel.leadingAnchor.constraint(equalTo: startLabel.leadingAnchor),
            sumValueLabel.centerYAnchor.constraint(equalTo: sumLabel.centerYAnchor),
            sumValueLabel.trailingAnchor.constraint(equalTo: startDatePicker.trailingAnchor),
            sortControl.topAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: pad),
            sortControl.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            sortControl.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),

            operationsHeader.topAnchor.constraint(equalTo: sortControl.bottomAnchor, constant: 20),
            operationsHeader.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            operationsHeader.trailingAnchor.constraint(equalTo: sortControl.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: operationsHeader.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            pieChartView.topAnchor.constraint(equalTo: sumLabel.bottomAnchor, constant: 12),
            pieChartView.leadingAnchor.constraint(equalTo:
                                                    infoCardView.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo:
                                                    infoCardView.trailingAnchor, constant: -16),
            pieChartView.heightAnchor.constraint(equalToConstant: 200),
            pieChartView.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -16)

        ])
    }

    private func bindViewModel() {
        viewModel.$startDate
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.startDatePicker.date = $0 }
            .store(in: &cancellables)

        viewModel.$endDate
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.endDatePicker.date = $0 }
            .store(in: &cancellables)

        viewModel.$totalAmount
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.sumValueLabel.text = $0.formatted(.currency(code: "RUB"))
            }
            .store(in: &cancellables)

        viewModel.$selectedSortOption
            .receive(on: RunLoop.main)
            .sink { [weak self] option in
                guard let self else { return }
                let idx = TransactionsStoryViewModel.SortOption.allCases.firstIndex(of: option) ?? 0
                sortControl.selectedSegmentIndex = idx
                tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$transactions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] loading in
                loading ? self?.activityIndicator.startAnimating()
                :
                self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.errorLabel.text = error.map {
                    "error.title".localized + ": " + $0.localizedDescription }
                self?.errorLabel.isHidden = (error == nil)
            }
            .store(in: &cancellables)

        viewModel.$transactions
            .receive(on: RunLoop.main)
            .sink { [weak self] txns in
                guard let self else { return }

                let grouped = Dictionary(grouping: txns, by: { $0.category.name })
                    .map { label, group in
                        Entity(
                            value: group.reduce(0) { $0 + $1.amount },
                            label: label
                        )
                    }

                pieChartView.entities = grouped.sorted { $0.value > $1.value }
            }
            .store(in: &cancellables)
    }

    @objc private func startDateChanged() {
        if startDatePicker.date > viewModel.endDate {
            viewModel.endDate = startDatePicker.date
        }
        viewModel.startDate = startDatePicker.date
        Task { await viewModel.reloadData() }
    }

    @objc private func endDateChanged() {
        if endDatePicker.date < viewModel.startDate {
            viewModel.startDate = endDatePicker.date
        }
        viewModel.endDate = endDatePicker.date
        Task { await viewModel.reloadData() }
    }

    @objc private func sortChanged() {
        let opt = TransactionsStoryViewModel.SortOption.allCases[sortControl.selectedSegmentIndex]
        viewModel.selectedSortOption = opt
    }

    private static func makeLeftTitle(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sortedTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TransactionCell.reuseIdentifier,
            for: indexPath
        ) as? TransactionCell else {
            return UITableViewCell()
        }

        let txn = viewModel.sortedTransactions[indexPath.row]
        let percent = viewModel.totalAmount.doubleValue == 0 ? 0 :
                      (txn.amount.doubleValue / viewModel.totalAmount.doubleValue) * 100

        cell.configure(with: txn, direction: viewModel.direction, percent: percent)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

private extension Decimal {
    var doubleValue: Double { (self as NSDecimalNumber).doubleValue }
}

private extension UIFont {
    func bold() -> UIFont { with(.traitBold) }
    private func with(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
