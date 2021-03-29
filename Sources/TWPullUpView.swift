//
//  TWPullUpView.swift
//  TWPullUpView
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import UIKit

public enum TWStickyPoint {
    case percent(CGFloat)
    case custom(CGFloat)
    case max
    
    var toHeight: CGFloat {
        switch self {
        case .percent(let percent):
            return UIScreen.main.bounds.height * percent
        case .custom(let height):
            return height
        case .max:
            return UIScreen.main.bounds.height
        }
    }
}

open class TWPullUpView: UIView {
    
    //Options
    private var option: TWOptionProtocol = TWPullUpOption()
    private var initialStickyPoint: TWStickyPoint = .percent(0.3)
    
    open var stickyPoints: [TWStickyPoint] = [.percent(0.3), .percent(0.6), .max] {
        didSet {
            stickyPoints = stickyPoints.sorted(by: {  $0.toHeight < $1.toHeight })
            if stickyPoints.count <= 1 {
                fatalError("You need to add more than 2 sticky points.")
            }
        }
    }
    
    public var willMoveToPoint: ((CGFloat) -> ())?
    public var didMoveToPoint: ((CGFloat) -> ())?
    public var didChangePoint: ((CGFloat) -> ())?
    
    private var currentPoint: CGFloat = 0
    public var getCurrentPoint: CGFloat {
        get { return currentPoint }
    }
    
    private weak var scrollView: UIScrollView?
    
    // Constraint
    private var leftConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    
    private var panningStartPoint: CGFloat?
    private var scrollViewDefaultOffsetY: CGFloat! {
        get {
            return -(scrollView?.contentInset.top ?? 0)
        }
    }
    
    private var offsetCorrection: CGFloat?
    private var scrollViewBounceCorrection: CGFloat?
    private var slowDownPoint: CGFloat?
    
    
    /// Add pull up view to parent view
    /// - Parameters:
    ///   - view: Parent view
    ///   - initialStickyPoint: Starting sticky point
    ///   - animated: Animate to start sticky point
    ///   - completion: Return's after finishing animation
    public func addOn(_ view: UIView,
                      initialStickyPoint: TWStickyPoint,
                      animated: Bool,
                      completion: (()->())? = nil) {
        
        setup(superview: view, initialStickyPoint: initialStickyPoint, animate: animated)
    }
}

extension TWPullUpView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - SetUp
extension TWPullUpView {
    // MARK: - SetUp
    private func setup(superview: UIView, initialStickyPoint: TWStickyPoint, animate: Bool) {
        translatesAutoresizingMaskIntoConstraints = false
        self.initialStickyPoint = initialStickyPoint
        superview.addSubview(self)
        setConstraint()
        setupPanGesture()
        animateView(to: initialStickyPoint, animate: animate)
    }
    
    
    /// Add scrollView for scroll connection
    /// - Parameter scrollView: Internal Scroll View
    public func addScrollView(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    // MARK: - Set Constraint
    private func setConstraint() {
        guard let parentView = superview else { return }
        topConstraint = self.topAnchor.constraint(equalTo: parentView.topAnchor)
        topConstraint?.constant = parentView.frame.height
        leftConstraint = self.leftAnchor.constraint(equalTo: parentView.leftAnchor)
        rightConstraint = self.rightAnchor.constraint(equalTo: parentView.rightAnchor)
        bottomConstraint = self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        
        let constraintsToActivate = [topConstraint,
                                     leftConstraint,
                                     rightConstraint,
                                     bottomConstraint
                                     ].compactMap { $0 }
        NSLayoutConstraint.activate(constraintsToActivate)
        parentView.layoutIfNeeded()
    }
    
    // MARK: - Gesture
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panning(_:)))
        pan.delegate = self
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
    }
    
}


