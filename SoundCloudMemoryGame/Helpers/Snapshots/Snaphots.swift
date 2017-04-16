
import UIKit
import Quick
import Nimble

// Helper functions for snapshot tests

/// Master switch for snapshot tests. If 'true', all snapshots are re-recorded. Use with caution.
private let shouldRecordAllSnapshots = false

private let defaultSnapshotFrame = CGRect(x: 0, y: 0, width: 400, height: 600)

extension UIViewController {
    func prepareForSnapshot() {
        UIView.setAnimationsEnabled(false)
        _ = view
        view.frame = defaultSnapshotFrame
        view.setNeedsLayout()
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}

func compareSnapshot(_ view: UIView, recordReferenceSnapshot: Bool = false, file: FileString = #file, line: UInt = #line) {
    
    setupSnapshotFolder // Ran only once
    
    if shouldRecordAllSnapshots || recordReferenceSnapshot {
        expect(view, file: file, line: line).to(recordSnapshot())
    } else {
        expect(view, file: file, line: line).to(haveValidSnapshot())
    }
}

func createSnapshot(_ view: UIView, file: FileString = #file, line: UInt = #line) {
    compareSnapshot(view, recordReferenceSnapshot: true, file: file, line: line)
}

private let setupSnapshotFolder: Void = {
    guard let folder = getenv("FB_REFERENCE_IMAGE_DIR") else {
        fatalError("FB_REFERENCE_IMAGE_DIR environment variable not defined.")
    }

    FBSnapshotTest.setReferenceImagesDirectory(String(utf8String: folder))
}()
