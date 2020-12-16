//
//  AddGroupVC.swift
//  SimpleFit
//
//  Created by shuo on 2020/12/14.
//

import UIKit

class AddGroupVC: BlurViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerAvatarImage: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var groupTitleTextField: UITextField!
    @IBOutlet weak var groupIntroTextView: UITextView!
    @IBOutlet weak var coverPhotoButton: UIButton!
    
    @IBAction func dismiss(_ sender: Any) { dismiss(animated: true) }
    @IBAction func confirmButtonDidTap(_ sender: Any) { uploadCoverPhoto() }
    @IBAction func photoButtonDidTap(_ sender: Any) { showPhotoAlert() }
    
    let provider = GroupProvider()
    var newGroup = Group(coverPhoto: "", title: "", content: "", category: "")
    var callback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
    }
    
    private func configureLayout() {
        
        dateLabel.text = DateProvider.dateToDateString(Date())
        
        titleLabel.applyBorder()
        categoryTextField.applyBorder()
        groupTitleTextField.applyBorder()
        groupIntroTextView.applyBorder()
        
        categoryTextField.delegate = self
        groupTitleTextField.delegate = self
        groupIntroTextView.delegate = self
        
        categoryTextField.layer.cornerRadius = 5
        categoryTextField.layer.borderColor = UIColor.systemGray4.cgColor
        groupTitleTextField.layer.cornerRadius = 5
        groupTitleTextField.layer.borderColor = UIColor.systemGray4.cgColor
        groupIntroTextView.layer.cornerRadius = 5
        groupIntroTextView.layer.borderColor = UIColor.systemGray4.cgColor
        
        ownerNameLabel.text = newGroup.owner.name
        ownerAvatarImage.loadImage(newGroup.owner.avatar)
        ownerAvatarImage.applyBorder()
        ownerAvatarImage.layer.borderWidth = 2
    }
    
    private func showPhotoAlert() {
        
        let alert = PhotoAlertVC(showAction: showImagePicker(type:))
        present(alert, animated: true, completion: nil)
    }
    
    private func showImagePicker(type: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func uploadCoverPhoto() {
        
        guard let coverPhotoImage = coverPhotoButton.currentImage else { return }
        
        provider.uploadPhotoWith(image: coverPhotoImage) { [weak self] result in
            
            switch result {
            
            case .success(let url):
                self?.newGroup.coverPhoto = "\(url)"
                self?.addGroup()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func addGroup() {
        
        provider.addGroupWith(group: newGroup) { [weak self] result in
            
            switch result {
            
            case .success(let group):
                print("Success adding new group: \(group)")
                self?.callback?()
                self?.dismiss(animated: true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension AddGroupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let selectedPhoto = info[.editedImage] as? UIImage else { return }
        coverPhotoButton.setImage(selectedPhoto, for: .normal)
        dismiss(animated: true)
    }
}

extension AddGroupVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.borderWidth = 2
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        
        switch textField {
        
        case categoryTextField:
            guard let category = categoryTextField.text else { return }
            newGroup.category = category
            
        case groupTitleTextField:
            guard let title = groupTitleTextField.text else { return }
            newGroup.title = title
            
        default: break
        }
    }
}

extension AddGroupVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.borderWidth = 2
        
        if textView.textColor == UIColor.systemGray3 {
            
            textView.text = nil
            textView.textColor = .systemGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        
        if textView.text.isEmpty {
            
            textView.textColor = UIColor.systemGray3
            textView.text = "請輸入介紹"
        }
        
        guard let content = textView.text else { return }
        newGroup.content = content
    }
}
