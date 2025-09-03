import UIKit

/// 3D卡片动画工具类 - 提供优雅的四角轮转动画效果
class Card3DAnimationUtil {
    
    /// 3D动画配置参数
    struct AnimationConfig {
        /// 动画角度 (小号卡片建议0.4，中大号卡片建议0.25)
        let angle: Float
        /// 动画时长 (秒)
        let duration: Double
        /// 关键帧数量 (数量越多越丝滑)
        let totalFrames: Int
        /// 随机延迟范围 (避免多个动画同步)
        let delayRange: ClosedRange<Double>
        /// 透视效果强度 (值越小透视越强)
        let perspectiveStrength: Float
        
        /// 默认配置 - 适合中大号卡片
        static let `default` = AnimationConfig(
            angle: 0.25,
            duration: 15.0,
            totalFrames: 32,
            delayRange: 0.0...0.5,
            perspectiveStrength: 800.0
        )
        
        /// 小号卡片配置 - 角度更大，动画更明显
        static let small = AnimationConfig(
            angle: 0.4,
            duration: 15.0,
            totalFrames: 32,
            delayRange: 0.0...0.5,
            perspectiveStrength: 800.0
        )
    }
    
    /// 阴影配置参数
    struct ShadowConfig {
        /// 阴影偏移
        let offset: CGSize
        /// 阴影模糊半径
        let radius: CGFloat
        /// 阴影透明度
        let opacity: Float
        /// 阴影颜色
        let color: CGColor
        
        /// 默认阴影配置
        static let `default` = ShadowConfig(
            offset: CGSize(width: 0, height: 40),
            radius: 20,
            opacity: 0.25,
            color: UIColor.black.cgColor
        )
    }
    
    /// 为视图添加3D四角轮转动画
    /// - Parameters:
    ///   - view: 目标视图
    ///   - config: 动画配置 (默认为中大号卡片配置)
    ///   - animationKey: 动画标识符 (用于移除动画)
    ///   - forceRestart: 是否强制重新开始动画 (默认false，如果动画已存在则不重新开始)
    static func startCornerRotation(
        for view: UIView,
        config: AnimationConfig = .default,
        animationKey: String = "cornerRotation",
        forceRestart: Bool = false
    ) {
        // 检查动画是否已经存在，如果存在且不强制重启，则直接返回
        if !forceRestart && view.layer.animation(forKey: animationKey) != nil {
            return
        }
        
        // 如果视图尚未完成布局，延迟启动动画
        if view.frame.size.width == 0 || view.frame.size.height == 0 {
            DispatchQueue.main.async {
                startCornerRotation(for: view, config: config, animationKey: animationKey, forceRestart: forceRestart)
            }
            return
        }
        
        // 只有在强制重启时才移除之前的动画
        if forceRestart {
            view.layer.removeAnimation(forKey: animationKey)
        }
        
        // 设置透视效果，确保3D效果正确
        setupPerspective(for: view, strength: config.perspectiveStrength)
        
        // 创建四角轮转动画
        let animation = createCornerRotationAnimation(config: config, baseTransform: view.layer.transform)
        
        // 添加随机延迟，让多个动画不同步
        let randomDelay = Double.random(in: config.delayRange)
        animation.beginTime = CACurrentMediaTime() + randomDelay
        
        // 开始动画
        view.layer.add(animation, forKey: animationKey)
    }
    
    /// 停止指定视图的动画
    /// - Parameters:
    ///   - view: 目标视图
    ///   - animationKey: 动画标识符
    static func stopAnimation(for view: UIView, animationKey: String = "cornerRotation") {
        view.layer.removeAnimation(forKey: animationKey)
    }
    
    /// 为视图设置3D透视效果
    /// - Parameters:
    ///   - view: 目标视图
    ///   - strength: 透视强度 (值越小透视越强，建议800-1000)
    static func setupPerspective(for view: UIView, strength: Float = 800.0) {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / CGFloat(strength)
        view.layer.transform = transform
    }
    
    // MARK: - Private Methods
    
    /// 配置阴影效果
    private static func configureShadow(for view: UIView, config: ShadowConfig) {
//        view.layer.shadowColor = config.color
//        view.layer.shadowOffset = config.offset
//        view.layer.shadowRadius = config.radius
//        view.layer.shadowOpacity = config.opacity
//        view.layer.masksToBounds = false
    }
    
    /// 创建四角轮转动画
    private static func createCornerRotationAnimation(
        config: AnimationConfig,
        baseTransform: CATransform3D
    ) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        // 生成丝滑的关键帧
        var transforms: [CATransform3D] = []
        
        for i in 0..<config.totalFrames {
            let progress = Float(i) / Float(config.totalFrames - 1)
            let circleProgress = progress * 2 * Float.pi
            
            // 计算当前的X和Y轴旋转角度 (创建8字形运动轨迹)
            let xRotation = sin(circleProgress * 2) * config.angle * 0.8
            let yRotation = cos(circleProgress * 2) * config.angle * 0.8
            
            // 在基础transform基础上添加旋转
            var transform = baseTransform
            transform = CATransform3DRotate(transform, CGFloat(xRotation), 1.0, 0.0, 0.0)
            transform = CATransform3DRotate(transform, CGFloat(yRotation), 0.0, 1.0, 0.0)
            
            transforms.append(transform)
        }
        
        // 配置动画属性
        animation.values = transforms
        animation.duration = config.duration
        animation.repeatCount = Float.infinity
        animation.calculationMode = .cubic  // 三次贝塞尔插值，更丝滑
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        return animation
    }
}

// MARK: - UIView Extension

extension UIView {
    
    /// 开始3D卡片动画 (便捷方法)
    /// - Parameter isSmallCard: 是否为小号卡片
    func startCard3DAnimation(isSmallCard: Bool = false) {
        let config = isSmallCard ? Card3DAnimationUtil.AnimationConfig.small : .default
        Card3DAnimationUtil.startCornerRotation(for: self, config: config)
    }
    
    /// 停止3D卡片动画
    func stopCard3DAnimation() {
        Card3DAnimationUtil.stopAnimation(for: self)
    }
    
    /// 设置3D透视效果
    /// - Parameter strength: 透视强度
    func setupCard3DPerspective(strength: Float = 800.0) {
        Card3DAnimationUtil.setupPerspective(for: self, strength: strength)
    }
}
