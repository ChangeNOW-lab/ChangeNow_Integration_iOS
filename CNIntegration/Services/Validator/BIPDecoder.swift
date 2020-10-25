//
//  BIPDecoder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 25.10.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

protocol BIPDecoderService {

    func decode(uri: String) -> String?
}

class BIPDecoderDefaultService: BIPDecoderService {

//    @Injected private var validatorService: ValidatorService

//    private let schemes = ["bitcoin": "btc", "litecoin": "ltc"]

    func decode(uri: String) -> String? {
        let urlComponents = URLComponents(string: uri)
        if let address = urlComponents?.path,
           address.isNotEmpty,
           urlComponents?.scheme != nil {
//            if (try? validatorService.isValid(ticker: ticker, address: address)) == true {
            return address
//            }
        }
        return nil
    }
}
