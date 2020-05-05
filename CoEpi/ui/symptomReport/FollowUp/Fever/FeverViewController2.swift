import UIKit

class FeverViewController2: UIViewController {
    private let viewModel: FeverViewModel2
    
    //button actions
    @IBAction func yesButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func noButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: FeverViewModel2) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        self.title = self.viewModel.title
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: Fonts.robotoRegular]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)
     }
}
