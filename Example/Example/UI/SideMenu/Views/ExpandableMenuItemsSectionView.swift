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

class ExpandableMenuItemsSectionView: BaseView
{
    var itemsLeading: CGFloat = 68
    { didSet { if let constraint = itemsLeadingConstraint { constraint.constant = itemsLeading } } }
    
    private var titleContainer: UIView =
    {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        return view
    }()
    
    private var itemsContainer: UIView =
    {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        return view
    }()

    private var itemsStack = UIStackView(frame: .zero)
    
    private var expanded: Bool = false
    private var headerTapHandler: (() -> Void)?
    
    private var itemsContainerHeightConstraint: NSLayoutConstraint!
    private var itemsLeadingConstraint: NSLayoutConstraint!
    
    func setup(withTitleView titleView: View, items: [View])
    {
        titleContainer.subviews.removeAllFromSuperview()
        itemsStack.arrangedSubviews.removeAllFromSuperview()
        
        titleContainer.addSubview(titleView.view)
        titleView.view.pinToSuperview()
        headerTapHandler = titleView.tapHandler
        
        titleContainer.addTapHandler
        { [weak self] in guard let self = self else { return }
            
            if self.itemsStack.arrangedSubviews.count == 0 { self.headerTapHandler?() }
            else { self.toggleExpanded() }
        }
        
        titleContainer.isUserInteractionEnabled = true
        
        for item in items
        {
            itemsStack.addArrangedSubview(item.view)
            if let tapHandler = item.tapHandler { item.view.addTapHandler(action: tapHandler) }
        }
        
        update(animated: false)
    }
    
    func toggleExpanded(animated: Bool = true)
    {
        setExpanded(!expanded, animated: animated)
    }
    
    func expand(animated: Bool = true)
    {
        setExpanded(true, animated: animated)
    }
    
    func collapse(animated: Bool = true)
    {
        setExpanded(false, animated: animated)
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool = true)
    {
        guard self.expanded != expanded else { return }
        
        self.expanded = expanded
        update(animated: animated)
    }
    
    func update(animated: Bool = true)
    {
        itemsContainerHeightConstraint.priority = expanded ? .defaultLowest : .defaultHighest

        guard superview != nil else { return }
        
        guard animated else
        {
            layoutIfNeeded()
            superview?.layoutIfNeeded()
            superview?.superview?.layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.3, delay: expanded ? 0 : 0.1, options: expanded ? .curveEaseOut : .curveEaseIn)
        {
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
            self.superview?.superview?.layoutIfNeeded()
        }
        
        // Appear animation
        if expanded
        {
            for (idx, view) in itemsStack.arrangedSubviews.reversed().enumerated()
            {
                applyIndividualAppearAnimation(to: view, delay: TimeInterval(idx) * 0.04)
            }
        }
        // Disappear animation
        else
        {
            for (idx, view) in itemsStack.arrangedSubviews.enumerated()
            {
                applyIndividualDisappearAnimation(to: view, delay: TimeInterval(idx) * 0.04)
            }
        }
    }
    
    func applyIndividualAppearAnimation(to view: UIView, delay: TimeInterval = 0)
    {
        view.transform = CGAffineTransform(translationX: 0, y: -50)
        view.alpha = 0

        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut)
        {
            view.transform = .identity
        }
        
        UIView.animate(withDuration: 0.4, delay: delay + 0.06, options: .curveEaseOut)
        {
            view.alpha = 1
        }
    }
    
    func applyIndividualDisappearAnimation(to view: UIView, delay: TimeInterval = 0)
    {
        UIView.animate(withDuration: 0.4, delay: delay, options: .curveEaseOut)
        {
            view.transform = CGAffineTransform(translationX: 0, y: -50)
        }
        
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut)
        {
            view.alpha = 0
        }
    }
    
    override func commonInit()
    {
        backgroundColor = .clear
        
        addSubview(titleContainer)
        addSubview(itemsContainer)
        itemsContainer.addSubview(itemsStack)
        
        itemsContainer.clipsToBounds = true
        
        itemsStack.axis = .vertical
        itemsStack.distribution = .fillProportionally
        itemsStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        itemsContainer.translatesAutoresizingMaskIntoConstraints = false
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let itemsStackTopConstraint = itemsStack.topAnchor.constraint(equalTo: itemsContainer.topAnchor, constant: 0)
        itemsStackTopConstraint.priority = .defaultLow
        
        itemsContainerHeightConstraint = itemsContainer.heightAnchor.constraint(equalToConstant: 0)
        itemsContainerHeightConstraint.priority = .defaultLowest
        
        itemsLeadingConstraint = itemsStack.leadingAnchor.constraint(equalTo: itemsContainer.leadingAnchor,
                                                                     constant: itemsLeading)
        
        NSLayoutConstraint.activate(
        [
            titleContainer.topAnchor.constraint(equalTo: topAnchor),
            titleContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            itemsContainerHeightConstraint,
            itemsContainer.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            
            itemsContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            itemsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            itemsStackTopConstraint,
            itemsLeadingConstraint,
            itemsStack.trailingAnchor.constraint(equalTo: itemsContainer.trailingAnchor, constant: 0),
            itemsStack.bottomAnchor.constraint(equalTo: itemsContainer.bottomAnchor, constant: -1)
        ])
    }

    struct View
    {
        let view: UIView
        let tapHandler: (() -> Void)?
        
        init(view: UIView, tapHandler: (() -> Void)? = nil)
        {
            self.view = view
            self.tapHandler = tapHandler
        }
    }
}
