//
//  AppDelegate.swift
//  Demo
//
//  Created by camel_yang on 1/30/18.
//  Copyright © 2018 camelcc. All rights reserved.
//

import UIKit

public protocol MenuPopOverViewDelegate: class {
    func didSelect(view: MenuPopOverView, at index: Int)
    func didDismiss(view: MenuPopOverView)
}

open class MenuPopOverView: UIView {
    // delegate
    public weak var delegate: MenuPopOverViewDelegate?

    // color configs
    open var background: UIColor = UIColor.black
    open var highlighted: UIColor = UIColor.lightGray
    open var selected: UIColor = UIColor.white
    open var divider: UIColor = UIColor.white
    open var border: UIColor = UIColor.clear
    open var text: UIColor = UIColor.white
    open var highlightedText: UIColor = UIColor.gray
    open var selectedText: UIColor = UIColor.black

    // geometry configs
    private let VIEW_PADDING: CGFloat = 20.0
    private let VIEW_HEIGHT: CGFloat = 44.0
    private let CORNER_RADIUS: CGFloat = 8.0
    private let BUTTON_HEIGHT: CGFloat = 53.5
    private let LEFT_BUTTON_WIDTH: CGFloat = 30.0
    private let RIGHT_BUTTON_WIDTH: CGFloat = 30.0
    private let ARROW_HEIGHT: CGFloat = 9.5
    private let TEXT_EDGE_INSETS: CGFloat = 10.0
    private let TEXT_FONT = UIFont.systemFont(ofSize: 14)

    private var buttonsContainer: UIView? = nil
    private var buttons = [UIButton]()
    private var pageButtons = [[UIButton]]()
    private var dividers = [CGRect]()

