---
layout: post
title: "Making your BDD test code DRYer with  Shared Assertions"
description: "Swift Testing"
category: articles
tags: [iOS, Apple Swift, BDD, Testing, Quick / Nimble, Mobile Development]
comments: true
---

One of the key aspects of [behavior-driven development](https://en.wikipedia.org/wiki/Behavior-driven_development), or BDD, is about using natural language to describe system behavior and expected outcomes. While semantically not that different from traditional unit-testing, it does help cross-team communication as well focus on viewing things from end user's perspective.

In the land of Swift, the combination of [Quick](https://github.com/Quick/Quick) / [Nimble](https://github.com/Quick/Nimble) is quickly becoming de-facto standard of BDD approach to testing apps. Compared to out-of-the-box [XCTest](https://github.com/apple/swift-corelibs-xctest), it shines in making the test code more readable and keeping it in close resemblance to test specifications.

While this article goes through common steps of writing a spec and following up with the tests, it is not intended as an introduction to Quick / Nimble and BDD testing.

The main focus is rather on testing multiple implementations of a specific interface, or more generally on applying the same set of test specifications to multiple related functional units.

All examples shown in article are a part of [the sample project](https://github.com/akpw/SwiftNetworkImages), which you can download and run / test in Xcode.

**The initial problem definition**

Let's say have we have an app that does something with network images. An essential functionality would be some kind of service that can retrieve an image by its URL:

{% highlight swift %}
/// Image Service protocol
protocol NetworkImageService {
    /// given an URL string, fetches an image and
    /// provides it to the completion closure on the main thread
    func requestImage(urlString: String, completion: Result<UIImage> -> ())
}
{% endhighlight %}

Let's propose the following simplified functional test spec for the service:

_GIVEN an image URL, fetch the image and provide it to the completion closure on the main thread. WHEN there are problems with connection, provide a descriptive error. WHEN not able to process received content, provide a descriptive error._


**Let's go test first!**

The `Test-First` approach suggests the following sequence of steps:

 * define a test set for the unit
 * implement the unit
 * verify that the implementation of the unit makes the tests succeed

While not always practically achievable in real-life, Test-First is definitely useful for its focus on specific, well-defined problems and it also helps with making testing a first-class development activity.

Let's start with writing test code for the NetworkImageService.

**Establishing the infrastructure**

To write our test, we will need to set up a minimal version of common async service infrastructure.

The Result<T> type represents either a success or a failure of a method call:
{% highlight swift %}
enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}
extension Result {
    // conversion to Swift2 throw model
    func resolve() throws -> T {
        switch self {
        case Result.Success(let value): return value
        case Result.Failure(let error): throw error
        }
    }
}
{% endhighlight %}

For compliance with Swift2 error handling, we added a `resolve` method that we will use in our test code later on.

For quick introduction of the rationale behind Result there is [a great talk](https://realm.io/news/compelling-code) by Brian Gesiak, the original author of the Quick framework.

The NetworkError enum will follow the error scenarios provided by the test spec:
{% highlight swift %}
enum NetworkError: ErrorType {
    case Unknown, NetworkRequestFailed, ContentValidationFailed, CannotConnectToServer

    // translates NSError into NetworkError
    init(error: NSError) {
        guard error.domain == NSURLErrorDomain else {
            self = .Unknown
            return
        }
        switch error.code {
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            self = .CannotConnectToServer
        case  NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData:
            self = .ContentValidationFailed
        default:
            self = .NetworkRequestFailed
        }
    }
}
{% endhighlight %}


Now let's create a stub for our future `NetworkImageService` implementation:

{% highlight swift %}
struct NetworkImageServiceImpl: NetworkImageService {
    func requestImage(urlString: String, completion: Result<UIImage> -> ()) {
    }
}
{% endhighlight %}
We should be all done with preparations and ready to write the test spec code.

## Test Spec
From looking at the test spec, the obvious core functionality of our service is fetching an image by its URL. It also need to be able to handle several potential error scenarios.

Let's use [httpbin.org](https://httpbin.org) as our target test server.

With this, the test spec code could be written as the following:

{% highlight swift %}
class NetworkImageServiceImplSpec: QuickSpec {
    override func spec() {
        describe("Network Image Service") {
            var network: NetworkImageService!

            beforeEach {
                network = NetworkImageServiceImpl()
            }
            it("eventually fetchs an image") {
                var image: UIImage?
                network.requestImage("https://httpbin.org/image/jpeg") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTruthy())
                    do {
                        image = try result.resolve()
                    } catch {}
                }
                expect(image).toEventuallyNot(beNil(), timeout: 10)
            }

            it("eventually provides an expected error when there are problems with connection") {
                var error: NetworkError?
                network.requestImage("https://some.broken.server.com/content/image/png") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTruthy())
                    do {
                        _ = try result.resolve()
                    } catch let networkError as NetworkError {
                        error = networkError
                    } catch {}
                }
                expect(error).toEventually(equal(NetworkError.CannotConnectToServer), timeout: 10)
            }

            it("eventually provides an expected error when handling wrong content type") {
                var error: NetworkError?
                network.requestImage("https://httpbin.org/get") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTruthy())
                    do {
                        _ = try result.resolve()
                    } catch let networkError as NetworkError {
                        error = networkError
                    } catch {}
                }
                expect(error).toEventually(equal(NetworkError.NetworkRequestFailed), timeout: 10)
            }
        }
    }
}
{% endhighlight %}

