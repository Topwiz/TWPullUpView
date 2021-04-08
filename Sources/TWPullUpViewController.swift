//
//  TWPullUpView.swift
//  TWPullUpView
//
//  Created by Jeehoon Son on 2021/03/29.
//

import Foundation
import UIKit

public enum TWStickyPoint {
    case min
    case percent(CGFloat)
    case custom(CGFloat)
    case max
    
    public var toHeight: CGFloat {
        switch self {
        case .min:
            return 0
        case .percent(let percent):
            return UIScreen.main.bounds.height * percent
        case .custom(let height):
            return height
        case .max:
            return UIScreen.main.bounds.height
        }
    }
}

open class TWPullUpViewController: UIViewController {
    /// Options
    open var option: TWPullUpOption {
        return TWPullUpOption()
    }
    
    private var initialStickyPoint: TWStickyPoint = .percent(0.3)
    
    private var _stickyPoints: [TWStickyPoint] = [.percent(0.3), .percent(0.6), .max]
    open var stickyPoints: [TWStickyPoint] {
        get {
            return _stickyPoints
        } set {
            self._stickyPoints = newValue.sorted(by: {  $0.toHeight < $1.toHeight })
            if _stickyPoints.count <= 1 {
                fatalError("You need to add more than 2 sticky points.")
            }
        }
    }
    
    public var isPullUpScrollEnabled: Bool = true
    
    public var willMoveToPoint: ((CGFloat) -> ())?
    public var didMoveToPoint: ((CGFloat) -> ())?
    public var didChangePoint: ((CGFloat) -> ())?
    public var percentOfMinToMax: ((CGFloat) -> ())?
    public var nearestStickyPointIndex: Int {
        return closestStickyIndex()
    }
    
    public var getMaxHeight: CGFloat {
        get { return _stickyPoints.last!.toHeight }
    }
    
    public var getMinHeight: CGFloat {
        get { return _stickyPoints.first!.toHeight }
    }
    
    /// Default is min value of sticky point
    open var startPercentFromPoint: TWStickyPoint {
        return  _stickyPoints.last!
    }
    
    private var currentPoint: CGFloat = 0 {
        didSet {
            let min = startPercentFromPoint.toHeight
            let max = _stickyPoints.last!.toHeight
            let percent = (currentPoint - min) / (max - min)
            percentOfMinToMax?(percent >= 0 ? percent : 0)
        }
    }
    
    public var getCurrentPoint: CGFloat {
        get { return currentPoint }
    }
    
    private weak var scrollView: UIScrollView?
    
    private weak var parentVC: UIViewController!
    
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
    public func addOn(_ viewController: UIViewController,
                      initialStickyPoint: TWStickyPoint,
                      animated: Bool,
                      completion: (()->())? = nil) {
        
        setup(superview: viewController, initialStickyPoint: initialStickyPoint, animate: animated)
    }
    
    
    /// Remove from super view
    /// - Parameters:
    ///   - animate: Animate to bottom and remove
    ///   - completion: Completion after remove from super view
    public func removeView(animate: Bool, completion: (()->())? = nil) {
        animateView(to: .min, animate: animate) { [weak self] in
            self?.willMove(toParent: nil)
            self?.view.removeFromSuperview()
            self?.removeFromParent()
            completion?()
        }
    }
}

extension TWPullUpViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - SetUp
extension TWPullUpViewController {
    // MARK: - SetUp
    private func setup(superview: UIViewController, initialStickyPoint: TWStickyPoint, animate: Bool) {
        parentVC = superview
        view.translatesAutoresizingMaskIntoConstraints = false
        self.initialStickyPoint = initialStickyPoint
        superview.addChild(self)
        superview.view.addSubview(self.view)
        setConstraint()
        setupPanGesture()
        animateView(to: initialStickyPoint, animate: animate)
    }
    
    
    /// Add scrollView for scroll connection
    /// - Parameter scrollView: Internal Scroll View
    public func attachScrollView(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    // MARK: - Set Constraint
    private func setConstraint() {
        topConstraint = view.topAnchor.constraint(equalTo: parentVC.view.topAnchor)
        topConstraint?.constant = parentVC.view.frame.height
        leftConstraint = view.leftAnchor.constraint(equalTo: parentVC.view.leftAnchor)
        rightConstraint = view.rightAnchor.constraint(equalTo: parentVC.view.rightAnchor)
        bottomConstraint = view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor)
        
        let constraintsToActivate = [topConstraint,
                                     leftConstraint,
                                     rightConstraint,
                                     bottomConstraint
                                     ].compactMap { $0 }
        NSLayoutConstraint.activate(constraintsToActivate)
        parentVC.didMove(toParent: self)
        parentVC.view.layoutIfNeeded()
    }
    
