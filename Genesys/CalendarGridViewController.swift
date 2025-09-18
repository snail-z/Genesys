import UIKit
import SnapKit

class CalendarGridViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    
    private let backgroundImageView = UIImageView()
    private let componentContainer = UIView()
    
    // 日历状态管理
    private var currentYear: Int = 2025
    private var currentMonth: Int = 2  // February
    private var monthLabel: UILabel!
    private var leftArrowButton: UIButton!
    private var rightArrowButton: UIButton!
    private var calendarGridView: UIView!
    
    private let minYear = 1997
    private let maxYear = 2099
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrentDate()
        setupUI()
        setupNavigationBar()
        createCalendarComponents()
    }
    
    private func setupCurrentDate() {
        let calendar = Calendar.current
        let now = Date()
        currentYear = calendar.component(.year, from: now)
        currentMonth = calendar.component(.month, from: now)
    }
    
    private func setupNavigationBar() {
        // 如果没有设置title，默认为"清晰小日历组件"
        if title == nil || title == "" {
            title = "清晰小日历组件"
        }
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 背景图片
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = createGradientBackgroundImage()
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(componentContainer)
        
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
        
        componentContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func createCalendarComponents() {
        // 根据标题决定显示哪种样式
        if title == "日历助手" {
            // 创建现代化日历助手界面
            let calendarWidget = createModernCalendarWidget()
            
            componentContainer.addSubview(calendarWidget)
            
            calendarWidget.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(350)
                make.height.equalTo(480)
                make.top.greaterThanOrEqualToSuperview().offset(20)
                make.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
        } else {
            // 创建高度还原截图的widget样式日历
            let widgetCalendar = createWidgetStyleCalendar()
            
            componentContainer.addSubview(widgetCalendar)
            
            widgetCalendar.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(320)
                make.height.equalTo(320)
                make.top.greaterThanOrEqualToSuperview().offset(20)
                make.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
        }
    }
    
    private func createModernCalendarWidget() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        containerView.layer.cornerRadius = 24
        containerView.clipsToBounds = true
        
        // 添加轻微的阴影效果
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOpacity = 0.1
        
        // 日历头部导航
        let headerView = createCalendarHeader()
        
        // 星期标题
        let weekdayHeader = createWeekdayHeader()
        
        
        
        // 日历网格容器
        let calendarGridView = createCalendarGrid()
        
        // 事件列表
        let eventsList = createEventsList()
        
        containerView.addSubview(headerView)
        containerView.addSubview(weekdayHeader)
        containerView.addSubview(calendarGridView)
        containerView.addSubview(eventsList)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }
        
        weekdayHeader.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(30)
        }
        
        calendarGridView.snp.makeConstraints { make in
            make.top.equalTo(weekdayHeader.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(180) // 4行 x 45高度
        }
        
        eventsList.snp.makeConstraints { make in
            make.top.equalTo(calendarGridView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        return containerView
    }
    
    private func createCalendarHeader() -> UIView {
        let headerView = UIView()
        
        // 左箭头
        leftArrowButton = UIButton()
        leftArrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        leftArrowButton.tintColor = .black
        leftArrowButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        
        // 右箭头
        rightArrowButton = UIButton()
        rightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightArrowButton.tintColor = .black
        rightArrowButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        
        // 月份标题
        monthLabel = UILabel()
        monthLabel.font = .boldSystemFont(ofSize: 18)
        monthLabel.textColor = .black
        monthLabel.textAlignment = .center
        updateMonthLabel()
        
        headerView.addSubview(leftArrowButton)
        headerView.addSubview(rightArrowButton)
        headerView.addSubview(monthLabel)
        
        leftArrowButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        rightArrowButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        monthLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return headerView
    }
    
    private func createWeekdayHeader() -> UIView {
        let headerView = UIView()
        let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        
        for (index, weekday) in weekdays.enumerated() {
            let label = UILabel()
            label.text = weekday
            label.font = .systemFont(ofSize: 14)
            label.textColor = .gray
            label.textAlignment = .center
            
            headerView.addSubview(label)
            
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalTo(40)
                make.leading.equalToSuperview().offset(index * 42)
            }
        }
        
        return headerView
    }
    
    private func createCalendarGrid() -> UIView {
        let gridView = UIView()
        let dateData = generateCompactDateData()
        
        for row in 0..<4 { // 只显示4行
            for col in 0..<7 {
                let dayIndex = row * 7 + col
                if dayIndex < dateData.count {
                    let dayInfo = dateData[dayIndex]
                    let dayView = createModernDayView(dayInfo: dayInfo)
                    gridView.addSubview(dayView)
                    
                    dayView.snp.makeConstraints { make in
                        make.width.height.equalTo(40)
                        make.leading.equalToSuperview().offset(col * 42)
                        make.top.equalToSuperview().offset(row * 45)
                    }
                }
            }
        }
        
        return gridView
    }
    
    private func createEventsList() -> UIView {
        let eventsContainer = UIView()
        
        // Dune: Part Two 事件
        let duneEvent = createEventView(
            imageName: nil,
            title: "Dune: Part Two",
            times: ["12:00", "15:00", "18:00", "21:00"],
            color: UIColor.systemOrange,
            isDuneMovie: true
        )
        
        // Moonlight 事件
        let moonlightEvent = createEventView(
            imageName: nil,
            title: "Moonlight",
            times: ["12:00", "15:00", "18:00", "21:00"],
            color: UIColor.systemTeal,
            isMoonlightMovie: true
        )
        
        eventsContainer.addSubview(duneEvent)
        eventsContainer.addSubview(moonlightEvent)
        
        duneEvent.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        moonlightEvent.snp.makeConstraints { make in
            make.top.equalTo(duneEvent.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        return eventsContainer
    }
    
    private func createEventView(imageName: String?, title: String, times: [String], color: UIColor, isDuneMovie: Bool = false, isMoonlightMovie: Bool = false) -> UIView {
        let eventView = UIView()
        
        // 事件图标
        let iconView = UIView()
        iconView.layer.cornerRadius = 8
        iconView.clipsToBounds = true
        
        if isDuneMovie {
            // Dune电影的渐变背景（橙色到黑色）
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor.systemOrange.cgColor,
                UIColor.black.cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 8
            iconView.layer.insertSublayer(gradientLayer, at: 0)
            
            // 添加文字"DUNE"
            let duneLabel = UILabel()
            duneLabel.text = "D U N E"
            duneLabel.font = .boldSystemFont(ofSize: 10)
            duneLabel.textColor = .white
            duneLabel.textAlignment = .center
            iconView.addSubview(duneLabel)
            
            duneLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            // 设置gradientLayer的frame
            DispatchQueue.main.async {
                gradientLayer.frame = iconView.bounds
            }
        } else if isMoonlightMovie {
            // Moonlight电影的背景（蓝绿色）
            iconView.backgroundColor = UIColor.systemTeal
            
            // 添加人物头像样式的圆形
            let avatarView = UIView()
            avatarView.backgroundColor = UIColor.systemCyan
            avatarView.layer.cornerRadius = 12
            iconView.addSubview(avatarView)
            
            avatarView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(24)
            }
        } else {
            iconView.backgroundColor = color
        }
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        
        // 时间标签容器
        let timeStackView = UIStackView()
        timeStackView.axis = .horizontal
        timeStackView.spacing = 12
        timeStackView.alignment = .center
        
        for time in times {
            let timeLabel = UILabel()
            timeLabel.text = time
            timeLabel.font = .systemFont(ofSize: 14)
            timeLabel.textColor = .gray
            timeLabel.textAlignment = .center
            timeLabel.backgroundColor = UIColor.systemGray6
            timeLabel.layer.cornerRadius = 12
            timeLabel.clipsToBounds = true
            
            timeStackView.addArrangedSubview(timeLabel)
            
            timeLabel.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(24)
            }
        }
        
        eventView.addSubview(iconView)
        eventView.addSubview(titleLabel)
        eventView.addSubview(timeStackView)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(4)
        }
        
        timeStackView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        return eventView
    }
    
    // MARK: - 月份切换
    
    @objc private func previousMonthTapped() {
        currentMonth -= 1
        if currentMonth < 1 {
            currentMonth = 12
            currentYear -= 1
        }
        
        // 限制年份范围
        if currentYear < minYear {
            currentYear = minYear
            currentMonth = 1
        }
        
        updateCalendar()
    }
    
    @objc private func nextMonthTapped() {
        currentMonth += 1
        if currentMonth > 12 {
            currentMonth = 1
            currentYear += 1
        }
        
        // 限制年份范围
        if currentYear > maxYear {
            currentYear = maxYear
            currentMonth = 12
        }
        
        updateCalendar()
    }
    
    private func updateMonthLabel() {
        let monthNames = ["", "January", "February", "March", "April", "May", "June",
                         "July", "August", "September", "October", "November", "December"]
        monthLabel?.text = "\(monthNames[currentMonth]) \(currentYear)"
    }
    
    private func updateCalendar() {
        updateMonthLabel()
        updateCalendarGrid()
    }
    
    private func updateCalendarGrid() {
        // 只在日历助手页面进行动态更新
        guard title == "日历助手" else { return }
        
        // 找到现代化日历widget容器
        guard let calendarWidget = componentContainer.subviews.first else { return }
        
        // 找到现有的日历网格视图并移除
        for subview in calendarWidget.subviews {
            if subview != calendarWidget.subviews.first && // 不是header
               subview != calendarWidget.subviews[1] && // 不是weekday header  
               subview != calendarWidget.subviews.last { // 不是events list
                subview.removeFromSuperview()
                break
            }
        }
        
        // 创建新的日历网格
        let newCalendarGrid = createDynamicCalendarGrid()
        calendarWidget.addSubview(newCalendarGrid)
        
        // 重新设置约束
        newCalendarGrid.snp.makeConstraints { make in
            make.top.equalTo(calendarWidget.subviews[1].snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(180) // 4行 x 45高度
        }
    }
    
    // MARK: - 动态日历网格生成
    
    private func createDynamicCalendarGrid() -> UIView {
        let gridView = UIView()
        let dateData = generateCompactDateData() // 使用紧凑样式
        
        for row in 0..<4 { // 只显示4行
            for col in 0..<7 {
                let dayIndex = row * 7 + col
                if dayIndex < dateData.count {
                    let dayInfo = dateData[dayIndex]
                    let dayView = createModernDayView(dayInfo: dayInfo)
                    gridView.addSubview(dayView)
                    
                    dayView.snp.makeConstraints { make in
                        make.width.height.equalTo(40)
                        make.leading.equalToSuperview().offset(col * 42)
                        make.top.equalToSuperview().offset(row * 45)
                    }
                }
            }
        }
        
        return gridView
    }
    
    // MARK: - 日期计算工具方法
    
    private func generateDynamicDateData() -> [DayInfo] {
        var dateInfos: [DayInfo] = []
        
        let calendar = Calendar.current
        
        // 获取当前月第一天
        var dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return [] }
        
        // 获取当前月有多少天
        let daysInCurrentMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30
        
        // 获取当前月第一天是星期几（0=Sunday, 1=Monday, ... 6=Saturday）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // 获取上个月的信息
        let previousMonth = currentMonth == 1 ? 12 : currentMonth - 1
        let previousYear = currentMonth == 1 ? currentYear - 1 : currentYear
        var previousDateComponents = DateComponents(year: previousYear, month: previousMonth, day: 1)
        let firstDayOfPreviousMonth = calendar.date(from: previousDateComponents)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: firstDayOfPreviousMonth)?.count ?? 30
        
        // 添加上个月的补位日期
        for i in 0..<firstWeekday {
            let day = daysInPreviousMonth - firstWeekday + i + 1
            dateInfos.append(DayInfo(day: day, type: .previousMonth))
        }
        
        // 添加当前月的日期
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let isCurrentMonth = (todayComponents.year == currentYear && todayComponents.month == currentMonth)
        
        for day in 1...daysInCurrentMonth {
            var dayType: DayType = .currentMonth
            
            if isCurrentMonth && day == todayComponents.day {
                dayType = .today
            } else if day == 8 && currentMonth == 2 && currentYear == 2025 {
                // 特殊处理：February 2025的8号显示为选中状态
                dayType = .selected
            }
            
            dateInfos.append(DayInfo(day: day, type: dayType))
        }
        
        // 添加下个月的补位日期，填满42个位置（6行×7列）
        let totalCells = 42
        let remainingCells = totalCells - dateInfos.count
        
        for day in 1...remainingCells {
            dateInfos.append(DayInfo(day: day, type: .nextMonth))
        }
        
        return dateInfos
    }
    
    // 生成紧凑版日期数据（如新截图样式）
    private func generateCompactDateData() -> [DayInfo] {
        var dateInfos: [DayInfo] = []
        
        let calendar = Calendar.current
        
        // 获取当前月第一天
        var dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return [] }
        
        // 获取当前月第一天是星期几（0=Sunday, 1=Monday, ... 6=Saturday）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // 获取上个月的信息（只用于补位前几天）
        let previousMonth = currentMonth == 1 ? 12 : currentMonth - 1
        let previousYear = currentMonth == 1 ? currentYear - 1 : currentYear
        var previousDateComponents = DateComponents(year: previousYear, month: previousMonth, day: 1)
        let firstDayOfPreviousMonth = calendar.date(from: previousDateComponents)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: firstDayOfPreviousMonth)?.count ?? 30
        
        // 添加上个月的补位日期（只显示必要的几天）
        for i in 0..<firstWeekday {
            let day = daysInPreviousMonth - firstWeekday + i + 1
            dateInfos.append(DayInfo(day: day, type: .previousMonth))
        }
        
        // 添加当前月的日期（只添加能填满4周的天数）
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let isCurrentMonth = (todayComponents.year == currentYear && todayComponents.month == currentMonth)
        
        let maxDaysToShow = 28 - firstWeekday // 4周总共28天，减去上月补位天数
        
        for day in 1...min(maxDaysToShow, 31) {
            var dayType: DayType = .currentMonth
            
            if isCurrentMonth && day == todayComponents.day {
                dayType = .today
            } else if day == 8 && currentMonth == 2 && currentYear == 2025 {
                // 特殊处理：February 2025的8号显示为选中状态
                dayType = .selected
            }
            
            dateInfos.append(DayInfo(day: day, type: dayType))
            
            // 如果已经填满28个格子就停止
            if dateInfos.count >= 28 {
                break
            }
        }
        
        return dateInfos
    }
    
    private func createModernDayView(dayInfo: DayInfo) -> UIView {
        let dayView = UIView()
        dayView.layer.cornerRadius = 20
        
        let dayLabel = UILabel()
        dayLabel.text = "\(dayInfo.day)"
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.textAlignment = .center
        
        switch dayInfo.type {
        case .selected:
            // 紫色选中背景（如截图中的8号）
            dayView.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1.0)
            dayLabel.textColor = .white
        case .currentMonth:
            dayView.backgroundColor = .clear
            dayLabel.textColor = .black
        case .previousMonth:
            dayView.backgroundColor = .clear
            dayLabel.textColor = UIColor.lightGray
        case .nextMonth:
            dayView.backgroundColor = .clear
            dayLabel.textColor = UIColor.lightGray
        case .today:
            dayView.backgroundColor = .clear
            dayLabel.textColor = .black
            dayLabel.font = .boldSystemFont(ofSize: 16)
        default:
            dayView.backgroundColor = .clear
            dayLabel.textColor = .black
        }
        
        dayView.addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return dayView
    }
    
    private func generateFebruaryDateData() -> [DayInfo] {
        // 按照截图中February 2025的布局
        return [
            // 第一周 (Su, Mo, Tu, We, Th, Fr, Sa)
            DayInfo(day: 26, type: .previousMonth), // 上月最后几天
            DayInfo(day: 27, type: .previousMonth),
            DayInfo(day: 28, type: .previousMonth),
            DayInfo(day: 29, type: .previousMonth),
            DayInfo(day: 30, type: .previousMonth),
            DayInfo(day: 31, type: .previousMonth),
            DayInfo(day: 1, type: .currentMonth),
            
            // 第二周
            DayInfo(day: 2, type: .currentMonth),
            DayInfo(day: 3, type: .currentMonth),
            DayInfo(day: 4, type: .currentMonth),
            DayInfo(day: 5, type: .currentMonth),
            DayInfo(day: 6, type: .currentMonth),
            DayInfo(day: 7, type: .currentMonth),
            DayInfo(day: 8, type: .selected), // 紫色选中
            
            // 第三周
            DayInfo(day: 9, type: .currentMonth),
            DayInfo(day: 10, type: .currentMonth),
            DayInfo(day: 11, type: .currentMonth),
            DayInfo(day: 12, type: .currentMonth),
            DayInfo(day: 13, type: .currentMonth),
            DayInfo(day: 14, type: .currentMonth),
            DayInfo(day: 15, type: .currentMonth),
            
            // 第四周 (只显示部分)
            DayInfo(day: 16, type: .currentMonth),
            DayInfo(day: 17, type: .currentMonth),
            DayInfo(day: 18, type: .currentMonth),
            DayInfo(day: 19, type: .currentMonth),
            DayInfo(day: 20, type: .currentMonth),
            DayInfo(day: 21, type: .currentMonth),
            DayInfo(day: 22, type: .currentMonth)
        ]
    }
    
    
    private func createGradientBackgroundImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [
                UIColor.systemBlue.cgColor,
                UIColor.systemIndigo.cgColor,
                UIColor.systemPurple.cgColor,
                UIColor.systemPink.cgColor
            ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 0.33, 0.66, 1])!
            
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
    
    // MARK: - Widget样式日历（高度还原截图）
    
    private func createWidgetStyleCalendar() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = 24
        containerView.clipsToBounds = true
        
        // Daily Activity 标题
        let titleLabel = UILabel()
        titleLabel.text = "Daily\nActivity"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        
        // 右上角区域
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.spacing = 8
        headerStackView.alignment = .center
        
        let calendarIcon = UIImageView()
        calendarIcon.image = UIImage(systemName: "calendar")
        calendarIcon.tintColor = .white
        calendarIcon.contentMode = .scaleAspectFit
        
        let monthLabel = UILabel()
        monthLabel.text = "August"
        monthLabel.font = .systemFont(ofSize: 16)
        monthLabel.textColor = .white
        
        let yearLabel = UILabel()
        yearLabel.text = "2024"
        yearLabel.font = .systemFont(ofSize: 16)
        yearLabel.textColor = .white
        
        headerStackView.addArrangedSubview(calendarIcon)
        headerStackView.addArrangedSubview(monthLabel)
        headerStackView.addArrangedSubview(yearLabel)
        
        // 当前月份标签
        let currentMonthLabel = UILabel()
        currentMonthLabel.text = "Nov"
        currentMonthLabel.font = .boldSystemFont(ofSize: 14)
        currentMonthLabel.textColor = .black
        currentMonthLabel.backgroundColor = .white
        currentMonthLabel.textAlignment = .center
        currentMonthLabel.layer.cornerRadius = 12
        currentMonthLabel.clipsToBounds = true
        
        // 日历网格容器
        let calendarGridView = UIView()
        
        // 创建7x6的日期网格
        let dateData = generateWidgetDateData()
        
        for row in 0..<6 {
            for col in 0..<7 {
                let dayIndex = row * 7 + col
                if dayIndex < dateData.count {
                    let dayInfo = dateData[dayIndex]
                    let dayView = createWidgetDayView(dayInfo: dayInfo)
                    calendarGridView.addSubview(dayView)
                    
                    dayView.snp.makeConstraints { make in
                        make.width.height.equalTo(32)
                        make.leading.equalToSuperview().offset(col * 40)
                        make.top.equalToSuperview().offset(row * 40)
                    }
                }
            }
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(headerStackView)
        containerView.addSubview(currentMonthLabel)
        containerView.addSubview(calendarGridView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        calendarIcon.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        
        currentMonthLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(40)
            make.height.equalTo(24)
        }
        
        calendarGridView.snp.makeConstraints { make in
            make.top.equalTo(currentMonthLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(240)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        return containerView
    }
    
    private func createWidgetDayView(dayInfo: DayInfo) -> UIView {
        let dayView = UIView()
        dayView.layer.cornerRadius = 16
        
        let dayLabel = UILabel()
        dayLabel.text = "\(dayInfo.day)"
        dayLabel.font = .boldSystemFont(ofSize: 16)
        dayLabel.textAlignment = .center
        
        switch dayInfo.type {
        case .today:
            dayView.backgroundColor = .white
            dayLabel.textColor = .black
        case .activity:
            dayView.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 0.3, alpha: 1.0) // 亮绿色
            dayLabel.textColor = .black
        case .special:
            dayView.backgroundColor = UIColor.systemRed
            dayLabel.textColor = .white
        case .selected:
            dayView.backgroundColor = .clear
            dayView.layer.borderWidth = 2
            dayView.layer.borderColor = UIColor(red: 0.7, green: 0.9, blue: 0.3, alpha: 1.0).cgColor
            dayLabel.textColor = .white
        case .currentMonth:
            dayView.backgroundColor = .clear
            dayLabel.textColor = .white
        case .previousMonth:
            dayView.backgroundColor = .clear
            dayLabel.textColor = .gray
        default:
            dayView.backgroundColor = .clear
            dayLabel.textColor = .gray
        }
        
        dayView.addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return dayView
    }
    
    private func generateWidgetDateData() -> [DayInfo] {
        // 模拟截图中的数据
        return [
            // 第一行 (上月末尾)
            DayInfo(day: 27, type: .previousMonth),
            DayInfo(day: 28, type: .previousMonth),
            DayInfo(day: 29, type: .previousMonth),
            DayInfo(day: 30, type: .previousMonth),
            DayInfo(day: 1, type: .today),
            DayInfo(day: 2, type: .activity),
            DayInfo(day: 3, type: .selected),
            
            // 第二行
            DayInfo(day: 4, type: .selected),
            DayInfo(day: 5, type: .activity),
            DayInfo(day: 6, type: .activity),
            DayInfo(day: 7, type: .activity),
            DayInfo(day: 8, type: .special),
            DayInfo(day: 9, type: .currentMonth),
            DayInfo(day: 10, type: .currentMonth),
            
            // 第三行
            DayInfo(day: 11, type: .currentMonth),
            DayInfo(day: 12, type: .currentMonth),
            DayInfo(day: 13, type: .currentMonth),
            DayInfo(day: 14, type: .currentMonth),
            DayInfo(day: 15, type: .currentMonth),
            DayInfo(day: 16, type: .currentMonth),
            DayInfo(day: 17, type: .currentMonth),
            
            // 第四行
            DayInfo(day: 18, type: .currentMonth),
            DayInfo(day: 19, type: .currentMonth),
            DayInfo(day: 20, type: .currentMonth),
            DayInfo(day: 21, type: .currentMonth),
            DayInfo(day: 22, type: .currentMonth),
            DayInfo(day: 23, type: .currentMonth),
            DayInfo(day: 24, type: .currentMonth),
            
            // 第五行
            DayInfo(day: 25, type: .currentMonth),
            DayInfo(day: 26, type: .currentMonth),
            DayInfo(day: 27, type: .currentMonth),
            DayInfo(day: 28, type: .currentMonth),
            DayInfo(day: 29, type: .currentMonth),
            DayInfo(day: 30, type: .currentMonth),
            DayInfo(day: 31, type: .currentMonth)
        ]
    }
}

enum CalendarStyle {
    case widget  // 桌面Widget样式（高度还原截图）
}

struct DayInfo {
    let day: Int
    let type: DayType
}

enum DayType {
    case today          // 今天 - 白色背景
    case activity       // 有活动 - 亮绿色背景
    case special        // 特殊事件 - 红色背景
    case selected       // 选中状态 - 绿色边框
    case currentMonth   // 当月普通日期 - 白色文字
    case previousMonth  // 上月日期 - 灰色文字
    case nextMonth      // 下月日期 - 灰色文字
}
