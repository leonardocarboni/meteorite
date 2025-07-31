import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 100))
                    .foregroundColor(.primary)
                    .padding()
                
                Text("Meteorite")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("ML-Powered Photography Composition")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    // Camera view will be implemented here
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Start Photography")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Meteorite")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}