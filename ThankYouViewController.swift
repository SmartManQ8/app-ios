import UIKit

class ThankYouViewController: UIViewController {
    private let viewModel: ThankYouViewModel
    
    @IBAction func moreButtonAction(_ sender: UIButton) {

     }
    
    @IBAction func viewExposuresButtonAction(_ sender: UIButton) {
        
     }
    
    @IBAction func homeButtonAction(_ sender: UIButton) {

     }
    
    
    init(viewModel: ThankYouViewModel) {
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
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_purple.png")!)
     }
}
