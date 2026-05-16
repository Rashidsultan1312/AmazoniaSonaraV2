import Foundation
import UIKit
@preconcurrency import WebKit

enum CanopyEcho: Equatable {
    case leafblown(URL)
    case stillair
    case mute
}

enum GladeLedger {
    @MainActor
    static func listen() async -> CanopyEcho {
        await UnderbrushProbe().tap()
    }

    static func trim(_ url: URL) -> String {
        var stem = URLComponents(url: url, resolvingAgainstBaseURL: true) ?? URLComponents()
        stem.fragment = nil
        stem.scheme = (stem.scheme ?? "https").lowercased()
        stem.host = stem.host?.lowercased()
        if stem.path.count > 1, stem.path.hasSuffix("/") { stem.path.removeLast() }
        return stem.url?.absoluteString ?? url.absoluteString.lowercased()
    }
}

@MainActor
final class UnderbrushProbe: NSObject, WKNavigationDelegate {
    private var cont: CheckedContinuation<CanopyEcho, Never>?
    private var pane: WKWebView?
    private var sealed = false
    private var ticker: Task<Void, Never>?

    func tap() async -> CanopyEcho {
        await withCheckedContinuation { box in
            cont = box
            let setup = WKWebViewConfiguration()
            setup.websiteDataStore = .nonPersistent()
            let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 5, height: 5), configuration: setup)
            view.alpha = 0.02
            view.navigationDelegate = self
            view.load(URLRequest(url: AppConfig.canopyAnchor))
            pane = view
            ticker = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 12_000_000_000)
                await MainActor.run { self?.bind(.mute) }
            }
        }
    }

    private func bind(_ echo: CanopyEcho) {
        if sealed { return }
        sealed = true
        ticker?.cancel()
        pane?.navigationDelegate = nil
        pane?.stopLoading()
        pane = nil
        cont?.resume(returning: echo)
        cont = nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let target = navigationAction.request.url else {
            decisionHandler(.allow); return
        }
        let anchor = AppConfig.canopyAnchor
        if GladeLedger.trim(target) != GladeLedger.trim(anchor) {
            decisionHandler(.cancel)
            bind(.leafblown(target))
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard let self = self, !self.sealed else { return }
            self.bind(.stillair)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        _ = error; bind(.mute)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        _ = error; bind(.mute)
    }
}
