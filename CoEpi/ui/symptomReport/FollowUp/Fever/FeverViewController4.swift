import UIKit

class FeverViewController4: UIViewController {
    private let viewModel: FeverViewModel4
    
    //numberInput
    @IBOutlet weak var numberInput: UITextField!
    
    //button actions
    @IBAction func unknownButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func scaleButtonAction(_ sender: UIButton) {

    }
    
    
    
    init(viewModel: FeverViewModel4) {
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
