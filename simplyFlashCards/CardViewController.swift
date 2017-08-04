//
//  CardViewController.swift
//  simplyFlashCards
//
//  Created by Jack Ngai on 7/26/17.
//  Copyright © 2017 Jack Ngai. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class CardViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let wordView = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.6))
    let leftButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "left"), for: .normal)
        button.addTarget(self, action: #selector(previousWord), for: .touchUpInside)
        button.addTarget(self, action: #selector(goToFirstWord), for: .touchDragExit)
        return button
    }()
    
    let rightButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "right"), for: .normal)
        button.addTarget(self, action: #selector(nextWord), for: .touchUpInside)
        return button
    }()
    
    var currentWordIndex = 0
    var wordsArray = [String]()
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().clientID = "344544624789-ac7mvmocl98vc4ii0f03bmq5js46l7u9.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Change View color to white
        view.backgroundColor = .white
        
        // Rotate view from portrait to landscape
        let landscape = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(landscape, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        // Hide left button because current word is the first word
        leftButton.isHidden = true
        
        setupViews()
        
        // List available fonts in console
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .landscape
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            accessSheet()
        }
    }
    
    func setupViews(){
        view.addSubview(wordView)
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(signInButton)
        
        //Disable translate auto resizing mask for all subviews
        wordView.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Set font and font size
        let font = UIFont(name: "Avenir-Book", size: 72) ?? UIFont.systemFont(ofSize: 72)
        wordView.font = font
        
        wordView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        wordView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        leftButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        leftButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        leftButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
        
        rightButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        //rightButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
    }
    
    // Populate the wordsArray with words from a sample spreadsheet:
    // https://docs.google.com/spreadsheets/d/1dKNMohSlH0_5lmABLOKWE-0YRoqyBL8am6bnXfJ0YBU/edit
    func accessSheet() {
        output.text = "Getting sheet data..."
        let spreadsheetId = "1dKNMohSlH0_5lmABLOKWE-0YRoqyBL8am6bnXfJ0YBU"
        let range = "Sheet1!A2:B"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        let rows = result.values!
        
        if rows.isEmpty {
            showAlert(title: "No data found", message: "Is your spreadsheet empty?")
            return
        }
        
        for row in rows {
            
            let optionalWord = row[0] as? String
            
            if let word = optionalWord{
                
                wordsArray.append(word)
            }
        }
        
        // Set text of wordView to first word in wordsArray
        wordView.text = wordsArray[currentWordIndex]
        
    }
    
    
    @objc func previousWord(){
        print("left button tapped")
        switch(currentWordIndex){
        // if current word index is 0, break
        case 0:
            break
        // if current word index is 1, hide leftButton
        case 1:
            leftButton.isHidden = true
            fallthrough
        // Decrement current word index by 1 and update word view
        default:
            currentWordIndex -= 1
            wordView.text = wordsArray[currentWordIndex]
            
            // if current word index is 2 less than word array.count, unhide right button
            if currentWordIndex < wordsArray.count + 1{
                rightButton.isHidden = false
            }
        }
        
    }
    
    @objc func nextWord(){
        print("right button tapped")
        switch (wordsArray.count - currentWordIndex){
        // If current word index is 1 less than wordsArray.count, break
        case 1:
            break
        // If current word index is 2 less, hide right button, then fallthrough to default
        case 2:
            rightButton.isHidden = true
            fallthrough
        // Increment current word index by 1 and update word view
        default:
            currentWordIndex += 1
            wordView.text = wordsArray[currentWordIndex]
            
            // if current word index is greater than or equal 1, unhide left button
            if currentWordIndex >= 1{
                leftButton.isHidden = false
            }
        }
        
        
    }
    
    @objc func goToFirstWord(){
        // TODO: Set currentWordIndex to 0, hide left button, unhide right button, update word view
        currentWordIndex = 0
        leftButton.isHidden = true
        rightButton.isHidden = false
        wordView.text = wordsArray[currentWordIndex]
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
