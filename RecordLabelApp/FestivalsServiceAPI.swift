//
//  FestivalsServiceAPI.swift
//  BandsApp
//
//  Created by Rui Alho on 14/10/20.
//

import Foundation

class FestivalsServiceAPI {
    
    public enum APIServiceError: Error {
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
        case throttle(String)
    }
    
    // Enum Endpoint
    enum Endpoint: String, CaseIterable {
        case festivals = "/api/v1/festivals"
    }
    
    public static let shared = FestivalsServiceAPI()
    private init() {}
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://eacp.energyaustralia.com.au/codingtest")!
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    public func fetchFestivals(from endpoint: Endpoint, result: @escaping (Result<[MusicFestival], APIServiceError>) -> Void) {
        let apiURL = baseURL
            .appendingPathComponent(endpoint.rawValue)
        fetchResources(url: apiURL, completion: result)
    }
    private func fetchResources<T: Decodable>(url: URL, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        guard let url = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: url) { (result) in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                switch statusCode {
                case 200..<299:
                    do {
                        let values = try self.jsonDecoder.decode(T.self, from: data)
                        completion(.success(values))
                    } catch {
                        completion(.failure(.decodeError))
                    }
                case 429:
                    completion(.failure(.throttle(String(data: data, encoding: .utf8) ?? "Unknown Error")))
                default:
                    completion(.failure(.invalidResponse))
                }
            case .failure(_):
                completion(.failure(.apiError))
            }
        }.resume()
    }
}

extension URLSession {
    func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
