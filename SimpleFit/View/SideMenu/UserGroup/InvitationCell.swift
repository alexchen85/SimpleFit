//
//  InvitationCell.swift
//  SimpleFit
//
//  Created by shuo on 2020/12/18.
//

import UIKit

class InvitationCell: UITableViewCell {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var inviterImage: UIImageView!
    @IBOutlet weak var inviterNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBAction func acceptButtonDidTap(_ sender: Any) { callback?(id) }
    
    var callback: ((String) -> Void)?
    var id = ""
    
    func layoutCell(with invitation: Invitation) {
        
        acceptButton.applyBorder()
        inviterImage.layer.cornerRadius = inviterImage.frame.height / 2
        
        id = invitation.id
        inviterNameLabel.text = invitation.inviter.name
        inviterImage.loadImage(invitation.inviter.avatar)
        groupNameLabel.text = invitation.name
    }
}
