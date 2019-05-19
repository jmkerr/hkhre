//
//  ViewController.swift
//  HealthKitHeartRateExporter
//
//  Created by Jonathan Kerr on 10.12.17.
//  Copyright © 2017 Jonathan Kerr. All rights reserved.
//

import UIKit
import HealthKit
import SQLite3

class ViewController: UIViewController {
    
    var mainView = UIView()
    
    var segmentedStartControl: UISegmentedControl!
    var segmentedIntervalControl: UISegmentedControl!
    
    var startTimePicker: UIDatePicker!
    var endTimePicker: UIDatePicker!
    
    var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = .white
        // Initialize View
        mainView = UIView()
        mainView.backgroundColor = .white
        self.view.addSubview(mainView)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        //mainView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        mainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        
        segmentedStartControl = UISegmentedControl(items: ["Start", "This Month", "This Year"])
        self.view.addSubview(segmentedStartControl)
        segmentedStartControl.setEnabled(false, forSegmentAt: 0)
        segmentedStartControl.addTarget(self, action: #selector(segmentChanged), for: UIControl.Event.valueChanged)
        
        segmentedStartControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedStartControl.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        segmentedStartControl.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        segmentedStartControl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        //segmentedStartControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        segmentedStartControl.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.07).isActive = true
        
        startTimePicker = UIDatePicker()
        self.view.addSubview(startTimePicker)
        startTimePicker.datePickerMode = UIDatePicker.Mode.date
        
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        startTimePicker.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        startTimePicker.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        startTimePicker.topAnchor.constraint(equalTo: self.segmentedStartControl.bottomAnchor).isActive = true
        //startTimePicker.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        startTimePicker.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.37).isActive = true
        
        segmentedIntervalControl = UISegmentedControl(items: ["End", "Last Month", "Last Year"])
        segmentedIntervalControl.setEnabled(false, forSegmentAt: 0)
        segmentedIntervalControl.addTarget(self, action: #selector(segmentChanged2), for: UIControl.Event.valueChanged)
        self.view.addSubview(segmentedIntervalControl)
        
        segmentedIntervalControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedIntervalControl.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        segmentedIntervalControl.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        segmentedIntervalControl.topAnchor.constraint(equalTo: self.startTimePicker.bottomAnchor).isActive = true
        //segmentedIntervalControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        segmentedIntervalControl.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.07).isActive = true
        
        endTimePicker = UIDatePicker()
        self.view.addSubview(endTimePicker)
        endTimePicker.datePickerMode = UIDatePicker.Mode.date
        
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimePicker.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        endTimePicker.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        endTimePicker.topAnchor.constraint(equalTo: self.segmentedIntervalControl.bottomAnchor).isActive = true
        //endTimePicker.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        endTimePicker.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.37).isActive = true
        
        startButton = UIButton(type: UIButton.ButtonType.system)
        startButton.setTitle("Save", for: UIControl.State.normal)
        startButton.setTitle("Saving", for: UIControl.State.disabled)
        startButton.addTarget(self, action: #selector(saveHeartRate(_:)), for: .touchUpInside)
        self.view.addSubview(startButton)
    
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        startButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        startButton.topAnchor.constraint(equalTo: self.endTimePicker.bottomAnchor).isActive = true
        //startButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        startButton.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.08).isActive = true
        
        
        
        startTimePicker.date = Date()
        setIntervalYear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPickers (startDate: Date, endDate: Date) {
        DispatchQueue.main.async {
            self.startTimePicker.setDate(startDate, animated: true)
        }
        DispatchQueue.main.async {
            self.endTimePicker.setDate(endDate, animated: true)
        }
    }
    
    func setIntervalYear() {
        let startComponent = Calendar.current.dateComponents([.year], from: Date())
        let start = Calendar.current.date(from: startComponent)
        setPickers(startDate: start!, endDate: Date())
    }
    
    func setIntervalMonth() {
        let startComponent = Calendar.current.dateComponents([.month, .year], from: Date())
        let start = Calendar.current.date(from: startComponent)
        setPickers(startDate: start!, endDate: Date())
    }
    
    func setIntervalToLastMonth() {
        let endComponent = Calendar.current.dateComponents([.month, .year], from: Date())
        var startComponent = endComponent
        startComponent.month = startComponent.month! - 1
        
        let end = Calendar.current.date(from: endComponent)
        let start = Calendar.current.date(from: startComponent)
        
        setPickers(startDate: start!, endDate: end!)
    }
    
    func setIntervalToLastYear() {
        let endComponent = Calendar.current.dateComponents([.year], from: Date())
        var startComponent = endComponent
        startComponent.year = startComponent.year! - 1
        
        let end = Calendar.current.date(from: endComponent)
        let start = Calendar.current.date(from: startComponent)
        
        setPickers(startDate: start!, endDate: end!)
    }
    
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            setIntervalMonth()
            sender.selectedSegmentIndex = -1
        case 2:
            setIntervalYear()
            sender.selectedSegmentIndex = -1
        default:
            break
        }
    }
    
    @objc func segmentChanged2(_ sender: UISegmentedControl) {
    
    switch sender.selectedSegmentIndex {
        case 1:
            setIntervalToLastMonth()
            sender.selectedSegmentIndex = -1
        case 2:
            setIntervalToLastYear()
            sender.selectedSegmentIndex = -1
        default:
            break
        }
    }
    

    @objc func saveHeartRate(_ sender: UIButton) {
        let healthStore = HKHealthStore()
        
        sender.isEnabled = false
        sender.setNeedsDisplay()
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        if (HKHealthStore.isHealthDataAvailable()){
            healthStore.requestAuthorization(toShare: nil, read:[heartRateType], completion:{(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm:ss"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                
                let startTime = self.startTimePicker.date
                var endTime = self.endTimePicker.date
                endTime = endTime.addingTimeInterval(24*3600)
                
                let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)
                
                let query = HKSampleQuery(sampleType:heartRateType, predicate:predicate, limit:0, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    guard let results = results else { return }
                    if(0 == results.count) {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "No data for this range or HealthKit access denied.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            sender.isEnabled = true
                            print("No data for this range or HealthKit access denied.")
                        }
                        return
                    }
                    
                    // Store in SQLite 3 DB
                    
                    struct HRRecord {
                        let Timestamp: Int
                        let Magnitude: Int
                        let UUID: String
                        let WritingLibrary: String
                    }
                    
                    var data: [HRRecord] = []
                    
                    // Prepare data to write
                    for quantitySample in results {
                        let quantity = (quantitySample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(from: "count/min")
                        
                        let timestamp = quantitySample.startDate.timeIntervalSince1970
                        let magnitude = quantity.doubleValue(for: heartRateUnit)
                        
                        let record = HRRecord(Timestamp: Int(timestamp)
                            , Magnitude: Int(magnitude)
                            , UUID: quantitySample.uuid.description
                            , WritingLibrary: quantitySample.sourceRevision.source.name)
                        
                        data.append(record)
                        
                        print((quantitySample as! HKQuantitySample).quantity)
                        //print(quantitySample.sourceRevision.source.bundleIdentifier)
                        print(quantitySample.sourceRevision.source.name)
                        //print(quantitySample.sourceRevision.version!)
                        print(quantitySample.uuid)
                        //print(quantitySample.device)
                        //print(quantitySample.metadata)
                        //print(quantitySample.sampleType)
                        //print(quantitySample.description)
                    }
                    
                    // Perform the database write
                    let dbURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("db.sqlite3")
                    
                    var db: OpaquePointer?
                    if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
                        print("error opening database")
                    }
                    
                    // Conditionally prepare database if it was newly created.
                    if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS HeartRate (Timestamp INT PRIMARY KEY, Magnitude INT)", nil, nil, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error creating table: \(errmsg)")
                    }
                    
                    // Insert values
                    var statement: OpaquePointer?
                    
                    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

                    if sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error beginning transaction: \(errmsg)")
                    }
                    
                    if sqlite3_prepare_v2(db, "INSERT OR IGNORE INTO HeartRate (Timestamp, Magnitude) VALUES (@ep, @mag)", -1, &statement, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error preparing insert: \(errmsg)")
                    }
                    
                    for record in data {

                        if sqlite3_bind_text(statement, 1, String(record.Timestamp), -1, SQLITE_TRANSIENT) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding timestamp: \(errmsg)")
                        }
                        
                        if sqlite3_bind_text(statement, 2, String(record.Magnitude), -1, SQLITE_TRANSIENT) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding magnitude: \(errmsg)")
                        }
                        
                        if sqlite3_step(statement) != SQLITE_DONE {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure inserting: \(errmsg)")
                        }
                        
                        if sqlite3_reset(statement) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure resetting: \(errmsg)")
                        }
                        
                        if sqlite3_clear_bindings(statement) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure unbinding: \(errmsg)")
                        }
                    }
                    
                    if sqlite3_finalize(statement) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error finalizing prepared statement: \(errmsg)")
                    }
                    
                    if sqlite3_exec(db, "END TRANSACTION", nil, nil, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error ending transaction: \(errmsg)")
                    }
                    
                    if sqlite3_exec(db, "VACUUM hr", nil, nil, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error in vacuum: \(errmsg)")
                    }
                    
                    if sqlite3_close(db) != SQLITE_OK {
                        print("error closing database")
                    }
                    
                    // Dispatch completion to main queue, enable Button for the next query.
                    DispatchQueue.main.async {
                        print("Completed Query.")
                        sender.isEnabled = true
                    }
                })
                healthStore.execute(query)
            })
            
        } else {
            print("HealthKit not available on this device.")
            let alert = UIAlertController(title: "Error", message: "HealthKit not available on this device.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

