//
//  ViewController.swift
//  WikitudeSwiftStarter
//
//  Created by alexwasner on 5/26/16.
//  Copyright © 2016 alexwasner. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WTArchitectViewDelegate{
    fileprivate var architectView:WTArchitectView?
    fileprivate var architectWorldNavigation:WTNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try WTArchitectView.isDeviceSupported(forRequiredFeatures: WTFeatures._ImageTracking)
            architectView = WTArchitectView(frame: self.view.frame)
            architectView?.requiredFeatures = ._ImageTracking
            architectView?.delegate = self
            architectView?.setLicenseKey("xxx")
            //broken on purpose so it will not compile until  you add your Wikitude license

            
            self.architectView?.loadArchitectWorld(from: Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web")!)
            self.view.addSubview(architectView!)
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main, using: {(notification) in
                    DispatchQueue.main.async(execute: {
                        if self.architectWorldNavigation?.wasInterrupted == true{
                            self.architectView?.reloadArchitectWorld()
                        }
                        self.startWikitudeSDKRendering()
                    })
                })
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: OperationQueue.main, using: {(notification) in
                DispatchQueue.main.async(execute: {
                    self.stopWikitudeSDKRendering()
                })
            })
            
            
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    func startWikitudeSDKRendering(){
        if self.architectView?.isRunning == false{
            self.architectView?.start({ configuration in
                    configuration.captureDevicePosition = AVCaptureDevicePosition.back
                }, completion: {isRunning, error in
                    if !isRunning{
                        print("WTArchitectView could not be started. Reason: \(error.localizedDescription)")
                    }
            })
        }
    }
    
    func stopWikitudeSDKRendering(){
        if self.architectView?.isRunning == true{
            self.architectView?.stop()
        }

    }
    func architectView(_ architectView: WTArchitectView, invokedURL URL: Foundation.URL) {
        //do shit here
        
//        - (void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL
//        {
//            NSDictionary *parameters = [URL URLParameter];
//            if ( parameters )
//            {
//                if ( [[URL absoluteString] hasPrefix:@"architectsdk://button"] )
//                {
//                    NSString *action = [parameters objectForKey:@"action"];
//                    if ( [action isEqualToString:@"captureScreen"] )
//                    {
//                        [self captureScreen];
//                    }
//                }
//                else if ( [[URL absoluteString] hasPrefix:@"architectsdk://markerselected"])
//                {
//                    [self presentPoiDetails:parameters];
//                }
//            }
//        }
    }
    

    func architectView(_ architectView: WTArchitectView, didFinishLoadArchitectWorldNavigation navigation: WTNavigation) {
        //    /* Architect World did finish loading */
    }
    func architectView(_ architectView: WTArchitectView, didFailToLoadArchitectWorldNavigation navigation: WTNavigation, withError error: Error) {
        print("Architect World from URL \(navigation.originalURL) could not be loaded. Reason: \(error.localizedDescription)");
    }
    func architectView(_ architectView: WTArchitectView!, didEncounterInternalError error: NSError!) {
        print("WTArchitectView encountered an internal error \(error.localizedDescription)");
    }
}
