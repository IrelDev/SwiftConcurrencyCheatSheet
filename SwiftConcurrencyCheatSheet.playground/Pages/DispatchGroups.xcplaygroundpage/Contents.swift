//: [Dispatch Queues](@previous)
/*:
 # Dispatch Groups
 
 Dispatch groups allow you to organize tasks into groups that can perform completion blocks after tasks are completed. For example, the code below will print Work One at first, Work Two after two seconds delay, and All work is done at the end.
 */
import Foundation
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let viewController = UIViewController()

let dispatchGroup = DispatchGroup()

dispatchGroup.enter()
DispatchQueue.global(qos: .background).async {
    print("Work One")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        print("Work Two")
        dispatchGroup.leave()
    }
}

dispatchGroup.notify(queue: DispatchQueue.main) {
    print("All work is done")
    
    let alert = UIAlertController(title: "Completed!", message: "All work is done", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default)
    alert.addAction(alertAction)
    
    viewController.present(alert, animated: true)
}
//: Remember that count of .enter() and .leave() calls must be equal otherwise .notify() completion block will never be executed or will be executed not in time.

PlaygroundPage.current.liveView = viewController
//: [Dispatch Semaphores](@next)
