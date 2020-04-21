import XCTest
import Foundation
import Alamofire

final class AlamofireLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
        ⚡️ Request Started: \(request)
        ⚡️ Body Data: \(body)
        """
        NSLog(message)
    }
    
    
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, Error>) {
        NSLog("⚡️ Response Received: \(response.debugDescription)")
    }
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        NSLog("⚡️ Response Received (unserialized): \(response.debugDescription)")
    }
    
    func requestDidFinish(_ request: Request){
        NSLog("⚡️ Request did finish: \(request.response.debugDescription)")
    }
}

class CoEpiNetworkingV4Tests: XCTestCase {
    
    let apiV4 = "https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4"

    
   
    func testV4GetTcnReport() {
        /*
        curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport
        ["WlhsS01GcFlUakJKYW05cFdXMDVhMlZUU2prPQ=="]
        */
        let url: String = apiV4 + "/tcnreport"
        executeGet(url: url)
    }
    
  
    

    func testV4GetTcnReportWithDate() {
        /**
         curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport?date=2020-04-19
         */
        let dateString = "2020-04-19"
        guard let date = getDateForString(dateString) else
        {
            XCTFail("Date conversion failed for [\(dateString)]")
            return
        }
        
        getTcnForDate(date)
    }
    
   
    
    
    func testV4GetTcnReportWithIntervalNumber() {
        /**
         GET /tcnreport?date={report_date}?intervalNumber={interval}?intervalLengthMs={interval_length_ms}
         */
        
        /**
         formatedDate : [2020-04-20 01:28:04 +0200]
         formatedUtcDate : [2020-04-19 23:28:04 +0000]
         */
        let currentDate = Date()
        
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        
        let startOfDay = cal.startOfDay(for: currentDate)
        
        NSLog(startOfDay.description)
              
        getTcnForDate(startOfDay)
        
//        let intervalLengthMillis : Int64 = 6 * 3600 * 1000
//        let currentMillis = Int64(currentDate.timeIntervalSince1970 * 1000)
//        let intervalNumber = currentMillis / intervalLengthMillis
//        let dateformater = DateFormatter()
//        dateformater.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd HH:mm:ss ZZZ"
//        dateformater.timeZone = TimeZone(abbreviation: "UTC")
//        let formatedDate = dateformater.string(from: currentDate)
//        let url: String = apiV4 + "/tcnreport?date=\(formatedDate)&intervalNumber=\(intervalNumber)&intervalLengthMs=\(intervalLengthMillis)"
//
//        NSLog("intervalLengthMillis : [\(intervalLengthMillis)]")
//        NSLog("currentMillis : [\(currentMillis)]")
//        NSLog("intervalNumber : [\(intervalNumber)]")
//        NSLog("formatedDate : [\(formatedDate)]")
//        NSLog("url : [\(url)]")
//
//        executeGet(url: url)
    }
    
    func testV4PostTcnReport() {
        /**
          curl -X POST https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport -d "ZXlKMFpYTjBJam9pWW05a2VTSjk="
          */
        let urlString: String = apiV4 + "/tcnreport"
        let expect = expectation(description: "POST request complete")
        
        //Fix for error message: "CredStore - performQuery - Error copying matching creds.  Error=-25300" See: https://stackoverflow.com/a/54100650
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil
        
        let session = Session(configuration:configuration, eventMonitors: [ AlamofireLogger() ])
        let paramsString = "Test payload \(Date().timeIntervalSince1970)"
        let paramsStringEncoded = Data(paramsString.utf8).base64EncodedString()
        //https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#urlrequestconvertible
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post

        urlRequest.httpBody = Data(paramsStringEncoded.utf8)
        
        do {
            let _ = session.request(urlRequest)
                .cURLDescription { description in
                NSLog(description)
            }
            .response { response in
                switch response.result {
                case .success:
                    expect.fulfill()
                case .failure(let error):
                    NSLog("\n\n Request failed with error: \(error)")
                    XCTFail()
                }
                
            }
        }
        
        waitForExpectations(timeout: 15)
    }
    
    //MARK: Helper functions
    
    private func getTcnForDate(_ date: Date){
           let intervalLengthMillis : Int64 = 6 * 3600 * 1000
           let millis = Int64(date.timeIntervalSince1970 * 1000)
           let intervalNumber = millis / intervalLengthMillis
           let dateformater = DateFormatter()
           dateformater.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd HH:mm:ss ZZZ"
           dateformater.timeZone = TimeZone(abbreviation: "UTC")
           let formatedDate = dateformater.string(from: date)
           
           NSLog("intervalLengthMillis : [\(intervalLengthMillis)]")
           NSLog("millis : [\(millis)]")
           NSLog("intervalNumber : [\(intervalNumber)]")
           NSLog("formatedDate : [\(formatedDate)]")
           
           //Single date has 4 6h long intervals:
           for var i : Int64 in 0...3 {
               let url: String = apiV4 + "/tcnreport?date=\(formatedDate)&intervalNumber=\(intervalNumber+i)&intervalLengthMs=\(intervalLengthMillis)"
               NSLog("\n⚡️ URL : [\(url)]")
               executeGet(url: url)
               
           }

       }
    
    private func executeGet(url: String){
          let expect = expectation(description: "request complete")
          
          //Fix for error message: "CredStore - performQuery - Error copying matching creds.  Error=-25300" See: https://stackoverflow.com/a/54100650
          let configuration = URLSessionConfiguration.default
          configuration.urlCredentialStorage = nil

          let session = Session(configuration: configuration,  eventMonitors: [ AlamofireLogger()])
          let _ = session.request(url)
              .cURLDescription { description in
                  NSLog(description)
              }
              .responseJSON { response in
               let statusCode = response.response?.statusCode
              NSLog("⚡️ StatusCode : [\(statusCode!)]")
              expect.fulfill()
              switch response.result {
              case .success(let JSON):
                  NSLog("\n Success value and JSON: \(JSON)")
                  XCTAssertNotNil(JSON)
                  if let stringArray = JSON as? Array<String> {
                    for s in stringArray {
                        guard let ps = s.fromBase64() else {continue}
                        NSLog("⚡️ Decoded once :[\(s)] -> [\(ps)]")
                        guard let pps =  ps.fromBase64()  else { continue }
                        NSLog("⚡️ Decoded twice : [\(ps)] -> [\(pps)]")
                    }
                }

              case .failure(let error):
                  NSLog("\n Request failed with error: \(error)")
                  XCTFail()
              }
              
          }
          
          waitForExpectations(timeout: 10)

      }
    
    private func getDateForString(_ dateString: String) -> Date?{
           let dateformater = DateFormatter()
           dateformater.dateFormat = "yyyy-MM-dd"
           dateformater.timeZone = TimeZone(abbreviation: "UTC")
           let date = dateformater.date(from: dateString)!
           return date
   }

}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
