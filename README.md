# ScenarioDemo

A Swift-based Xcode demo project that explores information architecture and techniques for displaying large volumes of data. The design was shaped by research and user interviews, with continuous iteration based on feedback. The primary goal is to enhance situational awareness through intuitive, data-driven interactions.

---

## 📦 Clone the Repository

To get started, clone the repository using:

```bash
git clone https://github.com/chanceadrian/ScenarioDemo.git
```

## 👥 Access

This project is intended for use by a select group of 3 team members with authorized access. Make sure you're on the access list before proceeding.

- John Karasinski
- Megan Parisi
- Katie McTigue

## 🚀 Running the Project

1. Open `ScenarioDemo.xcodeproj` in Xcode
2. Select your preferred simulator or device
3. Click Run (▶️) in Xcode

No additional setup is required.

## ✨ Features

- **Chart Interaction**: Filter data, drag finger to see exact data points, sync multiple graphs with hold and drag gesture
- **Time Simulation**: All time-based components can be reset by hitting the reset button, so that we can get some realism by timeboxing the scenario to 52 minutes

## 🧩 Requirements

- macOS with Xcode installed (recommended: Xcode 14 or newer)
- Familiarity with Combine and Swift Charts

## 📱 Project Structure

```
ScenarioDemo/
├── ScenarioDemo.xcodeproj
├── README.md
├── ScenarioDemo/
│   ├── Effects/
│   │   └── MeshGradient
│   ├── Tabs/
│   │   ├── Affected Systems/
│   │   │   ├── Power System/
│   │   │   │   ├── PowerSystem
│   │   │   │   └── PowerSystemChartView
│   │   │   ├── Transit Phase/
│   │   │   │   └── TransitPhase
│   │   │   └── Water Purifier/
│   │   │       ├── WaterChart
│   │   │       ├── WaterPurifier
│   │   │       ├── AffectedSystems
│   │   │       └── ChartComponents
│   │   ├── Summary/
│   │   └── Sub Views/
│   │       ├── ActionsAndCommView
│   │       ├── NextEffect
│   │       ├── SummaryHeader
│   │       ├── Timeline
│   │       ├── TimerView
│   │       └── Summary
│   ├── Assets/
│   │   ├── ContentView
│   │   ├── NasaLogo
│   │   └── ScenarioDemoApp
│   └── Timer Watch App/
│       ├── Assets/
│       │   └── ContentView
│       └── TimerApp
```

## 🎯 Design Philosophy

The project emphasizes:
- **User-Centered Design**: Built from research and user feedback
- **Information Architecture**: Optimized for large data visualization
- **Situational Awareness**: Intuitive data-driven interactions
- **Iterative Development**: Continuous improvement based on user testing

## 🛠 Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **Swift Charts**: Native charting and data visualization
- **Combine**: Reactive programming for data flow
- **Xcode**: Development environment

## 📊 Data Visualization Features

- Interactive multi-touch gestures
- Real-time data filtering and manipulation
- Synchronized chart interactions
- Time-based scenario simulation
- Responsive design for various screen sizes

## 🔄 Time Simulation

The demo includes a 52-minute scenario simulation that can be:
- Started and stopped at any time
- Reset to beginning state
- Used to demonstrate real-world data patterns
- Synchronized across all chart components

## 📝 Usage Notes

- Ensure you have the latest version of Xcode for optimal compatibility
- The project is optimized for iOS devices and simulators 
- Touch interactions work best on physical devices
- Charts are designed to handle large datasets efficiently

## 🤝 Contributing

This is a demo project for authorized team members. For questions or suggestions:
1. Review the existing codebase
2. Test thoroughly on multiple devices
3. Document any changes or improvements
4. Coordinate with other team members before major modifications

## 📄 License

This project is for internal demonstration purposes only. Access is restricted to authorized team members.
