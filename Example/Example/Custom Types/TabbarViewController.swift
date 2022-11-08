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

protocol TabbarViewControllerDelegate: AnyObject
{
    func tabBarController(_ tabbarViewController: TabbarViewController, shouldSelect: UIViewController) -> Bool
    func tabBarController(_ tabbarViewController: TabbarViewController, didSelect: UIViewController)
}

class TabbarViewController: BaseViewController
{
    weak var delegate: TabbarViewControllerDelegate?
    
    private let tabbar = SegmentedControl(frame: .zero)
    private let container = UIScrollView(frame: .zero)
    private let stack = UIStackView(frame: .zero)
 
    private var tabBarHeightConstraint = NSLayoutConstraint()
    private var tabBarLeadingConstraint = NSLayoutConstraint()
    private var tabBarTrailingConstraint = NSLayoutConstraint()
    private var containerLeadingConstraint = NSLayoutConstraint()
    private var containerTrailingConstraint = NSLayoutConstraint()
    private var containerTopConstraint = NSLayoutConstraint()
    
    private var items: [Item] = []
    private var currentSelectedIndex: Int = 0
    private var interactivePageSelectionEnabled = true
    
    var tabBarHeight: CGFloat = 60 { didSet { updateConstraints() } }
    var tabBarLeading: CGFloat = 0 { didSet { updateConstraints() } }
    var tabBarTrailing: CGFloat = 0 { didSet { updateConstraints() } }
    var containerTop: CGFloat = 0 { didSet { updateConstraints() } }
    var containerLeading: CGFloat = 0 { didSet { updateConstraints() } }
    var containerTrailing: CGFloat = 0 { didSet { updateConstraints() } }
    
    // MARK: - Public methods

    func applyThemingScheme(_ scheme: TabbarScheme)
    {
        tabbar.titleFont = scheme.titleFont
        tabbar.selectedTitleColor = scheme.selectedTitleColor
        tabbar.normalTitleColor = scheme.normalTitleColor
        tabbar.selectorColor = scheme.selectorColor
        tabbar.selectorHeight = scheme.selectorHeight
        tabbar.selectorBottom = scheme.selectorBottom
        tabbar.dividerColor = scheme.dividerColor
        tabbar.dividerHeight = scheme.dividerHeight
    }

    func setup(with items: [Item])
    {
        invalidateItems()
        
        tabbar.setup(withTitles: items.map { $0.title })
        for item in items
        {
            add(childViewController: item.viewController)
        }
        
        self.items = items
        
        setSelectedItem(at: 0, animated: false, updateOffset: true)
    }
    
    func setSelectedItem(at itemIndex: Int, animated: Bool = true, updateOffset: Bool = true)
    {
        if items.count == 0 { return }
    
        let index = (0..<items.count).contains(itemIndex) ? itemIndex : 0
        
        currentSelectedIndex = index
        tabbar.setSelectedItem(at: itemIndex, animated: animated)
        
        if updateOffset
        {
            if animated { interactivePageSelectionEnabled = false }
            scrollContent(to: index, animated: animated)
        }
    }
    
    // MARK: - Private methods
    
    private func invalidateItems()
    {
        items.forEach { self.remove(childViewController: $0.viewController) }
        tabbar.removeAllItems()
        items = []
        currentSelectedIndex = 0
    }
    
    private func add(childViewController viewController: UIViewController)
    {
        addChild(viewController)
        stack.addArrangedSubview(viewController.view)
        viewController.view.widthAnchor.constraint(equalTo: container.frameLayoutGuide.widthAnchor).isActive = true
        viewController.didMove(toParent: self)
    }
    
