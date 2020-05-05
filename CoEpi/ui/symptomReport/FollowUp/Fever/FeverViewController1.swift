import UIKit

class FeverViewController1: UIViewController {
    private let viewModel: FeverViewModel1
    
    //days input
    @IBOutlet weak var dasyInput: UITextField!
    
    //action buttons
    @IBAction func unknownButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: FeverViewModel1) {
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
