import SwiftUI

struct ContentView: View {
    @State private var goNext = false

    var body: some View {
        NavigationStack {
            ZStack {
              VStack(alignment: .center, spacing: 0) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 166, height: 92)
                        .padding(.vertical, 391)
                }

                NavigationLink(
                    "",
                    destination: StartView(),
                    isActive: $goNext
                )
                .hidden()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    goNext = true
                }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
