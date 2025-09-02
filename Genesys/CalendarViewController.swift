import UIKit

// MARK: - 数据模型
struct CalendarDay {
    let date: Date
    let solarDay: Int
    let lunarDay: String
    let lunarMonth: String
    let festival: String?
    let solarTerm: String?
    let isToday: Bool
    let isCurrentMonth: Bool
    let isSelected: Bool
}

struct DayDetail {
    let lunarDate: String
    let zodiac: String
    let ganZhi: String
    let suitable: [String]
    let avoid: [String]
    let festival: String?
    let solarTerm: String?
    let motivation: String
}

class CalendarViewController: UIViewController {
    
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
    private var calendarGridView: UIView!
    private var dayButtons: [UIButton] = []
    
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
    private var calendarDays: [CalendarDay] = []
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateCalendar()
    }
    
    private func setupNavigationBar() {
        title = "日历"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupHeaderView()
        setupWeekHeaderView()
        setupCalendarGridView()
        setupDetailCardView()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeaderView() {
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .secondarySystemBackground
        headerView.layer.cornerRadius = 12
        
        yearMonthLabel = UILabel()
        yearMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        yearMonthLabel.font = .boldSystemFont(ofSize: 20)
        yearMonthLabel.textColor = .label
        yearMonthLabel.textAlignment = .center
        
        prevButton = UIButton(type: .system)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = .label
        prevButton.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        
        nextButton = UIButton(type: .system)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = .label
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        
        todayButton = UIButton(type: .system)
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        todayButton.setTitle("今", for: .normal)
        todayButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        todayButton.backgroundColor = .systemBlue
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.layer.cornerRadius = 15
        todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
        
        contentView.addSubview(headerView)
        headerView.addSubview(yearMonthLabel)
        headerView.addSubview(prevButton)
        headerView.addSubview(nextButton)
        headerView.addSubview(todayButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            yearMonthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            yearMonthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            prevButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            prevButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            prevButton.widthAnchor.constraint(equalToConstant: 30),
            prevButton.heightAnchor.constraint(equalToConstant: 30),
            
            nextButton.trailingAnchor.constraint(equalTo: todayButton.leadingAnchor, constant: -12),
            nextButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
            
            todayButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            todayButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            todayButton.widthAnchor.constraint(equalToConstant: 30),
            todayButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupWeekHeaderView() {
        weekHeaderView = UIView()
        weekHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let colors: [UIColor] = [.systemRed, .label, .label, .label, .label, .label, .systemRed]
        
        for (index, weekday) in weekdays.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = weekday
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = colors[index]
            label.textAlignment = .center
            
            weekHeaderView.addSubview(label)
            weekLabels.append(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: weekHeaderView.topAnchor),
                label.bottomAnchor.constraint(equalTo: weekHeaderView.bottomAnchor),
                label.widthAnchor.constraint(equalTo: weekHeaderView.widthAnchor, multiplier: 1.0/7.0),
                label.leadingAnchor.constraint(equalTo: weekHeaderView.leadingAnchor, constant: CGFloat(index) * UIScreen.main.bounds.width / 7.0)
            ])
        }
        
        contentView.addSubview(weekHeaderView)
        
        NSLayoutConstraint.activate([
            weekHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            weekHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            weekHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            weekHeaderView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupCalendarGridView() {
        calendarGridView = UIView()
        calendarGridView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(calendarGridView)
        
        NSLayoutConstraint.activate([
            calendarGridView.topAnchor.constraint(equalTo: weekHeaderView.bottomAnchor, constant: 8),
            calendarGridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendarGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendarGridView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupDetailCardView() {
        detailCardView = UIView()
        detailCardView.translatesAutoresizingMaskIntoConstraints = false
        detailCardView.backgroundColor = .secondarySystemBackground
        detailCardView.layer.cornerRadius = 16
        detailCardView.layer.shadowColor = UIColor.black.cgColor
        detailCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        detailCardView.layer.shadowRadius = 8
        detailCardView.layer.shadowOpacity = 0.1
        
        // 农历信息
        lunarInfoLabel = UILabel()
        lunarInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        lunarInfoLabel.font = .boldSystemFont(ofSize: 18)
        lunarInfoLabel.textColor = .label
        lunarInfoLabel.numberOfLines = 0
        
        // 宜事项
        let suitableIconLabel = UILabel()
        suitableIconLabel.translatesAutoresizingMaskIntoConstraints = false
        suitableIconLabel.text = "宜"
        suitableIconLabel.font = .boldSystemFont(ofSize: 14)
        suitableIconLabel.textColor = .white
        suitableIconLabel.backgroundColor = .systemGreen
        suitableIconLabel.textAlignment = .center
        suitableIconLabel.layer.cornerRadius = 10
        suitableIconLabel.clipsToBounds = true
        
        suitableLabel = UILabel()
        suitableLabel.translatesAutoresizingMaskIntoConstraints = false
        suitableLabel.font = .systemFont(ofSize: 14)
        suitableLabel.textColor = .secondaryLabel
        suitableLabel.numberOfLines = 0
        
        // 忌事项
        let avoidIconLabel = UILabel()
        avoidIconLabel.translatesAutoresizingMaskIntoConstraints = false
        avoidIconLabel.text = "忌"
        avoidIconLabel.font = .boldSystemFont(ofSize: 14)
        avoidIconLabel.textColor = .white
        avoidIconLabel.backgroundColor = .systemRed
        avoidIconLabel.textAlignment = .center
        avoidIconLabel.layer.cornerRadius = 10
        avoidIconLabel.clipsToBounds = true
        
        avoidLabel = UILabel()
        avoidLabel.translatesAutoresizingMaskIntoConstraints = false
        avoidLabel.font = .systemFont(ofSize: 14)
        avoidLabel.textColor = .secondaryLabel
        avoidLabel.numberOfLines = 0
        
        // 添加备注按钮
        addNoteButton = UIButton(type: .system)
        addNoteButton.translatesAutoresizingMaskIntoConstraints = false
        addNoteButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addNoteButton.setTitle("  添加备注", for: .normal)
        addNoteButton.titleLabel?.font = .systemFont(ofSize: 16)
        addNoteButton.tintColor = .systemBlue
        addNoteButton.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
        
        // 励志文案
        motivationLabel = UILabel()
        motivationLabel.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            detailCardView.topAnchor.constraint(equalTo: calendarGridView.bottomAnchor, constant: 20),
            detailCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            lunarInfoLabel.topAnchor.constraint(equalTo: detailCardView.topAnchor, constant: 20),
            lunarInfoLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            lunarInfoLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            
            suitableIconLabel.topAnchor.constraint(equalTo: lunarInfoLabel.bottomAnchor, constant: 16),
            suitableIconLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            suitableIconLabel.widthAnchor.constraint(equalToConstant: 20),
            suitableIconLabel.heightAnchor.constraint(equalToConstant: 20),
            
            suitableLabel.centerYAnchor.constraint(equalTo: suitableIconLabel.centerYAnchor),
            suitableLabel.leadingAnchor.constraint(equalTo: suitableIconLabel.trailingAnchor, constant: 8),
            suitableLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            
            avoidIconLabel.topAnchor.constraint(equalTo: suitableLabel.bottomAnchor, constant: 12),
            avoidIconLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            avoidIconLabel.widthAnchor.constraint(equalToConstant: 20),
            avoidIconLabel.heightAnchor.constraint(equalToConstant: 20),
            
            avoidLabel.centerYAnchor.constraint(equalTo: avoidIconLabel.centerYAnchor),
            avoidLabel.leadingAnchor.constraint(equalTo: avoidIconLabel.trailingAnchor, constant: 8),
            avoidLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            
            addNoteButton.topAnchor.constraint(equalTo: avoidLabel.bottomAnchor, constant: 20),
            addNoteButton.centerXAnchor.constraint(equalTo: detailCardView.centerXAnchor),
            
            motivationLabel.topAnchor.constraint(equalTo: addNoteButton.bottomAnchor, constant: 20),
            motivationLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            motivationLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            motivationLabel.bottomAnchor.constraint(equalTo: detailCardView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 更新日历
    private func updateCalendar() {
        // 更新年月标题
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MM月"
        yearMonthLabel.text = formatter.string(from: currentDate)
        
        // 生成日历数据
        generateCalendarDays()
        
        // 更新日历网格
        updateCalendarGrid()
        
        // 更新详情卡片
        updateDetailCard()
    }
    
    private func generateCalendarDays() {
        calendarDays.removeAll()
        
        let calendar = Calendar.current
        let today = Date()
        
        // 获取当月第一天
        let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentDate)!.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 计算需要显示的天数 (6周 = 42天)
        let totalDays = 42
        
        // 计算起始日期
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: firstDayOfMonth)!
        
        for i in 0..<totalDays {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            let day = calendar.component(.day, from: date)
            
            let isCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
            let isToday = calendar.isDateInToday(date)
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            
            // 生成农历和节气信息
            let lunarInfo = generateLunarInfo(for: date)
            
            let calendarDay = CalendarDay(
                date: date,
                solarDay: day,
                lunarDay: lunarInfo.lunarDay,
                lunarMonth: lunarInfo.lunarMonth,
                festival: lunarInfo.festival,
                solarTerm: lunarInfo.solarTerm,
                isToday: isToday,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected
            )
            
            calendarDays.append(calendarDay)
        }
    }
    
    private func generateLunarInfo(for date: Date) -> (lunarDay: String, lunarMonth: String, festival: String?, solarTerm: String?) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        // 简化的农历计算（实际应用中需要使用专业农历库）
        let lunarDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        
        let lunarDay = lunarDays[(day - 1) % 30]
        let lunarMonth = "\(month)月"
        
        // 节日判断
        var festival: String? = nil
        var solarTerm: String? = nil
        
        if month == 11 {
            if day == 7 { solarTerm = "立冬" }
            else if day == 22 { solarTerm = "小雪" }
            else if day == 27 { festival = "感恩节" }
        }
        
        if month == 1 && day == 1 { festival = "元旦" }
        if month == 12 && day == 25 { festival = "圣诞节" }
        
        return (lunarDay, lunarMonth, festival, solarTerm)
    }
    
    private func updateCalendarGrid() {
        // 清空之前的按钮
        dayButtons.forEach { $0.removeFromSuperview() }
        dayButtons.removeAll()
        
        let screenWidth = UIScreen.main.bounds.width
        let buttonWidth = screenWidth / 7
        let buttonHeight: CGFloat = 50
        
        for (index, calendarDay) in calendarDays.enumerated() {
            let row = index / 7
            let col = index % 7
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(
                x: CGFloat(col) * buttonWidth,
                y: CGFloat(row) * buttonHeight,
                width: buttonWidth,
                height: buttonHeight
            )
            
            // 主数字
            let solarDayText = "\(calendarDay.solarDay)"
            let lunarText = calendarDay.solarTerm ?? calendarDay.lunarDay
            
            let attributedString = NSMutableAttributedString()
            
            // 阳历日期
            let solarAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: calendarDay.isCurrentMonth ? UIColor.label : UIColor.tertiaryLabel
            ]
            attributedString.append(NSAttributedString(string: solarDayText, attributes: solarAttributes))
            
            // 换行
            attributedString.append(NSAttributedString(string: "\n"))
            
            // 农历/节气
            let lunarAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: calendarDay.isCurrentMonth ? UIColor.secondaryLabel : UIColor.quaternaryLabel
            ]
            attributedString.append(NSAttributedString(string: lunarText, attributes: lunarAttributes))
            
            button.setAttributedTitle(attributedString, for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            
            // 今天标记
            if calendarDay.isToday {
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                button.layer.cornerRadius = 8
            }
            
            // 选中标记
            if calendarDay.isSelected {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.layer.cornerRadius = 8
            }
            
            // 节日标记
            if let festival = calendarDay.festival {
                button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                button.layer.cornerRadius = 8
            }
            
            button.tag = index
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            
            calendarGridView.addSubview(button)
            dayButtons.append(button)
        }
    }
    
    private func updateDetailCard() {
        let dayDetail = generateDayDetail(for: selectedDate)
        
        lunarInfoLabel.text = "\(dayDetail.lunarDate) \(dayDetail.zodiac) \(dayDetail.ganZhi)"
        suitableLabel.text = dayDetail.suitable.joined(separator: " ")
        avoidLabel.text = dayDetail.avoid.joined(separator: " ")
        motivationLabel.text = dayDetail.motivation
    }
    
    private func generateDayDetail(for date: Date) -> DayDetail {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        let zodiac = zodiacs[year(from: date) % 12] + "年"
        
        let motivations = [
            "每一天的努力，以后只有幸福的未来。",
            "坚持的昨天叫立足，坚持的今天叫进取，坚持的明天叫成功。",
            "努力是为了更好的选择，或者是为了自己能自由选择。",
            "不是每个人都能成为自己想要的样子，但每个人都可以努力成为自己想要的样子。",
            "生活总是让我们遍体鳞伤，但到后来，那些受伤的地方一定会变成我们最强壮的地方。"
        ]
        
        return DayDetail(
            lunarDate: "九月十二",
            zodiac: zodiac,
            ganZhi: "乙巳年",
            suitable: ["祭祀", "造车器", "出行", "修造", "上梁", "造屋", "安门", "安床", "造"],
            avoid: ["出货财", "开仓", "动土", "破土", "安葬", "行丧", "伐木", "开渠"],
            festival: nil,
            solarTerm: nil,
            motivation: motivations[day % motivations.count]
        )
    }
    
    private func year(from date: Date) -> Int {
        return Calendar.current.component(.year, from: date)
    }
    
    // MARK: - 事件处理
    @objc private func prevMonthTapped() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        updateCalendar()
    }
    
    @objc private func nextMonthTapped() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        updateCalendar()
    }
    
    @objc private func todayTapped() {
        currentDate = Date()
        selectedDate = Date()
        updateCalendar()
    }
    
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let calendarDay = calendarDays[sender.tag]
        selectedDate = calendarDay.date
        currentDate = calendarDay.date
        updateCalendar()
    }
    
    @objc private func addNoteTapped() {
        let alert = UIAlertController(
            title: "添加备注",
            message: "为今天添加一个备注提醒",
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