//
//  CalenderView.swift
//  VoiceDiary
//
//  Created by dongyixuan on 16/6/20.
//  Copyright © 2016年 Lemur. All rights reserved.
//

import UIKit

class CalenderView: UIView {
    enum Tags: Int {
        case RoundedView = 101
        case Label = 102
    }
    var progress = 0
    var count = NSDate().getDayCountOfMonth()
    var offset = NSDate().startOfMonth()!.getDayOfTheWeek() - 1
    var selectedDay: Int? = nil
    var itemViews:[UIView] = []
    var firstUpdated = false
    var viewRecordTool: ViewRecordTool = ViewRecordTool()
    
    weak var playButton: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (!firstUpdated) {
            firstUpdated = true
            updateView()
            updateLayer()
        }
    }
    
}

// MARK: - Private
extension CalenderView {
    func setup() {
        self.backgroundColor = UIColor.clearColor()
        let date = NSDate()
        let recordModelList = viewRecordTool.getMonthDailyRecordList(month: date.getMonth(), year: date.getYear())
        for i in 0..<count {
            let v = UIView()
            let roundedView = UIView()
            let recordModel = recordModelList[i]
            if recordModel.isRecorded {
                roundedView.backgroundColor = recordModel.recordModel?.mood.color()
            } else {
                roundedView.backgroundColor = UIColor.Calendar.nothing
            }
            roundedView.tag = Tags.RoundedView.rawValue
            roundedView.layer.masksToBounds = true
            v.addSubview(roundedView)
            
            let label = UILabel()
            label.tag = Tags.Label.rawValue
            label.text = "\(i+1)"
            label.textColor = UIColor.Calendar.nothing
            label.textAlignment = .Left
            v.addSubview(label)
            
            let button = UIButton()
            button.tag = i+1
            button.addTarget(self, action: #selector(buttonClicked), forControlEvents: .TouchUpInside)
            v.addSubview(button)
            
            addSubview(v)
            itemViews.append(v)
        }
    }
    
    func updateView() {
        let colNum = 7
        let rowNum = (count + offset) / 7 + 1
        let width = self.bounds.width
        let height = self.bounds.height
        
        let itemWidth = width / CGFloat(colNum)
        let itemHeight = height / CGFloat(rowNum)
        
        for (i, v) in itemViews.enumerate() {
            let index = i + offset
            let x = CGFloat(index % colNum) * (itemWidth)
            let y = CGFloat(index / colNum) * (itemHeight)
            v.frame = CGRectMake(x, y, itemWidth, itemHeight)
            
            let margin = v.frame.width / 6
            let itemSize = itemWidth - margin * 2
            
            let roundedView = v.viewWithTag(Tags.RoundedView.rawValue)!
            roundedView.frame = CGRectMake(margin, margin, itemSize, itemSize)
            
            let label = v.viewWithTag(Tags.Label.rawValue)! as! UILabel
            label.alpha = CGFloat(progress)
            label.sizeToFit()
            let labelW = label.frame.size.width
            label.frame.origin.x = roundedView.frame.origin.x + (roundedView.frame.size.width - labelW) / 2
            label.frame.origin.y = roundedView.frame.maxY
            
            let button = v.viewWithTag(i+1) as! UIButton
            button.frame = CGRectMake(margin, margin, itemSize, itemSize)
            button.backgroundColor = UIColor.clearColor()
        }
    }
    
    
    
    func updateLayer(duration: NSTimeInterval = 0) {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration + 0.05
        for v in itemViews {
            let roundedView = v.viewWithTag(Tags.RoundedView.rawValue)!
            animation.fromValue = NSNumber(double: Double(roundedView.layer.cornerRadius))
            animation.toValue = NSNumber(double: Double(roundedView.frame.size.width / 2))
            roundedView.layer.addAnimation(animation, forKey: "cornerRadius")
        }
    }
    
    func updateRoundedViewColor(day: Int, mood: Mood){
        for (i, item) in itemViews.enumerate() {
            if (i+1) == day {
                for subview in item.subviews {
                    if subview.tag == Tags.RoundedView.rawValue {
                        subview.backgroundColor = mood.color()
                        subview.setNeedsDisplay()
                    }
                }
            }
        }
    }
}


// MARK: - Override
extension CalenderView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for item in itemViews {
            if (CGRectContainsPoint(item.frame, point)) {
                return true
            }
        }
        return false
    }
}
// MARK: - Selector
extension CalenderView {
    func buttonClicked(sender: UIButton){
        let day = sender.tag
        selectedDay = day
        let date = NSDate()
        let month = date.getMonth()
        let year = date.getYear()
        let record = viewRecordTool.getRecordByTime(day, month: month, year: year)
        playButton?.hidden = !record.isRecorded
        playButton?.userInteractionEnabled = record.isRecorded
    }
}