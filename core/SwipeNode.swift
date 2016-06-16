//
//  SwipeNode.swift
//
//  Created by Pete Stoppani on 5/19/16.
//

import Foundation

class SwipeNode: NSObject {
    var children = [SwipeNode]()
    weak var parent:SwipeNode?
    let eventHandler = SwipeEventHandler()
    var session: NSURLSession?

    override init() {
        self.parent = nil
        super.init()
    }
    
    init(parent: SwipeNode) {
        self.parent = parent
        super.init()
    }
    
    func execute(originator: SwipeNode, actions:[SwipeAction]) {
        for action in actions {
            executeAction(originator, action: action)
        }
    }
    
    func executeAction(originator: SwipeNode, action: SwipeAction) {
        if let fetchInfo = action.info["fetch"] as? [String:AnyObject] {
            SwipeFetcher.create(self, fetchInfo: fetchInfo)
        } else if let postInfo = action.info["post"] as? [String:AnyObject] {
            SwipePoster.create(self, postInfo: postInfo)
        } else if let timerInfo = action.info["timer"] as? [String:AnyObject] {
            SwipeTimer.create(self, timerInfo: timerInfo)
        } else {
            parent?.executeAction(originator, action: action)
        }
    }

    func getPropertyValue(property: String) -> AnyObject? {
        return nil
    }
    
    func getPropertiesValue(info: [String:AnyObject]) -> AnyObject? {
        return nil
    }
    
    func getValue(info: [String:AnyObject]) -> AnyObject? {
        var up = true
        if let val = info["include"] as? String {
            up = val != "children"
        }
        
        if let property = info["property"] as? String {
            return getPropertyValue(property)
        } else if let propertyInfo = info["property"] as? [String:AnyObject] {
            return getPropertiesValue(propertyInfo)
        } else {
            if up {
                return self.parent?.getValue(info)
            } else {
                for c in self.children {
                    let val = c.getValue(info)
                    if val != nil {
                        return val
                    }
                }
            }
        }
        
        return nil
    }
}