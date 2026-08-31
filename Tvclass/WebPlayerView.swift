import SwiftUI
import WebKit

struct WebPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct PlayerContainerView: View {
    let mediaItem: MediaItem
    @Environment(\.dismiss) private var dismiss

    var embedURL: URL {
        // يمكنك تغيير نطاق مشغل الويب المفضل هنا
        let isTV = mediaItem.title == nil
        let typePath = isTV ? "tv" : "movie"
        return URL(string: "https://vidsrc.to/embed/\(typePath)/\(mediaItem.id)") ?? URL(string: "https://google.com")!
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            WebPlayerView(url: embedURL)
                .ignoresSafeArea()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
        }
    }
}
