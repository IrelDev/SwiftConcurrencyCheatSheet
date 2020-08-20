/*:
 # DispatchQueues
 
 Dispatch queue is an object that manages the execution of tasks serially or concurrently on your app's main thread or on a background thread.
 
 ## Serial & Concurrent Queues
 
 SERIAL queues can only use one thread, which means that only one task can be completed at a time.
 */
import Foundation
import UIKit
import PlaygroundSupport

let serialQueue = DispatchQueue(label: "serial")
//: CONCURRENT queues can only use as many threads as the system has resources for.

let cuncurrentQueue = DispatchQueue(label: "cuncurrent", attributes: .concurrent)
/*:
 ## ASYNCHRONOUS DOES NOT MEAN CONCURRENT
 
 An ASYNCHRONOUS queue executes the task in another thread, while a SYNCHRONOUS queue just waits for the task to complete before executing the next one.
 
 If you call serialQueue.async { } it will behave exactly like serialQueue.sync { } because there is only one thread available so the second task can't be started.
 
 ## Main Queue
 
 The MAIN queue is the dispatch queue associated with the main thread that's responsible for UI. You should NEVER execute something synchronously in the main queue unless it is related to the UI. Otherwise, it will freeze your app until your synchronous task is completed.
 
 In addition, all DispatchQueue.main.sync calls should NEVER be called from the main thread, otherwise, it will cause deadlock.
 
 ## Global Queue
 The GLOBAL queue is the dispatch queue that executes tasks concurrently using threads from the global thread pool.
 */
let viewController = UIViewController()

let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
imageView.center = viewController.view.center
imageView.clipsToBounds = true
imageView.layer.cornerRadius = 25

viewController.view.addSubview(imageView)

let urlToImage = "https://picsum.photos/seed/picsum/200/300"
DispatchQueue.global(qos: .utility).async {
    guard let url = URL(string: urlToImage),
          let data = try? Data(contentsOf: url),
          let image = UIImage(data: data) else { return }
    
    DispatchQueue.main.async {
        imageView.image = image
    }
}
PlaygroundPage.current.liveView = viewController
//: [Dispatch Groups](@next)
