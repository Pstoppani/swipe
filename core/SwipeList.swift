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

    private let info: [String:AnyObject]
    private let templatesInfo: [[String:AnyObject]]?
    private var items = [[String:AnyObject]]()
    private let scale:CGSize
    private var screenDimension = CGSize(width: 0, height: 0)
    weak var delegate:SwipeElementDelegate!
    var tableView: UITableView
    
    init(parent: SwipeNode, info: [String:AnyObject], scale: CGSize, frame: CGRect, screenDimension: CGSize, delegate:SwipeElementDelegate) {
        self.scale = scale
        self.screenDimension = screenDimension
        self.info = info
        self.delegate = delegate
        self.templatesInfo = self.info["rowTemplates"] as? [[String:AnyObject]]
        self.tableView = UITableView(frame: frame, style: .Plain)
        super.init(parent: parent)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .None
        self.tableView.allowsSelection = true
        self.tableView.backgroundColor = UIColor.clearColor()
        if let itemsInfo = info["rowItems"] as? [[String:AnyObject]] {
            items = itemsInfo
        }
        if let selectedIndex = self.info["selectedRow"] as? Int {
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
        self.cellIndexPath = indexPath
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        if let templates = self.templatesInfo {
            let template = templates[indexPath.row % templates.count]
                    let element = SwipeElement(info: template, scale:self.scale, parent:self, delegate:self.delegate!)
                    if let subview = element.loadViewInternal(CGSizeMake(self.tableView.bounds.size.width, kH), screenDimension: self.screenDimension) {
                        cell.contentView.addSubview(subview)
                        children.append(element)
                        /*
                        let item = items[indexPath.row]
                        if let actionsInfo = item["actions"] as? [[String:AnyObject]] {
                            for actionInfo in actionsInfo {
                                element.executeAction(self, action: SwipeAction(info:actionInfo))
                            }
                        }
                        */
                    }
            
        } else {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: kH))
            let l = UILabel(frame: CGRect(x:0, y:0, width: v.bounds.size.width, height: v.bounds.size.height))
            v.addSubview(l)
            cell.contentView.addSubview(v)
            l.text = "cell \(indexPath.row))"
        }
        
        self.cellIndexPath = nil
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // SwipeNode
    
    override func getPropertyValue(property: String) -> AnyObject? {
        switch (property) {
        case "selectedRow":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                return "\(indexPath.row)"
            } else {
                return "none"
            }
        default:
            return nil
        }
    }
    
    override func getPropertiesValue(info: [String:AnyObject]) -> AnyObject? {
        let prop = info.keys.first!
        switch (prop) {
        case "rowItems":
            if let indexPath = self.cellIndexPath {
                var item = items[indexPath.row]
                var path = info["rowItems"] as! [String:AnyObject]
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
