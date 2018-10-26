//
//  TableViewCell.swift
//  Intro à CoreML
//
//  Created by Thierry Huu on 26/10/2018.
//  Copyright © 2018 Matthieu PASSEREL. All rights reserved.
//

import UIKit
import Vision

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!

    var resultat: VNClassificationObservation!
    
    func setupCell(_ resultat: VNClassificationObservation) {
        self.resultat = resultat
        identifierLabel.text = self.resultat.identifier
        confidenceLabel.text = "Sûr à \(Int(self.resultat.confidence * 100)) %"
    }
}
