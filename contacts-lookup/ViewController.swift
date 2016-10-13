
import UIKit
import Contacts

private let charToNumMap = [
    "a": 2,
    "b": 2,
    "c": 2,
    "d": 3,
    "e": 3,
    "f": 3,
    "g": 4,
    "h": 4,
    "i": 4,
    "j": 5,
    "k": 5,
    "l": 5,
    "m": 6,
    "n": 6,
    "o": 6,
    "p": 7,
    "q": 7,
    "r": 7,
    "s": 7,
    "t": 8,
    "u": 8,
    "v": 8,
    "w": 9,
    "x": 9,
    "y": 9,
    "z": 9
]

class ContactModel {

    var firstName: String!
    var lastName: String!

    var searchString: String {

        get {

            var search = ""

            var characters = [Character]()

            characters += firstName.lowercased().characters
            characters += (" " + lastName.lowercased()).characters

            for character in characters {

                if let character = charToNumMap[String(character)] {

                    search += String(character)

                }

            }

            return search

        }

    }

    init(contact: CNContact) {

        self.firstName = contact.givenName
        self.lastName = contact.familyName

    }

}

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!

    var contacts = [ContactModel]()
    var filteredContacts = [ContactModel]()

    let store = CNContactStore()

    override func viewDidLoad() {

        super.viewDidLoad()

        self.checkContactsPermission()

    }

    func checkContactsPermission() {

        switch CNContactStore.authorizationStatus(for: .contacts) {

            case .authorized:
            
                self.loadContacts()

            case .notDetermined:

                self.store.requestAccess(for: .contacts) { granted, error in
                    
                    if granted {
                        
                        DispatchQueue.main.async {

                            self.loadContacts()

                        }

                    }

                }

            case .denied, .restricted:

                print("I have no permissions :(")

        }

    }

    func loadContacts() {

        let fetchRequest = CNContactFetchRequest(keysToFetch: [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ])

        do {

            try self.store.enumerateContacts(with: fetchRequest, usingBlock: {

                (contact, stop) -> Void in
                
                self.contacts.append(ContactModel(contact: contact))

            })

            self.filteredContacts = self.contacts

         }
         catch let error as NSError {

             print(error.localizedDescription)

         }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let value = searchBar.text!.lowercased()

        if value.isEmpty {

            self.resetData(false)

            return

        }

        self.filteredContacts = self.contacts.filter({

            $0.searchString.contains(value)

        })

        self.table.reloadData()

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()

    }

    func resetData(_ looseFocus: Bool) {

        searchBar.text = ""

        self.filteredContacts = self.contacts

        self.table.reloadData()

        if looseFocus {

            searchBar.resignFirstResponder()

        }

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.resetData(true)

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return self.filteredContacts.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)

        cell.textLabel?.text = self.filteredContacts[(indexPath as NSIndexPath).section].firstName
            + " "
            + self.filteredContacts[(indexPath as NSIndexPath).section].lastName

        return cell

    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

    }

}
