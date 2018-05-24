//
//  ViewController.swift
//  FTS
//
//  Created by bytedance on 2018/4/18.
//  Copyright © 2018年 radar. All rights reserved.
//

import UIKit
import SQLite
import SnapKit

enum searchBtnTag: Int {
    case normalSearch = 0
    case ftsSearch
}

class ViewController: UIViewController {
    var db: Connection!
    let table = VirtualTable("Files")
    let id = Expression<Int>("docid")
    let text = Expression<String>("text")
    var snippet = Expression<String>("")

    let displayLabel = UILabel()
    let inputField = UITextField()

    let dbInitializationKey = "DBHasInitialized"

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        self.doInitDB()
        self.doInitUI()
    }

    func doInitUI() {
        let lightGrayColor = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0)

        // search input
        inputField.placeholder = "keyword"
        inputField.backgroundColor = lightGrayColor

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        inputField.leftView = paddingView
        inputField.leftViewMode = .always

        self.view.addSubview(inputField)
        inputField.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(200)
        }

        // normal search button
        let normalSearchBtn = UIButton()
        normalSearchBtn.tag = searchBtnTag.normalSearch.rawValue
        normalSearchBtn.setTitle("普通搜索", for: .normal)
        normalSearchBtn.setTitleColor(.black, for: .normal)
        normalSearchBtn.setTitleColor(.lightGray, for: .highlighted)
        normalSearchBtn.backgroundColor = lightGrayColor
        normalSearchBtn.addTarget(self, action: #selector(didClickBtn(_:)), for: .touchUpInside)
        self.view.addSubview(normalSearchBtn)
        normalSearchBtn.snp.makeConstraints { (make) in
            make.width.equalTo(85)
            make.height.equalTo(inputField)
            make.left.equalTo(inputField)
            make.top.equalTo(inputField.snp.bottom).offset(30)
        }

        // FTS search button
        let ftsSearchBtn = UIButton()
        ftsSearchBtn.tag = searchBtnTag.ftsSearch.rawValue
        ftsSearchBtn.setTitle("FTS搜索", for: .normal)
        ftsSearchBtn.setTitleColor(.black, for: .normal)
        ftsSearchBtn.setTitleColor(.lightGray, for: .highlighted)
        ftsSearchBtn.backgroundColor = lightGrayColor
        ftsSearchBtn.addTarget(self, action: #selector(didClickBtn(_:)), for: .touchUpInside)
        self.view.addSubview(ftsSearchBtn)
        ftsSearchBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(normalSearchBtn)
            make.right.equalTo(inputField)
            make.centerY.equalTo(normalSearchBtn)
        }

        // time display
        displayLabel.text = ""
        displayLabel.textColor = .black
        self.view.addSubview(displayLabel)
        displayLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(normalSearchBtn.snp.bottom).offset(30)
        }
    }

    func doInitDB() {
        // create DB
        let sqlFilePath = NSHomeDirectory() + "/Documents" + "/file.sqlite3"
        var dbConnect: Connection?
        do {
            dbConnect = try Connection(sqlFilePath)
        } catch {
            debugPrint(error)
        }
        db = dbConnect

        // create table
        do {
            let create = table.create(.FTS4(text), ifNotExists: true)
            try db.run(create)
        } catch {
            print(error)
        }

        // insert data
        if !UserDefaults.standard.bool(forKey: dbInitializationKey) {
            for index in 0...200 {
                self.insert(0 + 9 * index)
                self.insert(1 + 9 * index)
                self.insert(2 + 9 * index)
                self.insert(3 + 9 * index)
                self.insert(4 + 9 * index)
                self.insert(5 + 9 * index)
                self.insert(6 + 9 * index)
                self.insert(7 + 9 * index)
                self.insert(8 + 9 * index)
            }
        }

        UserDefaults.standard.set(true, forKey: dbInitializationKey)
    }

    @objc func didClickBtn(_ button: UIButton) {
//        snippet = self.snippetWrapper(column: text, tableName: "Files")

        guard let inputText = inputField.text, inputText.count != 0 else {
            displayLabel.text = "搜索词为空"
            return
        }

        // search & display execution time
        let startTime = Date()

        var results: Statement??
        if button.tag == searchBtnTag.normalSearch.rawValue {
            results = self.doNormalSearch(inputText)
        } else if button.tag == searchBtnTag.ftsSearch.rawValue {
            results = self.doFTSSearch(inputText)
        }

        // display results
        var displayText = ""
        if let results = results, let concreteResults = results {
            var count = 0
            for _ in concreteResults {
                count += 1
            }
            displayText = "命中结果:\(count)"
        }

        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        displayText += ", 消耗时间:\(executionTime)s"

        displayLabel.text = displayText
    }

    func doNormalSearch(_ text: String) -> Statement?? {
//        let matchQuery = table.filter(text.like("%automatically%"))
//        return try? db?.prepare(matchQuery)

        return try? db?.prepare("SELECT docid FROM Files WHERE text LIKE '%\(text)%'")
    }

    func doFTSSearch(_ text: String) -> Statement?? {
//        let matchQuery: QueryType = table.select("docid").match("automatically")
//        return try? db?.prepare(matchQuery)

        return try? db?.prepare("SELECT docid FROM Files WHERE text MATCH '\(text)'")
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
        guard let path = Bundle.main.path(forResource: "article\(index % 9)", ofType: "txt") else { return ""}
        let content = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)

        return content ?? ""
    }

    func snippetWrapper(column: Expression<String>, tableName: String) -> Expression<String> {
        return Expression("snippet(\(tableName))", column.bindings)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
