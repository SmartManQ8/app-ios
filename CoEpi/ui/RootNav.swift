import UIKit
import RxSwift
import RxCocoa

class RootNav {
    let navigationCommands: PublishRelay<RootNavCommand> = PublishRelay()

    func navigate(command: RootNavCommand) {
        navigationCommands.accept(command)
    }
}

enum RootNavCommand {
    case to(destination: RootNavDestination)
    case back
}

enum RootNavDestination {
    case quiz
    case debug
    case alerts
    case thankYou
    case breathless
    case cough1
    case cough2
    case cough3
    case fever1
    case fever2
    case fever3
    case fever4
    case symptomReport
}

