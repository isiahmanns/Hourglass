import SwiftUI

struct Logo: View {
    let size: Double

    var body: some View {
        Image("hourglassLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityIdentifier("hourglass-logo")
    }
}
