//
//  APICaller.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 12.04.2021.
//

import Foundation
final class APICaller {
    static let shared = APICaller()
    
    private init(){ }
    struct Constant {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    // Category
    public func getCategories(completion : @escaping ((Result<[Category],Error>)-> Void)){
        createRequest(with: URL(string: Constant.baseAPIURL + "/browse/categories?limit=50"), type: .GET, completion: {request in
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data,_,error in
                guard let data = data , error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
              
                    completion(.success(result.categories.items))
                }catch{
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
            
        })
    }
    //Playlist
    public func getCategoryPlaylist(categories : Category,completion : @escaping ((Result<[Playlist],Error>)-> Void)){
        createRequest(with: URL(string: Constant.baseAPIURL + "/browse/categories/\(categories.id)/playlists?limit=20"), type: .GET, completion: {request in
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data,_,error in
                guard let data = data , error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(CategoryPLayListResponsive.self, from: data)
           
                    completion(.success(result.playlists.items))
                }catch{
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
            
        })
    }
    
    enum APIError : Error {
        case failedToGetData
    }
    //Albums
    
    public func getAlbumDetails(for album : Album , completion : @escaping (Result<AlbumDetailsResponse,Error>)-> Void){
        createRequest(with: URL(string: Constant.baseAPIURL + "/albums/" + album.id), type: .GET, completion: { request in
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data , _ , error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                    
                }
                do{
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
              
                    completion(.success(result))
                }catch{
                    print(error.localizedDescription)
                }
                
                
            })
            task.resume()
            
        })
                                                                            
  }
    public func getCurrentUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(
            with: URL(string: Constant.baseAPIURL + "/me/albums"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(LibraryAlbumResponse.self, from: data)
                    completion(.success(result.items.compactMap({ $0.album })))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func saveAlbum(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(
            with: URL(string: Constant.baseAPIURL + "/me/albums?ids=\(album.id)"),
            type: .PUT
        ) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let code = (response as? HTTPURLResponse)?.statusCode,
                      error == nil else {
                    completion(false)
                    return
                }
                print(code)
                completion(code == 200)
            }
            task.resume()
        }
    }
    
    //Playlist
    public func getPlaylistDetails(for playlist : Playlist , completion : @escaping (Result<PlaylistDetailsResponse,Error>)-> Void){
        createRequest(with: URL(string: Constant.baseAPIURL + "/playlists/" + playlist.id), type: .GET, completion: { request in
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data , _ , error in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                    
                }
                do{
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                  
                    completion(.success(result))
                }catch{
                    print(error.localizedDescription)
                }
                
                
            })
            task.resume()
            
        })
                                                                            
  }
    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(
            with: URL(string: Constant.baseAPIURL + "/me/playlists/?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(LibraryPlaylistResponse.self, from: data)
                    completion(.success(result.items))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
        getCurrentProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constant.baseAPIURL + "/users/\(profile.id)/playlists"
                print(urlString)
                self?.createRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    print("Starting creation...")
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }

                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                completion(true)
                            }
                            else {
                                completion(false)
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                            completion(false)
                        }
                    }
                    task.resume()
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    public func addTrackToPlaylist(
        track: AudioTracks,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        createRequest(
            with: URL(string: Constant.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
            type: .POST
        ) { baseRequest in
            var request = baseRequest
            let json = [
                "uris": [
                    "spotify:track:\(track.id)"
                ]
            ]
            print(json)
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            print("Adding...")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(false)
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                      
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                }
            }
            task.resume()
        }
    }

    public func removeTrackFromPlaylist(
        track: AudioTracks,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        createRequest(
            with: URL(string: Constant.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
            type: .DELETE
        ) { baseRequest in
            var request = baseRequest
            let json: [String: Any] = [
                "tracks": [
                    [
                        "uri": "spotify:track:\(track.id)"
                    ]
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(false)
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                }
            }
            task.resume()
        }
    }
    //Profile
    
    public func getCurrentProfile(completion : @escaping (Result<UserProfile,Error>)->Void) {
        createRequest(with: URL(string: Constant.baseAPIURL + "/me"),
                      type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                  
                }catch {
                    print("\(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
   
    public func getNewReleases(completion : @escaping ((Result<NewReleasesResponsive,Error>)->Void)){
        createRequest(with: URL(string: Constant.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET, completion: {request in
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data,_, error in
               
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
               
                do{
                    
                    let result = try JSONDecoder().decode(NewReleasesResponsive.self, from: data)
                    
                    completion(.success(result))
                   
                    
                    
                }catch{
                   
                    completion(.failure(APIError.failedToGetData))
                }
            })
            task.resume()
        })
    }
    public func getFeaturedPlayList(completion :@escaping ((Result<FeaturesPLayListResponsive,Error>)-> Void)){
        createRequest(with: URL(string: Constant.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET, completion: { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(FeaturesPLayListResponsive.self, from: data)
                    
                    completion(.success(result))
                    
                }catch{
                    print("\(error)")
                }
            }
            task.resume()
        })
                                                  
 }
    public func getRecomendations(genres:Set<String>, completion :@escaping ((Result<RecommendationsResponse,Error>)-> Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constant.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET, completion: { request in
           
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data) //JSONSerialization.jsonObject(with: data, options: .allowFragments)
                      
                  

                    completion(.success(result))

                }catch{
                    print("\(error)")
                }
            }
            task.resume()
        })

 }
    public func getRecommendationGenres(completion : @escaping ((Result<RecommendedGenres,Error>)-> Void)){
        createRequest(with: URL(string: Constant.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET, completion: { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data , error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenres.self, from: data)
                        
                    //print("deneme :\(result)")
                    
                    completion(.success(result))
                    
                }catch{
                    print("\(error)")
                }
            }
            task.resume()
        })
                                                                
   }
    // search
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
         createRequest(
             with: URL(string: Constant.baseAPIURL+"/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
             type: .GET
         ) { request in
             print(request.url?.absoluteString ?? "none")
             let task = URLSession.shared.dataTask(with: request) { data, _, error in
                 guard let data = data, error == nil else {
                     completion(.failure(APIError.failedToGetData))
                     return
                 }

                 do {
                     let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)

                     var searchResults: [SearchResult] = []
                     searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0) }))
                     searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0) }))
                     searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0) }))
                     searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0) }))

                     completion(.success(searchResults))
                 }
                 catch {
                     completion(.failure(error))
                 }
             }
             task.resume()
         }
     }

    
 
    enum HTTPMethod: String {
         case GET
         case PUT
         case POST
         case DELETE
     }
    private func createRequest(with url : URL?,type : HTTPMethod , completion : @escaping (URLRequest)-> Void){
        AuthManager.shared.withValidToken(completion: {token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        })
    }
}
