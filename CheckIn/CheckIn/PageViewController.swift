//
//  PageViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 15/02/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController :"QRScanFlow"), self.newVc(viewController: "Landing"),
                self.newVc(viewController: "manualFlow")]
    }()
    
    var pageControl = UIPageControl()
    
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 1
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = ColorSettings.textColor
        self.pageControl.currentPageIndicatorTintColor = ColorSettings.navBarColor
        self.view.addSubview(pageControl)
    }
    
    @objc func hidePageControl(notification: NSNotification)
    {
        pageControl.isHidden=true;
    }
    
    @objc func unhidePageControl(notification: NSNotification)
    {
        pageControl.isHidden=false;
    }
    
    @objc func changeColor(notification: NSNotification)
    {
        self.pageControl.pageIndicatorTintColor = ColorSettings.textColor
        self.pageControl.currentPageIndicatorTintColor = ColorSettings.navBarColor
        print("here")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        setViewControllers([orderedViewControllers[1]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.disableSwipe(notification:)), name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.enableSwipe(notification:)), name: NSNotification.Name(rawValue: "createSwipeList"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.hidePageControl(notification:)), name: NSNotification.Name(rawValue: "hidePageControl"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.unhidePageControl(notification:)), name: NSNotification.Name(rawValue: "unhidePageControl"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageViewController.changeColor(notification:)), name: NSNotification.Name(rawValue: "changeColor"), object: nil)
        

        self.delegate = self
        configurePageControl()
    }
    
    @objc func disableSwipe(notification: NSNotification){
        self.dataSource = nil
    }
    
    @objc func enableSwipe(notification: NSNotification){
        self.dataSource = self
        self.pageControl.currentPage=1
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }


}
