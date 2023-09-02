//
//  ViewController.swift
//  TravelBook
//
//  Created by Görkem Güray on 27.08.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mainText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    //Core location manager
    var locationManager = CLLocationManager()
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedID : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
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
        
        if selectedTitle != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            let idString = selectedID!.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        mainText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                }
                
            } catch {
                
            }
            
            //core data
            
        }
        
    } //viewDidLoad
    
    //CoreLocation'dan gelen delegat
    //kullanıcının konumu ne yapılacak?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
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
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.magenta
            
            // sağ tarafta görülen buton burada oluşturuldu
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            
            pinView?.annotation = annotation
            
        }
        
        return pinView
    }
    
    // pinimizin yanındaki butona tıklanıldığında yapılacak işlemler
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                
                if let placemark = placemarks {
                    
                    if placemark.count>0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                    
                    
                }
                

                
            }
            
            
        }
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        //dokunma eylemi başladı mı?
        if gestureRecognizer.state == .began {
            
            //dokunulan noktayı alır
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            //alınan bu noktayı koordinat haline getirir.
            let touchedCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            //harita üzerine konulacak pin oluşturuluyor.
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = mainText.text
            annotation.subtitle = commentText.text
            //oluşturulan pin haritaya ekleniyor.
            self.mapView.addAnnotation(annotation)
            
        }
        
        
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(mainText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Yer kaydı başarılı")
        } catch {
            print("Yer kaydı başarısız")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
}

