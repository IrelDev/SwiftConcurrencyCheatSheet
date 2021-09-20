# SwiftConcurrencyCheatSheet

## Dispatch Queues
Dispatch queue is an object that manages the execution of tasks serially or 
concurrently on your app's main thread or on a background thread. 

## Serial & Concurrent Queues 
**SERIAL** queues can only use one thread, which means that only one task can be completed at a time. 
```swift
let serialQueue = DispatchQueue(label: "serial")
```

**CONCURRENT** queues can only use as many threads as the system has resources for. 
```swift
let cuncurrentQueue = DispatchQueue(label: "cuncurrent", attributes: .concurrent)
```

### ASYNCHRONOUS DOES NOT MEAN CONCURRENT 
An **ASYNCHRONOUS** queue executes the task in another thread, while a **SYNCHRONOUS** queue just waits for the task to complete before executing the next one. 

If you call `serialQueue.async { }` it will behave exactly like `serialQueue.sync { }` because there is only one thread available so the second task can't be started.

## Main Queue
The **MAIN** queue is the  dispatch queue associated with the main thread that's responsible for UI. 
You should **NEVER** execute something synchronously in the main queue unless it is related to the UI. Otherwise, it will freeze your app until your synchronous task is completed. 

In addition, all `DispatchQueue.main.sync` calls should **NEVER** be called from the 
main async thread, otherwise, it will cause deadlock. 
```swift
DispatchQueue.main.async {
    DispatchQueue.main.sync {
        tableView.reloadData()
    }
}
```

## Global Queue 
The **GLOBAL** queue is the dispatch queue that executes tasks 
concurrently using threads from the global thread pool. 
```swift
let urlToImage = "https://picsum.photos/seed/picsum/200/300" 
DispatchQueue.global(qos: .utility).async {
    guard let url = URL(string: urlToImage), 
    let data = try? Data(contentsOf: url),
    let image = UIImage(data: data) else { return } 
    
    DispatchQueue.main.async {
        imageView.image = image 
    } 
}
```

## QOS
The quality of service allows you to determine how important a task is and 
how quickly it should be completed. 

- `.userInteractive` is used for highest priority tasks, such as animations, event handling, or updating your app's user interface. 
- `.userInitiated` is used for second priority tasks that provide immediate results for something the user is doing, such as email opening. 
- `.utility` is used for long-running tasks that may have a progress indicator. 
- `.background` is used for lowest priority tasks, such as server synchronization. 
- `.default` is used for tasks that  perform active work on the user's behalf. 
- `.unspecified` should not be used directly unless you know what are you doing. 

## Dispatch Groups
Dispatch groups allow you to organize tasks into groups that can perform completion blocks after tasks are completed. For example, the code below will print `Work One` at first, `Work Two` after two seconds delay, and `All work is done` at the end.
```swift
let dispatchGroup = DispatchGroup()

DispatchQueue.global(qos: .background).async {
    print("Work One")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        print("Work Two")
        dispatchGroup.leave()
    }
}

dispatchGroup.notify(queue: DispatchQueue.main) {
    print("All work is done")
}
```
Remember that count of `.enter()` and `.leave()` calls must be equal otherwise `.notify()` completion block will never be executed or will be executed not in time.

## Dispatch Semaphores
A dispatch semaphore is an efficient implementation of a traditional counting semaphore which is defined as a non-negative integer variable and what a dispatch semaphore does is limit the number of concurrent tasks performed at a time.

You increment a semaphore count by calling the `.signal()` method, and decrement a semaphore count or wait for a signal by calling `.wait()`.
For example, the code below will print two task numbers every 2 seconds.
```swift
let semaphore = DispatchSemaphore(value: 2)

for index in 1 ..< 5 {
    DispatchQueue.global(qos: .utility).async {
        semaphore.wait()
        
        Thread.sleep(forTimeInterval: 2)
        print("Task number is \(index)")
        
        semaphore.signal()
    }
}
```
## Dispatch Work Items
A dispatch work item encapsulates work to be performed on a dispatch queue or within a dispatch group. A dispatch work item has a cancel flag. If it is canceled before running, the dispatch queue won’t execute it and will skip it. If it is canceled during its execution, the cancel property return `true` and the dispatch queue will continue executing so there is no way to stop a dispatch work item after it is started. Also, a dispatch work item can perform a completion block after work is completed.

For example, the code below will execute the first task but the second task will never be executed. 
```swift
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
```
Remember that `.notify()` method will be executed no matter `isCancelled` property set to false or not.

## Block Operations
The BlockOperation class is a concrete subclass of Operation that manages the concurrent execution of one or more blocks on the default global queue but there's a catch. Execution blocks will run concurrently, but BlockOperation itself is not actually concurrent, it's serial and we can see that by calling `BlockOperation().isConcurrent` so the calling thread will be stuck until all the execution blocks finish their work.
```swift
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
```
So, if you want your operation to be fully concurrent, you must implement the appropriate functionality in an Operation's subclass.

## Operation Queues
Operation Queues regulate the execution of operations, same as Dispatch Queues.
Take a look at the Block Operations section code reimplementation.
```swift
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
```
Remember that you can pause any operation queue by setting the isSuspended property to true.

## Subclassing Operations
You can create reusable operations by subclassing `Operation` class. For example, the code below is the synchronous reimplementation of code used in the Block Operations section.
```swift
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
```
Note that this code is synchronous because in the for in loop we don't add any execution blocks.

## Asynchronous Operations
You can create reusable asynchronous operations by creating and subclassing custom `AsynchronousOperation` class.
`AsynchronousOperation` is a subclass of `Operation` class and it overrides `isReady`, `isExecuting` and `isFinished` properties that allow us to manually finish or delay the operation.
For example, the code below will implement `AsynchronousOperation` and its subclass that will be used for image downloading.
```swift
class AsynchronousOperation: Operation {
    enum State: String {
        case ready
        case executing
        case finished
        
        var key: String { "is\(rawValue.capitalized)" }
    }
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.key)
            willChangeValue(forKey: state.key)
        } didSet {
            didChangeValue(forKey: oldValue.key)
            didChangeValue(forKey: state.key)
        }
    }
    final override public var isAsynchronous: Bool { true }
    override public var isReady: Bool { super.isReady && state == .ready }
    override public var isExecuting: Bool { state == .executing }
    override public var isFinished: Bool { state == .finished }
    
    override func cancel() { state = .finished }
    final override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
}
class ImageFromNetworkOperation: AsynchronousOperation {
    var urlToImage: String
    let completion: (UIImage) -> Void
    
    init(urlToImage: String, completion: @escaping (UIImage) -> Void) {
        self.urlToImage = urlToImage
        self.completion = completion
    }
    
    override func main() {
        DispatchQueue.global(qos: .utility).async {
            guard let url = URL(string: self.urlToImage),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            self.completion(image)
            self.state = .finished
        }
    }
}
let urlToImage = "https://picsum.photos/seed/picsum/200/300"
let imageOperation = ImageFromNetworkOperation(urlToImage: urlToImage) { (image) in
    DispatchQueue.main.async {
        imageView.image = image
    }
}
imageOperation.start()
```
