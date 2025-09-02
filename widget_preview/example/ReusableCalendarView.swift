//
//  ReusableCalendarView.swift
//  widget_preview
//
//  Created by Assistant on 2025/8/31.
//  可复用的日历视图组件
//

import SwiftUI

struct ReusableCalendarView: View {
    let currentMonth: Date
    let today: Date
    let showHeader: Bool
    let headerContent: AnyView?
    let containerSize: CGSize
    
    init(
        currentMonth: Date = Date(),
        today: Date = Date(),
        showHeader: Bool = false,
        headerContent: AnyView? = nil,
        containerSize: CGSize = CGSize(width: 300, height: 300)
    ) {
        self.currentMonth = currentMonth
        self.today = today
        self.showHeader = showHeader
        self.headerContent = headerContent
        self.containerSize = containerSize
    }
    
    private let calendar = Calendar.current
    
    private var weekdayHeaders: [String] {
        return ["一", "二", "三", "四", "五", "六", "日"]
    }
    
    // 计算当前月份需要的行数
    private var totalRows: Int {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
        
        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
        firstWeekday = (firstWeekday + 5) % 7
        
        let totalCellsUsed = firstWeekday + daysInMonth
        return Int(ceil(Double(totalCellsUsed) / 7.0))
    }
    
    private var calendarDays: [[CalendarDay]] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
        
        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
        firstWeekday = (firstWeekday + 5) % 7
        
        var days: [CalendarDay] = []
        
        if firstWeekday > 0 {
            let startOfPrevMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
            let daysInPrevMonth = calendar.range(of: .day, in: .month, for: startOfPrevMonth)?.count ?? 30
            
            for i in (daysInPrevMonth - firstWeekday + 1)...daysInPrevMonth {
                let dayDate = calendar.date(byAdding: .day, value: i - daysInPrevMonth - 1, to: startOfMonth)!
                days.append(CalendarDay(
                    number: i,
                    isCurrentMonth: false,
                    isToday: false,
                    date: dayDate
                ))
            }
        }
        
        for day in 1...daysInMonth {
            let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let isToday = calendar.isDate(dayDate, inSameDayAs: today)
            days.append(CalendarDay(
                number: day,
                isCurrentMonth: true,
                isToday: isToday,
                date: dayDate
            ))
        }
        
        // 计算需要的最少行数：确保当月最后一天显示完整
        let totalCellsUsed = firstWeekday + daysInMonth
        let neededRows = Int(ceil(Double(totalCellsUsed) / 7.0))
        let totalCellsNeeded = neededRows * 7
        
        // 添加下个月的日期填充到完整行数
        var nextMonthDay = 1
        while days.count < totalCellsNeeded {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let dayDate = calendar.date(byAdding: .day, value: nextMonthDay - 1, to: nextMonth)!
            days.append(CalendarDay(
                number: nextMonthDay,
                isCurrentMonth: false,
                isToday: false,
                date: dayDate
            ))
            nextMonthDay += 1
        }
        
