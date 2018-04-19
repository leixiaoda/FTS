//
//  ViewController.swift
//  FTS
//
//  Created by bytedance on 2018/4/18.
//  Copyright © 2018年 radar. All rights reserved.
//

import UIKit
import SQLite
//import SQLite3

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.test()
    }

    func test() {
        // 声明变量
        var db: Connection!
//        let normalTable = Table("Files")
        let table = VirtualTable("Files")
        let id = Expression<String>("id")
        let text = Expression<String>("text")
        var snippet = Expression<String>("")

        // 初始化
        let sqlFilePath = NSHomeDirectory() + "/Documents" + "/file.sqlite3"
        var dbConnect: Connection?
        do {
            dbConnect = try Connection(sqlFilePath)
        } catch {
            debugPrint(error)
        }
        db = dbConnect

        // 建表
        //        do {
        //            let create = normalTable.create { t in
        //                t.column(id, primaryKey: true)
        //                t.column(text)
        //            }
        //            try db.run(create)
        //        } catch {
        //            print(error)
        //        }
        do {
            let create = table.create(.FTS4(id, text))
            try db.run(create)
        } catch {
            print(error)
        }

        // 插入数据
        do {
            let insert = table.insert(id <- "1", text <- self.article1())
            try db.run(insert)
        } catch {
            print(error)
        }

        do {
            let insert = table.insert(id <- "2", text <- "world")
            try db.run(insert)
        } catch {
            print(error)
        }

        do {
            let insert = table.insert(id <- "3", text <- "world break")
            try db.run(insert)
        } catch {
            print(error)
        }

        snippet = self.snippetWrapper(column: text, tableName: "Files")

        // 查询
        let matchQuery: QueryType = table.select(snippet, id, text).match("all")
        let results = try? db?.prepare(matchQuery)

        if let concreteResults = results {
            let _ = concreteResults?.compactMap({
                print("\($0[id]), \($0[snippet]), \($0[text])")
            })
        }
    }

    func article1() -> String {
        guard let path = Bundle.main.path(forResource: "article1", ofType: "txt") else { return ""}
        let content = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)

        return content ?? ""
    }

    func snippetWrapper(column: Expression<String>, tableName: String) -> Expression<String> {
        return Expression("snippet(\(tableName))", column.bindings)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

