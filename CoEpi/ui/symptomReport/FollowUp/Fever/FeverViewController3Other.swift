import UIKit

class FeverViewController3Other: UIViewController {
    private let viewModel: FeverViewModel3Other
    //text input
    @IBOutlet weak var textInput: UITextField!
    
    //button actions
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: FeverViewModel3Other) {
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
