import RxSwift
import os.log

protocol CENReportRepo {
    var reports: Observable<[ReceivedCenReport]> { get }

    func insert(report: ReceivedCenReport) -> Bool
    func delete(report: ReceivedCenReport)
}

class CenReportRepoImpl: CENReportRepo {
    private let cenReportDao: CENReportDao

    lazy var reports = cenReportDao.reports

    private let disposeBag = DisposeBag()

    init(cenReportDao: CENReportDao) {
        self.cenReportDao = cenReportDao
    }

    func insert(report: ReceivedCenReport) -> Bool {
        cenReportDao.insert(report: report)
    }

    func delete(report: ReceivedCenReport) {
        cenReportDao.delete(report: report)
    }
}
