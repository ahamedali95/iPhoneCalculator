//
//  CalculatorBrain.swift
//  calculator3
//
//  Created by Ahamed Abbas on 9/11/17.
//  Copyright © 2017 Ahamed Abbas. All rights reserved.
//

import Foundation

func changeSign(operand: Double) -> Double
{
    return -1 * operand;
    
}


func cubicRootFunction(operand: Double) -> Double
{
    let x = pow(operand, 1/3);
    return x;
}

func cosecantFunction(operand: Double) -> Double
{
    let sineValue = sin(operand);
    return 1/sineValue;
    
}

func secantFunction(operand: Double) -> Double
{
    let cosineValue = cos(operand);
    return 1/cosineValue;
    
}

func cotangentFunction(operand: Double) -> Double
{
    let tangentValue = tan(operand);
    return 1/tangentValue;
    
}

func generateRandomFloat() -> (Double)
{
    return Double(arc4random()) / Double(UINT32_MAX);
}


//func multiply(op1: Double, op2: Double) -> Double
//{
//    return op1 * op2;
//}

struct CalculatorBrain
{
    private var accumulator: (Double, String)?;
    
    
    private enum Operation
    {
        case constant(Double);
        case unaryOperation((Double) -> Double, (String) -> String);
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String));
        case randomNumber(() -> Double, (String) -> String);
        case equals;
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "log" : Operation.unaryOperation(log, {"log(" + $0 + ")"}),
        "√" : Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "∛": Operation.unaryOperation(cubicRootFunction, {"∛(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin" : Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "sec" : Operation.unaryOperation(secantFunction, {"sec(" + $0 + ")"}),
        "csc" : Operation.unaryOperation(cosecantFunction, {"csc(" + $0 + ")"}),
        "cot" : Operation.unaryOperation(cotangentFunction, {"cot(" + $0 + ")"}),
        "±" : Operation.unaryOperation(changeSign, {"±(" + $0 + ")"}),
        "×" : Operation.binaryOperation(*, {$0 + "×" + $1}),
        "+" : Operation.binaryOperation(+, {$0 + "+" + $1}),
        "-" : Operation.binaryOperation(-, {$0 + "-" + $1}),
        "÷" : Operation.binaryOperation(/, {$0 + "÷" + $1}),
        "%" : Operation.unaryOperation({$0 * (1/100)}, {"(" + $0 + ")%"}),
        "R" : Operation.randomNumber(generateRandomFloat, {"R(0,1): " + $0}),
        "=" : Operation.equals,
        
        ]
    mutating func performOperation(_ symbol: String)
    {
        if let operation = operations[symbol]
        {
            switch operation
            {
                case .constant(let value):
                    accumulator = (value, symbol)
                
                case .unaryOperation(let function, let description):
                    if nil != accumulator
                    {
                        accumulator = (function(accumulator!.0), description(accumulator!.1));
                    }
                
                case .binaryOperation(let function, let description):
                    performPendingBinaryOperation()
                    if nil != accumulator
                    {
                        pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!);
                        accumulator = nil;
                    }
                
                case .randomNumber(let function, let description):
                    accumulator = (function(), description(accumulator!.1));
                
                case .equals:
                    performPendingBinaryOperation();
                
                
                
            }
        }
    }
    
    private mutating func performPendingBinaryOperation()
    {
        if nil != pendingBinaryOperation && nil != accumulator
        {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!);
            pendingBinaryOperation = nil;
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation
    {
        let function: (Double, Double) -> Double;
        let description: (String, String) -> String;
        let firstOperand: (Double, String);
        
        func perform(with secondOperand: (Double, String)) -> (Double, String)
        {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1));
        }
    }
    
    mutating func setOperand(_ operand: Double)
    {
        accumulator = (operand, "\(operand)");
    }
    
    var result: Double?
    {
        get
        {
            if nil != accumulator
            {
                return accumulator!.0;
            }
            return nil;
        }
    }
    
    var resultIsPending: Bool
    {
        get
        {
            if(pendingBinaryOperation != nil)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
    
    var description: String?
    {
        get
        {
            if resultIsPending
            {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "");
            }
            else
            {
                return accumulator?.1;
            }
        }
    }
    
}
