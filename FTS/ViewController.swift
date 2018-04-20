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
    var db: Connection!
    //        let normalTable = Table("Files")
    let table = VirtualTable("Files")
    let id = Expression<Int>("id")
    let text = Expression<String>("text")
    var snippet = Expression<String>("")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.doSomething()
    }

    func doSomething() {
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
        self.insert(1)
        self.insert(2)
        self.insert(3)
        self.insert(4)
        self.insert(5)
        self.insert(6)
        self.insert(7)
        self.insert(8)

        snippet = self.snippetWrapper(column: text, tableName: "Files")

        // 查询
        let matchQuery: QueryType = table.select(snippet, id, text).match("we")
        let results = try? db?.prepare(matchQuery)

        if let concreteResults = results {
            let _ = concreteResults?.compactMap({
                print("\($0[id]), \($0[snippet])")
            })
        }
    }

    func insert(_ index: Int) {
        do {
            let insert = table.insert(id <- index, text <- self.article(index))
            try db.run(insert)
        } catch {
            print(error)
        }
    }

    func article(_ index: Int) -> String {
        guard let path = Bundle.main.path(forResource: "article\(index)", ofType: "txt") else { return ""}
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

