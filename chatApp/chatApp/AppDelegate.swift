import UIKit
import CoreData
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?
    var previousState: Int?
    let stateNames: [String] = ["Active", "Inactive", "Background"]
    var animView: UIView?
    var animated: [UIView] = []
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // true - логирование включено; false - логирование выключено
        Logger.setEnabled(false)
        printState(#function)
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        printState(#function)
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap(_:)))
                tapGesture.delegate = self
                window?.addGestureRecognizer(tapGesture)
        
        return true
    }
    
    @objc func handleLongTap(_ sender: UILongPressGestureRecognizer? = nil) {
        switch sender?.state {
        case .began: print("began")
            let location = sender?.location(ofTouch: 0, in: window) ?? CGPoint(x: 0, y: 0)
            self.regenerateAnim(location)
            self.anim(location)
        case .cancelled: print("cancelled")
        case .ended:
            print("ended")
            for view in animated {
                view.layer.removeAllAnimations()
                view.removeFromSuperview()
            }
            animated = []
        case .failed: print("failed")
        case .none: print("none")
        case .possible: print("possible")
        case .changed: print("changed")
            let location = sender?.location(ofTouch: 0, in: window) ?? CGPoint(x: 0, y: 0)
            self.regenerateAnim(location)
            self.anim(location)
        default:
//            let location = sender?.location(ofTouch: 0, in: window) ?? CGPoint(x: 0, y: 0)
//            self.anim(location)
            print("bla")
        }
        
    }
    
    func regenerateAnim(_ center: CGPoint) {
        
        for view in self.animated {
            view.layer.removeAllAnimations()
            view.removeFromSuperview()
        }
        animated = []
        for _ in 1...10 {
            self.addViewForAnim(center)
        }
    }
    
    func addViewForAnim(_ center: CGPoint) {
//        let letterT = UILabel(); letterT.text = "T"
//        letterT.font = UIFont(name: "System", size: 30)
//        letterT.center = center
//        self.window?.addSubview(letterT)
//        letterT.sizeToFit()
//        self.animated.append(letterT)
        let imageView = UIImageView(frame: CGRect(x: center.x - 20,
                                                  y: center.y - 20,
                                                  width: 40, height: 40))
        imageView.center = center
        imageView.image = UIImage(named: "40")
        self.window?.addSubview(imageView)
        self.animated.append(imageView)
    }
    
    func anim(_ center: CGPoint) {

        for view in self.animated {
            UIView.animate(withDuration: 0.8,
                           delay: 0,
                           options: [.allowUserInteraction, .repeat]) {

                let animation = CABasicAnimation(keyPath: "position")
                animation.repeatCount = .infinity
                animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x, y: center.y))
                
                let randX = Float.random(in: -100...100)
                let randY = Float.random(in: -100...100)
                animation.duration = 0.8
                animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + CGFloat(randX),
                                                             y: center.y + CGFloat(randY)))
                view.alpha = 0
                view.layer.add(animation, forKey: "position")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        printState(#function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        printState(#function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        printState(#function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        printState(#function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        printState(#function)
    }
    
    func printState(_ callerFunction: String) {
        let currentState = UIApplication.shared.applicationState.rawValue
        if previousState == nil {
            Logger.log("Application moved from Not Running State to \(stateNames[currentState]) State: \(callerFunction)")
        } else {
            Logger.log("Application moved from \(stateNames[previousState ?? 0]) State to \(stateNames[currentState]) State: \(callerFunction)")
        }
        previousState = UIApplication.shared.applicationState.rawValue
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "chatApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
