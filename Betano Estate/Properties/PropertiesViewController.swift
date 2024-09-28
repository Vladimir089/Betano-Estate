//
//  PropertiesViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 27.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class PropertiesViewController: UIViewController {
    
    var watchListPubliser = PassthroughSubject<Any, Never>()
    var cancellable = [AnyCancellable]()
    
    private var sortedProperties: [Home] = []
    private var selectedType = "Earning"
    
    //ui
    private var collection: UICollectionView?
    private let segmentItems = ["Earning", "Available"]
    private lazy var segmentedControl = UISegmentedControl(items: segmentItems)
    private var isLocalUpdate = false
    
    //other
    private lazy var properties = "0"
    private lazy var earning = "0"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Properties"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always

        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton

        let addButton = UIButton(type: .system)
        addButton.setBackgroundImage(UIImage.addProperties
            .resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
        navigationController?.navigationBar.addSubview(addButton)
        let targetView = self.navigationController?.navigationBar
        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(targetView?.snp.trailing ?? 1).offset(-15)
            make.bottom.equalTo(targetView?.snp.bottom ?? 1).offset(-6)
            make.height.width.equalTo(40)
        }
        addButton.tapPublisher
            .sink { _ in
                let vc = AddNewPropertyViewController()
                vc.publisher = self.watchListPubliser
                vc.isNew = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellable)
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        subscribe()
        checkStat()
        createInterface()
    }
    
    private func checkStat() {
        if let prop = UserDefaults.standard.string(forKey: "properties") {
            properties = prop
        }
        if let earn = UserDefaults.standard.string(forKey: "earnOnes") {
            earning = earn
        }
    }
    
    private func subscribe() {
        watchListPubliser
            .sink { _ in
                if self.isLocalUpdate {
                    self.isLocalUpdate = false
                    return
                }
                self.sortedProperties = propertiesArr
                self.changeCategory(category: "Earning")
                self.segmentedControl.selectedSegmentIndex = 0
                self.collection?.reloadData()
                print("Prop publicher is work")
            }
            .store(in: &cancellable)
        
        //watchListPubliser.send(0) при лайке дома
    }
    
   
    

    func createInterface() {
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .white
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.dataSource = self
            collection.showsVerticalScrollIndicator = false
            collection.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 15, right: 0)
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .secondary
        segmentedControl.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        segmentedControl.selectedSegmentIndexPublisher
            .sink { index in
                self.changeCategory(category: self.segmentItems[index])
            }
            .store(in: &cancellable)
    }
    
    private func createViews(topText: String, topImage: UIImage, mainText: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        view.layer.cornerRadius = 14
        
        let imageViewType = UIImageView(image: topImage.resize(targetSize: CGSize(width: 26, height: 26)))
        view.addSubview(imageViewType)
        imageViewType.snp.makeConstraints { make in
            make.height.width.equalTo(26)
            make.top.left.equalToSuperview().inset(15)
        }
        
        let topLabel = UILabel()
        topLabel.text = topText
        topLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.5)
        topLabel.font = .systemFont(ofSize: 13, weight: .regular)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(imageViewType.snp.right).inset(-5)
            make.centerY.equalTo(imageViewType)
        }
        
        let mainLabel = UILabel()
        mainLabel.text = mainText
        mainLabel.textColor = .black
        mainLabel.textAlignment = .left
        mainLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        
        let editImageView = UIImageView(image: .editTopsView.withRenderingMode(.alwaysTemplate))
        editImageView.tintColor = .gray.withAlphaComponent(0.8)
        view.addSubview(editImageView)
        editImageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(15)
            make.height.width.equalTo(24)
        }
        
        
        return view
    }
    
    private func openAlrertController() {
        let alertController = UIAlertController(title: "Change", message: "Change properties and earning ones", preferredStyle: .alert)
        alertController.addTextField()
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "Properties"
        alertController.textFields?[1].placeholder = "Earning ones"
        
        alertController.textFields?[0].text = properties == "0" ? "" : properties
        alertController.textFields?[1].text = earning == "0" ? "" : earning
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            UserDefaults.standard.setValue(alertController.textFields?[0].text ?? "", forKey: "properties")
            UserDefaults.standard.setValue(alertController.textFields?[1].text ?? "", forKey: "earnOnes")
            self.properties = alertController.textFields?[0].text ?? ""
            self.earning = alertController.textFields?[1].text ?? ""
            self.collection?.reloadData()
            self.dismiss(animated: true)
        }
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    
    private func changeCategory(category: String) {
        sortedProperties.removeAll()
        for i in propertiesArr {
            if i.status == category {
                sortedProperties.append(i)
            }
        }
        print(category)
        collection?.reloadData()
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
    
    func createStackViewSunviews(image: UIImage, text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.width.equalTo(28)
        }
        view.clipsToBounds = true
        
        let label = UILabel()
        label.text = text
        label.textColor = .black.withAlphaComponent(0.7)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        return view
    }

}


