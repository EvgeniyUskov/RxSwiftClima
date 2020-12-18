//
//  URLRequest + Extension.swift
//  RxSwiftClimaApp
//
//  Created by Evgeniy Uskov on 08.12.2020.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

struct Resource<T> {
    let url: URL
}

extension URLRequest {
    
    static func load<T: Decodable> (resource: Resource<T>) -> Observable<T> {
        return Observable.from([resource.url])
            .flatMap {
                (url) -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }.map{
                data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }.asObservable()
    }
}
