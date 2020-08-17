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
You should NEVER execute something synchronously in the main queue unless it is related to the UI. Otherwise, it will freeze your app until your synchronous task is completed. 

In addition, all `DispatchQueue.main.sync` calls should **NEVER** be called from the 
main thread, otherwise, it will cause deadlock. 
```swift
DispatchQueue.main.async {
    tableView.reloadData()
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
Remember that count of `.enter()` and `.leave()` calls must be equal otherwise `.notify` completion block will never be executed or will be executed not in time.