    // MARK: - Gesture
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panning(_:)))
        pan.delegate = self
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
    }
    
}


// MARK: - Gesture
extension TWPullUpViewController {
    @objc private func panning(_ gesture: UIPanGestureRecognizer) {
        if !isPullUpScrollEnabled { return }
        
        let translationY = gesture.translation(in: view).y
        let velocityY = gesture.velocity(in: view).y
        
        if scrollView?.contentOffset.y ?? 0 > scrollViewDefaultOffsetY {
            offsetCorrection = translationY
            checkScrollViewEnabled()
            return
        }
        
        switch gesture.state {
        case .began:
            offsetCorrection = nil
            panningStartPoint = currentPoint
        case .changed:
            if let point = panningStartPoint, (scrollView?.contentOffset.y ?? 0 <= scrollViewDefaultOffsetY) {
                var p = point - (offsetCorrection != nil ? (translationY - offsetCorrection!) : translationY)
                
                if (translationY < 0 && option.overMaxHeight ? (scrollView == nil ? true : p <= stickyPoints.last!.toHeight) : p <= stickyPoints.last!.toHeight) &&
                    (translationY > 0 && option.underMinHeight ? true : p >= stickyPoints.first!.toHeight) {
                    
                    if option.overMaxHeight && currentPoint >= stickyPoints.last!.toHeight {
                        p = (p - stickyPoints.last!.toHeight) / 8 + stickyPoints.last!.toHeight
                    } else if option.underMinHeight && p <= stickyPoints.first!.toHeight {
                        p = (p - stickyPoints.first!.toHeight) / 8 + stickyPoints.first!.toHeight
                    }
                    
                    scrollView?.contentOffset.y = scrollViewDefaultOffsetY
                    topConstraint?.constant = parentVC.view.frame.height - p
                    currentPoint = p
                    didChangePoint?(p)
                    
                    UIView.animate(withDuration: 0.05) {
                        self.parentVC.view.layoutIfNeeded()
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
            moveToStickyPoint(index: closestStickyIndex(velocity: velocityY))
        default: break
        }
        
        checkScrollViewEnabled()
    }
    
    private func checkScrollViewEnabled() {
        guard let scrollView = scrollView else { return }
        if (stickyPoints.last!.toHeight - 2)...(stickyPoints.last!.toHeight + 2) ~= currentPoint  {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.contentOffset.y = scrollViewDefaultOffsetY
            scrollView.isScrollEnabled = false
        }
        
    }
}

//MARK: - Animation
extension TWPullUpViewController {
    
    /// Animate pull up view to custom point
    /// - Parameters:
    ///   - point: Custom point
    ///   - animate: Animate to that point
    public func animateView(to point: TWStickyPoint, animate: Bool = true, completion: (()->())? = nil) {
        topConstraint?.constant = parentVC.view.frame.height - point.toHeight
        currentPoint = point.toHeight
        willMoveToPoint?(currentPoint)
        
        let duration = animate ? option.animationDuration : 0
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: option.animationDamping,
                       initialSpringVelocity: option.animationSpringVelocity,
                       options: [.curveEaseInOut]) {
            self.parentVC.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.didMoveToPoint?(point.toHeight)
            self?.checkScrollViewEnabled()
            completion?()
        }
        
        checkScrollViewEnabled()
    }
    
    
    /// Move to sticky point
    /// - Parameter index: Index of the sticky point you have seted
    public func moveToStickyPoint(index: Int) {
        if stickyPoints.count <= index {
            fatalError("Sticky point index out of range. Check 'stickyPoints' Array.")
        }
        animateView(to: stickyPoints[index])
    }
    
    private func closestStickyIndex(from point: TWStickyPoint? = nil, velocity: CGFloat? = nil) -> Int {
        let point = point == nil ? currentPoint : point!.toHeight
        var offset = stickyPoints.map { $0.toHeight }.enumerated().min( by: { abs($0.1 - point) < abs($1.1 - point) } )!.offset
        if let velocity = velocity {
            if velocity < -option.moveToNextPointVelocity && offset < stickyPoints.count - 1 { // scrolling up
                offset += 1
            } else if velocity > option.moveToNextPointVelocity && offset > 0 {
                offset -= 1
            }
        }
        return offset
    }
}