    private var isArrowUp = true
    private var arrowPoint = CGPoint.zero
    private var boxFrame = CGRect.zero
    private var pageIndex: Int = -1
    private var selectedIndex: Int = -1

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCode is not supported")
    }

    open func present(at location: CGRect, in superView: UIView, with titles: [String], select index: Int? = nil) {
        if titles.count < 0 {
            return;
        }

        // create buttons form titles
        self.buttons = titles.map { (title) -> UIButton in
            let textButton = createButton(title, clickAction: #selector(onButtonClick(_:)))
            textButton.isSelected = self.buttons.count == self.selectedIndex
            textButton.backgroundColor = textButton.isSelected ? selected : background
            return textButton
        }

        // perform early layout to determine the bounds
        superView.layoutIfNeeded()
        if superView.bounds.width < 2 * VIEW_PADDING + LEFT_BUTTON_WIDTH + RIGHT_BUTTON_WIDTH ||
                   superView.bounds.height < BUTTON_HEIGHT {
            print("view is too small to display popover")
            return
        }

        self.dividers = [CGRect]()
        self.buttonsContainer?.removeFromSuperview()
        self.pageIndex = 0

        let container = UIView(frame: CGRect.zero)
        container.backgroundColor = UIColor.clear
        container.clipsToBounds = true
        self.buttonsContainer = container
        self.add(self.buttons, into: container, with: superView.bounds)
        self.layout(container: container, at: location, with: superView.bounds)

        self.addSubview(container)
        superView.addSubview(self)
        self.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true

        self.layoutIfNeeded()
        self.setNeedsDisplay()

        //Add a tap gesture recognizer to the large invisible view (self), which will detect taps anywhere on the screen.
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapHandler.cancelsTouchesInView = false // Allow touches through to a UITableView or other touchable view, as suggested by Dimajp.
        self.addGestureRecognizer(tapHandler)
        self.isUserInteractionEnabled = true

        // Make the view small and transparent before animation
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        // animate into full size
        // First stage animates to 1.05x normal size, then second stage animates back down to 1x size.
        // This two-stage animation creates a little "pop" on open.
        UIView.animate(withDuration: TimeInterval(0.2),
                delay: TimeInterval(0),
                options: .curveEaseInOut,
                animations: {
                    self.alpha = 1
                    self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                },
                completion: { _ in
                    UIView.animate(withDuration: TimeInterval(0.08),
                            delay: TimeInterval(0),
                            options: .curveEaseInOut,
                            animations: {
                                self.transform = CGAffineTransform.identity
                            },
                            completion: nil)
                })
    }

    open override func draw(_ rect: CGRect) {
        // Build the popover path
        let frame = self.boxFrame

        /*
           LT2            RT1
         LT1⌜⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⌝RT2
         |                    |
         |         popover    |
         |                    |
         LB2⌞_______________⌟RB1
            LB1           RB2

         Traverse rectangle in clockwise order, starting at LB2
         L = Left
         R = Right
         T = Top
         B = Bottom
         1,2 = order of traversal for any given corner
         */

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let bubblePath = CGMutablePath()

        // Move to LB2
        bubblePath.move(to: CGPoint(x: frame.minX, y: frame.maxY - CORNER_RADIUS))
        // Move to LT2
        bubblePath.addArc(tangent1End: CGPoint(x: frame.minX, y: frame.minY),
                tangent2End: CGPoint(x: frame.minX + CORNER_RADIUS, y: frame.minY),
                radius: CORNER_RADIUS)

        //If the popover is positioned below (!above) the arrowPoint, then we know that the arrow must be on the top of the popover.
        //In this case, the arrow is located between LT2 and RT1
        if (self.isArrowUp) {
            // Move to left point of Arrow and draw Arrow
            bubblePath.addLine(to: CGPoint(x: self.arrowPoint.x - ARROW_HEIGHT, y: frame.minY))
            bubblePath.addLine(to: CGPoint(x: self.arrowPoint.x, y: self.arrowPoint.y))
            bubblePath.addLine(to: CGPoint(x: self.arrowPoint.x + ARROW_HEIGHT, y: frame.minY))
        }

        // Move to RT2
        bubblePath.addArc(tangent1End: CGPoint(x: frame.maxX, y: frame.minY),
                tangent2End: CGPoint(x: frame.maxX, y: frame.minY + CORNER_RADIUS),
                radius: CORNER_RADIUS)
        // Move to RB2
        bubblePath.addArc(tangent1End: CGPoint(x: frame.maxX, y: frame.maxY),
                tangent2End: CGPoint(x: frame.maxX - CORNER_RADIUS, y: frame.maxY),
                radius: CORNER_RADIUS)

        if (!self.isArrowUp) {
            //Move to right point of Arrow and draw Arrow
            bubblePath.addLine(to: CGPoint(x: self.arrowPoint.x + ARROW_HEIGHT, y: frame.maxY))
            bubblePath.addLine(to: CGPoint(x: self.arrowPoint.x, y: self.arrowPoint.y))
            bubblePath.addLine(to: CGPoint(x: self.arrowPoint.x - ARROW_HEIGHT, y: frame.maxY))
        }

        // Move to LB2
        bubblePath.addArc(tangent1End: CGPoint(x: frame.minX, y: frame.maxY),
                tangent2End: CGPoint(x: frame.minX, y: frame.maxY - CORNER_RADIUS),
                radius: CORNER_RADIUS)
        bubblePath.closeSubpath()

        context.saveGState()
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds;
        maskLayer.path = bubblePath;
        self.layer.mask = maskLayer;
        context.restoreGState()

        //Draw the divider rects if we need to
        if (self.dividers.count > 0) {
            for var divider in self.dividers {
                divider.origin.x += self.buttonsContainer?.frame.origin.x ?? 0
                divider.origin.y += self.buttonsContainer?.frame.origin.y ?? 0

                let dividerPath = UIBezierPath(rect: divider)
                self.divider.setFill()
                dividerPath.fill()
            }
        }


        // Add border if border is set
        if (self.border != UIColor.clear) {
            let layer = CAShapeLayer()
            layer.frame = self.bounds
            layer.path = bubblePath
            layer.fillColor = nil
            layer.lineWidth = 2
            layer.strokeColor = self.border.cgColor
            self.layer.addSublayer(layer)
        }
    }

    open func dismiss(_ animated: Bool) {
        let completion: (Bool) -> Void = { completed in
            self.removeFromSuperview()
            self.delegate?.didDismiss(view: self)
        }

        if animated {
            UIView.animate(withDuration: TimeInterval(0.3), delay: TimeInterval(0.15), options: [], animations: {
                self.alpha = 0.1
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: completion)
        } else {
            completion(true)
        }
    }

    private func createButton(_ title: String, clickAction: Selector) -> UIButton {
        let textSize = (title as NSString).size(withAttributes: [.font : TEXT_FONT])
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: round(textSize.width + 2 * TEXT_EDGE_INSETS), height: BUTTON_HEIGHT))
        button.isEnabled = false
        button.backgroundColor = self.background
        button.titleLabel?.font = TEXT_FONT
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(self.text, for: .normal)
        button.setTitleColor(self.highlightedText, for: .highlighted)
        button.setTitleColor(self.selectedText, for: .selected)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: clickAction, for: .touchUpInside)
        button.addTarget(self, action: #selector(setHighlightBackground(_:)), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(resetBackground(_:)), for: [.touchUpOutside, .touchDragExit, .touchCancel])
        return button
    }
}

