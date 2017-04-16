
// Credit: https://github.com/ashfurrow/Nimble-Snapshots

import FBSnapshotTestCase
import Foundation
import Nimble
import QuartzCore
import Quick
import UIKit

@objc public protocol Snapshotable {
    var snapshotObject: UIView? { get }
}

extension UIViewController : Snapshotable {
    public var snapshotObject: UIView? {
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
        return view
    }
}

extension UIView : Snapshotable {
    public var snapshotObject: UIView? {
        return self
    }
}

@objc class FBSnapshotTest: NSObject {

    var currentExampleMetadata: ExampleMetadata?

    var referenceImagesDirectory: String?
    var tolerance: CGFloat = 0

    class var sharedInstance: FBSnapshotTest {
        struct Instance {
            static let instance: FBSnapshotTest = FBSnapshotTest()
        }
        return Instance.instance
    }

    class func setReferenceImagesDirectory(_ directory: String?) {
        sharedInstance.referenceImagesDirectory = directory
    }

    // swiftlint:disable:next function_parameter_count
    class func compareSnapshot(_ instance: Snapshotable, isDeviceAgnostic: Bool = false,
                               usesDrawRect: Bool = false, snapshot: String, record: Bool,
                               referenceDirectory: String, tolerance: CGFloat,
                               filename: String) -> Bool {

        let testName = parseFilename(filename: filename)
        let snapshotController: FBSnapshotTestController = FBSnapshotTestController(testName: testName)
        snapshotController.isDeviceAgnostic = isDeviceAgnostic
        snapshotController.recordMode = record
        snapshotController.referenceImagesDirectory = referenceDirectory
        snapshotController.usesDrawViewHierarchyInRect = usesDrawRect

        let reason = "Missing value for referenceImagesDirectory - " +
                     "Call FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)"
        assert(snapshotController.referenceImagesDirectory != nil, reason)

        do {
            try snapshotController.compareSnapshot(ofViewOrLayer: instance.snapshotObject,
                                                   selector: Selector(snapshot), identifier: nil, tolerance: tolerance)
        } catch let error {
            print(error)
            return false
        }
        return true
    }
}

// Note that these must be lower case.
private var testFolderSuffixes = ["tests", "specs"]

public func setNimbleTestFolder(_ testFolder: String) {
    testFolderSuffixes = [testFolder.lowercased()]
}

public func setNimbleTolerance(_ tolerance: CGFloat) {
    FBSnapshotTest.sharedInstance.tolerance = tolerance
}

func _getDefaultReferenceDirectory(_ sourceFileName: String) -> String {
    if let globalReference = FBSnapshotTest.sharedInstance.referenceImagesDirectory {
        return globalReference
    }

    // Search the test file's path to find the first folder with a test suffix,
    // then append "/ReferenceImages" and use that.

    // Grab the file's path
    let pathComponents = (sourceFileName as NSString).pathComponents as NSArray

    // Find the directory in the path that ends with a test suffix.
    let testPath = pathComponents.first { component -> Bool in
        return !testFolderSuffixes.filter {
            (component as AnyObject).lowercased.hasSuffix($0)
        }.isEmpty
    }

    guard let testDirectory = testPath else {
        fatalError("Could not infer reference image folder – You should provide a reference dir using " +
                   "FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)")
    }

    // Recombine the path components and append our own image directory.
    let currentIndex = pathComponents.index(of: testDirectory) + 1
    let folderPathComponents = pathComponents.subarray(with: NSRange(location: 0, length: currentIndex)) as NSArray
    let folderPath = folderPathComponents.componentsJoined(by: "/")

    return folderPath + "/ReferenceImages"
}

private func parseFilename(filename: String) -> String {
    let nsName = filename as NSString

    let type = ".\(nsName.pathExtension)"
    let sanitizedName = nsName.lastPathComponent.replacingOccurrences(of: type, with: "")

    return sanitizedName
}

func _sanitizedTestName(_ name: String?) -> String {
	guard let testName = currentTestName() else {
		fatalError("Test matchers must be called from inside a test block")
	}

    var filename = name ?? testName
    filename = filename.replacingOccurrences(of: "root example group, ", with: "")
    let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    let components = filename.components(separatedBy: characterSet.inverted)
    return components.joined(separator: "_")
}

func _getTolerance() -> CGFloat {
    return FBSnapshotTest.sharedInstance.tolerance
}

func _clearFailureMessage(_ failureMessage: FailureMessage) {
    failureMessage.actualValue = nil
    failureMessage.expected = ""
    failureMessage.postfixMessage = ""
    failureMessage.to = ""
}

