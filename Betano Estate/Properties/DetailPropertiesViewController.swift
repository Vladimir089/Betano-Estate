//
//  DetailPropertiesViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 30.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class DetailPropertiesViewController: UIViewController {
    
    var publisher: PassthroughSubject<Any, Never>?
    var index = 0
    var cancellables = [AnyCancellable]()
    
    private var collection: UICollectionView?
    private var isLocal = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = propertiesArr[index].name
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.subviews.forEach { $0.removeFromSuperview() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        subscribe()
        createInterface()
    }
    
    private func subscribe() {
        publisher?
            .sink(receiveValue: { _ in
                if self.isLocal == false {
                    DispatchQueue.main.async {
                        self.collection?.reloadData()
                    }
                }
                self.isLocal = false
            })
            .store(in: &cancellables)
    }

    private func createInterface() {
        collection = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.backgroundColor = .clear
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
            collection.dataSource = self
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        })
    }
    
    private func openEditPage() {
        let vc = AddNewPropertyViewController()
        vc.publisher = self.publisher
        vc.isNew = false
        vc.oldIndex = index
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func delHome() {
        isLocal = true
        propertiesArr.remove(at: index)
        
        do {
            let data = try JSONEncoder().encode(propertiesArr)
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
    
    private func likeHome() {
        propertiesArr[index].isLike =  propertiesArr[index].isLike ? false : true
        do {
            let data = try JSONEncoder().encode(propertiesArr)
            try saveAthleteArrToFile(data: data)
            publisher?.send(0)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    private func createStackSubviews(image: UIImage, topText: String, botText: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        view.layer.cornerRadius = 14
        
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.left.top.equalToSuperview().inset(15)
        }
        
        let topLabel = UILabel()
        topLabel.text = topText
        topLabel.textAlignment = .left
        topLabel.textColor = .black.withAlphaComponent(0.7)
        topLabel.font = .systemFont(ofSize: 12, weight: .regular)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-5)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(imageView)
        }
        
        let botLabel = UILabel()
        botLabel.text = botText
        botLabel.textColor = .black
        botLabel.textAlignment = .left
        botLabel.font = .systemFont(ofSize: 15, weight: .bold)
        view.addSubview(botLabel)
        botLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        
        return view
    }
    
    private func createEconomySubviews(topText: String, botText: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        view.layer.cornerRadius = 14
        
        let topLabel = UILabel()
        topLabel.text = topText
        topLabel.textColor = .black.withAlphaComponent(0.7)
        topLabel.font = .systemFont(ofSize: 12, weight: .regular)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(view.snp.centerY).offset(-5)
        }
        
        let botLabel = UILabel()
        botLabel.text = botText
        botLabel.textColor = .black
        botLabel.textAlignment = .left
        botLabel.font = .systemFont(ofSize: 15, weight: .bold)
        view.addSubview(botLabel)
        botLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.snp.centerY)
        }
        
        return view
    }

}

