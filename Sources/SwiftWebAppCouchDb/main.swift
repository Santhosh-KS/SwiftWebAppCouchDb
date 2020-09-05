import CouchDB
import Kitura
import HeliumLogger
import KituraStencil
import LoggerAPI

struct docElement : Codable, Document {
    let _id: String?
    var _rev: String?
    var title: String
    var option1: String
    var option2: String
    var votes1:Int
    var votes2:Int
}

let logger = HeliumLogger(.info)
Log.logger = logger
let router = Router()
Log.info("Created 1")
let connectionProperties = ConnectionProperties.init(host: "localhost",
    port: 5984, secured: false, username: "admin", password: "admin123")

Log.info("ConnectionProperties set")
let client = CouchDBClient.init(connectionProperties: connectionProperties)

func errorHandler(_ error:Error, _ response:RouterResponse ) {
    let errorMsg = error.localizedDescription
    let status = ["status": "error", "message": errorMsg]
    let result = ["result": status]
    response.status(.OK).send(json: result)
}

router.get("/polls/list") {
    request, response, next in

    client.retrieveDB("polls") { (database , error: CouchDBError?) in
        defer { next() }
        // Let us handle the error case if the db doesn't exits
        if let error = error {
            errorHandler(error, response)
        }
        else if let database = database {
            Log.info("Fetching database \(database.name) successfull")
            Log.info("KSS: type of \(type(of: response))")

            database.retrieveAll(includeDocuments: true) { docs, error in
                if let error = error {
                    Log.info("KSS error in getting the data.")
                    errorHandler(error, response)
                } else {
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
/*
    let status = ["status": "ok"]
    let result = ["result": status]
    response.status(.OK).send(json: result)*/
}

router.post("/polls/create") {
    request, response, next in
    defer { next() }
    response.status(.OK)
}

router.post("/polls/vote/:pollid/:option") {
    request, response, next in
    defer { next() }
    response.status(.OK)
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()