        // 将一维数组转换为二维数组（动态行数×7列）
        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<min($0 + 7, days.count)])
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 可选的头部内容
            if showHeader, let header = headerContent {
                header
//                    .padding(.bottom, adaptiveHeaderBottomPadding())
            }
            
            // 日历卡片
            VStack(spacing: 0) {
                // 星期标题行
                HStack(spacing: 0) {
                    ForEach(weekdayHeaders, id: \.self) { weekday in
                        Text(weekday)
                            .font(.system(size: adaptiveWeekdaySize(), weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, adaptiveCalendarTopPadding())
                .padding(.bottom, adaptiveWeekdayBottomPadding())
                
                // 日历网格 - 动态行数
                VStack(spacing: adaptiveDaySpacing()) {
                    ForEach(0..<calendarDays.count, id: \.self) { weekIndex in
                        HStack(spacing: 0) {
                            ForEach(0..<calendarDays[weekIndex].count, id: \.self) { dayIndex in
                                ReusableCalendarDayView(
                                    day: calendarDays[weekIndex][dayIndex],
                                    containerSize: containerSize
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, adaptiveCalendarBottomPadding())
            }
            .background(Color.white)
            .cornerRadius(adaptiveCornerRadius())
            .shadow(color: Color.black.opacity(0.08), radius: adaptiveShadowRadius(), x: 0, y: 2)
        }
    }
    
    // MARK: - 自适应尺寸函数
    
    private func adaptiveHeaderBottomPadding() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 12
        } else if baseSize > 300 {
            return 10
        } else {
            return 8
        }
    }
    
    private func adaptiveWeekdaySize() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 14
        } else if baseSize > 300 {
            return 12
        } else {
            return 11
        }
    }
    
    private func adaptiveCalendarTopPadding() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 12
        } else if baseSize > 300 {
            return 10
        } else {
            return 8
        }
    }
    
    private func adaptiveWeekdayBottomPadding() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 8
        } else if baseSize > 300 {
            return 6
        } else {
            return 4
        }
    }
    
    private func adaptiveDaySpacing() -> CGFloat {
        let fixedCalendarHeight = fixedCalendarGridHeight()
        let dayHeight = adaptiveDayHeight()
        let rows = totalRows
        
        // 如果只有1行，不需要间距
        guard rows > 1 else { return 0 }
        
        // 动态计算间距：(总高度 - 行数×单元格高度) / (行数-1)
        let totalSpacingHeight = fixedCalendarHeight - CGFloat(rows) * dayHeight
        let spacing = totalSpacingHeight / CGFloat(rows - 1)
        
        // 确保间距不会为负数或过大
        return max(1, min(spacing, 8))
    }
    
    // 定义固定的日历网格总高度
    private func fixedCalendarGridHeight() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 180  // Large widget: 6行×28高度 + 5个间距×4 = 168+20 ≈ 180
        } else if baseSize > 300 {
            return 150  // Medium widget: 6行×24高度 + 5个间距×3 = 144+15 ≈ 150  
        } else {
            return 120  // Small widget: 6行×20高度 + 5个间距×2 = 120+10 ≈ 120
        }
    }
    
    // 统一的日期单元格高度
    private func adaptiveDayHeight() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 28
        } else if baseSize > 300 {
            return 24
        } else {
            return 20
        }
    }
    
    private func adaptiveCalendarBottomPadding() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 12
        } else if baseSize > 300 {
            return 10
        } else {
            return 8
        }
    }
    
    private func adaptiveCornerRadius() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 16
        } else if baseSize > 300 {
            return 14
        } else {
            return 12
        }
    }
    
    private func adaptiveShadowRadius() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 8
        } else if baseSize > 300 {
            return 6
        } else {
            return 4
        }
    }
}

struct ReusableCalendarDayView: View {
    let day: CalendarDay
    let containerSize: CGSize
    
    var body: some View {
        Text("\(day.number)")
            .font(.system(size: adaptiveDayNumberSize(), weight: day.isToday ? .bold : .medium))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: adaptiveDayHeight())
    }
    
    private var textColor: Color {
        if day.isToday {
            return Color(red: 1.0, green: 0.4, blue: 0.2) // 橙红色
        } else if day.isCurrentMonth {
            return Color(red: 0.2, green: 0.6, blue: 0.3) // 深绿色
        } else {
            return Color.gray.opacity(0.4) // 浅灰色
        }
    }
    
    private func adaptiveDayNumberSize() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 16
        } else if baseSize > 300 {
            return 14
        } else {
            return 12
        }
    }
    
    private func adaptiveDayHeight() -> CGFloat {
        let baseSize = min(containerSize.width, containerSize.height)
        if baseSize > 350 {
            return 28
        } else if baseSize > 300 {
            return 24
        } else {
            return 20
        }
    }
}

// MARK: - 预览和使用示例

#Preview("Standalone Calendar") {
    GeometryReader { geometry in
        VStack {
            // 使用示例1：纯日历
            ReusableCalendarView(
                containerSize: geometry.size
            )
            .padding(20)
            
            Spacer()
            
            // 使用示例2：带自定义头部的日历
            ReusableCalendarView(
                showHeader: true,
                headerContent: AnyView(
                    HStack {
                        Text("🍀")
                            .font(.title)
                        Text("我的日历")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                ),
                containerSize: CGSize(width: geometry.size.width - 40, height: 200)
            )
            .padding(20)
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.7, green: 0.9, blue: 0.7),
                    Color(red: 0.6, green: 0.85, blue: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
