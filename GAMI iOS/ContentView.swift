import SwiftUI

struct ContentView: View {
    @State private var goNext = false

    var body: some View {
        NavigationStack {
            ZStack {
             a   VStack(alignment: .center) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 166, height: 92)
                        .padding(.vertical, 391)

                    Spacer()
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
