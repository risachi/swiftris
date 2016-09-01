//
//  AccessibilityUtil.swift
//  swiftris
//
//  Created by Lisa on 8/31/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import Foundation
import UIKit


struct AccessibilityUtil {
    
    func voiceOverIsRunning() -> Bool {
        return UIAccessibilityIsVoiceOverRunning()
    }

    func say(this: String) {
        print("DEBUG: say(\(this))")
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, this);
    }
    
}