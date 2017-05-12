//
//  MainPanelViewController.swift
//  VocalFun
//
//  Created by Gaurav Pathak on 4/19/17.
//  Copyright © 2017 gpmax. All rights reserved.
//

import UIKit
import AVFoundation


class MainPanelViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var bkgimg: UIImageView!
    
    @IBOutlet weak var vfx: UIVisualEffectView!
    
    var recordingSession : AVAudioSession!
    var audioRecorder    : AVAudioRecorder!
    
    @IBOutlet weak var imgView: UIImageView!
    var audioEngine     = AVAudioEngine()
    var audioPlayerNode = AVAudioPlayerNode()
    
    let swapImage = UIImage(named:"knob1")?.withRenderingMode(
        UIImageRenderingMode.alwaysTemplate)
    
//    let swapImage = UIImage(named:"main_knob")?.withRenderingMode(
//        UIImageRenderingMode.alwaysTemplate)
    
    var meterTimer: Timer?
    var micPeak: Float = 0
    var micAvgPow: Float = 0
    var timerEvent = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    var circleButton = [UIButton]()
    
    private var isRecording = true
    
    @IBOutlet weak var micButton: DesinableButtons!
    
    let audioManager : AudioManager = AudioManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        recordingSession = AVAudioSession.sharedInstance()
        
        //try! audioRecorder = AVAudioRecorder(url: soundURL(fileName: "recording")!, settings: [:])
        
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer:Timer) in
            
