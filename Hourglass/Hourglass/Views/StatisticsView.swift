import Charts
import SwiftUI

struct StatisticsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.start, order: .forward)])
    private var timeBlocks: FetchedResults<TimeBlock>

    @State private var hoveredChunk: TimeBlock.Chunk?

    let frame = (height: 400.0, width: 700.0)
    let daysPerFrame = 14

    var body: some View {
        let timeChunks: [TimeBlock.Chunk] = timeBlocks.flatMap(\.chunks)
        // TODO: - Write snapshot tests using test data sets
        //let timeChunks = [TimeBlock.Chunk]()
        //let timeChunks = TestData.timeChunks
        //let timeChunks = Array(TestData.timeChunks.prefix(25))
        //let timeChunks: [TimeBlock.Chunk] = TestData.timeBlocks.flatMap(\.chunks)

        if timeChunks.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.background)
                Text(Copy.emptyState)
                    .multilineTextAlignment(.center)
            }
            .frame(width: frame.width, height: frame.height)
        } else {
            let timeChunks = timeChunks.padIfNeeded()

            ScrollView(.vertical, showsIndicators: true) {
                Chart {
                    // MARK: - Bar Marks
                    ForEach(timeChunks) { chunk in
                        BarMark(xStart: .value("Start", chunk.startSeconds),
                                xEnd: .value("End", chunk.endSeconds),
                                y: .value("Day", chunk.date),
                                height: .fixed(14))
                        .foregroundStyle(by: .value("Category", chunk.category.asString))
                    }

                    // MARK: - Annotation
                    if let hoveredChunk {
                        let (annotationPos, annotationAlign) = getAnnotationPlacement(for: hoveredChunk, from: timeChunks)
                        let startTimeStamp = getTimeStamp(for: hoveredChunk.startSeconds)
                        let endTimeStamp = getTimeStamp(for: hoveredChunk.endSeconds)
                        let (focusMinutes, restMinutes) = getAggregateData(for: hoveredChunk.date, from: timeChunks)

                        RectangleMark(xStart: .value("Start", hoveredChunk.startSeconds),
                                      xEnd: .value("End", hoveredChunk.endSeconds),
                                      y: .value("Day", hoveredChunk.date),
                                      height: 14)
                        .cornerRadius(2)
                        .annotation(position: annotationPos,
                                    alignment: annotationAlign,
                                    spacing: 3) {
                            VStack(alignment: .leading) {
                                Text("\(hoveredChunk.category.asString) Time Block")
                                    .fontWeight(.semibold)
                                Text("Start: \(startTimeStamp)")
                                Text("End: \(endTimeStamp)")
                                Divider()
                                Text("Aggregate for Day")
                                    .fontWeight(.semibold)
                                Text("Focus time: \(focusMinutes)m")
                                Text("Rest time: \(restMinutes)m")
                            }
                            .font(.system(.footnote))
                            .padding(10)
                            .background(Color(white: 0.2))
                            .foregroundColor(Color(white: 0.8))
                            .cornerRadius(10)
                        }
                    }
                }

                // MARK: - Legend
                .chartForegroundStyleScale([
                    "Focus": Color.accent,
                    "Rest": Color.onBackgroundSecondary
                ])
                .chartLegend(.visible)
                .chartLegend(position: .top, spacing: -12)

                // MARK: - Y Axis
                .chartYAxisLabel("Day", position: .topTrailing)
                .chartYAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday().month().day())
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYAxis(.visible)
                /**
                 Note: Reverse domain so as user scrolls down, they scroll back in time.
                 Padding the data with an extra day with empty time span to override hiding y axis labels for data sets spanning single day.
                 This call makes Previews crash.
                 */
                .chartYScale(domain: .automatic(reversed: true))

                // MARK: - X Axis
                .chartXAxisLabel("Time", position: .top, alignment: .center)
                .chartXScale(domain: [0, 24 * 3600])
                .chartXAxis {
                    AxisMarks(values: (0..<25).map { 3600 * $0 }) {
                        AxisGridLine()
                    }

                    let hoursBy3 = stride(from: 0, through: 25, by: 3).map { 3600 * $0 }
                    AxisMarks(preset: .aligned, position: .top, values: hoursBy3) { value in
                        if let valueInt = value.as(Int.self) {
                            let hour = valueInt / 3600
                            switch hour {
                            case 0:
                                AxisValueLabel("12am")
                            case 12:
                                AxisValueLabel("12pm")
                            case 24:
                                AxisValueLabel("")
                            default:
                                AxisValueLabel(String(hour % 12))
                            }
                        }

                        AxisTick()
                    }
                }

                // MARK: - Plot area
                .chartPlotStyle { plotContent in
                    let daySpanCount = timeChunks.daySpanCount()
                    let plotHeight = frame.height * (Double(daySpanCount) / Double(daysPerFrame))

                    plotContent
                        .frame(width: frame.width, height: plotHeight)
                }

                // MARK: - Chart Overlay
                .chartOverlay { chartProxy in
                    GeometryReader { geoProxy in
                        Color.clear
                            .onContinuousHover { hoverPhase in
                                switch hoverPhase {
                                case .active(let hoverLocation):
                                    let origin = geoProxy[chartProxy.plotAreaFrame].origin
                                    let location = CGPoint(x: hoverLocation.x - origin.x,
                                                           y: hoverLocation.y - origin.y - 14)

                                    if let date = chartProxy.value(atY: location.y, as: Date.self),
                                       timeChunks.contains(date: date) {
                                        if let secondOfDay = chartProxy.value(atX: location.x, as: Int.self),
                                           let chunk = timeChunks.firstWhereContains(secondOfDay: secondOfDay, for: date) {
                                            // print("second of day", secondOfDay, "date", date)
                                            if hoveredChunk != chunk {
                                                hoveredChunk = chunk
                                            }
                                        } else {
                                            hoveredChunk = nil
                                        }
                                    } else {
                                        hoveredChunk = nil
                                    }
                                case .ended:
                                    hoveredChunk = nil
                                }
                            }
                    }
                }

                // MARK: - Chart Padding
                .padding(20)
                .padding([.leading], 56)
            } // ScrollView
            .frame(minHeight: frame.height)
        }
    }

    private func getAggregateData(for date: Date, from chunks: [TimeBlock.Chunk]) -> (focus: Int, rest: Int) {
        let chunksForDay = chunks.filter { $0.date == date }

        let sumMinutes = { (partialResult: Int, chunk: TimeBlock.Chunk) -> Int in
            let totalMinutes = (chunk.endSeconds - chunk.startSeconds) / 60
            return partialResult + totalMinutes
        }

        let focusMinutes = chunksForDay
            .filter { $0.category == .focus }
            .reduce(0, sumMinutes)

        let restMinutes = chunksForDay
            .filter { $0.category == .rest }
            .reduce(0, sumMinutes)

        return (focusMinutes, restMinutes)
    }

    private func getTimeStamp(for secondOfDay: Int) -> String {
        let (hour24, minutes) = secondOfDay.asSeconds.toHoursMinutes
        let amPM = 12 <= hour24 && hour24 < 24 ? "pm" : "am"

        let remainder = hour24 % 12
        let hour12 = remainder == 0 ? 12 : remainder

        return String(format: "\(hour12):%02d\(amPM)", minutes)
    }

    private func getAnnotationPlacement(for chunk: TimeBlock.Chunk,
                                        from chunks: [TimeBlock.Chunk]) -> (AnnotationPosition, Alignment) {
        var position: AnnotationPosition = .bottom
        var alignment: Alignment = .leading


        if chunk.startSeconds > 3600 * 20 {
            alignment = .trailing
        }

        let chunksByDate = Dictionary(grouping: chunks, by: \.date)
        let sortedDates = chunksByDate.keys.sorted()
        if sortedDates.prefix(5).contains(chunk.date) {
            position = .top
        }

        return (position, alignment)
    }
}

