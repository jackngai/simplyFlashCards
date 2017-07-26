//
//  CardViewController.swift
//  simplyFlashCards
//
//  Created by Jack Ngai on 7/26/17.
//  Copyright © 2017 Jack Ngai. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    let wordView = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.6))
    let leftButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "left"), for: .normal)
        button.addTarget(self, action: #selector(previousWord), for: .touchUpInside)
        return button
    }()
    
    let rightButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "right"), for: .normal)
        button.addTarget(self, action: #selector(nextWord), for: .touchUpInside)
        return button
    }()
    
    var currentWordIndex = 0
    let wordsArray = ["Hope", "kiss", "things", "happy"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change View color to white
        view.backgroundColor = .white
        
        // Rotate view from portrait to landscape
        let landscape = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(landscape, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        // Set text of wordView to first word in wordsArray
        wordView.text = wordsArray[currentWordIndex]
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews(){
        view.addSubview(wordView)
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        
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
        leftButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leftButton.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        leftButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        rightButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rightButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rightButton.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
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
    
    

}
