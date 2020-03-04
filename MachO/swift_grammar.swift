//
//  swift_grammar.swift
//  MachO
//
//  Created by XLsn0w on 2020/3/4.
//  Copyright © 2020 XLsn0w. All rights reserved.
//

import UIKit

class swift_grammar: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation
     Safe & Fast
     1. 能用 let，尽量不用 var
     把代码里的 var 全改成 let，只保留不能编译通过的。
     ObjC 的 Foundation 层几乎都是继承 NSObject 实现的，平时都在操作指针，所以要区分 Mutable 和 Imutable 的设计，比如 NSString 和 NSMutableString。
     Swift 使用了 let 和 var 关键字直接用于区分是否可变。可变会更容易出错，所以尽量采用不可变设计，等到需要改变才改为 var 吧。
     2.  尽量不用 ！
     ！遇到 nil 时会 crash（包括 as! 进行强制转换）。可以使用 if let/guard let/case let 配合 as? 将可选值消化掉。可能返回 nil 的 API，为什么要自己骗自己呢？
     当遇到 ObjC 代码暴露给 Swift 使用时，给接口 .h 文件加上 NS_ASSUME_NONNULL_BEGIN 和 NS_ASSUME_NONNULL_END 并检查接口参数是否可以为 nil 吧。
     3. 多定义 struct，少定义 class
     struct 是值类型，class 是引用类型。类类型分配在堆区，默认浅拷贝，容易被不经意间被改变，而值类型分配在栈区，默认深拷贝。并且 Swift 还有写时复制（copy on write）。
     即使是使用 class 时，也仅在必要时（如桥接到 ObjC，使用 Runtime 一些特性）继承自 NSObject。
     4. 能用 Swift 标准库类型，尽量不用对应的 Foundation 类型
     多使用 String、Array、Dictionary、Int、Bool，少使用 Foundation 里面的 NSString、NSArray、NSDictionary、NSNumber。Cocoa Foundation 里面的都是类类型，而 Swift 标准库的是值类型，有很多标准库的方便方法。
     还有用 print 代替 NSLog。
     5. 优先使用内置高阶函数
     forEach，map，compactMap，flatMap，zip，reduce 是好帮手，代替一些使用变量并在循环中处理的例子吧。用上高阶函数，不仅代码更清晰，还能将状态控制在更小的作用域内。
     6. 使用 try catch 捕获错误
     和 ObjC 基本都在函数的回调中返回 NSError 不一样，Swift 函数可以使用 throw 关键字抛出错误。
     func test() throws {
          //...
     }

     do {
       try test()
     } catch {
       print(error)
     }

     // 如果对错误不敏感
     try? test()
     复制代码7. 对 String 判空时优先采用 isEmpty
     Swift 里面的 String 的 index 和 count 不是一一对应的（兼容 Unicode），所以 stirng.count == 0 的效率不如 string.isEmpty。
     Clean Code
     8. 文件名字去掉前缀
     Swift 有着 framework 级别的命名空间，所以命名重复时可以通过 framework 名确定，不用担心重复命名问题。
     尽量只有在需要桥接给 ObjC 时，才使用 @objc(前缀 + 类名) 进行别名声明。
     9.  省略 self
     对应访问成员变量，方法时，都不用像 ObjC 那些写 self 了。
     只在闭包内、函数实参和成员变量名字相同和方法形参需要自身时使用。闭包内 self 是强制的，并且可以提醒注意循环引用问题。函数调用时实参名和成员变量相同时，函数作用域内会优先使用函数实参，所以访问成员变量是需要 self。
     10. 省略 init()
     直接使用 ClassA()，代替 ClassA.init()，代码更简洁。
     11. 能推导的类型不用显式编写
     // no bad
     let flag:Bool = false
     // better
     let flag = false

     // not bad
     view.contentMode = UIView.ContentMode.center
     // better
     view.contentMode = .center
     复制代码12. 使用默认形参，简化接口设计
     在设计接口时，不再需要为每一个形参是否需要而编写一个方法了，减少方法数吧。
     // not bad
     func test() {
         //...
     }

     func test(param1:String) {
         //...
     }

     func test(param2:String) {
         //...
     }

     // better
     func test(param1:String = "", param2:String = "") {
         //...
     }
     复制代码13. 使用 _ 表示不使用的返回值
     var a = [0]
     let _ = a.removeLast()

     [0].forEach{ _ in print("hh")}
     复制代码而对于自己设计的接口，如果返回值无关紧要，只是附加功能的话，可以使用 @discardableResult 进行标注。
     14. 使用 `` 来定义和关键字重名的方法和属性
     比如系统有个 default 关键字，而你也希望使用这个命名时就能派上用场。
     let `default` = A()

     func `default`() {}
     复制代码15. Strong-Weak Dance 很简单
     比起 ObjC 里需要每次需要写
     __weak typeof(self) weak_self = self;
     __typeof__(self) strong_self = weak_self;
     复制代码尽管很多人会采用宏来简化，但重复的宏定义又会冲突，且 ObjC 没有访问权限关键字。
     Swift 在闭包中可以使用 weak 和 unowned 指定闭包对值的捕获，配合 guard 就可以实现同样的功能。
     test(){ [weak self] in
             guard let self = self else { return }
         // self is strong without retain cycle
     }
     复制代码16. 类型嵌套
     类型嵌套用于在类型里定义类型，让类型的命名空间的精细化程度更高。
     struct GameService {
         enum APIError {
             enum ResultError {
                 case noResult
             }
         }
         // use APIError
     }
     // use GameService.APIError
     复制代码17. func 嵌套
     有时候某一块逻辑只需要在方法内复用或者做逻辑分割，可以在方法内定义方法，这样访问域会更清晰。
     func big(){
         func small() {
         //...
       }
       small()
     }
     复制代码18. 使用闭包做初始化
     有时候初始化时一个对象时还需要赋值其中的一些属性，这个时候就可以使用闭包代码块的整合。
     let someView: UIView = {
         let view = UIView(frame:.zero)
       view.backgroundColor = .red
       return view
     }()
     复制代码19. 使用更简洁的函数实参和形参
     和 ObjC 不同，有形参实参的 Swift，可以在调用和编写的时候都有更合适简洁的表达。
     // not bad
     func updateWithView(view:UIView)
     updateWithView(view:viewA)
     // better
     func updateWithView(_ view:UIView)
     updateWith(view:viewA)

     // not bad
     func didSelectAtIndex(index:Int)
     didSelectAtIndex(index:2)
     // better
     func didSelect(at index:Int)
     didSelect(at:2)
     复制代码20. Enum 用于命名空间声明
     定义一些常量时，用命名空间做隔离是最好的，Swift 的 Enum 比较适合用于命名空间的定义，能嵌套，且不存在初始化方法不会被用于其他作用。
     enum Event {
         enum Name {
             static let login = "event.name.login"
         }
     }

     // use
     Event.Name.login
     // not allow
     Event()
     复制代码21. 使用 ?? 返回默认值
     // not bad
     var name:String?
     if let aName = dic["name"] as? String {
         name = aName
     } else {
       name = ""
     }

     // better
     let name = dic["name"] as? String ?? ""
     复制代码22. 使用字符串插值
     除了常规的字符串插值，Swift5 还增加了更强大可自定义的字符串插值系统，详情见 文章。
     let a = 2
     print("\(a) is 2")
     复制代码Syntactic sugar
     23. 更 POP（Protocol Oriented Programming，面向协议编程）
     Swift 在设计上，为协议做了很多强大的功能。Swift 标准库里大量的方法和类都使用了协议进行抽象。在编写代码时优先考虑使用协议进行逻辑的抽象，详情可以参考 Apple WWDC 2015 Session 408 - Protocol-Oriented Programming in Swift。
     24. 优先使用 guard
     guard 是 if 的反义词，可以提前将异常情况 return。配合 guard let 使用，可以在正常分支下使用正确的条件。
     guard let a = a as? String else { return }
     // 下面的 a 就是 string 并且 non-nil 的了
     复制代码25. 尝试元组
     元组（Tuple）是个包含多个值的简单对象，使用元组，可以简单的用来函数返回多参数，也可以在集合类型中存取一对对的值。
     typealias Pair<T> = (T, T)

     let pair = Pair(1, 2)
     复制代码26. 尝试范型
     比起 ObjC 仅支持在集合类型里使用轻量级范型，Swift 的范型更强大，除了集合，还支持类、枚举、协议（Associate Type）。
     protocol View {
         associatedtype Model
         
         func update(model:Model)
     }
     复制代码27. 尝试枚举
     比起 ObjC 那和 C 语言差不多的枚举，Swift 的枚举更强大。Swift 的枚举不一定需要 Int 作为枚举的原始值，可以不需要原始值，也可以使用 String、Float、Boolean 作为原始值。能在枚举值上关联值，实现很多有趣的功能（Rx，Promise 的状态机）。能给枚举编写函数，能给枚举增加 Extension。
     enum State<Value> {
         case pending
         case fulfill(value:Value)
         case reject(reason:Error)
         mutating func update(to state:State){
             guard case .pending = self else {
                 return
             }
             self = state
         }
     }
     复制代码28. 尝试 Extension
     和 ObjC 的 Categories 类似，拓展可以添加类的方法。Swift 的 Extension 还能拓展值类型，枚举的方法，且不需要新建文件编写和支持权限访问关键字。通过 Extension，还能给 Protocol 增加默认实现。也能在 Extension 中遵循协议，让方法划分更加清晰。
     fileprivate extension Date {
         var toString: String {
             //...
         }
     }

     Date().toString
     复制代码29. lazy 关键字
     懒加载不需要像 ObjC 一样重写 getter 方法，并判空了，在属性前面加上 lazy 关键字就可以实现了。
     lazy var view = UIView(frame:.zero)
     复制代码30. where 关键字
     where 关键字可以对范围进行限定，详情见这篇 文章。
     31. typealias 关键字
     typealias 可以用来命名闭包类型、协议类型、范型类型，还支持组合。更多用法见 文章。
     typealias NewName<D> = ClassA<D>&ProtocolA&ProtocolB
     复制代码32. Result 类型
     Result 是一个枚举类型，包含成功或者失败的枚举值，并持有相应成功或者失败的值，通过范型确定类型信息。因为成功和失败是互斥的，这样就可以避免多个可选参数返回。
     比如对网络请求回调进行改造：
     URLSession.shared.dataTask(with: request) { result in
         switch result {
         case .success(let (data, _)):
             handle(data: data)
         case .failure(let error):
             handle(error: error)
         }
     }
     复制代码33. KVO
     在 ObjC 中，开发者更习惯用类似 FBKVOController 等第三方库进行 KVO 的监听，那是因为原生的写法太难用了。Swift 为 KVO 增加了闭包的 API，更简洁好用。
     scrollObserver = observe(\.scrollView!.contentOffset, options: [.new], changeHandler: { object, change in
          //...
     })
     复制代码同理，Swift 的 GCD API 也是专门经过 Swift 化的，也更加简洁好用。
     34. Codable
     在 Swift4 加入 Codable 协议后，JSON 等通用结构转模型，终于有了原生的支持。详情见 文章。
     35. SwiftUI&Combine
     在 WWDC19 推出的 Swift Only 的库，SwiftUI 有着类似 React 的声明式 UI 开发框架，配合实时调试，在 Demo 和简单页面，跨 Apple 平台应用适配时有一定优势。而 Combine 时类似 RxSwift 的响应式编程框架，能使事件流更统一。


     
    */

}
