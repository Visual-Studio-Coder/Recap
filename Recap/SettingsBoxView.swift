import SwiftUI

struct SettingsBoxView: View {
    var icon: String
    var color: Color

    var body: some View {
        Image(systemName: icon)
            .font(.callout) // Adjust font size if needed
            .foregroundStyle(.white)
            .frame(width: 30, height: 30) // Consistent size
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7)) // Rounded corners
    }
}

#Preview {
    SettingsBoxView(icon: "gearshape.fill", color: .gray)
}
