//
//  NetworkService.swift
//  StortApp
//
//  Created by Николай Игнатов on 20.03.2025.
//


import Foundation

// MARK: - NetworkServiceProtocol
protocol NetworkServiceProtocol {
    func fetchExercises(parameters: ExerciseQueryParameters, completion: @escaping (Result<[ExerciseModel], Error>) -> Void)
}

// MARK: - NetworkError
enum NetworkError: Error {
    case badURL, missingParameters, badResponse, invalidData, decodeError
}

// MARK: - NetworkService
final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://api.api-ninjas.com"
    
    func fetchExercises(parameters: ExerciseQueryParameters, completion: @escaping (Result<[ExerciseModel], Error>) -> Void) {
        guard var components = URLComponents(string: "\(baseURL)/v1/exercises") else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        components.queryItems = parameters.toQueryItems()
        
        guard let url = components.url else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("GjzH6TPla1aQTHkwdGUczA==3XqJrf3rVQjP8stn", forHTTPHeaderField: "X-Api-Key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completion(.failure(NetworkError.badResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode([ExerciseModel].self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(NetworkError.decodeError))
            }
        }.resume()
    }
}
