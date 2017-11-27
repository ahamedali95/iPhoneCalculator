//
//  ViewController.swift
//  calculator4
//
//  Created by Ahamed Abbas on 9/12/17.
//  Copyright © 2017 Ahamed Abbas. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet weak var display: UILabel!
    
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    var textInDisplay2: String = "";
    
    var userInTheMiddleOfTyping: Bool = false;
    
    @IBAction func touchDigit(_ sender: UIButton)
    {
        sender.showsTouchWhenHighlighted = true;
        let digit = sender.currentTitle!; //computed property
        if(userInTheMiddleOfTyping)
        {
            if(digit == ".")
            {
                if (display.text!.range(of: ".") == nil)
                {
                    let textCurrentlyInDisplay = display.text!;
                    display.text = textCurrentlyInDisplay + digit;
                }
            }
            
            else
            {
                let textCurrentlyInDisplay = display.text!;
                display.text = textCurrentlyInDisplay + digit;
                
                
            }
            
        }
            
        else
        {
            display.text = digit;
            userInTheMiddleOfTyping = true;
        }
        
    }
    
    var displayValue: Double
    {
        get
        {
            
            return Double(display.text!)!;
            
        }
        
        set
        {
            //display.text = String(newValue);
        }
    }
    
    var displayValue2: String
    {
        get
        {
            
            return "";
            
        }
        
        set
        {
            display.text = newValue;
        }
    }
    

    private var brain: CalculatorBrain = CalculatorBrain();
    
    @IBAction func performOperation(_ sender: UIButton)
    {
        sender.showsTouchWhenHighlighted = true;
        if(userInTheMiddleOfTyping)
        {
            brain.setOperand(displayValue);
            userInTheMiddleOfTyping = false;
        }
        
        
        if let mathematicalSymbol = sender.currentTitle
        {
            brain.performOperation(mathematicalSymbol);
        }
        
        if let result = brain.result
        {
            let formatNumber = NumberFormatter();
            formatNumber.numberStyle = .decimal;
            formatNumber.maximumFractionDigits = 6;
            formatNumber.minimumFractionDigits = 0;
            
            if (result.truncatingRemainder(dividingBy: 1) == 0)
            {
                
                
                let stringValue =  String(format: "%.0f", result);
                let doubleValue = Double(stringValue);
                let resultToNSNumber = NSNumber(value: doubleValue!);
                let resultStringValue: String = formatNumber.string(from: resultToNSNumber)!;
                
                displayValue2 = resultStringValue;
            }
            else
            {
                
                let resultToNSNumber = NSNumber(value: result);
                let resultStringValue: String = formatNumber.string(from: resultToNSNumber)!;
                
                displayValue2 = resultStringValue;
                
            }
            
        }
        
        
        if let description = brain.description
        {
            descriptionDisplay.text = description.beautifyNumbers() + (brain.resultIsPending ? "…" : "=")
        }
        else
        {
            descriptionDisplay.text = " "
        }

        
    }
    
    
    @IBAction func clearScreen(_ sender: UIButton)
    {
        sender.showsTouchWhenHighlighted = true;
        brain = CalculatorBrain();
        displayValue2 = "0";
        descriptionDisplay.text = "History";
        userInTheMiddleOfTyping = false;
    }
    
    
    
}

extension String
{
    func beautifyNumbers() -> String
    {
        return self.replace(pattern: "\\.0+([^0-9]|$)", with: "$1")
    }
    
    func replace(pattern: String, with replacement: String) -> String
    {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSMakeRange(0, self.characters.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}


