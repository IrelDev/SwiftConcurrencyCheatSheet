//: [Dispatch Groups](@previous)
/*:
 A dispatch semaphore is an efficient implementation of a traditional counting semaphore which is defined as a non-negative integer variable and what a dispatch semaphore does is limit the number of concurrent tasks performed at a time.
 
 You increment a semaphore count by calling the .signal() method, and decrement a semaphore count or wait for a signal by calling .wait(). For example, the code below will print two task numbers every 2 seconds.
 */
import Foundation

let semaphore = DispatchSemaphore(value: 2)

for index in 1 ..< 5 {
    DispatchQueue.global(qos: .utility).async {
        semaphore.wait()
        
        Thread.sleep(forTimeInterval: 2)
        print("Task number is \(index)")
        
        semaphore.signal()
    }
}

//: [Dispatch Work Items](@next)
