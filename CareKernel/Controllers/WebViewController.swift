//
//  WebViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 13/12/21.
//

import UIKit
import WebKit
import SwiftyJSON

class WebViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var titleLabel: UILabel!
    
    /**
     * Instance to urlString
     */
    var urlString = String()
    var params = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: JSON(params)["urlString"].stringValue)
        let myRequest = URLRequest(url: myURL!)
        self.webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(webView)
//        self.webView.navigationDelegate = self
        self.webView.configuration.preferences.javaScriptEnabled = true
        self.webView.load(myRequest)
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        let titleString = JSON(params)["title"].stringValue
        self.titleLabel.text = titleString
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        self.titleLabel.text = title
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
