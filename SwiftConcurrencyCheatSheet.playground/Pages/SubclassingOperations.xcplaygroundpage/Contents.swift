//: [Operation Queues](@previous)
/*:
 # Subclassing Operations
 You can create reusable operations by subclassing Operation class. For example, the code below is the synchronous reimplementation of code used in the Block Operations section.
 */
import Foundation

class CustomOperation: Operation {
    var executionBlocksCount: Int
    
    init(executionBlocksCount: Int) {
        self.executionBlocksCount = executionBlocksCount
        super.init()
    }
    override func main() {
        for index in 0 ..< executionBlocksCount + 1 {
            Thread.sleep(forTimeInterval: TimeInterval(index))
            print("Thread slept for \(index) seconds")
        }
    }
}
let customOperation = CustomOperation(executionBlocksCount: 2)
customOperation.completionBlock = {
    print("Custom Operation is Completed")
}
customOperation.start()
//: Note that this code is synchronous because in the for in loop we don't add any execution blocks.

//: [Asynchronous Operations](@next)
