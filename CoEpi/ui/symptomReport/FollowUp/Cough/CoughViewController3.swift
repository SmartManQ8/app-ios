import UIKit

class CoughViewController3: UIViewController {
    private let viewModel: CoughViewModel3
    
    //action buttons
    @IBAction func betterButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func worseButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func sameButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: CoughViewModel3) {
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
