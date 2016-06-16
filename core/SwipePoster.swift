//
//  SwipePoster.swift
//
//  Created by Pete Stoppani on 6/16/16.
//

import Foundation

class SwipePoster : SwipeNode {
    let TAG = "SWPoster"
    private static var posters = [SwipePoster]()
    private var params: [String:AnyObject]?
    private var data: [String:AnyObject]?
    
    static func create(parent: SwipeNode, postInfo: [String:AnyObject]) {
        let poster = SwipePoster(parent: parent, postInfo: postInfo)
        posters.append(poster)
    }
    
    override init() {
        super.init()
        self.parent = nil
    }
    
    init(parent: SwipeNode, postInfo: [String:AnyObject]) {
        super.init(parent: parent)
        
        if let eventsInfo = postInfo["events"] as? [String:AnyObject] {
            eventHandler.parse(eventsInfo)
        }
        
        if let targetInfo = postInfo["target"] as? [String:AnyObject] {
            if let urlString = targetInfo["url"] as? String, url = NSURL(string: urlString) {
                
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("BASIC dWllY2hhdDp1aWVjaGF0", forHTTPHeaderField: "Authorization")

                if let data = postInfo["data"] as? [String:AnyObject] {
                    do {
                        let postString = try NSString(data: NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted), encoding: NSUTF8StringEncoding)
                        request.HTTPBody = postString!.dataUsingEncoding(NSUTF8StringEncoding)
                        print("posting'\(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))'")
                    } catch let error as NSError {
                        print("error=\(error)")
                    }
                }
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                    guard error == nil && data != nil else {                                                          // check for fundamental networking error
                        print("error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("responseString = \(responseString)")
                    
                    do {
                        guard let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String:AnyObject] else {
                            self.handleError("post \(urlString): not a dictionary.")
                            return
                        }
                        // Success
                        if let event = self.eventHandler.getEvent("completion"), actionsInfo = self.eventHandler.actionsFor("completion") {
                            self.data = json
                            self.params = event.params
                            self.execute(self, actions: actionsInfo)
                        }
                    } catch let error as NSError {
                        self.handleError("post \(urlString): invalid JSON file \(error.localizedDescription)")
                        return
                    }
                }
                task.resume()
                
            } else {
                self.handleError("post missing or invalid url")
            }
        } else {
            self.handleError("post missing target")
        }
    }
    
    private func handleError(errorMsg: String) {
        if let event = self.eventHandler.getEvent("error"), actionsInfo = self.eventHandler.actionsFor("error") {
            self.data = ["message":errorMsg]
            self.params = event.params
            self.execute(self, actions: actionsInfo)
        } else {
            NSLog(TAG + errorMsg)
        }
    }
    
    func cancel() {
        
    }
    
    static func cancelAll() {
        for timer in posters {
            timer.cancel()
        }
        
        posters.removeAll()
    }
    
    // SwipeNode
    
    override func getPropertiesValue(info: [String:AnyObject]) -> AnyObject? {
        let prop = info.keys.first!
        NSLog(TAG + " getPropsVal(\(prop))")
        
        switch (prop) {
        case "params":
            if let params = self.params, data = self.data {
                NSLog(TAG + " not checking params \(params)")
                var item:[String:AnyObject] = ["params":data]
                var path = info
                var property = "params"
                
                while (true) {
                    if let next = path[property] as? String {
                        if let sub = item[property] as? [String:AnyObject] {
                            let ret = sub[next]
                            if let str = ret as? String {
                                return str
                            } else if let arr = ret as? [AnyObject] {
                                if arr.count > 0 {
                                    return arr[0]
                                }
                            }
                        } else {
                            return nil
                        }
                    } else if let next = path[property] as? [String:AnyObject] {
                        if let sub = item[property] as? [String:AnyObject] {
                            path = next
                            property = path.keys.first!
                            item = sub
                        } else {
                            return nil
                        }
                    } else {
                        return nil
                    }
                }
                
                // loop on properties in info until get to a String
            }
            break;
        default:
            return nil
        }
        
        return nil
    }
    
}