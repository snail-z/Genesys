//
//  CalendarWidgetView.swift
//  widget_preview
//
//  Created by Assistant on 2025/8/31.
//  大号日历组件样式
//

import WidgetKit
import SwiftUI

struct CalendarEntry: TimelineEntry {
    let date: Date
    let currentMonth: Date
    let today: Date
}

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), currentMonth: Date(), today: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        let now = Date()
        let entry = CalendarEntry(date: now, currentMonth: now, today: now)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> ()) {
        let now = Date()
        let entry = CalendarEntry(date: now, currentMonth: now, today: now)
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: now)!))
        completion(timeline)
    }
}

struct LargeCalendarWidgetView: View {
    let entry: CalendarEntry
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "yyyy年M月"
        return dateFormatter.string(from: entry.currentMonth)
    }
    
    private var weekdayHeaders: [String] {
        dateFormatter.dateFormat = "E"
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            return dateFormatter.string(from: date)
        }
    }
    
    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: entry.currentMonth)?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: entry.currentMonth)?.end ?? Date()
        
        let startOfFirstWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date?] = []
        var currentDate = startOfFirstWeek
        
        while currentDate < endOfMonth {
            if calendar.isDate(currentDate, inSameDayAs: startOfMonth) || currentDate > startOfMonth {
                if currentDate < endOfMonth {
                    days.append(currentDate)
                } else {
                    days.append(nil)
                }
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // 确保有完整的6行7列
        while days.count < 42 {
            days.append(nil)
        }
        
        return Array(days.prefix(42))
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // 月份年份标题
            HStack {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
            
            // 星期几标题
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            
            // 日历网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(0..<42, id: \.self) { index in
                    CalendarDayView(
                        date: daysInMonth[index],
                        today: entry.today,
                        currentMonth: entry.currentMonth
                    )
                }
            }
            .padding(.horizontal, 4)
            
            Spacer(minLength: 0)
        }
        .padding(8)
    }
}

struct CalendarDayView: View {
    let date: Date?
    let today: Date
    let currentMonth: Date
    
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        guard let date = date else { return "" }
        return String(calendar.component(.day, from: date))
    }
    
    private var isToday: Bool {
        guard let date = date else { return false }
        return calendar.isDate(date, inSameDayAs: today)
    }
    
    private var isCurrentMonth: Bool {
        guard let date = date else { return false }
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    var body: some View {
        ZStack {
            // 今天的背景
            if isToday {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 28, height: 28)
            }
            
            // 日期数字
            if let _ = date {
                Text(dayNumber)
                    .font(.system(size: 12, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
            }
        }
        .frame(height: 32)
        .frame(maxWidth: .infinity)
    }
    
    private var textColor: Color {
        if isToday {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.5)
        }
    }
}

// 大号日历Widget配置
struct LargeCalendarWidget: Widget {
    let kind: String = "LargeCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            if #available(iOS 17.0, *) {
                LargeCalendarWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LargeCalendarWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("大号日历")
        .description("显示完整月份日历的大号小组件")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview("Medium Calendar", as: .systemMedium) {
    LargeCalendarWidget()
} timeline: {
    CalendarEntry(date: .now, currentMonth: .now, today: .now)
}

#Preview("Large Calendar", as: .systemLarge) {
    LargeCalendarWidget()
} timeline: {
    CalendarEntry(date: .now, currentMonth: .now, today: .now)
}