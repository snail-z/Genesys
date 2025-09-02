import UIKit
import SnapKit

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
    private var monthCardView: UIView!
    private var dayCells: [CalendarDayCell] = []
    
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupMonthCardView()
        setupDayCells()
    }
    
    private func setupMonthCardView() {
        monthCardView = UIView()
        monthCardView.backgroundColor = .clear  // 默认透明，后期可扩展
        
        // 为将来的卡片效果预留样式设置
        // monthCardView.layer.cornerRadius = 8
        // monthCardView.layer.shadowOpacity = 0.03
        // monthCardView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        contentView.addSubview(monthCardView)
        
        monthCardView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
//        monthCardView.backgroundColor = .red
    }
    
    private func setupDayCells() {
        // 创建42个日期单元格（6行 x 7列）
        for _ in 0..<42 {
            let dayCell = CalendarDayCell()
            dayCell.delegate = self
            monthCardView.addSubview(dayCell)  // 🔑 添加到monthCardView而不是contentView
            dayCells.append(dayCell)
        }
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 先让父类完成约束计算
        monthCardView.layoutIfNeeded()
        updateLayout()
    }
    
    private func updateLayout() {
        let containerBounds = monthCardView.bounds  // 使用monthCardView的bounds来计算
        
        // 如果bounds还是0，使用cell的bounds减去边距
        let actualBounds = containerBounds.isEmpty ? 
            CGRect(x: 0, y: 0, width: bounds.width - 40, height: bounds.height) : 
            containerBounds
            
        let cellWidth = actualBounds.width / 7
        let cellHeight = actualBounds.height / 6
        
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
    
    // MARK: - 卡片样式控制 (可扩展)
    func enableCardEffect(backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.1),
                         cornerRadius: CGFloat = 8,
                         shadowOpacity: Float = 0.03) {
        monthCardView.backgroundColor = backgroundColor
        monthCardView.layer.cornerRadius = cornerRadius
        monthCardView.layer.shadowColor = UIColor.black.cgColor
        monthCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        monthCardView.layer.shadowRadius = 3
        monthCardView.layer.shadowOpacity = shadowOpacity
    }
    
    func disableCardEffect() {
        monthCardView.backgroundColor = .clear
        monthCardView.layer.cornerRadius = 0
        monthCardView.layer.shadowOpacity = 0
    }
}

// MARK: - CalendarDayCellDelegate
extension MonthCollectionViewCell: CalendarDayCellDelegate {
    func didSelectDay(_ calendarDay: CalendarDay) {
        delegate?.didSelectDate(calendarDay.date)
    }
}
