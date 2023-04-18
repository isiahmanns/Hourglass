import SwiftUI

struct ContentView: View {
    let viewModel: ViewModel

    var body: some View {
        ZStack {
            AlertView(viewModel: viewModel)

            VStack(alignment: .center, spacing: 18.0) {
                Logo(size: 40)

                TimerGrid(viewModel: viewModel)

                SettingsMenu(viewModel: viewModel)
            }
            .fixedSize()
            .padding([.top, .bottom], 40)
            .padding([.leading, .trailing], 50)
            .background(Color.background)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ViewModel(dataManager: DataManager.shared,
                                  timerManager: TimerManager.shared,
                                  userNotificationManager: UserNotificationManager.shared,
                                  settingsManager: SettingsManager.shared,
                                  windowCoordinator: NSApplication.shared.delegate as! WindowCoordinator)
        ContentView(viewModel: viewModel)
            .font(Font.poppins)
    }
}
