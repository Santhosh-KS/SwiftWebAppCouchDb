import CouchDB
import Kitura
import HeliumLogger
import KituraStencil
import LoggerAPI
import Foundation

struct docElement : Codable, Document {
    let _id: String?
    var _rev: String?
    var title: String
    var option1: String
    var option2: String
    var votes1:Int
    var votes2:Int
}

extension docElement {
    init() {
        self._id = nil
        self._rev = nil
        self.title = "DefaultTitle"
        self.option1 = "opt1"
        self.option2 = "opt2"
        self.votes1 = 0
        self.votes2 = 0
    }
}

struct pollResponse: Codable {
    var title: String
    var votes1: Int
    var votes2: Int
}

let logger = HeliumLogger(.info)
Log.logger = logger
let router = Router()
Log.info("Created 1")
let connectionProperties = ConnectionProperties.init(host: "localhost",
    port: 5984, secured: false, username: "admin", password: "admin123")

// Some pre-requisits before we run the program.
// export COUCHUSR="admin:admin123"
// export COUCH="http://$COUCHUSR@localhost:5984"
// export JSON="Content-Type:application/json"

// curl -X PUT $COUCH/polls
// curl -X POST -H $JSON $COUCH/polls -d '{"title": "Which is better: iOS or macOS?", "option1": "iOS", "option2": "macOS","votes1": 0, "votes2": 0 }'
Log.info("ConnectionProperties set")
let client = CouchDBClient.init(connectionProperties: connectionProperties)
let database = getDb("polls")

func errorHandler(_ error:Error, _ response:RouterResponse ) {
    let errorMsg = error.localizedDescription
    let status = ["status": "error", "message": errorMsg]
    let result = ["result": status]
    response.status(.OK).send(json: result)
}


func getDb(_ dbName:String) -> Database {
    var db: Database? = nil

    client.retrieveDB(dbName) { (database , error: CouchDBError?) in
        if let error = error {
            precondition(false, "Db name: \(dbName) doesn't exists, \(error)")
        }
        if let database = database {
            Log.info("Fetching database \(database.name) successfull")
            db = database
        }
    }
    return db!
}

router.get("/polls/list") {
    request, response, next in

    //client.retrieveDB(dbName: String, callback: (Database?, CouchDBError?) -> ())
    client.retrieveDB("polls") { (database , error: CouchDBError?) in
        defer { next() }
        Log.info("KSS list entry 1")
        // Let us handle the error case if the db doesn't exits
        if let error = error {
            Log.info("KSS list entry 1 error")
            errorHandler(error, response)
        }
        else if let database = database {
            Log.info("KSS list entry 2")
            Log.info("Fetching database \(database.name) successfull")
            Log.info("KSS: type of \(type(of: response))")

            database.retrieveAll(includeDocuments: true) { docs, error in
                if let error = error {
                    Log.info("KSS list entry 3 error")
                    Log.info("KSS error in getting the data.")
                    errorHandler(error, response)
                } else {
                    Log.info("KSS list entry 4")
                    //Log.info("KSS got the data. \(docs)")
                    var polls = [[String: Any]]()
                    if let allDocs = docs,
                        let decodedDocs = allDocs.decodeDocuments(ofType: docElement.self)  as [docElement]?{
                        Log.info("KSS All set to decode data \(decodedDocs.count)")
                        for doc in decodedDocs {
                            var poll = [String: Any]()
                            Log.info("Retrieved MyDocument with value: \(doc.title)")
                            poll["id"] = doc._id ?? "No_id_found"
                            poll["rev"] = doc._rev ?? "No_rev_found"
                            poll["title"] = doc.title
                            poll["option1"] = doc.option1
                            poll["option2"] = doc.option2
                            poll["votes1"] = doc.votes1
                            poll["votes2"] = doc.votes2
                            polls.append(poll)
                        }
                        let status = ["status": "ok"]
                        let result: [String: Any] = ["result": status, "polls": polls]
                        response.status(.OK).send(json: result)
                    }
                }
            }
        }
    }
}

router.post("/polls/create", middleware: BodyParser())
router.post("/polls/create") {
    request, response, next in
    defer { next() }
    Log.info("KSS entry 1")
    // 2: check we have some data submitted
    guard let values = request.body else {
        Log.info("KSS entry 1 error")
        try response.status(.badRequest).end()
        return
    }

    Log.info("KSS entry 2")
    // 3: attempt to pull out URL-encoded values from the submission
    guard case .urlEncoded(let body) = values else {
        response.status(.OK)
        Log.info("KSS entry 2 error")
        try response.status(.badRequest).end()
        return
    }

    // 4: create an array of fields to check
    let fields = ["title", "option1", "option2"]

    // this is where we'll store our trimmed values
    Log.info("KSS entry 3")
    var poll = [String: Any]()
    for field in fields {
        // check that this field exists, and if it does remove any whitespace
        if let value = body[field]?.trimmingCharacters(in: .whitespacesAndNewlines) {

        // make sure it has at least 1 character
            if value.count > 0 {
                // add it to our list of parsed values
                poll[field] = value
                // important: this value exists, so go on to the next one
                continue
            }
        }
        // this value does not exist, so send back an error and exit
        try response.status(.badRequest).end()
        Log.info("KSS entry 3 error")
        return
    }

    // fill in default values for the vote counts
    poll["votes1"] = 0
    poll["votes2"] = 0

    Log.info("KSS entry 4 ")
    database.create(fillData(poll)) { (dbResp, error) in
       if let dbResp = dbResp{
            Log.info("KSS entry 5 ")
          Log.info("Document: \(dbResp.id), created with rev: \(dbResp.rev)")
          let status = ["status": "ok", "id": dbResp.id]
          let result = ["result": status]
          response.status(.OK).send(json: result)
       } else {
            Log.info("KSS entry 5 error")
            // something went wrong – attempt to find out what
            let errorMessage = error?.localizedDescription ?? "Unknown error"
            let status = ["status": "error", "message": errorMessage]
            let result = ["result": status]
            // mark that this is a problem on our side, not the client's
            response.status(.internalServerError).send(json: result)
        }
    }
}

func fillData(_ d:[String: Any]) -> docElement {
  var resp: docElement = docElement()
  resp.title = d["title"] as! String
  resp.votes1 = d["votes1"] as! Int
  resp.votes2 = d["votes2"] as! Int
  resp.option1 = d["option1"] as! String
  resp.option2 = d["option2"] as! String
  return resp
}

router.post("/polls/vote/:pollid/:option") {
    request, response, next in
    defer { next() }
    response.status(.OK)
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()