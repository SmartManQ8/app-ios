import Foundation
import RxSwift
import RxCocoa
import UIKit





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
    
    
    
    
    
    let homeEntries: Driver<[HomeEntryViewData]>

    private let disposeBag = DisposeBag()
    

    init(bleAdapter: BleAdapter, cenKeyDao: CENKeyDao, api: CoEpiApi) {
        let combined = Observable.combineLatest(
            cenKeyDao.generatedMyKey.asSequence().map { $0.distinct() },
            bleAdapter.myCen.asSequence().map { $0.distinct() },
            bleAdapter.discovered.asSequence().map { $0.distinct() }
        )

        homeEntries = combined
            .map { myKey, myCen, discovered in
                return generateItems()
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    
    
    
}


enum HomeEntryViewData {
    case Header(String)
    //case Item(UIViewController)
}


private func generateItems() -> [HomeEntryViewData] {
    return items(header: "Health Quiz")
        + items(header: "Contact Alerts")
        + items(header: "Debug")
}

private func items(header: String) -> [HomeEntryViewData] {
    [.Header(header)]
}
