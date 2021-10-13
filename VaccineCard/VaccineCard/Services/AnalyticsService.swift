//
//  AnalyticsService.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-10-13.
//

import Foundation
import SnowplowTracker

class AnalyticsService: NSObject, RequestCallback {
    public static let shared = AnalyticsService()
    
    fileprivate let endPoint = "spm.apps.gov.bc.ca"
    fileprivate let appID = "Snowplow_standalone_HApp_dev"
    
    var tracker : TrackerController?
    
    override init() {
        super.init()
        tracker = initTracker(endPoint, method: .post)
    }
    
    fileprivate func initTracker(_ url: String, method: HttpMethodOptions) -> TrackerController {
        let eventStore = SQLiteEventStore(namespace: appID)
        let network = DefaultNetworkConnection.build { (builder) in
            builder.setUrlEndpoint(url)
            builder.setHttpMethod(method)
            builder.setEmitThreadPoolSize(20)
            builder.setByteLimitPost(52000)
        }
        let networkConfig = NetworkConfiguration(networkConnection: network)
        let trackerConfig = TrackerConfiguration()
            .base64Encoding(false)
            .sessionContext(true)
            .platformContext(true)
            .geoLocationContext(false)
            .lifecycleAutotracking(true)
            .screenViewAutotracking(true)
            .screenContext(true)
            .applicationContext(true)
            .exceptionAutotracking(true)
            .installAutotracking(true)
            .diagnosticAutotracking(true)
            .logLevel(.verbose)
            .loggerDelegate(self)
        let emitterConfig = EmitterConfiguration()
            .eventStore(eventStore)
            .emitRange(500)
            .requestCallback(self)
        let gdprConfig = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
        
        let tracker = Snowplow.createTracker(namespace: appID, network: networkConfig, configurations: [trackerConfig, emitterConfig, gdprConfig])
        
        return tracker
    }
    
    public func trackSelfDescribingEvent(key: String, value: NSObject) {
        let data = [key: value]
        let event = SelfDescribing(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", payload: data)
        tracker?.track(event)
    }
    
    public func trackScreenView(name: String, screenId: UUID) {
        let event = ScreenView(name: name, screenId: screenId)
        tracker?.track(event)
    }

}

extension AnalyticsService: LoggerDelegate {
    func error(_ tag: String, message: String) {
        print("[Error] \(tag): \(message)")
    }
    
    func debug(_ tag: String, message: String) {
        print("[Debug] \(tag): \(message)")
    }
    
    func verbose(_ tag: String, message: String) {
        print("[Verbose] \(tag): \(message)")
    }
    
    func onSuccess(withCount successCount: Int) {
        print(successCount)
    }
    
    func onFailure(withCount failureCount: Int, successCount: Int) {
        print(failureCount)
    }
}
