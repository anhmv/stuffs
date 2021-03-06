//
//  ContentView.swift
//  BucketList
//
//  Created by Mac Van Anh on 5/19/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false
    @State private var isUnlocked = false

    var body: some View {
        ZStack {
            if isUnlocked {
                MapView(
                    centerCoordinate: $centerCoordinate,
                    selectedPlace: $selectedPlace,
                    showingPlaceDetails: $showingPlaceDetails,
                    annotations: locations
                )
                    .edgesIgnoringSafeArea(.all)
                
                Circle()
                    .fill(Color.blue)
                    .opacity(0.2)
                    .frame(width: 32, height: 32)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.coordinate = self.centerCoordinate
                            newLocation.title = "Example location"
                            self.locations.append(newLocation)
                            self.selectedPlace = newLocation
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding([.trailing, .bottom])
                    }
                }
                .alert(isPresented: $showingPlaceDetails) {
                    Alert(
                        title: Text(selectedPlace?.title ?? "Unknown"),
                        message: Text(selectedPlace?.subtitle ?? "Missing place information."),
                        primaryButton: .default(Text("OK")),
                        secondaryButton: .default(Text("Edit")) {
                            self.showingEditScreen = true
                        }
                    )
                }
                .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
                    if self.selectedPlace != nil {
                        EditView(placemark: self.selectedPlace!)
                    }
                }
                .onAppear(perform: loadData)
            } else {
                Button("Unlock places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentDirectory().appendingPathComponent("SavedPlaced")
        
        do {
            let data = try Data(contentsOf: filename)
            print(data)
            self.locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("\(error)")
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentDirectory().appendingPathComponent("SavedPlaced")
            let data = try JSONEncoder().encode(self.locations)
            print(data)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,error: &error) {
            let reason = "Please authenticate yourself to unlock your places."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // error
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
