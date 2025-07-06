//import SwiftUI
//
//struct TimerView: View {
//    @State private var remainingSeconds: Int = 48 * 60 + 32
//    private let totalSeconds: Int = 48 * 60 + 32
//    @State private var isRunning = false
//    @State private var timer: Timer? = nil
//    
//    var body: some View {
//        VStack {
//            Text(timeString(from: remainingSeconds))
//                .font(.largeTitle)
//                .padding()
//            
//            Button(action: {
//                if isRunning {
//                    stopTimer()
//                } else {
//                    startTimer()
//                }
//            }) {
//                Text(isRunning ? "Pause" : "Start")
//            }
//            .padding()
//        }
//    }
//    
//    private func startTimer() {
//        isRunning = true
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if remainingSeconds > 0 {
//                remainingSeconds -= 1
//            } else {
//                stopTimer()
//            }
//        }
//    }
//    
//    private func stopTimer() {
//        isRunning = false
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    private func timeString(from seconds: Int) -> String {
//        let minutes = seconds / 60
//        let seconds = seconds % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//}
//
//struct TimerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimerView()
//    }
//}
