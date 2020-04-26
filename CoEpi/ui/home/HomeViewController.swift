import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController{

    private let viewModel: HomeViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()

    private var dataSource = HomeListDataSource()
    
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
        
        
        
        tableView.register(cellClass: UITableViewCell.self)

        viewModel.homeEntries
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

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


private class HomeListDataSource: NSObject, RxTableViewDataSourceType {
    private var homeEntries: [HomeEntryViewData] = []

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[HomeEntryViewData]>) {
        if case let .next(homeEntries) = observedEvent {
            self.homeEntries = homeEntries
            tableView.reloadData()
        }
    }
}


extension HomeListDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellClass: UITableViewCell.self, forIndexPath: indexPath)
        let label = cell.textLabel
        label?.font = .systemFont(ofSize: 14)

        switch homeEntries[indexPath.row] {
        case .Header(let text):
            label?.text = text
            cell.backgroundColor = .lightGray
        return cell
    }
}
}
