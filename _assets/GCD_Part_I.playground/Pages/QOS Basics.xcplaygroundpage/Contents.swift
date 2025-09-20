/*:
 ## Practical GCD, Part I: Introduction to queues
 > This is the playground with sample code for the following [blog](https://akpw.github.io/articles/2016/04/15/GCD-I.html)
 ****
 [Next](@next)
 */
import Foundation
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let q = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)

dispatch_async(q) {
    if let label_name = currentQueueLabel() {
        print("Now on a GCD pool thread with QOS class: \(label_name)")
    }
    dispatch_async(dispatch_get_main_queue()) {
        if let label_name = currentQueueLabel() {
            print("And now back to: \(label_name)")
        }
        XCPlaygroundPage.currentPage.finishExecution()
    }
}
