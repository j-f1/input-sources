import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 16) {
            Image(decorative: "App Icon")
            Text(getString(for: "CFBundleName")).font(Font.headline)
            Text("Version \(getString(for: "CFBundleShortVersionString")) (\(getString(for: "CFBundleVersion")))")
            Text(getString(for: "NSHumanReadableCopyright"))
            HStack {
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://j-f1.github.io/input-sources/privacy")!)
                }) {
                    Text("Privacy Policy")
                }
                Button(action: { NSApp!.terminate(nil) }) {
                    Text("Quit")
                }
            }
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
        .frame(minWidth: 500)
    }

    func getString(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as! String
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
