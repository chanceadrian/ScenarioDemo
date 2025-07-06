import SwiftUI

struct TimerView: View {
    private let totalSeconds: Int = 2912
    private let remainingSeconds: Int = 2912

    var body: some View {
        Text(timeString(from: remainingSeconds))
            .font(.largeTitle)
            .padding()
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
