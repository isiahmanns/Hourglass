import SwiftUI

struct StatisticsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.end, order: .forward)])
    private var fetchRequest: FetchedResults<TimeBlock>


    var body: some View {
        Color.blue
            .frame(width: 400, height: 400)
    }
}