// MARK: layout
extension MenuPopOverView {
    private func add(_ buttons: [UIButton], into containerView: UIView, with superViewBounds: CGRect) {
        // preparing
        containerView.frame = CGRect.zero
        let maxWidth = superViewBounds.size.width - 2 * VIEW_PADDING

        // layout looks like:
        // [ 0 ] | [ 1 ] | ... | > < | [ 2 ] | ... | > < | [ 3 ] ... [ 4 ]
        // figure out which page each button belong to.
        var tmpPagedButtons = [[UIButton]]()
        var currentPageButtons = [UIButton]()
        var currentX: CGFloat = 0
        for button in buttons {
            let w = currentX + button.frame.size.width
            if w > (button == buttons.last ? maxWidth : maxWidth - RIGHT_BUTTON_WIDTH - 1) {
                if currentPageButtons.isEmpty {
                    tmpPagedButtons.append([UIButton](repeating: button, count: 1))
                    currentX = 0
                } else {
                    tmpPagedButtons.append(currentPageButtons)
                    currentPageButtons = [UIButton]()
                    currentX = LEFT_BUTTON_WIDTH + 1
                    currentPageButtons.append(button)
                }
            } else {
                currentPageButtons.append(button)
                currentX += button.frame.size.width
                if button != buttons.last {
                    currentX += 1 // 1 point divider
                }
            }
        }
        if !currentPageButtons.isEmpty {
            tmpPagedButtons.append(currentPageButtons)
        }

        self.pageButtons = [[UIButton]]()
        currentPageButtons = [UIButton]()
        currentX = 0
        self.dividers.removeAll()
        for b in tmpPagedButtons {
            let isFirstPage = b == tmpPagedButtons.first ?? [UIButton]()
            let isLastPage = b == tmpPagedButtons.last ?? [UIButton]()

            // add leftArrow
            if !isFirstPage {
                let leftArrowButton = createButton("◀", clickAction: #selector(onLeftArrowClick(_:)))
                leftArrowButton.frame = CGRect(x: currentX, y: 0, width: LEFT_BUTTON_WIDTH, height: BUTTON_HEIGHT)
                currentPageButtons.append(leftArrowButton)
                currentX += LEFT_BUTTON_WIDTH;

                // add div between leftArrow - nextPageBtns
                let div = CGRect(x: currentX, y: 0, width: 1, height: BUTTON_HEIGHT)
                self.dividers.append(div)
                currentX += 1;
            }

            var w = maxWidth
            if !isFirstPage {
                w -= (LEFT_BUTTON_WIDTH + 1)
            }
            if !isLastPage {
                w -= (RIGHT_BUTTON_WIDTH + 1)
            }
            currentX = self.adjustFrames(with: b, into: w, from: currentX)
            currentPageButtons.append(contentsOf: b)

            // add right arrow
            if !isLastPage {
                let div = CGRect(x: currentX, y: 0, width: 1, height: BUTTON_HEIGHT)
                self.dividers.append(div)
                currentX += 1;
                // add rightArrowBtn
                let rightArrowButton = createButton("▶", clickAction: #selector(onRightArrowClick(_:)))
                rightArrowButton.frame = CGRect(x: currentX, y: 0, width: RIGHT_BUTTON_WIDTH, height: BUTTON_HEIGHT)
                currentPageButtons.append(rightArrowButton)
                currentX += RIGHT_BUTTON_WIDTH
            }

            self.pageButtons.append(currentPageButtons)
            currentPageButtons = [UIButton]()
        }

        for page in self.pageButtons {
            for btn in page {
                containerView.addSubview(btn)
            }
        }
        self.pageButtons.first?.forEach { $0.isEnabled = true } // enable first page buttons by default
        containerView.frame = CGRect(x: 0, y: 0, width: currentX, height: BUTTON_HEIGHT)
    }

    private func adjustFrames(with buttons: [UIButton], into totalWidth: CGFloat, from x: CGFloat) -> CGFloat {
        if buttons.count == 0 {
            return x
        }

        if buttons.count == 1 {
            guard let button = buttons.first else {
                return x + totalWidth
            }

            var buttonFrame = button.frame
            buttonFrame.origin.x = x
            buttonFrame.size.width = totalWidth
            button.frame = buttonFrame
            return x + totalWidth;
        }

        // get increment width for each button
        var buttonsWidth: CGFloat = CGFloat(buttons.count - 1) // 1 pixel dividers
        for button in buttons {
            buttonsWidth += button.frame.size.width
        }
        let incrementWidth = round(totalWidth - buttonsWidth)/CGFloat(buttons.count)

        // adjust frame
        var currentX = x;
        for button in buttons {
            var buttonFrame = button.frame
            buttonFrame.origin.x = currentX
            buttonFrame.size.width += incrementWidth
            button.frame = buttonFrame
            currentX += buttonFrame.size.width

            if button != buttons.last {
                let div = CGRect(x: currentX, y: buttonFrame.origin.y, width: 1, height: buttonFrame.size.height)
                self.dividers.append(div)
                currentX += 1
            }
        }

        return x + totalWidth;
    }

    private func layout(container view: UIView, at location: CGRect, with superViewBounds: CGRect) {
        let popoverMaxWidth = superViewBounds.width - 2 * VIEW_PADDING

        // determine the arrow position
        // 1 pixel gap
        if location.minY - 1 - BUTTON_HEIGHT > 0 {
            self.isArrowUp = false
            self.arrowPoint = CGPoint(x: location.midX, y: location.minY - 1)
        } else {
            self.isArrowUp = true
            self.arrowPoint = CGPoint(x: location.midX, y: location.maxY + 1)
        }

        let containerWidth = view.frame.size.width
        var xOrigin: CGFloat = 0

        //Make sure the arrow point is within the drawable bounds for the popover.
        if (self.arrowPoint.x + ARROW_HEIGHT > superViewBounds.width - VIEW_PADDING - CORNER_RADIUS) { // too right
            self.arrowPoint.x = superViewBounds.width - VIEW_PADDING - CORNER_RADIUS - ARROW_HEIGHT
        } else if (self.arrowPoint.x - ARROW_HEIGHT < VIEW_PADDING + CORNER_RADIUS) { // too left
            self.arrowPoint.x = VIEW_PADDING + CORNER_RADIUS + ARROW_HEIGHT
        }

        xOrigin = floor(self.arrowPoint.x - containerWidth * 0.5)
        //Check to see if the centered xOrigin value puts the box outside of the normal range.
        if (xOrigin < VIEW_PADDING) {
            xOrigin = VIEW_PADDING
        } else if (xOrigin + containerWidth > superViewBounds.width - VIEW_PADDING) {
            //Check to see if the positioning puts the box out of the window towards the left
            xOrigin = superViewBounds.width - VIEW_PADDING - containerWidth
        }

        var containerFrame = CGRect.zero
        if (self.isArrowUp) {
            self.boxFrame = CGRect(x: xOrigin, y: self.arrowPoint.y + ARROW_HEIGHT, width: min(containerWidth, popoverMaxWidth), height: VIEW_HEIGHT - ARROW_HEIGHT)
            containerFrame = CGRect(x: xOrigin, y: self.arrowPoint.y, width: containerWidth, height: BUTTON_HEIGHT)
        } else {
            self.boxFrame = CGRect(x: xOrigin, y: self.arrowPoint.y - VIEW_HEIGHT, width: min(containerWidth, popoverMaxWidth), height: VIEW_HEIGHT - ARROW_HEIGHT)
            containerFrame = CGRect(x: xOrigin, y: self.arrowPoint.y - BUTTON_HEIGHT, width: containerWidth, height: BUTTON_HEIGHT)
        }

        view.frame = containerFrame

        //We set the anchorPoint here so the popover will "grow" out of the arrowPoint specified by the user.
        //You have to set the anchorPoint before setting the frame, because the anchorPoint property will
        //implicitly set the frame for the view, which we do not want.
        self.layer.anchorPoint = CGPoint(x: self.arrowPoint.x / superViewBounds.width, y: self.arrowPoint.y / superViewBounds.height)
        self.frame = superViewBounds;
    }
}

// MARK: button
extension MenuPopOverView {
    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: self.buttonsContainer)
        var containerVisibleBounds = CGRect.zero
        containerVisibleBounds.origin.x = self.boxFrame.origin.x - (self.buttonsContainer?.frame.origin.x ?? 0)
        containerVisibleBounds.size.width = self.boxFrame.size.width
        containerVisibleBounds.size.height = self.buttonsContainer?.frame.size.height ?? 0
        if (containerVisibleBounds.contains(tapPoint)) {
            for buttons in self.pageButtons {
                for view in buttons {
                    if view.frame.contains(tapPoint) {
                        return // have response
                    }
                }

            }
        }

        self.dismiss(true)
    }

