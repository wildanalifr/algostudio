//
//  ViewController.swift
//  algostudio
//
//  Created by Wildan on 16/02/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
   
    let urlString = "https://api.imgflip.com/get_memes"
    
    private var collectionView: UICollectionView?
    
    var result = [Meme]()
    
    struct MemeData: Codable {
        let success: Bool
        let data: MemeResponse
    }

    struct MemeResponse: Codable {
        let memes: [Meme]
    }

    struct Meme: Codable {
        let id: String
        let name: String
        let url: URL
        let width: Int
        let height: Int
        let boxCount: Int
        let captions: Int

        enum CodingKeys: String, CodingKey {
            case id, name, url, width, height
            case boxCount = "box_count"
            case captions
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            return refreshControl
    }()
    
    @objc private func refreshData() {
            fetchData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let itemWidth = (view.frame.size.width - 3 * layout.minimumInteritemSpacing) / 3
                layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
                let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func fetchData() {
        guard let url = URL(string: urlString) else {
                    print("Invalid URL")
                    collectionView?.refreshControl?.endRefreshing()
                    return
                }
                
                let task = URLSession.shared.dataTask(with: url) {[weak self] data, response, error in
                    guard let data = data, error == nil else {
                        self?.collectionView?.refreshControl?.endRefreshing()
                        return
                    }
                    
                    do {
                        let memeData = try JSONDecoder().decode(MemeData.self, from: data)
//                        print(memeData.data)
                        
                        DispatchQueue.main.async {
                            self?.result = memeData.data.memes
                            self?.collectionView?.reloadData()
                            self?.collectionView?.refreshControl?.endRefreshing()
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        self?.collectionView?.refreshControl?.endRefreshing()
                    }
                }
                
                task.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = result[indexPath.row].url.absoluteString
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageURLString)
        return cell
    }

}

