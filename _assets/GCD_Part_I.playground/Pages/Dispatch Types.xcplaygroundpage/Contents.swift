/*:
 ## Practical GCD, Part I: Introduction to queues
 > This is the playground with sample code for the following [blog](http://localhost:4000/articles/2016/04/15/GCD-I.html)
 ***
 [First Page](QOS%20Basics) | [Previous](@previous) | [Next](@next)
 */
import Foundation
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let queue_attributes = dispatch_queue_attr_make_with_qos_class(
                                DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
let custom_queue = dispatch_queue_create("com.akpw.bckg.worker", queue_attributes)

guard let mainQueueLabel = currentQueueLabel() else {XCPlaygroundPage.currentPage.finishExecution()}

print("1. sumbitting async from \(mainQueueLabel)")
dispatch_async(custom_queue) {
    if let queueLabel = currentQueueLabel() {
        print("2. running async on the \(queueLabel)")
    }
}
print("3. now doing something else on \(mainQueueLabel)")

print("4. sumbitting synchronously from \(mainQueueLabel)")
dispatch_sync(custom_queue) {
    if let queueLabel = currentQueueLabel() {
        print("5. running sync on the \(queueLabel)")
    }
}
print("6. now doing something else on \(mainQueueLabel)")


let delay = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(NSTimeInterval(NSEC_PER_SEC) * 1))
print("7. submitting with delay from \(mainQueueLabel)")
dispatch_after(delay, dispatch_get_main_queue()) {
    if let queueLabel = currentQueueLabel() {
        print("8. running after delay on the \(queueLabel)")
    }
    XCPlaygroundPage.currentPage.finishExecution()
}
