import UIKit

protocol CalendarDayCellDelegate: AnyObject {
    func didSelectDay(_ calendarDay: CalendarDay)
}

class CalendarDayCell: UIView {
    
    // MARK: - 属性
    weak var delegate: CalendarDayCellDelegate?
    private var calendarDay: CalendarDay?
    
    // MARK: - UI组件
    private let containerView = UIView()
    private let solarDayLabel = UILabel()
    private let lunarDayLabel = UILabel()
    private let festivalLabel = UILabel()
    private let tapGesture = UITapGestureRecognizer()
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGesture()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(solarDayLabel)
        containerView.addSubview(lunarDayLabel)
        containerView.addSubview(festivalLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        solarDayLabel.translatesAutoresizingMaskIntoConstraints = false
        lunarDayLabel.translatesAutoresizingMaskIntoConstraints = false
        festivalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 容器视图设置
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        
        // 阳历日期标签
        solarDayLabel.font = .boldSystemFont(ofSize: 18)
        solarDayLabel.textAlignment = .center
        solarDayLabel.textColor = .label
        
        // 农历日期标签
        lunarDayLabel.font = .systemFont(ofSize: 10)
        lunarDayLabel.textAlignment = .center
        lunarDayLabel.textColor = .secondaryLabel
        
        // 节日标签
        festivalLabel.font = .systemFont(ofSize: 8)
        festivalLabel.textAlignment = .center
        festivalLabel.textColor = .systemRed
        festivalLabel.isHidden = true
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            
            // 阳历日期标签约束
            solarDayLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            solarDayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            solarDayLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            solarDayLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 农历日期标签约束
            lunarDayLabel.topAnchor.constraint(equalTo: solarDayLabel.bottomAnchor, constant: 2),
            lunarDayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            lunarDayLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            lunarDayLabel.heightAnchor.constraint(equalToConstant: 12),
            
            // 节日标签约束
            festivalLabel.topAnchor.constraint(equalTo: lunarDayLabel.bottomAnchor, constant: 1),
            festivalLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            festivalLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            festivalLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -2)
        ])
    }
    
    private func setupGesture() {
        tapGesture.addTarget(self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - 配置方法
    func configure(with calendarDay: CalendarDay) {
        self.calendarDay = calendarDay
        
        // 设置阳历日期
        solarDayLabel.text = "\(calendarDay.solarDay)"
        
        // 第二行按优先级显示：节假日 > 节气 > 农历
        if let festival = calendarDay.festival {
            // 优先级1：节假日（红色）
            lunarDayLabel.text = festival
            lunarDayLabel.textColor = .systemRed
        } else if let solarTerm = calendarDay.solarTerm {
            // 优先级2：节气（橙色）
            lunarDayLabel.text = solarTerm
            lunarDayLabel.textColor = .systemOrange
        } else {
            // 优先级3：农历（灰色）
            lunarDayLabel.text = calendarDay.lunarDay
            lunarDayLabel.textColor = calendarDay.isCurrentMonth ? .secondaryLabel : .quaternaryLabel
        }
        
        // 隐藏节假日标签，统一使用lunarDayLabel显示
        festivalLabel.isHidden = true
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        guard let day = calendarDay else { return }
        
        // 重置样式
        containerView.backgroundColor = .clear
        containerView.layer.borderWidth = 0
        containerView.layer.borderColor = nil
        
        // 当前月份颜色
        if day.isCurrentMonth {
            solarDayLabel.textColor = .label
            lunarDayLabel.textColor = day.solarTerm != nil ? .systemOrange : .secondaryLabel
        } else {
            solarDayLabel.textColor = .tertiaryLabel
            lunarDayLabel.textColor = .quaternaryLabel
        }
        
        // 今天标记 - 清新绿色主题
        if day.isToday {
            containerView.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 0.8, alpha: 0.4)
            solarDayLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)
            solarDayLabel.font = .boldSystemFont(ofSize: 18)
        }
        
        // 选中标记 - 清新绿色边框
        if day.isSelected {
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 1.0).cgColor
        }
        
        // 节日背景
        if day.festival != nil {
            if containerView.backgroundColor == .clear {
                containerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            }
        }
        
        // 周末颜色（周日和周六）
        let weekday = Calendar.current.component(.weekday, from: day.date)
        if weekday == 1 || weekday == 7 {
            if day.isCurrentMonth {
                solarDayLabel.textColor = .systemRed
            }
        }
    }
    
    // MARK: - 事件处理
    @objc private func handleTap() {
        guard let day = calendarDay else { return }
        
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        delegate?.didSelectDay(day)
    }
    
    // MARK: - 辅助方法
    func prepareForReuse() {
        calendarDay = nil
        containerView.backgroundColor = .clear
        containerView.layer.borderWidth = 0
        containerView.layer.borderColor = nil
        festivalLabel.isHidden = true
        lunarDayLabel.isHidden = false
        solarDayLabel.textColor = .label
        lunarDayLabel.textColor = .secondaryLabel
        solarDayLabel.font = .boldSystemFont(ofSize: 18)
    }
    
    func updateSelection(_ isSelected: Bool) {
        guard var day = calendarDay else { return }
        day.isSelected = isSelected
        self.calendarDay = day
        updateAppearance()
    }
}
