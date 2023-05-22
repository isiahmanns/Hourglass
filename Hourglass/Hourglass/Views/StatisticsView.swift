import Charts
import SwiftUI

// TODO: - Annotation summary
// TODO: - Add state to restrict y axis date domain, try to get pagination or scrolling

struct StatisticsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.end, order: .reverse)])
    private var timeBlocks: FetchedResults<TimeBlock>

    var body: some View {
         //let timeChunks: [TimeBlock.Chunk] = timeBlocks.flatMap(\.chunks)
        let timeChunks = StatisticsView.dummyData

        Chart(timeChunks) { chunk in
            BarMark(xStart: .value("Start", chunk.startSeconds),
                    xEnd: .value("End", chunk.endSeconds),
                    y: .value("Day", chunk.day),
                    height: .fixed(14))
            .foregroundStyle(by: .value("Category", chunk.category.asString))
        }

        // MARK: - Legend
        .chartForegroundStyleScale([
            "Focus": Color.accent,
            "Rest": Color.onBackgroundSecondary
        ])
        .chartLegend(.visible)

        // MARK: - Y Axis
        .chartYAxisLabel("Day", position: .trailing, alignment: .center)
        .chartYAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisValueLabel(format: .dateTime.weekday().month().day())
                AxisGridLine()
                AxisTick()
            }
        }

        // MARK: - X Axis
        .chartYAxis(.visible)
        .chartXAxisLabel("Time", position: .bottom, alignment: .center)
        .chartXScale(domain: [0, 24 * 3600])
        .chartXAxis {
            AxisMarks(values: (0..<25).map { 3600 * $0 }) {
                AxisGridLine()
            }

            AxisMarks(values: stride(from: 0, through: 25, by: 3).map { 3600 * $0 }) { value in
                if let valueInt = value.as(Int.self) {
                    let hour = valueInt / 3600
                    switch hour {
                    case 0:
                        AxisValueLabel("12am")
                    case 12:
                        AxisValueLabel("12pm")
                    default:
                        AxisValueLabel(String(hour % 12))
                    }
                }

                AxisTick()
            }
        }

        // MARK: - Sizing
        .frame(width: 700, height: 300)
        .padding(20)
    }
}

extension TimeBlock {
    struct Chunk: Identifiable {
        let id = UUID()
        let day: Date
        let startSeconds: Int
        let endSeconds: Int
        let category: Timer.Category
    }
}

extension TimeBlock {
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
            let lastSecondOfDay = DateComponents(hour: 23, minute: 59, second: 59).secondOfDay
            let firstSecondOfDay = 0

            return [
                Chunk(day: startDate.ymdDate,
                     startSeconds: startDate.secondOfDay,
                     endSeconds: lastSecondOfDay,
                      category: Timer.Category(rawValue: Int(category))!),
                Chunk(day: endDate.ymdDate,
                     startSeconds: firstSecondOfDay,
                     endSeconds: endDate.secondOfDay,
                     category: Timer.Category(rawValue: Int(category))!)
            ]
        }

        return [Chunk(day: endDate.ymdDate,
                     startSeconds: startDate.secondOfDay,
                     endSeconds: endDate.secondOfDay,
                     category: Timer.Category(rawValue: Int(category))!)]
    }
}

private extension DateComponents {
    var ymdDate: Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    var secondOfDay: Int {
        guard let hour, let minute, let second else { return -1 }
        return (hour * 3600) + (minute * 60) + second
    }
}

extension StatisticsView {
    static let dummyData = [
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 22).ymdDate, startSeconds: 3000 + 21600, endSeconds: 3900 + 21600, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 22).ymdDate, startSeconds: 5000 + 21600, endSeconds: 6800 + 21600, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 22).ymdDate, startSeconds: 7000 + 21600, endSeconds: 7900 + 21600, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),
//
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 24).ymdDate, startSeconds: 3000 + 43200, endSeconds: 3900 + 43200, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 24).ymdDate, startSeconds: 5000 + 43200, endSeconds: 6800 + 43200, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 24).ymdDate, startSeconds: 7000 + 43200, endSeconds: 7900 + 43200, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 23 * 3600, endSeconds: 24 * 3600, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 27).ymdDate, startSeconds: 3000 + 21600, endSeconds: 3900 + 21600, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 27).ymdDate, startSeconds: 5000 + 21600, endSeconds: 6800 + 21600, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 27).ymdDate, startSeconds: 7000 + 21600, endSeconds: 7900 + 21600, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 29).ymdDate, startSeconds: 3000 + 43200, endSeconds: 3900 + 43200, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 29).ymdDate, startSeconds: 5000 + 43200, endSeconds: 6800 + 43200, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 29).ymdDate, startSeconds: 7000 + 43200, endSeconds: 7900 + 43200, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 23 * 3600, endSeconds: 24 * 3600, category: .focus),


        // TODO: - Adding these makes the data window too large. Figure this out!
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 29).ymdDate, startSeconds: 3000 + 43200, endSeconds: 3900 + 43200, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 29).ymdDate, startSeconds: 5000 + 43200, endSeconds: 6800 + 43200, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 29).ymdDate, startSeconds: 7000 + 43200, endSeconds: 7900 + 43200, category: .focus),

        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .rest),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(day: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 23 * 3600, endSeconds: 24 * 3600, category: .focus),
    ]
}
