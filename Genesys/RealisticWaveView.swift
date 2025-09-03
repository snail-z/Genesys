import UIKit

class RealisticWaveView: UIView {
    
    // MARK: - Properties
    private var waveDisplayLink: CADisplayLink?
    private var waveStartTime: CFTimeInterval = 0
    private var progressLabel: UILabel!
    
    // 波浪图层
    private var firstWaveLayer: CAShapeLayer!
    private var secondWaveLayer: CAShapeLayer!
    
    // 进度相关
    private var currentProgress: CGFloat = 0.0
    private var targetProgress: CGFloat = 0.0 {
        didSet {
            updateProgressLabel()
        }
    }
    
    // 进度动画
    private var isAnimatingProgress = false
    private var progressStartTime: CFTimeInterval = 0
    private var progressDuration: TimeInterval = 3.0
    private var initialProgress: CGFloat = 0.0
    
    // 波浪振幅倍数 - 可调参数
    var waveAmplitudeMultiplier: CGFloat = 1.0 {
        didSet {
            // 当振幅改变时，重新计算波浪配置
            updateWaveConfigs()
        }
    }
    
    // 波浪速度倍数 - 可调参数
    var waveSpeedMultiplier: CGFloat = 1.0 {
        didSet {
            // 当速度改变时，重新计算波浪配置
            updateWaveConfigs()
        }
    }
    
    // 波浪参数 - 模拟真实液体
    private var primaryWave = WaveConfig(
        amplitude: 4.0,      // 主波浪振幅（减小基础振幅）
        frequency: 0.8,      // 主波浪频率  
        speed: 1.8,          // 主波浪速度（加快速度）
        phase: 0.0           // 主波浪相位
    )
    
    private var secondaryWave = WaveConfig(
        amplitude: 2.5,      // 次波浪振幅（减小基础振幅）
        frequency: 1.3,      // 次波浪频率
        speed: 1.2,          // 次波浪速度（加快速度）
        phase: .pi           // 次波浪相位差
    )
    
    // 波浪配置结构
    private struct WaveConfig {
        var amplitude: CGFloat
        let frequency: CGFloat
        var speed: CGFloat
        let phase: CGFloat
    }
    
    // 更新波浪配置
    private func updateWaveConfigs() {
        // 根据倍数调整振幅和速度
        primaryWave.amplitude = 4.0 * waveAmplitudeMultiplier
        secondaryWave.amplitude = 2.5 * waveAmplitudeMultiplier
        primaryWave.speed = 1.8 * waveSpeedMultiplier
        secondaryWave.speed = 1.2 * waveSpeedMultiplier
    }
    
    // 颜色配置
    var primaryWaveColor: UIColor = .systemGreen {
        didSet {
            firstWaveLayer?.fillColor = primaryWaveColor.cgColor
        }
    }
    
