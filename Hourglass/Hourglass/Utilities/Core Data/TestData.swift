import CoreData
import Foundation

enum TestData {
    private static func createTimeBlock(start: Date, end: Date, category: Timer.Category) -> TimeBlock {
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.timeBlock.rawValue,
                                                in: CoreDataStore.shared.context)
        let timeBlock = NSManagedObject(entity: entity!, insertInto: nil) as! TimeBlock

        timeBlock.category = Int16(category.rawValue)
        timeBlock.start = start
        timeBlock.end = end

        return timeBlock
    }
    
    static let timeBlocks = [
        createTimeBlock(start: Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 21, hour: 0, minute: 42, second: 58))!,
                        end: Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 21, hour: 2, minute: 42, second: 58))!,
                        category: .focus),
        createTimeBlock(start: Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 21, hour: 23, minute: 30, second: 0))!,
                        end: Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 22, hour: 0, minute: 30, second: 0))!,
                        category: .rest),
    ]

    static let timeChunks = [
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 21).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 22).ymdDate, startSeconds: 3000 + 21600, endSeconds: 3900 + 21600, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 22).ymdDate, startSeconds: 5000 + 21600, endSeconds: 6800 + 21600, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 22).ymdDate, startSeconds: 7000 + 21600, endSeconds: 7900 + 21600, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 23).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 24).ymdDate, startSeconds: 3000 + 43200, endSeconds: 3900 + 43200, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 24).ymdDate, startSeconds: 5000 + 43200, endSeconds: 6800 + 43200, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 24).ymdDate, startSeconds: 7000 + 43200, endSeconds: 7900 + 43200, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 25).ymdDate, startSeconds: 23 * 3600, endSeconds: 24 * 3600, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 26).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 27).ymdDate, startSeconds: 3000 + 21600, endSeconds: 3900 + 21600, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 27).ymdDate, startSeconds: 5000 + 21600, endSeconds: 6800 + 21600, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 27).ymdDate, startSeconds: 7000 + 21600, endSeconds: 7900 + 21600, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 28).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 29).ymdDate, startSeconds: 3000 + 43200, endSeconds: 3900 + 43200, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 29).ymdDate, startSeconds: 5000 + 43200, endSeconds: 6800 + 43200, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 29).ymdDate, startSeconds: 7000 + 43200, endSeconds: 7900 + 43200, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 5, day: 30).ymdDate, startSeconds: 23 * 3600, endSeconds: 24 * 3600, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 28).ymdDate, startSeconds: 7000, endSeconds: 7900, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 29).ymdDate, startSeconds: 3000 + 43200, endSeconds: 3900 + 43200, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 29).ymdDate, startSeconds: 5000 + 43200, endSeconds: 6800 + 43200, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 29).ymdDate, startSeconds: 7000 + 43200, endSeconds: 7900 + 43200, category: .focus),

        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 0, endSeconds: 900, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 1000, endSeconds: 2800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 3000, endSeconds: 3900, category: .rest),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 5000, endSeconds: 6800, category: .focus),
        TimeBlock.Chunk(date: DateComponents(year: 2023, month: 6, day: 30).ymdDate, startSeconds: 23 * 3600, endSeconds: 24 * 3600, category: .focus),
    ]
}
