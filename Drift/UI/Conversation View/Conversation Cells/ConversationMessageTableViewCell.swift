//
//  ConversationMessageTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class ConversationMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    var message: Message? {
        didSet{
            displayMessage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayMessage() {
            self.messageTextView.text = ""
            self.nameLabel.text = "Brian McDonald"
            self.nameLabel.textColor = DriftDataStore.primaryFontColor
            self.messageTextView.text = self.message!.body
            self.messageTextView.textColor = DriftDataStore.secondaryFontColor
            self.timeLabel.textColor = DriftDataStore.secondaryFontColor
            self.timeLabel.text = self.dateFormatter.createdAtStringFromDate(self.message!.createdAt)
            do {
                let htmlStringData = (self.message!.body ?? "").dataUsingEncoding(NSUTF8StringEncoding)!
                let options: [String: AnyObject] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                    NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
                ]
                let attributedHTMLString = try NSMutableAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
                self.messageTextView.text = attributedHTMLString.string
            } catch {
                self.messageTextView.text = ""
            }
    }
    
}
