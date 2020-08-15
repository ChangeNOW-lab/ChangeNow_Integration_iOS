//
//  Date+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 14/07/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

class Calendars {

    static func updateLocalizableCalendars(with locale: Locale) {
        localTimeZoneCalendar.locale = locale
        calendarWithDefaultFirstWeekDay.locale = locale
        localTimeZoneCalendar.firstWeekday = locale.calendar.firstWeekday
        calendarWithDefaultFirstWeekDay.firstWeekday = locale.calendar.firstWeekday
    }

    static var calendarWithDefaultFirstWeekDay: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .GMT
        return calendar
    }()

    static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .UTC
        calendar.firstWeekday = 2
        return calendar
    }()

    static var localTimeZoneCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        calendar.firstWeekday = 2
        return calendar
    }()
}

extension Date {

    private static let componentFlags: Set<Calendar.Component> = Set([.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal])

    static var localTimeZoneDateTomorrow: Date {
        return localTimeZoneDateToday.dateByAdding(days: 1)
    }

    static var utcDateToday: Date {
        let calendar = Calendars.utcCalendar
        let components = calendar.dateComponents([.day, .month, .year], from: Date())

        // Force unwrapped because here we know that creating new date from current date should be successfull
        return calendar.date(from: components)!
    }

    static var localTimeZoneDateToday: Date {
        let calendar = Calendars.localTimeZoneCalendar
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        let date = calendar.date(from: DateComponents(timeZone: .GMT,
                                                      year: components.year,
                                                      month: components.month,
                                                      day: components.day)
        )
        return date!
    }

    var day: Int {
        let components = Calendars.localTimeZoneCalendar.dateComponents(Date.componentFlags, from: self)
        return components.day!
    }

    var month: Int {
        let components = Calendars.localTimeZoneCalendar.dateComponents(Date.componentFlags, from: self)
        return components.month!
    }

    var isToday: Bool {
        return isEqualToDateIgnoringTime(Date.localTimeZoneDateToday)
    }

    var isTomorrow: Bool {
        return isEqualToDateIgnoringTime(Date.localTimeZoneDateTomorrow)
    }

    var timeIntervalSinceNowInMS: TimeInterval {
        return abs(timeIntervalSinceNow) * 1_000
    }

    // MARK: Date operations

    func dateByAdding(days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days

        return Calendars.localTimeZoneCalendar.date(byAdding: dateComponents, to: self)!
    }

    func dateByAdding(months: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = months

        return Calendars.localTimeZoneCalendar.date(byAdding: dateComponents, to: self)!
    }

    func dateByAdding(years: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = years

        return Calendars.localTimeZoneCalendar.date(byAdding: dateComponents, to: self)!
    }

    func dateByAdding(hours: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.hour = hours

        return Calendars.localTimeZoneCalendar.date(byAdding: dateComponents, to: self)!
    }

    func dateBySetting(hours: Int) -> Date {
        return Calendars.localTimeZoneCalendar.date(bySetting: .hour, value: hours, of: self)!
    }

    // MARK: Comparing

    static func dateComponentsBetweenDate(_ fromDate: Date, andDate toDate: Date) -> DateComponents {
        let calendar = Calendars.localTimeZoneCalendar
        return calendar.dateComponents(Set([.year, .day, .weekOfYear]), from: fromDate, to: toDate)
    }

    static func daysBetweenDate(_ fromDate: Date, andDate toDate: Date) -> Int {
        let calendar = Calendars.localTimeZoneCalendar

        let processingFromDate = calendar.startOfDay(for: fromDate)
        let processingToDate = calendar.startOfDay(for: toDate)
        let components = calendar.dateComponents(Set([.day]), from: processingFromDate, to: processingToDate)
        return components.day!
    }

    static func minutesBetweenDate(_ fromDate: Date, andDate toDate: Date) -> Int {
        let calendar = Calendars.localTimeZoneCalendar
        let components = calendar.dateComponents(Set([.minute]), from: fromDate, to: toDate)
        return components.minute!
    }

    func isEqualToDateIgnoringTime(_ anotherDate: Date) -> Bool {
        let components = Calendar.current.dateComponents(Date.componentFlags, from: self)
        let anotherDateComponents = Calendar.current.dateComponents(Date.componentFlags, from: anotherDate)

        return components.year == anotherDateComponents.year &&
            components.month == anotherDateComponents.month &&
            components.day == anotherDateComponents.day
    }

    func earlierThanDate(_ anotherDate: Date) -> Bool {

        return self < anotherDate
    }

    func equalOrEarlierThanDate(_ anotherDate: Date) -> Bool {
        return self <= anotherDate
    }

    func isDateInRange(startDate: Date, endDate: Date) -> Bool {
        return self.compare(startDate) == .orderedDescending && self.compare(endDate) == .orderedAscending
    }

    func isNextDateForDate(_ date: Date) -> Bool {
        return self.dateByAdding(days: 1).isEqualToDateIgnoringTime(date)
    }

    var dateComponents: DateComponents {
        return Calendars.localTimeZoneCalendar.dateComponents(Set([.hour, .day, .month, .year]), from: self)
    }

    static func dateFromComponents(_ components: DateComponents) -> Date? {
        return Calendars.localTimeZoneCalendar.date(from: components)
    }

    static func localTimeZoneDateFrom(_ date: Date) -> Date {
        let localTimeZoneCalendar = Calendars.localTimeZoneCalendar
        let localTimeZoneDateComponents = localTimeZoneCalendar.dateComponents(in: .GMT, from: date)
        let localTimeZoneDate = localTimeZoneCalendar.date(
            from: DateComponents(timeZone: .GMT,
                                 year: localTimeZoneDateComponents.year,
                                 month: localTimeZoneDateComponents.month,
                                 day: localTimeZoneDateComponents.day)
        )
        return localTimeZoneDate!
    }

    static func date(_ day: Int, month: Int, year: Int) -> Date? {
        let now = Date()
        let calendar = Calendars.localTimeZoneCalendar

        var component = calendar.dateComponents(Set([Calendar.Component.year]), from: now)
        component.year = year
        component.month = 2
        component.day = day + 1

        return calendar.date(from: component)
    }
}
