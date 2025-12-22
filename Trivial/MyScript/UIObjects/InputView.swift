import UIKit

// Selects how touch input is interpreted as pen or finger input.
enum InputMode: Int {
    case forcePen
    case forceTouch
    case auto
}

// Turns touch events into MyScript pointer events.
final class InputView: UIView {
    // Receives pointer events.
    weak var editor: IINKEditor?

    // Stores tool state for later extensions.
    weak var toolController: IINKToolController?

    // Controls the pointer type mapping.
    var inputMode: InputMode = .auto

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Keeps the overlay transparent.
        isOpaque = false
        backgroundColor = .clear

        // Allows multi-touch pointer streams.
        isMultipleTouchEnabled = true
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("🖐 InputView.touchesBegan: \(touches.count) touch(es), editor=\(editor != nil ? "YES" : "NO")")
        // Sends pointer down events for new touches.
        forward(touches: touches, with: event, eventType: .down)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("🖐 InputView.touchesMoved: \(touches.count) touch(es)")
        // Sends pointer move events for touch updates.
        forward(touches: touches, with: event, eventType: .move)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("🖐 InputView.touchesEnded: \(touches.count) touch(es)")
        // Sends pointer up events when touches end.
        forward(touches: touches, with: event, eventType: .up)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("🖐 InputView.touchesCancelled: \(touches.count) touch(es)")
        // Cancels the current pointer sequence in the editor.
        do { 
            try editor?.pointerCancel(0)
            print("✅ InputView: pointerCancel succeeded")
        } catch {
            print("❌ InputView: pointerCancel failed: \(error)")
        }
    }

    private func forward(touches: Set<UITouch>, with event: UIEvent?, eventType: IINKPointerEventType) {
        // Requires a live editor instance.
        guard let editor else { 
            print("❌ InputView.forward: No editor available, dropping \(eventType) event")
            return 
        }

        print("📤 InputView.forward: eventType=\(eventType), touches=\(touches.count)")

        // Prefers coalesced touches for smoother ink.
        let allTouches: [UITouch]
        if let event, let first = touches.first, let coalesced = event.coalescedTouches(for: first) {
            allTouches = coalesced
            print("📤 InputView: Using \(coalesced.count) coalesced touches")
        } else {
            allTouches = Array(touches)
            print("📤 InputView: Using \(touches.count) regular touches")
        }

        // Builds a contiguous pointer event buffer for the editor call.
        var events = [IINKPointerEvent]()
        events.reserveCapacity(allTouches.count)

        for t in allTouches {
            // Converts a touch location into view coordinates.
            let p = t.location(in: self)

            // Maps the UIKit touch into a MyScript pointer type.
            let type = mapPointerType(t)

            // Uses a stable id derived from the touch object identity.
            // Truncates the 64-bit hash to 32 bits to fit in Int32.
            let pointerId = Int32(bitPattern: UInt32(truncatingIfNeeded: t.hash))

            // Converts seconds into milliseconds.
            let timestampMs = Int64(t.timestamp * 1000.0)

            // Sets pressure only for pencil touches.
            let pressure = Float(t.type == .pencil ? max(0.001, t.force) : 0.0)

            print("📤 InputView: Creating pointer event - type=\(type), point=(\(p.x), \(p.y)), pressure=\(pressure), id=\(pointerId)")

            // Creates the pointer event struct expected by the SDK.
            let pe = IINKPointerEventMake(eventType, p, timestampMs, pressure, type, pointerId)
            events.append(pe)
        }

        print("📤 InputView: Sending \(events.count) pointer events to editor")

        // Sends the pointer event batch into the editor.
        do {
            try events.withUnsafeMutableBufferPointer { buf in
                guard let base = buf.baseAddress else { 
                    print("❌ InputView: No buffer base address")
                    return 
                }
                let result = try editor.pointerEvents(base, count: Int(buf.count), doProcessGestures: true)
                print("✅ InputView: pointerEvents succeeded, result=\(result)")
            }
        } catch {
            print("❌ InputView: pointerEvents failed: \(error)")
        }
    }

    private func mapPointerType(_ touch: UITouch) -> IINKPointerType {
        // Selects the pointer type based on the configured input mode.
        let type: IINKPointerType
        switch inputMode {
        case .forcePen:
            type = .pen
        case .forceTouch:
            type = .touch
        case .auto:
            type = (touch.type == .pencil) ? .pen : .touch
        }
        print("🖐 InputView.mapPointerType: touch.type=\(touch.type), inputMode=\(inputMode), mapped=\(type)")
        return type
    }
}