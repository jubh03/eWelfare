//
//  Networking.swift
//  WebEwelfare
//
//  Created by nam yeon hun on 02/01/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

import Moya
import RxSwift

typealias NetworkingService = Networking<API>

final class Networking<Target: TargetType>: MoyaProvider<Target>  {
    
    func request(
        _ target: Target,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
        ) -> Single<Response> {
        let requestString = "\(target.method) \(target.path) \(target.task)"
        return self.rx.request(target)
            .filterSuccessfulStatusCodes()
            .do(
                onSuccess: { value in
                    let message = "SUCCESS: \(requestString) (\(value.statusCode))"
                    print(message,"\n\(file)\n\(function)\n\(line)\n")
            },
                onError: { error in
                    if let response = (error as? MoyaError)?.response {
                        if let jsonObject = try? response.mapJSON(failsOnEmptyData: false) {
                            let message = "FAILURE: \(requestString) (\(response.statusCode))\n\(jsonObject)"
                            print(message,"\n\(file)\n\(function)\n\(line)")
                        } else if let rawString = String(data: response.data, encoding: .utf8) {
                            let message = "FAILURE: \(requestString) (\(response.statusCode))\n\(rawString)"
                            print(message,"\n\(file)\n\(function)\n\(line)")
                        } else {
                            let message = "FAILURE: \(requestString) (\(response.statusCode))"
                            print(message,"\n\(file)\n\(function)\n\(line)")
                        }
                    } else {
                        let message = "FAILURE: \(requestString)\n\(error)"
                        print(message,"\n\(file)\n\(function)\n\(line)")
                    }
            },
                onSubscribed: {
                    let message = "REQUEST: \(requestString)"
                    print(message,"\n\(file)\n\(function)\n\(line)")
            }
        )
    }
    
}
