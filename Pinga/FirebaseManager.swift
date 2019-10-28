//
//  FirebaseManager.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import Firebase

struct Measurement {
    let timestamp: Timestamp;
    let ssid: String;
    let connected: Bool;
    let speed: Double;
}

class FirebaseManager {
    static let db = Firestore.firestore()
    static let measurements = "devices/pinga/entries"
    
    static func setup() {
        FirebaseApp.configure()
        print("Firebase Configurado")
    }
    
    static func transformMeasurements (_ element: QueryDocumentSnapshot) -> Measurement {
        let data = element.data()
        let ts = data["timestamp"] as! Timestamp
        let ssid = data["ssid"] as! String
        let connected = data["connected"] as! Bool
        let speed = (data["speed"] as! Double) + Double.random(in: 1..<400)
        
        return Measurement(timestamp: ts, ssid: ssid, connected: connected, speed: speed)
    }
    
    static func getConnectivityThisWeek(_ callback: @escaping ([Double: Double]) -> ()) {
        let end: Timestamp = Timestamp(date: Date().endOfWeek)
        let start: Timestamp = Timestamp(date: Date().startOfWeek)
        
        print(Date().startOfWeek)
        print(Date().endOfWeek)
        db.collection(measurements)
            .whereField("timestamp", isGreaterThanOrEqualTo: start)
            .whereField("timestamp", isLessThanOrEqualTo: end)
            .limit(to: Int(INT_MAX))
            .getDocuments { (snapshot, err) in
                if err != nil {
                    print("Erro ao buscar as conexões da semana")
                }
                
                let values = snapshot?.documents.map(transformMeasurements(_:))
                let dictValues = Dictionary(grouping: values!, by: { $0.timestamp.dateValue().startOfDay.timeIntervalSince1970 })
                var response: [Double: Double] = [:]
                
                print("Encontrado \(dictValues.keys.count) dias!")
                print("Encontrado \(dictValues.values.count) documentos ou \(snapshot?.count).")

                // Pega qual a porcentagem de registros conectados pra cada dia
                for day in dictValues.keys {
                    response[day] = Double(dictValues[day]!.filter({$0.connected}).count) / max(Double(dictValues[day]!.count), 8540.0)
                }

                callback(response)
        }
    }
    
    static func getConnectivityToday(_ callback: @escaping (Array<Measurement>) -> ()) {
        let start: Timestamp = Timestamp(date: Date().startOfDay)
        let end: Timestamp = Timestamp(date: Date().endOfDay)

        db.collection(measurements)
            .whereField("timestamp", isGreaterThanOrEqualTo: start)
            .whereField("timestamp", isLessThanOrEqualTo: end)
            .getDocuments { (snapshot, err) in
                if err != nil {
                    print("Erro ao buscar as conexões de hoje")
                }
                
                let values = snapshot?.documents.map(transformMeasurements(_:))
                print("Encontrado \(values!.count) documentos.")
                callback(values!)
        }
    }
}