    @objc private func onButtonClick(_ sender: UIButton) {
        for button in self.buttons {
            button.isSelected = false
            button.backgroundColor = self.background
        }
        sender.isSelected = true
        sender.backgroundColor = selected

        self.delegate?.didSelect(view: self, at: self.buttons.index(of: sender) ?? -1)
        self.dismiss(true)
    }

    @objc private func onLeftArrowClick(_ sender: UIButton) {
        sender.backgroundColor = self.background;
        self.moveContainer(toRight: false)
    }

    @objc private func onRightArrowClick(_ sender: UIButton) {
        sender.backgroundColor = self.background;
        self.moveContainer(toRight: true)
    }

    private func moveContainer(toRight right: Bool) {
        // disable current buttons, enable next page buttons
        self.pageButtons[self.pageIndex].forEach { $0.isEnabled = false }
        if right {
            self.pageIndex += 1
        } else {
            self.pageIndex -= 1
        }
        self.pageButtons[self.pageIndex].forEach { $0.isEnabled = true }

        let containerWidth = self.bounds.width - 2 * VIEW_PADDING
        UIView.animate(withDuration: TimeInterval(0.25)) {
            if right {
                self.buttonsContainer?.frame.origin.x -= containerWidth
            } else {
                self.buttonsContainer?.frame.origin.x += containerWidth
            }

        }
        self.setNeedsDisplay()
    }

    @objc private func setHighlightBackground(_ sender: UIButton) {
        sender.backgroundColor = highlighted
    }

    @objc private func resetBackground(_ sender: UIButton) {
        let index = self.buttons.index(of: sender)
        sender.backgroundColor = index == self.selectedIndex ? selected : background
    }
}
