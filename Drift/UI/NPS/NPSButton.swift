//
//  NPSButton.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class NPSButton: UIButton {

    @IBInspectable var lineWidth: CGFloat = 1
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor(){
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var buttonColor: UIColor = UIColor.clearColor(){
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var titleColor: UIColor = UIColor.whiteColor(){
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            setupView()
        }
    }
    
    private func setupView(){
        backgroundColor = buttonColor
        layer.borderColor = borderColor.CGColor
        if cornerRadius == 0{
            layer.cornerRadius = self.frame.size.height/2
        }else{
            layer.cornerRadius = cornerRadius
        }
        
        layer.borderWidth = CGFloat(lineWidth)
        clipsToBounds = true
        
        setTitleColor(titleColor, forState: .Normal)
    }

    override func prepareForInterfaceBuilder() {
        backgroundColor = buttonColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    

}
