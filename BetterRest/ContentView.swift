//
//  ContentView.swift
//  BetterRest
//
//  Created by Oliver Delaney on 9/20/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var calculatedSleep: String {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch {
            return "Error!"
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section(header: Text("Desired amount of sleep")) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffee intake")) {
                    Picker("Cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            if $0 == 1 {
                                Text("1 cup")
                            } else {
                                Text("\($0) cups")
                            }
                        }
                    }
                }
                
                Section(header: Text("Ideal Sleeping Time")) {
                    Text(calculatedSleep)
                }
            }
            .navigationBarTitle("BetterRest")
        }
    }
    func calculateBedtime() {
                    do {
                        let config = MLModelConfiguration()
                        let model = try SleepCalculator(configuration: config)
                        
                        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                        let hour = (components.hour ?? 0) * 3600
                        let minute = (components.minute ?? 0) * 60
                        
                        let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                        
                        let sleepTime = wakeUp - prediction.actualSleep
                        alertTitle = "Your ideal bedtime is..."
                        alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
                    } catch {
                        alertTitle = "Error"
                        alertMessage = "Sorry, there was a problem calculating your bedtime."
                    }
        
                showingAlert = true
                }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }


