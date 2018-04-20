//
//  NormalViewController.swift
//  FTS
//
//  Created by bytedance on 2018/4/18.
//  Copyright © 2018年 radar. All rights reserved.
//

import UIKit
import SQLite
//import SQLite3

class NormalViewController: UIViewController {
    var db: Connection!
    let normalTable = Table("NormalFiles")
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
            let create = normalTable.create() {t in
                t.column(id, primaryKey: true)
                t.column(text)
            }
            try db.run(create)
        } catch {
            print(error)
        }

        // 插入数据
//        for index in 0...50 {
//            self.insert(0 + 9 * index)
//            self.insert(1 + 9 * index)
//            self.insert(2 + 9 * index)
//            self.insert(3 + 9 * index)
//            self.insert(4 + 9 * index)
//            self.insert(5 + 9 * index)
//            self.insert(6 + 9 * index)
//            self.insert(7 + 9 * index)
//            self.insert(8 + 9 * index)
//        }

        // 查询
//        let matchQuery: QueryType = normalTable.select(text).filter(text.like("%we%"))
//        let results = try? db?.prepare(matchQuery)
//
//        if let concreteResults = results {
//            for data in concreteResults {
//                print("\(data[id])")
//            }
//        }

        let startTime = Date()

        let matchQuery = normalTable.filter(text.like("%automatically%"))
        let results = try? db?.prepare(matchQuery)
        if let concreteResults = results {
            for user in concreteResults! {
                print("------\(user[id])")
            }
        }

        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        print("Time: \(executionTime)")
    }

    func insert(_ index: Int) {
        do {
            let insert = normalTable.insert(id <- index, text <- self.article(index))
            try db.run(insert)
        } catch {
            print(error)
        }
    }

    func article(_ index: Int) -> String {
        guard let path = Bundle.main.path(forResource: "article\(index % 9)", ofType: "txt") else { return ""}
        let content = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)

        return content ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
