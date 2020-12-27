//
//  MemberDetailVC.swift
//  SimpleFit
//
//  Created by shuo on 2020/12/20.
//

import UIKit

class MemberDetailVC: BlurViewController {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func dismiss(_ sender: Any) { dismiss(animated: true) }
    @IBAction func removeButtonDidTap(_ sender: Any) { showRemoveAlert() }
    
    override var blurEffectStyle: UIBlurEffect.Style? { return .prominent }
    
    let provider = GroupProvider()
    var member = User()
    var group = Group(id: "", coverPhoto: "", name: "", content: "", category: "")
    var callback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
    }
    
    private func configureLayout() {
        
        removeButton.applyBorder()
        
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarImage.loadImage(member.avatar)
        nameLabel.text = member.name
        genderLabel.text = member.gender
    }
    
    private func showRemoveAlert() {
        
        let alert = SFAlertVC(title: "移除成員？", showAction: remove)
        
        removeButton.showButtonFeedbackAnimation { [weak self] in
            
            self?.present(alert, animated: true)
        }
    }
    
    private func remove() {
        
        SFProgressHUD.showLoading()
        
        provider.removeMember(of: member, in: group) { [weak self] result in
            
            switch result {
            
            case .success(let name):
                print("Success removing member: \(name) in group: \(String(describing: self?.group.name))")
                self?.callback?()
                self?.dismiss(animated: true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
