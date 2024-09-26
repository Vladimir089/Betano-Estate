//
//  EditCurrentBalanceViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class EditCurrentBalanceViewController: UIViewController {
    
    lazy var currentBalance = ""
    lazy var earnedCash = ""
    lazy var spentCash = ""
    
    var editBalancePublisher:PassthroughSubject<[String], Never>?
    lazy var cancellable = [AnyCancellable]()
    
    //ui
    lazy var currentTextField = createTextField()
    lazy var earnedTextField = createTextField()
    lazy var spentTextField = createTextField()
    
    lazy var saveButton = UIButton(type: .system)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Current Balance"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createInterface()
    }
    

    func createInterface() {
        let currentLabel = createLabel(text: "Current Balance")
        view.addSubview(currentLabel)
        currentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
        }
       
        currentTextField.text = currentBalance
        view.addSubview(currentTextField)
        currentTextField.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(currentLabel.snp.bottom).inset(-10)
        }
        
        let earnedLabel = createLabel(text: "Earned")
        view.addSubview(earnedLabel)
        earnedLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(currentTextField.snp.bottom).inset(-15)
        }
        
        earnedTextField.text = earnedCash
        view.addSubview(earnedTextField)
        earnedTextField.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(earnedLabel.snp.bottom).inset(-10)
        }
        
        let spentLabel = createLabel(text: "Spent")
        view.addSubview(spentLabel)
        spentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(earnedTextField.snp.bottom).inset(-15)
        }
        
        spentTextField.text = spentCash
        view.addSubview(spentTextField)
        spentTextField.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(spentLabel.snp.bottom).inset(-10)
        }
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideKBGesture)
        hideKBGesture.tapPublisher
            .sink { _ in
                self.checkButton()
                self.view.endEditing(true)
            }
            .store(in: &cancellable)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.backgroundColor = .secondary
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        saveButton.alpha = 0.3
        saveButton.isEnabled = false
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
        
        saveButton.tapPublisher
            .sink { _ in
                self.save()
            }
            .store(in: &cancellable)
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        textField.layer.cornerRadius = 12
        textField.keyboardType = .decimalPad
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.textColor = .black
        textField.placeholder = "0"
        textField.delegate = self
        return textField
    }
    
    private func checkButton() {
        if currentTextField.text?.count ?? 0 > 0, earnedTextField.text?.count ?? 0 > 0 , spentTextField.text?.count ?? 0 > 0 {
            saveButton.alpha = 1
            saveButton.isEnabled = true
        } else {
            saveButton.alpha = 0.3
            saveButton.isEnabled = false
        }
    }
    
    private func save() {
        let current: String = currentTextField.text ?? ""
        let earned: String = earnedTextField.text ?? ""
        let spent: String = spentTextField.text ?? ""
        
        UserDefaults.standard.setValue(current, forKey: "current")
        UserDefaults.standard.setValue(earned, forKey: "earned")
        UserDefaults.standard.setValue(spent, forKey: "spent")
        
        editBalancePublisher?.send([current, earned, spent])
        self.navigationController?.popViewController(animated: true)
    }

}


extension EditCurrentBalanceViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        checkButton()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkButton()
        return true
    }
}
