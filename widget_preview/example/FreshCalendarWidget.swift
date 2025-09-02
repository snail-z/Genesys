//
//  FreshCalendarWidget.swift
//  widget_preview
//
//  Created by Assistant on 2025/8/31.
//  清新风格日历组件 - 专业架构重构版
//

import WidgetKit
import SwiftUI

// MARK: - 数据模型

struct FreshCalendarEntry: TimelineEntry {
    let date: Date
    let currentMonth: Date
    let today: Date
    let dayOfMonth: Int
    let motivationText: String
    let recordTime: String
}

struct CalendarDay {
    let number: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let date: Date
}

// MARK: - 布局配置

struct FreshCalendarLayout {
    // 主要间距配置
    let headerTopMargin: CGFloat = 0
    let headerHorizontalMargin: CGFloat = 15
    let cardSpacing: CGFloat = 15
    let calendarHorizontalMargin: CGFloat = 15
    let calendarBottomMargin: CGFloat // 动态参数：日历卡片距离背景底部的间距
    
    // 内部间距配置
    let headerVerticalPadding: CGFloat
    let calendarInternalPadding: CGFloat
    
    // 尺寸配置
    let headerCardHeight: CGFloat // 固定Header卡片高度
    let iconSize: CGFloat
    let dayNumberSize: CGFloat
    let mainTextSize: CGFloat
    let smallTextSize: CGFloat
    let proTagSize: CGFloat
    let weekdaySize: CGFloat
    let dayHeight: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(containerSize: CGSize, calendarBottomMargin: CGFloat = 0) {
        let baseSize = min(containerSize.width, containerSize.height)
        self.calendarBottomMargin = calendarBottomMargin
        
        if baseSize > 350 {
            // Large widget
            headerCardHeight = 80
            headerVerticalPadding = 16
            calendarInternalPadding = 12
            iconSize = 32
            dayNumberSize = 48
            mainTextSize = 16
            smallTextSize = 12
            proTagSize = 12
            weekdaySize = 14
            dayHeight = 28
            cornerRadius = 16
            shadowRadius = 8
        } else if baseSize > 300 {
            // Medium widget
            headerCardHeight = 72
            headerVerticalPadding = 14
            calendarInternalPadding = 15
            iconSize = 28
            dayNumberSize = 40
            mainTextSize = 14
            smallTextSize = 11
            proTagSize = 11
            weekdaySize = 12
            dayHeight = 24
            cornerRadius = 14
            shadowRadius = 6
        } else {
            // Small widget
            headerCardHeight = 60
            headerVerticalPadding = 12
            calendarInternalPadding = 8
            iconSize = 24
            dayNumberSize = 32
            mainTextSize = 12
            smallTextSize = 10
            proTagSize = 10
            weekdaySize = 11
            dayHeight = 20
            cornerRadius = 12
            shadowRadius = 4
        }
    }
}

// MARK: - 样式配置

struct FreshCalendarStyle {
    // 颜色配置
    static let todayColor = Color(red: 0.6, green: 0.4, blue: 0.9) // 紫色
    static let currentMonthColor = Color(red: 0.2, green: 0.6, blue: 0.3) // 深绿色
    static let otherMonthColor = Color.gray.opacity(0.4) // 浅灰色
    static let cardBackgroundColor = Color(red: 0.98, green: 0.98, blue: 0.95) // 奶白色
    static let proTagBackgroundColor = Color(red: 0.4, green: 0.3, blue: 0.2) // 棕色
    static let shadowColor = Color.black.opacity(0.08)
    
    // 背景渐变 - 更清新淡雅的绿色
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.92, green: 0.97, blue: 0.92),  // 非常浅的薄荷绿
            Color(red: 0.85, green: 0.93, blue: 0.85)   // 清淡的浅绿色
        ],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
}

// MARK: - Header 组件

struct FreshCalendarHeaderCard: View {
    let entry: FreshCalendarEntry
    let layout: FreshCalendarLayout
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // 四叶草图标 - 更大更浅
            Text("🍀")
                .font(.system(size: layout.iconSize * 1.1))
                .opacity(0.8)
            
            // 中间今日小语
            VStack(alignment: .leading, spacing: 8) {
                Text("今日小语")
                    .font(.system(size: layout.smallTextSize, weight: .medium))
                    .foregroundColor(.black.opacity(0.5))
                
                Text("又是元气满满的一天")
                    .font(.system(size: layout.mainTextSize, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 右侧日期 - 中文月份年份
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatChineseMonth(entry.date))
                    .font(.system(size: layout.smallTextSize, weight: .regular, design: .rounded))
                    .italic()
                    .foregroundColor(.black.opacity(0.5))
                
                Text(formatChineseYear(entry.date))
                    .font(.system(size: layout.smallTextSize, weight: .regular, design: .rounded))
                    .italic()
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .padding(.horizontal, layout.headerHorizontalMargin)
        .padding(.vertical, 12)
    }
    
    private func formatYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter.string(from: date)
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }
    
