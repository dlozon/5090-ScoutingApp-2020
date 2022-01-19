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
    @IBOutlet weak var comments: UITextView!
    
    @IBOutlet weak var autonLower: GMStepper!
    @IBOutlet weak var autonUpper: GMStepper!
    @IBOutlet weak var crossSwitch: UISwitch!
    @IBOutlet weak var
    climbAttempt: UISwitch!
    @IBOutlet weak var
    climbSuccess: UISwitch!
    
    @IBOutlet weak var teleLower: GMStepper!
    @IBOutlet weak var teleUpper: GMStepper!
    @IBOutlet weak var
    rotateAttempt: UISwitch!
    @IBOutlet weak var
      rotateSuccess: UISwitch!
    @IBOutlet weak var
        positionAttempt: UISwitch!
    @IBOutlet weak var
        positionSuccess: UISwitch!
    
    @IBOutlet weak var disabledSwitch: UISwitch!

    
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
            
            self.matchNum.text = String((self.matchNum.text! as NSString).integerValue + 1)
            self.teamNum.text = ""
            self.comments.text = ""
            
            self.autonLower.value = 0.0
            self.autonUpper.value = 0.0

            self.crossSwitch.isOn = false
            
            self.teleLower.value = 0.0
            self.teleUpper.value = 0.0

            self.disabledSwitch.isOn = false
            
            self.QRCodeImageView.image = nil
            self.LogoImageView.isHidden = false
            
            self.climbSuccess.isOn = false
            self.climbAttempt.isOn = false
            
            self.rotateSuccess.isOn = false
            self.rotateAttempt.isOn = false
            
            self.positionSuccess.isOn = false
            self.positionAttempt.isOn = false
            // score calc form hide
            
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    //If attempt is turned off, so is success
    @IBAction func climbAttemptOff(_ sender: Any) {
        if(climbAttempt.isOn == false){
            self.climbSuccess.isOn = false
        }
    }
    
    @IBAction func rotateAttemptOff(_ sender: Any) {
        if(rotateAttempt.isOn == false){
            self.rotateSuccess.isOn = false
        }
    }
    
    @IBAction func positionAttemptOff(_ sender: Any) {
        if(positionAttempt.isOn == false){
            self.positionSuccess.isOn = false
        }
    }
    
    //If success is turned on, so is attempt
    @IBAction func climbSuccessOn(_ sender: Any) {
        if(climbSuccess.isOn == true){
            self.climbAttempt.isOn = true
        }
       }
  
    @IBAction func rotateSuccessOn(_ sender: Any) {
        if(rotateSuccess.isOn == true){
            self.rotateAttempt.isOn = true
        }
         }
    
    @IBAction func positionSuccessOn(_ sender: Any) {
        if(positionSuccess.isOn == true){
            self.positionAttempt.isOn = true
        }
         }
    
    @IBAction func createCode(_ sender: Any) {
        
        self.matchNum.endEditing(true)
        self.teamNum.endEditing(true)
        self.comments.endEditing(true)
        
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
        let autonLowerVal = autonLower.value
        let autonUpperVal = autonUpper.value
       
        let teleLowerVal = teleLower.value
        let teleUpperVal = teleUpper.value
        
        
        var commentText = comments?.text ?? ""
        commentText = commentText.replacingOccurrences(of: "\"", with: "\\\"")
        commentText = commentText.replacingOccurrences(of: ",", with: "&#44;")
        commentText = commentText.replacingOccurrences(of: "'|’", with: "&#39;", options: .regularExpression)
        
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+=-?().!_;&#")
        commentText = commentText.filter {okayChars.contains($0) }
    
        var matchText = matchNum?.text ?? ""
        matchText = matchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var teamText = teamNum?.text ?? ""
        teamText = teamText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var scoutText = scoutName?.text ?? ""
        scoutText = scoutText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        var myData = "\(teamText),\(matchText),\(String(format: "%.0f", autonLowerVal)),\(String(format: "%.0f", autonUpperVal)),\(String(format: "%.0f", teleLowerVal)),\(String(format: "%.0f", teleUpperVal)),\(crossSwitch.isOn),\(climbAttempt.isOn),\(climbSuccess.isOn),\(rotateAttempt.isOn),\(rotateSuccess.isOn),\(positionAttempt.isOn),\(positionSuccess.isOn),\(disabledSwitch.isOn),\(scoutText),\( "'" + commentText + "'"),\(newDate)"
        
        
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
        // show "showscore" viewcontroller
        QRCodeImageView.image = image
        print(String(describing: myData))
    }
    

}

