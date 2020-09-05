import Foundation
/*
let JSON = """
{
    "total_rows": 1,
    "offset": 0,
    "rows": [
        {
            "id": "66e5e0d6ff42b1a626385de8db000c06",
            "key": "66e5e0d6ff42b1a626385de8db000c06",
            "value": {
                "rev": "1-91748a2d8b11a1afcc5c34cac68fe444"
            },
            "doc": {
                "_id": "66e5e0d6ff42b1a626385de8db000c06",
                "_rev": "1-91748a2d8b11a1afcc5c34cac68fe444",
                "title": "Which is better: iOS or macOS?",
                "option1": "iOS",
                "option2": "macOS",
                "votes1": 0,
                "votes2": 0
            }
        }
    ]
}
"""

let jsonData = JSON.data(using: .utf8)!
print(jsonData)
parse(json:jsonData)
*/
/*
struct dbResponse: Codable {
   var  totalRows:Int
   var  offset:Int
   var  rows: [row]

   private enum CodingKeys: String, CodingKey {
       case offset, rows
       case totalRows = "total_rows"
   }
}

struct row: Codable {
    var id:String
    var key:String
    var doc: docElement
}

struct docElement : Codable {
    var id: String
    var rev: String
    var title: String
    var option1: String
    var option2: String
    var votes1:Int
    var votes2:Int

   private enum CodingKeys: String, CodingKey {
       case title,option1, option2, votes1, votes2
       case id = "_id"
       case rev = "_rev"
   }
}

func parse(json: Data) {
    let decoder = JSONDecoder()
    if let jsonRows = try? decoder.decode(dbResponse.self, from: json) {
        print(jsonRows.totalRows)
        print(jsonRows.rows.count)
        for r in jsonRows.rows {
            print(r.doc.title)
        }
    } else {
        print("Alles nicht gut")
    }
}

*/