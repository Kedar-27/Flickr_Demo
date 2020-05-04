//
//  FRHomeVC.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 03/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import UIKit

class FRHomeVC: UIViewController {

    // MARK: - Outlets
    lazy var photosCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = UIScreen.main.bounds.height * 0.045
        layout.sectionHeadersPinToVisibleBounds = true
        layout.minimumInteritemSpacing = UIScreen.main.bounds.width * 0.025
        layout.sectionInset = UIEdgeInsets(top: UIScreen.main.bounds.height * 0.02, left: UIScreen.main.bounds.width * 0.025, bottom: UIScreen.main.bounds.height * 0.02, right: UIScreen.main.bounds.width * 0.025)
        let collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
       let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    
    var bottomLoadingIndicatorView: UIView = {
       var bottomView =  UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .white
        return bottomView
    }()
    
    

    // MARK: - Properties
    var isNewDataLoading = false
    var recentImagesDict = [Int: [Photo]]()
    var pageNo = 0
    var bottomLoadingIndicatorBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupVC()
        self.setupConstraints()
        self.getRecentImages(pageNo: self.pageNo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    private func setupVC(){
        self.view.backgroundColor = .white
        self.view.addSubview(self.bottomLoadingIndicatorView)
        self.view.addSubview(self.photosCollectionView)
        self.view.bringSubviewToFront(self.bottomLoadingIndicatorView)
        self.bottomLoadingIndicatorView.addSubview(self.activityIndicator)
    
        self.photosCollectionView.dataSource = self
        self.photosCollectionView.delegate = self
        self.photosCollectionView.register(FRPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "FRPhotoCollectionViewCell")
        self.photosCollectionView.register(FRHomeStickyHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FRHomeStickyHeaderCollectionReusableView")
        
    }
    
    private func setupUI(){
        
        
    }
    
    private func setupConstraints(){
        
        self.bottomLoadingIndicatorBottomConstraint = self.bottomLoadingIndicatorView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        
        [
        self.photosCollectionView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
        self.photosCollectionView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
        self.photosCollectionView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
        self.photosCollectionView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor),
            
        self.bottomLoadingIndicatorView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
        self.bottomLoadingIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        self.bottomLoadingIndicatorView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
        self.bottomLoadingIndicatorBottomConstraint!,
        
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.bottomLoadingIndicatorView.centerXAnchor),
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.bottomLoadingIndicatorView.centerYAnchor),
        self.activityIndicator.widthAnchor.constraint(equalToConstant: 30),
        self.activityIndicator.heightAnchor.constraint(equalToConstant: 40)
            
            
        ].forEach({$0.isActive = true})
    }
    
    // MARK: - Bottom Loading Indicator Animation
    
    func showLoadingIndicator(_ value: Bool){
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.bottomLoadingIndicatorBottomConstraint?.constant =  value ? 0 : 200
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [] , animations: {
                strongSelf.view.layoutIfNeeded()
            }, completion: nil)
        }


    }
    

    
    
    // MARK: - Network Requests
    func getRecentImages(pageNo: Int){
        self.showLoadingIndicator(true)
        KSNetworkManager.shared.sendRequest(methodType: .get, apiName: AppConstants.baseURL, parameters:["method":"flickr.photos.getRecent","per_page": "20","page": pageNo ,"api_key" : AppConstants.apiKey , "nojsoncallback": 1 , "extras": "url_s", "format": "json"], headers: nil) {[weak self] (result) in

            self?.showLoadingIndicator(false)

            
            switch result{
        
            case .success(let data):
                if let data = data as? Data{
                    KSNetworkManager.shared.getJSONDecodedData(from: data) { (result: Swift.Result<FlickrJSONResponse, Error>) in
                        switch result{
                            
                        case .success(let data):
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else {return}
                                
                                strongSelf.recentImagesDict[strongSelf.pageNo] = data.photos.photo.filter({ (photo) -> Bool in
                                    return !(strongSelf.recentImagesDict[strongSelf.pageNo]?.contains(where: {$0.id == photo.id}) ?? false)
                                })
                                
                                
                                strongSelf.photosCollectionView.reloadData()
                            }
                            break
                            
                        case .failure(let error):
                            print(error)
                            self?.pageNo -= 1
                            break
                        }
                        
                    }
                }
                break
                
            case .failure(let error):
                self?.pageNo -= 1
                print(error)
                break
            }

            
            
        }

    }
    
    
}
extension FRHomeVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.recentImagesDict.keys.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionKey = Array(self.recentImagesDict.keys.sorted())[section]
        
        return self.recentImagesDict[sectionKey]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FRPhotoCollectionViewCell", for: indexPath) as? FRPhotoCollectionViewCell else{return UICollectionViewCell()}
        let sectionKey = Array(self.recentImagesDict.keys.sorted())[indexPath.section]
        let data = self.recentImagesDict[sectionKey]?[indexPath.item]
        
        cell.configureCell(image: data?.urlS ?? "")
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = (collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow)
        
        
        return CGSize(width: size, height: UIScreen.main.bounds.width * 0.3)

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let sectionKey = Array(self.recentImagesDict.keys.sorted())[indexPath.section]

        if let data = self.recentImagesDict[sectionKey], indexPath.item == data.count - 4{
            self.pageNo += 1
            self.getRecentImages(pageNo: self.pageNo)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? FRPhotoCollectionViewCell else{return}
        
        cell.photoImageView.kf.cancelDownloadTask()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
                
        case UICollectionView.elementKindSectionHeader:
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FRHomeStickyHeaderCollectionReusableView", for: indexPath) as? FRHomeStickyHeaderCollectionReusableView else{return UICollectionReusableView()}
            
            let sectionKey = Array(self.recentImagesDict.keys.sorted())[indexPath.section]

            headerView.configureView(title: "\(sectionKey)")
            
            
            return headerView
            
    
            
        default:
            
            return UICollectionReusableView()
        }

        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: UIScreen.main.bounds.width * 0.1)
    }
    
    


}