extension StatisticsView {
    enum Copy {
        static let emptyState = "There is no data to show.\nRevisit after completing a few time blocks."
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

extension TimeBlock {
    struct Chunk: Identifiable, Comparable {
        static func < (lhs: TimeBlock.Chunk, rhs: TimeBlock.Chunk) -> Bool {
            lhs.date < rhs.date
        }

        static func == (lhs: TimeBlock.Chunk, rhs: TimeBlock.Chunk) -> Bool {
            lhs.date == rhs.date &&
            lhs.startSeconds == rhs.startSeconds &&
            lhs.endSeconds == rhs.endSeconds &&
            lhs.category == rhs.category
        }

        let id = UUID()

        /// Date (ymd) without timestamp, used to bucket all chunks belonging to the same day.
        let date: Date

        let startSeconds: Int
        let endSeconds: Int
        let category: Timer.Category
    }
}

private extension Array<TimeBlock.Chunk> {
    /// Pad data so that there will be x days minimum on y axis (enough chart area to show annotation)
    func padIfNeeded() -> Self {
        let sortedCopy = sorted()

        let padCount = 10 - daySpanCount()
        if padCount > 0 {
            let padChunks = (1...padCount).map { count in
                let precedingDay = sortedCopy.first!.date.addingTimeInterval(Double(count) * -24 * 3600)
                return TimeBlock.Chunk(date: precedingDay, startSeconds: 0, endSeconds: 0, category: .focus)
            }

            return padChunks + sortedCopy
        }

        return sortedCopy
    }

    func contains(date : Date) -> Bool {
        contains(where: { $0.date == date.ymdDate } )
    }

    func firstWhereContains(secondOfDay: Int, for date: Date) -> TimeBlock.Chunk? {
        filter { $0.date == date.ymdDate }
            .first(where: { $0.startSeconds <= secondOfDay && secondOfDay <= $0.endSeconds })
    }

    func daySpanCount() -> Int {
        let groupedByDate = Dictionary(grouping: self, by: \.date)
        let dates = groupedByDate.keys.sorted()
        return Calendar.current.dateComponents([.day], from: dates.first!, to: dates.last!).day! + 1
    }
}

private extension TimeBlock {
    var startDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start!)
    }

    var endDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: end!)
    }

    // TODO: - Test this with Core Data
    var doesIncludeNextDay: Bool {
        startDate.day! < endDate.day!
    }

    var chunks: [TimeBlock.Chunk] {
        if doesIncludeNextDay {
            let lastSecondOfDay = 24 * 3600
            let firstSecondOfDay = 0

            return [
                Chunk(date: startDate.ymdDate,
                      startSeconds: startDate.secondOfDay,
                      endSeconds: lastSecondOfDay,
                      category: Timer.Category(rawValue: Int(category))!),
                Chunk(date: endDate.ymdDate,
                      startSeconds: firstSecondOfDay,
                      endSeconds: endDate.secondOfDay,
                      category: Timer.Category(rawValue: Int(category))!)
            ]
        }

        return [Chunk(date: endDate.ymdDate,
                      startSeconds: startDate.secondOfDay,
                      endSeconds: endDate.secondOfDay,
                      category: Timer.Category(rawValue: Int(category))!)]
    }
}

extension DateComponents {
    var ymdDate: Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    var secondOfDay: Int {
        return (hour! * 3600) + (minute! * 60) + second!
    }
}

private extension Date {
    var ymdDate: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
