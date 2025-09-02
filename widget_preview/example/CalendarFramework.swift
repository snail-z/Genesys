////
////  CalendarFramework.swift
////  widget_preview
////
////  Created by Assistant on 2025/8/31.
////  通用日历数据框架 - 支持各种样式的日历UI
////
//
//import SwiftUI
//import Foundation
//
//// MARK: - 核心数据模型
//
///// 日历日期数据模型
//public struct CalendarDayModel: Identifiable, Hashable {
//    public let id = UUID()
//    public let number: Int              // 日期数字 1-31
//    public let date: Date               // 完整日期
//    public let isCurrentMonth: Bool     // 是否当前月
//    public let isToday: Bool           // 是否今天
//    public let isWeekend: Bool         // 是否周末
//    public let weekdayIndex: Int       // 星期几索引 0=周一, 6=周日
//    
//    public init(
//        number: Int,
//        date: Date,
//        isCurrentMonth: Bool,
//        isToday: Bool,
//        isWeekend: Bool,
//        weekdayIndex: Int
//    ) {
//        self.number = number
//        self.date = date
//        self.isCurrentMonth = isCurrentMonth
//        self.isToday = isToday
//        self.isWeekend = isWeekend
//        self.weekdayIndex = weekdayIndex
//    }
//}
//
///// 日历周数据模型
//public struct CalendarWeekModel: Identifiable {
//    public let id = UUID()
//    public let days: [CalendarDayModel]
//    public let weekOfYear: Int
//    
//    public init(days: [CalendarDayModel], weekOfYear: Int) {
//        self.days = days
//        self.weekOfYear = weekOfYear
//    }
//}
//
///// 日历月份数据模型
//public struct CalendarMonthModel: Identifiable {
//    public let id = UUID()
//    public let date: Date               // 月份日期
//    public let year: Int                // 年份
//    public let month: Int               // 月份 1-12
//    public let weeks: [CalendarWeekModel] // 周数据
//    public let totalRows: Int           // 需要的行数
//    public let monthName: String        // 月份名称
//    public let yearMonthString: String  // 年月字符串
//    
//    public init(
//        date: Date,
//        year: Int,
//        month: Int,
//        weeks: [CalendarWeekModel],
//        totalRows: Int,
//        monthName: String,
//        yearMonthString: String
//    ) {
//        self.date = date
//        self.year = year
//        self.month = month
//        self.weeks = weeks
//        self.totalRows = totalRows
//        self.monthName = monthName
//        self.yearMonthString = yearMonthString
//    }
//}
//
///// 布局配置模型
//public struct CalendarLayoutConfig {
//    public let containerSize: CGSize
//    public let fixedGridHeight: CGFloat
//    public let dayHeight: CGFloat
//    public let fontSize: CGFloat
//    public let cornerRadius: CGFloat
//    public let shadowRadius: CGFloat
//    public let paddingSize: CGFloat
//    
//    public init(containerSize: CGSize) {
//        self.containerSize = containerSize
//        let baseSize = min(containerSize.width, containerSize.height)
//        
//        if baseSize > 350 {
//            // Large Widget
//            self.fixedGridHeight = 180
//            self.dayHeight = 28
//            self.fontSize = 16
//            self.cornerRadius = 16
//            self.shadowRadius = 8
//            self.paddingSize = 20
//        } else if baseSize > 300 {
//            // Medium Widget
//            self.fixedGridHeight = 150
//            self.dayHeight = 24
//            self.fontSize = 14
//            self.cornerRadius = 14
//            self.shadowRadius = 6
//            self.paddingSize = 16
//        } else {
//            // Small Widget
//            self.fixedGridHeight = 120
//            self.dayHeight = 20
//            self.fontSize = 12
//            self.cornerRadius = 12
//            self.shadowRadius = 4
//            self.paddingSize = 12
//        }
//    }
//    
//    /// 根据行数计算动态间距
//    public func dynamicRowSpacing(for rows: Int) -> CGFloat {
//        guard rows > 1 else { return 0 }
//        
//        let totalSpacingHeight = fixedGridHeight - CGFloat(rows) * dayHeight
//        let spacing = totalSpacingHeight / CGFloat(rows - 1)
//        
//        return max(1, min(spacing, 8))
//    }
//}
//
//// MARK: - 日历数据计算引擎
//
//public class CalendarDataEngine {
//    private let calendar: Calendar
//    
//    public init(calendar: Calendar = Calendar.current) {
//        self.calendar = calendar
//    }
//    
//    /// 生成指定月份的完整日历数据
//    public func generateCalendarData(
//        for targetDate: Date,
//        today: Date = Date()
//    ) -> CalendarMonthModel {
//        let startOfMonth = calendar.dateInterval(of: .month, for: targetDate)?.start ?? targetDate
//        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
//        
//        // 计算第一天是星期几 (转换为周一开始)
//        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
//        firstWeekday = (firstWeekday + 5) % 7  // 0=周一, 6=周日
//        
//        var allDays: [CalendarDayModel] = []
//        
//        // 1. 添加上个月的填充日期
//        if firstWeekday > 0 {
//            allDays.append(contentsOf: generatePreviousMonthDays(
//                startOfMonth: startOfMonth,
//                fillDays: firstWeekday,
//                today: today
//            ))
//        }
//        
//        // 2. 添加当前月的所有日期
//        allDays.append(contentsOf: generateCurrentMonthDays(
//            startOfMonth: startOfMonth,
//            daysInMonth: daysInMonth,
//            today: today
//        ))
//        
//        // 3. 计算需要的行数
//        let totalCellsUsed = firstWeekday + daysInMonth
//        let neededRows = Int(ceil(Double(totalCellsUsed) / 7.0))
//        let totalCellsNeeded = neededRows * 7
//        
//        // 4. 添加下个月的填充日期
//        if allDays.count < totalCellsNeeded {
//            allDays.append(contentsOf: generateNextMonthDays(
//                startOfMonth: startOfMonth,
//                currentDayCount: allDays.count,
//                targetCount: totalCellsNeeded,
//                today: today
//            ))
//        }
//        
//        // 5. 将一维数组转换为周数据
//        let weeks = createWeeks(from: allDays, startOfMonth: startOfMonth)
//        
//        // 6. 生成月份信息
//        let year = calendar.component(.year, from: startOfMonth)
//        let month = calendar.component(.month, from: startOfMonth)
//        let monthName = monthNameString(for: startOfMonth)
//        let yearMonthString = yearMonthString(for: startOfMonth)
//        
//        return CalendarMonthModel(
//            date: startOfMonth,
//            year: year,
//            month: month,
//            weeks: weeks,
//            totalRows: neededRows,
//            monthName: monthName,
//            yearMonthString: yearMonthString
//        )
//    }
//    
//    // MARK: - 私有方法
//    
//    private func generatePreviousMonthDays(
//        startOfMonth: Date,
//        fillDays: Int,
//        today: Date
//    ) -> [CalendarDayModel] {
//        let startOfPrevMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
//        let daysInPrevMonth = calendar.range(of: .day, in: .month, for: startOfPrevMonth)?.count ?? 30
//        
//        return (daysInPrevMonth - fillDays + 1...daysInPrevMonth).map { dayNumber in
//            let dayDate = calendar.date(byAdding: .day, value: dayNumber - daysInPrevMonth - 1, to: startOfMonth)!
//            return createDayModel(
//                number: dayNumber,
//                date: dayDate,
//                isCurrentMonth: false,
//                today: today
//            )
//        }
//    }
//    
//    private func generateCurrentMonthDays(
//        startOfMonth: Date,
//        daysInMonth: Int,
//        today: Date
//    ) -> [CalendarDayModel] {
//        return (1...daysInMonth).map { dayNumber in
//            let dayDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: startOfMonth)!
//            return createDayModel(
//                number: dayNumber,
//                date: dayDate,
//                isCurrentMonth: true,
//                today: today
//            )
//        }
//    }
//    
//    private func generateNextMonthDays(
//        startOfMonth: Date,
//        currentDayCount: Int,
//        targetCount: Int,
//        today: Date
//    ) -> [CalendarDayModel] {
//        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
//        let remainingDays = targetCount - currentDayCount
//        
//        return (1...remainingDays).map { dayNumber in
//            let dayDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: nextMonth)!
//            return createDayModel(
//                number: dayNumber,
//                date: dayDate,
//                isCurrentMonth: false,
//                today: today
//            )
//        }
//    }
//    
//    private func createDayModel(
//        number: Int,
//        date: Date,
//        isCurrentMonth: Bool,
//        today: Date
//    ) -> CalendarDayModel {
//        let weekdayIndex = (calendar.component(.weekday, from: date) + 5) % 7  // 0=周一
//        let isWeekend = weekdayIndex >= 5  // 周六日
//        let isToday = calendar.isDate(date, inSameDayAs: today)
//        
//        return CalendarDayModel(
//            number: number,
//            date: date,
//            isCurrentMonth: isCurrentMonth,
//            isToday: isToday,
//            isWeekend: isWeekend,
//            weekdayIndex: weekdayIndex
//        )
//    }
//    
//    private func createWeeks(from days: [CalendarDayModel], startOfMonth: Date) -> [CalendarWeekModel] {
//        return stride(from: 0, to: days.count, by: 7).map { weekStartIndex in
//            let weekDays = Array(days[weekStartIndex..<min(weekStartIndex + 7, days.count)])
//            let firstDayOfWeek = weekDays.first?.date ?? startOfMonth
//            let weekOfYear = calendar.component(.weekOfYear, from: firstDayOfWeek)
//            
//            return CalendarWeekModel(days: weekDays, weekOfYear: weekOfYear)
//        }
//    }
//    
//    private func monthNameString(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "zh_CN")
//        formatter.dateFormat = "M月"
//        return formatter.string(from: date)
//    }
//    
//    private func yearMonthString(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "zh_CN")
//        formatter.dateFormat = "yyyy年M月"
//        return formatter.string(from: date)
//    }
//}
//
//// MARK: - 便捷扩展
//
//public extension CalendarMonthModel {
//    /// 获取所有天数的一维数组
//    var allDays: [CalendarDayModel] {
//        return weeks.flatMap { $0.days }
//    }
//    
//    /// 获取当前月的天数
//    var currentMonthDays: [CalendarDayModel] {
//        return allDays.filter { $0.isCurrentMonth }
//    }
//    
//    /// 获取今天（如果在当前月）
//    var todayModel: CalendarDayModel? {
//        return allDays.first { $0.isToday && $0.isCurrentMonth }
//    }
//    
//    /// 星期标题（中文）
//    static var weekdayHeaders: [String] {
//        return ["一", "二", "三", "四", "五", "六", "日"]
//    }
//    
//    /// 星期标题（英文简写）
//    static var weekdayHeadersEN: [String] {
//        return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
//    }
//}
//
//// MARK: - 使用示例和预览
//
//#Preview("Calendar Framework Demo") {
//    struct DemoView: View {
//        let engine = CalendarDataEngine()
//        let calendarData: CalendarMonthModel
//        let layoutConfig: CalendarLayoutConfig
//        
//        init() {
//            self.calendarData = CalendarDataEngine().generateCalendarData(for: Date())
//            self.layoutConfig = CalendarLayoutConfig(containerSize: CGSize(width: 350, height: 350))
//        }
//        
//        var body: some View {
//            VStack(spacing: 16) {
//                // 标题
//                Text(calendarData.yearMonthString)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                
//                // 使用框架数据的简单日历
//                VStack(spacing: 0) {
//                    // 星期标题
//                    HStack(spacing: 0) {
//                        ForEach(CalendarMonthModel.weekdayHeaders, id: \.self) { weekday in
//                            Text(weekday)
//                                .font(.caption)
//                                .frame(maxWidth: .infinity)
//                        }
//                    }
//                    .padding(.bottom, 8)
//                    
//                    // 日历网格
//                    VStack(spacing: layoutConfig.dynamicRowSpacing(for: calendarData.totalRows)) {
//                        ForEach(calendarData.weeks) { week in
//                            HStack(spacing: 0) {
//                                ForEach(week.days) { day in
//                                    Text("\(day.number)")
//                                        .font(.system(size: layoutConfig.fontSize))
//                                        .foregroundColor(
//                                            day.isToday ? .orange :
//                                            day.isCurrentMonth ? .primary : .secondary
//                                        )
//                                        .fontWeight(day.isToday ? .bold : .regular)
//                                        .frame(maxWidth: .infinity)
//                                        .frame(height: layoutConfig.dayHeight)
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color(.systemBackground))
//                .cornerRadius(layoutConfig.cornerRadius)
//                .shadow(radius: layoutConfig.shadowRadius)
//                
//                // 数据信息
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("框架数据信息:")
//                        .font(.headline)
//                    Text("总行数: \(calendarData.totalRows)")
//                    Text("当月天数: \(calendarData.currentMonthDays.count)")
//                    Text("今天: \(calendarData.todayModel?.number ?? 0)")
//                    Text("动态间距: \(String(format: "%.1f", layoutConfig.dynamicRowSpacing(for: calendarData.totalRows)))pt")
//                }
//                .padding()
//                .background(Color(.secondarySystemBackground))
//                .cornerRadius(8)
//                
//                Spacer()
//            }
//            .padding()
//        }
//    }
//    
//    return DemoView()
//}
