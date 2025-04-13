import SwiftUI

struct ThresholdEditor: View {
    @Binding var threshold: Double
    let title: String
    let description: String
    let iconName: String
    let color: Color
    
    @State private var isEditing = false
    @State private var tempValue: Double
    
    // Initialize state with the initial binding value
    init(threshold: Binding<Double>, title: String, description: String, iconName: String, color: Color) {
        self._threshold = threshold
        self.title = title
        self.description = description
        self.iconName = iconName
        self.color = color
        self._tempValue = State(initialValue: threshold.wrappedValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with icon and title
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(String(format: "%.1f", threshold))¢")
                    .foregroundColor(.secondary)
            }
            
            // Description text
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Slider for adjusting threshold
            HStack {
                Slider(
                    value: isEditing ? $tempValue : $threshold,
                    in: 0...20,
                    step: 0.1
                ) { editing in
                    isEditing = editing
                    if !editing {
                        threshold = tempValue
                    }
                }
                .accentColor(color)
                
                // Button to show number input
                Button(action: {
                    // Show alert with text field for precise input
                    tempValue = threshold
                    isEditing = true
                }) {
                    Image(systemName: "keyboard")
                        .foregroundColor(.secondary)
                }
                .sheet(isPresented: $isEditing) {
                    NumberInputView(value: $tempValue, color: color, onDone: {
                        threshold = tempValue
                        isEditing = false
                    })
                }
            }
            
            // Visual indicator of current threshold level
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .frame(height: 4)
                        .foregroundColor(Color.gray.opacity(0.2))
                        .cornerRadius(2)
                    
                    // Filled portion
                    Rectangle()
                        .frame(width: CGFloat(threshold / 20) * geometry.size.width, height: 4)
                        .foregroundColor(color)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 8)
    }
}

// View for precise number input
struct NumberInputView: View {
    @Binding var value: Double
    let color: Color
    let onDone: () -> Void
    
    @State private var stringValue: String
    @Environment(\.presentationMode) var presentationMode
    
    init(value: Binding<Double>, color: Color, onDone: @escaping () -> Void) {
        self._value = value
        self.color = color
        self.onDone = onDone
        self._stringValue = State(initialValue: String(format: "%.1f", value.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter value", text: $stringValue)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding()
                
                // Value preview
                HStack {
                    Text("Current value:")
                    Spacer()
                    Text("\(formatValue())¢")
                        .foregroundColor(color)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Set Threshold")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    saveValue()
                    onDone()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // Format the display value
    private func formatValue() -> String {
        if let number = Double(stringValue) {
            return String(format: "%.1f", number)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    // Save the value
    private func saveValue() {
        if let number = Double(stringValue) {
            // Clamp the value between 0 and 20
            value = max(0, min(number, 20))
        }
    }
}

struct ThresholdEditor_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ThresholdEditor(
                threshold: .constant(10.0),
                title: "High Price Threshold",
                description: "Get notified when price exceeds this value",
                iconName: "arrow.up.circle.fill",
                color: .red
            )
            
            ThresholdEditor(
                threshold: .constant(2.0),
                title: "Low Price Threshold",
                description: "Get notified when price falls below this value",
                iconName: "arrow.down.circle.fill",
                color: .green
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}