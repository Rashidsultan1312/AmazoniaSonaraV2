import SwiftUI

struct CanopyConsentPanel: View {
    let resource: URL
    let onSeal: () -> Void
    @State private var ok = false

    var body: some View {
        ZStack {
            Palette.jungleDeep.ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("gate.welcome.title")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.textLight)
                    Text("gate.welcome.subtitle")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.textLight.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)
                }
                .padding(.top, 28)

                CanopyFrame(resource: resource, pristine: true)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Palette.aqua.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 18)

                Button(action: { ok.toggle() }) {
                    HStack(spacing: 12) {
                        Image(systemName: ok ? "leaf.fill" : "leaf")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(ok ? Palette.aqua : Palette.textLight.opacity(0.55))
                        Text("gate.privacy.agree")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Palette.textLight)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Palette.jungleDeep.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Palette.aqua.opacity(0.18), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)

                Button(action: onSeal) {
                    Text("gate.privacy.continue")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.jungleDeep)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Palette.aqua)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!ok)
                .opacity(ok ? 1 : 0.4)
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
            }
        }
        .interactiveDismissDisabled(true)
    }
}
