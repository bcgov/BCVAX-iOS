import Foundation

public class BCVaccineValidator {
    public enum Config {
        case Prod
        case Test
        case Dev
    }
    static var mode: Config = .Prod
    static var enableRemoteRules = true
    public static var shouldUpdateWhenOnline = false
    public static let shared = BCVaccineValidator()
    
    static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: BCVaccineValidator.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "BCVaccineValidator", withExtension: "bundle")
            else { fatalError("MySDK.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access MySDK.bundle!") }

        return resourceBundle
    }()
    
    func initData() {
#if DEBUG
        print("Initialized BCVaccineValidator in \(BCVaccineValidator.mode)")
        print("Enable Remote rules: \(BCVaccineValidator.enableRemoteRules)")
#endif
        loadData { [weak self] in
            guard let `self` = self, BCVaccineValidator.enableRemoteRules else {return}
            self.setupReachabilityListener()
            self.setupUpdateListener()
        }
#if DEBUG
        print("\n\nBundled Files: \n")
        if let files = try? FileManager.default.contentsOfDirectory(atPath: BCVaccineValidator.resourceBundle.bundlePath){
            for file in files {
                
                print(file)
            }
        }
        print("\n\n")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("\(documentsDirectory)\n\n")
        print("\n\n")
#endif
    }
    
    private func loadData(completion: @escaping()->Void) {
        let displatchGroup = DispatchGroup()
        displatchGroup.enter()
        IssuerManager.shared.getIssuers { issuers in
            displatchGroup.leave()
        }
        displatchGroup.enter()
        RulesManager.shared.getRules { rules in
            displatchGroup.leave()
        }
        
        displatchGroup.notify(queue: .main) {
            return completion()
        }
    }
    
    public func setup(mode: Config, remoteRules: Bool? = true) {
        BCVaccineValidator.enableRemoteRules = remoteRules ?? true
        BCVaccineValidator.mode = mode
        initData()
    }
    
    private func setupUpdateListener() {
        // When issuers list is updated, re-download keys for issuers
        Notification.Name.issuersUpdated.onPost(object: nil, queue: .main) { _ in
            IssuerManager.shared.getIssuers(completion: { res in
                if let issuers = res {
                    let issuerURLs = issuers.participatingIssuers.map({$0.iss})
                    KeyManager.shared.downloadKeys(forIssuers: issuerURLs, completion: {})
                }
            })
        }
    }
    
    /// When network status changes to online,
    /// and if a network call had failed and set shouldUpdateWhenOnline to true,
    /// re-fetch issuers.
    private func setupReachabilityListener() {
        Notification.Name.isReachable.onPost(object: nil, queue: .main) { _ in
            if BCVaccineValidator.shouldUpdateWhenOnline {
                IssuerManager.shared.updateIssuers()
                RulesManager.shared.updateRules()
            }
        }
    }
    
    public func validate(code: String, completion: @escaping (CodeValidationResult)->Void) {
        CodeValidationService.shared.validate(code: code, completion: completion)
    }
}
