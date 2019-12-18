//
//  ViewController.swift
//  Waves_audio
//
//  Created by RodrigoCarrapeiro on 18/12/19.
//  Copyright © 2019 Rodrigo Pereira Carrapeiro. All rights reserved.
//

import UIKit
import CoreAudio
import CoreAudioKit
import AVFoundation
import Foundation
import AVKit


class ViewController: UIViewController {
    var recordingName: String  = ""
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!
    var playAudio: AVAudioPlayer?
    
    @IBOutlet var viewEqualizer: AudioBars!
    @IBOutlet var recordButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        initRecorderConfig()

    }


    func initRecorderConfig() -> Void
    {
        recordingName  = Utils().randomString(length: 6)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.recordButton.addGestureRecognizer(longPress)
        
        do {
            if #available(iOS 10.0, *) {
                
                let settings = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 8000, channels: 1, interleaved: true)
                try recordingSession.setCategory(.playAndRecord, mode: .default, options: [])
                recorder = try AVAudioRecorder(url:  urlFileNamePath(), format: settings!)
                
            } else {
                recordingSession.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playback, with:  [])
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 8000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                ]
                recorder = try AVAudioRecorder(url: urlFileNamePath(), settings: settings)
            }
            
            try recordingSession.setActive(true)
            
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            viewEqualizer.recorder = recorder
            
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    @IBAction func recordAudio(_ sender: Any) {
        
        if self.recorder == nil {
            self.startRecording()
        } else {
            self.finishRecording(success: true)
        }
    }
    
    func urlFileNamePath() -> URL{
        return  Utils().getDocumentsDirectory().appendingPathComponent(recordingName + ".wav")
    }

    @objc func longPress(_ guesture: UILongPressGestureRecognizer) {
        
        if guesture.state == UIGestureRecognizer.State.began {
            print("Long Press")
            startRecording()
        }
        
        if guesture.state == UIGestureRecognizer.State.ended {
            print("Ended Press")
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        recorder.record()
        recorder.updateMeters()
        self.viewEqualizer.start()
        
    }
    
    func finishRecording(success: Bool) {
        recorder?.stop()
        playAudioRecorder()
        self.viewEqualizer.stop()
    }
    
}

extension ViewController : AVAudioRecorderDelegate{
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}


extension ViewController : AVAudioPlayerDelegate{
    
    func playAudioRecorder(){
        
        do {
            playAudio = try AVAudioPlayer(contentsOf: urlFileNamePath())
            playAudio?.play()
            playAudio?.delegate = self
            
            recordButton.setTitle("Playback Started...", for: .normal)
            
        } catch {
            // couldn't load file :(
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag {
            recordButton.setTitle("Playback finished!", for: .normal)
        }
    }
}
