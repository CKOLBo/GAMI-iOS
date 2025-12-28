import SwiftUI

struct ContentView: View {
    @AppStorage("accessToken") private var accessToken: String = ""
    @State private var isSplashVisible: Bool = true

    var body: some View {
        Group {
            if isSplashVisible {
                NavigationStack {
                    ZStack {
                        VStack(alignment: .center, spacing: 0) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 166, height: 92)
                                .padding(.vertical, 391)
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            isSplashVisible = false
                        }
                    }
                }
            } else {
                if accessToken.isEmpty {
                    NavigationStack {
                        StartView()
                    }
                } else {
                    Group {
                        TabbarView()
                    }
                    .onAppear {
                        print("✅ Showing TabbarView (accessToken not empty)")
                    }
                }
            }
        }
        .onChange(of: accessToken) { newValue in
            print("🔄 ContentView accessToken changed:", newValue.isEmpty ? "EMPTY" : "len=\(newValue.count)")
        }
        .onAppear {
            print("👀 ContentView appear accessToken:", accessToken.isEmpty ? "EMPTY" : "len=\(accessToken.count)")
        }
    }
}

#Preview {
    ContentView()
}
