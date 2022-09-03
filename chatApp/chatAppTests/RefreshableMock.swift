import Foundation
@testable import chatApp

class RefreshableMock: IRefreshable {

    var invokedRefresh = false
    var invokedRefreshCount = 0

    func refresh() {
        invokedRefresh = true
        invokedRefreshCount += 1
    }
}
