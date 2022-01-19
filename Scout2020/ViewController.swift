//
//  ViewController.swift
//  scout2019
//
//  Coded by Nathan Blume w/ Eli Goreta during FRC 2019
//  Copyleft CC-BY SA 2019 THS Robotics
//

import UIKit
import CoreImage

class ViewController: UIViewController , UITextFieldDelegate{
    
    // buttons and fields get added here\
    
    @IBOutlet weak var saveMatchData: UIButton!
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var LogoImageView: UIImageView!
    
    @IBOutlet weak var matchNum: UITextField!
    @IBOutlet weak var teamNum: UITextField!
    @IBOutlet weak var scoutName: UITextField!
    
    @IBOutlet weak var startingHabLevel: GMStepper!
    @IBOutlet weak var sandstormBonus: GMStepper!
    
    @IBOutlet weak var hatchLow: GMStepper!
    @IBOutlet weak var hatchMedium: GMStepper!
    @IBOutlet weak var hatchHigh: GMStepper!
    @IBOutlet weak var hatchSandstormSwitch: UISwitch!
    
    @IBOutlet weak var cargoLow: GMStepper!
    @IBOutlet weak var cargoMedium: GMStepper!
    @IBOutlet weak var cargoHigh: GMStepper!
    @IBOutlet weak var cargoSandstormSwitch: UISwitch!
    
    @IBOutlet weak var finalHabLevel: GMStepper!
    @IBOutlet weak var droppedPieces: GMStepper!
    
    @IBOutlet weak var disabledSwitch: UISwitch!
    @IBOutlet weak var foulSwitch: UISwitch!

    var myUuid = ""
    var prevData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoutName.delegate = self
        teamNum.delegate = self
        matchNum.delegate = self
        myUuid = UUID().uuidString
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // only enable show button if team number has a value
    @IBAction func numChange(_ sender: Any) {
        if((teamNum.text?.isEmpty)! || (scoutName.text?.isEmpty)! || (matchNum.text?.isEmpty)!){
            saveMatchData.isEnabled = false
        }else{
            saveMatchData.isEnabled = true
        }
    }
    
    // yes/no alert on reset, if yes set variables to 0
    @IBAction func clearForm(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Clear form?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.matchNum.text = ""
            self.teamNum.text = ""

            self.startingHabLevel.value = 0.0
            self.sandstormBonus.value = 0.0
            
            self.hatchLow.value = 0.0
            self.hatchMedium.value = 0.0
            self.hatchHigh.value = 0.0
            self.hatchSandstormSwitch.isOn = false
            
            self.cargoLow.value = 0.0
            self.cargoMedium.value = 0.0
            self.cargoHigh.value = 0.0
            self.cargoSandstormSwitch.isOn = false
            
            self.finalHabLevel.value = 0.0
            self.droppedPieces.value = 0.0

            self.disabledSwitch.isOn = false
            self.foulSwitch.isOn = false
            
            self.QRCodeImageView.image = nil
            self.LogoImageView.isHidden = false
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func createCode(_ sender: Any) {
        
        // create image filter
        var filter:CIFilter!
        
        // qr code function
        func generateQRCode(from string: String) -> UIImage? {
            let data = string.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: ["inputMessage" : data as Any, "inputCorrectionLevel":"M"]) { // changed line
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 3, y: 3)
                
                if let output = filter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: output)
                }
            }
            return nil
        }
        
        // make a date/time string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let newDate = dateFormatter.string(from: Date())
        
        // set variables
        
        let startinghabVal = startingHabLevel.value
        let sandstormbonusVal = sandstormBonus.value
        
        let hatchlowVal = hatchLow.value
        let hatchmediumVal = hatchMedium.value
        let hatchhighVal = hatchHigh.value

        let cargolowVal = cargoLow.value
        let cargomediumVal = cargoMedium.value
        let cargohighVal = cargoHigh.value

        let droppedpiecesVal = droppedPieces.value
        
        let finalhabVal = finalHabLevel.value
        
        var myData = "\(teamNum.text!),\(matchNum.text!),\(String(format: "%.0f", startinghabVal)),\(String(format:"%.0f", sandstormbonusVal)),\(String(format: "%.0f", hatchlowVal)),\(String(format: "%.0f", hatchmediumVal)),\(String(format: "%.0f", hatchhighVal)),\(hatchSandstormSwitch.isOn),\(String(format: "%.0f", cargolowVal)),\(String(format: "%.0f", cargomediumVal)),\(String(format: "%.0f", cargohighVal)),\(cargoSandstormSwitch.isOn),\(String(format: "%.0f", finalhabVal)),\(String(format: "%.0f", droppedpiecesVal)),\(disabledSwitch.isOn),\(foulSwitch.isOn),\(scoutName.text!),\(newDate)"
        
        
        // change uuid if data changed and append uuid
        if(myData != prevData){
            myUuid = UUID().uuidString
            prevData = myData
            myData = myData + "," + myUuid
        }else{
            myData = myData + "," + myUuid
        }
        
        
        // create qr code image
        let image = generateQRCode(from: String(describing: myData))
        
        // set view image to qr code and hide logo
        self.LogoImageView.isHidden = true
        QRCodeImageView.image = image
        print(String(describing: myData))
    }


}

