import SwiftUI

struct DeveloperInfoView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Image(systemName: "tv.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.cyan)
                    .padding()
                    .liquidGlass()

                Text("تطبيق Tvclass")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)

                Text("تطبيق سينمائي لعرض الأفلام والمسلسلات بأحدث التقنيات والتأثيرات الزجاجية.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                VStack(spacing: 15) {
                    LinkButton(title: "الموقع الرسمي", icon: "globe", url: "https://example.com")
                    LinkButton(title: "تليجرام المطور", icon: "paperplane.fill", url: "https://t.me")
                    LinkButton(title: "حساب GitHub", icon: "code", url: "https://github.com")
                }
                .padding()
                .liquidGlass()
            }
            .padding()
        }
    }
}

struct LinkButton: View {
    let title: String
    let icon: String
    let url: String

    var body: some View {
        Button(action: {
            if let link = URL(string: url) { UIApplication.shared.open(link) }
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}
