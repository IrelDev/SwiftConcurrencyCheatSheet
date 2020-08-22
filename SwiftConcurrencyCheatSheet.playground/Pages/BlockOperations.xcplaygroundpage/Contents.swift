//: [DispatchWorkItems](@previous)
/*:
 # Block Operations
 The BlockOperation class is a concrete subclass of Operation that manages the concurrent execution of one or more blocks on the default global queue but there's a catch. Execution blocks will run concurrently, but BlockOperation itself is not actually concurrent, it's serial and we can see that by calling BlockOperation().isConcurrent so the calling thread will be stuck until all the execution blocks finish their work.
 */
import Foundation

let blockOperation = BlockOperation()

for index in 0 ..< 4 {
    blockOperation.addExecutionBlock {
        Thread.sleep(forTimeInterval: TimeInterval(index))
        print("Thread slept for \(index) seconds")
    }
}
blockOperation.completionBlock = {
    print("Thread woke up")
}

blockOperation.start()

print("Block Operation is serial so this line will be executed after blockOperation ends.")
//:  So, if you want your operation to be fully concurrent, you must implement the appropriate functionality in an Operation's subclass.

//: [Operation Queues](@next)
