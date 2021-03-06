//
//  DataRetreiver.swift
//  Energy
//
//  Created by Caleb Braun on 5/11/15.
//  Copyright (c) 2015 simonorlovsky. All rights reserved.
//
//  This class represents a DataRetreiver object that connects to the BuildingOS API.  Given a building, time range,
//  and resolution (data every hour, day, etc.) it returns an array of the energy data.
//
//  With help from http://jamesonquave.com/blog/developing-ios-apps-using-swift-tutorial-part-2/
//

import UIKit

class DataRetreiver: NSObject {
    
    
    // Fetches the data based on the URL created upon initialization
    func fetchCurrent(name: String, callback:([String: Double])->Void){
        var dataResults = [String: Double]()
        var URLstring = NSURL(string: "https://rest.buildingos.com/reports/timeseries/?period=lasthour&resolution=quarterhour&name=\(name)")!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URLstring, completionHandler: {data, response, error -> Void in
            if(error != nil){
                // Prints error to the console
                println(error.localizedDescription)
            }
            
            var jsonError: NSError?
            // Parses the JSON and casts it as an NSDictionary
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
            
            if(jsonError != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(jsonError!.localizedDescription)")
                println("URL: \(URLstring)")
            } else {
                println("ULR: \(URLstring)")
                // Only takes the results of the search and casts as an NSArray
                if let results: NSArray = jsonResult!["results"] as? NSArray{
                    var valueResults = [Double]()
                    if let mostRecentTime: [String: Double] = results[results.count-1][name] as? [String: Double]{
                        if let val = mostRecentTime["value"] as Double!{
                            dataResults[name] = val
                            callback(dataResults)
                        }
                    }
                }
            }
        })
        task.resume()
        
    }
    
    
    func fetchOverTimePeriod(name: String, timePeriod: String, callback: ([String:[Double]])->Void){
        var dataResults = [String: [Double]]()
        var resolution: String
        // today, lastweek, lastmonth, lastyear
        var url: NSURL = URLFormatterTimePeriod(name, timePeriod: timePeriod)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if(error != nil){
                // Prints error to the console
                println(error.localizedDescription)
            }
            
            var jsonError: NSError?
            // Parses the JSON and casts it as an NSDictionary
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
            
            if(jsonError != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(jsonError!.localizedDescription)")
                println(url)
            } else {
                // Only takes the results of the search and casts as an NSArray
                if let results: NSArray = jsonResult!["results"] as? NSArray{
                    var valueResults = [Double]()
                    for time in results{
                        if let hour = time[name] as? [String:Double]{
                            if let value = hour["value"]{
                                valueResults.append(value)
                            }
                        }
                    }
                    dataResults[name] = valueResults
                    callback(dataResults)
                }
            }
        })
        task.resume()

    }
    
    
    
    
    func fetchWind(nameArray : [String], startDate: NSDate, endDate : NSDate, resolution : String, callback: ([String:[Double]])->Void){
        
        var dataResults = [String:[Double]]()
        var counter = nameArray.count-1
        
        for buildingNameIndex in 0..<nameArray.count {
            var url : NSURL = URLFormatter(nameArray[buildingNameIndex], startDate: startDate, endDate: endDate, resolution: resolution)
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if(error != nil){
                    // Prints error to the console
                    println(error.localizedDescription)
                }
                
                var jsonError: NSError?
                // Parses the JSON and casts it as an NSDictionary
                let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
                
                if(jsonError != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(jsonError!.localizedDescription)")
                    println(url)
                } else {
                    // Only takes the results of the search and casts as an NSArray
                    if let results: NSArray = jsonResult!["results"] as? NSArray{
                        var valueResults = [Double]()
                        for time in results{
                            if let hour = time[nameArray[buildingNameIndex]] as? [String:Double]{
                                if let value = hour["value"]{
                                    valueResults.append(value)
                                }
                            }
                        }
                        dataResults[nameArray[buildingNameIndex]] = valueResults
                        if counter > 0 {
                            counter--
                        }else{
                            callback(dataResults)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    
    
    
    func fetch(nameArray : [String], meterType: String, startDate: NSDate, endDate : NSDate, resolution : String, callback: ([String:[Double]])->Void){
        
        var dataResults = [String:[Double]]()
        let buildings = BuildingsDictionary()
        let meterArray = buildings.getMetersFromNames(nameArray, meterType: meterType)
        var counter = nameArray.count-1
        println(meterArray)
        
        for buildingNameIndex in 0..<nameArray.count {
            var url : NSURL = URLFormatter(meterArray[buildingNameIndex], startDate: startDate, endDate: endDate, resolution: resolution)
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if(error != nil){
                    // Prints error to the console
                    println(error.localizedDescription)
                }
                
                var jsonError: NSError?
                // Parses the JSON and casts it as an NSDictionary
                let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
                
                if(jsonError != nil) {
                    if meterArray[buildingNameIndex] != "" {
                        // If there is an error parsing JSON, print it to the console
                        println("JSON Error \(jsonError!.localizedDescription)")
                        println(url)
                    } else {
                        dataResults[nameArray[buildingNameIndex]] = [0]
                        if counter > 0 {
                            counter--
                        } else {
                            callback(dataResults)
                        }
                    }
                    
                } else {
                    // Only takes the results of the search and casts as an NSArray
                    if let results: NSArray = jsonResult!["results"] as? NSArray{
                        var valueResults = [Double]()
                        for time in results{
                            if let hour = time[meterArray[buildingNameIndex]] as? [String:Double]{
                                if let value = hour["value"]{
                                    valueResults.append(value)
                                }
                            }
                        }
                        dataResults[nameArray[buildingNameIndex]] = valueResults
                        if counter > 0 {
                            counter--
                        } else {
                            callback(dataResults)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    func fetchOverTimePeriod(name: String, timePeriod: String, meterType: String, callback: ([String:[Double]])->Void){
        let bd = BuildingsDictionary()
        let meterName = bd.getMetersFromNames([name], meterType: meterType)[0]
        var dataResults = [String: [Double]]()
        var url: NSURL = URLFormatterTimePeriod(meterName, timePeriod: timePeriod)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if(error != nil){
                // Prints error to the console
                println(error.localizedDescription)
            }
            
            var jsonError: NSError?
            // Parses the JSON and casts it as an NSDictionary
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
            
            if(jsonError != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(jsonError!.localizedDescription)")
                println(url)
            } else {
                // Only takes the results of the search and casts as an NSArray
                if let results: NSArray = jsonResult!["results"] as? NSArray{
                    var valueResults = [Double]()
                    for time in results {
                        if let hour = time[meterName] as? [String:Double]{
                            if let value = hour["value"]{
                                valueResults.append(value)
                            }
                        }
                    }
                    dataResults[name] = valueResults
                    println(url)
                    callback(dataResults)
                }
            }
        })
        task.resume()
        
    }
    
    // This method returns an NSURL based on the requested start and end dates, building, and resolution.
    func URLFormatter(name : String, startDate: NSDate, endDate : NSDate, resolution : String) -> NSURL {
        
        // The NSDateFormatter() changes the date into the correct format for the URL
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd+HH:mm:ss"
        
        var startDateString = dateFormatter.stringFromDate(startDate)
        var endDateString = dateFormatter.stringFromDate(endDate)
        
        // Formats the URL correctly
        let urlString = "https://rest.buildingos.com/reports/timeseries/?start=\(startDateString)&end=\(endDateString)&resolution=\(resolution)&name=\(name)"
        return NSURL(string: urlString)!
    }
    
    func URLFormatterTimePeriod(meterName: String, timePeriod: String) -> NSURL {
        let urlString = "https://rest.buildingos.com/reports/timeseries/?period=\(timePeriod)&name=\(meterName)"
        return NSURL(string: urlString)!
    }
    
    
}
