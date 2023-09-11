import SwiftUI

struct ContentView: View {
    let viewModel: ViewModel
    let settingsManager: SettingsManager

    var body: some View {
        ZStack {
            AlertView(viewModel: viewModel, settingsManager: settingsManager)

            VStack(alignment: .center, spacing: 18.0) {
                HStack {
                    Logo(size: 40)
                    Spacer()
                    SettingsMenu(viewModel: viewModel)
                }

                HStack {
                    ForEach(viewModel.timerModels.values.sortBySize()) { model in
                        TimerButton(model: model) {
                            viewModel.didTapTimer(from: model)
                        }
                    }
                }
            }
            .fixedSize()
            .padding([.top, .bottom], 34)
            .padding([.leading, .trailing], 50)
            .background(Color.Hourglass.background)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ViewModel(analyticsManager: AnalyticsManager.shared,
                                  dataManager: DataManager.shared,
                                  settingsManager: SettingsManager.shared,
                                  timerManager: TimerManager.shared,
                                  userNotificationManager: UserNotificationManager.shared)
        let settingsManager = SettingsManager.shared
        ContentView(viewModel: viewModel, settingsManager: settingsManager)
            .font(Font.poppins)
    }
}
