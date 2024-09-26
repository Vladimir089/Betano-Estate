//
//  AddTransactionViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class AddTransactionViewController: UIViewController {
    
    var oldArr: [transactions]?
    var publisher: PassthroughSubject<[transactions], Never>?
    
    private lazy var cancellable = [AnyCancellable]()
    
    //ui
    private lazy var propertyTextField = createTextField()
    private lazy var locationTextField = createTextField()
    private lazy var typeTextField = createTextField()
    private lazy var amountTextField = createTextField()
    
    private let items = ["Earning", "Spending"]
    private let pickerView = UIPickerView()
    private let toolBar = UIToolbar()
    private let saveButton = UIButton(type: .system)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Add transaction"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createInterface()
    }
    

    private func createInterface() {
        let propertyLabel = createLabel(text: "Property")
        view.addSubview(propertyLabel)
        propertyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
        }
        
        view.addSubview(propertyTextField)
        propertyTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(propertyLabel.snp.bottom).inset(-10)
        }
        
        
        let locationLabel = createLabel(text: "Location")
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(propertyTextField.snp.bottom).inset(-15)
        }
        
        view.addSubview(locationTextField)
        locationTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(locationLabel.snp.bottom).inset(-10)
        }
        
        let labelType = createLabel(text: "Type of transaction")
        view.addSubview(labelType)
        labelType.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(locationTextField.snp.bottom).inset(-15)
        }
        
        let selectTypeImageView = UIImageView(image: .selectTextField.resize(targetSize: CGSize(width: 14, height: 20)))
        let clearView = UIView()
        clearView.addSubview(selectTypeImageView)
       
        typeTextField.rightView = clearView
        typeTextField.rightView?.backgroundColor = .red
        typeTextField.addSubview(selectTypeImageView)
        selectTypeImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(14)
        }
        view.addSubview(typeTextField)
        typeTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(labelType.snp.bottom).inset(-10)
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
    
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        typeTextField.delegate = self
        typeTextField.inputView = pickerView
        typeTextField.inputAccessoryView = toolBar
        
        let amountLabel = createLabel(text: "Amount")
        view.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(typeTextField.snp.bottom).inset(-15)
        }
        
        view.addSubview(amountTextField)
        amountTextField.keyboardType = .decimalPad
        amountTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(54)
            make.top.equalTo(amountLabel.snp.bottom).inset(-10)
        }
        
        let tapGestureHideKB = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGestureHideKB)
        tapGestureHideKB.tapPublisher
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
    
    private func save() {
        let property: String = propertyTextField.text ?? ""
        let location: String = locationTextField.text ?? ""
        let type: String = typeTextField.text ?? ""
        let amount: String = amountTextField.text ?? ""
        
        let transaction = transactions(property: property, location: location, tupe: type, amount: amount)
        oldArr?.append(transaction)
        
        do {
            let data = try JSONEncoder().encode(oldArr ?? []) //тут мкассив конвертируем в дату
            try saveAthleteArrToFile(data: data)
           
            publisher?.send(oldArr ?? [])
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    private func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("transactions.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
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
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        //textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.textColor = .black
        textField.placeholder = "Enter"
        textField.delegate = self
        return textField
    }
    
    @objc private func doneTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        typeTextField.text = items[selectedRow]
        typeTextField.resignFirstResponder() // Закрываем колесо выбора
        checkButton()
    }
    
    private func checkButton() {
        if propertyTextField.text?.count ?? 0 > 0 , locationTextField.text?.count ?? 0 > 0, typeTextField.text?.count ?? 0 > 0 , amountTextField.text?.count ?? 0 > 0 {
            saveButton.alpha = 1
            saveButton.isEnabled = true
        } else {
            saveButton.alpha = 0.3
            saveButton.isEnabled = false
        }
    }
    
}


extension AddTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountTextField {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -100)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.checkButton()
            self.view.transform = .identity
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkButton()
        view.endEditing(true)
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