//            if let audioRecorder = self.audioRecorder {
//                audioRecorder.updateMeters()
//                self.micPeak = audioRecorder.peakPower(forChannel: 0)
//             }
            
            guard (self.audioManager) != nil else {
                return
            }
            
            self.micPeak = self.audioManager.volumeFloat
            
        })
        
        
        var buttonColor : UIColor = UIColor.init(red: 128/255, green: 216/255, blue: 255/255, alpha: 1.0)
        getCircleButton(bgColor : buttonColor)
        buttonColor  = UIColor.init(red: 100/255, green: 216/255, blue: 203/255, alpha: 1.0)
        getCircleButton(bgColor : buttonColor)
        buttonColor  = UIColor.init(red: 178/255, green: 254/255, blue: 247/255, alpha: 1.0)
        getCircleButton(bgColor : buttonColor)
        
        
        timerEvent.setEventHandler { [weak self] in
            
//            guard (self?.audioRecorder) != nil else {
//                return
//            }
            
            guard (self?.audioManager) != nil else {
                return
            }
            
           let percent = (Double((self?.micPeak)!) + 160) / 160
           
           let finalPeak = CGFloat(percent)
            
            print(String(describing: finalPeak))
            
           //let finalPeak = CGFloat(self!.micPeak)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                let button : UIButton = self!.circleButton[2]
                button.transform = CGAffineTransform(scaleX: finalPeak*2.5, y: finalPeak*2.5)
                button.backgroundColor = UIColor.init(red: 128*finalPeak/255, green: 216*finalPeak/255, blue: 255*finalPeak/255, alpha: 1.0)
            }, completion: nil)
            
            
            UIView.animate(withDuration: 0.4, delay : 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                let button : UIButton = self!.circleButton[1]
                button.transform = CGAffineTransform(scaleX: finalPeak*2, y: finalPeak*2)
                button.backgroundColor = UIColor.init(red: 100*finalPeak/255, green: 216*finalPeak/255, blue: 203*finalPeak/255, alpha: 1.0)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay : 0.2, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                let button : UIButton = self!.circleButton[0]
                button.transform = CGAffineTransform(scaleX: finalPeak*1.5, y: finalPeak*1.5)
                button.backgroundColor = UIColor.init(red: 178*finalPeak/255, green: 254*finalPeak/255, blue: 247*finalPeak/255, alpha: 1.0)
            }, completion: nil)
        }

        self.timerEvent.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.milliseconds(50))
        
        let borderColor  = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        animateButtonBackground(borderColor: borderColor)
       
        self.view.sendSubview(toBack: vfx)

        self.view.sendSubview(toBack: bkgimg)
        
        let inputNode = audioEngine.inputNode
        let bus = 0
        
        inputNode?.installTap(onBus: bus, bufferSize: 2048, format: inputNode?.inputFormat(forBus: bus)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            
        }
        
        audioManager.initializeAudioEngine()
        
        //prepareAudioEngine()
       
    }
    
    var audioBuffer = AVAudioPCMBuffer()
    
    @IBAction func playRecording(_ sender: Any) {
        
//         if isRecording {
//            audioManager.startRecording()
//            isRecording = false;
//         } else {
//            audioManager.stopRecording()
//            isRecording = true;
//         }
        
       //try! recording.read(into: audioBuffer)
        
      // audioPlayerNode.play()
    }
    
    func animateButtonBackground(borderColor: UIColor){
        
        micButton.layer.borderWidth = 2.0
        let color: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        color.fromValue = UIColor.clear.cgColor
        color.toValue = borderColor.cgColor
        color.duration = 0.5
        color.autoreverses = true
        color.fillMode = kCAFillModeForwards
        color.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        color.delegate = self
        self.micButton.layer.borderColor = UIColor.clear.cgColor
        self.micButton.layer.add(color, forKey: "")

    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !isStopBorderAnim {
            animateButtonBackground(borderColor: UIColor.red)
        } else {
            animateButtonBackground(borderColor: UIColor.white)
        }
    }
    
    
    func prepareAudioEngine() {
        
        let recording = try! AVAudioFile(forReading: soundURL(fileName: "recording")!)
        
        audioBuffer = AVAudioPCMBuffer(pcmFormat: recording.processingFormat, frameCapacity: AVAudioFrameCount(recording.length))
        
        //try! recording.read(into: audioBuffer)
        
        
        addDistortion(audioBuffer: audioBuffer)
        addReverb(audioBuffer: audioBuffer)
        audioPlayerNode.scheduleBuffer(audioBuffer, at: nil, options: .interrupts, completionHandler: nil)
        audioEngine.prepare()

    }
    
    
    let pitchEffect = AVAudioUnitTimePitch()
    let reverb = AVAudioUnitReverb()
    let distortion = AVAudioUnitDistortion()
    
    func addDistortion(audioBuffer: AVAudioPCMBuffer){
       
        audioEngine.attach(distortion)
        
        audioEngine.connect(audioPlayerNode, to: distortion, format: audioBuffer.format)
        
        audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: audioBuffer.format)
        
    }
    
    
    func addReverb(audioBuffer: AVAudioPCMBuffer){

        audioEngine.attach(reverb)
        
        audioEngine.connect(audioPlayerNode, to: distortion, format: audioBuffer.format)
        
        audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: audioBuffer.format)
        
    }
    
    @IBAction func barButtonPressed(_ sender: Any) {
    
        pitchEffect.pitch = -500
        pitchEffect.rate = 0.5
        
    }
    
    @IBAction func poolButtonPressed(_ sender: Any) {
        
        
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
        reverb.wetDryMix = 50
      
   }
    
    @IBAction func distortionEffect(_ sender: Any) {
        
        
        distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.drumsLoFi)
        distortion.wetDryMix = 50
    
    }
    
    func getCircleButton(bgColor : UIColor){
        
        let button = UIButton()
        button.frame = micButton.frame
        button.backgroundColor = bgColor
        button.layer.cornerRadius = 30
        button.alpha = 1.0
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowRadius = 4.0
        button.layer.shadowOpacity = 0.9
        button.layer.shadowOffset = CGSize.zero
        button.layer.masksToBounds = false
        
        self.view.addSubview(button)
        self.view.sendSubview(toBack: button)
        
        circleButton.append(button)
        
        
    }
    
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        
        if isRecording {
            
            micButton.setImage( #imageLiteral(resourceName: "ic_stop_36pt"), for: .normal)
           
//            try! recordingSession.setActive(true)
//            
//            audioRecorder.delegate = self
//            audioRecorder.isMeteringEnabled = true
//            audioRecorder.prepareToRecord()
//            audioRecorder.record()
            
            audioManager.startRecording()
            
            UIView.animate(withDuration: 0.2, delay: 0.0,  options: [.curveEaseInOut], animations: {
                let button : UIButton = self.circleButton[0]
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: nil)

            
            UIView.animate(withDuration: 0.2, delay : 0.1, options: [.curveEaseInOut], animations: {
                let button : UIButton = self.circleButton[1]
                button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion : nil)

            
            UIView.animate(withDuration: 0.2, delay : 0.2,   options: [.curveEaseInOut],animations: {
                let button : UIButton = self.circleButton[2]
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { finished in
                
                if finished {

                    self.timerEvent.resume()
                    
                }
                
            })
            
            
            isRecording = false
            isStopBorderAnim = false
            
            
        } else  {
            
            micButton.setImage( #imageLiteral(resourceName: "ic_mic_36pt") , for: .normal)
            
            audioManager.stopRecording()
            
            UIView.animate(withDuration: 0.2, delay : 0.0,  options: [.curveEaseInOut],animations: {
                let button : UIButton = self.circleButton[0]
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: nil )
            
            
            UIView.animate(withDuration: 0.3, delay : 0.1, options: [.curveEaseInOut], animations: {
                let button : UIButton = self.circleButton[1]
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion : nil)
            
            UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseInOut], animations: {
                let button : UIButton = self.circleButton[2]
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: nil)
            
            
            isStopBorderAnim = true
            
            timerEvent.suspend()
//            audioRecorder.stop()
//            audioEngine.stop()
//            try! recordingSession.setActive(false)
            
            isRecording = true
            
        }
        
    }
    
    var isStopBorderAnim = true
    
    func soundURL(fileName: String) -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent(fileName+".wav")
        print(soundURL as Any)
        return soundURL as URL?
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finished.")
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        print(error.debugDescription)
    }
    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        print(player.debugDescription)
    }
    
    
    
    
}

