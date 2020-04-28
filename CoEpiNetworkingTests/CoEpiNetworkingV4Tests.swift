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
        NSLog("⚡️ \(startOfDay.description)")
        getTcnForDate(startOfDay)
    }
    
    func testV4PostTcnReport(){
        let urlRequest = buildUrlRequest()
        postTcnReportHelper(urlRequest: urlRequest)
    }
    
    func postTcnReportHelper(urlRequest : URLRequest) {
        /**
          curl -X POST https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport -d "ZXlKMFpYTjBJam9pWW05a2VTSjk="
          */
        
        let expect = expectation(description: "POST request complete")
               
       //Fix for error message: "CredStore - performQuery - Error copying matching creds.  Error=-25300" See: https://stackoverflow.com/a/54100650
       let configuration = URLSessionConfiguration.default
       configuration.urlCredentialStorage = nil
       
       let session = Session(configuration:configuration, eventMonitors: [ AlamofireLogger() ])
       
//       let urlRequest = buildUrlRequest()
        
        do {
            let _ = session.request(urlRequest)
                .cURLDescription { description in
                NSLog(description)
            }
            .response { response in
                if let status = response.response?.statusCode {
                    if status >= 300 {
                        XCTFail("Bad status: \(status)")
                    }
                    
                }
                switch response.result {
                case .success:
                    expect.fulfill()
                case .failure(let error):
                    NSLog("\n\n⚡️ Request failed with error: \(error)")
                    XCTFail()
                }
                
            }
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func buildUrlRequest() -> URLRequest {
        let paramsString = "Test payload \(Date().timeIntervalSince1970)"
        return buildUrlRequest(string: paramsString)
    }
    
    
    func buildUrlRequest(data: Data) -> URLRequest {
        let urlString: String = apiV4 + "/tcnreport"
       
        //https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#urlrequestconvertible
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.httpBody = data
        
        return urlRequest
    }
    
    func buildUrlRequest(string: String) -> URLRequest {
        let paramsStringEncoded = string.toBase64()
        let data = Data(paramsStringEncoded.utf8)
        return buildUrlRequest(data: data)
    }
    
    func testV4Crypto(){
        
        let count : UInt16 = 25
        let startIndex : UInt16 = 15
        let endIndex : UInt16 = 18
        
        let crypto = TcnLogicV4()
        
        var tck = [UInt8](crypto.tck_0)
        var tcn: [UInt8]
        var preceedingTck: [UInt8]?
        
        for i: UInt16 in 1...count {
            print("\(i). ")
            tck = crypto.tckRatchet(previousKeyBytes: tck)
            tcn = crypto.tcnGeneration(index: i, tck: tck)
            
            if (startIndex - 1 == i){
                preceedingTck = tck
            }
        }
        
        let memo = crypto.memoGeneration()
        if let preceedingTck = preceedingTck {
            let report = crypto.reportGeneration(preceedingTck: preceedingTck, startIndex: startIndex, endIndex: endIndex, memo: memo)
            print("Report ← rvk || tck_{j1-1} || le_u16(j1) || le_u16(j2) || memo: \n<\(report.debugDescription)>") 
            crypto.parseReport(report)
        }else{
            fatalError("no preceedingTck")
        }
    }
    
    func testV4CryptoNetworking(){
        /**
         2020-04-28 18:53:41.203523+0200 xctest[79360:8256913] PrivateKey bytes <rak>: [16, 6, 32, 212, 61, 134, 39, 141, 37, 217, 130, 60, 247, 167, 51, 33, 118, 24, 70, 131, 87, 250, 203, 35, 151, 223, 56, 221, 52, 3, 34, 94]
         2020-04-28 18:53:41.203772+0200 xctest[79360:8256913] PublicKey bytes <rvk>: [175, 83, 147, 104, 68, 210, 188, 62, 161, 216, 147, 203, 41, 195, 103, 134, 98, 48, 11, 200, 235, 115, 77, 182, 17, 135, 21, 51, 235, 181, 0, 37]
         */
        
        let rak : [UInt8] = [16, 6, 32, 212, 61, 134, 39, 141, 37, 217, 130, 60, 247, 167, 51, 33, 118, 24, 70, 131, 87, 250, 203, 35, 151, 223, 56, 221, 52, 3, 34, 94]
        let rvk : [UInt8] = [175, 83, 147, 104, 68, 210, 188, 62, 161, 216, 147, 203, 41, 195, 103, 134, 98, 48, 11, 200, 235, 115, 77, 182, 17, 135, 21, 51, 235, 181, 0, 37]
        
        let count : UInt16 = 25
        let startIndex : UInt16 = 15
        let endIndex : UInt16 = 18
        
        let crypto = TcnLogicV4(rak: rak, rvk: rvk)
        
        var tck = [UInt8](crypto.tck_0)
        var tcn: [UInt8]
        var preceedingTck: [UInt8]?
        
        for i: UInt16 in 1...count {
            print("\(i). ")
            tck = crypto.tckRatchet(previousKeyBytes: tck)
            tcn = crypto.tcnGeneration(index: i, tck: tck)
            
            if (startIndex - 1 == i){
                preceedingTck = tck
            }
        }
        
        let memo = crypto.memoGeneration()
        if let preceedingTck = preceedingTck {
            let report = crypto.reportGeneration(preceedingTck: preceedingTck, startIndex: startIndex, endIndex: endIndex, memo: memo)
            print("Report ← rvk || tck_{j1-1} || le_u16(j1) || le_u16(j2) || memo: \n<\(report.debugDescription)>")
            crypto.parseReport(report)
            
            let encodedReport = report.description.toBase64()
            
            let payload = Data(encodedReport.utf8)
            let request = buildUrlRequest(data: payload)
            postTcnReportHelper(urlRequest: request)
                        
        }else{
            fatalError("no preceedingTck")
        }
    }
/**
     2020-04-28 19:42:49.768142+0200 xctest[79663:8282630] ⚡️ Decoded once :[WzE3NSwgODMsIDE0NywgMTA0LCA2OCwgMjEwLCAxODgsIDYyLCAxNjEsIDIxNiwgMTQ3LCAyMDMsIDQxLCAxOTUsIDEwMywgMTM0LCA5OCwgNDgsIDExLCAyMDAsIDIzNSwgMTE1LCA3NywgMTgyLCAxNywgMTM1LCAyMSwgNTEsIDIzNSwgMTgxLCAwLCAzNywgMjIsIDEyMSwgMzUsIDIzNCwgMTM0LCAxMDksIDEzOSwgMTMxLCAyNTAsIDEwOCwgMTY2LCAyMjYsIDM1LCAxMjMsIDIwMiwgMjIwLCA3MSwgMTIzLCA0NiwgMTAxLCAxMDgsIDEzMywgNjAsIDE3NiwgMTU3LCAyMTUsIDI0NywgMTMwLCAxNDAsIDE5NCwgMjAzLCA1NCwgMCwgMTUsIDAsIDE4LCAwLCA4LCAwLCAwLCAwLCAwLCA5NCwgMTY4LCAxMDYsIDIzOF0=] -> [[175, 83, 147, 104, 68, 210, 188, 62, 161, 216, 147, 203, 41, 195, 103, 134, 98, 48, 11, 200, 235, 115, 77, 182, 17, 135, 21, 51, 235, 181, 0, 37, 22, 121, 35, 234, 134, 109, 139, 131, 250, 108, 166, 226, 35, 123, 202, 220, 71, 123, 46, 101, 108, 133, 60, 176, 157, 215, 247, 130, 140, 194, 203, 54, 0, 15, 0, 18, 0, 8, 0, 0, 0, 0, 94, 168, 106, 238]]
     */
    
    
    
    //MARK: Helper functions
    
    private func getTcnForDate(_ date: Date){
           let intervalLengthMillis : Int64 = 6 * 3600 * 1000
           let millis = Int64(date.timeIntervalSince1970 * 1000)
           let intervalNumber = millis / intervalLengthMillis
           let dateformater = DateFormatter()
           dateformater.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd HH:mm:ss ZZZ"
           dateformater.timeZone = TimeZone(abbreviation: "UTC")
           let formatedDate = dateformater.string(from: date)
           
           NSLog("⚡️ IntervalLengthMillis : [\(intervalLengthMillis)]")
           NSLog("⚡️ Millis : [\(millis)]")
           NSLog("⚡️ IntervalNumber : [\(intervalNumber)]")
           NSLog("⚡️ FormatedDate : [\(formatedDate)]")
           
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
                  NSLog("\n⚡️ Success value and JSON: \(JSON)")
                  XCTAssertNotNil(JSON)
                  if let stringArray = JSON as? Array<String> {
                    for s in stringArray {
                        guard let ps = s.fromBase64() else {continue}
                        NSLog("⚡️ Decoded once :<\(s)> -> <\(ps)>")
                        guard let pps =  ps.fromBase64()  else { continue }
                        NSLog("⚡️ Decoded twice : <\(ps)> -> <\(pps)>")
                    }
                }

              case .failure(let error):
                  NSLog("\n⚡️ Request failed with error: \(error)")
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