    private func remove(childViewController viewController: UIViewController)
    {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    private func scrollContent(to index: Int, animated: Bool = true)
    {
        let index = (0..<items.count).contains(index) ? index : 0
        
        let offset: CGFloat = CGFloat(index) * container.bounds.width
        
        container.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
    }
    
    private func getIndex(for offset: CGFloat) -> Int
    {
        let width = container.frame.width
        let index = Int(round(container.contentOffset.x / width))
        
        return index
    }
    
    private func updateConstraints()
    {
        tabBarHeightConstraint.constant = tabBarHeight
        tabBarLeadingConstraint.constant = tabBarLeading
        tabBarTrailingConstraint.constant = -tabBarTrailing
        containerTopConstraint.constant = containerTop
        containerLeadingConstraint.constant = containerLeading
        containerTrailingConstraint.constant = -containerTrailing
    }
    
    // MARK: - Setup
    
    private func setupTabbar()
    {
        view.addSubview(tabbar)
        tabbar.translatesAutoresizingMaskIntoConstraints = false
        tabbar.delegate = self
    }

    private func setupContainer()
    {
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isPagingEnabled = true
        container.showsVerticalScrollIndicator = false
        container.showsHorizontalScrollIndicator = false
        container.delegate = self
        container.backgroundColor = .xsolla_nightBlue
        container.bounces = false
    }
    
    private func setupStack()
    {
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints()
    {
        tabBarHeightConstraint = tabbar.heightAnchor.constraint(equalToConstant: tabBarHeight)
        tabBarLeadingConstraint = tabbar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        tabBarTrailingConstraint = tabbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        containerTopConstraint = container.topAnchor.constraint(equalTo: tabbar.bottomAnchor, constant: containerTop)
        
        containerLeadingConstraint = container.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        containerTrailingConstraint = container.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate(
        [
            tabbar.topAnchor.constraint(equalTo: view.topAnchor),
            tabBarLeadingConstraint,
            tabBarTrailingConstraint,
            tabBarHeightConstraint,

            containerTopConstraint,
            containerLeadingConstraint,
            containerTrailingConstraint,
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: container.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.contentLayoutGuide.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: container.frameLayoutGuide.heightAnchor)
        ])

        updateConstraints()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupTabbar()
        setupContainer()
        setupStack()
        setupConstraints()
    }
    
    // MARK: - Custom types
    
    struct Item
    {
        let title: String
        let viewController: UIViewController
    }

    struct TabbarScheme
    {
        // Title
        public var titleFont: UIFont = .systemFont(ofSize: 17)
        public var selectedTitleColor: UIColor = .black
        public var normalTitleColor: UIColor = .gray

        // Selector
        public var selectorColor: UIColor = .black
        public var selectorHeight: CGFloat = 2
        public var selectorBottom: CGFloat = 0

        // Divider
        public var dividerColor: UIColor = .black
        public var dividerHeight: CGFloat = 1
    }
}

extension TabbarViewController
{
    static func create(with scheme: TabbarScheme,
                       config: ((TabbarViewController) -> Void)? = nil) -> TabbarViewController
    {
        let viewController = TabbarViewController()
        viewController.applyThemingScheme(scheme)

        config?(viewController)
        
        return viewController
    }
}

extension TabbarViewController: SegmentedControlDelegate
{
    func didSelectItem(at index: Int, in segmentedControl: SegmentedControl)
    {
        interactivePageSelectionEnabled = false
        scrollContent(to: index, animated: true)
        delegate?.tabBarController(self, didSelect: items[index].viewController)
    }

    func shouldSelectItem(at index: Int, in segmentedControl: SegmentedControl) -> Bool
    {
        delegate?.tabBarController(self, shouldSelect: items[index].viewController) ?? true
    }
}

extension TabbarViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let index = getIndex(for: scrollView.contentOffset.x)

        if index != currentSelectedIndex && interactivePageSelectionEnabled
        {
            setSelectedItem(at: index, animated: true, updateOffset: false)
        }
        
        currentSelectedIndex = index
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        delegate?.tabBarController(self, didSelect: items[currentSelectedIndex].viewController)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        interactivePageSelectionEnabled = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate { delegate?.tabBarController(self, didSelect: items[currentSelectedIndex].viewController) }
    }
}
