import Foundation

enum TestData {
    static let timeBlockChunks = [
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
