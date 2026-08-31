import SwiftUI
import WebKit

struct NativeWebPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        // استخدام UserAgent نظامي لتجاوز الحظر وتشغيل الـ iframe بسلاسة
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct NativeWebPlayer: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            NativeWebPlayerView(url: url)
                .ignoresSafeArea()

            // زر إغلاق مرن واضح
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("إغلاق")
                        .font(.caption).bold()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.7))
                .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.5), radius: 10)
            }
            .padding(.top, 40)
            .padding(.trailing, 20)
        }
        .statusBarHidden(true)
    }
}
