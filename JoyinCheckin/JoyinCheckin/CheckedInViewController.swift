//
//  ViewController.swift
//  JoyinCheckin
//
//  Created by Pan Hu on 14/12/14.
//  Copyright (c) 2014 Pan Hu. All rights reserved.
//
import UIKit

class CheckedInViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QRCodeReaderDelegate{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var scanButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    lazy var reader: QRCodeReader = QRCodeReader(cancelButtonTitle: "Cancel")
    
    
    override func viewDidLoad() {
        tableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        tableView.dataSource = self
        tableView.delegate = self
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        updateCounter()
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    func updateCounter()
    {
        counterLabel.text = (appDelegate.checked.count == 0 ? "No" : String(appDelegate.checked.count)) + " guests"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.checked.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = appDelegate.checked.values.array[indexPath.row]
        cell.detailTextLabel?.text = appDelegate.checked.keys.array[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let key = appDelegate.checked.keys.array[indexPath.row]
        let name = appDelegate.checked.values.array[indexPath.row]
        appDelegate.checked.removeValueForKey(key)
        appDelegate.unchecked.updateValue(name, forKey: key)
        self.tableView.reloadData()
        self.updateCounter()
    }
    
    @IBAction func scan(sender: AnyObject)
    {
        reader.delegate = self
        reader.completionBlock =
            { (result: String?) in
                println(result)
                if result == nil {
                    return
                }
                else if let name = self.appDelegate.unchecked[result!] {
                    self.appDelegate.unchecked.removeValueForKey(result!)
                    self.appDelegate.checked.updateValue(name, forKey: result!)
                    self.tableView.reloadData()
                    self.updateCounter()
                    self.alert(name + " just checked in")
                }
                else if let name = self.appDelegate.checked[result!]
                {
                    self.alert(name + " has already checked in")
                }
                else
                {
                    println("Invalid pass")
                    self.alert("Invalid pass")
                }
        }
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)

    }
    
    func alert(message: String)
    {
        let alert = UIAlertView()
        alert.title = ""
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func reader(reader: QRCodeReader, didScanResult result: String) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReader) {
        self.dismissViewControllerAnimated(false, nil)
    }
    
}

