import SwiftUI

struct IAPStoreView: View {
    let iapManager: IAPManager
    @Binding var isPresenting: Bool
    @State private var quantity: Int = 1

    var body: some View {
        VStack (spacing: 14) {
            Text("Support Hourglass").fontWeight(.medium)

            Form {
                Picker("Quantity:", selection: $quantity) {
                    Text("1x").tag(1)
                    Text("3x").tag(3)
                    Text("5x").tag(5)
                }

                let total = Double(quantity) * 4.99
                let formattedTotal = total.formatted(.currency(code: "USD"))
                HStack {
                    Button("Tip \(formattedTotal)") {
                        defer { isPresenting.toggle() }

                        // TODO: - make purchase
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.Hourglass.accent)

                    Button("Close", role: .cancel) {
                        isPresenting.toggle()
                    }
                }
            }
            .pickerStyle(.segmented)
        }
        .font(.system(.body))
        .frame(width: 220)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}

struct IAPStoreView_Previews: PreviewProvider {
    static var previews: some View {
        IAPStoreView(iapManager: IAPManager.shared,
                     isPresenting: .constant(true))
    }
}
