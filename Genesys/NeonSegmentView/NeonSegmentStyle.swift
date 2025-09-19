import UIKit

public struct NeonSegmentStyle {
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    public var indicatorColor: UIColor = UIColor.white.withAlphaComponent(0.15)
    public var normalForegroundColor: UIColor = .white
    public var selectedForegroundColor: UIColor = .systemBlue
    public var font: UIFont = .systemFont(ofSize: 12, weight: .medium)
    public var iconSize: CGSize = CGSize(width: 20, height: 20)
    public var contentSpacing: CGFloat = 4

    public init() { }
}

