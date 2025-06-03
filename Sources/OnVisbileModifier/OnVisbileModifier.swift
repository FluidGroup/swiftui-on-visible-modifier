import SwiftUI


extension View {
  
  /**
   Triggers given cloosure when the view becomes visbile on the screen.
   
   Triggers only once when the view becomes visible during its lifecycle.
   */
  public func onVisible(_ handler: @escaping () -> Void) -> some View {
    modifier(OnVisibleWrapperModifier(onVisible: handler))
  }
  
}

public struct OnVisibleTrigger: Equatable {
  private var count: UInt64 = 0
  
  mutating func send() {
    count &+= 1
  }
}

private struct OnVisibleWrapperModifier: ViewModifier {
  
  private let onVisible: () -> Void
  
  @State private var trigger = OnVisibleTrigger()
  
  public init(onVisible: @escaping () -> Void) {
    self.onVisible = onVisible
  }
  
  func body(content: Content) -> some View {
    content
      .modifier(OnVisibleModifier(trigger: $trigger))
      .onChange(of: trigger) { _ in
        onVisible()
      }
  }
}

public struct OnVisibleModifier: ViewModifier {
  
  @Binding var trigger: OnVisibleTrigger
  
  public init(trigger: Binding<OnVisibleTrigger>) {
    self._trigger = trigger
  }
  
  public func body(content: Content) -> some View {
    content
      .overlay(
        TiledLayerViewRepresentation(onDraw: { 
          trigger.send()
        })
        .frame(width: 1, height: 1)
        .allowsHitTesting(false)
      )
  }
}

private struct TiledLayerViewRepresentation: UIViewRepresentable {
  
  let onDraw: @MainActor () -> Void
  
  func makeUIView(context: Context) -> TiledLayerView {
    let view = TiledLayerView()
    view.setOnDraw(onDraw)
    return view
  }
  
  func updateUIView(_ uiView: TiledLayerView, context: Context) {
    uiView.setOnDraw(onDraw)
  }
}


private final class TiledLayerView: UIView {
  
  override class var layerClass: AnyClass {
    TiledLayer.self
  }
  
  init() {
    super.init(frame: .zero)
    
    isOpaque = false
    backgroundColor = .clear
    
    (layer as! TiledLayer).drawsAsynchronously = true
  }
  
  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    
    let view = super.hitTest(point, with: event)
    
    if view == self {
      
      return nil
    }
    return view
  }
  
  func setOnDraw(_ closure: @escaping @MainActor () -> Void) {
    (layer as! TiledLayer).onDraw = closure
  }
}

private final class TiledLayer: CATiledLayer {
  
  var onDraw: @MainActor () -> Void = {}
  
  override class func fadeDuration() -> CFTimeInterval {
    0
  }
  
  override func draw(in ctx: CGContext) {
    if Thread.isMainThread {
      MainActor.assumeIsolated { [onDraw] in
        onDraw()
      }
    } else {
      DispatchQueue.main.async(execute: onDraw)
    }
  }
}

#Preview("ScrollView") {
    
  struct _Book: View {
    
    @State var trigger = OnVisibleTrigger()
    
    var body: some View {    
      ScrollView {
        VStack {
          Text("Scroll down")
          Spacer(minLength: 1000)
          Text("Hello, World!")
            .onVisible {
              print("Visble")
            }
        }
       
      }
    }
  }
  
  return _Book()
}

#Preview("List") {
    
  struct _Book: View {
    
    @State var trigger = OnVisibleTrigger()
    
    var body: some View {    
      List {
        Text("Scroll down")
        ForEach(0..<100) { i in
          Text("Item \(i)")
            .onVisible {
              print("Item \(i) is visible")
            }
        }
        Text("Hello, World!")
          .onVisible {
            print("Visble")
          }
      }
    }
  }
  
  return _Book()
}


