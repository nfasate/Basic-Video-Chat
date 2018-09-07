//
//  ViewController.swift
//  Hello-World
//
//  Created by Roberto Perez Cubero on 11/08/16.
//  Copyright © 2016 tokbox. All rights reserved.
//

import UIKit
import OpenTok

// *** Fill the following variables using your own Project info  ***
// ***            https://tokbox.com/account/#/                  ***
// Replace with your OpenTok API key
let kApiKey = "46178582"
// Replace with your generated session ID
let kSessionId = "1_MX40NjE3ODU4Mn5-MTUzNjMwMzI3MzMxMH5OZlBNK1NGNEpqM056aTl3WjV6VDNMRWF-fg"
// Replace with your generated token
let kToken = "T1==cGFydG5lcl9pZD00NjE3ODU4MiZzaWc9ZjYzNmUxNmJhMTljMDA4ZDZiODgzYTU1YzMxYjU3ZmQ1MDIxODZlZjpzZXNzaW9uX2lkPTFfTVg0ME5qRTNPRFU0TW41LU1UVXpOak13TXpJM016TXhNSDVPWmxCTksxTkdORXBxTTA1NmFUbDNXalY2VkROTVJXRi1mZyZjcmVhdGVfdGltZT0xNTM2MzAzMjkyJm5vbmNlPTAuNTU1MjQzMzQ4MTcyOTY3JnJvbGU9cHVibGlzaGVyJmV4cGlyZV90aW1lPTE1MzYzODk2OTImaW5pdGlhbF9sYXlvdXRfY2xhc3NfbGlzdD0="
//let kToken = "T1==cGFydG5lcl9pZD00NjE3ODU4MiZzaWc9ZGRhMjE2YmYxOTc3YzliNWY3MGEwMzMxMTk0MzY2ZjJkMGJjMzE1MDpzZXNzaW9uX2lkPTFfTVg0ME5qRTNPRFU0TW41LU1UVXpOVGsyT1RjeU16azJNMzVLZVRWcVJDdFVlazVzS3psNFVUbGxlSEJ2Y2tVdllTOS1mZyZjcmVhdGVfdGltZT0xNTM1OTcwMjQ5Jm5vbmNlPTAuMDM0ODEyODAwMDc3NDM1NDgmcm9sZT1zdWJzY3JpYmVyJmV4cGlyZV90aW1lPTE1MzU5NzM4NDcmaW5pdGlhbF9sYXlvdXRfY2xhc3NfbGlzdD0="

let kWidgetHeight = 240
let kWidgetWidth = 320

enum VideoDismissState {
    case cornerRadiusChanging, sizeChanging, complete
}

class ViewController: UIViewController {
    lazy var session: OTSession = {
        return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    
    var tapGesture = UITapGestureRecognizer()
    
    var initialGesturePosition: CGPoint = .zero
    var maxCornerRadiusGesturePosition: CGPoint = .zero
    var dismissState: VideoDismissState = .cornerRadiusChanging
    let swipeGesture = UIPanGestureRecognizer()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doConnect()
        view.backgroundColor = .clear
        view.isOpaque = false
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.connect(withToken: kToken, error: &error)
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            view.addSubview(pubView)
            
            //tapGesture = UITapGestureRecognizer(target: self, action: #selector(animatePublisherView))
            //tapGesture.numberOfTapsRequired = 1
            //tapGesture.numberOfTouchesRequired = 1
            //pubView.addGestureRecognizer(tapGesture)
            pubView.isUserInteractionEnabled = false
           
            
            swipeGesture.addTarget(self, action: #selector(minimiseView(_:)))
            //swipeGesture.direction = .down
            self.view?.addGestureRecognizer(swipeGesture)
            //pubView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(minimiseView(_:))))
        }
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    

    
    func minimiseView(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.view)
        print("Location \(location), gesture.state : \(gesture.state)")
        switch gesture.state {
        case .began:
            initialGesturePosition = gesture.location(in: self.view)
            dismissState = .cornerRadiusChanging
        case .changed:
            let currentPosition = gesture.location(in: self.view)
            switch dismissState {
            case .cornerRadiusChanging:
                if let pubView = publisher.view {
                    let swipeDistance = distance(between: initialGesturePosition, and: currentPosition)
                    // play around with this formula to see what feels right
                    self.view.layer.cornerRadius = swipeDistance / 2
                    
                    // at a certain point, switch to changing the size
                    if swipeDistance >= self.view.frame.width / 2 {
                        maxCornerRadiusGesturePosition = currentPosition
                        dismissState = .sizeChanging
                    }
                }
            case .sizeChanging:
                if let pubView = publisher.view {
                    let swipeDistance = distance(between: maxCornerRadiusGesturePosition, and: currentPosition)
                    // again try different things to see what feels right here
                    var scaleFactor = 50 / swipeDistance
                    if scaleFactor >= 1 {
                        scaleFactor = scaleFactor/2
                    }
                    self.view.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                    if scaleFactor <= 0.2 {
                        dismissState = .complete
                    }
                    
                }
            case .complete:
                // reset values
                initialGesturePosition = .zero
                maxCornerRadiusGesturePosition = .zero
            }
        case .ended: break
            // if the gesture ends too soon you may want to animate the view back to full screen
        case .possible:
            break
        case .cancelled:
            break
        case .failed:
            break
        }
    }
    
    /// Measure distance between two points
    func distance(between first: CGPoint, and second: CGPoint) -> CGFloat {
        let xDist = first.x - second.x
        let yDist = first.y - second.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}

// MARK: - OTSession delegate callbacks
extension ViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension ViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension ViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let subsView = subscriber?.view {
            subsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            view.addSubview(subsView)
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateSubscriberView))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            subsView.addGestureRecognizer(tapGesture)
            subsView.isUserInteractionEnabled = false
            
            showSmallPublisherView()
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func showSmallPublisherView() {
        if let pubView = publisher.view {
            self.view.bringSubview(toFront: pubView)
            pubView.isUserInteractionEnabled = true
            pubView.frame = CGRect(x: self.view.frame.width - 130, y: 30, width: 120, height: 150)
            pubView.transform = CGAffineTransform(scaleX: 5, y: 5)
            UIView.animate(withDuration: 0.4, animations: {
                pubView.transform = CGAffineTransform.identity
                //pubView.roundedAllCorner()
            })
        }
    }
    
    func showSmallSubscriberView() {
        if let subsView = subscriber?.view {
            self.view.bringSubview(toFront: subsView)
            subsView.isUserInteractionEnabled = true
            subsView.frame = CGRect(x: self.view.frame.width - 130, y: 30, width: 120, height: 150)
            subsView.transform = CGAffineTransform(scaleX: 5, y: 5)
            UIView.animate(withDuration: 0.4, animations: {
                subsView.transform = CGAffineTransform.identity
                //subsView.roundedAllCorner()
            })
        }
    }
    
    @objc func animatePublisherView() {
        if let pubView = publisher.view {
            pubView.isUserInteractionEnabled = false
            pubView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            showSmallSubscriberView()
        }
    }
    
    @objc func animateSubscriberView() {
        if let subsView = subscriber?.view {
            subsView.isUserInteractionEnabled = false
            subsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            showSmallPublisherView()
        }
    }
}

extension UIView {
    func roundedTopLeft(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundedTopRight(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedBottomLeft(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedBottomRight(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedBottom(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomRight , .bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedTop(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .topLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedLeft(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedRight(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .bottomRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundedAllCorner(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .bottomRight , .topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}

