//
//  ViewController.swift
//  MyMapKitGoogleSDK
//
//  Created by Rafael M. Trasmontero on 5/18/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class ViewController: UIViewController , UISearchBarDelegate , GMSMapViewDelegate {
    
    var mySearchBar = UISearchBar()
    var didSetStartingView:Bool = false
    var myMapView:GMSMapView!
    var segmentView: UIView!
    var segmentControl:UISegmentedControl!
    var tttLogo:UIImageView = UIImageView()
    var tttLogoAdded:Bool = false
    var restaurantMarkers = Set<GMSMarker>()
    var allMarkers = Set<GMSMarker>()
    var searchTerm:String?
    var myResultsJSONArray:[[String:Any]]!
    var tappedMarker:GMSMarker!
    
    class MyMarker: GMSMarker {
        var placeid:String = ""
        var webURL:URL!
        var photoreference:String = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMapView(mapType: .normal)
        initSearchBar()
        loadTTTMarker()
        setupRestaurantMarkers()
        
        //OBSERVER ADJUST LOCATION OF SEGEMENT
        NotificationCenter.default.addObserver(self, selector: #selector(addSegmentControl), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //ADD OBSERVER WHEN THE SEGEMNT CONTROL IS TAPPED
        NotificationCenter.default.addObserver(self, selector:#selector(segmentSelected), name: NSNotification.Name(rawValue: "SCTapped"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ADJUST MAP PADDING DOWN TO SHOW COMPASS BEHIND NAVIGATIONBAR
        myMapView.padding = .init(top:50, left: 0, bottom: 0, right: 0)
        addTTTLogo()
        addSegmentControl()
        
        //SHOW RESTAURANT MARKERS
        for restaurant in self.restaurantMarkers{
            restaurant.map = myMapView
        }
        

    }

    
    
    //METHOD TO IMPLEMENT MAP
    func setUpMapView(mapType:GMSMapViewType ){
        
        //1.SET STARTING CAMERA FOR MAP VIEW SET AT TURN TO TECH
        myMapView = GMSMapView.map(withFrame: CGRect.zero, camera: GMSCameraPosition.camera(withLatitude: 40.7084257, longitude:-74.0148711, zoom: 17))
        myMapView.settings.myLocationButton = true
        myMapView.mapType = mapType // .normal // .satelite // .hybrid
        myMapView.settings.compassButton = true
        
        //****IMPORTANT**** 
        //DRAWS THE PIN ON THE MAP
        self.view = myMapView
        
        //2.SET DELEGATE
        myMapView.delegate = self
        
    }
    
    //METHOD TO LOAD TTT MARKER
    func loadTTTMarker(){
        let turnToTechMarker = MyMarker(position: CLLocationCoordinate2DMake(40.7084257,-74.0148711))
        turnToTechMarker.title = "Turn To Tech"
        turnToTechMarker.snippet = "40 Rector St #1000, New York, NY 10006"
        turnToTechMarker.icon = MyMarker.markerImage(with: .blue)
        turnToTechMarker.opacity = 0.5
        turnToTechMarker.map = myMapView
        

    }
    
    //METHODS TO LOAD SEARCH BAR
    func initSearchBar(){
        mySearchBar.placeholder = "Search For Stuff"
        mySearchBar.delegate = self
        self.navigationItem.titleView = mySearchBar
    }
    
    //ADD TTT CORNER LOGO
    func addTTTLogo(){
        tttLogo.removeFromSuperview()
        let bottomOfNavBar = self.navigationController?.navigationBar.frame.height
        
        tttLogo = UIImageView(frame: CGRect(x: 0, y:bottomOfNavBar! + 15, width: 50, height: 50))
    
        tttLogo.backgroundColor = .clear
        let imageToUse = UIImage.init(named: "tlogo")
        tttLogo.image = imageToUse
        
        tttLogoAdded = true
        myMapView.addSubview(tttLogo)
        
    }
    
    //ADD SEGMENTED CONTROL
    func addSegmentControl(){
        segmentView.removeFromSuperview()
        
        segmentView = UIView(frame: CGRect(x:(self.view.bounds.midX) - 120  , y: (self.view.bounds.maxY - 55) , width: 240, height: 50))
        segmentView.backgroundColor = UIColor.white
        segmentView.alpha = 0.70
        segmentView.layer.cornerRadius = 10
        
        segmentControl = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 220, height: 30))
        segmentControl = UISegmentedControl(items: ["Standard", "Satellite","Hybrid"])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentSelected), for: .valueChanged)
        segmentControl.alpha = 1.0
        
        segmentView.addSubview(segmentControl)
        segmentControl.center.x = segmentView.bounds.midX
        segmentControl.center.y = segmentView.bounds.midY
        
        myMapView.addSubview(segmentView)
        
    }
    
    //HANDLE SEGMENT CONTROL
    func segmentSelected(){
        
        //self.myMapView.removeFromSuperview()
        
        switch self.segmentControl.selectedSegmentIndex {
        
        case 1 :
            myMapView.mapType = .satellite
            print("SATELLITE TYPE")
        case 2 :
            myMapView.mapType = .hybrid
            print("HYBRID TYPE")
        default:
            myMapView.mapType = .normal
            print("NORMAL TYPE")
        }
        
    }
    
    //SETUP SOME HARD CODED MARKERS TO MAP
    func setupRestaurantMarkers(){
        
        let dunkinMarker = MyMarker(position: CLLocationCoordinate2DMake(40.70802719245363,-74.01396989822388))
        dunkinMarker.title = "Dunkin Donuts"
        dunkinMarker.snippet =  "19 Rector St, New York, NY 10006, USA"
        dunkinMarker.opacity = 0.5
        dunkinMarker.icon = MyMarker.markerImage(with: .cyan)
        dunkinMarker.placeid = "ChIJw3zO3RBawokRr-KKfs1D9iA"
        
        let subwayMarker = MyMarker(position: CLLocationCoordinate2DMake(40.70852329864894,-74.01353001594543))
        subwayMarker.title = "Subway"
        subwayMarker.snippet = "106 Greenwich St, New York, NY 10006, USA"
        subwayMarker.opacity = 0.5
        subwayMarker.icon = MyMarker.markerImage(with: .cyan)
        subwayMarker.placeid = "ChIJiZh1wRBawokRt6LAGvi8fEk"
        
        let starbucksMarker = MyMarker(position: CLLocationCoordinate2DMake(40.70921458800388, -74.01414155960083))
        starbucksMarker.title = "Starbucks"
        starbucksMarker.snippet = "85 West St, New York, NY 10280"
        starbucksMarker.opacity = 0.5
        starbucksMarker.icon = MyMarker.markerImage(with: .cyan)
        starbucksMarker.placeid = "ChIJv3kxhRBawokR4SbHWzjB6DE"
        
        let oharasMarker = MyMarker(position: CLLocationCoordinate2DMake(40.70950330084529, -74.01266634464264))
        oharasMarker.title = "O'Hara's"
        oharasMarker.snippet = "120 Cedar St, New York, NY 10006, USA"
        oharasMarker.opacity = 0.5
        oharasMarker.icon = MyMarker.markerImage(with: .cyan)
        oharasMarker.placeid = "ChIJueUCrBBawokRiw9LMJFm0_o"
        
        let georgesMarker = MyMarker(position: CLLocationCoordinate2DMake(40.70766527658617, -74.01339590549469))
        georgesMarker.title = "George's"
        georgesMarker.snippet = "89 Greenwich St, New York, NY 10006, USA"
        georgesMarker.opacity = 0.5
        georgesMarker.icon = MyMarker.markerImage(with: .cyan)
        georgesMarker.placeid = "ChIJtVcN3BBawokRfYHdSkgPmwY"
        
        //ADD TO SET
        self.restaurantMarkers = NSSet.init(objects: dunkinMarker,subwayMarker,starbucksMarker,oharasMarker,georgesMarker) as! Set<GMSMarker>
    }
    
    //DELEGATE METHOD FOR CUSTOM INFO MARKER WINDOW WHEN PIN IS TAPPED
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    
        self.tappedMarker = marker as! MyMarker
        self.tappedMarker.tracksInfoWindowChanges = true
        
        //SET UP THE INFO VIEW
        let infoView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        infoView.backgroundColor = .white
        infoView.alpha = 0.9
        infoView.layer.cornerRadius = 15
        
        //SET UP IMAGE VIEW FOR LOGO
        let logoImageView = UIImageView(frame: CGRect(x: infoView.bounds.midX - 40 , y: 5, width: 80, height: 40))
        logoImageView.backgroundColor = .clear
        logoImageView.layer.cornerRadius = 15
        logoImageView.clipsToBounds = true
        logoImageView.contentMode = .scaleToFill
        
        if let imageName = getStockImage(title: tappedMarker.title!){
            logoImageView.image = UIImage(named: imageName)
        }else{
            fetchImageForMarker(completion: { (success, theImage) in
                if success {
                    logoImageView.image = theImage
                } else {
                    logoImageView.image = theImage
                }
                
                infoView.addSubview(logoImageView)
            })
        }
        
        //SET UP LABEL FOR THE TITLE
        let titleLabel = UILabel(frame: CGRect(x: infoView.bounds.midX - 40, y: 45, width: 80, height: 20))
        titleLabel.backgroundColor = .clear
        titleLabel.layer.cornerRadius = 10
        titleLabel.clipsToBounds = true
        titleLabel.contentMode = .scaleAspectFit
        titleLabel.font = UIFont(name: "Ariel", size: 12)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        titleLabel.textAlignment = .center
        titleLabel.text = tappedMarker.title
        infoView.addSubview(titleLabel)
        
        //SET UP LABEL FOR THE SNIPPET
        let snippetLabel = UILabel(frame: CGRect(x: infoView.bounds.midX - 40, y: 65, width: 80, height: 30))
        snippetLabel.backgroundColor = .clear
        snippetLabel.layer.cornerRadius = 10
        snippetLabel.clipsToBounds = true
        snippetLabel.contentMode = .scaleAspectFit
        snippetLabel.font = UIFont(name: "Courier", size: 8)
        snippetLabel.numberOfLines = 0
        snippetLabel.textAlignment = .center
        snippetLabel.text = tappedMarker.snippet
        
        infoView.addSubview(snippetLabel)
        infoView.addSubview(logoImageView)
        return infoView
    }

    //METHOD TO HANDLE IMAGES FOR RESTAURANT
    func getStockImage(title:String) -> String?{
        
        let imageName:String?
        
        switch title{
        case "Dunkin Donuts":
            imageName  = "dunkinLogo"
        case "Subway":
            imageName = "subwayLogo"
        case "Starbucks":
            imageName = "starbucksLogo"
        case "O'Hara's":
            imageName  = "oharasLogo"
        case "George's":
            imageName = "georgesLogo"
        case "Turn To Tech":
            imageName = "tlogo"
        default:
            imageName = nil
        }
        
        return imageName
    }

    //DELEGATE METHOD TO HANDLE TAPPING INFO WINDOW TO PERFORM ACTION
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        self.tappedMarker = marker as! MyMarker
        
        //INIT WEBVIEW & SEGQEUE TO THE WEBVIEW
        if let myWebViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController")as? WebViewController{
            
            if let stockUrl = getStockUrl(title: tappedMarker.title!) {
                myWebViewController.webURL = stockUrl
                if let navigator = navigationController{
                    navigator.pushViewController(myWebViewController, animated: true)
                }
                
            } else {
                fetchWebURLForMarker{ (success, theURL) in
                    if success{
                        print(theURL)
                        myWebViewController.webURL = theURL
                    } else {
                        print(theURL)
                        myWebViewController.webURL = theURL
                    }
                    if let navigator = self.navigationController{
                        navigator.pushViewController(myWebViewController, animated: true)
                    }
                }
            }
        }
    }
    
    
    
    //METHOD TO HANDLE STOCK URL
    func getStockUrl(title:String) -> URL? {
        var webURL:URL?
        
        switch title{
        case "Dunkin Donuts":
            webURL = URL.init(string:"https://www.dunkindonuts.com/en")!
        case "Subway":
            webURL = URL.init(string: "http://www.subway.com/en-us")!
        case "Starbucks":
            webURL = URL.init(string: "https://www.starbucks.com/")!
        case "O'Hara's":
            webURL = URL.init(string: "http://www.oharaspubnyc.com/")!
        case "George's":
            webURL = URL.init(string: "http://georges-ny.com//")!
        case "Turn To Tech":
            webURL = URL.init(string: "http://turntotech.io/")!
        default:
            webURL = nil
        }
        return webURL
    }
    
    //REQUEST IMAGE FOR MARKER VIEW W/ COMPLETION HANDLER/CALLBACK B/C OF "ASYNC WITH A RETURN"
    func fetchImageForMarker (completion:@escaping(_ isSuccessful:Bool , _ thePhoto: UIImage)-> Void){
        let myTappedMarker = tappedMarker as! MyMarker
        let myMarkerPhotoReference = myTappedMarker.photoreference
        
        //https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM
        
        let requestString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(myMarkerPhotoReference)&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM"
        
        print(requestString)
        
        let requestURL = URL(string: requestString)
        
        let session = URLSession.shared
        
        session.dataTask(with: requestURL!, completionHandler: { (data, response, error) in

            
            if error != nil {
                print(error?.localizedDescription as! Error)
            }
            
            if let myData = data{
                if let myImage = UIImage(data: myData){
                        DispatchQueue.main.async {
                            completion(true, myImage)
                           
                    }
                } else {
                        let myImage = UIImage(named: "tlogo")
                        DispatchQueue.main.async {
                            completion(false, myImage!)
                        }
                    }
                }
          
        })
        .resume()
    }


    //REQUEST FOR WEBSITE URL w/ COMPLETION HANDLER/CALLBACK B/C OF "ASYNC WITH A RETURN"
    func fetchWebURLForMarker(completion:@escaping(_ isSuccessful:Bool , _ theResultURL: URL)-> Void){
        //DOWN CAST FROM GMS MARKER TO MYMARKER TO USE ID
        let myTappedMarker = tappedMarker as! MyMarker
        let myMarkerPlaceID = myTappedMarker.placeid as String
 //       let markerPlaceIDxxxx = "ChIJtVcN3BBawokRfYHdSkgPmwY"   //<--- for testing
        
        //REQUEST PLACE DETAIL FOR WEBSITE URL FROM PLACES API WEBSERVICE USE "PLACE_ID" NOT "ID"
        //https://maps.googleapis.com/maps/api/place/details/json?&placeid=ChIJtVcN3BBawokRfYHdSkgPmwY&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM
        
        let requestString = "https://maps.googleapis.com/maps/api/place/details/json?&placeid=\(myMarkerPlaceID)&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM"
        
        
        let requestURL = URL(string:requestString)
        
        //***********START URL SESSION WITH COMPLETION HANDLER/CALLBACK B/C RETURNING***********************
        let session = URLSession.shared
            session.dataTask(with: requestURL!, completionHandler: { (data, response, error) in
                

                //DO/CATCH
                do {
                    let myJSON = try JSONSerialization.jsonObject(with:data!, options: .mutableContainers) as! [String:Any]
                    print(myJSON)
                    
                    if let result = myJSON["result"] as? [String:Any],
                        let resultWebSiteString = result["website"] as? String,
                        let resultURL = URL.init(string: resultWebSiteString) {
                        
                        DispatchQueue.main.async {
                            print(resultWebSiteString)
                            completion(true,resultURL)
                        }
                    } else {
                        
                        let resultURL = URL(string: "https://www.google.com")
                        DispatchQueue.main.async {
                            completion(false,resultURL!)
                        }
                        
                    }
                }
                    
                catch {
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        completion(false, URL.init(string: "turntotech.io")!)
                    }
                 
                }
                
                
            })

            .resume()
     }
    
    
    
    //SET UP URL REQUEST
    func downloadNewMarkerData(){
        //test
        //searchTerm = "Restaurant"
        
        //******************************************************************************************************************
        //NOTE: MAKE SURE TO "ENABLE" GOOGLE PLACES API WEB SERVICE API ON THE GOOGLE API DASHBOARD CONSOLE               **
        // CONSOLE.DEVELOPER.GOOGLE.COM                                                                                   **
        //******************************************************************************************************************
        
        //TEST THE URL BY PRINTING THEM AND CLICKING ON THEM/ DETERMINE IF API IS "ENABLED" OR WORKING
        //NEARBY SEARCH URL
        //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.7084257,-74.0148711&radius=300&keyword=restaurant&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM
        //TEXTSEARCH URL*
        //https://maps.googleapis.com/maps/api/place/textsearch/json?location=40.7084257,-74.0148711&radius=300&query=restaurant&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM
        
        //***********SET UP SEARCH URL*********************************
        
        guard let mySearchTerm = self.searchTerm else {return}
        
        let requestString = "https://maps.googleapis.com/maps/api/place/textsearch/json?location=40.7084257,-74.0148711&radius=100&type=\(mySearchTerm)&query=\(mySearchTerm)&key=AIzaSyD7iDgoF1QI1hZ-odWBogSCCGOBtPnoWVM"
        
        guard let requestURL = URL(string:requestString) else {return}
        
         //***********START URL SESSION*********************************
            let session = URLSession.shared
            session.dataTask(with: requestURL) { (data, response, error) in
        
        //***********CONVERT JSON TO READABLE DATA*************************
            if let myData = data {
 
                do {
                    
                    var myJsonDictionary: [String: Any]  = try JSONSerialization.jsonObject(with: myData, options: .mutableContainers)as! [String: Any]

                //CONVERT FOR EASY READABILITY
                    guard let resultsArray = myJsonDictionary["results"] as? [[String:Any]] else {
                        return
                    }
                
                    
                self.myResultsJSONArray = resultsArray
                print(self.myResultsJSONArray.count)
                    
                    
                //DISPATCH TO MAIN THREAD
                    DispatchQueue.main.async {
                        self.createSearchMarkersWithJSON(json:self.myResultsJSONArray)
                    }
                
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .resume()
    }
    
    //METHOD TO CREATE MARKERS FOR SEARCH TERM //use the PLace_ID & PhotoReference for website and Images
    func createSearchMarkersWithJSON(json:[[String:Any]]){
        //CLEAR ANY EXISTING MARKERS
        self.allMarkers.removeAll()
        self.myMapView.clear()
        loadTTTMarker()
        
        //1.ADD OUR HARDCODED MARKERS TO THE SET THAT WILL HOLD ALL MARKERS
        let mutableMarkerSet = NSMutableSet.init(set: self.restaurantMarkers)
        
        
        //2.LOOP THOUGH THE JSON ARRAY AND MAKE NEW MARKERS
        for item in self.myResultsJSONArray{
            
            //PARSING TO GET LOCATION
            guard let geometry = (item["geometry"] as? [String:Any]),
                let location = (geometry["location"] as? [String:Any]),
                let latitude = location["lat"] as? Double,
                let longitude = location["lng"] as? Double else {
                    print("error parsing JSON for location")
                    continue
            }
            
            //PARSE GET PHOTO_REFERENCE
            guard let photo = item["photos"] as? [[String:Any]] else {return}
            let object = photo[0]
            guard let photoReference = object["photo_reference"] as? String else {return}
                
            //ASSIGNING LOCATION,TITLE,ADDRESS(SNIPPET) ALL ELSE IN CUSTOM VIEW
            let newMarker = MyMarker(position: CLLocationCoordinate2DMake(latitude,longitude))
            newMarker.title = (item["name"] as! String)
            newMarker.snippet =  (item["formatted_address"] as! String)
            newMarker.placeid = item["place_id"] as! String
            newMarker.photoreference = photoReference
            
            //ASSIGN ADDITIONAL INFO
            newMarker.map = self.myMapView   //<--- Nil for now, to be shown all together later
            newMarker.opacity = 0.5
            newMarker.icon = GMSMarker.markerImage(with: UIColor.green)
            
            //ADD THE NEW CREATED MARKER TO SET
            mutableMarkerSet.add(newMarker)
        
        }
        
        //3.STORE TO ALL MARKERS
        self.allMarkers = mutableMarkerSet.copy() as! Set<MyMarker>
        
        //4. DRAW THE MARKERS
        showMarkers()
        
    }
    
    //SHOW THE MARKERS ON THE MAP
    func showMarkers(){
        for marker in allMarkers{
            if(marker.map == nil){
                marker.map = self.myMapView
            }
        }
        print("THE NUMBER OF MARKERS \(self.allMarkers.count)")
        
    }

    
    
    //SEARCH BAR DELEGATE METHODS
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //DISMISS KEYBOARD SLOWLY
        UIView.animate(withDuration: 0.5, animations: {
            //handle keyboard dismiss
            searchBar.endEditing(true)
        })
        
        self.searchTerm = ""
        
        if let mySearchTerm:String = mySearchBar.text{
            self.searchTerm = mySearchTerm
        }
        
        downloadNewMarkerData()
        
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //DISMISS KEYBOARD SLOWLY
        UIView.animate(withDuration: 0.8, animations: {
            //handle keyboard dismiss
            searchBar.endEditing(true)
        })
        
        searchBar.resignFirstResponder()
    }
    
    

}





