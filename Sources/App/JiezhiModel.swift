import Foundation

@MainActor
final class JiezhiModel: ObservableObject {
    @Published private(set) var allowsPointerAcrossDevices = true
    @Published private(set) var isWorking = true
    @Published private(set) var errorMessage: String?

    private let commands = JiezhiCommandController()
    private var confirmedDisabled: Bool?
    private var desiredDisabled: Bool?
    private var operationInFlight = false

    init() {
        commands.readDisabled { [weak self] disabled in
            guard let self else { return }
            self.confirmedDisabled = disabled
            if self.desiredDisabled == nil {
                self.desiredDisabled = disabled
                self.allowsPointerAcrossDevices = !disabled
            }
            self.isWorking = false
            self.beginNextOperationIfNeeded()
        }
    }

    func setAllowsPointerAcrossDevices(_ allowed: Bool) {
        desiredDisabled = !allowed
        allowsPointerAcrossDevices = allowed
        errorMessage = nil
        beginNextOperationIfNeeded()
    }

    func toggle() {
        setAllowsPointerAcrossDevices(!allowsPointerAcrossDevices)
    }

    private func beginNextOperationIfNeeded() {
        guard !operationInFlight,
              let confirmedDisabled,
              let desiredDisabled,
              confirmedDisabled != desiredDisabled else {
            return
        }

        operationInFlight = true
        isWorking = true
        commands.setDisabled(desiredDisabled) { [weak self] result in
            guard let self else { return }
            self.operationInFlight = false
            switch result {
            case .success(let disabled):
                self.confirmedDisabled = disabled
                self.isWorking = false
                self.beginNextOperationIfNeeded()
            case .failure(let error):
                self.desiredDisabled = self.confirmedDisabled
                self.allowsPointerAcrossDevices = !(self.confirmedDisabled ?? false)
                self.isWorking = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
