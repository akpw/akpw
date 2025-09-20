/*:
 ## Practical GCD, Part I: Introduction to queues
 > This is the playground with sample code for the following [blog](https://akpw.github.io/articles/2016/04/15/GCD-I.html)
 ****
 [First Page](QOS%20Basics) | [Previous](@previous) | [Next](@next)
 */
import Foundation
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
let custom_queue = dispatch_queue_create("com.akpw.bckg.worker", DISPATCH_QUEUE_SERIAL)

dispatch_async(custom_queue) {
    dispatch_sync(dispatch_get_main_queue()) {
        print("deadlocked!!! 👻")
    }
}

// do something else
// ...

// nice try, except...
dispatch_sync(custom_queue) {
    if let queueLabel = currentQueueLabel(){
        print(String(format:
            "supposly running sync on the \(queueLabel)",
            "...or perhaps not???"))
    }
}

// do not wait for too long here :)
