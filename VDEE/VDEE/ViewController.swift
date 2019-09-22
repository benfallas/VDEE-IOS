//
//  ViewController.swift
//  VDEE
//
//  Created by Benito Sanchez on 9/20/19.
//  Copyright © 2019 Voz Del Evangelio Eterno. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player:AVPlayer?
    @IBOutlet var playStopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
    
    func setPlayButton() {
        if let image = UIImage(named: "play_button.png") {
            playStopButton.setImage(image, for: UIControl.State.normal)
        }
    }
    
    func setStopButton() {
        if let image = UIImage(named: "stop_button.png") {
            playStopButton.setImage(image, for: UIControl.State.normal)
        }
    }

    @IBAction func onPlayStopButtonClicked(_ sender: UIButton) {
        if ((player != nil) && (player!.rate != 0) && player!.error == nil) {
            player!.pause()
            player = nil
            setPlayButton()
        } else {
            showLoading()
            setupPlayer()
            player!.play()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Only handle observation for the player item context
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                setStopButton()
                dismissLoading()
                break;
            case .failed:
                dismissLoading()
                showError()
                print("failed")

            case .unknown:
                print("buffering")
                
            @unknown default:
                showError()

                print ("Unknown")
            }
        }
    }
    
    func showLoading() {
        let alert = UIAlertController(title: nil, message: "Cargando...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func setupPlayer() {
        let playerItem = AVPlayerItem(url: URL(string: "http://radio.vdee.org:8000/salinas")!)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        player = AVPlayer(playerItem: playerItem)
    }
    
    func dismissLoading() {
        dismiss(animated: false, completion: nil)
    }
    
    func showError() {
        let alert = UIAlertController(title: "Warning", message: "The Internet is not available", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

