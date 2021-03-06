//
//  KDEDateLabel.swift
//  KDEDateLabelExample
//
//  Created by Kevin DELANNOY on 23/12/14.
//  Copyright (c) 2014 Kevin Delannoy. All rights reserved.
//

import UIKit

// MARK: - KDEWeakReferencer
////////////////////////////////////////////////////////////////////////////////

private class KDEWeakReferencer<T: NSObject>: NSObject, Equatable {
    private(set) weak var value: T?

    init(value: T) {
        self.value = value
        super.init()
    }
}

private func ==<T: NSObject>(lhs: KDEWeakReferencer<T>, rhs: KDEWeakReferencer<T>) -> Bool {
    return (lhs.value == rhs.value)
}

////////////////////////////////////////////////////////////////////////////////


// MARK: - KDEDateLabelsHolder
////////////////////////////////////////////////////////////////////////////////

class KDEDateLabelsHolder: NSObject {
    private var dateLabels: [KDEWeakReferencer<KDEDateLabel>] = []

    private lazy var timer: NSTimer = {
        return NSTimer.scheduledTimerWithTimeInterval(0.5,
            target: self,
            selector: "timerTicked:",
            userInfo: nil,
            repeats: true)
    }()


    private class var instance: KDEDateLabelsHolder {
        struct KDESingleton {
            static var instance = KDEDateLabelsHolder()
        }
        return KDESingleton.instance
    }

    private override init() {
        super.init()
        self.timer.fire()
    }


    private func addReferencer(referencer: KDEWeakReferencer<KDEDateLabel>) {
        self.dateLabels.append(referencer)
    }

    private func removeReferencer(referencer: KDEWeakReferencer<KDEDateLabel>) {
        if let index = find(self.dateLabels, referencer) {
            self.dateLabels.removeAtIndex(index)
        }
    }


    func timerTicked(NSTimer) {
        for referencer in self.dateLabels {
            referencer.value?.updateText()
        }
    }
}

////////////////////////////////////////////////////////////////////////////////


// MARK: - KDEDateLabel
////////////////////////////////////////////////////////////////////////////////

public class KDEDateLabel: UILabel {
    private lazy var holder: KDEWeakReferencer<KDEDateLabel> = {
        return KDEWeakReferencer<KDEDateLabel>(value: self)
    }()


    // MARK: Initialization
    public override init() {
        super.init()
        self.commonInit()
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    private func commonInit() {
        KDEDateLabelsHolder.instance.addReferencer(self.holder)
    }

    // MARK: Deinit
    deinit {
        KDEDateLabelsHolder.instance.removeReferencer(self.holder)
    }


    // MARK: Date & Text updating
    public var date: NSDate? = nil {
        didSet {
            self.updateText()
        }
    }

    public var dateFormatTextBlock: ((date: NSDate) -> String)? {
        didSet {
            self.updateText()
        }
    }

    public var dateFormatAttributedTextBlock: ((date: NSDate) -> NSAttributedString)? {
        didSet {
            self.updateText()
        }
    }

    private func updateText() {
        if let date = date {
            if let dateFormatAttributedTextBlock = self.dateFormatAttributedTextBlock {
                self.attributedText = dateFormatAttributedTextBlock(date: date)
            }
            else if let dateFormatTextBlock = self.dateFormatTextBlock {
                self.text = dateFormatTextBlock(date: date)
            }
            else {
                self.text = "\(Int(fabs(date.timeIntervalSinceNow)))s ago"
            }
        }
        else {
            self.text = nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
