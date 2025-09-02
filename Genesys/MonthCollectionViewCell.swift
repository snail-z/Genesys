import UIKit

protocol MonthCollectionViewCellDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class MonthCollectionViewCell: UICollectionViewCell {
    
    // MARK: - 属性
    weak var delegate: MonthCollectionViewCellDelegate?
    private let dataManager = CalendarDataManager.shared
    
    private var currentDate = Date()
    private var selectedDate = Date()
    private var calendarDays: [CalendarDay] = []
    
    // MARK: - UI组件
    private var dayCells: [CalendarDayCell] = []
    private let weekdayLabels: [UILabel] = []
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        
        setupDayCells()
    }
    
    private func setupDayCells() {
        // 创建42个日期单元格（6行 x 7列）
        for _ in 0..<42 {
            let dayCell = CalendarDayCell()
            dayCell.delegate = self
            contentView.addSubview(dayCell)
            dayCells.append(dayCell)
        }
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        let containerBounds = contentView.bounds
        let cellWidth = containerBounds.width / 7
        let cellHeight = containerBounds.height / 6
        
        for (index, dayCell) in dayCells.enumerated() {
            let row = index / 7
            let col = index % 7
            
            let x = CGFloat(col) * cellWidth
            let y = CGFloat(row) * cellHeight
            
            dayCell.frame = CGRect(
                x: x,
                y: y, 
                width: cellWidth,
                height: cellHeight
            )
        }
    }
    
    // MARK: - 配置方法
    func configure(currentDate: Date, selectedDate: Date) {
        self.currentDate = currentDate
        self.selectedDate = selectedDate
        
        generateCalendarData()
        updateDayCells()
        
        setNeedsLayout()
    }
    
    private func generateCalendarData() {
        calendarDays = dataManager.generateCalendarDays(for: currentDate, selectedDate: selectedDate)
    }
    
    private func updateDayCells() {
        let cellCount = min(dayCells.count, calendarDays.count)
        
        for index in 0..<dayCells.count {
            if index < cellCount {
                let dayCell = dayCells[index]
                let calendarDay = calendarDays[index]
                
                dayCell.configure(with: calendarDay)
                dayCell.isHidden = false
                dayCell.alpha = 1.0
            } else {
                dayCells[index].isHidden = true
                dayCells[index].alpha = 0.0
            }
        }
    }
    
    // MARK: - 重用准备
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置所有单元格状态
        dayCells.forEach { dayCell in
            dayCell.prepareForReuse()
            dayCell.isHidden = false
            dayCell.alpha = 1.0
        }
        
        calendarDays.removeAll()
    }
    
    // MARK: - 辅助方法
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        generateCalendarData()
        updateDayCells()
    }
}

// MARK: - CalendarDayCellDelegate
extension MonthCollectionViewCell: CalendarDayCellDelegate {
    func didSelectDay(_ calendarDay: CalendarDay) {
        delegate?.didSelectDate(calendarDay.date)
    }
}