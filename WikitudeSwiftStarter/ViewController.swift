//
//  ViewController.swift
//  WikitudeSwiftStarter
//
//  Created by alexwasner on 5/26/16.
//  Copyright © 2016 alexwasner. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WTArchitectViewDelegate{
    private var architectView:WTArchitectView?
    private var architectWorldNavigation:WTNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try WTArchitectView.isDeviceSupportedForRequiredFeatures(WTFeatures._2DTracking)
            architectView = WTArchitectView(frame: self.view.frame)
            architectView?.delegate = self
            add license here : architectView?.setLicenseKey("ADD LICENSE HERE")
            //broken on purpose so it will not compile until  you add your Wikitude license

            
            self.architectView?.loadArchitectWorldFromURL(NSBundle.mainBundle().URLForResource("index", withExtension: "html", subdirectory: "Web"), withRequiredFeatures: ._2DTracking)
            self.view.addSubview(architectView!)
            
            NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {(notification) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if self.architectWorldNavigation?.wasInterrupted == true{
                            self.architectView?.reloadArchitectWorld()
                        }
                        self.startWikitudeSDKRendering()
                    })
                })
            NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {(notification) in
                dispatch_async(dispatch_get_main_queue(), {
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func startWikitudeSDKRendering(){
        if self.architectView?.isRunning == false{
            self.architectView?.start({ configuration in
                    configuration.captureDevicePosition = AVCaptureDevicePosition.Back
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
    func architectView(architectView: WTArchitectView!, invokedURL URL: NSURL!) {
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
    

    func architectView(architectView: WTArchitectView!, didFinishLoadArchitectWorldNavigation navigation: WTNavigation!) {
        //    /* Architect World did finish loading */
    }
    func architectView(architectView: WTArchitectView!, didFailToLoadArchitectWorldNavigation navigation: WTNavigation!, withError error: NSError!) {
        print("Architect World from URL \(navigation.originalURL) could not be loaded. Reason: \(error.localizedDescription)");
    }
    func architectView(architectView: WTArchitectView!, didEncounterInternalError error: NSError!) {
        print("WTArchitectView encountered an internal error \(error.localizedDescription)");
    }
}