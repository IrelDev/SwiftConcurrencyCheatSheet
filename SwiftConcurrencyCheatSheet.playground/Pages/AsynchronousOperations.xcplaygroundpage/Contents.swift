//: [Subclassing Operations](@previous)
/*:
 # Asynchronous Operations
 You can create reusable asynchronous operations by creating and subclassing custom AsynchronousOperation class.
 AsynchronousOperation is a subclass of Operation class and it overrides isReady, isExecuting and isFinished properties that allow us to manually finish or delay the operation.
 For example, the code below will implement AsynchronousOperation and its subclass that will be used for image downloading.
 */
import Foundation
import UIKit
import PlaygroundSupport

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

let viewController = UIViewController()

let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
imageView.center = viewController.view.center
imageView.clipsToBounds = true
imageView.layer.cornerRadius = 25

viewController.view.addSubview(imageView)

let urlToImage = "https://picsum.photos/seed/picsum/200/300"
let imageOperation = ImageFromNetworkOperation(urlToImage: urlToImage) { (image) in
    DispatchQueue.main.async {
        imageView.image = image
    }
}
imageOperation.start()
imageOperation.completionBlock = { print("ImageFromNetworkOperation has finished") }

PlaygroundPage.current.liveView = viewController

//: [](@next)
