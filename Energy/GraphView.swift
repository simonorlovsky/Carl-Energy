//
//  GraphViewController.swift
//  Energy
//
//  Created by Caleb Braun on 5/18/15.
//  Copyright (c) 2015 simonorlovsky. All rights reserved.
//
//  This is a template for how we will draw our graphs.  The graphs are drawn using Core Graphics.
//
//  Most of the graph display is based off of the tutorial found here: http://www.raywenderlich.com/90693/modern-core-graphics-with-swift-part-2

// Received help on getting max Double from an array from http://stackoverflow.com/questions/24036514/correct-way-to-find-max-in-an-array-in-swift
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    //The properties for the background gradient
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    @IBOutlet weak var maxLabel: UILabel!
    //Weekly sample data
    var turbineData=[String: [Double]]()
    var resolutionNumber: Int?
    
    override func drawRect(rect: CGRect) {
        
        if turbineData.count == 0 {
            return
        }
        
        //Set the graph variables
        let width = Double(rect.width)
        let height = Double(rect.height)
        let margin:Double = 20.0
        let topBorder:Double = 60
        let bottomBorder:Double = 50
        var productionPoints = [Double]()
        
        if turbineData["carleton_wind_production"] != nil{
            println("here")
            productionPoints = turbineData["carleton_wind_production"]!
        }
        
        //Calculate the x point
        var columnXPoint = { (column:Int) -> Double in
            //Calculate gap between points
//            let spacer = (width - margin*2 - 4.0) / Double(productionPoints.count - 1)
            let spacer = (width-margin*2 - 4.0)/Double(self.resolutionNumber!-1)
            var x:Double = Double(column) * spacer
            x += margin + 2
            return x
        }
        
        //Calculate the y point
        let graphHeight = height - topBorder - bottomBorder
//        let maxValue = maxElement(productionPoints)
        var columnYPoint = { (graphPoint:Double, maxValue: Double) -> Double in
//            var y:Double = graphPoint / maxValue * graphHeight
            var y: Double = graphPoint
//            var y:Double = graphPoint
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        
        //Create the line graph
        var graphPath = UIBezierPath()
        for (meterName, value) in turbineData {
            var graphPoints = value
            var yPoint: Double?
            // adjust the ratio of values for graph
            if meterName == "carleton_wind_production"{
                print("graphPoints for Wind Production: ")
                println(graphPoints)
            }
            var maxItem: Double? = 0
            for i in 0..<graphPoints.count{
                if graphPoints[i]>maxItem{
                    maxItem = graphPoints[i]
                }
            }
            //                let maxItem: Double = turbineData["carleton_wind_speed"]!.reduce(-Double.infinity, combine: {max($0, $1)})
            print("maxItem: ")
            println(maxItem)
            print("graphHeight: ")
            println(graphHeight)
            for i in 0..<graphPoints.count{
                graphPoints[i] = (graphPoints[i] * graphHeight)/(maxItem!)
            }
            graphPath.moveToPoint(CGPoint(x:columnXPoint(0), y:columnYPoint(graphPoints[0], maxItem!)))
            
            //Add points for each item in the graphPoints array at the correct (x, y) for the point
            for i in 1..<graphPoints.count {
                let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i], maxItem!))
                graphPath.addLineToPoint(nextPoint)
            }
            
            //Draw the line
            UIColor.whiteColor().setFill()
            UIColor.whiteColor().setStroke()
            graphPath.stroke()
            
            //Draw the circles on top of graph stroke
            let circleSize = CGSize(width: 5.0, height: 5.0)
            for i in 0..<graphPoints.count {
                var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i], maxItem!))
                point.x -= circleSize.width/2
                point.y -= circleSize.height/2
                var circleRect = CGRect(origin: point, size: circleSize)
                let circle = UIBezierPath(ovalInRect: circleRect)
                circle.fill()
            }
            
            //Draw horizontal graph lines on the top of everything
            var linePath = UIBezierPath()
            
            //Top line
            linePath.moveToPoint(CGPoint(x:margin, y: topBorder))
            linePath.addLineToPoint(CGPoint(x: width - margin,
                y:topBorder))
            
            //Center line
            linePath.moveToPoint(CGPoint(x:margin,
                y: graphHeight/2 + topBorder))
            linePath.addLineToPoint(CGPoint(x:width - margin,
                y:graphHeight/2 + topBorder))
            
            //Bottom line
            linePath.moveToPoint(CGPoint(x:margin,
                y:height - bottomBorder))
            linePath.addLineToPoint(CGPoint(x:width - margin,
                y:height - bottomBorder))
            let color = UIColor(white: 1.0, alpha: 0.3)
            color.setStroke()
            
            linePath.lineWidth = 1.0
            linePath.stroke()
        }
    }
    
    func drawGraphPoints(points: [String: [Double]]){
        self.turbineData = points
    }
    
}
