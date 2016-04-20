/*:
 ## Practical GCD, Part I: Introduction to queues
 > This is the playground with sample code for the following [blog](http://localhost:4000/articles/2016/04/15/GCD-I.html)
 ***
 [First Page](QOS%20Basics) | [Previous](@previous) 
 */
import Foundation
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

class ShapeShifter {
    var name: String
    var species: String
    
    private let synchronizationQueue = dispatch_queue_create(
            "com.akpw.shapeshifter.sync_queue", DISPATCH_QUEUE_CONCURRENT)
    
    init(name: String, species: String) {
        self.name = name
        self.species = species
    }
    
    func shiftShape(name: String, species: String) {
        dispatch_barrier_async(synchronizationQueue) {
            self.name = name
            self.species = species
        }
    }
    
    func shapeInfo() -> String {
        var shapeInfo = ""
        dispatch_sync(synchronizationQueue) {
            shapeInfo = "\(self.name) the \(self.species)"
        }
        return shapeInfo
    }
}


// Test
let queue = dispatch_queue_create("com.akpw.worker", DISPATCH_QUEUE_CONCURRENT)
let shapesGroup = dispatch_group_create()
let shapes = [("Tom", "Cat"), ("Spike", "Bulldog"), ("Jerry", "Mouse")]

var shapeShifter = ShapeShifter(name: "Tyke", species: "Puppy")
print(shapeShifter.shapeInfo())
for shape in shapes {
    dispatch_group_async(shapesGroup, queue) {
        shapeShifter.shiftShape(shape.0, species: shape.1)
        print("Current shape: \(shapeShifter.shapeInfo())")
    }
}

dispatch_group_notify(shapesGroup, dispatch_get_main_queue()) {
    print("Latest shape: \(shapeShifter.shapeInfo())")
    XCPlaygroundPage.currentPage.finishExecution()
}
