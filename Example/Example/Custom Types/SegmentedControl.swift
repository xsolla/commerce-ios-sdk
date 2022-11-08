// Copyright 2021-present Xsolla (USA), Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at q
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing and permissions and

import UIKit

public protocol SegmentedControlDelegate: AnyObject
{
    func shouldSelectItem(at index: Int, in segmentedControl: SegmentedControl) -> Bool
    func didSelectItem(at index: Int, in segmentedControl: SegmentedControl)
}

extension SegmentedControlDelegate
{
    func shouldSelectItem(at index: Int, in segmentedControl: SegmentedControl) -> Bool
    {
        true
    }
}

public class SegmentedControl: UIView
{
    // MARK: - Public interface

    // Title style
    public var titleFont: UIFont? { didSet { updateItemTitleStyles() } }
    public var selectedTitleColor: UIColor = .black { didSet { updateItemTitleStyles() } }
    public var normalTitleColor: UIColor = .gray { didSet { updateItemTitleStyles() } }

    // Selector
    public var selectorColor: UIColor = .black { didSet { selectorView.backgroundColor = selectorColor } }
    public var selectorHeight: CGFloat = 2 { didSet { selectorViewHeight.constant = max(selectorHeight, 1) } }
    public var selectorBottom: CGFloat = 0 { didSet { selectorViewBottom.constant = -max(selectorBottom, 0) } }

    // Divider
    public var dividerColor: UIColor = .black { didSet { dividerView.backgroundColor = dividerColor } }
    public var dividerHeight: CGFloat = 1 { didSet { dividerViewHeight.constant = max(dividerHeight, 1) } }

    public weak var delegate: SegmentedControlDelegate?

    public func setSelectedItem(at index: Int, animated: Bool = true)
    {
        _setSelectedItem(at: index, animated: animated, informDelegate: false)
    }

    public func setup(withTitles titles: [String])
    {
        _setup(withTitles: titles)
    }

    public func removeAllItems()
    {
        invalidate()
    }

    // MARK: - Private views

    private let scrollView = UIScrollView(frame: .zero)
    private let stackView = UIStackView(frame: .zero)
    private let selectorView = UIView(frame: .zero)
    private let dividerView = UIView(frame: .zero)
    private let buttons = [UIView]()

    // MARK: - Private properties

    private var selectedItemIndex: Int = 0
    private var lastSelectedItemIndex: Int?

    private var selectorViewLeading = NSLayoutConstraint()
    private var selectorViewTrailing = NSLayoutConstraint()
    private var selectorViewHeight = NSLayoutConstraint()
    private var selectorViewBottom = NSLayoutConstraint()
    private var dividerViewHeight = NSLayoutConstraint()

    // MARK: - Setup

    private func setupViews()
    {
        layoutMargins = .zero

        setupDividerView()
        setupScrollView()
        setupStackView()
        setupSelectorView()
    }

    private func setupScrollView()
    {
        addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        scrollView.addGestureRecognizer(tapGesture)

        // Constraints

        scrollView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    }

    private func setupStackView()
    {
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true

        stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
        stackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true

        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
    }

    private func setupSelectorView()
    {
        scrollView.addSubview(selectorView)
        selectorView.isHidden = true
        selectorView.backgroundColor = selectorColor
        selectorView.translatesAutoresizingMaskIntoConstraints = false

        selectorViewBottom = selectorView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor,
                                                                  constant: -selectorBottom)
        selectorViewBottom.isActive = true