// MARK: - Gesture
extension TWPullUpView {
    @objc private func panning(_ gesture: UIPanGestureRecognizer) {
        guard let parentView = superview else { return }
        let translationY = gesture.translation(in: self).y
        
        if scrollView?.contentOffset.y ?? 0 > scrollViewDefaultOffsetY {
            offsetCorrection = translationY
            checkScrollViewEnabled()
            return
        }
        
        switch gesture.state {
        case .began:
            panningStartPoint = currentPoint
        case .changed:
            if let point = panningStartPoint, (scrollView?.contentOffset.y ?? 0 <= scrollViewDefaultOffsetY) {
                var p = point - (offsetCorrection != nil ? (translationY - offsetCorrection!) : translationY)
                
                if (translationY < 0 && option.overMaxHeight ? true : p <= stickyPoints.last!.toHeight) &&
                    (translationY > 0 && option.underMinHeight ? true : p >= stickyPoints.first!.toHeight) {
                    
                    if option.overMaxHeight && currentPoint >= stickyPoints.last!.toHeight {
                        p = (p - stickyPoints.last!.toHeight) / 8 + stickyPoints.last!.toHeight
                    } else if option.underMinHeight && p <= stickyPoints.first!.toHeight {
                        p = (p - stickyPoints.first!.toHeight) / 8 + stickyPoints.first!.toHeight
                    }
                    
                    scrollView?.contentOffset.y = scrollViewDefaultOffsetY
                    topConstraint?.constant = parentView.frame.height - p
                    currentPoint = p
                    didChangePoint?(p)
                    
                    UIView.animate(withDuration: 0.05) {
                        parentView.layoutIfNeeded()
                    }
                } else {
                    offsetCorrection = nil
                    panningStartPoint = nil
                    moveToStickyPoint(index: closestStickyIndex())
                }
                
            } else {
                panningStartPoint = currentPoint
            }
        case .ended:
            scrollViewBounceCorrection = nil
            offsetCorrection = nil
            panningStartPoint = nil
            moveToStickyPoint(index: closestStickyIndex())
        default: break
        }
        
        checkScrollViewEnabled()
    }
    
    private func checkScrollViewEnabled() {
        guard let scrollView = scrollView else { return }
        if (stickyPoints.last!.toHeight - 2)...(stickyPoints.last!.toHeight + 2) ~= currentPoint  {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.contentOffset.y = 0
            scrollView.isScrollEnabled = false
        }
        
    }
}

//MARK: - Animation
extension TWPullUpView {
    
    /// Animate pull up view to custom point
    /// - Parameters:
    ///   - point: Custom point
    ///   - animate: Animate to that point
    public func animateView(to point: TWStickyPoint, animate: Bool = true) {
        guard let parentView = superview else { return }
        topConstraint?.constant = parentView.frame.height - point.toHeight
        currentPoint = point.toHeight
        willMoveToPoint?(currentPoint)

        UIView.animate(withDuration: animate ? option.animationDuration : 0,
                       delay: 0,
                       usingSpringWithDamping: option.animationDamping,
                       initialSpringVelocity: option.animationSpringVelocity,
                       options: [.curveEaseInOut]) {
            parentView.layoutIfNeeded()
        } completion: { _ in
            self.didMoveToPoint?(point.toHeight)
        }

    }
    
    
    /// Move to sticky point
    /// - Parameter index: Index of the sticky point you have seted
    public func moveToStickyPoint(index: Int) {
        if stickyPoints.count <= index {
            fatalError("Sticky point index out of range. Check 'stickyPoints' Array.")
        }
        animateView(to: stickyPoints[index])
    }
    
    private func closestStickyIndex(from point: TWStickyPoint? = nil) -> Int {
        let point = point == nil ? currentPoint : point!.toHeight
        return stickyPoints.map { $0.toHeight }.enumerated().min( by: { abs($0.1 - point) < abs($1.1 - point) } )!.offset
    }
}

//MARK: Options
extension TWPullUpView {
    
    
    /// Custom option for TWPullUpView - Use TWOptionProtocol
    /// - Parameter option: Custom option
    public func setOption(_ option: TWOptionProtocol) {
        self.option = option
    }
}
