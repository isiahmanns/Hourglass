import StoreKit

class IAPManager {
    static let shared = IAPManager()

    private var updates: Task<Void, Never>

    private init() {
        self.updates = Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                guard case .verified(let transaction) = verificationResult else { return }
                await transaction.finish()
            }
        }
    }

    deinit {
        updates.cancel()
    }

    func products() async throws -> [Product] {
        let productIds = ProductId.allCases.map(\.rawValue)
        return try await Product.products(for: productIds)
    }

    func purchase(product: Product, quantity: Int) async throws -> Product.PurchaseResult {
        return try await product.purchase(options: [.quantity(quantity)])
    }
}

extension IAPManager {
    enum ProductId: String, CaseIterable {
        case tip = "consumable.tip"
    }
}
