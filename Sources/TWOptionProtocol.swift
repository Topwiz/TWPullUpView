//
//  TWOptionType.swift
//  TWPullUpView
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import UIKit

public protocol TWOptionProtocol {
    var animationDuration: Double { get }
    var animationDamping: CGFloat { get }
    var animationSpringVelocity: CGFloat { get }
    var overMaxHeight: Bool { get }
    var underMinHeight: Bool { get }
}
