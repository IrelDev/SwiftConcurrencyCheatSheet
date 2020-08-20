//: [DispatchSemaphores](@previous)
/*:
 # Dispatch Work Items
 
 A dispatch work item encapsulates work to be performed on a dispatch queue or within a dispatch group. A dispatch work item has a cancel flag. If it is canceled before running, the dispatch queue won’t execute it and will skip it. If it is canceled during its execution, the cancel property return true and the dispatch queue will continue executing so there is no way to stop a dispatch work item after it is started. Also, a dispatch work item can perform a completion block after work is completed.
 
 For example, the code below will execute the first task but the second task will never be executed.
 */
import Foundation

let dispatchQueue = DispatchQueue.global()

let firstDispatchWorkItem = DispatchWorkItem {
    print("First Work Item Started")
    Thread.sleep(forTimeInterval: 2)
    
    print("First Work Item Completed")
}
let secondDispatchWorkItem = DispatchWorkItem {
    print("Second Work Item Started")
    Thread.sleep(forTimeInterval: 2)
    
    print("Second Work Item Completed")
}

dispatchQueue.async(execute: firstDispatchWorkItem)

firstDispatchWorkItem.notify(queue: DispatchQueue.main) {
    secondDispatchWorkItem.cancel()
    print(secondDispatchWorkItem.isCancelled ? "Second Work Item Canceled": "Second Work Item Is Ready For Execution")
    
    dispatchQueue.async(execute: secondDispatchWorkItem)
}
//: Remember that .notify() method will be executed no matter isCancelled property set to false or not.

//: [Next](@next)