extension PropertiesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            return 2
        } else {
            return sortedProperties.count > 0 ? sortedProperties.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white //.orange
            var collectionCancellable = [AnyCancellable]()
            
            if indexPath.row == 0 {
                let leftView = createViews(topText: "Properties", topImage: .propertiesTopLeft, mainText: properties)
                cell.addSubview(leftView)
                leftView.snp.makeConstraints { make in
                    make.left.top.equalToSuperview()
                    make.height.equalTo(93)
                    make.right.equalTo(cell.snp.centerX).offset(-5)
                }
                
                let tapPubliserLeft = UITapGestureRecognizer(target: self, action: nil)
                leftView.addGestureRecognizer(tapPubliserLeft)
                tapPubliserLeft.tapPublisher.sink { _ in
                    self.openAlrertController()
                }
                .store(in: &collectionCancellable)
                
                let rightView = createViews(topText: "Earning ones", topImage: .earningsTopLeft, mainText: earning)
                cell.addSubview(rightView)
                rightView.snp.makeConstraints { make in
                    make.right.top.equalToSuperview()
                    make.height.equalTo(93)
                    make.left.equalTo(cell.snp.centerX).offset(5)
                }
                let tapPubliserRight = UITapGestureRecognizer(target: self, action: nil)
                rightView.addGestureRecognizer(tapPubliserRight)
                tapPubliserRight.tapPublisher.sink { _ in
                    self.openAlrertController()
                }
                .store(in: &collectionCancellable)
                
                
               
                cell.addSubview(segmentedControl)
                segmentedControl.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(rightView.snp.bottom).inset(-10)
                    make.height.equalTo(28)
                }
               
                
            } else {
               // cell.backgroundColor = .red
                let layout = UICollectionViewFlowLayout()
                let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
                collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
                layout.scrollDirection = .vertical
                collection.delegate = self
                collection.isScrollEnabled = false
                collection.dataSource = self
                cell.addSubview(collection)
                collection.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                //cell.backgroundColor = .orange
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white
            cell.clipsToBounds = true
            
            
            if sortedProperties.count > 0 {
                cell.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
                cell.layer.cornerRadius = 24
                
                let imageView = UIImageView(image: UIImage(data: sortedProperties[indexPath.row].photos.first ?? Data()))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                cell.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                let mainView = UIView()
                mainView.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
                cell.addSubview(mainView)
                mainView.snp.makeConstraints { make in
                    make.left.right.bottom.equalToSuperview()
                    make.top.equalTo(cell.snp.centerY).offset(-10)
                }
                
                let likeButton = UIButton(type: .system)
                likeButton.setBackgroundImage(sortedProperties[indexPath.row].isLike ? .likeBut : .disLikeBut, for: .normal)
                cell.addSubview(likeButton)
                likeButton.snp.makeConstraints { make in
                    make.right.top.equalToSuperview().inset(15)
                    make.height.width.equalTo(36)
                }
                likeButton.tapPublisher
                    .sink { _ in
                        let item = self.sortedProperties[indexPath.row]
                        let index = propertiesArr.firstIndex(where: { $0.name == item.name &&  $0.isLike == item.isLike &&  $0.annualReturn == item.annualReturn &&  $0.description == item.description &&  $0.location == item.location &&  $0.occupancyRate == item.occupancyRate &&  $0.price == item.price &&  $0.propertyType == item.propertyType &&  $0.size == item.size &&  $0.status == item.status &&  $0.photos == item.photos })
                        propertiesArr[index ?? 0].isLike.toggle()
                      
                        do {
                            let data = try JSONEncoder().encode(propertiesArr) //тут мкассив конвертируем в дату
                            try self.saveAthleteArrToFile(data: data)
                            self.isLocalUpdate = true
                            self.watchListPubliser.send(0)
                            self.changeCategory(category: self.segmentItems[self.segmentedControl.selectedSegmentIndex])
                        } catch {
                            print("Failed to encode or save athleteArr: \(error)")
                        }
                        
                    }
                    .store(in: &cancellable)
                
                let typeView = UIView()
                typeView.backgroundColor = sortedProperties[indexPath.row].status == "Earning" ? .secondary : .primary
                typeView.layer.cornerRadius = 12
                cell.addSubview(typeView)
                typeView.snp.makeConstraints { make in
                    make.left.top.equalToSuperview().inset(15)
                    make.height.equalTo(26)
                    make.width.equalTo(86)
                }
                
                let imageViewType = UIImageView(image: sortedProperties[indexPath.row].status == "Earning" ? .earningItem : .aviaableItem)
                typeView.addSubview(imageViewType)
                imageViewType.snp.makeConstraints { make in
                    make.height.width.equalTo(15)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().inset(5)
                }
                
                let typeLabel = UILabel()
                typeLabel.textColor = .black
                typeLabel.font = .systemFont(ofSize: 13, weight: .regular)
                typeLabel.text = sortedProperties[indexPath.row].status == "Earning" ? "Earning" : "Available"
                typeView.addSubview(typeLabel)
                typeLabel.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(imageViewType.snp.right).inset(-5)
                }
                
                let nameLabel = UILabel()
                nameLabel.text = sortedProperties[indexPath.row].name
                nameLabel.textColor = .black
                nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                nameLabel.textAlignment = .left
                mainView.addSubview(nameLabel)
                nameLabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalToSuperview().inset(15)
                }
                
                let desklabel = UILabel()
                desklabel.textColor = .black.withAlphaComponent(0.7)
                desklabel.font = .systemFont(ofSize: 13, weight: .regular)
                desklabel.text = sortedProperties[indexPath.row].description
                desklabel.numberOfLines = 2
                desklabel.textAlignment = .left
                mainView.addSubview(desklabel)
                desklabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalTo(nameLabel.snp.bottom).inset(-7)
                }
                
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 7
                stackView.distribution = .fillEqually
                
                let cashView = createStackViewSunviews(image: .priceStack, text: sortedProperties[indexPath.row].price)
                let sizeView = createStackViewSunviews(image: .sizeStack, text: sortedProperties[indexPath.row].size)
                let locView = createStackViewSunviews(image: .lockView, text: sortedProperties[indexPath.row].location)
                stackView.addArrangedSubview(cashView)
                stackView.addArrangedSubview(sizeView)
                stackView.addArrangedSubview(locView)
                
                cell.addSubview(stackView)
                stackView.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.bottom.equalToSuperview().inset(15)
                    make.height.equalTo(28)
                }
                
            } else {
                let topLabel = UILabel()
                topLabel.text = "Empty"
                topLabel.textColor = .black
                topLabel.font = .systemFont(ofSize: 22, weight: .bold)
                cell.addSubview(topLabel)
                topLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(cell.snp.centerY)
                }
                
                let botLabel = UILabel()
                botLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.7)
                botLabel.font = .systemFont(ofSize: 13, weight: .regular)
                botLabel.text = "You don’t have any properties"
                cell.addSubview(botLabel)
                botLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(cell.snp.centerY).offset(3)
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //перенеси в окно детали
        if collectionView != collection {
            let vc = AddNewPropertyViewController()
            vc.publisher = self.watchListPubliser
            vc.isNew = false
            
            let item = sortedProperties[indexPath.row]
            let index = propertiesArr.firstIndex(where: { $0.name == item.name &&  $0.isLike == item.isLike &&  $0.annualReturn == item.annualReturn &&  $0.description == item.description &&  $0.location == item.location &&  $0.occupancyRate == item.occupancyRate &&  $0.price == item.price &&  $0.propertyType == item.propertyType &&  $0.size == item.size &&  $0.status == item.status &&  $0.photos == item.photos })
            vc.oldIndex = index ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collection {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.bounds.width, height: 140)
            } else {
                if sortedProperties.count > 0 {
                    return CGSize(width: collectionView.bounds.width, height: CGFloat(sortedProperties.count * 252))
                } else {
                    return CGSize(width: collectionView.bounds.width, height: 243)
                }
            }
        } else {
            return CGSize(width: collectionView.bounds.width, height: 243)
        }
    }
}
