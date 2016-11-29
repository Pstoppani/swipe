//
//  SwipeTimer.swift
//
//  Created by Pete Stoppani on 5/23/16.
//

import Foundation

class SwipeTimer : SwipeNode {
    static var timers = [SwipeTimer]()
<<<<<<< HEAD
    var timer: NSTimer?
    var repeats = false
    
    static func create(parent: SwipeNode, timerInfo: [String:AnyObject]) {
=======
    var timer: Timer?
    var repeats = false
    
    static func create(_ parent: SwipeNode, timerInfo: [String:Any]) {
>>>>>>> swipe-org/master
        let timer = SwipeTimer(parent: parent, timerInfo: timerInfo)
        timers.append(timer)
    }
    
<<<<<<< HEAD
    init(parent: SwipeNode, timerInfo: [String:AnyObject]) {
=======
    init(parent: SwipeNode, timerInfo: [String:Any]) {
>>>>>>> swipe-org/master
        super.init(parent: parent)
        var duration = 0.2
        if let value = timerInfo["duration"] as? Double {
            duration = value
        }
        if let value = timerInfo["repeats"] as? Bool {
            repeats = value
        }
<<<<<<< HEAD
        if let eventsInfo = timerInfo["events"] as? [String:AnyObject] {
            eventHandler.parse(eventsInfo)
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(duration, target:self, selector: #selector(SwipeTimer.didTimerTick(_:)), userInfo: nil, repeats: repeats)
=======
        if let eventsInfo = timerInfo["events"] as? [String:Any] {
            eventHandler.parse(eventsInfo)
            
            self.timer = Timer.scheduledTimer(timeInterval: duration, target:self, selector: #selector(SwipeTimer.didTimerTick(_:)), userInfo: nil, repeats: repeats)
>>>>>>> swipe-org/master
        }
    }
    
    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }

    static func cancelAll() {
        for timer in timers {
            timer.cancel()
        }
        
        timers.removeAll()
    }
    
<<<<<<< HEAD
    func didTimerTick(timer: NSTimer) {
=======
    func didTimerTick(_ timer: Timer) {
        if !timer.isValid {
            return
        }

>>>>>>> swipe-org/master
        if let actions = eventHandler.actionsFor("tick") {
            execute(self, actions:actions)
        }
        
        if !repeats {
            cancel()
        }
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> swipe-org/master
