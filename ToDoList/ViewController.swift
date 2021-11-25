//
//  ViewController.swift
//  ToDoList
//
//  Created by 또영이 on 2021/10/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    
    //UIBarButtonItem 프로퍼티선언(셀삭제를위한...)
    var doneButton: UIBarButtonItem?
    
    //할일을 저장하는 배열선언
    //앱을 재 실행했을 때 저장된 할일 들을 로드하는 코드 (프로퍼티옵저버)
    var tasks = [Task]() {
        didSet {
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customController()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks()
        
        //아이콘생성
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
    }
    
    func customController() {
        
        //        self.tabBarController?.tabBar.layer.borderWidth = 0.5
        //        self.tabBarController?.tabBar.layer.borderColor = UIColor.blue.cgColor
        self.tabBarController?.tabBar.barTintColor = .white
        self.tabBarController?.tabBar.clipsToBounds = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    //done버튼을 눌러 편집모드에서 빠져나오게 하는 함수
    @objc func doneButtonTap() {
        self.navigationItem.leftBarButtonItem = self.editBtn
        
        //편집모드 해제 false
        self.tableView.setEditing(false, animated: true)
    }
    
    //edit 버튼을 눌렀을 때 tableView편집모드로 변경
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        
        //tasks배열이 비어있지 않을 때만 편집모드로 전환
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        
        //편집모드로 전환 true->편집모드
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: "할 일을 입력해주세요.", preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .destructive, handler: { [weak self] _ in
            
            //guard로 옵셔널 바인딩하고 title상수명 정하고 textFields의0번째에 입력 받음
            guard let title = alert.textFields?[0].text else { return }
            
            //task구조체 인스턴스 생성
            let task = Task(title: title, done: false)
            
            //tasks배열에 할일들을 추가한다.
            self?.tasks.append(task)
            
            //tasks 할일들이 추가될 때 마다 tableView를 갱신해서 tableview에 추가될 할일이 표시되게 함
            self?.tableView.reloadData()
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    //UserDefaults에 저장
    func saveTasks() {
        
        //dictionay형태로 맵핑
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        
        //userDefaults에 접근할수있게 만듬, 싱글톤이라 하나의 인스턴스에만 존재
        let userDefaults = UserDefaults.standard
        
        //userDefaults에 키에 쌍으로 데이터 저장 data->value값 tasks->key값
        userDefaults.set(data, forKey: "tasks")
    }
    
    //userDefaults에 저장된 할 일들을 로드
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        
        //tasks배열에 저장
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    //numberOfRowsInSection 각 세션에 표시할 행의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //배열에 저장되어있는 할일 요소들을 가져옴
        let task = self.tasks[indexPath.row]
        
        //textLabel에 표시하기
        cell.textLabel?.text = task.title
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        
        //task.done true이면
        if task.done {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.red
            cell.textLabel?.alpha = 0.2
            
            //task.don false이면
        } else {
            cell.accessoryType = .none
            cell.textLabel?.alpha = 1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "delete", handler: { _,_,_  in
            let alret = UIAlertController(title: "삭제 하시겠습니까?", message: nil, preferredStyle: .actionSheet)
            let alretAction2 = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                
                //편집모드를 눌러서 셀의 마이너스버튼 눌러서 테이블뷰에서 삭제
                self.tasks.remove(at: indexPath.row)
                
                //삭제된 셀에 인덱스패치정보를 넘겨줘서 테이블뷰에도 삭제되게 스와이프로도 삭제할수있음
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                //모든 셀이 삭제되면
                if self.tasks.isEmpty {
                    
                    //done버튼에서 - > edit버튼으로 빠져나가게 함
                    self.doneButtonTap()
                }
            })
            
            let alretAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alret.addAction(alretAction)
            alret.addAction(alretAction2)
            self.present(alret, animated: true, completion: nil)
        })
        
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //cell 위치 변경하기 (재정렬) sourceIndexPath->원래있었던 위치로 알려줌 destinationIndexPath->어디로 이동했는지 알려줌
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //재정렬된 순서대로 배열도 재정렬된 순서대로 저장
        var tasks = self.tasks
        
        //row 배열의 요소로 접근
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}

extension ViewController: UITableViewDelegate {
    
    //didSelectRowAt 셀을 선택했을 때 실행되는 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        
        //reloadRows-> 선택된 셀만 reloade되게 함
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
