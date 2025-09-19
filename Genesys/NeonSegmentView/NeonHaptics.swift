import UIKit

// 统一封装的触觉反馈，便于集中管理与禁用
public enum NeonHaptics {
    public static func impactLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    public static func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

