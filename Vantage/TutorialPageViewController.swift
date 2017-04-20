//
//  TutorialPageViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 8/9/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        self.view.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 1
        }) 
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        var scrollView: UIScrollView?
        var pageControl: UIPageControl?
        
        if (self.view.subviews.count == 2) {
            for view in self.view.subviews {
                if (view.isKind(of: UIScrollView.self)) {
                    scrollView = view as? UIScrollView
                } else if (view.isKind(of: UIPageControl.self)) {
                    pageControl = view as? UIPageControl
                }
            }
        }
        
        if let scrollView = scrollView {
            if let pageControl = pageControl {
                scrollView.frame = self.view.bounds
                self.view.bringSubview(toFront: pageControl)
            }
        }
        
        super.viewDidLayoutSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController("FirstPage"),
                self.newColoredViewController("SecondPage"),
                self.newColoredViewController("ThirdPage"),
                self.newColoredViewController("FourthPage"),
                self.newColoredViewController("FifthPage")]
    }()
    
    fileprivate func newColoredViewController(_ color: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(color)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            print("On Last Page")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
            return vc
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}