    private func formatMonthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: date)
    }
    
    private func formatYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private func formatChineseMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M"
        let month = formatter.string(from: date)
        return "\(month)月"
    }
    
    private func formatChineseYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        return "\(year)年"
    }
}

// MARK: - Calendar 组件

struct FreshCalendarCard: View {
    let calendarDays: [[CalendarDay]]
    let layout: FreshCalendarLayout
    let dynamicHeight: CGFloat // 动态计算的高度
    
    private let weekdayHeaders = ["一", "二", "三", "四", "五", "六", "日"]
    private let weekdayBottomPadding: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 0) {
            // 星期标题行
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: layout.weekdaySize, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, layout.calendarInternalPadding)
            .padding(.bottom, weekdayBottomPadding)
            
            // 日历网格
            VStack(spacing: calculateDaySpacing()) {
                ForEach(0..<calendarDays.count, id: \.self) { weekIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<calendarDays[weekIndex].count, id: \.self) { dayIndex in
                            FreshCalendarDayView(
                                day: calendarDays[weekIndex][dayIndex],
                                layout: layout
                            )
                        }
                    }
                }
            }
            .padding(.bottom, layout.calendarInternalPadding)
        }
        .frame(height: dynamicHeight) // 使用动态计算的高度
        .padding(.horizontal, layout.calendarHorizontalMargin)
        .background(FreshCalendarStyle.cardBackgroundColor)
        .cornerRadius(layout.cornerRadius)
        .shadow(
            color: FreshCalendarStyle.shadowColor,
            radius: layout.shadowRadius,
            x: 0,
            y: 2
        )
    }
    
    private func calculateDaySpacing() -> CGFloat {
        let rows = calendarDays.count
        guard rows > 1 else { return 0 }
        
        // 根据动态卡片高度计算间距
        let availableCardHeight = dynamicHeight
        
        // 计算已知的高度
        let weekdayHeaderHeight = layout.weekdaySize + layout.calendarInternalPadding + weekdayBottomPadding  // weekday文字高度 + 顶部padding + 底部padding
        let totalItemsHeight = CGFloat(rows) * layout.dayHeight  // 所有日期行的总高度
        let bottomPadding = layout.calendarInternalPadding  // 底部内边距
        
        // 可用于间距的剩余高度
        let remainingHeight = availableCardHeight - weekdayHeaderHeight - totalItemsHeight - bottomPadding
        
        // 计算每行间距：剩余高度 / (行数-1)
        let spacing = remainingHeight / CGFloat(rows - 1)
        
        // 确保间距在合理范围内
        return max(2, min(spacing, 20))
    }
}

// MARK: - Day 组件

struct FreshCalendarDayView: View {
    let day: CalendarDay
    let layout: FreshCalendarLayout
    
    var body: some View {
        Text("\(day.number)")
            .font(.system(
                size: layout.weekdaySize,
                weight: day.isToday ? .bold : .medium
            ))
            .foregroundColor(day.isToday ? .white : textColor)
            .frame(maxWidth: .infinity)
            .frame(height: layout.dayHeight)
            .background(
                day.isToday ? 
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.9),
                                Color.orange.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: layout.dayHeight * 0.9, height: layout.dayHeight * 0.9)
                : nil
            )
    }
    
    private var textColor: Color {
        if day.isCurrentMonth {
            return FreshCalendarStyle.currentMonthColor
        } else {
            return FreshCalendarStyle.otherMonthColor
        }
    }
}

// MARK: - 主容器组件

struct FreshCalendarContainerView: View {
    let entry: FreshCalendarEntry
    let calendarDays: [[CalendarDay]]
    let containerSize: CGSize
    let calendarBottomMargin: CGFloat // 可配置的底部间距
    
