protocol HomeViewModelDelegate {
    func debugTapped()
    func checkInTapped()
    func seeAlertsTapped()
    func onboardingTapped()
}

class HomeViewModel  {
    var delegate: HomeViewModelDelegate?
    
    let title = "CoEpi"

    func debugTapped() {
        delegate?.debugTapped()
    }
    
    func quizTapped() {
        delegate?.checkInTapped()
    }
    
    func seeAlertsTapped() {
        delegate?.seeAlertsTapped()
    }
    
    func onboardingTapped() {
        delegate?.onboardingTapped()
    
}
}
