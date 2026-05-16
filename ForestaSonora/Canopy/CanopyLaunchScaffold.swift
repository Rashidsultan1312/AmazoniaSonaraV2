import SwiftUI

struct CanopyLaunchScaffold<Inner: View>: View {
    @AppStorage("as.canopy.sealed") private var sealed = false
    @State private var motion: Motion = .listening
    @State private var promptOpen = false
    @ViewBuilder var inner: () -> Inner

    var body: some View {
        Group {
            if sealed {
                inner()
            } else {
                switch motion {
                case .listening:
                    ZStack {
                        Palette.jungleDeep.ignoresSafeArea()
                        ProgressView()
                            .tint(Palette.aqua)
                            .scaleEffect(1.4)
                    }
                    .task { await drift() }
                case .leafblown(let url):
                    CanopyFrame(resource: url, pristine: false)
                        .ignoresSafeArea()
                case .promptTrellis:
                    Palette.jungleDeep.ignoresSafeArea()
                        .fullScreenCover(isPresented: $promptOpen) {
                            CanopyConsentPanel(resource: AppConfig.privacyPolicyURL) {
                                sealed = true
                                promptOpen = false
                                motion = .opened
                            }
                        }
                case .opened:
                    inner()
                }
            }
        }
    }

    @MainActor
    private func drift() async {
        async let nap: Void = { try? await Task.sleep(nanoseconds: 1_800_000_000) }()
        async let echo = GladeLedger.listen()
        let answer = await echo
        _ = await nap
        switch answer {
        case .leafblown(let url):
            motion = .leafblown(url)
        case .stillair:
            motion = .promptTrellis
            Task { @MainActor in promptOpen = true }
        case .mute:
            motion = .opened
        }
    }

    private enum Motion: Equatable {
        case listening
        case leafblown(URL)
        case promptTrellis
        case opened
    }
}
