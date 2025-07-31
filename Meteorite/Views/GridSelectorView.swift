import SwiftUI

struct GridSelectorView: View {
    @Binding var selectedComposition: CompositionType
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Current selection button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: selectedComposition.icon)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(selectedComposition.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            }
            
            // Expanded grid options
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(CompositionType.allCases.filter { $0 != selectedComposition }) { composition in
                        Button(action: {
                            selectedComposition = composition
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Image(systemName: composition.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(composition.displayName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text(composition.description)
                                        .font(.caption2)
                                        .opacity(0.8)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: 250)
    }
}

#Preview {
    VStack {
        GridSelectorView(selectedComposition: .constant(.ruleOfThirds))
            .padding()
    }
    .background(Color.gray)
}