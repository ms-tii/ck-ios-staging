//
//  IncidentWebViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 20/09/22.
//

import UIKit
import WebKit
import SwiftyJSON

class IncidentWebViewController: UIViewController, WKScriptMessageHandler {

    

    @IBOutlet var webView: WKWebView!
    @IBOutlet var titleLabel: UILabel!
    
    /**
     * Instance to urlString
     */
    var urlString = String()
    var params = [String:String]()
    var mNativeToWebHandler : String = "carekernelHandler"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: JSON(params)["urlString"].stringValue)
        let myRequest = URLRequest(url: myURL!)
        self.webView.allowsBackForwardNavigationGestures = true
        DispatchQueue.main.async {
            self.view.addSubview(self.webView)
    //        self.webView.navigationDelegate = self
            self.webView.configuration.preferences.javaScriptEnabled = true
            self.webView.load(myRequest)
            let contentController = WKUserContentController()
            self.webView.configuration.userContentController = contentController
            self.webView.configuration.userContentController.add(self, name: self.mNativeToWebHandler)
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
            }
            let titleString = JSON(self.params)["title"].stringValue
            self.titleLabel.text = titleString
        }
       
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
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == mNativeToWebHandler {
            guard let resDict = message.body as? [String : AnyObject] else {
                showAlert("CareKernel", message: "Something went wrong.", actions: ["OK"]) { response in
                    self.dismiss(animated: true)
                }
                return
            }
            print(JSON(resDict))
            let message = JSON(resDict)["message"].stringValue
            print(message)
            if message == "Successfully added." || message == "Successfully edited." {
                showAlert("CareKernel", message: message, actions: ["OK"]) { response in
                    self.dismiss(animated: true)
                }
            }else{
                showAlert("CareKernel", message: message, actions: ["OK"]) { response in
                    self.dismiss(animated: true)
                }
            }
        }
       
    }
}
