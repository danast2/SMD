import UIKit

public final class PieChartView: UIView {

    private static let sectorColors: [UIColor] = [
        .systemBlue, .systemGreen, .systemYellow,
        .systemRed, .systemOrange, .systemPurple
    ]

    private let thicknessRatio: CGFloat = 0.3
    private let animationDuration: TimeInterval = 0.8

    public var entities: [Entity] = [] {
        didSet { redraw(animated: true) }
    }

    private var displayEntities: [Entity] = []
    private var total: Decimal = 0

    private let legendLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unavailable")
    }

    private func commonInit() {
        backgroundColor = .clear
        addSubview(legendLabel)
        NSLayoutConstraint.activate([
            legendLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            legendLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            legendLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8)
        ])
    }

    public override func draw(_ rect: CGRect) {
        guard total > 0,
              let ctx = UIGraphicsGetCurrentContext()
        else { return }

        let outerRadius = min(bounds.width, bounds.height) * 0.5 - 4
        let innerRadius = outerRadius * (1 - thicknessRatio)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        var startAngle = -CGFloat.pi / 2
        for (index, entity) in displayEntities.enumerated() {
            let percent = CGFloat((entity.value / total).doubleValue)
            let endAngle = startAngle + percent * 2 * .pi

            ctx.setFillColor(Self.sectorColors[index].cgColor)

            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: outerRadius,
                        startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addArc(withCenter: center, radius: innerRadius,
                        startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()

            ctx.addPath(path.cgPath)
            ctx.fillPath()

            startAngle = endAngle
        }
    }

    private func redraw(animated: Bool) {
        prepareData()

        if animated {
            animateTransition()
        } else {
            setNeedsDisplay()
        }

        updateLegend()
    }

    private func prepareData() {
        let top5 = Array(entities.prefix(5))
        let othersSum = entities.dropFirst(5).reduce(Decimal.zero) { $0 + $1.value }

        displayEntities = othersSum > 0
            ? top5 + [Entity(value: othersSum, label: "Остальные")]
            : top5

        total = displayEntities.reduce(0) { $0 + $1.value }
    }

    private func animateTransition() {
        let oldSnapshot = layer.snapshot()
        oldSnapshot.frame = bounds
        addSubview(oldSnapshot)

        setNeedsDisplay()
        layoutIfNeeded()
        alpha = 0
        transform = CGAffineTransform(rotationAngle: -.pi)

        UIView.animateKeyframes(withDuration: animationDuration,
                                delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                oldSnapshot.alpha = 0
                oldSnapshot.transform = CGAffineTransform(rotationAngle: .pi)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.alpha = 1
                self.transform = .identity
            }
        } completion: { _ in
            oldSnapshot.removeFromSuperview()
        }
    }

    private func updateLegend() {
        guard total > 0 else {
            legendLabel.attributedText = nil
            return
        }

        let legendHTML = displayEntities.enumerated().map { idx, entity in
            let colorHex = Self.sectorColors[idx].hex
            let percent = (entity.value / total).doubleValue * 100
            return """
            <span style="font-size:14">
              <span style="color:\(colorHex)">●</span>&nbsp;
              \(String(format: "%.0f", percent))% \(entity.label)
            </span>
            """
        }.joined(separator: "<br>")

        let html = "<div style='text-align:center'>\(legendHTML)</div>"
        legendLabel.attributedText = html.html2attr
    }
}

private extension Decimal {
    var doubleValue: Double { (self as NSDecimalNumber).doubleValue }
}

private extension UIColor {
    var hex: String {
        guard let components = cgColor.components else { return "#000000" }
        let red = Int((components[safe: 0] ?? 0) * 255)
        let green = Int((components[safe: 1] ?? 0) * 255)
        let blue = Int((components[safe: 2] ?? 0) * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

private extension CALayer {
    func snapshot() -> UIImageView {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in render(in: ctx.cgContext) }
        return UIImageView(image: image)
    }
}

private extension String {
    var html2attr: NSAttributedString? {
        guard let data = data(using: .utf16) else { return nil }
        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
