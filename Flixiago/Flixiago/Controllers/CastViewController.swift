//
//  CastViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/6/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit

class CastViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var knownForView: UILabel!
    @IBOutlet weak var birthdayView: UILabel!
    @IBOutlet weak var birthPlaceView: UILabel!
    @IBOutlet weak var biographyView: UITextView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var rolesTable: UITableView!
    @IBOutlet weak var backButton: UIImageView!
    
    var personId: Int64?
    
    var roles: [PersonCombinedCreditsRole]?
    
    var photoImageManager: ImageScrollerManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let personId = personId
            else { return }

        // Do any additional setup after loading the view.
        TMDBService.getPerson(id: personId) { (person, error) in
            self.processPerson(person)
        }
        
        TMDBService.getPersonImages(id: personId) { (images, error) in
            guard let images = images
                else { return }
            
            self.processPersonImages(images)
        }
        
        TMDBService.getPersonRoles(id: personId) { (roles, error) in
            self.processRoles(roles)
        }
        
        rolesTable.delegate = self
        rolesTable.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backTapped))
        backButton.addGestureRecognizer(tapGesture)
        backButton.isUserInteractionEnabled = true
    }
    
    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func processPerson(_ person: Person?) {
        guard let person = person
            else { return }
        
        person.setImage(into: photoView)
        titleView.text = person.name
        knownForView.text = person.known_for_department
        birthdayView.text = person.formatBirthdate()
        biographyView.text = person.biography
        birthPlaceView.text = person.place_of_birth
        
        UIUtils.autosizeView(
            view: biographyView,
            constraintId: "biographyHeight",
            maxHeight: 500)
    }
    
    private func processPersonImages(_ images: PersonImages) {
        guard let profiles = images.profiles
            else { return }
        
        photoImageManager = ImageScrollerManager(view: photoCollection)
        
        photoImageManager?.setItems(
            items: profiles,
            tapCallback: nil)
    }
    
    private func processRoles(_ responseRoles: [PersonCombinedCreditsRole]?) {
        roles = responseRoles
        rolesTable.reloadData()
        
        UIUtils.sizeView(view: rolesTable,
                         constraintId: "rolesHeight",
                         size: CGSize(width: 0,
                                      height: Int(Float(roles?.count ?? 0) * 150.5)))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = rolesTable.dequeueReusableCell(withIdentifier: "rolesCell")
            as? RoleTableViewCell
            else { return UITableViewCell() }
        
        guard let target = roles?[indexPath.row]
            else { return UITableViewCell() }
        
        cell.setupCell(target)
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
