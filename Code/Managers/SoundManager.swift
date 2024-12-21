import AVFoundation
import Foundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var currentMusic: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            print("Setting up audio session")
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(_ name: String) {
        //print("Attempting to play sound: \(name)")
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("❌ Could not find sound file: \(name).mp3")
            //print("Bundle path: \(Bundle.main.bundlePath)")
            return
        }
        
        do {
            //print("Playing sound: \(name)")
            let player = try AVAudioPlayer(contentsOf: url)
            player.enableRate = true
            player.rate = Float.random(in: 0.9...1.1)
            player.play()
            audioPlayers[name] = player
        } catch {
            //print("Failed to play sound: \(error)")
        }
    }
    
    func playRandomVariation(baseName: String, variations: Int) {
        let variation = Int.random(in: 1...variations)
        playSound("\(baseName)_\(variation)")
    }
    
    func playMusic(_ name: String) {
        currentMusic?.stop()
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            currentMusic = try AVAudioPlayer(contentsOf: url)
            currentMusic?.numberOfLoops = -1 // Infinite loop
            currentMusic?.play()
        } catch {
            print("Failed to play music: \(error)")
        }
    }
    
    func stopSound(_ name: String) {
        //print("Attempting to stop sound: \(name)")
        if let player = audioPlayers[name] {
            player.stop()
            audioPlayers.removeValue(forKey: name)
            print("Stopped sound: \(name)")
        }
    }
    
    func stopAllSounds() {
        // Stop all sound effects
        for (name, player) in audioPlayers {
            player.stop()
            print("Stopped sound: \(name)")
        }
        audioPlayers.removeAll()
        
        // Stop current music if playing
        currentMusic?.stop()
        currentMusic = nil
    }
} 