//
//  ViewController.swift
//  Seven Wonders Of The World
//
//  Created by Eric Davis on 18/10/2021.
//

import UIKit
import MapKit

class WonderAnnotation: NSObject, MKAnnotation {
    var title: String?
    var desc: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, desc: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.desc = desc
        self.coordinate = coordinate
        super.init()
    }
}

struct ResponseData: Decodable {
    var title: String
    var content: [Wonder]
}

struct Wonder: Decodable {
    var name: String
    var desc: String
    var lat: Double
    var lon: Double
}

class WonderCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var beenSwitch: UISwitch!
    
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    
    
    
   var theWonders = [WonderAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = MKMapType.satelliteFlyover

        URLSession.shared.dataTask(with: URL(string: "https://resources.trisreed.com/appx/data.json")!) {

                (data, response, error) in
                guard let data = data else { return }

                do {
                    let decoder = JSONDecoder()
                    let wonderData = try decoder.decode(ResponseData.self, from: data)

                    for eachLocation in wonderData.content{
                        let theAnnotation = WonderAnnotation(title: eachLocation.name, desc: eachLocation.desc, coordinate: CLLocationCoordinate2D(latitude: eachLocation.lat, longitude: eachLocation.lon))
                        self.theWonders.append(theAnnotation)
                        self.mapView.addAnnotation(theAnnotation)
                        if UserDefaults.standard.object(forKey: eachLocation.name) == nil {
                            UserDefaults.standard.set(false, forKey: eachLocation.name)
                        }
                        
                    }
                    
                } catch let err {
                    print("Error", err)
                }
            }.resume()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theWonders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WonderCell
        cell.title.text = theWonders[indexPath.row].title
        cell.descriptionLabel.text = theWonders[indexPath.row].desc
        cell.beenSwitch.isOn = UserDefaults.standard.bool(forKey: theWonders[indexPath.row].title!)
        cell.beenSwitch.accessibilityLabel = cell.title.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.setCenter(theWonders[indexPath.row].coordinate, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        UserDefaults.standard.set(!(UserDefaults.standard.bool(forKey: theWonders[indexPath.row].title!)), forKey: theWonders[indexPath.row].title!)
        let selectedCell = tableView.cellForRow(at: indexPath) as! WonderCell
        selectedCell.beenSwitch.isOn = !(selectedCell.beenSwitch.isOn)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