extension DetailPropertiesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            return 1
        } else {
            return propertiesArr[index].photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        if collectionView == collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white
            
            let home = propertiesArr[index]
            
         
            let imageViewImagies: UICollectionView = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
                collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
                collection.backgroundColor = .clear
                collection.showsHorizontalScrollIndicator = false
                collection.delegate = self
                collection.dataSource = self
                collection.layer.cornerRadius = 16
                collection.isPagingEnabled = true
                layout.minimumLineSpacing = 0
                return collection
            }()
            cell.addSubview(imageViewImagies)
            imageViewImagies.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(309)
            }
            
            
            let editButton = UIButton(type: .system)
            editButton.setBackgroundImage(.editProp, for: .normal)
            cell.addSubview(editButton)
            editButton.snp.makeConstraints { make in
                make.height.equalTo(22)
                make.width.equalTo(27)
                make.right.top.equalTo(imageViewImagies).inset(15)
            }
            editButton.tapPublisher
                .sink { _ in
                    self.openEditPage()
                }
                .store(in: &cancellables)
            
            let delButton = UIButton(type: .system)
            delButton.setBackgroundImage(.del, for: .normal)
            cell.addSubview(delButton)
            delButton.snp.makeConstraints { make in
                make.height.equalTo(22)
                make.width.equalTo(22)
                make.top.equalTo(imageViewImagies).inset(15)
                make.right.equalTo(editButton.snp.left).inset(-15)
            }
            delButton.tapPublisher
                .sink { _ in
                    self.delHome()
                }
                .store(in: &cancellables)
            
            let likeButton = UIButton(type: .system)
            likeButton.setBackgroundImage(home.isLike ? .likeBut : .disLikeBut, for: .normal)
            cell.addSubview(likeButton)
            likeButton.snp.makeConstraints { make in
                make.height.width.equalTo(36)
                make.right.bottom.equalTo(imageViewImagies).inset(15)
            }
            likeButton.tapPublisher
                .sink { _ in
                    self.likeHome()
                }
                .store(in: &cancellables)
            
            let typeView = UIView()
            typeView.backgroundColor = home.status == "Earning" ? .secondary : .primary
            typeView.layer.cornerRadius = 12
            cell.addSubview(typeView)
            typeView.snp.makeConstraints { make in
                make.left.bottom.equalTo(imageViewImagies).inset(15)
                make.height.equalTo(26)
                make.width.equalTo(86)
            }
            
            let imageViewType = UIImageView(image: home.status == "Earning" ? .earningItem : .aviaableItem)
            typeView.addSubview(imageViewType)
            imageViewType.snp.makeConstraints { make in
                make.height.width.equalTo(15)
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(5)
            }
            
            let typeLabel = UILabel()
            typeLabel.textColor = .black
            typeLabel.font = .systemFont(ofSize: 13, weight: .regular)
            typeLabel.text = home.status == "Earning" ? "Earning" : "Available"
            typeView.addSubview(typeLabel)
            typeLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(imageViewType.snp.right).inset(-5)
            }
            
            let nameLabel = UILabel()
            nameLabel.text = home.name
            nameLabel.textColor = .black
            nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
            nameLabel.textAlignment = .left
            cell.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(imageViewType.snp.bottom).inset(-25)
            }
            
            let deskLabel = UILabel()
            deskLabel.text = home.description
            deskLabel.numberOfLines = 2
            deskLabel.textAlignment = .left
            deskLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.5)
            deskLabel.font = .systemFont(ofSize: 15, weight: .regular)
            cell.addSubview(deskLabel)
            deskLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(nameLabel.snp.bottom).inset(-5)
            }
            
            let stackViewTop = UIStackView()
            stackViewTop.axis = .horizontal
            stackViewTop.spacing = 10
            stackViewTop.distribution = .fillEqually
            
            let priceView = createStackSubviews(image: .priceDetailProperty, topText: "Price", botText: home.price)
            let sizeView = createStackSubviews(image: .sizeDetailProperty, topText: "Size", botText: home.size)
            let locationView = createStackSubviews(image: .localDetailProperty, topText: "Location", botText: home.location)
            stackViewTop.addArrangedSubview(priceView)
            stackViewTop.addArrangedSubview(sizeView)
            stackViewTop.addArrangedSubview(locationView)
            
            cell.addSubview(stackViewTop)
            stackViewTop.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(deskLabel.snp.bottom).inset(-10)
                make.height.equalTo(82)
            }
            
            let economyLabel = UILabel()
            economyLabel.text = "Economy"
            economyLabel.textColor = .black
            economyLabel.font = .systemFont(ofSize: 20, weight: .bold)
            cell.addSubview(economyLabel)
            economyLabel.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalTo(stackViewTop.snp.bottom).inset(-15)
            }
            
            let botStackView = UIStackView()
            botStackView.axis = .vertical
            botStackView.spacing = 15
            botStackView.distribution = .fillEqually
            
            let typeViewStack = createEconomySubviews(topText: "Property Type", botText: home.propertyType)
            let returnViewStack = createEconomySubviews(topText: "Expected Annual Return", botText: home.annualReturn)
            let rateViewStack = createEconomySubviews(topText: "Occupancy Rate:", botText: home.occupancyRate)
            
            botStackView.addArrangedSubview(typeViewStack)
            botStackView.addArrangedSubview(returnViewStack)
            botStackView.addArrangedSubview(rateViewStack)
            
            cell.addSubview(botStackView)
            botStackView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(economyLabel.snp.bottom).inset(-15)
                make.bottom.equalToSuperview()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white
            let imageView = UIImageView(image: UIImage(data: propertiesArr[index].photos[indexPath.row]))
            cell.addSubview(imageView)
            imageView.layer.cornerRadius = 16
            imageView.clipsToBounds = true
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collection {
            return CGSize(width: collectionView.bounds.width, height: 750)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 309)
        }
        
    }
    
    
}
