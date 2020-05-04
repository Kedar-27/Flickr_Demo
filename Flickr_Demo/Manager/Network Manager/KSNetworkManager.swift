//
//  KSNetworkManager.swift
//  JSON_Parser
//
//  Created by Kedar Sukerkar on 28/04/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//
import Foundation
import Alamofire

public enum NetworkError: LocalizedError{
    
    case noInternet
    case parsingError
    
    public var errorDescription: String? {
        switch self {
        case .noInternet:
            return NSLocalizedString("No internet found.", comment: "No Internet Error")
        case .parsingError:
            return NSLocalizedString("Json parsing failed", comment: "JSON Parsing Error")
            
        }
    }
}



public class KSNetworkManager: NSObject {
    
    // MARK: - Initializer
    public static let shared = KSNetworkManager()
    private override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 60
        
        self.alamoFireManager = Session(configuration: configuration)
        
    }
    
    // MARK: - Properties
    public var serverURL = ""
    public let alamoFireManager: Session?
    
    
    
    // MARK: - Response Closures
    public typealias responseModel = (Result<Any?,Error>) -> Void
    
    
   
    // MARK: - Request Helpers
    public func sendRequest(baseUrl:String = KSNetworkManager.shared.serverURL,
                            methodType:HTTPMethod,
                            apiName:String,
                            parameters:[String:Any]?,
                            headers:HTTPHeaders?,
                            encoding:ParameterEncoding = URLEncoding.default,
                            completionHandler:@escaping responseModel){
        
        
        // Check network reachability
        if NetworkReachabilityManager()?.isReachable == true{
            
            let urlString = baseUrl + apiName
            
            print(urlString)
            
            
            self.alamoFireManager!.request(urlString,
                                           method: methodType,
                                           parameters: parameters ,
                                           encoding: encoding,
                                           headers: headers).responseJSON { (response) in
                                            if let err = response.error{
                                                print(err)
                                                completionHandler(.failure(err))
                                            }
                                            completionHandler(.success(response.data))
                                            
                                            
                                            
            }
        }else{
            print("Internet connection not available")
            completionHandler(.failure(NetworkError.noInternet))
            
        }
    }
    
    public func getJSONDecodedData<T: Codable>(from data: Data, completion: @escaping (Result<T, Error>)-> Void){
        
        DispatchQueue.global(qos: .background).async {
            do {
                let parsedJSON = try JSONDecoder().decode(T.self, from: data)
                completion(.success(parsedJSON))
            } catch let jsonErr {
                completion(.failure(jsonErr))
                print("failed to decode, \(jsonErr)")
            }
        }
        
        
        
    }

}
