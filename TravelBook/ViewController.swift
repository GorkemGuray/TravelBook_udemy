//
//  ViewController.swift
//  TravelBook
//
//  Created by Görkem Güray on 27.08.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    //Core location manager
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        mapView.delegate = self
        locationManager.delegate = self
        
        //alınan konumun ne kadar hassas olacağı belirleniyor. best yaparsak çok daha fazla pil harcar.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //kullanıcıdan konumunun kullanılabilmesi için izin isteniyor.
        locationManager.requestWhenInUseAuthorization()
        
        //kullanıcının konumu alınmaya başlanıyor.
        locationManager.startUpdatingLocation()
        
        
    }
    
    //CoreLocation'dan gelen delegat
    //kullanıcının konumu ne yapılacak?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //locations[0] kullanıcıdan alınan en güncel konum verisi barındırmaktadır.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        //zoomlama seviyesi
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        //setRegion yapabilmek için oluşturmalıyız.
        //bizden merkez nokta (center) ve zoom seviyesi istemekte (span)
        let region = MKCoordinateRegion(center: location, span: span)
        
        //map'imizde bir noktayı açmak istiyoruz
        //bizden region istemekte.
        mapView.setRegion(region, animated: true)
        
    }


}

