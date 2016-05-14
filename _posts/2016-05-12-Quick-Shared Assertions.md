---
layout: post
title: "Making your Quick test code DRYer with  Shared Assertions"
description: "Swift Testing"
category: articles
tags: [iOS, Apple Swift, BDD, Testing, Quick / Nimble, Mobile Development]
comments: true
---

One of the key aspects of [behavior-driven development](https://en.wikipedia.org/wiki/Behavior-driven_development), or BDD, is about using natural language to describe system behavior and expected outcomes. While semantically not that different from traditional unit-testing, it does help in cross-team communication and puts focus on viewing things from end user's perspective.

In the land of Swift, the combination of [Quick](https://github.com/Quick/Quick) / [Nimble](https://github.com/Quick/Nimble) is becoming a de-facto standard of BDD approach to testing apps. Compared to out-of-the-box [XCTest](https://github.com/apple/swift-corelibs-xctest), it shines in making the test code more readable as well as keeping it in close resemblance to test specifications.

This article is not intended as an introduction to [Quick](https://github.com/Quick/Quick) / [Nimble](https://github.com/Quick/Nimble) and BDD testing, though it does go through common steps of writing a technical test spec and following up with the tests code.

The main focus is rather on testing multiple implementations of a specific interface, or more generally on applying the same set of test specifications to several related functional units.

All examples shown in article are a part of [the sample project](https://github.com/akpw/SwiftNetworkImages), which you can download and run / test in Xcode.

**The initial problem definition**

Let's say we have an app that does something with network images. An essential functionality would be some kind of service that can retrieve an image by its URL:

{% highlight swift %}
/// Image Service protocol
protocol NetworkImageService {
    /// given an URL string, fetches an image and
    /// provides it to the completion closure on the main thread
    func requestImage(urlString: String, completion: Result<UIImage> -> Void)
}
{% endhighlight %}

### Test Spec

Let's propose the following simplified functional test spec for the service:

_GIVEN an image URL, fetch the image and provide it to completion closure on the main thread. WHEN there are problems with connection THEN provide a descriptive error. WHEN not able to process received content THEN provide a descriptive error._


**Let's go test first!**

The `Test-First` approach suggests the following sequence of steps:

 * define a test set for a unit of functionality
 * implement the unit
 * verify that the implementation makes the tests succeed

While not always practically achievable in real-life, _Test-First_ is definitely useful for its focus on specific, well-defined problems. It also helps with making testing a first-class development activity.

Given this is an article about testing, let's stick to that approach and start with writing test code for our `NetworkImageService`.

**Establishing the infrastructure**

To write our test, we will need to set up a minimal version of common service infrastructure.

The `Result<T>` type[^1] represents either a success or a failure of an asynchronous function call:
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
For compliance with Swift2 error handling, we added the `resolve` function that will be used in our
test code later on.

Let's map the error scenarios provided by the test spec to an enum:
{% highlight swift %}
enum NetworkError: ErrorType {
    case CannotConnectToServer, ContentValidationFailed, NetworkRequestFailed
}
{% endhighlight %}


Now let's create a stub for our future `NetworkImageService` implementation:

{% highlight swift %}
struct NetworkImageServiceImpl: NetworkImageService {
    func requestImage(urlString: String, completion: Result<UIImage> -> Void) {
    }
}
{% endhighlight %}
We should be all done with preparations and ready to write the test spec code.

**The Test Spec in Code**

From looking at the original [test spec](#test-spec), the obvious core functionality of our service is fetching an image by its URL. It also needs to be able to handle several potential error scenarios.

Let's use [httpbin.org](https://httpbin.org) as our target test server. With this, the test spec code could be written as the following:

### Test Spec in Code

{% highlight swift %}
class NetworkImageServiceImplSpec: QuickSpec {
    override func spec() {
        describe("Network Image Service") {
            var networkImageService: NetworkImageService!

            beforeEach {
                networkImageService = NetworkImageServiceImpl()
            }
            it("eventually fetchs an image") {
                var image: UIImage?
                networkImageService.requestImage("https://httpbin.org/image/jpeg") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTruthy())
                    do {
                        image = try result.resolve()
                    } catch {}
                }
                expect(image).toEventuallyNot(beNil(), timeout: 10)
            }

            it("eventually provides an expected error when there are problems with connection") {
                var error: NetworkError?
                networkImageService.requestImage("https://some.broken.server.com/content/image/png") { result in
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
                networkImageService.requestImage("https://httpbin.org/get") { result in
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

Note how by courtesy of [Quick](https://github.com/Quick/Quick) / [Nimble](https://github.com/Quick/Nimble), the code above is pretty much a close transcription of [the test spec](#test-spec). And even better yet, it does compile, run & fail as `expect`ed.

At that point we are ready for writing a working implementation of the `NetworkImageService` protocol. It'd better behave well and be on par with our firmly established test infrastructure!


**Fetching an image with NSURLSession**

First let's extend our `NetworkError` with a simple initialization from `NSError`:
{% highlight swift %}
extension NetworkError {
    init(error: NSError) {
        guard error.domain == NSURLErrorDomain else {
            self = .NetworkRequestFailed
            return
        }
        switch error.code {
        case  NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData:
            self = .ContentValidationFailed
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            self = .CannotConnectToServer
        default:
            self = .NetworkRequestFailed
        }
    }
}
{% endhighlight %}

And then we can write our image-fetching code using `NSURLSessionDataTask`:

{% highlight swift %}
struct NSURLSessionNetworkImageService: NetworkImageService  {
    func requestImage(urlString: String, completion: Result<UIImage> -> Void) {
        guard let url = NSURL(string: urlString) else {
            return completion( Result.Failure( NetworkError.CannotConnectToServer ) )
        }

        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithURL(url) { data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    return completion( Result.Failure( NetworkError(error: error) ) )
                }
                guard let data = data, image = UIImage(data: data) else {
                    return completion( Result.Failure( NetworkError.ContentValidationFailed ) )
                }
                completion(Result.Success(image))
            }
        }.resume()
    }
}
{% endhighlight %}

All we need to do now is to inject this implementation into our [test spec code](#test-spec-in-code) code:
{% highlight swift %}
...
beforeEach {
    networkImageService = NSURLSessionNetworkImageService()
}
...
{% endhighlight %}

 and check that all works as `expect`ed. Time to celebrate!

![aa]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/anchorman-jump-in-air.gif)


**Fetching an image with Alamofire**

While we were busy celebrating, someone has implement another version of the image fetch service using popular [Alamofire networking](https://github.com/Alamofire/Alamofire):
{% highlight swift %}
import Alamofire
import AlamofireImage

struct AlamofireNetworkImageService: NetworkImageService  {
    // MARK: - ImageService
    func requestImage(urlString: String, completion: Result<UIImage> -> Void) {
        Alamofire.request(.GET, urlString).responseImage {
            if let error = $0.result.error {
                return completion( Result.Failure( NetworkError(error: error) ) )
            }
            guard let image: UIImage = $0.result.value else {
                return completion( Result.Failure( NetworkError.ContentValidationFailed ) )
            }
            completion(Result.Success(image))
        }
    }
}
{% endhighlight %}

All of a sudden, we have multiple implementation of the image service protocol and now each of them needs to be tested against the same [test specification](#test-spec).

While this example might be a bit oversimplified, having the same set of test specifications for multiple related functional units is quite real. Imagine e.g. a specialized version of image service to fetch a graphical snapshot of a web page, etc.

The question is, how should we go about writing tests for our multiple image service implementations without largely duplicating the same [test spec code](#test-spec-in-code) code over and over again?


**Quick's Shared Assertions**

Luckily, Quick supports the concept of shared assertions. It allows us to define a group of common scenarios and then execute it within contexts of multiple test specs.

On the technical end, this requires writing a custom `QuickConfiguration` class and overriding its `configure` function. It is a common way to influences Quick's behavior when running specs, and it also can be used to create a group of shared assertions with a unique name and associated `SharedExampleClosure` closure:
{% highlight swift %}
public typealias SharedExampleClosure = (SharedExampleContext) -> ()
{% endhighlight %}

where `SharedExampleContext` is basically a key-value representation of the functional unit that we want to test with our shared assertions.

In each image service's test spec code, we then just need to create a specific context and use Quick's `itBehavesLike` function to inject our group of shared assertions into that context.[^2]

To put things in perspective, let's translate this into some working code.

Starting with a service test spec, let create one for the original `NSURLSessionNetworkImageService`:

{% highlight swift %}
class NSURLSessionNetworkImageServiceSpec: QuickSpec {
    override func spec() {
        var networkImageService: NetworkImageService!
        beforeEach {
            let networkImageService = NSURLSessionNetworkImageService()
        }
        itBehavesLike("a NetworkImageService") { ["networkImageService": networkImageService] }
    }
}
{% endhighlight %}

This looks promising, except some annoying _"Value of type does not conform to expected dictionary value type"_  compiler error:

![ce]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/quick-spec-compiler-error.png)

Well, looks like we would need some little tweak there. Looking at the definition of `SharedExampleContext`:

{% highlight swift %}
public typealias SharedExampleContext = () -> (NSDictionary)
{% endhighlight %}

it turns out to be a closure that returns an `NSDictionary`. As our  `NSURLSessionNetworkImageService` is defined as a struct, it can not be put into NSDictionary since its values can only be object types and not Swift structs.

An initial reflex of an experienced Objective-C developer might be: hmm... let's go `NSValue`? While a valid approach (and my initial thought ☺️), let's rather do it more Swifty way and simply define a wrapper:
{% highlight swift %}
class NetworkImageServiceWrapper {
    let networkImageService: NetworkImageService

    init(networkImageService: NetworkImageService) {
        self.networkImageService = networkImageService
    }
}
{% endhighlight %}

that would allow us to deal with the compiler error like this:

{% highlight swift %}
class NSURLSessionNetworkImageServiceSpec: QuickSpec {
    override func spec() {
        var networkImageServiceWrapper: NetworkImageServiceWrapper!
        beforeEach {
            let networkImageService = NSURLSessionNetworkImageService()
            networkImageServiceWrapper = NetworkImageServiceWrapper(networkImageService: networkImageService)
        }
        itBehavesLike("a NetworkImageService") { ["networkImageService": networkImageServiceWrapper] }
    }
}
{% endhighlight %}

Now the compiler is happy and we can move on with writing a similar test spec for the `AlamofireNetworkImageService`.

{% highlight swift %}
class AlamofireNetworkImageServiceSpec: QuickSpec {
    override func spec() {
        var networkImageServiceWrapper: NetworkImageServiceWrapper!
        beforeEach {
            let networkImageService = AlamofireNetworkImageService()
            networkImageServiceWrapper = NetworkImageServiceWrapper(networkImageService: networkImageService)
        }
        itBehavesLike("a NetworkImageService") { ["networkImageService": networkImageServiceWrapper] }
    }
}
{% endhighlight %}

Both test specs looks good now and are definitely DRY enough. The only step remaining is to write our actual shared assertions code, that would be injected into the specs by the `itBehavesLike` function at run-time.

{% highlight swift %}
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

The code above first registers our shared group with unique identifier of `"a NetworkImageService"`, and then uses `beforeEach` function to retrieve and set a specific `NetworkImageServiceWrapper`from the passed context.

Now that we have a specific instance of `NetworkImageService`, we can just add all the shared tests from our original [test spec code](#test-spec-in-code):

{% highlight swift %}
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
            it("eventually retrives an image") {
                var image: UIImage?
                networkImageService.requestImage("https://httpbin.org/image/jpeg") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTrue())
                    do {
                        image = try result.resolve()
                    } catch {}
                }
                expect(image).toEventuallyNot(beNil(), timeout: 10)
            }

            it("eventually gets an expected error if there are problems with connection") {
                var error: NetworkError?
                networkImageService.requestImage("https://some.broken.server.com/content/image/png") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTrue())
                    do {
                        _ = try result.resolve()
                    } catch let networkError as NetworkError {
                        error = networkError
                    } catch {}
                }
                expect(error).toEventually(equal(NetworkError.CannotConnectToServer), timeout: 10)
            }

            it("eventually gets an expected error for handling wrong content type") {
                var error: NetworkError?
                networkImageService.requestImage("https://httpbin.org/get") { result in
                    expect(NSThread.currentThread().isMainThread).to(beTrue())
                    do {
                        _ = try result.resolve()
                    } catch let networkError as NetworkError {
                        error = networkError
                    } catch {}
                }
                expect(error).toEventually(equal(NetworkError.NetworkRequestFailed) ||
                                           equal(NetworkError.ContentValidationFailed),
                                           timeout: 10)
            }
        }
    }
}
{% endhighlight %}


All that's all!

Let's run the tests, check that everything goes as `expect`ed, and have a beer or two with that troublesome author of the extra image service... 🍻🍻


***Conclusion***

The article went through common steps of behavior-driven development with [Quick](https://github.com/Quick/Quick) / [Nimble](https://github.com/Quick/Nimble), and covered the case of applying the same set of test specifications to multiple related functional units.

All examples shown in article are a part of [the sample project](https://github.com/akpw/SwiftNetworkImages), which you can download and run / test in Xcode.

* * *

[^1]: For more on the rationale behind Result, there is [a good talk](https://realm.io/news/compelling-code) by Brian Gesiak, the original author of the Quick framework.

[^2]: On a side note, this is kind of dependency injection in reverse. Looking at the original [test spec code](#test-spec-in-code), an obvious way of thinking DRY is: how can we inject our multiple specific implementations  there: `networkImageService = NetworkImageServiceImpl()`. Well, with Quick's Shared Examples we are not injecting specific implementations to a single generic test, instead creating a test for each implementation and injecting a share assertions group that will then be run as if it was written there manually.


