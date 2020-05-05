import UIKit

class FeverViewController3: UIViewController {
    private let viewModel: FeverViewModel3
    
    @IBAction func mouthButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func earButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func armpitButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func otherButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: FeverViewModel3) {
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
