//
//  AvatarImage.swift
//  Drift
//
//  Created by Brian McDonald on 19/06/2017.
//  Copyright © 2017 Drift. All rights reserved.
//

import UIKit
import AlamofireImage

class AvatarView: UIView {
    
    var cornerRadius: CGFloat = 3{
        didSet{
            setUpCorners()
        }
    }
    
    var imageView = UIImageView()
    var initialsLabel = UILabel()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.isUserInteractionEnabled = true
        
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.addSubview(initialsLabel)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        layer.masksToBounds = true
        backgroundColor = ColorPalette.subtitleTextColor
        initialsLabel.isHidden = true
        
        setUpCorners()
    }
    
    func setUpCorners(){
        layer.cornerRadius = cornerRadius
    }
    
    func setUpForAvatarURL(avatarUrl: String?){
        if let avatarUrl = avatarUrl{
            if let url = URL(string: avatarUrl){
                
                initialsLabel.isHidden = true
 
                imageView.backgroundColor = UIColor.clear
                imageView.isHidden = false
                
                let placeholder = UIImage(named: "placeholderAvatar", in: Bundle.drift_getResourcesBundle(), compatibleWith: nil)
                
                imageView.af.setImage(withURL: url, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.1), runImageTransitionIfCached: false, completion: { result in
                    
                    self.initialsLabel.text = ""
                    switch result.result {
                    case .success(let image):
                        self.imageView.image = image
                        self.initialsLabel.isHidden = true
                    case .failure(_):
                        self.imageView.image = placeholder
                        
                    }
                    self.imageView.layer.removeAllAnimations()
                    
                })
            }
        }else{
            let placeholder = UIImage(named: "placeholderAvatar", in: Bundle.drift_getResourcesBundle(), compatibleWith: nil)
            self.imageView.image = placeholder
        }
    }
    
    func setupForBot(embed: Embed?){
        imageView.image = UIImage(named: "robot", in: Bundle.drift_getResourcesBundle(), compatibleWith: nil)
        if let backgroundColorString = embed?.backgroundColor {
            let color = UIColor(hexString: "#\(backgroundColorString)")
            imageView.backgroundColor = color
        }else{
            imageView.backgroundColor = ColorPalette.driftBlue
        }
    }
    
    func setupForUser(user: UserDisplayable?) {
        if let user = user {
            if user.bot {
                setupForBot(embed: DriftDataStore.sharedInstance.embed)
            } else {
                setUpForAvatarURL(avatarUrl: user.avatarURL)
            }
        } else {
            let placeholder = UIImage(named: "placeholderAvatar", in: Bundle.drift_getResourcesBundle(), compatibleWith: nil)
            self.imageView.image = placeholder
        }
    }
    
}
