import UIKit

class SimpleWaveProgressView: UIView {
    
    private var waveLayer: CAShapeLayer!
    private var displayLink: CADisplayLink?
    private var waveStartTime: CFTimeInterval = 0
    private var progressLabel: UILabel!
    
    // 当前显示的进度（用于动画）
    private var currentProgress: CGFloat = 0.0
    
    // 目标进度
    private var targetProgress: CGFloat = 0.0
    
    // 进度动画参数
    private var progressAnimationStartTime: CFTimeInterval = 0
    private var progressAnimationDuration: CFTimeInterval = 2.0
    private var animatingProgress = false
    
    var progress: CGFloat = 0.0 {
        didSet {
            updateProgressLabel()
        }
    }
    
    var waveColor: UIColor = .systemGreen {
        didSet {
            waveLayer?.fillColor = waveColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        clipsToBounds = true
        
        // 创建波浪图层
        waveLayer = CAShapeLayer()
        waveLayer.fillColor = waveColor.cgColor
        layer.addSublayer(waveLayer)
        
        // 创建进度标签
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
        
        updateProgressLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waveLayer.frame = bounds
        
        if displayLink == nil {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
        waveStartTime = CACurrentMediaTime()
    }
    
    @objc private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let waveElapsed = currentTime - waveStartTime
        
        // 更新进度动画
        if animatingProgress {
            let progressElapsed = currentTime - progressAnimationStartTime
            let normalizedTime = min(progressElapsed / progressAnimationDuration, 1.0)
            
            // 使用缓动函数让上涨更自然
            let easedTime = easeInOut(normalizedTime)
            currentProgress = targetProgress * easedTime
            
            // 动画完成
            if normalizedTime >= 1.0 {
                animatingProgress = false
                currentProgress = targetProgress
            }
        }
        
        // 更新进度标签
        let percentage = Int(currentProgress * 100)
        progressLabel.text = "\(percentage)%"
        
        // 创建带有当前进度的波浪路径
        let path = createWavePath(time: waveElapsed, progress: currentProgress)
        waveLayer.path = path.cgPath
    }
    
    private func easeInOut(_ t: Double) -> CGFloat {
        return CGFloat(t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t)
    }
    
    private func createWavePath(time: CFTimeInterval, progress: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        
        guard width > 0 && height > 0 else { return path }
        
        // 水位高度（从底部开始）
        let waterLevel = height * (1.0 - progress)
        
        // 如果进度为0，直接返回空路径
        if progress <= 0 {
            return path
        }
        
        // 开始路径 - 从底部开始
        path.move(to: CGPoint(x: 0, y: height))
        
        // 使用更平滑的波浪参数
        let waveAmplitude: CGFloat = 3.0  // 减小振幅让波浪更平缓
        let waveFrequency: CGFloat = 2.5   // 减少波浪数量
        let waveSpeed: CGFloat = 1.5       // 减慢速度让动画更柔和
        
        // 生成丝滑的波浪曲线 - 使用更小的步长
        let step: CGFloat = 0.5
        var points: [CGPoint] = []
        
        // 收集所有波浪点
        for x in stride(from: 0, through: width, by: step) {
            let normalizedX = x / width
            
            // 使用双重正弦波叠加，创造更自然的波浪效果
            let wave1 = sin(normalizedX * .pi * waveFrequency + time * waveSpeed) * waveAmplitude
            let wave2 = sin(normalizedX * .pi * waveFrequency * 1.5 + time * waveSpeed * 0.8) * waveAmplitude * 0.5
            
            let waveY = wave1 + wave2
            let y = waterLevel + waveY
            points.append(CGPoint(x: x, y: y))
        }
        
        // 确保第一个点连接到水面
        if let firstPoint = points.first {
            path.addLine(to: CGPoint(x: 0, y: firstPoint.y))
        }
        
        // 使用三次贝塞尔曲线绘制更平滑的波浪
        if points.count >= 4 {
            // 第一个点
            path.addLine(to: points[0])
            
            // 使用三次贝塞尔曲线连接所有点
            for i in 1..<points.count {
                let currentPoint = points[i]
                
                if i < points.count - 1 {
                    let nextPoint = points[i + 1]
                    let controlPoint1 = CGPoint(
                        x: points[i-1].x + (currentPoint.x - points[i-1].x) * 0.5,
                        y: points[i-1].y + (currentPoint.y - points[i-1].y) * 0.1
                    )
                    let controlPoint2 = CGPoint(
                        x: currentPoint.x + (nextPoint.x - currentPoint.x) * 0.5,
                        y: currentPoint.y + (nextPoint.y - currentPoint.y) * 0.1
                    )
                    
                    path.addCurve(to: currentPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                } else {
                    path.addLine(to: currentPoint)
                }
            }
        } else {
            // 备用：直接连接所有点
            for point in points {
                path.addLine(to: point)
            }
        }
        
        // 确保到达右边界
        path.addLine(to: CGPoint(x: width, y: waterLevel))
        
        // 封闭路径
        path.addLine(to: CGPoint(x: width, y: height))
        path.close()
        
        return path
    }
    
    private func updateProgressLabel() {
        let percentage = Int(progress * 100)
        progressLabel.text = "\(percentage)%"
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = false, duration: TimeInterval = 2.0) {
        let clampedProgress = max(0.0, min(1.0, progress))
        
        if animated {
            // 设置目标进度和动画参数
            targetProgress = clampedProgress
            progressAnimationStartTime = CACurrentMediaTime()
            progressAnimationDuration = duration
            animatingProgress = true
        } else {
            // 直接设置进度
            currentProgress = clampedProgress
            targetProgress = clampedProgress
            self.progress = clampedProgress
            animatingProgress = false
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}