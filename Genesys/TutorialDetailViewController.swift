import UIKit
import SnapKit

class TutorialDetailViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var headerView: UIView!
    private var titleLabel: UILabel!
    private var tutorialContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Widget使用教程"
        
        setupScrollView()
        setupHeader()
        setupTutorialContent()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView = UIView()
        scrollView.addSubview(contentView)
    }
    
    private func setupHeader() {
        headerView = UIView()
        headerView.backgroundColor = .systemBackground
        contentView.addSubview(headerView)
        
        titleLabel = UILabel()
        titleLabel.text = "如何将小组件添加到主屏幕"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        headerView.addSubview(titleLabel)
    }
    
    private func setupTutorialContent() {
        tutorialContentView = UIView()
        contentView.addSubview(tutorialContentView)
        
        // 创建主要的小组件预览
        let mainWidgetPreview = createMainWidgetPreview()
        tutorialContentView.addSubview(mainWidgetPreview)
        
        // 创建详细步骤
        let stepsContainer = createDetailedSteps()
        tutorialContentView.addSubview(stepsContainer)
        
        // 创建底部编辑教程部分
        let editTutorialSection = createEditTutorialSection()
        tutorialContentView.addSubview(editTutorialSection)
        
        // 设置约束
        mainWidgetPreview.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(180)
        }
        
        stepsContainer.snp.makeConstraints { make in
            make.top.equalTo(mainWidgetPreview.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        editTutorialSection.snp.makeConstraints { make in
            make.top.equalTo(stepsContainer.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    private func createMainWidgetPreview() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // 创建渐变背景的小组件
        let widgetView = UIView()
        widgetView.layer.cornerRadius = 24
        container.addSubview(widgetView)
        
        // 添加渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemOrange.cgColor,
            UIColor.systemPink.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 24
        widgetView.layer.insertSublayer(gradientLayer, at: 0)
        
        // 时间标签
        let timeLabel = UILabel()
        timeLabel.text = "23:59"
        timeLabel.font = UIFont.systemFont(ofSize: 56, weight: .ultraLight)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .left
        widgetView.addSubview(timeLabel)
        
        // 星期标签
        let dayLabel = UILabel()
        dayLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        dayLabel.textColor = .white
        
        let attributedString = NSMutableAttributedString(string: "WEDNESDAY")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 2.0, range: NSRange(location: 0, length: attributedString.length))
        dayLabel.attributedText = attributedString
        
        widgetView.addSubview(dayLabel)
        
        // 日期标签
        let dateLabel = UILabel()
        dateLabel.text = "September 3"
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        widgetView.addSubview(dateLabel)
        
        widgetView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(180)
        }
        
        // 延迟设置渐变层frame
        DispatchQueue.main.async {
            gradientLayer.frame = widgetView.bounds
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
        }
        
        dayLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(24)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(24)
        }
        
        return container
    }
    
    private func createDetailedSteps() -> UIView {
        let container = UIView()
        
        let steps = [
            ("1", "长按主屏幕上的任意位置，并轻点左上角的\n⊕ 按钮。"),
            ("2", "在小组件列表中找到并选择百变主题。"),
            ("3", "滑动来设置小组件的尺寸，并轻点\"添加小\n组件\"。")
        ]
        
        var previousStepView: UIView?
        
        for (stepNumber, stepText) in steps {
            let stepView = createDetailedStepView(number: stepNumber, text: stepText)
            container.addSubview(stepView)
            
            stepView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let previous = previousStepView {
                    make.top.equalTo(previous.snp.bottom).offset(24)
                } else {
                    make.top.equalToSuperview()
                }
                if stepNumber == "3" {
                    make.bottom.equalToSuperview()
                }
            }
            
            previousStepView = stepView
        }
        
        return container
    }
    
    private func createDetailedStepView(number: String, text: String) -> UIView {
        let stepView = UIView()
        stepView.backgroundColor = .systemGray6.withAlphaComponent(0.3)
        stepView.layer.cornerRadius = 12
        
        // 步骤数字圆圈
        let numberCircle = UIView()
        numberCircle.backgroundColor = .systemPink
        numberCircle.layer.cornerRadius = 18
        stepView.addSubview(numberCircle)
        
        let numberLabel = UILabel()
        numberLabel.text = number
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberCircle.addSubview(numberLabel)
        
        // 步骤文本
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        stepView.addSubview(textLabel)
        
        numberCircle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(36)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(numberCircle.snp.right).offset(16)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        return stepView
    }
    
    private func createEditTutorialSection() -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "如何更改主屏幕上的小组件"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        container.addSubview(titleLabel)
        
        // 创建小的预览小组件
        let smallWidgetPreview = createSmallWidgetPreview()
        container.addSubview(smallWidgetPreview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        smallWidgetPreview.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
            make.height.equalTo(160)
            make.bottom.equalToSuperview()
        }
        
        return container
    }
    
    private func createSmallWidgetPreview() -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.1
        
        // 创建黑色背景的小组件
        let widgetView = UIView()
        widgetView.backgroundColor = .black
        widgetView.layer.cornerRadius = 12
        container.addSubview(widgetView)
        
        // 时间显示
        let timeLabel = UILabel()
        timeLabel.text = "1:28 pm"
        timeLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        widgetView.addSubview(timeLabel)
        
        // 底部进度条
        let progressBar = UIView()
        progressBar.backgroundColor = .white
        progressBar.layer.cornerRadius = 1
        widgetView.addSubview(progressBar)
        
        widgetView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 140))
        }
        
        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        progressBar.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(2)
        }
        
        return container
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        tutorialContentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}