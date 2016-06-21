//
//  SwipeList.swift
//
//  Created by Pete Stoppani on 5/26/16.
//

import Foundation
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

class SwipeList: SwipeView, UITableViewDelegate, UITableViewDataSource {
    let TAG = "SWList"
    private var items = [[String:AnyObject]]()
    private let scale:CGSize
    private var screenDimension = CGSize(width: 0, height: 0)
    weak var delegate:SwipeElementDelegate!
    var tableView: UITableView
    
    init(parent: SwipeNode, info: [String:AnyObject], scale: CGSize, frame: CGRect, screenDimension: CGSize, delegate:SwipeElementDelegate) {
        self.scale = scale
        self.screenDimension = screenDimension
        self.delegate = delegate
        self.tableView = UITableView(frame: frame, style: .Plain)
        super.init(parent: parent, info: info)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .None
        self.tableView.allowsSelection = true
        self.tableView.backgroundColor = UIColor.clearColor()
        if let itemsInfo = info["items"] as? [[String:AnyObject]] {
            items = itemsInfo
        }
        if let selectedIndex = self.info["selectedItem"] as? Int {
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0), animated: true, scrollPosition: .Middle)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UITableViewDataDelegate
    let kH: CGFloat = 70.0
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kH
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let actions = parent!.eventHandler.actionsFor("rowSelected") {
            parent!.execute(self, actions: actions)
        }
    }
    
    // UITableViewDataSource
    
    var cellIndexPath: NSIndexPath?
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let subviewTag = 999
        self.cellIndexPath = indexPath
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if let subView = cell.contentView.viewWithTag(subviewTag) {
            subView.removeFromSuperview()
        }
        var cellError: String?
        
        let item = self.items[indexPath.row]
        
        if let elementsInfo = item["elements"] as? [[String:AnyObject]] {
            for elementInfo in elementsInfo {
                let element = SwipeElement(info: elementInfo, scale:self.scale, parent:self, delegate:self.delegate!)
                if let subview = element.loadViewInternal(CGSizeMake(self.tableView.bounds.size.width, kH), screenDimension: self.screenDimension) {
                    subview.tag = subviewTag
                    cell.contentView.addSubview(subview)
                    children.append(element)
                } else {
                    cellError = "can't load"
                }
            }
        } else {
            cellError = "no elements"
        }
        
        if cellError != nil {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: kH))
            let l = UILabel(frame: CGRect(x:0, y:0, width: v.bounds.size.width, height: v.bounds.size.height))
            v.addSubview(l)
            cell.contentView.addSubview(v)
            l.text = "row \(indexPath.row) error " + cellError!
        }
        
        self.cellIndexPath = nil
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // SwipeView

    override func appendList(originator: SwipeNode, info: [String:AnyObject]) {
        if let itemsInfoArray = info["items"] as? [[String:AnyObject]] {
            for itemsInfo in itemsInfoArray {
                if let _ = itemsInfo["data"] as? [String:AnyObject] {
                    items.append(originator.evaluate(itemsInfo))
                } else {
                    items.append(itemsInfo)
                }
                self.tableView.reloadData()
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.items.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    override func appendList(originator: SwipeNode, name: String, up: Bool, info: [String:AnyObject])  -> Bool {
        if (name == "*" || self.name.caseInsensitiveCompare(name) == .OrderedSame) {
            appendList(originator, info: info)
            return true
        }
        
        var node: SwipeNode? = self
        
        if up {
            while node?.parent != nil {
                if let viewNode = node?.parent as? SwipeView {
                    for c in viewNode.children {
                        if let e = c as? SwipeElement {
                            if e.name.caseInsensitiveCompare(name) == .OrderedSame {
                                e.appendList(originator, info: info)
                                return true
                            }
                        }
                    }
                    
                    node = node?.parent
                } else {
                    return false
                }
            }
        } else {
            for c in children {
                if let e = c as? SwipeElement {
                    if e.updateElement(originator, name:name, up:up, info:info) {
                        return true
                    }
                }
            }
        }
        
        return false
    }

    // SwipeNode
    
    override func getPropertyValue(originator: SwipeNode, property: String) -> AnyObject? {
        switch (property) {
        case "selectedItem":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                return "\(indexPath.row)"
            } else {
                return "none"
            }
        default:
            return nil
        }
    }
    
    override func getPropertiesValue(originator: SwipeNode, info: [String:AnyObject]) -> AnyObject? {
        let prop = info.keys.first!
        switch (prop) {
        case "items":
            if let indexPath = self.cellIndexPath {
                var item = items[indexPath.row]
                if let itemStr = info["items"] as? String {
                    // ie "property":{"items":"data"}}
                    if let val = item[itemStr] as? String {
                        // ie "data":String
                        return val
                    } else if let valInfo = item[itemStr] as? [String:AnyObject] {
                        // ie "data":{...}
                        return originator.evaluate(valInfo)
                    }
                }
                // ie "property":{"items":{"data":{...}}}
                var path = info["items"] as! [String:AnyObject]
                var property = path.keys.first!
                
                while (true) {
                    if let next = path[property] as? String {
                        if let sub = item[property] as? [String:AnyObject] {
                            return sub[next]
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
