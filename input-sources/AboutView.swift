import SwiftUI

struct AboutView: View {
    private static let creditsURL = Bundle.main.url(forResource: "Credits", withExtension: "html")!
    private static var credits: NSAttributedString {
        let str = NSMutableAttributedString(
            html: try! Data(contentsOf: creditsURL),
            baseURL: creditsURL,
            documentAttributes: nil
        )!
        str.addAttribute(.foregroundColor, value: NSColor.textColor, range: NSRange(location: 0, length: str.length))
        return str
    }
    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 16) {
            Image(decorative: "App Icon")
            Text(getString(for: "CFBundleName")).font(Font.headline)
            Text("Version \(getString(for: "CFBundleShortVersionString")) (\(getString(for: "CFBundleVersion")))")
            Text(getString(for: "NSHumanReadableCopyright"))
            ScrollableAttributedText(content: AboutView.credits)
                .frame(width: 350, height: 138)
            HStack {
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://j-f1.github.io/input-sources/privacy")!)
                }) {
                    Text("Privacy Policy")
                }
                Button(action: { NSApp.terminate(nil) }) {
                    Text("Quit")
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(minWidth: 500)
    }

    func getString(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as! String
    }
}

struct ScrollableAttributedText: NSViewRepresentable {
    typealias NSViewType = NSScrollView

    let content: NSAttributedString
    init(content: NSAttributedString) {
        self.content = content
    }

    func makeNSView(context: NSViewRepresentableContext<ScrollableAttributedText>) -> NSViewType {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.borderType = .lineBorder

        let textView = scrollView.documentView as! NSTextView
        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = true

        return scrollView
    }
    
    func updateNSView(_ scrollView: NSViewType, context: NSViewRepresentableContext<ScrollableAttributedText>) {
        (scrollView.documentView as! NSTextView).textStorage?.setAttributedString(content)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
