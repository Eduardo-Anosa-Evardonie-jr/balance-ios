import UIKit
import CoreData
import SwiftEntryKit
import SnapKit

class WatchlistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var managedEthereumWallets = [NSManagedObject]()
    private var ethereumWallets = [EthereumWallet]()
    
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setBackgroundImage(UIImage(named:"plusButton"), for: .normal)
        return addButton
    }()

    private let walletsTableView = UITableView()
    
    // MARK: - View Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#fbfbfb")
        
        walletsTableView.backgroundColor = UIColor(hexString: "#fbfbfb")
        walletsTableView.separatorStyle = .none
        walletsTableView.rowHeight = 119
        walletsTableView.dataSource = self
        walletsTableView.delegate = self
        
        walletsTableView.register(WalletTableViewCell.self, forCellReuseIdentifier: "walletCell")
        view.addSubview(walletsTableView)
        
        walletsTableView.translatesAutoresizingMaskIntoConstraints = false
        walletsTableView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.leading.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view)
        }
        
        setupNavigation()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(walletAdded), name: CoreDataHelper.Notifications.ethereumWalletAdded, object: nil)
    }
    
    private func setupNavigation() {
        navigationItem.title = ""
        navigationItem.titleView = addButton
        addButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
            make.width.equalTo(72)
        }
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = .white
            navigationBar.isTranslucent = false
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }
    
    // MARK: - Button Actions -
    
    @objc private func addAction() {
        let addEthereumWalletViewController = AddEthereumWalletViewController()
        present(addEthereumWalletViewController, animated: true)
    }
    
    // MARK: - Data Loading -
    
    private func loadData() {
        managedEthereumWallets = CoreDataHelper.loadAllEthereumWallets()
        ethereumWallets = [EthereumWallet]()
        if managedEthereumWallets.count > 0 {
            for wallet in managedEthereumWallets {
                let name = wallet.value(forKey: "name") as? String ?? ""
                let address = wallet.value(forKey: "address") as? String ?? ""
                let includeInTotal = wallet.value(forKey: "includeInTotal") as? Bool ?? true
                ethereumWallets.append(EthereumWallet(name: name, address: address, includeInTotal: includeInTotal))
            }
        }
        walletsTableView.reloadData()
    }
    
    @objc private func walletAdded() {
        loadData()
        if presentedViewController != nil {
            dismiss(animated: true)
        }
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethereumWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath) as! WalletTableViewCell
        cell.selectionStyle = .none
        cell.wallet = ethereumWallets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Row: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if CoreDataHelper.delete(managedObject: managedEthereumWallets[indexPath.row]) {
                managedEthereumWallets.remove(at: indexPath.row)
                ethereumWallets.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
