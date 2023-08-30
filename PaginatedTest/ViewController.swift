//
//  ViewController.swift
//  PaginatedTest
//
//  Created by Jotno on 8/30/23.
//

import UIKit

class ViewController: UIViewController {

    var beerNames : [BeerModel] = []
    var currentPage = 1
    var isLoading = false
        
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchItems(page: currentPage)
        // Do any additional setup after loading the view.
    }
    
    func fetchItems(page: Int){
        
        
        guard !isLoading else { return }
        isLoading = true
        
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)&per_page=25") else{
            return
        }

        let session = URLSession(configuration: .default)
        
        loadingIndicator.startAnimating()

        let task = session.dataTask(with: url) { data, response, error in

            if error != nil {
                print("Got error \(error!)")
                return
            }



            if let safeData = data{

                let decoder  =  JSONDecoder()

                do {
                    let decodedData = try decoder.decode([BeerModel].self, from: safeData)

                    self.beerNames.append(contentsOf: decodedData)

                    DispatchQueue.main.async {
                                           self.tableView.reloadData()
                                           self.loadingIndicator.stopAnimating()
                                           self.isLoading = false
                        
                                       }

                } catch  {
                    print("Could Not Decode")
                }
            }
        }

        task.resume()
        
        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data {
//                do {
//                    let decoder = JSONDecoder()
//                    let newItems = try decoder.decode([BeerModel].self, from: data)
//                    self.beerNames.append(contentsOf: newItems)
//
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.isLoading = false
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//        }.resume()
        
        
        
        
        
        
    }
}


extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let name = "\(beerNames[indexPath.row].id) . \(beerNames[indexPath.row].name)"
        
        cell.textLabel?.text = name
        
        return cell
        
    }
    
}

extension ViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = beerNames.count - 1
        if currentPage <= 13 {
            if indexPath.row == lastItem && !isLoading {
                currentPage += 1
                fetchItems(page: currentPage)
            }
        }else{
            loadingIndicator.isHidden = true
        }
    }
    
}

