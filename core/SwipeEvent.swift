//
//  SwipeEvent.swift
//
//  Created by Pete Stoppani on 5/19/16.
//

import Foundation

/* Format
 {
    "<event>": {
        "params": {"<p1>":{"type":"<type>"}, ... },
        "actions": [<action>, ... ]
 }
 */

class SwipeEvent: NSObject {
 
    var actions = [SwipeAction]()
    private let info:[String:AnyObject]

    init(type: String, info: [String:AnyObject]) {
        self.info = info
        if let paramsInfo = info["params"] as? [String:AnyObject] {
            NSLog("XdEvent params: \(paramsInfo)")
        }
        if let actionsInfo = info["actions"] as? [[String:AnyObject]] {
            for actionInfo in actionsInfo {
                let action = SwipeAction(info:actionInfo)
                actions.append(action)
            }
        }
    }
}