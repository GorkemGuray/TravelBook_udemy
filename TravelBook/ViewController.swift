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

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mainText: UITextField!
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
        
        //kullanıcı, harita üstüne uzun basarak pin koyabilmesi için gesture oluşturduk.
        //selector fonksiyonumuzda UILongPressGestureRecognizer'ı gönderdik ki işlmeler yapabilelim
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        //long press'in süresini belirledik.
        gestureRecognizer.minimumPressDuration = 2
        //gesture'ı mapView'e ekledik.
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    //CoreLocation'dan gelen delegat
    //kullanıcının konumu ne yapılacak?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //locations[0] kullanıcıdan alınan en güncel konum verisi barındırmaktadır.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        //zoomlama seviyesi
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        
        //setRegion yapabilmek için oluşturmalıyız.
        //bizden merkez nokta (center) ve zoom seviyesi istemekte (span)
        let region = MKCoordinateRegion(center: location, span: span)
        
        //map'imizde bir noktayı açmak istiyoruz
        //bizden region istemekte.
        mapView.setRegion(region, animated: true)
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        //dokunma eylemi başladı mı?
        if gestureRecognizer.state == .began {
            
            //dokunulan noktayı alır
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            //alınan bu noktayı koordinat haline getirir.
            let touchedCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            //harita üzerine konulacak pin oluşturuluyor.
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = mainText.text
            annotation.subtitle = commentText.text
            //oluşturulan pin haritaya ekleniyor.
            self.mapView.addAnnotation(annotation)
            
        }
        
        
    }


}

