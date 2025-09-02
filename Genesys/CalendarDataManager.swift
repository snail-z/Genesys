import Foundation

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
    var isSelected: Bool
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

// MARK: - 日历数据管理器
class CalendarDataManager {
    static let shared = CalendarDataManager()
    
    private init() {}
    
    private let calendar = Calendar.current
    private let lunarCalendar = Calendar(identifier: .chinese)
    
    // MARK: - 公共方法
    
    /// 生成指定月份的日历数据
    func generateCalendarDays(for currentDate: Date, selectedDate: Date) -> [CalendarDay] {
        var calendarDays: [CalendarDay] = []
        let today = Date()
        
        // 获取当月第一天
        let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentDate)!.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 计算需要显示的天数 (6周 = 42天)
        let totalDays = 42
        
        // 计算起始日期（从周日开始）
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
        
        return calendarDays
    }
    
    /// 生成日期详情
    func generateDayDetail(for date: Date) -> DayDetail {
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        
        let zodiac = generateZodiac(for: year)
        let ganZhi = generateGanZhi(for: date)
        let lunarDate = generateLunarDate(for: date)
        let motivation = generateMotivation(for: day)
        let (suitable, avoid) = generateSuitableAndAvoid(for: date)
        
        return DayDetail(
            lunarDate: lunarDate,
            zodiac: zodiac,
            ganZhi: ganZhi,
            suitable: suitable,
            avoid: avoid,
            festival: nil,
            solarTerm: nil,
            motivation: motivation
        )
    }
    
    // MARK: - 私有方法
    
    private func generateLunarInfo(for date: Date) -> (lunarDay: String, lunarMonth: String, festival: String?, solarTerm: String?) {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        // 农历日期显示
        let lunarDayNames = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        
        let lunarDay = lunarDayNames[(day - 1) % 30]
        let lunarMonthNames = ["正月", "二月", "三月", "四月", "五月", "六月",
                              "七月", "八月", "九月", "十月", "冬月", "腊月"]
        let lunarMonth = lunarMonthNames[(month - 1) % 12]
        
        // 节日和节气判断
        let festival = getFestival(month: month, day: day)
        let solarTerm = getSolarTerm(month: month, day: day)
        
        return (lunarDay, lunarMonth, festival, solarTerm)
    }
    
    private func getFestival(month: Int, day: Int) -> String? {
        switch (month, day) {
        case (1, 1): return "元旦"
        case (2, 14): return "情人节"
        case (3, 8): return "妇女节"
        case (3, 12): return "植树节"
        case (4, 1): return "愚人节"
        case (5, 1): return "劳动节"
        case (5, 4): return "青年节"
        case (6, 1): return "儿童节"
        case (7, 1): return "建党节"
        case (8, 1): return "建军节"
        case (9, 10): return "教师节"
        case (10, 1): return "国庆节"
        case (12, 25): return "圣诞节"
        default: return nil
        }
    }
    
    private func getSolarTerm(month: Int, day: Int) -> String? {
        let solarTerms: [(month: Int, day: Int, term: String)] = [
            (1, 6, "小寒"), (1, 20, "大寒"),
            (2, 4, "立春"), (2, 19, "雨水"),
            (3, 6, "惊蛰"), (3, 21, "春分"),
            (4, 5, "清明"), (4, 20, "谷雨"),
            (5, 6, "立夏"), (5, 21, "小满"),
            (6, 6, "芒种"), (6, 22, "夏至"),
            (7, 7, "小暑"), (7, 23, "大暑"),
            (8, 8, "立秋"), (8, 23, "处暑"),
            (9, 8, "白露"), (9, 23, "秋分"),
            (10, 8, "寒露"), (10, 24, "霜降"),
            (11, 8, "立冬"), (11, 22, "小雪"),
            (12, 7, "大雪"), (12, 22, "冬至")
        ]
        
        return solarTerms.first { $0.month == month && abs($0.day - day) <= 1 }?.term
    }
    
    private func generateZodiac(for year: Int) -> String {
        let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        return zodiacs[(year - 1900) % 12] + "年"
    }
    
    private func generateGanZhi(for date: Date) -> String {
        let gan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
        let zhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
        
        let year = calendar.component(.year, from: date)
        let ganIndex = (year - 4) % 10
        let zhiIndex = (year - 4) % 12
        
        return gan[ganIndex] + zhi[zhiIndex] + "年"
    }
    
    private func generateLunarDate(for date: Date) -> String {
        // 简化版农历日期生成
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let lunarMonths = ["正月", "二月", "三月", "四月", "五月", "六月",
                          "七月", "八月", "九月", "十月", "冬月", "腊月"]
        let lunarDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        
        return lunarMonths[(month - 1) % 12] + lunarDays[(day - 1) % 30]
    }
    
    private func generateMotivation(for day: Int) -> String {
        let motivations = [
            "每一天的努力，都是为了更好的明天。",
            "坚持的昨天叫立足，坚持的今天叫进取，坚持的明天叫成功。",
            "努力是为了更好的选择，或者是为了自己能自由选择。",
            "不是每个人都能成为自己想要的样子，但每个人都可以努力成为自己想要的样子。",
            "生活总是让我们遍体鳞伤，但到后来，那些受伤的地方一定会变成我们最强壮的地方。",
            "你要做的就是别人换不掉的，那你做不到怪谁，就是你自己没用！",
            "天塌下来，有个高的人帮你扛着，可是你能保证，天塌下来的时候，个儿高的人没在弯腰吗？",
            "人生就像一杯茶，不会苦一辈子，但总会苦一阵子。",
            "世界上只有想不通的人，没有走不通的路。",
            "成功不是将来才有的，而是从决定去做的那一刻起，持续累积而成。"
        ]
        
        return motivations[day % motivations.count]
    }
    
    private func generateSuitableAndAvoid(for date: Date) -> (suitable: [String], avoid: [String]) {
        let day = calendar.component(.day, from: date)
        
        let allSuitable = ["祭祀", "祈福", "出行", "嫁娶", "安床", "作灶", "修造", "动土", "栽种", "纳畜", "牧养", "安葬", "立碑", "修坟", "启攒", "移徙", "入宅", "安香", "裁衣", "冠笄", "入学", "求医", "治病"]
        let allAvoid = ["开市", "立券", "纳财", "分居", "开仓", "出货财", "启攒", "安葬", "伐木", "作梁", "行丧", "断蚁", "归岫", "筑堤", "放水", "开渠", "造船", "服药", "求医", "治病", "针灸", "出行"]
        
        let suitableCount = min(6, allSuitable.count)
        let avoidCount = min(6, allAvoid.count)
        
        let suitableStart = day % (allSuitable.count - suitableCount)
        let avoidStart = day % (allAvoid.count - avoidCount)
        
        let suitable = Array(allSuitable[suitableStart..<suitableStart + suitableCount])
        let avoid = Array(allAvoid[avoidStart..<avoidStart + avoidCount])
        
        return (suitable, avoid)
    }
}