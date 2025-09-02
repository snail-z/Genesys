import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }
    
    private func setupTabs() {
        let demoListVC = DemoListViewController()
        let demoNavController = UINavigationController(rootViewController: demoListVC)
        demoNavController.tabBarItem = UITabBarItem(
            title: "Demo",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet.circle.fill")
        )
        
        let secondVC = SecondViewController()
        let secondNavController = UINavigationController(rootViewController: secondVC)
        secondNavController.tabBarItem = UITabBarItem(
            title: "第二页",
            image: UIImage(systemName: "square.grid.2x2"),
            selectedImage: UIImage(systemName: "square.grid.2x2.fill")
        )
        
        viewControllers = [demoNavController, secondNavController]
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .systemBackground
    }
}