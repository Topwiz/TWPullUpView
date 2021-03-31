//
//  TWPullUpOption.swift
//  TWPullUpView
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import UIKit

public struct TWPullUpOption {
    /// Animation option to nearest sticky point when panning is ended
    public var animationDuration: Double = 0.3
    public var animationDamping: CGFloat = 1
    public var animationSpringVelocity: CGFloat = 0.4
    
    /// If view can pull up then max height. (When there is no scrollview inside)
    public var overMaxHeight: Bool = true
    
    /// If view can pull down then min Height
    public var underMinHeight: Bool = true
    
    /// Velocity of the panning to go to next sticky point
    /// If it is 0 it will move to next point right away.
    /// If it is CGFloat.infinity view will need to move more than half up or down to move to the next sticky point
    /// Recommend to use between 1000 ~ 3000
    public var moveToNextPointVelocity: CGFloat = 1500
    
    public init(animationDuration: Double = 0.3,
                animationDamping: CGFloat = 1,
                animationSpringVelocity: CGFloat = 0.4,
                overMaxHeight: Bool = true,
                underMinHeight: Bool = true,
                moveToNextPointVelocity: CGFloat = 1500) {
        
        self.animationDuration = animationDuration
        self.animationDamping = animationDamping
        self.animationSpringVelocity = animationSpringVelocity
        self.overMaxHeight = overMaxHeight
        self.underMinHeight = underMinHeight
        self.moveToNextPointVelocity = moveToNextPointVelocity
    }
}