    var secondaryWaveColor: UIColor = UIColor.systemGreen.withAlphaComponent(0.7) {
        didSet {
            secondWaveLayer?.fillColor = secondaryWaveColor.cgColor
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        clipsToBounds = true
        
        setupWaveLayers()
        setupProgressLabel()
    }
    
    private func setupWaveLayers() {
        // 第一层波浪 - 主要波浪
        firstWaveLayer = CAShapeLayer()
        firstWaveLayer.fillColor = primaryWaveColor.cgColor
        firstWaveLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(firstWaveLayer)
        
        // 第二层波浪 - 增加层次感和真实感
        secondWaveLayer = CAShapeLayer()
        secondWaveLayer.fillColor = secondaryWaveColor.cgColor
        secondWaveLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(secondWaveLayer)
    }
    
    private func setupProgressLabel() {
        progressLabel = UILabel()
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        progressLabel.textColor = .white
        progressLabel.layer.shadowColor = UIColor.black.cgColor
        progressLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        progressLabel.layer.shadowRadius = 2
        progressLabel.layer.shadowOpacity = 0.3
        addSubview(progressLabel)
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateProgressLabel()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        firstWaveLayer?.frame = bounds
        secondWaveLayer?.frame = bounds
        
        if waveDisplayLink == nil && bounds.width > 0 && bounds.height > 0 {
            startWaveAnimation()
        }
    }
    
    // MARK: - Wave Animation
    private func startWaveAnimation() {
        stopWaveAnimation()
        
        waveDisplayLink = CADisplayLink(target: self, selector: #selector(updateWaves))
        waveDisplayLink?.preferredFramesPerSecond = 60 // 确保60FPS
        waveDisplayLink?.add(to: .main, forMode: .common)
        waveStartTime = CACurrentMediaTime()
    }
    
    private func stopWaveAnimation() {
        waveDisplayLink?.invalidate()
        waveDisplayLink = nil
    }
    
    @objc private func updateWaves() {
        let currentTime = CACurrentMediaTime()
        let waveTime = currentTime - waveStartTime
        
        // 更新进度动画
        updateProgressAnimation(currentTime: currentTime)
        
        // 创建真实的波浪效果
        let primaryWavePath = createRealisticWavePath(
            time: waveTime,
            config: primaryWave,
            progress: currentProgress
        )
        
        let secondaryWavePath = createRealisticWavePath(
            time: waveTime,
            config: secondaryWave,
            progress: currentProgress
        )
        
        // 更新图层
        CATransaction.begin()
        CATransaction.setDisableActions(true) // 禁用隐式动画，确保流畅
        firstWaveLayer.path = primaryWavePath.cgPath
        secondWaveLayer.path = secondaryWavePath.cgPath
        CATransaction.commit()
    }
    
    private func updateProgressAnimation(currentTime: CFTimeInterval) {
        guard isAnimatingProgress else { return }
        
        let elapsed = currentTime - progressStartTime
        let normalizedTime = min(elapsed / progressDuration, 1.0)
        
        // 使用更自然的缓动函数
        let progress = easeOutCubic(normalizedTime)
        currentProgress = initialProgress + (targetProgress - initialProgress) * progress
        
        if normalizedTime >= 1.0 {
            currentProgress = targetProgress
            isAnimatingProgress = false
        }
        
        updateProgressLabel()
    }
    
    private func createRealisticWavePath(time: CFTimeInterval, config: WaveConfig, progress: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        
        guard width > 0 && height > 0 && progress > 0 else { return path }
        
        // 水位线高度
        let baseWaterLevel = height * (1.0 - progress)
        
        // 开始绘制
        path.move(to: CGPoint(x: 0, y: height))
        
        // 更精细的采样 - 提高波浪质量
        let samplingRate: CGFloat = 1.0
        var wavePoints: [CGPoint] = []
        
        for x in stride(from: 0, through: width, by: samplingRate) {
            let normalizedX = x / width
            
            // 多层波浪叠加 - 模拟真实液体的复杂运动
            let primarySin = sin(normalizedX * .pi * 2 * config.frequency + time * config.speed + config.phase)
            let harmonicSin = sin(normalizedX * .pi * 4 * config.frequency + time * config.speed * 1.3 + config.phase) * 0.3
            let subHarmonicSin = sin(normalizedX * .pi * 0.8 * config.frequency + time * config.speed * 0.7 + config.phase) * 0.2
            
            // 组合波形 - 创造更自然的液体表面
            let combinedWave = (primarySin + harmonicSin + subHarmonicSin) * config.amplitude
            
            // 添加边缘衰减效果，让波浪在容器边缘更自然
            let edgeFactor = sin(normalizedX * .pi)
            let dampedAmplitude = combinedWave * edgeFactor * 0.8
            
            let y = baseWaterLevel + dampedAmplitude
            wavePoints.append(CGPoint(x: x, y: y))
        }
        
        // 连接第一个水面点
        if let firstPoint = wavePoints.first {
            path.addLine(to: CGPoint(x: 0, y: firstPoint.y))
        }
        
        // 使用平滑的曲线连接波浪点
        drawSmoothCurve(path: path, points: wavePoints)
        
        // 封闭路径
        path.addLine(to: CGPoint(x: width, y: height))
        path.close()
        
        return path
    }
    
    private func drawSmoothCurve(path: UIBezierPath, points: [CGPoint]) {
        guard points.count > 2 else {
            points.forEach { path.addLine(to: $0) }
            return
        }
        
        // 使用卡特穆尔-罗姆曲线算法创建超平滑的波浪
        for i in 0..<points.count {
            let currentPoint = points[i]
            
            if i == 0 {
                path.addLine(to: currentPoint)
            } else if i == points.count - 1 {
                path.addLine(to: currentPoint)
            } else {
                let previousPoint = points[i - 1]
                let nextPoint = points[i + 1]
                let nextNextPoint = i + 2 < points.count ? points[i + 2] : points[i + 1]
                
                // 卡特穆尔-罗姆控制点计算
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (currentPoint.x - (i >= 2 ? points[i - 2] : previousPoint).x) / 6,
                    y: previousPoint.y + (currentPoint.y - (i >= 2 ? points[i - 2] : previousPoint).y) / 6
                )
                
                let controlPoint2 = CGPoint(
                    x: currentPoint.x - (nextPoint.x - previousPoint.x) / 6,
                    y: currentPoint.y - (nextPoint.y - previousPoint.y) / 6
                )
                
                path.addCurve(to: currentPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
        }
    }
    
    // MARK: - Easing Functions
    private func easeOutCubic(_ t: Double) -> CGFloat {
        let f = t - 1.0
        return CGFloat(f * f * f + 1.0)
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool = false, duration: TimeInterval = 3.0) {
        let clampedProgress = max(0.0, min(1.0, progress))
        
        if animated {
            initialProgress = currentProgress
            targetProgress = clampedProgress
            progressStartTime = CACurrentMediaTime()
            progressDuration = duration
            isAnimatingProgress = true
        } else {
            currentProgress = clampedProgress
            targetProgress = clampedProgress
            isAnimatingProgress = false
            updateProgressLabel()
        }
    }
    
    /// 设置波浪振幅大小
    /// - Parameter amplitudeMultiplier: 振幅倍数 (1.0 = 默认, 1.5 = 大一点, 2.0 = 很大)
    func setWaveAmplitude(_ amplitudeMultiplier: CGFloat) {
        self.waveAmplitudeMultiplier = max(0.1, min(3.0, amplitudeMultiplier)) // 限制在合理范围
    }
    
    /// 设置波浪速度
    /// - Parameter speedMultiplier: 速度倍数 (1.0 = 默认, 1.5 = 快一点, 2.0 = 很快)
    func setWaveSpeed(_ speedMultiplier: CGFloat) {
        self.waveSpeedMultiplier = max(0.1, min(3.0, speedMultiplier)) // 限制在合理范围
    }
    
    /// 同时设置波浪振幅和速度
    /// - Parameters:
    ///   - amplitude: 振幅倍数
    ///   - speed: 速度倍数
    func setWaveProperties(amplitude: CGFloat, speed: CGFloat) {
        setWaveAmplitude(amplitude)
        setWaveSpeed(speed)
    }
    
    private func updateProgressLabel() {
        let percentage = Int(targetProgress * 100)
        progressLabel.text = "\(percentage)%"
    }
    
    // MARK: - Lifecycle
    deinit {
        stopWaveAnimation()
    }
}

// MARK: - Factory Methods
extension RealisticWaveView {
    static func batteryStyle(waveAmplitude: CGFloat = 1.0, waveSpeed: CGFloat = 1.0) -> RealisticWaveView {
        let waveView = RealisticWaveView()
        waveView.primaryWaveColor = .systemGreen
        waveView.secondaryWaveColor = UIColor.systemGreen.withAlphaComponent(0.6)
        waveView.setWaveProperties(amplitude: waveAmplitude, speed: waveSpeed)
        return waveView
    }
    
    static func waterStyle(waveAmplitude: CGFloat = 1.2, waveSpeed: CGFloat = 1.0) -> RealisticWaveView {
        let waveView = RealisticWaveView()
        waveView.primaryWaveColor = .systemBlue
        waveView.secondaryWaveColor = UIColor.systemBlue.withAlphaComponent(0.6)
        waveView.setWaveProperties(amplitude: waveAmplitude, speed: waveSpeed)
        return waveView
    }
}