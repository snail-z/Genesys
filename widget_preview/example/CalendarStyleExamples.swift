////
////  CalendarStyleExamples.swift
////  widget_preview
////
////  Created by Assistant on 2025/8/31.
////  基于框架的各种日历样式示例
////
//
//import SwiftUI
//
//// MARK: - 样式1: 简约现代风格
//
//struct ModernCalendarView: View {
//    private let engine = CalendarDataEngine()
//    private let calendarData: CalendarMonthModel
//    private let layoutConfig: CalendarLayoutConfig
//    
//    init(containerSize: CGSize = CGSize(width: 350, height: 300)) {
//        self.calendarData = CalendarDataEngine().generateCalendarData(for: Date())
//        self.layoutConfig = CalendarLayoutConfig(containerSize: containerSize)
//    }
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            // 简约标题
//            HStack {
//                Text(calendarData.yearMonthString)
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                Spacer()
//                Circle()
//                    .fill(Color.blue)
//                    .frame(width: 8, height: 8)
//            }
//            
//            // 现代风格日历网格
//            VStack(spacing: layoutConfig.dynamicRowSpacing(for: calendarData.totalRows)) {
//                // 星期标题
//                HStack(spacing: 0) {
//                    ForEach(CalendarMonthModel.weekdayHeaders, id: \.self) { weekday in
//                        Text(weekday)
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//                
//                // 日期网格
//                ForEach(calendarData.weeks) { week in
//                    HStack(spacing: 0) {
//                        ForEach(week.days) { day in
//                            ZStack {
//                                if day.isToday {
//                                    RoundedRectangle(cornerRadius: 6)
//                                        .fill(Color.blue)
//                                        .frame(width: 24, height: 24)
//                                }
//                                
//                                Text("\(day.number)")
//                                    .font(.system(size: layoutConfig.fontSize - 1, weight: .medium))
//                                    .foregroundColor(
//                                        day.isToday ? .white :
//                                        day.isCurrentMonth ? .primary : .secondary
//                                    )
//                            }
//                            .frame(maxWidth: .infinity)
//                            .frame(height: layoutConfig.dayHeight)
//                        }
//                    }
//                }
//            }
//        }
//        .padding(12)
//        .background(.ultraThinMaterial)
//        .cornerRadius(16)
//    }
//}
//
//// MARK: - 样式2: 彩色圆点风格
//
//struct ColorfulCalendarView: View {
//    private let calendarData: CalendarMonthModel
//    private let layoutConfig: CalendarLayoutConfig
//    
//    init(containerSize: CGSize = CGSize(width: 350, height: 300)) {
//        self.calendarData = CalendarDataEngine().generateCalendarData(for: Date())
//        self.layoutConfig = CalendarLayoutConfig(containerSize: containerSize)
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // 彩色标题
//            HStack {
//                Text(calendarData.monthName)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.pink, .purple, .blue],
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                Spacer()
//                Text("\(calendarData.year)")
//                    .font(.title2)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.bottom, 16)
//            
//            VStack(spacing: layoutConfig.dynamicRowSpacing(for: calendarData.totalRows)) {
//                // 彩色星期标题
//                HStack(spacing: 0) {
//                    ForEach(Array(CalendarMonthModel.weekdayHeaders.enumerated()), id: \\.offset) { index, weekday in
//                        Text(weekday)
//                            .font(.caption)
//                            .fontWeight(.semibold)
//                            .foregroundColor(weekdayColor(for: index))
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//                .padding(.bottom, 8)
//                
//                // 圆点装饰日历
//                ForEach(calendarData.weeks) { week in
//                    HStack(spacing: 0) {
//                        ForEach(week.days) { day in
//                            VStack(spacing: 2) {
//                                Text("\(day.number)")
//                                    .font(.system(size: layoutConfig.fontSize, weight: day.isToday ? .bold : .medium))
//                                    .foregroundColor(
//                                        day.isCurrentMonth ? .primary : .secondary
//                                    )
//                                
//                                // 装饰圆点
//                                Circle()
//                                    .fill(dayColor(for: day))
//                                    .frame(width: day.isToday ? 6 : 3, height: day.isToday ? 6 : 3)
//                                    .opacity(day.isCurrentMonth ? 1 : 0.3)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .frame(height: layoutConfig.dayHeight)
//                        }
//                    }
//                }
//            }
//        }
//        .padding(16)
//        .background(
//            LinearGradient(
//                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//        )
//        .cornerRadius(20)
//    }
//    
//    private func weekdayColor(for index: Int) -> Color {
//        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .cyan]
//        return colors[index % colors.count]
//    }
//    
//    private func dayColor(for day: CalendarDayModel) -> Color {
//        if day.isToday {
//            return .red
//        } else if day.isWeekend {
//            return .orange
//        } else {
//            return .blue
//        }
//    }
//}
//
//// MARK: - 样式3: 卡片网格风格
//
//struct CardCalendarView: View {
//    private let calendarData: CalendarMonthModel
//    private let layoutConfig: CalendarLayoutConfig
//    
//    init(containerSize: CGSize = CGSize(width: 350, height: 300)) {
//        self.calendarData = CalendarDataEngine().generateCalendarData(for: Date())
//        self.layoutConfig = CalendarLayoutConfig(containerSize: containerSize)
//    }
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            // 卡片标题
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(calendarData.yearMonthString)
//                        .font(.headline)
//                    Text("共\(calendarData.currentMonthDays.count)天")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                Spacer()
//                
//                if let today = calendarData.todayModel {
//                    VStack {
//                        Text("\(today.number)")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                        Text("今天")
//                            .font(.caption2)
//                    }
//                    .foregroundColor(.white)
//                    .frame(width: 40, height: 40)
//                    .background(Color.red)
//                    .cornerRadius(8)
//                }
//            }
//            
//            // 卡片式日历
//            VStack(spacing: layoutConfig.dynamicRowSpacing(for: calendarData.totalRows) / 2) {
//                // 星期卡片
//                HStack(spacing: 2) {
//                    ForEach(CalendarMonthModel.weekdayHeaders, id: \.self) { weekday in
//                        Text(weekday)
//                            .font(.caption2)
//                            .fontWeight(.medium)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 4)
//                            .background(Color.blue.opacity(0.1))
//                            .cornerRadius(4)
//                    }
//                }
//                
//                // 日期卡片
//                ForEach(calendarData.weeks) { week in
//                    HStack(spacing: 2) {
//                        ForEach(week.days) { day in
//                            Text("\\(day.number)")
//                                .font(.system(size: layoutConfig.fontSize - 1, weight: .medium))
//                                .foregroundColor(
//                                    day.isToday ? .white :
//                                    day.isCurrentMonth ? .primary : .secondary
//                                )
//                                .frame(maxWidth: .infinity)
//                                .frame(height: layoutConfig.dayHeight - 4)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 6)
//                                        .fill(cardBackground(for: day))
//                                )
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 6)
//                                        .stroke(day.isToday ? Color.red : Color.clear, lineWidth: 2)
//                                )
//                        }
//                    }
//                }
//            }
//        }
//        .padding(16)
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .shadow(radius: 4)
//    }
//    
//    private func cardBackground(for day: CalendarDayModel) -> Color {
//        if day.isToday {
//            return .red
//        } else if !day.isCurrentMonth {
//            return Color(.systemGray6)
//        } else if day.isWeekend {
//            return Color(.systemBlue).opacity(0.1)
//        } else {
//            return Color(.systemGray5)
//        }
//    }
//}
//
//// MARK: - 样式4: 极简线条风格
//
//struct MinimalCalendarView: View {
//    private let calendarData: CalendarMonthModel
//    private let layoutConfig: CalendarLayoutConfig
//    
//    init(containerSize: CGSize = CGSize(width: 300, height: 250)) {
//        self.calendarData = CalendarDataEngine().generateCalendarData(for: Date())
//        self.layoutConfig = CalendarLayoutConfig(containerSize: containerSize)
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // 极简标题
//            Text(calendarData.yearMonthString)
//                .font(.system(size: layoutConfig.fontSize + 2, weight: .light))
//                .padding(.bottom, 16)
//            
//            // 线条分隔的日历
//            VStack(spacing: 0) {
//                // 星期标题行
//                HStack(spacing: 0) {
//                    ForEach(CalendarMonthModel.weekdayHeaders, id: \.self) { weekday in
//                        Text(weekday)
//                            .font(.system(size: layoutConfig.fontSize - 2, weight: .ultraLight))
//                            .foregroundColor(.secondary)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 20)
//                    }
//                }
//                .overlay(
//                    Rectangle()
//                        .fill(Color.secondary.opacity(0.3))
//                        .frame(height: 1),
//                    alignment: .bottom
//                )
//                
//                // 日期行
//                ForEach(Array(calendarData.weeks.enumerated()), id: \\.offset) { weekIndex, week in
//                    HStack(spacing: 0) {
//                        ForEach(week.days) { day in
//                            Text("\\(day.number)")
//                                .font(.system(size: layoutConfig.fontSize - 1, weight: .light))
//                                .foregroundColor(
//                                    day.isToday ? .red :
//                                    day.isCurrentMonth ? .primary : .secondary
//                                )
//                                .frame(maxWidth: .infinity)
//                                .frame(height: layoutConfig.dayHeight + 4)
//                        }
//                    }
//                    .overlay(
//                        Rectangle()
//                            .fill(Color.secondary.opacity(0.1))
//                            .frame(height: 1),
//                        alignment: .bottom
//                    )
//                }
//            }
//        }
//        .padding(12)
//    }
//}
//
//// MARK: - 统一预览
//
//#Preview("Calendar Styles") {
//    ScrollView {
//        VStack(spacing: 24) {
//            VStack {
//                Text("现代简约风格")
//                    .font(.headline)
//                ModernCalendarView()
//            }
//            
//            VStack {
//                Text("彩色圆点风格")
//                    .font(.headline)
//                ColorfulCalendarView()
//            }
//            
//            VStack {
//                Text("卡片网格风格")
//                    .font(.headline)
//                CardCalendarView()
//            }
//            
//            VStack {
//                Text("极简线条风格")
//                    .font(.headline)
//                MinimalCalendarView()
//            }
//        }
//        .padding()
//    }
//}
