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
        layout.sectionHeadersPinToVisibleBounds = false
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
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    
    // MARK: - Properties
    var recentImages = [Photo](){
        didSet{
            self.photosCollectionView.reloadData()
        }
    }
    
    var pageNo = 0
    
    
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
        self.view.addSubview(self.activityIndicator)
        self.view.addSubview(self.photosCollectionView)
        
        self.photosCollectionView.dataSource = self
        self.photosCollectionView.delegate = self
        self.photosCollectionView.register(FRPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "FRPhotoCollectionViewCell")
        
    }
    
    private func setupUI(){
        
        
    }
    
    private func setupConstraints(){
        [
        self.photosCollectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        self.photosCollectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        self.photosCollectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        self.photosCollectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        self.activityIndicator.widthAnchor.constraint(equalToConstant: 30),
        self.activityIndicator.heightAnchor.constraint(equalToConstant: 40)
            
            
        ].forEach({$0.isActive = true})
    }
    // MARK: - Network Requests
    func getRecentImages(pageNo: Int){
        self.activityIndicator.startAnimating()
        KSNetworkManager.shared.sendRequest(methodType: .get, apiName: AppConstants.baseURL, parameters:["method":"flickr.photos.getRecent","per_page": "20","page": pageNo ,"api_key" : AppConstants.apiKey , "nojsoncallback": 1 , "extras": "url_s", "format": "json"], headers: nil) {[weak self] (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.activityIndicator.stopAnimating()
            }

            
            
            switch result{
        
            case .success(let data):
                if let data = data as? Data{
                    KSNetworkManager.shared.getJSONDecodedData(from: data) { (result: Swift.Result<FlickrJSONResponse, Error>) in
                        switch result{
                            
                        case .success(let data):
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else {return}
                                strongSelf.recentImages.append(contentsOf:  data.photos.photo.filter({ (photo) -> Bool in
                                    return !strongSelf.recentImages.contains(where: {$0.id == photo.id})
                                }))
                            }
                            break
                            
                        case .failure(let error):
                            print(error)
                            break
                        }
                        
                    }
                }
                break
                
            case .failure(let error):
                print(error)
                break
            }

            
            
        }

    }
    
    
}
extension FRHomeVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recentImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FRPhotoCollectionViewCell", for: indexPath) as? FRPhotoCollectionViewCell else{return UICollectionViewCell()}
        
        let data = self.recentImages[indexPath.item]
        
        cell.configureCell(image: data.urlS)
        
        
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
        if indexPath.item == self.recentImages.count - 4{
            self.pageNo += 1
            self.getRecentImages(pageNo: self.pageNo)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? FRPhotoCollectionViewCell else{return}
        
        cell.photoImageView.kf.cancelDownloadTask()
        
    }
    
}
