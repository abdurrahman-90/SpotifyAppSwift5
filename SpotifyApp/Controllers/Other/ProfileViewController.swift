//
//  ProfileViewController.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 12.04.2021.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    private var models = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        title = "Profile"
        view.addSubview(tableView)
        fetchProfile()
        view.backgroundColor = .systemBackground
 
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func fetchProfile(){
        APICaller.shared.getCurrentProfile { result in
            switch result{
            case .success(let model):
                self.updateUI(model: model)
            case .failure(let error):
                print(error.localizedDescription)
                self.failedToGetProfile()
            }
        }
    }
    private func updateUI(model :UserProfile){
        // configure table models
        models.append("Full Name : \(model.display_name)")
        models.append("Email Address: \(model.email)")
        models.append("User ID: \(model.id)")
        models.append("Plan: \(model.product)")
 //       createTableHeader(with: model.image.first!.url)
        
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    private func createTableHeader (with string : String?) {
        guard let urlString = string , let url = URL(string: urlString) else {
            return
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))

        let imageSize :CGFloat = headerView.height/2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.sd_setImage(with: url, completed: nil)

        tableView.tableHeaderView = headerView
    }
    
    private func failedToGetProfile(){
        DispatchQueue.main.async {
            let label = UILabel(frame: .zero)
            label.text = "Failed to load profile"
            label.sizeToFit()
            label.textColor = .secondaryLabel
            self.view.addSubview(label)
            label.center = self.view.center
        }
    }
    
 // tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model
        return cell
    }
    

}
