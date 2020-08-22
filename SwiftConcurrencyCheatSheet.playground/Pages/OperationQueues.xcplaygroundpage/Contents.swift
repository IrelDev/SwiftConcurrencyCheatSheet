//: [Block Operations](@previous)
/*:
 Operation Queues regulate the execution of operations, same as Dispatch Queues.
 Take a look at the Block Operations section code reimplementation.
 */
import Foundation

let queue = OperationQueue()
let blockOperation = BlockOperation()

for index in 0 ..< 4 {
    blockOperation.addExecutionBlock {
        Thread.sleep(forTimeInterval: TimeInterval(index))
        print("Thread slept for \(index) seconds")
    }
}

queue.addOperation(blockOperation)

print("Operation queue does not block the main thread because it's concurrent so that line will run first")
//: Remember that you can pause any operation queue by setting the isSuspended property to true.

//: [Subclassing Operations](@next)
