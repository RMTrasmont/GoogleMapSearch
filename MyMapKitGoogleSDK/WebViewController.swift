//
//  WebViewController.swift
//  MyMapKitGoogleSDK
//
//  Created by Rafael M. Trasmontero on 5/23/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit


class WebViewController: UIViewController {
    var webURL:URL?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let restaurantWebURL = webURL else {return}
        webView.loadRequest(URLRequest(url: restaurantWebURL))
        


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    



}
