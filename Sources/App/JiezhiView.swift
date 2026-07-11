import AppKit
import SwiftUI

struct JiezhiView: View {
    @ObservedObject var model: JiezhiModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.16), radius: 3, y: 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text("止界")
                        .font(.system(size: 28, weight: .semibold))
                    Text("让指针停在你想要的边界")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Toggle("允许指针跨设备", isOn: Binding(
                get: { model.allowsPointerAcrossDevices },
                set: { model.setAllowsPointerAcrossDevices($0) }
            ))
            .toggleStyle(.switch)
            .disabled(model.isWorking)

            if model.isWorking {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("正在应用…").foregroundColor(.secondary)
                }
                .font(.caption)
            } else if let error = model.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                    Text(error).foregroundColor(.red).lineLimit(2)
                }
                .font(.caption)
            }
        }
        .padding(24)
        .frame(width: 340, height: 175, alignment: .topLeading)
    }
}
