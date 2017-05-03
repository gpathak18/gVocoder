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
    var backAudioPlayerNode = AVAudioPlayerNode()
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        try! audioRecorder = AVAudioRecorder(url: soundURL(fileName: "recording1")!, settings: [:])
        
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer:Timer) in
            
            if let audioRecorder = self.audioRecorder {
                audioRecorder.updateMeters()
                self.micAvgPow = audioRecorder.averagePower(forChannel: 0)
                self.micPeak = audioRecorder.peakPower(forChannel: 0)
             }
        })
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(backAudioPlayerNode)
        
        var buttonColor : UIColor = UIColor.init(red: 128/255, green: 216/255, blue: 255/255, alpha: 1.0)
        getCircleButton(bgColor : buttonColor)
        buttonColor  = UIColor.init(red: 100/255, green: 216/255, blue: 203/255, alpha: 1.0)
        getCircleButton(bgColor : buttonColor)
        buttonColor  = UIColor.init(red: 178/255, green: 254/255, blue: 247/255, alpha: 1.0)
        getCircleButton(bgColor : buttonColor)
        
        
        timerEvent.setEventHandler { [weak self] in
            
            guard (self?.audioRecorder) != nil else {
                return
            }
            
            let percent = (Double((self?.micPeak)!) + 160) / 160
           let finalPeak = CGFloat(percent)
            
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

        animateButtonBackground(borderColor: UIColor.green)
        
        
        
        
        let img = swapImage?.cgImage?.cropping(to: CGRect(x: 0.0, y: 80.0*0, width: 80, height: 72))!
        
       // print(swapImage?.cgImage?.width)
        
        let finalimg = UIImage(cgImage: img!)
        
        
        imgView.image = finalimg
        imgView.isUserInteractionEnabled = true
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleRotation))
        
        recognizer.minimumNumberOfTouches = 1
        recognizer.maximumNumberOfTouches = 1
        
        imgView.addGestureRecognizer(recognizer)
       
        self.view.sendSubview(toBack: vfx)

        self.view.sendSubview(toBack: bkgimg)
    }
    
    var rotation = 100
    var index = 0
    
    func handleRotation(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
       
        if ((recognizer.state != UIGestureRecognizerState.ended) &&
            (recognizer.state != UIGestureRecognizerState.failed)) {
            
            index = rotation - Int(translation.y)
        
            if index >= 0 && index <= 100 {
               
                let img = swapImage?.cgImage?.cropping(to: CGRect(x: 0, y: 80*index, width: 100, height: 72))!
                
                let finalimg = UIImage(cgImage: img!)
                
                imgView.image = finalimg
                
                
            }
        } else {
            
            rotation = index
            
        }
    }
    
    
    func animateButtonBackground(borderColor: UIColor){
        
        micButton.layer.borderWidth = 2.0
        let color: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        color.fromValue = UIColor.clear.cgColor
        color.toValue = borderColor.cgColor
        color.duration = 3.0
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
            animateButtonBackground(borderColor: UIColor.green)
        }
    }
    
    func playEffect(backTrack: String) {
        
        let fileFront = try! AVAudioFile(forReading: soundURL(fileName: "recording")!)
        
        let fileBack = try! AVAudioFile(forReading: URL.init(string: Bundle.main.path(forResource: backTrack, ofType: "caf")!)! )
        
        let audioBufferFront = AVAudioPCMBuffer(pcmFormat: fileFront.processingFormat, frameCapacity: AVAudioFrameCount(fileFront.length))
        
        let audioBufferBack = AVAudioPCMBuffer(pcmFormat: fileBack.processingFormat, frameCapacity: AVAudioFrameCount(fileBack.length))
        
        try! fileFront.read(into: audioBufferFront)
        try! fileBack.read(into: audioBufferBack)
        
        // audioEngine.attach(effect)
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioBufferFront.format)
        
        audioEngine.connect(backAudioPlayerNode, to: audioEngine.mainMixerNode, format: audioBufferBack.format)
        
        audioPlayerNode.scheduleBuffer(audioBufferFront, at: nil, options: .interrupts, completionHandler: nil)
        
        backAudioPlayerNode.scheduleBuffer(audioBufferBack, at: nil, options: .interrupts, completionHandler: nil)
        
        audioEngine.prepare()
        try! audioEngine.start()
        
        
        audioPlayerNode.play()
        backAudioPlayerNode.volume = 0.3
        backAudioPlayerNode.play()
        
        
        
    }
    
    @IBAction func barButtonPressed(_ sender: Any) {
        
        //        let distortion = AVAudioUnitDistortion()
        //        distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.speechRadioTower)
        //        distortion.wetDryMix = 25
        
        playEffect(backTrack: "Traffic")
        
    }
    
    @IBAction func poolButtonPressed(_ sender: Any) {
        
        //        let reverb = AVAudioUnitReverb()
        //        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
        //        reverb.wetDryMix = 50
        
        playEffect(backTrack: "Traffic")
        
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
           
            try! recordingSession.setActive(true)
            
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
            
            UIView.animate(withDuration: 0.2, delay: 0.0,  options: [.curveEaseInOut], animations: {
                let button : UIButton = self.circleButton[0]
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: nil)

            
            UIView.animate(withDuration: 0.3, delay : 0.1, options: [.curveEaseInOut], animations: {
                let button : UIButton = self.circleButton[1]
                button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion : nil)

            
            UIView.animate(withDuration: 0.4, delay : 0.2,   options: [.curveEaseInOut],animations: {
                let button : UIButton = self.circleButton[2]
                button.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            }, completion: { finished in
                
                if finished {
                    self.timerEvent.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.milliseconds(50))
                    self.timerEvent.resume()
                    
                }
                
            })
            
            
            isRecording = false
            isStopBorderAnim = false
            
            
        } else  {
            
            micButton.setImage( #imageLiteral(resourceName: "ic_mic_36pt") , for: .normal)
            
            
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
            audioRecorder.stop()
            audioEngine.stop()
            try! recordingSession.setActive(false)
            
            isRecording = true
            
        }
        
    }
    
    var isStopBorderAnim = true
    
    func soundURL(fileName: String) -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent(fileName+".wav")
        //print(soundURL as Any)
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
    
    
    @IBAction func knobDragged(_ sender: Any) {
        
        
    }
    
    
}

