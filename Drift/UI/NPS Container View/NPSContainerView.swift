//
//  NPSContainerView.swift
//  Drift
//
//  Created by Eoin O'Connell on 27/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

///Methods subviews can call on container
protocol ContainerSubViewDelegate: class {
    func subViewNeedsDismiss(campaign: Campaign, response: CampaignResponse)
    func subViewNeedsToPresent(campaign: Campaign, view: ContainerSubView)
}

///Abstract class used to ensure all container subviews have delegate back to container view and a campaign
class ContainerSubView:UIView {
    weak var delegate:ContainerSubViewDelegate?
    var campaign:Campaign?
}

///Container view for NPS
class NPSContainerView: CampaignView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewCenterYConstraint: NSLayoutConstraint!
    var campaign: Campaign!
    var viewStack: [ContainerWrapper] = []
    
    ///Wrapper on Subviews to hold reference to top and bottom constraints
    class ContainerWrapper {
        var view: ContainerSubView
        var topConstraint: NSLayoutConstraint
        var bottomConstraint: NSLayoutConstraint
        
        init(view: ContainerSubView, topConstraint: NSLayoutConstraint, bottomConstraint: NSLayoutConstraint){
            self.view = view
            self.topConstraint = topConstraint
            self.bottomConstraint = bottomConstraint
        }
    }
    
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if newWindow == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardWillHideNotification, object: nil)
        }
    }
    
    
    override func awakeFromNib() {
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 5
        containerView.hidden = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    ///Animate In initial View inside container
    func popUpContainer(initialView initialView: ContainerSubView){
        
        initialView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(initialView)

        containerView.addConstraint(NSLayoutConstraint(item: initialView, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: initialView, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.0, constant: 0))
        
        let top = NSLayoutConstraint(item: initialView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: initialView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0)
        containerView.addConstraint(top)
        containerView.addConstraint(bottom)
        
        initialView.delegate = self
        viewStack = [ContainerWrapper(view: initialView, topConstraint: top, bottomConstraint: bottom)]
        
        let background = DriftDataStore.sharedInstance.generateBackgroundColor()
        containerView.backgroundColor = background
        
        containerView.transform = CGAffineTransformMakeScale(0.00001, 0.00001)
        containerView.hidden = false
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.containerView.transform = CGAffineTransformMakeScale(1, 1)
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }, completion: nil)
    }
    
    ///Replace current top view with next view
    func replaceTopView(view: ContainerSubView) {

        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidden = true
        containerView.addSubview(view)
        
        containerView.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.0, constant: 0))
        
        let top = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: -containerView.frame.size.height)
        let bottom = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: -containerView.frame.size.height)
        containerView.addConstraint(top)
        containerView.addConstraint(bottom)
        
        layoutIfNeeded()
        
        if let currentContainer = viewStack.last {
            animateOff(currentContainer)
        }
        
        view.delegate = self
        let newContainer = ContainerWrapper(view: view, topConstraint: top, bottomConstraint: bottom)
        viewStack.append(newContainer)
        
        animateOn(newContainer)
    }
   
    ///Animate off view
    func animateOff(containerWrapper: ContainerWrapper) {
        
        containerWrapper.topConstraint.constant = containerView.frame.size.height
        containerWrapper.bottomConstraint.constant = containerView.frame.size.height
        setNeedsLayout()
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (success) -> Void in
            if success {
                containerWrapper.view.hidden = true
            }
        }
        
    }
    
    
    ///Animate on a given view
    func animateOn(containerWrapper: ContainerWrapper) {
        
        containerWrapper.view.hidden = false
        containerWrapper.topConstraint.constant = 0
        containerWrapper.bottomConstraint.constant = 0
        setNeedsLayout()
        UIView.animateWithDuration(0.7, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: nil)
    }

    @IBAction func didTapBackground() {
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: .NPS(.Dismissed))
    }
    
    
    ///Overrides
    ///Show NPS Container on window
    override func showOnWindow(window: UIWindow) {
        window.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: window, attribute: .Leading, multiplier: 1.0, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: window, attribute: .Trailing, multiplier: 1.0, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: window, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: 0))
        
    }
    
    ///Hide Container from view
    override func hideFromWindow() {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.alpha = 0
            }, completion: { (success) in
                if success {
                    self.removeFromSuperview()
                }
        })
    }
    
    ///Keyboard
    func keyboardShown(notification: NSNotification) {
        
        if let size = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            let height = min(size.height, size.width)
            let bottomContainerHeight = frame.size.height - (containerView.frame.size.height + containerView.frame.origin.y)
            
            if bottomContainerHeight < height {
                containerViewCenterYConstraint.constant = -(height - bottomContainerHeight + 30)
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.layoutIfNeeded()
                    }, completion: nil)
            }
        }
        
    }
    
    func keyboardHidden(notification: NSNotification) {
        containerViewCenterYConstraint.constant = 0
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: nil)
    }
}

extension NPSContainerView: ContainerSubViewDelegate{
    
    func subViewNeedsDismiss(campaign: Campaign, response: CampaignResponse){
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: response)
    }
    
    
    func subViewNeedsToPresent(campaign: Campaign, view: ContainerSubView) {
        self.campaign = campaign
        view.campaign = campaign
        replaceTopView(view)
    }
    
}
