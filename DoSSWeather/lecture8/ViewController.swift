//
//  ViewController.swift
//  lecture8
//
//  Created by admin on 08.02.2021.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var citySegment: UISegmentedControl!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var myData: Model?
    
    
    private var decoder: JSONDecoder = JSONDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        tableView.register(TableViewCell.nib, forCellReuseIdentifier: TableViewCell.identifier)
            }
    
    
    func updateUI(){
        temp.text = "\(myData?.current?.temp ?? 0.0) C"
        feelsLikeTemp.text = "\(myData?.current?.feels_like ?? 0.0) C"
        desc.text = myData?.current?.weather?.first?.description
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    func fetchData(){
        let URL = "https://api.openweathermap.org/data/2.5/onecall?lat=\(Constants.lat)&lon=\(Constants.lon)&exclude=minutely,alerts&appid=66c415c790bc5074c51f3d3a8e644146&units=metric"
        AF.request(URL).responseJSON { (response) in
            switch response.result{
            case .success(_):
                guard let data = response.data else { return }
                guard let answer = try? self.decoder.decode(Model.self, from: data)
                else{return}
                    self.myData = answer
                    self.updateUI()
            case .failure(let err):
                print(err.errorDescription ?? "")
            }
        }
    }
    @IBAction func valueChanged(_ sender: Any) {
        switch citySegment.selectedSegmentIndex {
        case 0:
            Constants.lat = "51.1801"
            Constants.lon = "71.446"
        case 1:
            Constants.lat = "43.25654"
            Constants.lon = "76.92848"
        case 2:
            Constants.lat = "49.83"
            Constants.lon = "73.165"
        default:
            break
        }
        
        fetchData()
    }

}
    
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData?.daily?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
        let item = myData?.daily?[indexPath.item]
        cell.tempLabel.text = "\(item?.temp?.day ?? 0.0)"
        cell.feelsLabel.text = "\(item?.feels_like?.day ?? 0.0)"
        cell.descriptionLabel.text = item?.weather?.first?.description
        return cell
    }
    
    
}


extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myData?.hourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        let item = myData?.hourly?[indexPath.item]
        cell.temp.text = "\(item?.temp ?? 0.0)"
        cell.feelsLike.text = "\(item?.feels_like ?? 0.0)"
        cell.desc.text = item?.weather?.first?.description
        return cell

    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}