Note how by courtesy of Quick / Nimble, the code above is pretty much a transcription of the test spec. And even better yet, it does successfully compile, run & fail as expected! 👻

At that point we are ready for writing a working implementation of the `NetworkImageService` protocol. And it'd better behave well and be on par with our firmly established test infrastructure requirements!


**Fetching an image with NSURLSession**

Luckily, fetching an image with `NSURLSession` is not really a big deal:

{% highlight swift %}
struct NSURLSessionNetworkImageService: NetworkImageService  {
    func requestImage(urlString: String, completion: Result<UIImage> -> ()) {
        guard let url = NSURL(string: urlString) else {
            completion( Result.Failure( NetworkError.CannotConnectToServer ) )
            return
        }

        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithURL(url) { data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    completion( Result.Failure( NetworkError(error: error) ) )
                    return
                }
                guard let data = data, image = UIImage(data: data) else {
                    completion( Result.Failure( NetworkError.ContentValidationFailed ) )
                    return
                }
                completion(Result.Success(image))
            }
        }.resume()
    }
}
{% endhighlight %}

All we need to do now is inject this specific implementation into our [test spec](#test-spec) code:
{% highlight swift %}
...
beforeEach {
    network = NSURLSessionNetworkImageService()
}
...
{% endhighlight %}

 and check that all works as `expect`ed. Time to celebrate!

![aa]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/anchorman-jump-in-air.gif)



**Fetching an image with Alamofire**

While we were busy celebrating, someone has implement a cooler version of the image fetch service using popular [Alamofire networking](https://github.com/Alamofire/Alamofire):
{% highlight swift %}
import Alamofire
import AlamofireImage

struct AlamofireNetworkImageService: NetworkImageService  {
    func requestImage(urlString: String, completion: Result<UIImage> -> ()) {
        Alamofire.request(.GET, urlString).responseImage {
            if let error = $0.result.error {
                completion( Result.Failure( NetworkError(error: error) ) )
                return
            }
            guard let image: UIImage = $0.result.value else {
                completion( Result.Failure( NetworkError.ContentValidationFailed ) )
                return
            }
            completion(Result.Success(image))
        }
    }
}
{% endhighlight %}

Now we have multiple implementation of the image service protocol, and each of them needs to be tested against the same test specification.

While the example above might be a bit over simplified, having same set of test specifications for multiple related functional units is quite real. Imagine e.g. a specialized version of image service to fetch a graphical snapshot of a web page, etc.

The question is, how should we go about writing tests for our image service implementations without largely duplicating the same [test spec](#test-spec) code over and over again?

![aa]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/Dwight-Schrute-look-of-disapproval.gif)


***Quick's Shared Assertions***

Luckily, Quick already supports the concept of shared assertions for multiple specs. A custom `QuickConfiguration` class allows overriding its `configure` method, which then influences Quick's behavior when running specs. It also can be used for creating a group of share examples, with a unique name and associated `SharedExampleClosure` closure.

The `SharedExampleClosure` there is defined as:
{% highlight swift %}
public typealias SharedExampleClosure = (SharedExampleContext) -> ()
{% endhighlight %}

where `SharedExampleContext` is basically a key-value representation of the functional unit parameter that needs to be tested against the shared examples spec.


To put his all in perspective, let's translate this to our case and re-write our [test spec](#test-spec) as a `sharedExamples` group.

{% highlight swift %}
/// NetworkImageService wrapper,
/// needed since SharedExampleContext has a NSDictionary return type
/// and NSDictionary values can only be object types (not structs)
class NetworkImageServiceWrapper {
    private(set) var networkImageService: NetworkImageService

    init(networkImageService: NetworkImageService) {
        self.networkImageService = networkImageService
    }
}

/// Shared Examples Configuration for the NetworkImageService tests
class NetworkImageServiceConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        var networkImageService: NetworkImageService!
        sharedExamples("a NetworkImageService") { (sharedExampleContext: SharedExampleContext) in
            beforeEach {
                guard let networkImageServiceWrapper =
                        sharedExampleContext()["networkImageService"] as? NetworkImageServiceWrapper else {
                        XCTFail("failed retrieve a networkImageService from SharedExampleContext")
                        abort()
                }
                networkImageService = networkImageServiceWrapper.networkImageService
            }
        }
    }
}
{% endhighlight %}

`sharedExamples` defines a group of shared examples
objects
For example, consider a protocol called Edible. When a dolphin eats something Edible, the dolphin becomes happy. Mackerel and Cod are both edible. Quick allows you to easily test that a dolphin is happy to eat either one.

The example below defines a set of "shared examples" for "something edible", and specifies that both mackerel and cod behave like "something edible":

Shared examples can include any number of it, context, and describe blocks. They save a lot of typing when running the same tests against several different kinds of objects



***Conclusion***

This introductory part of the series covered Grand Central Dispatch queues and base tasks dispatching, along with common practices for selecting appropriate queue types.

All code examples are available for download in [this playground]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/GCD_Part_I.playground.zip)

The next part will go deeper into QOS features as well as diving into more advanced GCD usage patterns.
