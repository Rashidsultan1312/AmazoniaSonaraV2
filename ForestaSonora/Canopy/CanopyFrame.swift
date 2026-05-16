import SwiftUI
@preconcurrency import WebKit

struct CanopyFrame: View {
    let resource: URL
    var pristine: Bool = true
    @StateObject private var bridge = ProbeBridge()

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                CanopyPane(resource: resource, pristine: pristine, bridge: bridge)
                if bridge.loading && bridge.progress < 1.0 {
                    ProgressView(value: bridge.progress)
                        .progressViewStyle(.linear)
                        .tint(.white)
                }
            }
            HStack(spacing: 0) {
                navButton(systemImage: "chevron.left") { bridge.pane?.goBack() }
                navButton(systemImage: "chevron.right") { bridge.pane?.goForward() }
                navButton(systemImage: "arrow.clockwise") { bridge.pane?.reload() }
                navButton(systemImage: "house.fill") { bridge.pane?.load(URLRequest(url: resource)) }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .top)
    }

    private func navButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.plain)
    }
}

@MainActor
private final class ProbeBridge: ObservableObject {
    @Published var loading = false
    @Published var progress: Double = 0
    weak var pane: WKWebView?
    private var observers: [NSKeyValueObservation] = []

    func attach(_ web: WKWebView) {
        pane = web
        observers = [
            web.observe(\.estimatedProgress, options: [.new]) { [weak self] view, _ in
                Task { @MainActor in self?.progress = view.estimatedProgress }
            },
            web.observe(\.isLoading, options: [.new]) { [weak self] view, _ in
                Task { @MainActor in self?.loading = view.isLoading }
            }
        ]
    }
}

private final class CleanWebView: WKWebView {
    override var inputAccessoryView: UIView? { nil }
}

private struct CanopyPane: UIViewRepresentable {
    let resource: URL
    var pristine: Bool
    var bridge: ProbeBridge

    func makeUIView(context: Context) -> WKWebView {
        let setup = WKWebViewConfiguration()
        setup.allowsInlineMediaPlayback = true
        setup.mediaTypesRequiringUserActionForPlayback = []
        setup.websiteDataStore = pristine ? .nonPersistent() : .default()
        let canvas = CleanWebView(frame: .zero, configuration: setup)
        canvas.allowsBackForwardNavigationGestures = true
        canvas.scrollView.bounces = true
        canvas.load(URLRequest(url: resource))
        DispatchQueue.main.async { bridge.attach(canvas) }
        return canvas
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
