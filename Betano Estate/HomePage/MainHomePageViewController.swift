//
//  MainHomePageViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class MainHomePageViewController: UIViewController {
    
    //publishers
    lazy var cancellable = [AnyCancellable]()
    lazy var editBalancePublisher = PassthroughSubject<[String], Never>()
    lazy var transactionPublisher = PassthroughSubject<[transactions], Never>()
    var watchListPubliser: PassthroughSubject<Any, Never>? 
    
    //work
    var transactionArr: [transactions] = []
    var sortedHomeArr: [Home] = []
    
    //ui
    private var mainCollection: UICollectionView?
    private var watchListCollection: UICollectionView?
    private var transactionsCollection: UICollectionView?
    
    //balance
    private lazy var currentBalance = "0"
    private lazy var earnedCash = "0"
    private lazy var spentCash = "0"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Home"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        
    }
    
   


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        transactionArr = loadAthleteArrFromFile() ?? []
        sortHomeArr()
        checkItems()
        createInterface()
        subscribe()

    }
    
    private func checkItems() {
        if let current = UserDefaults.standard.string(forKey: "current") {
            currentBalance = current
        }
        if let earned = UserDefaults.standard.string(forKey: "earned") {
            earnedCash = earned
        }
        if let spent = UserDefaults.standard.string(forKey: "spent") {
            spentCash = spent
        }
    }
    
    private func subscribe() {
        editBalancePublisher
            .sink { Items in
                self.currentBalance = Items[0]
                self.earnedCash = Items[1]
                self.spentCash = Items[2]
                self.mainCollection?.reloadData()
            }
            .store(in: &cancellable)
        
        watchListPubliser?
            .sink { _ in
                self.sortHomeArr()
                self.watchListCollection?.reloadData()
                print("Home publicher is work")
            }
            .store(in: &cancellable)
        
       // watchListPubliser?.send(0) при снятии лайка с недвиги
        
        transactionPublisher
            .sink { items in
                self.transactionArr = items
                self.mainCollection?.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func sortHomeArr() {
        sortedHomeArr.removeAll()
        for i in propertiesArr {
            if i.isLike == true {
                sortedHomeArr.append(i)
            }
        }
        mainCollection?.reloadData()
    }
    
    private func loadAthleteArrFromFile() -> [transactions]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("transactions.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([transactions].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    

    private func createInterface() {
        
        mainCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.dataSource = self
            collection.backgroundColor = .white
            return collection
        }()
        view.addSubview(mainCollection!)
        mainCollection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
    }
    
    private func createBalanceView(color: UIColor, image: UIImage, text: String, type: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(15)
            make.height.width.equalTo(26)
        }
        
        let typeLabel = UILabel()
        typeLabel.text = type
        typeLabel.textColor = color
        typeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        view.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).inset(-5)
        }
        
        let countLabel = UILabel()
        countLabel.text = text
        countLabel.textColor = .black
        countLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        countLabel.textAlignment = .left
        
        view.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(15)
        }
        return view
    }
    
    private func editCurrentBalance() {
        let vc = EditCurrentBalanceViewController()
        vc.currentBalance = currentBalance == "$0" ? "" : currentBalance
        vc.earnedCash = earnedCash == "$0" ? "" : earnedCash
        vc.spentCash = spentCash == "$0" ? "" : spentCash
        vc.editBalancePublisher = editBalancePublisher
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func nilView(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        
        let emptyLabel = UILabel()
        emptyLabel.text = "Empty"
        emptyLabel.textColor = .black
        emptyLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY).offset(-2)
        }
        
        let botlabel = UILabel()
        botlabel.text = "You don’t have any properties in \(text)"
        botlabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.7)
        botlabel.font = .systemFont(ofSize: 13, weight: .regular)
        view.addSubview(botlabel)
        botlabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.centerY).offset(2)
        }
        
        return view
    }
    
    private func createTransaction() {
        let vc = AddTransactionViewController()
        vc.publisher = transactionPublisher
        vc.oldArr = transactionArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func delTransaction(index: Int) {
        transactionArr.remove(at: index)
        saveToFile()
    }
    
    private func saveToFile() {
        do {
            let data = try JSONEncoder().encode(transactionArr) //тут мкассив конвертируем в дату
            try saveAthleteArrToFile(data: data)
            mainCollection?.reloadData()
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
    
    private func dislikeHome(index: Int) {
        let item = sortedHomeArr[index]
        
        let index = propertiesArr.firstIndex(where: { $0.name == item.name &&  $0.isLike == item.isLike &&  $0.annualReturn == item.annualReturn &&  $0.description == item.description &&  $0.location == item.location &&  $0.occupancyRate == item.occupancyRate &&  $0.price == item.price &&  $0.propertyType == item.propertyType &&  $0.size == item.size &&  $0.status == item.status &&  $0.photos == item.photos })
        
        propertiesArr[index ?? 0].isLike = false
        watchListPubliser?.send(0)
        saveToFile()
    }
    
    private func openDetailVC(index: Int) {
        let item = sortedHomeArr[index]
        
        let index = propertiesArr.firstIndex(where: { $0.name == item.name &&  $0.isLike == item.isLike &&  $0.annualReturn == item.annualReturn &&  $0.description == item.description &&  $0.location == item.location &&  $0.occupancyRate == item.occupancyRate &&  $0.price == item.price &&  $0.propertyType == item.propertyType &&  $0.size == item.size &&  $0.status == item.status &&  $0.photos == item.photos })
        
        let vc = DetailPropertiesViewController()
        vc.publisher = watchListPubliser
        vc.index = index ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }

}


extension MainHomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollection {
            return 3
        } else if collectionView == watchListCollection {
            return sortedHomeArr.count //сделать чтобы тут отображались избранные
        } else {
            return transactionArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            switch indexPath.row {
            case 0:
                let viewCell = UIView()
                viewCell.layer.cornerRadius = 12
                viewCell.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
                cell.addSubview(viewCell)
                viewCell.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                let currentLabel = UILabel()
                currentLabel.text = "Current Balance"
                currentLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.5)
                currentLabel.font = .systemFont(ofSize: 15, weight: .semibold)
                viewCell.addSubview(currentLabel)
                currentLabel.snp.makeConstraints { make in
                    make.left.top.equalToSuperview().inset(15)
                }
                
                let balanceLabel = UILabel()
                balanceLabel.text = "$" + currentBalance
                balanceLabel.textColor = .black
                balanceLabel.font = .systemFont(ofSize: 34, weight: .bold)
                balanceLabel.textAlignment = .left
                viewCell.addSubview(balanceLabel)
                balanceLabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalTo(currentLabel.snp.bottom).inset(-5)
                }
                
                let editButton = UIButton(type: .system)
                editButton.setBackgroundImage(.editBalanceButt, for: .normal)
                viewCell.addSubview(editButton)
                editButton.snp.makeConstraints { make in
                    make.height.width.equalTo(28)
                    make.right.equalToSuperview().inset(15)
                    make.bottom.equalTo(balanceLabel.snp.centerY)
                }
                editButton.tapPublisher
                    .sink { _ in
                        self.editCurrentBalance()
                    }
                    .store(in: &cancellable)
                
                let earnedView = createBalanceView(color: UIColor(red: 79/255, green: 229/255, blue: 130/255, alpha: 1), image: .earned, text: "$" + earnedCash, type: "Earned")
                
                viewCell.addSubview(earnedView)
                earnedView.snp.makeConstraints { make in
                    make.left.bottom.equalToSuperview().inset(15)
                    make.right.equalTo(viewCell.snp.centerX).offset(-7.5)
                    make.height.equalTo(93)
                }
                
                let spentView = createBalanceView(color: UIColor(red: 255/255, green: 117/255, blue: 117/255, alpha: 1), image: .spent, text: "$" + spentCash, type: "Spent")
                
                viewCell.addSubview(spentView)
                spentView.snp.makeConstraints { make in
                    make.right.bottom.equalToSuperview().inset(15)
                    make.left.equalTo(viewCell.snp.centerX).offset(7.5)
                    make.height.equalTo(93)
                }
                
            case 1:
                //cell.backgroundColor = .red
                let topLabel = UILabel()
                topLabel.text = "Watchlist"
                topLabel.textColor = .black
                topLabel.font = .systemFont(ofSize: 22, weight: .semibold)
                cell.addSubview(topLabel)
                topLabel.snp.makeConstraints { make in
                    make.left.top.equalToSuperview()
                }
                if sortedHomeArr.count > 0 {
                    let layout = UICollectionViewFlowLayout()
                    watchListCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
                    watchListCollection?.backgroundColor = .white
                    watchListCollection?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "123")
                    watchListCollection?.delegate = self
                    watchListCollection?.dataSource = self
                    watchListCollection?.layer.cornerRadius = 24
                    watchListCollection?.showsHorizontalScrollIndicator = false
                    layout.scrollDirection = .horizontal
                    cell.addSubview(watchListCollection!)
                    watchListCollection?.snp.makeConstraints { make in
                        make.left.right.bottom.equalToSuperview()
                        make.top.equalTo(topLabel.snp.bottom).inset(-10)
                    }
                    
                } else {
                    let view = nilView(text: "watchlist")
                    cell.backgroundColor = .white
                    cell.addSubview(view)
                    view.snp.makeConstraints { make in
                        make.left.right.bottom.equalToSuperview()
                        make.top.equalTo(topLabel.snp.bottom)
                    }
                }
            case 2:
                
                let topLabel = UILabel()
                topLabel.text = "Transactions"
                topLabel.textColor = .black
                topLabel.font = .systemFont(ofSize: 22, weight: .semibold)
                cell.addSubview(topLabel)
                topLabel.snp.makeConstraints { make in
                    make.left.top.equalToSuperview()
                }
                
                let createTransactionButton = UIButton(type: .system)
                createTransactionButton.setBackgroundImage(.createTransaction, for: .normal)
                cell.addSubview(createTransactionButton)
                createTransactionButton.snp.makeConstraints { make in
                    make.centerY.equalTo(topLabel)
                    make.right.equalToSuperview().inset(15)
                    make.height.width.equalTo(34)
                }
                createTransactionButton.tapPublisher
                    .sink { _ in
                        self.createTransaction()
                    }
                    .store(in: &cancellable)
                
                if transactionArr.count > 0 {
                    transactionsCollection = {
                        let layout = UICollectionViewFlowLayout()
                        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
                        layout.scrollDirection = .vertical
                        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "3")
                        collection.showsVerticalScrollIndicator = false
                        collection.delegate = self
                        collection.dataSource = self
                        collection.backgroundColor = .white
                        return collection
                    }()
                    cell.addSubview(transactionsCollection!)
                    transactionsCollection?.snp.makeConstraints({ make in
                        make.left.right.bottom.equalToSuperview()
                        make.top.equalTo(createTransactionButton.snp.bottom).inset(-15)
                    })
                } else {
                    let view = nilView(text: "transactions")
                    cell.addSubview(view)
                    view.snp.makeConstraints { make in
                        make.left.right.bottom.equalToSuperview()
                        make.top.equalTo(createTransactionButton.snp.bottom)
                    }
                }
            default:
                print(1)
            }
            return cell
        } else if collectionView == watchListCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "123", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
            cell.layer.cornerRadius = 24
            cell.clipsToBounds = true
            
            let home = sortedHomeArr[indexPath.row]
            
            let imageView = UIImageView(image: UIImage(data: home.photos.first ?? Data()))
            cell.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(cell.snp.centerY)
            }
            
            let likeButton = UIButton(type: .system)
            likeButton.setBackgroundImage(.likeBut, for: .normal)
            cell.addSubview(likeButton)
            likeButton.snp.makeConstraints { make in
                make.right.top.equalToSuperview().inset(15)
                make.height.width.equalTo(30)
            }
            likeButton.tapPublisher
                .sink { _ in
                    self.dislikeHome(index: indexPath.row)
                }
                .store(in: &cancellable)
            
            let nameLabel = UILabel()
            nameLabel.text = sortedHomeArr[indexPath.row].name
            nameLabel.textColor = .black.withAlphaComponent(0.7)
            nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            nameLabel.textAlignment = .left
            nameLabel.numberOfLines = 2
            cell.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(10)
                make.top.equalTo(imageView.snp.bottom).inset(-10)
            }
            
            let countLabel = UILabel()
            countLabel.text = home.price
            countLabel.textColor = .black
            countLabel.textAlignment = .left
            countLabel.font = .systemFont(ofSize: 17, weight: .bold)
            cell.addSubview(countLabel)
            countLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(10)
                make.bottom.equalToSuperview().inset(10)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "3", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
            cell.layer.cornerRadius = 20
            
            let areaLabel = UILabel()
            areaLabel.text = transactionArr[indexPath.row].location
            areaLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.5)
            areaLabel.font = .systemFont(ofSize: 13, weight: .regular)
            areaLabel.textAlignment = .left
            
            cell.addSubview(areaLabel)
            areaLabel.snp.makeConstraints { make in
                make.bottom.equalTo(cell.snp.centerY).offset(-3)
                make.left.equalToSuperview().inset(15)
                make.width.equalTo(200)
            }
            
            let titleLabel = UILabel()
            titleLabel.text = transactionArr[indexPath.row].property
            titleLabel.textColor = .black
            titleLabel.textAlignment = .left
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            cell.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(cell.snp.centerY).offset(3)
                make.width.equalTo(200)
            }
            
            let trashButton = UIButton(type: .system)
            trashButton.setBackgroundImage(.del, for: .normal)
            cell.addSubview(trashButton)
            trashButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.width.equalTo(19)
                make.height.equalTo(22)
                make.centerY.equalToSuperview()
            }
            trashButton.tapPublisher
                .sink { _ in
                    self.delTransaction(index: indexPath.row)
                }
                .store(in: &cancellable)
            
            let imageView = UIImageView(image: transactionArr[indexPath.row].tupe == "Earning" ? .sell : .buy)
            cell.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.height.equalTo(20)
                make.width.equalTo(18)
                make.centerY.equalTo(areaLabel)
                make.right.equalTo(trashButton.snp.left).inset(-10)
            }
            
            let countLabel = UILabel()
            countLabel.text = transactionArr[indexPath.row].tupe == "Earning" ? "+$\(transactionArr[indexPath.row].amount)" : "-$\(transactionArr[indexPath.row].amount)"
            countLabel.font = .systemFont(ofSize: 15, weight: .regular)
            countLabel.textAlignment = .right
            countLabel.textColor = transactionArr[indexPath.row].tupe == "Earning" ? UIColor(red: 79/255, green: 229/255, blue: 130/255, alpha: 1): UIColor(red: 255/255, green: 117/255, blue: 117/255, alpha: 1)
            cell.addSubview(countLabel)
            countLabel.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(trashButton.snp.left).inset(-10)
                make.left.equalTo(titleLabel.snp.right).inset(-5)
            }
            
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollection {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.bounds.width, height: 196)
            } else if indexPath.row == 1 {
                return CGSize(width: collectionView.bounds.width, height: 240)
            } else {
                if transactionArr.count > 0 {
                    return CGSize(width: collectionView.bounds.width, height: 40 + CGFloat(85 * transactionArr.count) )
                } else {
                    return CGSize(width: collectionView.bounds.width, height: 240)
                }
            }
        } else if collectionView == watchListCollection {
            if sortedHomeArr.count > 0 {
                return CGSize(width: 162, height: 200)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 200)
            }
        } else {
            if transactionArr.count > 0 {
                return CGSize(width: collectionView.bounds.width, height: 74)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 200)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == watchListCollection {
            openDetailVC(index: indexPath.row)
        }
    }
    
}
