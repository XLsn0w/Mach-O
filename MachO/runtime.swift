//
//  runtime.swift
//  MachO
//
//  Created by XLsn0w on 2020/2/26.
//  Copyright © 2020 XLsn0w. All rights reserved.
//

import UIKit

class runtime: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    Runtime内容如下:

    数据结构
    类对象与元类对象
    消息传递
    方法缓存
    消息转发
    Method-Swizzling
    动态添加方法
    动态方法解析
     
     
     - objc_object
     - objc_class
     - isa指针
     - method_t

     id = objc_object

     - class 等同于 objc_class
     - objc_class继承于objc_object
     - objc_class 包含 superClass,cache,bits.
     
     - 指针型isa
     isa的值代表Class的地址

     - 非指针型isa
     isa的值得部分代表Class的地址

     isa指向:
     - 关于对象,其指向类对象

     关于元类,其指向元类对象

     - 理解一个数组来实现
     - 数组每一个对象都是bucket_t结构体封装
     - bucket_t两个成员变量key ,IMP
     - key对应OC selector
     - IMP理解为无类型的函数指针

     
    
    */

}
