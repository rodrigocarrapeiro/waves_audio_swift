//
//  AudioBars.swift
//  Waves_audio
//
//  Created by RodrigoCarrapeiro on 18/12/19.
//  Copyright © 2019 Rodrigo Pereira Carrapeiro. All rights reserved.
//

import UIKit
import AVFoundation

class AudioBars: UIView {
    
    @IBInspectable open var frequency:CGFloat = 2.0
    @IBInspectable open var idleAmplitude:CGFloat = 0.01
    @IBInspectable open var phaseShift:CGFloat = -0.15
    @IBInspectable open var density:CGFloat = 1.0
    @IBInspectable open var primaryLineWidth:CGFloat = 1.5
    @IBInspectable open var secondaryLineWidth:CGFloat = 0.5
    @IBInspectable open var numberOfWaves:Int = 6
    @IBInspectable open var waveColor:UIColor = UIColor.orange
    @IBInspectable open var recorder:AVAudioRecorder?
    
    var timer:Timer?
    
    @IBInspectable open var amplitude:CGFloat = 0.0 {
        didSet {
            amplitude = max(amplitude, self.idleAmplitude)
            self.setNeedsDisplay()
        }
    }
    
    fileprivate var phase:CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func start(){
        timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(AudioBars.refreshAudioView(_:)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        self.amplitude = CGFloat(0.0)
        self.recorder?.stop()
        timer?.invalidate()
        timer = nil
        
    }
    
    @objc internal func refreshAudioView(_:Timer) {
        
        if self.recorder == nil {
            self.amplitude = CGFloat(0.0)
            return
        }
        
        self.recorder?.updateMeters()
        
        let decibels:Float = (self.recorder?.averagePower(forChannel: 0))!
        
        if decibels < -60.0 || decibels == 0.0{
            self.amplitude = CGFloat(0.0)
        }else{
            let power = powf((powf(10.0, 0.05 * Float(decibels)) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0)
            self.amplitude = CGFloat(power)
        }
        
    }
    
    
    
    
    override open func draw(_ rect: CGRect) {
        // Convenience function to draw the wave
        func drawWave(_ index:Int, maxAmplitude:CGFloat, normedAmplitude:CGFloat) {
            let path = UIBezierPath()
            let mid = self.bounds.width/2.0
            
            path.lineWidth = index == 0 ? self.primaryLineWidth : self.secondaryLineWidth
            
            for x in Swift.stride(from:0, to:self.bounds.width + self.density, by:self.density) {
                // Parabolic scaling
                let scaling = -pow(1 / mid * (x - mid), 2) + 1
                let y = scaling * maxAmplitude * normedAmplitude * sin(CGFloat(2 * Double.pi) * self.frequency * (x / self.bounds.width)  + self.phase) + self.bounds.height/2.0
                if x == 0 {
                    path.move(to: CGPoint(x:x, y:y))
                } else {
                    path.addLine(to: CGPoint(x:x, y:y))
                }
            }
            path.stroke()
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(true)
        
        self.backgroundColor?.set()
        context?.fill(rect)
        
        let halfHeight = self.bounds.height / 2.0
        let maxAmplitude = halfHeight - self.primaryLineWidth
        
        for i in 0 ..< self.numberOfWaves {
            let progress = 1.0 - CGFloat(i) / CGFloat(self.numberOfWaves)
            let normedAmplitude = (1.5 * progress - 0.8) * self.amplitude
            let multiplier = min(1.0, (progress/3.0*2.0) + (1.0/3.0))
            self.waveColor.withAlphaComponent(multiplier * self.waveColor.cgColor.alpha).set()
            drawWave(i, maxAmplitude: maxAmplitude, normedAmplitude: normedAmplitude)
        }
        self.phase += self.phaseShift
    }
    
    
}



