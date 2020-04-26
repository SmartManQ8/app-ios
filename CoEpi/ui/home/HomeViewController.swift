import UIKit

class HomeViewController: UIViewController{

    private let viewModel: HomeViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
        //TODO
        //viewModel.quizTapped()
        //viewModel.seeAlertsTapped()
        //viewModel.debugTapped()

    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        self.title = self.viewModel.title
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: Fonts.robotoRegular]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func share(sender: UIView) {
        Sharer().share(viewController: self, sourceView: sender)
    }
    
    @objc func info(sender: UIView) {
        viewModel.onboardingTapped()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let share = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(sender:)))
        share.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = share
       
        let info = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(info(sender:)))
        info.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = info

    }
    
    private func getVersionNumber() -> String{
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
         else{
            fatalError("Failed to read bundle version")
        }
        print("Version : \(version)");
        return "Version: \(version)"
    }
    private func getBuildNumber() -> String {
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("Failed to read build number")
        }
        print("Build : \(build)")
        return "Build: \(build)"
    }
}
