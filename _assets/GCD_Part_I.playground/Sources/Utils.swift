import Foundation

public func currentQueueLabel() -> String? {
    let queueLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)
    return String(CString: queueLabel, encoding: NSUTF8StringEncoding)
}
