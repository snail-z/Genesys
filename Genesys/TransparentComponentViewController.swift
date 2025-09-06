import UIKit
import SnapKit

class TransparentComponentViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    
    private let backgroundImageView = UIImageView()
    private let sampleContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        createTransparentExamples()
    }
    
    private func setupNavigationBar() {
        title = "透明组件演示"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 背景图片
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = createGradientImage()
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        titleLabel.text = "透明组件演示"
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
    
    private func createTransparentExamples() {
        let examples = [
            ("完全透明", 0.0),
            ("10% 透明", 0.1),
            ("30% 透明", 0.3),
            ("50% 透明", 0.5),
            ("70% 透明", 0.7),
            ("90% 透明", 0.9)
        ]
        
        var previousView: UIView?
        
        // 透明度示例
        for (index, (title, alpha)) in examples.enumerated() {
            let containerView = createTransparentExample(title: title, alpha: alpha)
            sampleContainer.addSubview(containerView)
            
            containerView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(80)
                
                if let previous = previousView {
                    make.top.equalTo(previous.snp.bottom).offset(16)
                } else {
                    make.top.equalToSuperview()
                }
            }
            
            previousView = containerView
        }
        
        // 毛玻璃效果示例
        let blurTitle = UILabel()
        blurTitle.text = "毛玻璃效果示例"
        blurTitle.font = .boldSystemFont(ofSize: 20)
        blurTitle.textColor = .white
        blurTitle.textAlignment = .center
        
        sampleContainer.addSubview(blurTitle)
        blurTitle.snp.makeConstraints { make in
            make.top.equalTo(previousView!.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        
        let blurEffects: [(String, UIBlurEffect.Style)] = [
            ("亮色毛玻璃", .light),
            ("暗色毛玻璃", .dark),
            ("系统材质", .systemMaterial),
            ("厚材质", .systemThickMaterial),
            ("薄材质", .systemThinMaterial)
        ]
        
        previousView = blurTitle
        
        for (title, style) in blurEffects {
            let blurView = createBlurExample(title: title, style: style)
            sampleContainer.addSubview(blurView)
            
            blurView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(80)
                make.top.equalTo(previousView!.snp.bottom).offset(16)
            }
            
            previousView = blurView
        }
        
        // 渐变透明示例
        let gradientTitle = UILabel()
        gradientTitle.text = "渐变透明效果"
        gradientTitle.font = .boldSystemFont(ofSize: 20)
        gradientTitle.textColor = .white
        gradientTitle.textAlignment = .center
        
        sampleContainer.addSubview(gradientTitle)
        gradientTitle.snp.makeConstraints { make in
            make.top.equalTo(previousView!.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        
        let gradientView = createGradientTransparentExample()
        sampleContainer.addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.top.equalTo(gradientTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
            make.bottom.equalToSuperview()
        }
    }
    
    private func createTransparentExample(title: String, alpha: CGFloat) -> UIView {
        let containerView = UIView()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBlue.withAlphaComponent(alpha)
        backgroundView.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = alpha < 0.5 ? .white : .black
        titleLabel.textAlignment = .center
        
        let alphaLabel = UILabel()
        alphaLabel.text = "Alpha: \(alpha)"
        alphaLabel.font = .systemFont(ofSize: 14)
        alphaLabel.textColor = alpha < 0.5 ? .white.withAlphaComponent(0.8) : .black.withAlphaComponent(0.8)
        alphaLabel.textAlignment = .center
        
        containerView.addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(alphaLabel)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        alphaLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        return containerView
    }
    
    private func createBlurExample(title: String, style: UIBlurEffect.Style) -> UIView {
        let containerView = UIView()
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        
        containerView.addSubview(blurView)
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(titleLabel)
        
        // 为厚材质添加点击事件
        if title == "厚材质" {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thickMaterialTapped))
            containerView.addGestureRecognizer(tapGesture)
            containerView.isUserInteractionEnabled = true
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        vibrancyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return containerView
    }
    
    private func createGradientTransparentExample() -> UIView {
        let containerView = UIView()
        
        let gradientView = UIView()
        gradientView.layer.cornerRadius = 12
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.0).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.7).cgColor,
            UIColor.systemPurple.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.locations = [0, 0.3, 0.7, 1]
        gradientLayer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = "透明度渐变效果"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        containerView.addSubview(gradientView)
        containerView.addSubview(titleLabel)
        
        gradientView.layer.addSublayer(gradientLayer)
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 设置渐变层的frame
        DispatchQueue.main.async {
            gradientLayer.frame = gradientView.bounds
        }
        
        return containerView
    }
    
    private func createGradientImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [
                UIColor.systemBlue.cgColor,
                UIColor.systemPurple.cgColor,
                UIColor.systemPink.cgColor
            ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 0.5, 1])!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变层的frame
        view.subviews.forEach { subview in
            updateGradientLayers(in: subview)
        }
    }
    
    private func updateGradientLayers(in view: UIView) {
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
        
        view.subviews.forEach { subview in
            updateGradientLayers(in: subview)
        }
    }
    
    @objc private func thickMaterialTapped() {
        let thickMaterialVC = ThickMaterialDetailViewController()
        navigationController?.pushViewController(thickMaterialVC, animated: true)
    }
}