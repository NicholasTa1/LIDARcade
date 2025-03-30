//
//  DoctorViews.swift
//  LIDARacde
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI

struct DoctorLoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        ZStack {
            SpaceBackgroundView()
            
            VStack(spacing: 25) {
                ArcadeTitle("DOCTOR LOGIN", size: 32)
                    .padding(.top, 40)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .font(.system(.body, design: .monospaced))
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .font(.system(.body, design: .monospaced))
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    // Simple login simulation
                    isLoggedIn = true
                }) {
                    Text("LOGIN")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.8, green: 0.4, blue: 0.9))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isLoggedIn) {
            DoctorDashboardView()
        }
    }
}

struct DoctorDashboardView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Sample patient data
    let patientData = [
        PatientData(name: "John D.", score: 4200, progress: "Improving", lastSession: "Yesterday"),
        PatientData(name: "Mary S.", score: 3800, progress: "Stable", lastSession: "2 days ago"),
        PatientData(name: "Robert K.", score: 2900, progress: "Improving", lastSession: "Today"),
        PatientData(name: "Emily T.", score: 1500, progress: "Needs Review", lastSession: "1 week ago")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                SpaceBackgroundView()
                
                VStack {
                    ArcadeTitle("DOCTOR DASHBOARD", size: 28)
                        .padding(.top, 40)
                    
                    // Patient list
                    List {
                        ForEach(patientData) { patient in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(patient.name)
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundColor(.pink)
                                    
                                    Text("Last: \(patient.lastSession)")
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(patient.score)")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    Text(patient.progress)
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(progressColor(for: patient.progress))
                                }
                            }
                            .listRowBackground(Color(red: 0.3, green: 0.1, blue: 0.5).opacity(0.7))
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("LOGOUT")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func progressColor(for progress: String) -> Color {
        switch progress {
        case "Improving":
            return .green
        case "Stable":
            return .blue
        case "Needs Review":
            return .orange
        default:
            return .white
        }
    }
}

// Model for patient data
struct PatientData: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let progress: String
    let lastSession: String
}
