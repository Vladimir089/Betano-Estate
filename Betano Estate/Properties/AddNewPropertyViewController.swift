//
//  AddNewPropertyViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 28.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class AddNewPropertyViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    //work
    var publisher: PassthroughSubject<Any, Never>?
    private lazy var cancellable = [AnyCancellable]()
    
    //isNew
    var isNew = true
    var oldIndex = 0
    
    //UI
    private var collection: UICollectionView?
    private var items: [(UILabel, UITextField)] = []
    private var imageArr = [Data]()
    private var saveButton = UIButton(type: .system)
    
    //other
    private let itemsPicker = ["Earning", "Available"]
    private let pickerView = UIPickerView()
    private let toolBar = UIToolbar()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = isNew == true ? "Add property" : "Edit property"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.subviews.forEach { $0.removeFromSuperview() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadArr()
        checkIsNew()
        createInterface()
//        publisher?
//            .sink(receiveValue: { _ in
//                self.collection?.reloadData()
//            })
//            .store(in: &cancellable)
    }
    
    private func checkIsNew() {
        if isNew == false {
            let item = propertiesArr[oldIndex]
            imageArr = item.photos
            items[0].1.text = item.name
            items[1].1.text = item.status
            items[2].1.text = item.description
            items[3].1.text = item.price
            items[4].1.text = item.size
            items[5].1.text = item.location
            items[6].1.text = item.propertyType
            items[7].1.text = item.annualReturn
            items[8].1.text = item.occupancyRate
        }
    }

    private func createInterface() {
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.scrollDirection = .vertical
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.dataSource = self
            collection.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 15, right: 0)
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
        
        saveButton.backgroundColor = .secondary
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        saveButton.layer.cornerRadius = 16
        
        saveButton.tapPublisher
            .sink { _ in
                self.saveProp()
            }
            .store(in: &cancellable)
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideKBGesture)
        hideKBGesture.tapPublisher
            .sink { _ in
                self.checkButton()
                self.view.endEditing(true)
            }
            .store(in: &cancellable)
    }
    
    private func loadArr() {
        let labelTextArr = [("Name", "Enter"), ("Status", ""), ("Description", "Enter"), ("Price", "$"), ("Size", "Enter"), ("Location", "Enter"), ("Property type", "Enter"), ("Expected Annual Return", "Enter"), ("Occupancy rate", "Enter")]
        for i in labelTextArr {
            let label = UILabel()
            label.text = i.0
            label.textColor = .black
            label.font = .systemFont(ofSize: 15, weight: .semibold)
            
            let textField = UITextField()
            textField.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
            textField.layer.cornerRadius = 12
            textField.placeholder = i.1
            textField.delegate = self
            textField.textColor = .black
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightViewMode = .always
            textField.leftViewMode = .always
            items.append((label, textField))
        }
    }
    
    @objc private func doneTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        items[1].1.text = itemsPicker[selectedRow]
        items[1].1.resignFirstResponder() // Закрываем колесо выбора
        checkButton()
    }
    
    private func saveProp() {
        
        let name: String = items[0].1.text ?? ""
        let status: String = items[1].1.text ?? ""
        let description: String = items[2].1.text ?? ""
        let price: String = items[3].1.text ?? ""
        let size: String = items[4].1.text ?? ""
        let location: String = items[5].1.text ?? ""
        let propertyType: String = items[6].1.text ?? ""
        let annualReturn: String = items[7].1.text ?? ""
        let occupancyRate: String = items[8].1.text ?? ""
        
        
        let prop = Home(isLike: isNew ? false: propertiesArr[oldIndex].isLike, name: name, status: status, description: description, price: price, size: size, location: location, propertyType: propertyType, annualReturn: annualReturn, occupancyRate: occupancyRate, photos: imageArr)
        
        if isNew {
            propertiesArr.append(prop)
        } else {
            propertiesArr[oldIndex] = prop
        }

         do {
             let data = try JSONEncoder().encode(propertiesArr) //тут мкассив конвертируем в дату
             try saveAthleteArrToFile(data: data)
             publisher?.send(0)
             navigationController?.popViewController(animated: true)
         } catch {
             print("Failed to encode or save athleteArr: \(error)")
         }
    }
    
    private func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("home.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    private func checkButton() {
        var isTextYes = false
        for textField in items {
            if textField.1.text?.count ?? 0 > 0, imageArr.count > 0 {
                isTextYes = true
            } else {
                isTextYes = false
                break
            }
        }
        
        if isTextYes == true, imageArr.count > 0 {
            saveButton.alpha = 1
            saveButton.isEnabled = true
        } else {
            saveButton.alpha = 0.5
            saveButton.isEnabled = false
        }
    }
    
    private func setImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[.originalImage] as? UIImage {
            imageArr.append(pickedImage.jpegData(compressionQuality: 1) ?? Data())
            collection?.reloadData()
            checkButton()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private func randomDate() -> String {
        // Генерируем случайное время
        let randomTimeInterval = TimeInterval(arc4random_uniform(60 * 60 * 24 * 365)) // случайная дата за последний год
        let randomDate = Date().addingTimeInterval(-randomTimeInterval)

        // Настраиваем форматтер для вывода даты в нужном формате
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d h:mm a" // Пример формата: May 3 12:57 PM
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Устанавливаем локаль для английского формата

        // Преобразуем случайную дату в строку
        let formattedDate = dateFormatter.string(from: randomDate)
        
        return formattedDate
    }
    
    private func delImage(index: Int) {
        print(index)
        imageArr.remove(at: index)
        collection?.reloadData()
        checkButton()
    }
    
}

