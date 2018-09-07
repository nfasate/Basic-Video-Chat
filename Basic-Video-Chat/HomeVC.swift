//
//  HomeVC.swift
//  Basic-Video-Chat
//
//  Created by NILESH_iOS on 07/09/18.
//  Copyright © 2018 tokbox. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func open(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "videoController") as! ViewController
        //controller.modalPresentationStyle = .overCurrentContext
        //controller.modalPresentationStyle = .custom
        //present(controller, animated: true, completion: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.addSubview((controller.view)!)
        controller.view.frame = (appDelegate.window?.bounds)!
        controller.view.alpha = 0
        controller.view.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            controller.view.isHidden = false
            controller.view.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func timePass(_ sender: UIButton) {
        let alertC = UIAlertController(title: "This is test", message: "Hi", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .cancel) { (action) in
            
        }
        
        alertC.addAction(actionOk)
        present(alertC, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
