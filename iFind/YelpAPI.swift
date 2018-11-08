import Foundation


// Use this String extension method to encode a string to be passed in a URL request.
// When sending a string as a parameter in a URL query, you must replace certain characters with escape sequences.
// This function will return a string that is safe to embed in a URL query.
// It will escape any non-alphanumeric characters, except for the specified exceptions.

extension String {
    func encodedStringForURLEncodedFormData() -> String? {
        let exceptions = "*-._"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(exceptions)
        
        return stringByAddingPercentEncodingWithAllowedCharacters(allowed)
    }
}

// Use this class to communicate with the Yelp Fusion API.
// Create instances of this class using the connectClient factory method.
// Our sample implementation has one instance method that lets you use Yelp's Location Search.
// You can find more APIs by browsing Yelp's documentation. 
// Use the locationSearch function as a guide on constructing a request and parsing the returned data.

class YelpAPIClient {
    
    private var accessToken: String = "gvAH1XulxGvl5xYJdmrsJ98_Q7x3irE0FLIudJ3NKL5Gboboii08JgL4b6BDycyQdGJc050O4vmM44twi4pfC1q-zwl1ti61Mi40bs4ZUZj1UAqhJQOo55nJ9RrXW3Yx"
    
    static let AuthURL = "https://api.yelp.com/oauth2/token"
    static let SearchURL = "https://api.yelp.com/v3/businesses/search"
    static let businessURL = "https://api.yelp.com/v3/businesses"
    
    enum YelpAPIClientError: Int {
        case URLFormattingError
        case JSONFormatError
        case TokenResponseMissing
        case StringEncodingError
        case MissingData
    }
    
    // Note: An access token must be requested from Yelp using the connectClient class function.
    init(token: String) {
        accessToken = token
    }
    
    init() {}
    
    // Requests an access token and returns a new instance of YelpAPIClient.
    static func connectClient (id: String, secret: String, completion: (YelpAPIClient?, NSError?) -> Void) {
        
        let requestString = "\(AuthURL)?grant_type=client_credentials&client_id=\(id.encodedStringForURLEncodedFormData()!)&client_secret=\(secret.encodedStringForURLEncodedFormData()!)"
        guard let requestURL = NSURL(string: requestString) else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.URLFormattingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "URL Formatting Error"])
            dispatch_async(dispatch_get_main_queue(), { 
                completion(nil, error)
            })
            return
        }
        
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "POST"
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }
            
            guard let jsonData = data else {
                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.MissingData.rawValue, userInfo: [NSLocalizedDescriptionKey:"YelpAPIClient server response did not include any data."])
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }
            
            guard let json = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as? Dictionary<String, AnyObject> else {
                dispatch_async(dispatch_get_main_queue(), { 
                    completion(nil, NSError(domain: "YelpAPIClient", code: YelpAPIClientError.JSONFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient could not decode json response."]))
                })
                
                return
            }
            
            guard let accessToken = json["access_token"] as? String else {
                dispatch_async(dispatch_get_main_queue(), { 
                    completion(nil, NSError(domain: "YelpAPIClient", code: YelpAPIClientError.TokenResponseMissing.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient token missing from response."]))
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                completion(YelpAPIClient(token: accessToken), nil)
            })
            
            
        }.resume()
        
    }
    
    // Search near a particular location using the Location Search API.
    // See here for all possible parameters: https://www.yelp.ca/developers/documentation/v3/business_search
    
    func locationSearch(location: String, completion: (NSData?, NSError?)->Void) {
        
        // Note how calls to our completion block are wrapped in 'dispatch_async(dispatch_get_main_queue()) {}'.
        // This is necessary to ensure the completion block is called on the main queue. Only code on the main queue
        // may update user interface elements, call Cocoa APIs, etc.
        // It's also done to ensure the completion block is not called before this function returns, in case
        // the user of this function doesn't expect that to happen.
        
        print(location)
        
        guard let encodedLocation = location.encodedStringForURLEncodedFormData() else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.StringEncodingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient string encoding error."])
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, error)
            })
            return
        }
        
        // Construct the full url including parameters.
        let requestString = "\(YelpAPIClient.SearchURL)?&location=\(encodedLocation)"
        guard let requestURL = NSURL(string: requestString) else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.URLFormattingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "URL Formatting Error"])
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, error)
            })
            return
        }
        
        // Create the URL request. Note we need to include the current access token as an HTTP header field value.
        let request = NSMutableURLRequest(URL: requestURL)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Send the network data task.
        // Don't forget to call resume() on the new data task!
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }
            
            // Make sure some data was returned.
//            guard let jsonData = data else {
//                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.MissingData.rawValue, userInfo: [NSLocalizedDescriptionKey:"YelpAPIClient server response did not include any data."])
//                dispatch_async(dispatch_get_main_queue(), {
//                    completion(nil, error)
//                })
//                return
//            }
//            
//            // Parse the raw text data into an object.
//            guard let json = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as? Dictionary<String,AnyObject> else {
//                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.JSONFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient could not decode json response."])
//                dispatch_async(dispatch_get_main_queue(), {
//                    completion(nil, error)
//                })
//                return
//            }
            
            // Return the JSON object if everything is ok.
            dispatch_async(dispatch_get_main_queue(), {
                completion(data, nil)
            })
        }.resume()
    }
    
    func latLngSearch(latitude: String, longitude: String, completion: (NSData?, NSError?)->Void) {
        
        // Note how calls to our completion block are wrapped in 'dispatch_async(dispatch_get_main_queue()) {}'.
        // This is necessary to ensure the completion block is called on the main queue. Only code on the main queue
        // may update user interface elements, call Cocoa APIs, etc.
        // It's also done to ensure the completion block is not called before this function returns, in case
        // the user of this function doesn't expect that to happen.
        
        // Construct the full url including parameters.
        let requestString = "\(YelpAPIClient.SearchURL)?&latitude=\(latitude)&longitude=\(longitude)"
        guard let requestURL = NSURL(string: requestString) else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.URLFormattingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "URL Formatting Error"])
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, error)
            })
            return
        }
        
        // Create the URL request. Note we need to include the current access token as an HTTP header field value.
        let request = NSMutableURLRequest(URL: requestURL)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Send the network data task.
        // Don't forget to call resume() on the new data task!
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }
            
            // Make sure some data was returned.
            //            guard let jsonData = data else {
            //                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.MissingData.rawValue, userInfo: [NSLocalizedDescriptionKey:"YelpAPIClient server response did not include any data."])
            //                dispatch_async(dispatch_get_main_queue(), {
            //                    completion(nil, error)
            //                })
            //                return
            //            }
            //
            //            // Parse the raw text data into an object.
            //            guard let json = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as? Dictionary<String,AnyObject> else {
            //                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.JSONFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient could not decode json response."])
            //                dispatch_async(dispatch_get_main_queue(), {
            //                    completion(nil, error)
            //                })
            //                return
            //            }
            
            // Return the JSON object if everything is ok.
            dispatch_async(dispatch_get_main_queue(), {
                completion(data, nil)
            })
            
            
            }.resume()
        
        
    }
    
    func getBussinessDetail(id: String, completion: (NSData?, NSError?)->Void) {
        let requestString = "\(YelpAPIClient.businessURL)/\(id)"
        guard let requestURL = NSURL(string: requestString) else {
            return
        }
        
        // Create the URL request. Note we need to include the current access token as an HTTP header field value.
        let request = NSMutableURLRequest(URL: requestURL)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(data, nil)
            })
            
            
        }.resume()
    }
    
    
    
}
