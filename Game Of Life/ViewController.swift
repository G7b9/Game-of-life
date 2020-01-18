//
//  ViewController.swift
//  Game Of Life
//
//  Created by laimin on 2020/1/17.
//  Copyright © 2020 laimin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let edge = UIEdgeInsets(top: 64, left: 20, bottom: 20, right: 20)
    
    let num_column: Int = 80
    let width_line: CGFloat = 1
    
    fileprivate lazy var bgView: BGView = {
        let x = BGView(edge: edge, column: num_column, widthLine: width_line)
        return x
    }()
    
    fileprivate lazy var nextButton: UIButton = {
        let x = UIButton(type: .custom)
        x.backgroundColor = .red
        x.setTitle("迭代", for: .normal)
        let size = CGSize(width: 40, height: 20)
        x.frame = CGRect(x: (UIScreen.main.bounds.size.width - size.width) * 0.5, y: edge.top - size.height, width: size.width, height: size.height)
        x.addTarget(self, action: #selector(nextClick), for: .touchUpInside)
        return x
    }()
    
    fileprivate lazy var clearButton: UIButton = {
        let x = UIButton(type: .custom)
        x.backgroundColor = .red
        x.setTitle("清空", for: .normal)
        let size = CGSize(width: 40, height: 20)

        x.frame = CGRect(x: nextButton.frame.maxX + 20, y: edge.top - size.height, width: size.width, height: size.height)
        x.addTarget(self, action: #selector(clearClick), for: .touchUpInside)
        return x
    }()
    
    fileprivate lazy var autoButton: UIButton = {
        let x = UIButton(type: .custom)
        x.backgroundColor = .red
        x.setTitle("自动", for: .normal)
        let size = CGSize(width: 40, height: 20)
        
        x.frame = CGRect(x: clearButton.frame.maxX + 20, y: edge.top - size.height, width: size.width, height: size.height)
        x.addTarget(self, action: #selector(autoClick), for: .touchUpInside)
        return x
    }()
    
    fileprivate lazy var stopButton: UIButton = {
        let x = UIButton(type: .custom)
        x.backgroundColor = .red
        x.setTitle("停止", for: .normal)
        let size = CGSize(width: 40, height: 20)
        
        x.frame = CGRect(x: autoButton.frame.maxX + 20, y: edge.top - size.height, width: size.width, height: size.height)
        x.addTarget(self, action: #selector(stopClick), for: .touchUpInside)
        return x
    }()
    
    fileprivate lazy var upButton: UIButton = {
        let x = UIButton(type: .custom)
        x.backgroundColor = .red
        x.setTitle("加快", for: .normal)
        let size = CGSize(width: 40, height: 20)
        
        x.frame = CGRect(x: stopButton.frame.maxX + 20, y: edge.top - size.height, width: size.width, height: size.height)
        x.addTarget(self, action: #selector(upClick), for: .touchUpInside)
        return x
    }()
    
    fileprivate lazy var downButton: UIButton = {
        let x = UIButton(type: .custom)
        x.backgroundColor = .red
        x.setTitle("减慢", for: .normal)
        let size = CGSize(width: 40, height: 20)
        
        x.frame = CGRect(x: upButton.frame.maxX + 20, y: edge.top - size.height, width: size.width, height: size.height)
        x.addTarget(self, action: #selector(downClick), for: .touchUpInside)
        return x
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaultView()
    }

    
    func loadDefaultView() {
        view.addSubview(bgView)
        view.addSubview(nextButton)
        view.addSubview(clearButton)
        view.addSubview(autoButton)
        view.addSubview(stopButton)
        view.addSubview(upButton)
        view.addSubview(downButton)
    }
    
    @objc func nextClick() {
        bgView.showNext()
    }
    
    @objc func clearClick() {
        bgView.clearAll()
    }
    
    @objc func autoClick() {
        bgView.autoNext()
    }
    
    @objc func stopClick() {
        bgView.stopAuto()
    }
    
    @objc func upClick() {
        bgView.speedUp()
    }
    
    @objc func downClick() {
        bgView.speedDown()
    }
}

class BGView: UIView {
    convenience init(edge: UIEdgeInsets, column: Int = 20, widthLine: CGFloat = 1) {
        self.init(frame: .zero)
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        backgroundColor = .white
        self.column = column
        width = UIScreen.main.bounds.size.width - edge.left - edge.right
        // 保持高度为 box 宽度的整数倍
        var height = UIScreen.main.bounds.size.height - edge.top - edge.bottom
        self.row = Int(height / height_box)
        height = CGFloat(self.row) * height_box
        frame = CGRect(x: edge.left, y: edge.top, width: width, height: height)
        self.height = height
        self.width_line = width_line
        
        for _ in 0..<self.row {
            var cells = [Cell]()
            for _ in 0..<self.column {
                cells.append(Cell())
            }
            cellList.append(cells)
        }
    }
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    var row: Int = 0
    var column: Int = 20
    var width_box: CGFloat { return width / CGFloat(column) }
    var height_box: CGFloat { return width_box }
    var width_line: CGFloat = 1
    let color_line: UIColor = .red
    // 装载 cell
    var cellList = [[Cell]]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        // 第几行
        let i = Int(point.y / height_box)
        // 第几列
        let j = Int(point.x / width_box)
        let cell_clicked = cellList[i][j]
        cell_clicked.isSelected = !cell_clicked.isSelected
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        //绘制 box
        for j in 0..<row {
            for i in 0..<column {
                let rect_box = CGRect(x: CGFloat(i) * width_box, y: CGFloat(j) * height_box, width: width_box, height: height_box)
                let box = UIBezierPath(rect: rect_box)
                let cell = cellList[j][i]
                cell.color_current.set()
                box.fill()
            }
        }
        
        // 绘制网格
        //纵线
        for i in 0..<column - 1 {
            let point_start = CGPoint(x: CGFloat(i + 1) * width_box, y: 0)
            let point_end = CGPoint(x: point_start.x, y: height)
            let line_vertical = UIBezierPath()
            line_vertical.move(to: point_start)
            line_vertical.addLine(to: point_end)
            line_vertical.lineWidth = width_line
            color_line.set()
            line_vertical.stroke()
        }
        
        //横线
        for i in 0..<row - 1 {
            let point_start = CGPoint(x: 0, y: CGFloat(i + 1) * height_box)
            let point_end = CGPoint(x: width, y: point_start.y)
            let line_horizontal = UIBezierPath()
            line_horizontal.move(to: point_start)
            line_horizontal.addLine(to: point_end)
            line_horizontal.lineWidth = width_line
            color_line.set()
            line_horizontal.stroke()
        }
    }
    
    func showNext() {
        // 计算下一次状态
        var cellListStatus_new = [[Bool]]()
        for (i, cells) in cellList.enumerated() {
            var cellsStatus_new = [Bool]()
            for (j, cell) in cells.enumerated() {
                let cell_neightbors = Regulation.getNeighbors(cellList: cellList, position: (i, j))
                let isSelected_next = Regulation.newStatus(status_old: cell.isSelected, neighbors: cell_neightbors)
                cellsStatus_new.append(isSelected_next)
            }
            cellListStatus_new.append(cellsStatus_new)
        }
        //更新状态
        for (i, cells) in cellList.enumerated() {
            for (j, cell) in cells.enumerated() {
                cell.isSelected = cellListStatus_new[i][j]
            }
        }
        
        setNeedsDisplay()
    }
    
    func clearAll() {
        for cells in cellList {
            for cell in cells {
                cell.isSelected = false
            }
        }
        setNeedsDisplay()
    }
    
    var isAuto = false
    var speedAuto: Double = 1
    
    func autoNext() {
        isUserInteractionEnabled = false
        isAuto = true
        
        circleAction()
        isUserInteractionEnabled = true
    }
    
    /// 循环执行
    ///
    /// - Parameter circle: 循环次数
    func circleAction() {
        
        if isAuto {
            showNext()
            DispatchQueue.main.asyncAfter(deadline: .now() + speedAuto) {
                self.circleAction()
            }
        }
    }
    
    func stopAuto() {
        isAuto = false
    }
    
    func speedUp() {
        speedAuto *= 0.9
        print("speedAuto -------->", speedAuto)
    }
    
    func speedDown() {
        speedAuto *= 1.1
        print("speedAuto -------->", speedAuto)
    }
}


class Cell {
    var isSelected: Bool = false
    let color_selected: UIColor = .black
    let color_norm: UIColor = .white
    var color_current: UIColor { return isSelected ? color_selected : color_norm}
}

class Regulation {
    
    static func getNeighbors(cellList: [[Cell]], position: (i: Int, j: Int)) -> [Cell] {
        var cells = [Cell]()
        let row = cellList.count
        guard row > 0, let column = cellList.first?.count, column > 0, position.i >= 0, position.i < row, position.j >= 0, position.j < column else {
            return cells
        }
        
        // 上下左右四角落
        var neightborTuples = [(Int, Int)]()
        
        neightborTuples.append((position.i - 1, position.j - 1))
        neightborTuples.append((position.i - 1, position.j))
        neightborTuples.append((position.i - 1, position.j + 1))
        neightborTuples.append((position.i, position.j - 1))
        neightborTuples.append((position.i, position.j + 1))
        neightborTuples.append((position.i + 1, position.j - 1))
        neightborTuples.append((position.i + 1, position.j))
        neightborTuples.append((position.i + 1, position.j + 1))
        
        for (i, j) in neightborTuples {
            if i >= 0, i < row, j >= 0, j < column {
                let cell_neightbor = cellList[i][j]
                cells.append(cell_neightbor)
            }
        }
        return cells
    }
    
    static func newStatus(status_old: Bool, neighbors: [Cell]) -> Bool {
        let count_selected = neighbors.filter { (cell) -> Bool in
            cell.isSelected
        }.count
        if status_old{
            return (count_selected == 2) || (count_selected == 3)
        } else {
            return (count_selected == 3)
        }
    }
}
