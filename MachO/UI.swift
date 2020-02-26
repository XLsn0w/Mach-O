//
//  UI.swift
//  MachO
//
//  Created by XLsn0w on 2020/2/26.
//  Copyright © 2020 XLsn0w. All rights reserved.
//

import UIKit
    /*
    1.UITableView
    2.卡顿/掉帧
    3.绘制原理/异步绘制
    4.图像显示原理
    5.事件传递/视图响应
    6.离屏渲染
     
 2.1 UIView 和 CALayer
 UIView提供内容,负责处理触摸等事件,参与响应链
 CALayer负责显示内容

 2.2 事件传递
 //点击了那个视图
 -(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
 //点击位置是否在当前视图内
 -(BOOL)pointInside:(CGPoint)point wihtEvent:(UIEvent*)event;

     
     点击屏幕-->>UIApplication
           -->>UIWindow
           -->>最终响应的视图
 -->>判断点击的视图是否在UIWindow范围内-->>视图遍历(最后添加的视图
     优先遍历)
 -->>返回的view1如果存在就结束了

     详情
     - 开始遍历
     - 视图没有隐藏/视图存在点击事件/透明度不为0,视图存在,继续进行,否则返回nil
     - 判断点击视图是否在当前视图内,视图存在,继续下一级进行,否则返回nil
     - 遍历视图,通过响应视图hitTest方法,判断视图是否存在,如果不存在,继
     续遍历,直到找到最后的响应视图.
     - 遍历子视图,如果视图不存在,结果为上一层视图v

     面试题:如果传递到UIApplicationDelegate,最终仍然没有任何视图去处理事件,最终是什么样的场景?
     忽略这个事件,当做没有发生.

     
     - 页面的滑动流畅性是60FPS
     - 每一秒,会有60帧画面更新,人眼看到的就是流畅的.

     
     
     滑动优化方案
 - CPU:
 - 对象创建,调整,销毁可以放到子线程中,节省CPU的时间
 - 预排版(布局,文本计算),放到子线程中,主线程响应用户的交互
 - 预渲染(文本等异步绘制,图片编解码等)
 
 - GPU:
 - 纹理渲染
 - 视图混合:减轻视图层级的复杂性,减轻GPU的压力

     
     [UIView setNeedsDisPlay]
     |
     [view.layer setNeedsDisplay]
     |
     [CALayer display]

     - 如果不响应displayLayer方法,就会进入到系统绘制流程当中
     - 如果响应displayLayer方法,就开启了异步绘制
 - 使用layer的代理方法
 - 如果使用,调用系统的drawlayer方法,进行视图绘制
 - 如果不使用,调用drawinContext方法
 - 最终是对CALayer上传位图到GPU

     
     - [layer.delegate displayLayer:]
     - 代理负责生成对应的位图
     - 位图作为layer.contents属性的值

     
     - 在主队列调用setNeedsDisplay
     - 在当前runloop将要结束的时候,调用display方法,代理实现displayLayer函数,调用displayLayer方法
     - 通过子线程切换,位图绘制
     - 子线程中三个方法,CGBitmapContextCreate(),创建位图上下文
     - 通过CoreGraphic API进行位图绘制工作
     - 通过位图上下文生成图片
     - 回到主队列当中,提交位图,设置CALayer的content属性
     - 即完成了CALayer的异步绘制.

     
     离屏渲染何时会触发?
     - 圆角(与maskToBounds一起使用时)
     - 图层蒙版
     - 阴影
     - 光栅化

 为什么要避免离屏渲染?
 - 创建新的渲染缓冲区
 - 上下文切换

 增加GPU进行额外的开销,导致CPU和GPU合成大于16.7ms,会造成UI卡顿,掉帧

     
     
     
     
     
    */


