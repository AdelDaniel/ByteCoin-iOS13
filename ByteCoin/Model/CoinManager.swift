//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

/// Create the delegate at the same file that use that delegate
/// With the same name + Delegate
protocol CoinManagerDelegate {
    //Create the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdateCoinPrice(_ coinManager: CoinManager, price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    var selectedCurrency: String = "USD"
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "YOUR_API_KEY_HERE"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    mutating func getCoinPrice(for currency: String){
        let stringUrl = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        selectedCurrency = currency
        performRequest(stringUrl: stringUrl)
        print(stringUrl)
    }
    
    func performRequest(stringUrl: String) {
        /// 1. Create a URL
        if let url = URL(string: stringUrl) {
            
            /// 2. Create a URL Session
            let session = URLSession(configuration: .default)
            
            /// 3. Create a Data Task
            let task = session.dataTask(with: url, completionHandler: _handler)
            
            /// 4. Start Task
            task.resume()
        }
    }
    
    func _handler(data: Data?, response: URLResponse?, error: Error?) -> Void{
        /// 5. Check Error
        if error != nil {
            delegate?.didFailWithError(error: error!)
            print(error!)
            return
        }
        
        
        /// 6. Check Data And Parse
        if let data = data {
            print(data)
            if let price = parseJSON(data){
                //Optional: round the price down to 2 decimal places.
                let priceString = String(format: "%.2f", price)
                
                //Call the delegate method in the delegate (ViewController) and
                //pass along the necessary data.
                self.delegate?.didUpdateCoinPrice(self, price: priceString, currency: selectedCurrency)
            }
        }
        
    }
    
    
    func parseJSON(_ data: Data) -> Double? {
        
        //Create a JSONDecoder
        let decoder = JSONDecoder()
        do {
            //try to decode the data using the CoinData structure
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            //Get the last property from the decoded data.
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            //Catch and print any errors.
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    
    
}
