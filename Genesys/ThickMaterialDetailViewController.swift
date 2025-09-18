import UIKit
import SnapKit

class ThickMaterialDetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    
    private let backgroundImageView = UIImageView()
    private let sampleContainer = UIView()
    
    // 状态栏隐藏状态
    private var shouldHideStatusBar = false
    
    // 控制状态栏隐藏
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    // 状态栏隐藏动画 - 使用淡入淡出效果
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        createThickMaterialExamples()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 延迟隐藏状态栏，创建更平滑的过渡效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.shouldHideStatusBar = true
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 提前显示状态栏，确保返回时状态栏已经可见
        shouldHideStatusBar = false
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func setupNavigationBar() {
        title = "厚材质详细演示"
//        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 背景图片
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = createComplexGradientImage()
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        titleLabel.text = "厚材质效果详解"
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sampleContainer)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        sampleContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func createThickMaterialExamples() {
        let examples = [
            ("systemThickMaterial", UIBlurEffect.Style.systemThickMaterial, "系统厚材质 - 最常用的厚重毛玻璃效果"),
            ("systemMaterial", UIBlurEffect.Style.systemMaterial, "系统材质 - 标准厚度的毛玻璃效果"),
            ("systemThinMaterial", UIBlurEffect.Style.systemThinMaterial, "系统薄材质 - 轻薄的毛玻璃效果"),
            ("systemUltraThinMaterial", UIBlurEffect.Style.systemUltraThinMaterial, "超薄材质 - 最轻薄的毛玻璃效果"),
            ("systemThickMaterialLight", UIBlurEffect.Style.systemThickMaterialLight, "厚材质亮色 - 适合浅色背景"),
            ("systemThickMaterialDark", UIBlurEffect.Style.systemThickMaterialDark, "厚材质暗色 - 适合深色背景")
        ]
        
        var previousView: UIView?
        
        for (name, style, description) in examples {
            let containerView = createDetailedMaterialExample(name: name, style: style, description: description)
            sampleContainer.addSubview(containerView)
            
            containerView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(120)
                
                if let previous = previousView {
                    make.top.equalTo(previous.snp.bottom).offset(20)
                } else {
                    make.top.equalToSuperview()
                }
            }
            
            previousView = containerView
        }
        
        // 创建交互演示区域
        let interactiveTitle = UILabel()
        interactiveTitle.text = "交互演示区域"
        interactiveTitle.font = .boldSystemFont(ofSize: 24)
        interactiveTitle.textColor = .white
        interactiveTitle.textAlignment = .center
        
        sampleContainer.addSubview(interactiveTitle)
        interactiveTitle.snp.makeConstraints { make in
            make.top.equalTo(previousView!.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        
        let interactiveDemo = createInteractiveMaterialDemo()
        sampleContainer.addSubview(interactiveDemo)
        
        interactiveDemo.snp.makeConstraints { make in
            make.top.equalTo(interactiveTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview()
        }
    }
    
    private func createDetailedMaterialExample(name: String, style: UIBlurEffect.Style, description: String) -> UIView {
        let containerView = UIView()
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.textColor = .white.withAlphaComponent(0.9)
        
        containerView.addSubview(descLabel)
        containerView.addSubview(blurView)
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(nameLabel)
        
        blurView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(80)
        }
        
        vibrancyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(25)
        }
        
        return containerView
    }
    
    private func createInteractiveMaterialDemo() -> UIView {
        let containerView = UIView()
        
        // 创建多层材质效果演示
        let layer1 = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        layer1.layer.cornerRadius = 20
        layer1.clipsToBounds = true
        
        let layer2 = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        layer2.layer.cornerRadius = 16
        layer2.clipsToBounds = true
        
        let layer3 = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        layer3.layer.cornerRadius = 12
        layer3.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.text = "多层材质叠加效果"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "点击体验不同的材质组合"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(layer1)
        layer1.contentView.addSubview(layer2)
        layer2.contentView.addSubview(layer3)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        layer1.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        layer2.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.8)
        }
        
        layer3.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        // 添加交互动画
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateMaterials))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        return containerView
    }
    
    @objc private func animateMaterials() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            // 创建弹性动画效果
            self.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.4) {
                self.view.transform = .identity
            }
        }
    }
    
    private func createComplexGradientImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [
                UIColor.systemIndigo.cgColor,
                UIColor.systemPurple.cgColor,
                UIColor.systemPink.cgColor,
                UIColor.systemOrange.cgColor,
                UIColor.systemYellow.cgColor
            ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 0.25, 0.5, 0.75, 1])!
            
            // 径向渐变
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                startRadius: 0,
                endCenter: CGPoint(x: size.width * 0.7, y: size.height * 0.7),
                endRadius: min(size.width, size.height) * 0.8,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
    }
}
