//
//  TWPullUpOption.swift
//  TWPullUpView
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import UIKit

final class TWPullUpOption: TWOptionProtocol {
    var animationDuration: Double = 0.3
    var animationDamping: CGFloat = 1
    var animationSpringVelocity: CGFloat = 0.4
    var overMaxHeight: Bool = true
    var underMinHeight: Bool = true
}
