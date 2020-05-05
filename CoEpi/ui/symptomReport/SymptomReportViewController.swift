import UIKit

class SymptomReportViewController: UIViewController {
    private let viewModel: SymptomReportViewModel
    
    //Button Labels
    @IBOutlet weak var noSymptomsButtonLabel: UIButton!
    @IBOutlet weak var coughButtonLabel: UIButton!
    @IBOutlet weak var breathlessButtonLabel: UIButton!
    @IBOutlet weak var feverButtonLabel: UIButton!
    @IBOutlet weak var acheButtonLabel: UIButton!
    @IBOutlet weak var lossButtonLabel: UIButton!
    @IBOutlet weak var diarrheaButtonLabel: UIButton!
    @IBOutlet weak var noseButtonLabel: UIButton!
    @IBOutlet weak var otherSymptomsButtonLabel: UIButton!
    @IBOutlet weak var submitButtonLabel: UIButton!
    
    //Button Actions
    @IBAction func noSymptomsButtonAction(_ sender: UIButton) {
        if noSymptomsButtonLabel.isSelected == true{
           noSymptomsButtonLabel.isSelected = false
        }else{
            noSymptomsButtonLabel.isSelected = true
        }
    }
    
    @IBAction func coughButtonAction(_ sender: UIButton) {
        if coughButtonLabel.isSelected == true{
           coughButtonLabel.isSelected = false
        }else{
            coughButtonLabel.isSelected = true
        }
    }
    
    @IBAction func breathlessButtonAction(_ sender: UIButton) {
        if breathlessButtonLabel.isSelected == true{
           breathlessButtonLabel.isSelected = false
        }else{
            breathlessButtonLabel.isSelected = true
        }
    }
    
    @IBAction func feverButtonAction(_ sender: UIButton) {
        if feverButtonLabel.isSelected == true{
           feverButtonLabel.isSelected = false
        }else{
            feverButtonLabel.isSelected = true
        }
    }
    
    @IBAction func acheButtonAction(_ sender: UIButton) {
        if acheButtonLabel.isSelected == true{
           acheButtonLabel.isSelected = false
        }else{
            acheButtonLabel.isSelected = true
        }
    }
    
    @IBAction func lossButtonAction(_ sender: UIButton) {
        if lossButtonLabel.isSelected == true{
           lossButtonLabel.isSelected = false
        }else{
            lossButtonLabel.isSelected = true
        }
    }
    
    @IBAction func diarrheaButtonAction(_ sender: UIButton) {
        if diarrheaButtonLabel.isSelected == true{
           diarrheaButtonLabel.isSelected = false
        }else{
            diarrheaButtonLabel.isSelected = true
        }
    }
    
    @IBAction func noseButtonAction(_ sender: UIButton) {
        if noseButtonLabel.isSelected == true{
           noseButtonLabel.isSelected = false
        }else{
            noseButtonLabel.isSelected = true
        }
    }
    
    @IBAction func otherSymptomsButtonAction(_ sender: UIButton) {
        if otherSymptomsButtonLabel.isSelected == true{
           otherSymptomsButtonLabel.isSelected = false
        }else{
            otherSymptomsButtonLabel.isSelected = true
        }
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        
    }
    
    
    init(viewModel: SymptomReportViewModel) {
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
