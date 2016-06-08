//
//  SwipeView.swift
//
//  Created by Pete Stoppani on 5/19/16.
//

import Foundation
#if os(OSX)
    import Cocoa
    public typealias UIView = NSView
    public typealias UIButton = NSButton
    public typealias UIScreen = NSScreen
#else
    import UIKit
#endif

class SwipeView: SwipeNode {
    var elements = [SwipeElement]()
    var view: UIView?
    
    func setupGestureRecognizers() {
        var doubleTapRecognizer: UITapGestureRecognizer?
        
        if eventHandler.actionsFor("doubleTap") != nil {
            doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(SwipeView.didDoubleTap(_:)))
            doubleTapRecognizer!.numberOfTapsRequired = 2
            doubleTapRecognizer!.cancelsTouchesInView = false
            view!.addGestureRecognizer(doubleTapRecognizer!)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(SwipeView.didTap(_:)))
        if doubleTapRecognizer != nil {
            tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer!)
        }
        tapRecognizer.cancelsTouchesInView = false
        view!.addGestureRecognizer(tapRecognizer)
    }
    
    func endEditing() {
        let ended = view!.endEditing(true)
        if !ended {
            if let p = self.parent as? SwipeView {
                p.endEditing()
            }
        }
    }
    
    func setText(text:String, scale:CGSize, info:[String:AnyObject], dimension:CGSize, layer:CALayer) -> Bool {
        return false
    }
    
    func tapped() {
        if let p = self.parent as? SwipeView {
            p.tapped()
        }
    }
    
    func didTap(recognizer: UITapGestureRecognizer) {
        if let actions = eventHandler.actionsFor("tap") {
            endEditing()
            tapped()
            execute(self, actions: actions)
        } else  if let p = self.parent as? SwipeView {
            p.didTap(recognizer)
        } else {
            endEditing()
            tapped()
        }
    }
    
    func didDoubleTap(recognizer: UITapGestureRecognizer) {
        if let actions = eventHandler.actionsFor("doubleTap") {
            execute(self, actions: actions)
        }
    }
    
    override func executeAction(originator: SwipeNode, action: SwipeAction) {
        if let updateInfo = action.info["update"] as? [String:AnyObject] {
            var name = "*"; // default is 'self'
            if let value = updateInfo["name"] as? String {
                name = value
            }
            var up = true
            if let value = updateInfo["include"] as? String {
                up = value != "children"
            }
            updateElement(self, name:name, up:up, info: updateInfo)
        } else if let timerInfo = action.info["timer"] as? [String:AnyObject] {
            SwipeTimer.create(self, timerInfo: timerInfo)
        }
    }
    
    func updateElement(originator: SwipeNode, name: String, up: Bool, info: [String:AnyObject])  -> Bool {
        fatalError("Must Override")
    }
    
    func isFirstResponder() -> Bool {
        return false
    }
    
    func findFirstResponder() -> SwipeView? {
        if self.isFirstResponder() {
            return self
        }
        
        for e in self.elements {
            if let fr = e.findFirstResponder() {
                return fr
            }
        }
        
        return nil;
    }

}