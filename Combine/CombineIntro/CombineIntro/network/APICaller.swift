//
//  APICaller.swift
//  CombineIntro
//
//  Created by Anup Dsouza on 26/07/23.
//

import Foundation
import Combine

class APICaller {
    static let shared = APICaller()
    
    func fetchCompanies() -> Future<[String], Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(["Facebook", "Apple", "Amazon", "Netflix", "Google"]))
            }
        }
    }
}