func _performSnapshotTest(_ name: String?, isDeviceAgnostic: Bool = false, usesDrawRect: Bool = false,
                          actualExpression: Expression<Snapshotable>, failureMessage: FailureMessage,
                          tolerance: CGFloat?) -> Bool {
    // swiftlint:disable:next force_try force_unwrapping
    let instance = try! actualExpression.evaluate()!
    let testFileLocation = actualExpression.location.file
    let referenceImageDirectory = _getDefaultReferenceDirectory(testFileLocation)
    let snapshotName = _sanitizedTestName(name) + "_iOS\(osMajorVersion)"
    let tolerance = tolerance ?? _getTolerance()

    let result = FBSnapshotTest.compareSnapshot(instance, isDeviceAgnostic: isDeviceAgnostic,
                                                usesDrawRect: usesDrawRect, snapshot: snapshotName, record: false,
                                                referenceDirectory: referenceImageDirectory, tolerance: tolerance,
                                                filename: actualExpression.location.file)

    if !result {
        _clearFailureMessage(failureMessage)
        failureMessage.expected = "expected a matching snapshot in \(snapshotName)"
    }

    return result
}

let osMajorVersion = String(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)

func _recordSnapshot(_ name: String?, isDeviceAgnostic: Bool = false, usesDrawRect: Bool = false,
                     actualExpression: Expression<Snapshotable>, failureMessage: FailureMessage) -> Bool {
    // swiftlint:disable:next force_try force_unwrapping
    let instance = try! actualExpression.evaluate()!
    let testFileLocation = actualExpression.location.file
    let referenceImageDirectory = _getDefaultReferenceDirectory(testFileLocation)
    
    let snapshotName = _sanitizedTestName(name) + "_iOS\(osMajorVersion)"
    let tolerance = _getTolerance()

    _clearFailureMessage(failureMessage)

    if FBSnapshotTest.compareSnapshot(instance, isDeviceAgnostic: isDeviceAgnostic, usesDrawRect: usesDrawRect,
                                      snapshot: snapshotName, record: true, referenceDirectory: referenceImageDirectory,
                                      tolerance: tolerance, filename: actualExpression.location.file) {
        let name = name ?? snapshotName
        failureMessage.expected = "snapshot \(name) successfully recorded, replace recordSnapshot with a check"
    } else {
        let expectedMessage: String
        if let name = name {
            expectedMessage = "expected to record a snapshot in \(name)"
        } else {
            expectedMessage = "expected to record a snapshot"
        }
        failureMessage.expected = expectedMessage
    }

    return false
}

private func currentTestName() -> String? {
    if let quickExample = FBSnapshotTest.sharedInstance.currentExampleMetadata {
        return quickExample.example.name
    }

    if let testCase = CurrentTestCaseTracker.shared.currentTestCase {
        let characterSet = CharacterSet(charactersIn: "[]+-")
        return testCase.name?.components(separatedBy: characterSet).joined()
    }

    return nil
}

internal var switchChecksWithRecords = false

public func haveValidSnapshot(named name: String? = nil, usesDrawRect: Bool = false,
                              tolerance: CGFloat? = nil) -> MatcherFunc<Snapshotable> {

    return MatcherFunc { actualExpression, failureMessage in
        if switchChecksWithRecords {
            return _recordSnapshot(name, usesDrawRect: usesDrawRect, actualExpression: actualExpression,
                                   failureMessage: failureMessage)
        }

        return _performSnapshotTest(name, usesDrawRect: usesDrawRect, actualExpression: actualExpression,
                                    failureMessage: failureMessage, tolerance: tolerance)
    }
}

public func haveValidDeviceAgnosticSnapshot(named name: String? = nil, usesDrawRect: Bool = false,
                                            tolerance: CGFloat? = nil) -> MatcherFunc<Snapshotable> {

    return MatcherFunc { actualExpression, failureMessage in
        if switchChecksWithRecords {
            return _recordSnapshot(name, isDeviceAgnostic: true, usesDrawRect: usesDrawRect,
                                   actualExpression: actualExpression, failureMessage: failureMessage)
        }

        return _performSnapshotTest(name, isDeviceAgnostic: true, usesDrawRect: usesDrawRect,
                                    actualExpression: actualExpression,
                                    failureMessage: failureMessage, tolerance: tolerance)
    }
}

public func recordSnapshot(named name: String? = nil, usesDrawRect: Bool = false) -> MatcherFunc<Snapshotable> {

    return MatcherFunc { actualExpression, failureMessage in
        return _recordSnapshot(name, usesDrawRect: usesDrawRect,
                               actualExpression: actualExpression, failureMessage: failureMessage)
    }
}

public func recordDeviceAgnosticSnapshot(named name: String? = nil,
                                         usesDrawRect: Bool = false) -> MatcherFunc<Snapshotable> {

    return MatcherFunc { actualExpression, failureMessage in
        return _recordSnapshot(name, isDeviceAgnostic: true, usesDrawRect: usesDrawRect,
                               actualExpression: actualExpression, failureMessage: failureMessage)
    }
}
