# SwiftUI OnVisible Modifier

A SwiftUI modifier that triggers a closure when a view becomes visible on the screen.

## Features

- ✅ Triggers only once when the view becomes visible during its lifecycle
- ✅ Works with ScrollView, List, and other scrollable containers
- ✅ Lightweight implementation using CATiledLayer
- ✅ Thread-safe execution on main queue
- ✅ Easy to use with a simple modifier syntax

## Usage

### Basic Usage

Simply add the `.onVisible` modifier to any SwiftUI view:

```swift
import SwiftUI
import OnVisibleModifier

struct ContentView: View {
  var body: some View {
    ScrollView {
      VStack {
        Text("Scroll down to see the magic!")
        
        Spacer(minLength: 1000)
        
        Text("Hello, World!")
          .onVisible {
            print("This text is now visible!")
            // Perform your action here
          }
      }
    }
  }
}
```

### List Example

Perfect for tracking when list items become visible:

```swift
struct ListView: View {
  var body: some View {
    List {
      ForEach(0..<100) { index in
        Text("Item \(index)")
          .onVisible {
            print("Item \(index) became visible")
            // Track analytics, load data, etc.
          }
      }
    }
  }
}
```

### Use Cases

- **Analytics Tracking**: Track when specific content becomes visible to users

## How It Works

The modifier uses a clever implementation with `CATiledLayer` to detect when a view becomes visible:

1. A tiny (1x1) overlay is added to your view
2. The overlay uses `CATiledLayer` which calls `draw(in:)` when it becomes visible
3. The drawing callback triggers your closure on the main thread
4. The trigger only fires once per view lifecycle

## API Reference

### `onVisible(_:)`

```swift
func onVisible(_ handler: @escaping () -> Void) -> some View
```

**Parameters:**
- `handler`: A closure that will be called when the view becomes visible

**Returns:** A modified view that will trigger the handler when it becomes visible on screen.
