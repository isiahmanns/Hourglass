import SwiftUI

struct ContentView: View {
    private let viewModel = ViewModel()

    var body: some View {
        ZStack {
            AlertWrapper(viewModel: viewModel)

            VStack(alignment: .center, spacing: 30.0) {
                Logo(size: 40)

                TimerGrid(viewModel: viewModel)

                SettingsMenu(viewModel: viewModel)
            }
            .padding([.top, .bottom], 40)
            .padding([.leading, .trailing], 60)
            .background(Color.background)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .font(Font.poppins)
    }
}
