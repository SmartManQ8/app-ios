import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController{

    private let viewModel: HomeViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()

    //private var dataSource = HomeListDataSource()

    
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
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 120.0
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        Observable.just(["Health Quiz", "Contact Alerts", (getVersionNumber() + " " + getBuildNumber())])
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element)"
                cell.textLabel?.font = .systemFont(ofSize: 14)
                cell.backgroundColor = .clear
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                return cell
            }
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: {indexPath in
                if indexPath[1] == 0{
                    self.viewModel.quizTapped()
                }
                else if indexPath[1] == 1{
                    self.viewModel.seeAlertsTapped()
                }
                else if indexPath[1] == 2{
                    self.viewModel.debugTapped()
                }
                else{
                    print ("Invalid Selection")
                }
            })
            .disposed(by: disposeBag)
    }
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