        selectorViewHeight = selectorView.heightAnchor.constraint(equalToConstant: selectorHeight)
        selectorViewHeight.isActive = true
    }

    private func setupDividerView()
    {
        addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = dividerColor

        dividerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true

        dividerViewHeight = dividerView.heightAnchor.constraint(equalToConstant: dividerHeight)
        dividerViewHeight.isActive = true
    }

    // MARK: - Updates

    private func updateItemTitleStyles()
    {
        for case let label as UILabel in stackView.arrangedSubviews
        {
            label.textColor = normalTitleColor
            label.font = titleFont
        }

        if !stackView.arrangedSubviews.isEmpty
        {
            (stackView.arrangedSubviews[selectedItemIndex] as? UILabel)?.textColor = selectedTitleColor
        }
    }

    @objc private func handleTap(sender: UITapGestureRecognizer)
    {
        guard sender.state == .ended, let index = itemIndex(for: sender.location(in: scrollView)) else { return }

        if delegate?.shouldSelectItem(at: index, in: self) == true
        {
            _setSelectedItem(at: index, animated: true, informDelegate: true)
        }
    }

    private func itemIndex(for location: CGPoint) -> Int?
    {
        for (idx, itemView) in stackView.arrangedSubviews.enumerated()
        {
            if itemView.frame.contains(location) { return idx }
        }

        return nil
    }

    // MARK: - Item selection

    private func _setSelectedItem(at index: Int, animated: Bool, informDelegate: Bool)
    {
        if informDelegate { delegate?.didSelectItem(at: index, in: self) }

        lastSelectedItemIndex = selectedItemIndex
        selectedItemIndex = index

        deselect(at: lastSelectedItemIndex!, animated: animated)
        select(at: selectedItemIndex, animated: animated)
    }

    private func _setup(withTitles titles: [String])
    {
        invalidate()

        for title in titles
        {
            let label = PaddingLabel(frame: .zero)

            label.text = title
            label.paddingInsets = .init(top: 4, left: 20, bottom: 4, right: 20)
            label.textAlignment = .center

            stackView.addArrangedSubview(label)
        }

        updateItemTitleStyles()

        selectorView.isHidden = false
        _setSelectedItem(at: 0, animated: false, informDelegate: false)
    }

    private func invalidate()
    {
        for view in stackView.arrangedSubviews { view.removeFromSuperview() }

        selectedItemIndex = 0
        lastSelectedItemIndex = nil
        selectorView.isHidden = true
    }

    private func select(at index: Int, animated: Bool = true)
    {
        if stackView.arrangedSubviews.isEmpty { return }

        guard let label = stackView.arrangedSubviews[index] as? UILabel else { return }

        var offset = scrollView.frame.width/2 - label.center.x
        offset = min(offset, 0)
        offset = max(offset, scrollView.frame.width - scrollView.contentSize.width)

        let contentOffset = CGPoint(x: -offset,
                                    y: scrollView.contentOffset.y)

        self.selectorViewLeading.isActive = false
        self.selectorViewTrailing.isActive = false

        self.selectorViewLeading = self.selectorView.leadingAnchor.constraint(equalTo: label.leadingAnchor)
        self.selectorViewTrailing = self.selectorView.trailingAnchor.constraint(equalTo: label.trailingAnchor)

        self.selectorViewLeading.isActive = true
        self.selectorViewTrailing.isActive = true

        if animated
        {
            animate(view: label) { label.textColor = self.selectedTitleColor }
            UIView.animate(withDuration: 0.25)
            {
                self.scrollView.contentOffset = contentOffset
                self.layoutIfNeeded()
            }

        }
        else
        {
            label.textColor = self.selectedTitleColor
            self.scrollView.contentOffset = contentOffset
            self.layoutIfNeeded()
        }
    }

    private func deselect(at index: Int, animated: Bool = true)
    {
        if stackView.arrangedSubviews.isEmpty { return }

        guard let label = stackView.arrangedSubviews[index] as? UILabel else { return }

        let animations =
        {
            label.textColor = self.normalTitleColor
        }

        if animated { animate(view: label, withAnimations: animations) }
        else        { animations() }
    }

    private func animate(view: UIView, withAnimations animations: @escaping () -> Void)
    {
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: animations)
    }

    // MARK: - Initialization

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit()
    {
        setupViews()
    }
}

private class PaddingLabel: UILabel
{
    var paddingInsets = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 7) { didSet { setNeedsDisplay() } }

    override func drawText(in rect: CGRect)
    {
        super.drawText(in: rect.inset(by: paddingInsets))
    }

    override var intrinsicContentSize: CGSize
    {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + paddingInsets.left + paddingInsets.right,
                      height: size.height + paddingInsets.top + paddingInsets.bottom)
    }

    override var bounds: CGRect
    {
        didSet
        {
            preferredMaxLayoutWidth = bounds.width - (paddingInsets.left + paddingInsets.right)
        }
    }
}
