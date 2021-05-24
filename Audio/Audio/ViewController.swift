//
//  ViewController.swift
//  Audio
//
//  Created by Amit Kumar on 11/05/21.
//

import UIKit
import Accelerate
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var audioPlotView: AudioPlotView!

    var audioEngine : AVAudioEngine?
    
    var layer: CAShapeLayer?
    var waveform = [Float]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        print (audioPlotView.frame)
        print (audioPlotView.bounds)
    }
    
    func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var val : Float = 0
        vDSP_measqv(data, 1, &val, frameLength)
        val *= 1000
        return val
    }
    
    func processAudioData(buffer: AVAudioPCMBuffer){
        guard let channelData = buffer.floatChannelData?[0] else {return}
        let frames = buffer.frameLength
        
        let rmsValue = rms(data: channelData, frameLength: UInt(frames))
        audioPlotView.waveforms.append(Int(rmsValue))
       // waveform.append(rmsValue)
        print(rmsValue)
    }
    
    func setup() {
        audioEngine = AVAudioEngine()
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        
        let inputNode = self.audioEngine!.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [self] (buffer, time) in
        
            processAudioData(buffer: buffer)
            DispatchQueue.main.async {
                audioPlotView.setNeedsDisplay()
            }
        }
        
        _ = audioEngine?.mainMixerNode
        audioEngine?.prepare()
    }
    
    @IBAction func startEngine(_ sender: Any) {
        do {
            try audioEngine?.start()
            print("engine started")
        } catch {
            print (error)
        }
    }
    
    @IBAction func stopEngine(_ sender: Any) {
        audioEngine?.stop()
        print("engine stopped")
    }
    
    @IBAction func clear(_ sender: Any) {
    
    }
    
    
    @IBAction func shiftWaveForm(_ sender: Any) {
        audioPlotView.shiftWaveform()
    }
}

