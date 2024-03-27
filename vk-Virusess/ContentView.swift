import SwiftUI

struct SimulationView: View {
    let groupSize: Int
    let infectionFactor: Int
    let interval: TimeInterval
    
    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    
    @State private var isSick: [Bool]
    
    @State private var timer: Timer?
    
    init(groupSize: Int, infectionFactor: Int, interval: TimeInterval) {
        self.groupSize = groupSize
        self.infectionFactor = infectionFactor
        self.interval = interval
        _isSick = State(initialValue: Array(repeating: false, count: groupSize))
    }
    var body: some View {
        VStack {
            VStack {
                Text("Здоровые: \(isSick.filter { !$0 }.count)")
                Text("Зараженные: \(isSick.filter { $0 }.count)")
            }
            .padding()
            
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 10) {
                    ForEach(0..<groupSize, id: \.self) { index in
                        Circle()
                            .foregroundColor(self.isSick[index] ? .red : .green)
                            .frame(width: 20, height: 20)
                            .gesture(TapGesture(count: 1)
                                        .onEnded {
                                            self.toggleSickness(at: index)
                                        })
                    }
                }
                .padding(20)
                .scaleEffect(self.zoomScale * self.gestureScale)
            }
            .gesture(MagnificationGesture()
                        .updating($gestureScale, body: { (value, gestureScale, _) in
                            gestureScale = value
                        })
                        .onEnded { value in
                            self.zoomScale *= value
                        }
            )
            .navigationTitle("Симуляция")
        }
        .onAppear {
            self.startSimulation()
        }
        .onDisappear {
            self.stopSimulation()
        }
    }
    
    private func startSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.updateInfection()
        }
    }
    
    private func stopSimulation() {
        timer?.invalidate()
    }
    
    private func toggleSickness(at index: Int) {
        isSick[index].toggle()
    }
    
    private func updateInfection() {
        var newSickStatus = isSick
    
        for index in 0..<groupSize {
            if isSick[index] {

                let lowerBound = max(0, index - infectionFactor)
                let upperBound = min(groupSize - 1, index + infectionFactor)
                
                for neighborIndex in lowerBound...upperBound {
                    if !isSick[neighborIndex] {
                        if Double.random(in: 0.0...1.0) <= 0.5 {
                            newSickStatus[neighborIndex] = true
                        }
                    }
                }
            }
        }
        
        isSick = newSickStatus
    }
}

struct ContentView: View {
    @State private var groupSize = ""
    @State private var infectionFactor = ""
    @State private var interval = ""
    @State private var isSimulationStarted = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Количество Человек", text: $groupSize)
                    .padding()
                    .keyboardType(.numberPad)
                TextField("Один заражает", text: $infectionFactor)
                    .padding()
                    .keyboardType(.numberPad)
                TextField("Интервал", text: $interval)
                    .padding()
                    .keyboardType(.numberPad)
                
                NavigationLink(destination: SimulationView(groupSize: Int(groupSize) ?? 0, infectionFactor: Int(infectionFactor) ?? 0, interval: TimeInterval(Int(interval) ?? 1)), isActive: $isSimulationStarted) {
                    EmptyView()
                }
                
                Button(action: {
                    isSimulationStarted = true
                }) {
                    Text("Начать Симуляцию")
                }
                .padding()
            }
            .navigationTitle("Симуляция Вируса ")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

