//
//  TransactionCell.swift
//  FinApp
//
//  Created by Даниил Дементьев on 10.07.2025.
//

import UIKit

final class TransactionCell: UITableViewCell {

    static let reuseIdentifier = "TransactionCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor(named: "NewAccentColor")?.withAlphaComponent(0.65)
        return view
    }()

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        separatorInset = .zero

        setupLayout()
    }

    @available(*, unavailable, message: "Use reuseIdentifier-based init")
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Layout
    private func setupLayout() {
        let horizontalInset: CGFloat = 16
        let pad: CGFloat = 12

        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            cardView.leadingAnchor.constraint(equalTo:
                                                contentView.leadingAnchor,
                                              constant: horizontalInset),
            cardView.trailingAnchor.constraint(equalTo:
                                                contentView.trailingAnchor,
                                               constant: -horizontalInset)
        ])

        cardView.addSubview(iconContainer)
        iconContainer.addSubview(iconLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(commentLabel)
        cardView.addSubview(rightStack)

        rightStack.addArrangedSubview(amountLabel)
        rightStack.addArrangedSubview(timeLabel)
        rightStack.addArrangedSubview(percentLabel)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            iconContainer.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 30),
            iconContainer.heightAnchor.constraint(equalToConstant: 30),

            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo:
                                                    iconContainer.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo:
                                                cardView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo:
                                                    rightStack.leadingAnchor, constant: -8),

            commentLabel.leadingAnchor.constraint(equalTo:
                                                    titleLabel.leadingAnchor),
            commentLabel.topAnchor.constraint(equalTo:
                                                titleLabel.bottomAnchor, constant: 2),
            commentLabel.trailingAnchor.constraint(lessThanOrEqualTo:
                                                    rightStack.leadingAnchor, constant: -8),

            rightStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            rightStack.trailingAnchor.constraint(equalTo:
                                                    cardView.trailingAnchor, constant: -pad),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo:
                                                cardView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with transaction: Transaction,
                   direction: Direction,
                   percent: Double) {

        iconLabel.text  = String(transaction.category.emoji)
        titleLabel.text = transaction.category.name

        if let comment = transaction.comment, !comment.isEmpty {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }

        amountLabel.text = transaction.amount.formatted(.currency(code: "RUB"))

        timeLabel.text = transaction.updatedAt > transaction.createdAt
            ? timeFormatter.string(from: transaction.updatedAt)
            : nil
        timeLabel.isHidden = (timeLabel.text == nil)

        percentLabel.text = String(format: "%.1f%%", percent)
    }
}
