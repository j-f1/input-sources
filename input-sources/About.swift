import SwiftUI

class AboutViewController: NSHostingController<AboutView> {
    required init?(coder: NSCoder) {
        let creditsURL = Bundle.main.url(forResource: "Credits", withExtension: "html")!
        let credits = NSMutableAttributedString(
            html: try! Data(contentsOf: creditsURL),
            baseURL: creditsURL,
            documentAttributes: nil
        )!
        credits.addAttribute(
            .foregroundColor,
            value: NSColor.textColor,
            range: NSRange(location: 0, length: credits.length)
        )

        let rv = AboutView(credits: credits)
        super.init(coder: coder, rootView: rv)
    }
}

func getString(for key: String) -> String {
    Bundle.main.object(forInfoDictionaryKey: key) as! String
}

struct AboutView: View {
    let credits: NSAttributedString
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(decorative: "App Icon")
            Text(getString(for: "CFBundleName")).font(.headline)
            Text("Version \(getString(for: "CFBundleShortVersionString")) (\(getString(for: "CFBundleVersion")))")
            Text(getString(for: "NSHumanReadableCopyright"))
            ScrollableAttributedText(content: credits)
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
    }
}

struct ScrollableAttributedText: NSViewRepresentable {
    typealias NSViewType = NSScrollView

    let content: NSAttributedString

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
        AboutView(credits: NSAttributedString(string: "hello"))
    }
}
