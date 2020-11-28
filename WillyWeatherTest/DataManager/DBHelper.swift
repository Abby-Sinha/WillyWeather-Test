

import Foundation
import SQLite3

class DBHelper
{
    init()
    {
        db = openDatabase()
        createDetailsTable()
    }

    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    func createDetailsTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS details(id TEXT PRIMARY KEY,author TEXT,url TEXT,download_url TEXT,download_status INTEGER);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("details table created.")
            } else {
                print("details table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    func insert(id:String, author:String, url:String, download_url:String, download_status:Int)
    {
        let details = read()
        for d in details
        {
            if d.id == id
            {
                return
            }
        }
        let insertStatementString = "INSERT INTO details (id, author, url, download_url, download_status) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (author as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (url as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (download_url as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(download_status))
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func update(id:String, download_status:Int) {
        
        let updateStatementString = "UPDATE details SET download_status = \(download_status) WHERE id = \(id);"

        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("\nSuccessfully updated row.")
            } else {
                print("\nCould not update row.")
            }
        } else {
            print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func read() -> [DB_Details] {
        let queryStatementString = "SELECT * FROM details;"
        var queryStatement: OpaquePointer? = nil
        var psns : [DB_Details] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let author = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let url = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let download_url = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let download_status = sqlite3_column_int(queryStatement, 4)
                psns.append(DB_Details(id: id, author: author, url: url, download_url: download_url, download_status: Int(download_status)))
                print("Query Result:")
                print("\(id) | \(author) | \(download_url)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
    
//    func deleteByID(id:Int) {
//        let deleteStatementStirng = "DELETE FROM person WHERE Id = ?;"
//        var deleteStatement: OpaquePointer? = nil
//        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
//            sqlite3_bind_int(deleteStatement, 1, Int32(id))
//            if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                print("Successfully deleted row.")
//            } else {
//                print("Could not delete row.")
//            }
//        } else {
//            print("DELETE statement could not be prepared")
//        }
//        sqlite3_finalize(deleteStatement)
//    }
    
}
