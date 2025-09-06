import UIKit

class CustomNavigationController: UINavigationController {
    
    // 将状态栏隐藏控制权委托给当前的 top view controller
    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }
    
    // 将状态栏动画控制权委托给当前的 top view controller
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return topViewController?.preferredStatusBarUpdateAnimation ?? .none
    }
    
    // 将状态栏样式控制权委托给当前的 top view controller
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    // 当 view controller 改变时，更新状态栏
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        // 延迟更新状态栏，确保推送动画完成后再更新
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let result = super.popViewController(animated: animated)
        
        // 立即更新状态栏，确保返回时状态栏能及时恢复
        setNeedsStatusBarAppearanceUpdate()
        return result
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}