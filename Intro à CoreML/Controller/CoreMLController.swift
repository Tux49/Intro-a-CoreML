//
//  CoreMLController.swift
//  Intro à CoreML
//
//  Created by Thierry Huu on 25/10/2018.
//  Copyright © 2018 Matthieu PASSEREL. All rights reserved.
//

import UIKit
import CoreML
import Vision

class CoreMLController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var image: UIImage?
    var results: [VNClassificationObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imageView.image = image
        
        if let img = image, let data = img.pngData() {
            request(data: data)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func request(data: Data) {
        do {
            let modele = try VNCoreMLModel(for: MobileNet().model)
            let requete = VNCoreMLRequest(model: modele, completionHandler: response)
            let handler = VNImageRequestHandler(data: data, options: [:])
            try handler.perform([requete])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func response(_ requete: VNRequest, _ error: Error?) {
        if let resultats = requete.results as? [VNClassificationObservation] {
            self.results = resultats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension CoreMLController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CoreMLCell") as? TableViewCell {
            cell.setupCell(results[indexPath.row])
            return cell
        }
        return TableViewCell()
    }
}