    private var layout: FreshCalendarLayout {
        FreshCalendarLayout(containerSize: containerSize, calendarBottomMargin: calendarBottomMargin)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header 区域 - 固定高度
            FreshCalendarHeaderCard(entry: entry, layout: layout)
                .frame(height: layout.headerCardHeight)
                .background(FreshCalendarStyle.cardBackgroundColor)
                .cornerRadius(layout.cornerRadius)
            
            // 卡片间距
            Spacer().frame(height: layout.cardSpacing)
            
            // Calendar 卡片区域 - 动态高度填满剩余空间
            FreshCalendarCard(
                calendarDays: calendarDays, 
                layout: layout,
                dynamicHeight: calculateCalendarHeight()
            )
        }
        .padding(.top, layout.headerTopMargin)
        .padding(.bottom, layout.calendarBottomMargin)
    }
    
    // 动态计算日历卡片高度
    private func calculateCalendarHeight() -> CGFloat {
        let totalHeight = containerSize.height
        let usedHeight = layout.headerTopMargin + 
                        layout.headerCardHeight + 
                        layout.cardSpacing + 
                        layout.calendarBottomMargin
        return totalHeight - usedHeight
    }
}

// MARK: - 主视图组件

struct FreshCalendarWidgetView: View {
    let entry: FreshCalendarEntry
    private let calendar = Calendar.current
    
    var body: some View {
        GeometryReader { geometry in
            FreshCalendarContainerView(
                entry: entry,
                calendarDays: calendarDays,
                containerSize: geometry.size,
                calendarBottomMargin: 0 // 默认为0，日历卡片贴底部；可改为其他值如10、20等
            )
        }
    }
    
    // 计算日历数据
    private var calendarDays: [[CalendarDay]] {
        let startOfMonth = calendar.dateInterval(of: .month, for: entry.currentMonth)?.start ?? entry.currentMonth
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
        
        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
        firstWeekday = (firstWeekday + 5) % 7
        
        var days: [CalendarDay] = []
        
        // 添加上个月的日期填充
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
        
        // 添加当前月的日期
        for day in 1...daysInMonth {
            let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let isToday = calendar.isDate(dayDate, inSameDayAs: entry.today)
            days.append(CalendarDay(
                number: day,
                isCurrentMonth: true,
                isToday: isToday,
                date: dayDate
            ))
        }
        
        // 动态计算需要的行数，只显示必要的行数
        let totalCellsUsed = firstWeekday + daysInMonth
        let neededRows = Int(ceil(Double(totalCellsUsed) / 7.0))
        let totalCellsNeeded = neededRows * 7
        
        // 只补充到实际需要的行数
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
        
        // 转换为二维数组
        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<min($0 + 7, days.count)])
        }
    }
}

// MARK: - Provider

struct FreshCalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> FreshCalendarEntry {
        let now = Date()
        return FreshCalendarEntry(
            date: now,
            currentMonth: now,
            today: now,
            dayOfMonth: Calendar.current.component(.day, from: now),
            motivationText: "坚持吃轻食！",
            recordTime: formatRecordTime(now)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FreshCalendarEntry) -> ()) {
        let now = Date()
        let entry = FreshCalendarEntry(
            date: now,
            currentMonth: now,
            today: now,
            dayOfMonth: Calendar.current.component(.day, from: now),
            motivationText: "坚持吃轻食！",
            recordTime: formatRecordTime(now)
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FreshCalendarEntry>) -> ()) {
        let now = Date()
        let entry = FreshCalendarEntry(
            date: now,
            currentMonth: now,
            today: now,
            dayOfMonth: Calendar.current.component(.day, from: now),
            motivationText: "坚持吃轻食！",
            recordTime: formatRecordTime(now)
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now)) ?? now
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func formatRecordTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return "Rec:\(formatter.string(from: date))"
    }
}

// MARK: - Widget 配置

struct FreshCalendarWidget: Widget {
    let kind: String = "FreshCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FreshCalendarProvider()) { entry in
            if #available(iOS 17.0, *) {
                FreshCalendarWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        FreshCalendarStyle.backgroundGradient
                    }
            } else {
                FreshCalendarWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("清新日历")
        .description("清新绿色风格的日历小组件，激励每日坚持")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview("Fresh Calendar Medium", as: .systemMedium) {
    FreshCalendarWidget()
} timeline: {
    let now = Date()
    FreshCalendarEntry(
        date: now,
        currentMonth: now,
        today: now,
        dayOfMonth: Calendar.current.component(.day, from: now),
        motivationText: "坚持吃轻食！",
        recordTime: {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return "Rec:\(formatter.string(from: now))"
        }()
    )
}

#Preview("Fresh Calendar Large", as: .systemLarge) {
    FreshCalendarWidget()
} timeline: {
    let now = Date()
    FreshCalendarEntry(
        date: now,
        currentMonth: now,
        today: now,
        dayOfMonth: Calendar.current.component(.day, from: now),
        motivationText: "坚持吃轻食！",
        recordTime: {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return "Rec:\(formatter.string(from: now))"
        }()
    )
}
