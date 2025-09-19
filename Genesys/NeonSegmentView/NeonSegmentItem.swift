import UIKit

public struct NeonSegmentItem {
    public let title: String
    public let icon: String
    public let id: String

    public init(title: String, icon: String, id: String? = nil) {
        self.title = title
        self.icon = icon
        self.id = id ?? title
    }
}

