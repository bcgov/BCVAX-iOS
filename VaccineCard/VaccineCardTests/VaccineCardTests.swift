//
//  VaccineCardTests.swift
//  VaccineCardTests
//
//  Created by Amir Shayegh on 2021-08-30.
//

import XCTest
import VaccineCard

class VaccineCardTests: XCTestCase {
    
    let base64Encoded: [String] = ["fVLLbtswEPyVYHvoRZYpJ3VsHdugQHsqkDQ9BD5Q1Mpiw4dAUkrcQP_eXdoJUiCNwMtSM7Mzy30C13RQV-tzcb5ebcW6AB0j1NCnNMR6uWzUJB-VDO0eXdkFjP2DD_exVGZsoIBJQf0E6TAg1HcvpGhlSD1Kk_qSufHDsVhwQaz_47S1o9N_ZNLevQtUftJttYVdASpgiy5paa7H5jeqxJa6XodbDJF1argoRVmRHt9-Hl1rkDGUxo9B4U22D6cfxSkOKG8MqR2dUINwoIykPBrzMxgCPPNrQYDn4g3hHxSH-ARy0uJRRFptSA-uPHfc6wkdT_C7dAi7mVI1mhJfycQC1fZSLERFB-a5eNNC9b6Fb__OdTg5ysAOAzpmvQ40FxCTTGPMg7CDwYT8dJNUSjv84tvcRvlWu32OFA8xoT2tDr-Z8xbbUrvOL6Pi9CqTYLX5tKkEfZvLSqxh3lEvr9QYsg2OfKNtBooVZd4sVlu2jKHzwWLIzaRKPrCBVsfBSJ7kV17OX7ycH89u5ePZdS_VPc1rl888_wU"]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBase64Decoding() throws {
        let decoded = base64Encoded.compactMap({$0.base64DecodedData})
        
        XCTAssertNotEqual(decoded.count, 0)
        
        
    }

}
