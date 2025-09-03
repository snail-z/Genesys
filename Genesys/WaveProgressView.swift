import UIKit

/// 水波进度视图 - 模拟液体波动效果
class WaveProgressView: UIView {
    
    // MARK: - Properties
    
    /// 进度值 (0.0 - 1.0)
    var progress: CGFloat = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    /// 波浪颜色
    var waveColor: UIColor = .systemGreen {
        didSet {
            waveLayer1.fillColor = waveColor.cgColor
            waveLayer2.fillColor = waveColor.withAlphaComponent(0.8).cgColor
        }
    }
    
    /// 背景颜色
    var backgroundColor1: UIColor = UIColor.systemGreen.withAlphaComponent(0.2) {
        didSet {
            backgroundColor = backgroundColor1
        }
    }
    
    /// 波浪振幅
    private let waveAmplitude: CGFloat = 6.0
    
    /// 波浪频率
    private let waveFrequency: CGFloat = 0.02
    
    /// 波浪速度
    private let waveSpeed: CGFloat = 2.0
    
    /// 第一层波浪
    private var waveLayer1: CAShapeLayer!
    
    /// 第二层波浪（相位差）
    private var waveLayer2: CAShapeLayer!
    
    /// 动画显示链接
    private var displayLink: CADisplayLink?
    
    /// 动画开始时间
    private var startTime: CFTimeInterval = 0
    
    /// 进度标签
    private var progressLabel: UILabel!
    
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
        clipsToBounds = true
        backgroundColor = backgroundColor1
        
        // 创建波浪图层
        setupWaveLayers()
        
        // 创建进度标签
        setupProgressLabel()
    }
    
    private func setupWaveLayers() {
        // 第一层波浪（主波浪）
        waveLayer1 = CAShapeLayer()
        waveLayer1.fillColor = waveColor.cgColor
        waveLayer1.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(waveLayer1)
        
        // 第二层波浪（增加层次感）
        waveLayer2 = CAShapeLayer()
        waveLayer2.fillColor = waveColor.withAlphaComponent(0.8).cgColor
        waveLayer2.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(waveLayer2)
    }
    
    private func setupProgressLabel() {
        progressLabel = UILabel()
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        progressLabel.textColor = .white
        addSubview(progressLabel)
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Animation
    
    private func startWaveAnimation() {
        stopWaveAnimation() // 确保之前的动画已停止
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveAnimation))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }
    
    private func stopWaveAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateWaveAnimation() {
        guard waveLayer1 != nil && waveLayer2 != nil else { return }
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        
        // 创建波浪路径
        let wavePath1 = createWavePath(phase: elapsedTime * waveSpeed)
        let wavePath2 = createWavePath(phase: elapsedTime * waveSpeed * 1.2 + .pi) // 相位差
        
        // 更新图层路径
        waveLayer1.path = wavePath1.cgPath
        waveLayer2.path = wavePath2.cgPath
    }
    
    private func createWavePath(phase: Double) -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        
        guard width > 0 && height > 0 else { return path }
        
        // 计算水位高度（从底部开始）
        let waterLevel = height * (1.0 - progress)
        
        // 开始绘制波浪路径
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel + waveAmplitude))
        
        // 绘制波浪曲线 - 使用更细致的步长
        let step: CGFloat = 2.0
        for x in stride(from: 0, through: width, by: step) {
            // 使用正弦函数创建波浪效果
            let waveY = sin((x * waveFrequency) + phase) * waveAmplitude
            let y = waterLevel + waveY
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // 确保到达右边界
        let finalWaveY = sin((width * waveFrequency) + phase) * waveAmplitude
        path.addLine(to: CGPoint(x: width, y: waterLevel + finalWaveY))
        
        // 封闭路径
        path.addLine(to: CGPoint(x: width, y: height))
        path.close()
        
        return path
    }
    
    // MARK: - Public Methods
    
    private func updateProgress() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 更新进度标签
            let percentage = Int(self.progress * 100)
            self.progressLabel.text = "\(percentage)%"
            
            // 波浪动画会在 updateWaveAnimation 中自动更新
        }
    }
    
    /// 设置进度值并带有动画效果
    /// - Parameters:
    ///   - progress: 目标进度值 (0.0 - 1.0)
    ///   - animated: 是否使用动画
    ///   - duration: 动画时长
    func setProgress(_ progress: CGFloat, animated: Bool = true, duration: TimeInterval = 0.8) {
        let clampedProgress = max(0.0, min(1.0, progress))
        
        if animated {
            // 创建平滑的进度变化动画
            let animation = CABasicAnimation(keyPath: "progress")
            animation.fromValue = self.progress
            animation.toValue = clampedProgress
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // 使用 CADisplayLink 实现平滑的数值变化
            animateProgress(from: self.progress, to: clampedProgress, duration: duration)
        } else {
            self.progress = clampedProgress
        }
    }
    
    private func animateProgress(from startProgress: CGFloat, to endProgress: CGFloat, duration: TimeInterval) {
        let startTime = CACurrentMediaTime()
        let progressDiff = endProgress - startProgress
        
        let progressDisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressAnimation))
        progressDisplayLink.add(to: .main, forMode: .common)
        
        // 存储动画参数
        objc_setAssociatedObject(self, "startTime", startTime, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "startProgress", startProgress, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "progressDiff", progressDiff, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "duration", duration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "progressDisplayLink", progressDisplayLink, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func updateProgressAnimation() {
        guard let startTime = objc_getAssociatedObject(self, "startTime") as? CFTimeInterval,
              let startProgress = objc_getAssociatedObject(self, "startProgress") as? CGFloat,
              let progressDiff = objc_getAssociatedObject(self, "progressDiff") as? CGFloat,
              let duration = objc_getAssociatedObject(self, "duration") as? TimeInterval,
              let progressDisplayLink = objc_getAssociatedObject(self, "progressDisplayLink") as? CADisplayLink else {
            return
        }
        
        let currentTime = CACurrentMediaTime()
        let elapsed = currentTime - startTime
        let normalizedTime = min(elapsed / duration, 1.0)
        
        // 使用 ease-in-out 缓动函数
        let easedTime = easeInOut(normalizedTime)
        let currentProgress = startProgress + (progressDiff * easedTime)
        
        self.progress = currentProgress
        
        if normalizedTime >= 1.0 {
            // 动画完成，清理
            progressDisplayLink.invalidate()
            objc_setAssociatedObject(self, "progressDisplayLink", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func easeInOut(_ t: Double) -> CGFloat {
        return CGFloat(t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t)
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 确保波浪图层大小正确
        waveLayer1?.frame = bounds
        waveLayer2?.frame = bounds
        
        // 在布局完成后开始动画
        if displayLink == nil && bounds.width > 0 && bounds.height > 0 {
            startWaveAnimation()
        }
    }
    
    deinit {
        stopWaveAnimation()
    }
}

// MARK: - 使用示例扩展
extension WaveProgressView {
    
    /// 创建电池样式的水波进度视图
    static func batteryStyle(progress: CGFloat = 0.55) -> WaveProgressView {
        let waveView = WaveProgressView()
        waveView.waveColor = .systemGreen
        waveView.backgroundColor1 = UIColor.systemGreen.withAlphaComponent(0.1)
        waveView.progress = progress
        return waveView
    }
    
    /// 创建水样式的水波进度视图
    static func waterStyle(progress: CGFloat = 0.75) -> WaveProgressView {
        let waveView = WaveProgressView()
        waveView.waveColor = .systemBlue
        waveView.backgroundColor1 = UIColor.systemBlue.withAlphaComponent(0.1)
        waveView.progress = progress
        return waveView
    }
}