extension AddNewPropertyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 2 + imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        
        let isLastItem = indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1
        
        if indexPath.row < items.count {
            cell.addSubview(items[indexPath.row].0)
            items[indexPath.row].0.snp.makeConstraints { make in
                make.left.top.equalToSuperview()
            }
            
            cell.addSubview(items[indexPath.row].1)
            items[indexPath.row].1.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(54)
            }
            
            if indexPath.row == 1 {
                let selectTypeImageView = UIImageView(image: .selectTextField.resize(targetSize: CGSize(width: 14, height: 20)))
                let clearView = UIView()
                clearView.addSubview(selectTypeImageView)
                
                items[indexPath.row].1.rightView = clearView
                items[indexPath.row].1.rightView?.backgroundColor = .red
                items[indexPath.row].1.addSubview(selectTypeImageView)
                selectTypeImageView.snp.makeConstraints { make in
                    make.right.equalToSuperview().inset(10)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(20)
                    make.width.equalTo(14)
                }
                pickerView.delegate = self
                pickerView.dataSource = self
                pickerView.backgroundColor = .white
                
                toolBar.sizeToFit()
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
                let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                toolBar.setItems([spaceButton, doneButton], animated: false)
                toolBar.isUserInteractionEnabled = true
                items[indexPath.row].1.inputView = pickerView
                items[indexPath.row].1.inputAccessoryView = toolBar
            }
        } else {
            if indexPath.row == 9 {
                let button = UIButton(type: .system)
                button.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
                button.layer.cornerRadius = 10
                let imageView = UIImageView(image: .addPhoto.resize(targetSize: CGSize(width: 21, height: 21)))
                button.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().inset(10)
                    make.height.width.equalTo(21)
                }
                
                let photoLabel = UILabel()
                photoLabel.text = "Attach photo"
                photoLabel.textColor = .black
                photoLabel.font = .systemFont(ofSize: 13, weight: .regular)
                button.addSubview(photoLabel)
                photoLabel.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(imageView.snp.right).inset(-3)
                }
                
                cell.addSubview(button)
                button.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.height.equalTo(37)
                    make.width.equalTo(119)
                }
                button.tapPublisher
                    .sink { _ in
                        self.setImage()
                    }
                    .store(in: &cancellable)
            } else if isLastItem {
                cell.addSubview(saveButton)
                saveButton.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            } else {
                cell.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
                cell.layer.cornerRadius = 9
                let imageViewFile = UIImageView(image: .fileIcon)
                cell.addSubview(imageViewFile)
                imageViewFile.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(16)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().inset(15)
                }
                
                let labelName = UILabel()
                labelName.text = "Photo " + randomString(length: 9) + ".jpg"
                labelName.textColor = .black
                labelName.font = .systemFont(ofSize: 15, weight: .regular)
                cell.addSubview(labelName)
                labelName.snp.makeConstraints { make in
                    make.left.equalTo(imageViewFile.snp.right).inset(-10)
                    make.bottom.equalTo(cell.snp.centerY)
                }
                
                let dateLabel = UILabel()
                dateLabel.text = randomDate() + " 3 KB"
                dateLabel.textColor = .black.withAlphaComponent(0.5)
                dateLabel.font = .systemFont(ofSize: 11, weight: .regular)
                cell.addSubview(dateLabel)
                dateLabel.snp.makeConstraints { make in
                    make.left.equalTo(imageViewFile.snp.right).inset(-10)
                    make.top.equalTo(cell.snp.centerY)
                }
                
                let delImageButton = UIButton(type: .system)
                delImageButton.setBackgroundImage(.delImageInEdit, for: .normal)
                cell.addSubview(delImageButton)
                delImageButton.snp.makeConstraints { make in
                    make.top.right.equalToSuperview().inset(10)
                    make.height.width.equalTo(21)
                }
                
                delImageButton.tapPublisher
                    .sink { _ in
                        self.delImage(index: indexPath.row - 10)
                    }
                    .store(in: &cancellable)
            }
        }
       

        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row > 8 {
            return CGSize(width: collectionView.bounds.width, height: 51)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 80)
        }
       
    }
    
    
    
}


extension AddNewPropertyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return itemsPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return itemsPicker[row]
    }
}


extension AddNewPropertyViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == items[7].1 ||  textField == items[8].1  {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -230)
                
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
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
