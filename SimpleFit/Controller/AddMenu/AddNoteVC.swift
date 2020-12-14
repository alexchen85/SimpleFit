//
//  AddNoteVC.swift
//  SimpleFit
//
//  Created by shuo on 2020/12/3.
//

import UIKit

class AddNoteVC: BlurViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var backgroundCardView: CardView!
    
    @IBAction func dismiss(_ sender: Any) { dismiss(animated: true) }
    @IBAction func confirmButtonDidTap(_ sender: Any) {
        
        addNote()
        callback?(selectedYear, selectedMonth)
        dismiss(animated: true)
    }
    
    var callback: ((Int, Int) -> Void)?
    let provider = ChartProvider()
    var selectedDate = Date()
    var selectedYear = Date().year()
    var selectedMonth = Date().month()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
    }
    
    private func configureLayout() {
        
        datePicker.maximumDate = selectedDate
        datePicker.applyBorder()
        datePicker.addTarget(self, action: #selector(dateDidPick), for: .valueChanged)
        
        pinImage.transform = CGAffineTransform(rotationAngle: .pi * 0.2)
        cardView.transform = CGAffineTransform(rotationAngle: -.pi * 0.02)
        backgroundCardView.transform = CGAffineTransform(rotationAngle: .pi * 0.03)
    }
    
    private func addNote() {
        
        guard let note = noteTextView.text else { return }
        
        let daily = DailyData(note: note)
        provider.addDataWith(dailyData: daily, field: .note, date: selectedDate, completion: { [weak self] result in
            
            switch result {
            
            case .success(let note):
                let dateString = String(describing: self?.selectedDate)
                print("Success adding new note: \(note) on date: \(dateString)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    @objc private func dateDidPick(sender: UIDatePicker) {
        
        selectedDate = sender.date
        selectedYear = selectedDate.year()
        selectedMonth = selectedDate.month()
    }
}
