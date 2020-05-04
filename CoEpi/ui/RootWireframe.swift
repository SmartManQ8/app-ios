import Dip
import UIKit
import RxSwift

class RootWireFrame {
    private let container: DependencyContainer

    private var homeViewController: HomeViewController?
    private var onboardingWireframe: OnboardingWireframe?
    private var rootNavigationController = UINavigationController()

    private let disposeBag = DisposeBag()

    init(container: DependencyContainer, window: UIWindow) {
        self.container = container

        initNav()

        let homeViewModel: HomeViewModel = try! container.resolve()

        let homeViewController = HomeViewController(viewModel: homeViewModel)
        rootNavigationController.setViewControllers([homeViewController], animated: false)
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()

        self.homeViewController = homeViewController

        let keyValueStore: KeyValueStore = try! container.resolve()
        showOnboardingIfNeeded(keyValueStore: keyValueStore, parent: homeViewController)
    }

    private func initNav() {
        let rootNav: RootNav = try! container.resolve()

        rootNav.navigationCommands.subscribe(onNext: { [weak self] command in
            self?.onNavigationCommand(navCommand: command)
        }).disposed(by: disposeBag)
    }

    private func showOnboardingIfNeeded(keyValueStore: KeyValueStore, parent: UIViewController) {
        guard !keyValueStore.getBool(key: .seenOnboarding) else {
            return
        }

        let wireFrame: OnboardingWireframe = try! container.resolve()
        wireFrame.showIfNeeded(parent: parent)
        onboardingWireframe = wireFrame
        keyValueStore.putBool(key: .seenOnboarding, value: true)
    }

    private func onNavigationCommand(navCommand: RootNavCommand) {
        switch navCommand {
        case .to(let destination): navigate(to: destination)
        case .back: rootNavigationController.popViewController(animated: true)
        }
    }

    private func navigate(to: RootNavDestination) {
        switch to {
        case .quiz: showQuiz()
        case .debug: showDebug()
        case .alerts: showAlerts()
        case .thankYou: showThankYou()
        case .breathless: showBreathless()
        case .cough1: showCough1()
        case .cough2: showCough2()
        case .cough3: showCough3()
        case .fever1: showFever1()
        case .fever2: showFever2()
        case .fever3: showFever3()
        case .fever4: showFever4()
        case .symptomReport: showSymptomReport()
        }
    }

    private func showDebug() {
        let debugViewModel: DebugViewModel = try! container.resolve()
        let debugViewController = DebugViewController(viewModel: debugViewModel)
        rootNavigationController.pushViewController(debugViewController, animated: true)
    }


    private func showQuiz() {
        let viewModel: HealthQuizViewModel = try! container.resolve()
        let quizViewController = HealthQuizViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(quizViewController, animated: true)
    }

    private func showAlerts() {
        let viewModel: AlertsViewModel = try! container.resolve()
        let alertsViewController = AlertsViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(alertsViewController, animated: true)
    }
    
    private func showThankYou() {
        let viewModel: ThankYouViewModel = try! container.resolve()
        let thankYouViewController = ThankYouViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(thankYouViewController, animated: true)
    }
    
    private func showBreathless() {
        let viewModel: BreathlessViewModel = try! container.resolve()
        let breathlessViewController = BreathlessViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(breathlessViewController, animated: true)
    }
    
    private func showCough1() {
        let viewModel: CoughViewModel1 = try! container.resolve()
        let coughViewController1 = CoughViewController1(viewModel: viewModel)
        rootNavigationController.pushViewController(coughViewController1, animated: true)
    }

    private func showCough2() {
        let viewModel: CoughViewModel2 = try! container.resolve()
        let coughViewController2 = CoughViewController2(viewModel: viewModel)
        rootNavigationController.pushViewController(coughViewController2, animated: true)
    }
    
    private func showCough3() {
        let viewModel: CoughViewModel3 = try! container.resolve()
        let coughViewController3 = CoughViewController3(viewModel: viewModel)
        rootNavigationController.pushViewController(coughViewController3, animated: true)
    }
    
    private func showFever1() {
        let viewModel: FeverViewModel1 = try! container.resolve()
        let feverViewController1 = FeverViewController1(viewModel: viewModel)
        rootNavigationController.pushViewController(feverViewController1, animated: true)
    }
    
    private func showFever2() {
        let viewModel: FeverViewModel2 = try! container.resolve()
        let feverViewController2 = FeverViewController2(viewModel: viewModel)
        rootNavigationController.pushViewController(feverViewController2, animated: true)
    }
    
    private func showFever3() {
        let viewModel: FeverViewModel3 = try! container.resolve()
        let feverViewController3 = FeverViewController3(viewModel: viewModel)
        rootNavigationController.pushViewController(feverViewController3, animated: true)
    }
    
    private func showFever4() {
        let viewModel: FeverViewModel4 = try! container.resolve()
        let feverViewController4 = FeverViewController4(viewModel: viewModel)
        rootNavigationController.pushViewController(feverViewController4, animated: true)
    }
    
    private func showSymptomReport() {
        let viewModel: SymptomReportViewModel = try! container.resolve()
        let symptomReportViewController = SymptomReportViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(symptomReportViewController, animated: true)
    }
    
}
