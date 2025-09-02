import UIKit
import SnapKit

class CalendarViewController: UIViewController {
    
    // MARK: - 数据管理器
    private let dataManager = CalendarDataManager.shared
    
    // MARK: - UI Components
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    // 头部
    private var headerView: UIView!
    private var yearMonthLabel: UILabel!
    private var prevButton: UIButton!
    private var nextButton: UIButton!
    private var todayButton: UIButton!
    
    // 星期头部
    private var weekHeaderView: UIView!
    private var weekLabels: [UILabel] = []
    
    // 日历网格
    private var calendarGridView: CalendarGridView!
    
    // 底部详情卡片
    private var detailCardView: UIView!
    private var lunarInfoLabel: UILabel!
    private var suitableLabel: UILabel!
    private var avoidLabel: UILabel!
    private var motivationLabel: UILabel!
    private var addNoteButton: UIButton!
    
    // MARK: - 数据
    private var currentDate = Date()
    private var selectedDate = Date()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateDetailCard()
    }
    
    private func setupNavigationBar() {
        title = "日历"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupGradientBackground() {
        // 创建清新淡雅绿渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        // 清新淡雅绿色调
        let lightGreen = UIColor(red: 0.95, green: 0.98, blue: 0.95, alpha: 1.0).cgColor    // 极淡的薄荷绿
        let softGreen = UIColor(red: 0.90, green: 0.95, blue: 0.92, alpha: 1.0).cgColor     // 柔和浅绿
        let paleGreen = UIColor(red: 0.93, green: 0.97, blue: 0.94, alpha: 1.0).cgColor     // 淡雅绿
        
        gradientLayer.colors = [lightGreen, softGreen, paleGreen]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // 视图大小改变时更新渐变
        gradientLayer.name = "backgroundGradient"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变层大小
        if let gradientLayer = view.layer.sublayers?.first(where: { $0.name == "backgroundGradient" }) as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    private func setupUI() {
        setupGradientBackground()
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        contentView = UIView()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupHeaderView()
        setupWeekHeaderView()
        setupCalendarGridView()
        setupDetailCardView()
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 0.93, alpha: 0.8)
        headerView.layer.cornerRadius = 12
        
        yearMonthLabel = UILabel()
        yearMonthLabel.font = .boldSystemFont(ofSize: 20)
        yearMonthLabel.textColor = .label
        yearMonthLabel.textAlignment = .center
        
        prevButton = UIButton(type: .system)
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = .label
        prevButton.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        
        nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = .label
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        
        todayButton = UIButton(type: .system)
        todayButton.setTitle("今", for: .normal)
        todayButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        todayButton.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.layer.cornerRadius = 15
        todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
        
        contentView.addSubview(headerView)
        headerView.addSubview(yearMonthLabel)
        headerView.addSubview(prevButton)
        headerView.addSubview(nextButton)
        headerView.addSubview(todayButton)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(60)
        }
        
        yearMonthLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        prevButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalTo(todayButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        todayButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
    }
    
    private func setupWeekHeaderView() {
        weekHeaderView = UIView()
        
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let colors: [UIColor] = [.systemRed, .label, .label, .label, .label, .label, .systemRed]
        
        for (index, weekday) in weekdays.enumerated() {
            let label = UILabel()
            label.text = weekday
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = colors[index]
            label.textAlignment = .center
            
            weekHeaderView.addSubview(label)
            weekLabels.append(label)
            
            label.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(7)
                
                if index == 0 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(weekLabels[index-1].snp.trailing)
                }
            }
        }
        
        contentView.addSubview(weekHeaderView)
        
        weekHeaderView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }
    
    private func setupCalendarGridView() {
        calendarGridView = CalendarGridView()
        calendarGridView.delegate = self
        
        contentView.addSubview(calendarGridView)
        
        calendarGridView.snp.makeConstraints { make in
            make.top.equalTo(weekHeaderView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            make.height.equalTo(300)
        }
    }
    
    private func setupDetailCardView() {
        detailCardView = UIView()
        detailCardView.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 0.93, alpha: 0.85)
        detailCardView.layer.cornerRadius = 16
        detailCardView.layer.shadowColor = UIColor.black.cgColor
        detailCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        detailCardView.layer.shadowRadius = 8
        detailCardView.layer.shadowOpacity = 0.1
        
        // 农历信息
        lunarInfoLabel = UILabel()
        lunarInfoLabel.font = .boldSystemFont(ofSize: 18)
        lunarInfoLabel.textColor = .label
        lunarInfoLabel.numberOfLines = 0
        
        // 宜事项
        let suitableIconLabel = UILabel()
        suitableIconLabel.text = "宜"
        suitableIconLabel.font = .boldSystemFont(ofSize: 14)
        suitableIconLabel.textColor = .white
        suitableIconLabel.backgroundColor = .systemGreen
        suitableIconLabel.textAlignment = .center
        suitableIconLabel.layer.cornerRadius = 10
        suitableIconLabel.clipsToBounds = true
        
        suitableLabel = UILabel()
        suitableLabel.font = .systemFont(ofSize: 14)
        suitableLabel.textColor = .secondaryLabel
        suitableLabel.numberOfLines = 0
        
        // 忌事项
        let avoidIconLabel = UILabel()
        avoidIconLabel.text = "忌"
        avoidIconLabel.font = .boldSystemFont(ofSize: 14)
        avoidIconLabel.textColor = .white
        avoidIconLabel.backgroundColor = .systemRed
        avoidIconLabel.textAlignment = .center
        avoidIconLabel.layer.cornerRadius = 10
        avoidIconLabel.clipsToBounds = true
        
        avoidLabel = UILabel()
        avoidLabel.font = .systemFont(ofSize: 14)
        avoidLabel.textColor = .secondaryLabel
        avoidLabel.numberOfLines = 0
        
        // 添加备注按钮
        addNoteButton = UIButton(type: .system)
        addNoteButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addNoteButton.setTitle("  添加备注", for: .normal)
        addNoteButton.titleLabel?.font = .systemFont(ofSize: 16)
        addNoteButton.tintColor = .systemBlue
        addNoteButton.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
        
        // 励志文案
        motivationLabel = UILabel()
        motivationLabel.font = .systemFont(ofSize: 14)
        motivationLabel.textColor = .tertiaryLabel
        motivationLabel.textAlignment = .center
        motivationLabel.numberOfLines = 0
        
        contentView.addSubview(detailCardView)
        detailCardView.addSubview(lunarInfoLabel)
        detailCardView.addSubview(suitableIconLabel)
        detailCardView.addSubview(suitableLabel)
        detailCardView.addSubview(avoidIconLabel)
        detailCardView.addSubview(avoidLabel)
        detailCardView.addSubview(addNoteButton)
        detailCardView.addSubview(motivationLabel)
        
        detailCardView.snp.makeConstraints { make in
            make.top.equalTo(calendarGridView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        lunarInfoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        suitableIconLabel.snp.makeConstraints { make in
            make.top.equalTo(lunarInfoLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(20)
        }
        
        suitableLabel.snp.makeConstraints { make in
            make.centerY.equalTo(suitableIconLabel)
            make.leading.equalTo(suitableIconLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        avoidIconLabel.snp.makeConstraints { make in
            make.top.equalTo(suitableLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(20)
        }
        
        avoidLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avoidIconLabel)
            make.leading.equalTo(avoidIconLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        addNoteButton.snp.makeConstraints { make in
            make.top.equalTo(avoidLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        motivationLabel.snp.makeConstraints { make in
            make.top.equalTo(addNoteButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    // MARK: - 更新日历
    private func updateYearMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MM月"
        yearMonthLabel.text = formatter.string(from: currentDate)
    }
    
    private func updateDetailCard() {
        let dayDetail = dataManager.generateDayDetail(for: selectedDate)
        
        lunarInfoLabel.text = "\(dayDetail.lunarDate) \(dayDetail.zodiac) \(dayDetail.ganZhi)"
        suitableLabel.text = dayDetail.suitable.joined(separator: " ")
        avoidLabel.text = dayDetail.avoid.joined(separator: " ")
        motivationLabel.text = dayDetail.motivation
    }
    
    // MARK: - 事件处理
    @objc private func prevMonthTapped() {
        calendarGridView.navigateToMonth(-1)
    }
    
    @objc private func nextMonthTapped() {
        calendarGridView.navigateToMonth(1)
    }
    
    @objc private func todayTapped() {
        selectedDate = Date()
        currentDate = Date()
        calendarGridView.scrollToToday()
        updateYearMonthLabel()
        updateDetailCard()
    }
    
    @objc private func addNoteTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateString = formatter.string(from: selectedDate)
        
        let alert = UIAlertController(
            title: "添加备注",
            message: "为\(dateString)添加一个备注提醒",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "输入备注内容..."
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                // 这里可以保存备注到本地存储
                let savedAlert = UIAlertController(title: "保存成功", message: "备注已保存", preferredStyle: .alert)
                savedAlert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(savedAlert, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - CalendarGridViewDelegate
extension CalendarViewController: CalendarGridViewDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        updateDetailCard()
    }
    
    func didChangeMonth(_ date: Date) {
        currentDate = date
        updateYearMonthLabel()
    }
}
