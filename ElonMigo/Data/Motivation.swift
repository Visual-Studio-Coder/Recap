//
//  Motivation.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Motivation {
    static let wrong = ["Mistakes are proof that you are trying.", "Every mistake is a step closer to success.", "Failure is the opportunity to begin again more intelligently.", "Believe in yourself, you'll get it next time!", "Keep going, you're closer than you think!", "You're on the right track, keep pushing forward!", "Don't give up, you're capable of amazing things!", "Success is not final, failure is not fatal: It is the courage to continue that counts.", "You're one step closer to mastering this!", "Every wrong answer brings you closer to the right one."]
    static let correct = ["Well done, you're on fire!", "Great job, keep up the good work!", "Fantastic, you're crushing it!", "You nailed it, way to go!", "Excellent work, you're unstoppable!", "Bravo, you're a star!", "Superb, keep shining bright!", "Impressive, you're on a roll!", "Outstanding, you're killing it!", "Amazing job, you're a rockstar!"]
    
    static var wrongMotivation: String {
        return wrong.randomElement() ?? "Keep going, you're closer than you think!"
    }
    
    static var correctMotivation: String {
        return correct.randomElement() ?? "Keep going, you're doing great!"
    }
}
