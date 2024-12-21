import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare the generators
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }
    
    func playKillImpact() {
        impactFeedbackGenerator.impactOccurred(intensity: 0.7)
    }
    
    func playDamageImpact() {
        impactFeedbackGenerator.impactOccurred(intensity: 0.5)
    }
    
    func playWaveComplete() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    func playWaveFailed() {
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
} 