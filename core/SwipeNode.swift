//
//  SwipeNode.swift
//
//  Created by Pete Stoppani on 5/19/16.
//

import Foundation

class SwipeNode: NSObject {
    weak var parent:SwipeNode?
    let eventHandler = SwipeEventHandler()
    
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
        parent?.executeAction(originator, action: action)
    }
    
    func getAttributeValue(attribte: String) -> AnyObject? {
        return nil
    }

    func getAttributesValue(info: [String:AnyObject]) -> AnyObject? {
        return nil
    }
    
    func getValue(info: [String:AnyObject]) -> AnyObject? {
        return nil
    }
}