# Mach-O
Mach-O其实是Mach Object文件格式的缩写，是macOS以及iOS上可执行文件的格式

逆向Hook一个App非常重要的文件，就是MachO文件。

通过查看应用打包后的ipa包内容，我们发现，用户的代码部分就是在MachO文件里面，那么MachO到底是什么呢？我们来一起了解一下今天MachO文件相关的知识内容，这也是逆向分析非常关键的一环：

1、MachO文件简介
2、可执行文件
3、通用二进制文件
4、MachO文件结构
5、MachOView
6、Header部分介绍
7、LoadCommands部分介绍
一、MachO文件简介

1、Mach-O定义部分：

Mach-O其实是Mach Object文件格式的缩写，它是是Mac以及iOS上一种用于可执行文件、目标代码、动态库的文件格式，类似于Windows上面的PE(Portable Executable)格式,linux上的elf格式(Executable and Link Format);作为a.out格式的替代，Mach-O提供了更强的拓展性。
2、属于Mach-O文件格式的常见文件类型有：

·  目标文件.o
·  库文件
   ·  .a
   ·  .dylib
   ·  .Framework
·  可执行文件
·  dyld(动态链接器)
·  .dsym
我们可以通过$file 文件路径 来查看文件类型

3、Mach-O文件举例

例如，在终端上执行命令

cd ~/Desktop

vi test.c

此时进入编辑界面，

#include <stdio.h>

int main(){

    printf("test\n");

    return 0;
}

'i'键进入编辑，编辑完成后'ESC'退出编辑，然后'shift'+':',接着'x'+回车保存退出，然后使用'clang'指令执行

clang -c test.c

执行完后，会发现‘test.c’路径下又多了一个‘test.o’的文件，接下来我们使用指令查看'test.o'文件类型

file test.o

得到终端输出

test.o: Mach-O 64-bit object x86_64

上面这一串信息详细解释就是：

‘test.o’是一个Mach-O文件，并且CPU解读它的时候是64位的，它是Mach-O文件，属于object类型的，并且它是x86_64架构的。(x86_64是Mac电脑的CPU，文件是在Mac上执行的，所以此处是x86_64架构)
接下来我们把object链接成可执行文件，终端执行命令

clang test.o

此时目录下又多出来一个a.out文件，

继续查看a.out文件的类型，

file a.out

得到终端输出

a.out: Mach-O 64-bit executable x86_64

中间的executable就代表a.out是Mach-O文件的可执行文件。

这个示例说明了，a.out可执行文件和text.o都是Mach-O格式的文件，只不过对应的文件类型不同而已。

那么你可能有疑问，Mach-O格式整这么多乱七八糟的有什么用呢？有什么业务需求或者场景吗？先不急，接着上面的例子，继续跟我一起敲：

在之前目录下再建一个新的test1.c的文件，在里面实现一个方法

vi test1.c

编辑内容

void test1(){

    printf("test1");

    return 0;

}
然后修改原先的test.c文件，直接在里面调用

#include <stdio.h>

void test1();

int main(){

    printf("test");

    test1();

    return 0;
}

如果此时我们直接编译test.c文件，那么会找到不到test1()这个方法的实现，因为此时方法的调用和实现分别在test.c和test1.c文件中；但是，注意了哈，终端命令输入后回车：

clang -o demo test1.c test.c

输出得到了一个demo可执行文件，

./demo

执行之后打印台打印

test

test1

也就做到了两个源文件test.c和test1.c生成两个object中间文件test.o, test1.o，最后链接成了一个可执行文件demo，执行demo就可以做到运行两个源文件的代码，这就是最后的效果，Mach-O文件的作用。

类推App打包，项目中有无数个文件，到最后链接成一个Mach-O格式的可执行文件。这就是编译和链接的过程。编译生成目标文件.o，链接就是把许许多多个这些.o目标文件链接生成可执行文件。链接过程就是使用clang编译器链接起来的。

同理.a/.dylib/.Framework也是同样的原理，下面是查找这些文件的指令

find / -name ".a"

find / -name ".dylib"

find / -name ".Framewoork"

比如查看库

cd /usr/lib

ls -l

能够查看很多系统库，随便找一个来查看文件类型，比如‘libeasyperf.dylib’

file  libeasyperf.dylib

libeasyperf.dylib: Mach-O 64-bit dynamically linked shared library x86_64

这个哥们也是Mach-O格式的文件，并且是dynamically linked shared library静态库文件。

如'dyld'

file dyld

dyld: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit dynamic linker x86_64] [i386:Mach-O dynamic linker i386]
dyld (for architecture x86_64): Mach-O 64-bit dynamic linker x86_64
dyld (for architecture i386):   Mach-O dynamic linker i386

可以看出dyld是Mach-O格式，dynamic linker(动态链接器)类型的文件，并且兼容x86_64架构以及i386架构。

二、可执行文件

1、上面我们已经说明了Mach—O文件的多种格式，我们也可以在Xcode中设置Mach—O文件的类型，设置方式如下，选项内就是我们上面说过的Mach-O文件的各种类型。


1、Xcode设置Mach-O文件的类型.jpg
2、通过Xcode设置修改可执行文件的系统架构。

系统架构：

32位的包含：armv7, armv7s

64位的包含：arm64，arm64e

只支持一个架构的我们称之为单一架构，比如只支持arm64

不同的iOS系统版本运行要求不同的系统架构：

指令集对应的机型：
2019~待更新
2018 A12芯片arm64e ： iphone XS、 iphone XS Max、 iphoneXR
2017 A11芯片arm64： iPhone 8, iPhone 8 Plus, and iPhone X
2016 A10芯片arm64：iPhone 7 , 7 Plus, iPad (2018)
2015 A9芯片arm64： iPhone 6S , 6S Plus 
2014 A8芯片arm64： iPhone 6 , iPhone 6 Plus
2013 A7芯片arm64： iPhone 5S
armv7s：iPhone5｜iPhone5C｜iPad4(iPad with Retina Display)
armv7：iPhone4｜iPhone4S｜iPad｜iPad2｜iPad3(The New iPad)｜iPad mini｜iPod Touch 3G｜iPod Touch4

模拟器32位处理器测试需要i386架构，
模拟器64位处理器测试需要x86_64架构，
真机32位处理器需要armv7,或者armv7s架构，
真机64位处理器需要arm64架构。

比如iOS11以上只支持arm64和arm64e系统架构的，最低支持这两个系统架构的设备是5S，所以arm64架构的App是不能在5S版本以下的机型上面运行的，这也是为什么5s以下版本的手机升级不了iOS11。举个例子：5C升级不了iOS11，也运行不了只支持arm64架构的App。

当然我们也可以修改Xcode设置来修改对应支持的系统架构，


2、设置架构.png

3、补充架构.png
3、修改架构示例：

由于图中选项2中我们得知，debug下只编译当前的架构，所以我们修改的架构的时候需要在release环境下进行，Edit scheme把环境切到release环境下(需要注意：不建议改Xcode这个Build Active Architecture Only的设置)

先直接在iOS11版本，Build编译一下

然后在这个路径下找到项目包和里面的Mach-O文件

~/Library/Developer/Xcode/DerivedData/

然后用file命令查看架构类型，打印台打印如下，64位的

/Users/fightmaster/Library/Developer/Xcode/DerivedData/LogicDemo1-gqzwykmqipnpppdvligxhzolxtpa/Build/Products/Debug-iphoneos/LogicDemo1.app
battleMage:LogicDemo1.app battleMage$ file LogicDemo1
LogicDemo1: Mach-O 64-bit executable arm64
battleMage:LogicDemo1.app battleMage$ 

再调整版本到11以下，比如10.3.1

然后修改设置，新增armv7,armv7s,arm64e

然后先clean项目，再build编译，'show in finder'后，直接用'file'查看Mach-O类型


/Users/fightmaster/Library/Developer/Xcode/DerivedData/LogicDemo1-gqzwykmqipnpppdvligxhzolxtpa/Build/Products/Release-iphoneos/LogicDemo1.app
battleMage:LogicDemo1.app battleMage$ file LogicDemo1
LogicDemo1: Mach-O universal binary with 4 architectures: [arm_v7:Mach-O executable arm_v7] [arm64:Mach-O 64-bit executable arm64]
LogicDemo1 (for architecture armv7):    Mach-O executable arm_v7
LogicDemo1 (for architecture armv7s):   Mach-O executable arm_v7s
LogicDemo1 (for architecture arm64):    Mach-O 64-bit executable arm64
LogicDemo1 (for architecture arm64e):   Mach-O 64-bit executable arm64
battleMage:LogicDemo1.app battleMage$ 

其中打印的
Mach-O universal binary with 4 architectures
代表了，Mach-O通用二进制文件，

这个通用二进制文件，在32位和64位架构的系统上都能读取。

三、通用二进制文件

1、通用二进制文件(Universal binary)

苹果公司提出的一种程序代码，能同时适用多种架构的二进制文件

同一个程序包中同时为多种架构提供最理想的性能

因为需要存储多种代码，通用二进制应用程序通常比单一平台二进制程序要大

但是由于两种架构有共同的非执行资源，所以并不会达到单一版本的两倍之多

而且由于执行中只调用一部分代码，运行起来并不需要额外的内存

2、使用lipo命令

使用lipo -info可以查看MachO文件包含的架构
$lipo -info MachO文件

使用lipo -thin可以拆分某种架构
$lipo MachO文件 -thin 架构 -output 输出文件路径

使用lipo -create合并多种架构
$lipo -create MachO1 MachO2 -output 输出文件路径

使用实例：

1、查看架构

battleMage:LogicDemo1.app battleMage$ lipo -info LogicDemo1
Architectures in the fat file: LogicDemo1 are: armv7 armv7s arm64 arm64e 

battleMage:LogicDemo1.app battleMage$ 

2、拆分一个armv7,一个arm64架构出来(原来的MachO文件并不会变)

battleMage:LogicDemo1.app battleMage$ lipo LogicDemo1 -thin  armv7 -output LogicDemo1_armv7
battleMage:LogicDemo1.app battleMage$

battleMage:LogicDemo1.app battleMage$ lipo LogicDemo1 -thin  arm64 -output LogicDemo1_arm64
battleMage:LogicDemo1.app battleMage$ 

3、合并架构

battleMage:LogicDemo1.app battleMage$ lipo -create LogicDemo1_armv7 LogicDemo1_arm64  -output machO_BM
battleMage:LogicDemo1.app battleMage$ 


5、通用二进制文件查看拆分合并.png
这种合并方式在我们合并静态库的时候，经常会用到，可以节约多个架构下公用资源的空间(代码部分是不可能节约的，只能节约资源部分的大小)。

四、MachO文件结构

下面我们来了解一下MachO文件的结构，先看苹果官方结构图如下：

主要组成可以大概分为三大块：

1、Header部分(包含该二进制文件的一般信息，类似一本书的序言)

字节顺序、架构类型、加载指令的数量等。
使得可以快速确认一些信息，比如当前文件用于32位还是64位，对应处理器是什么，文件类型是什么
2、Load commands 部分(一张包含很多内容的表，类似一本书的目录)

内容区包括区域的位置、符号表、动态符号表等。
3、Data段(类似一本书的详细内容)

包含Segement的具体数据
五、MachOView


4、MachO文件结构图.png
我们可以使用otool命令来查看Mach-O文件，也可以使用MachOView这个工具查看刚刚生成的MachO文件，先cd到当前文件夹，然后

$otool -f MachO

得到

battleMage:Desktop battleMage$ cd /Users/fightmaster/Desktop/20191016-应用安全-第六讲-MachO/006--MachO文件/备课代码 
battleMage:备课代码 battleMage$ otool -f MachO
Fat headers
fat_magic 0xcafebabe
nfat_arch 3
architecture 0
    cputype 12
    cpusubtype 9
    capabilities 0x0
    offset 16384
    size 73568
    align 2^14 (16384)
architecture 1
    cputype 12
    cpusubtype 11
    capabilities 0x0
    offset 98304
    size 73568
    align 2^14 (16384)
architecture 2
    cputype 16777228
    cpusubtype 0
    capabilities 0x0
    offset 180224
    size 73888
    align 2^14 (16384)
battleMage:备课代码 battleMage$ 

好的，下面我们使用MachOView来查看MachO文件，直接把这个MachO文件拖入MachOView里面就可以查看了，原理和otool类似，但是可读性增强了。


5、MachOView和otool类似.png
六、Header介绍

header结构图如下


6、MachOHeader结构.png
mach_header详细介绍如下

struct mach_header_64 {
    uint32_t    magic;        /* 魔数，快速定位属于64还是32位 */
    cpu_type_t    cputype;    /* CPU类型，比如ARM */
    cpu_subtype_t    cpusubtype;    /* CPU的具体类型 arm64\armv7 */
    uint32_t    filetype;    /* 文件类型，比如可执行文件 */
    uint32_t    ncmds;        /* loadCommands条数 */
    uint32_t    sizeofcmds;    /* LoadCommands的大小 */
    uint32_t    flags;        /* 标志位标识二进制文件支持的功能。主要是和系统加载、链接有关 */
    uint32_t    reserved;    /* reserved 保留部分*/
};

七、LoadCommands介绍

load Command结构图


7、loadCommand段
load commands详细介绍
```

/* Constants for the cmd field of all load commands, the type */

#define    LC_SEGMENT    0x1    /* segment of this file to be mapped */
#define    LC_SYMTAB    0x2    /* link-edit stab symbol table info */
#define    LC_SYMSEG    0x3    /* link-edit gdb symbol table info (obsolete) */
#define    LC_THREAD    0x4    /* thread */
#define    LC_UNIXTHREAD    0x5    /* unix thread (includes a stack) */
#define    LC_LOADFVMLIB    0x6    /* load a specified fixed VM shared library */
#define    LC_IDFVMLIB    0x7    /* fixed VM shared library identification */
#define    LC_IDENT    0x8    /* object identification info (obsolete) */
#define LC_FVMFILE    0x9    /* fixed VM file inclusion (internal use) */
#define LC_PREPAGE      0xa     /* prepage command (internal use) */
#define    LC_DYSYMTAB    0xb    /* dynamic link-edit symbol table info */
#define    LC_LOAD_DYLIB    0xc    /* load a dynamically linked shared library */
#define    LC_ID_DYLIB    0xd    /* dynamically linked shared lib ident */
#define LC_LOAD_DYLINKER 0xe    /* load a dynamic linker */
#define LC_ID_DYLINKER    0xf    /* dynamic linker identification */
#define    LC_PREBOUND_DYLIB 0x10    /* modules prebound for a dynamically */
/*  linked shared library */
#define    LC_ROUTINES    0x11    /* image routines */
#define    LC_SUB_FRAMEWORK 0x12    /* sub framework */
#define    LC_SUB_UMBRELLA 0x13    /* sub umbrella */
#define    LC_SUB_CLIENT    0x14    /* sub client */
#define    LC_SUB_LIBRARY  0x15    /* sub library */
#define    LC_TWOLEVEL_HINTS 0x16    /* two-level namespace lookup hints */
#define    LC_PREBIND_CKSUM  0x17    /* prebind checksum */

/*
 * load a dynamically linked shared library that is allowed to be missing
 * (all symbols are weak imported).
 */
#define    LC_LOAD_WEAK_DYLIB (0x18 | LC_REQ_DYLD)

#define    LC_SEGMENT_64    0x19    /* 64-bit segment of this file to be
mapped */
#define    LC_ROUTINES_64    0x1a    /* 64-bit image routines */
#define LC_UUID        0x1b    /* the uuid */
#define LC_RPATH       (0x1c | LC_REQ_DYLD)    /* runpath additions */
#define LC_CODE_SIGNATURE 0x1d    /* local of code signature */
#define LC_SEGMENT_SPLIT_INFO 0x1e /* local of info to split segments */
#define LC_REEXPORT_DYLIB (0x1f | LC_REQ_DYLD) /* load and re-export dylib */
#define    LC_LAZY_LOAD_DYLIB 0x20    /* delay load of dylib until first use */
#define    LC_ENCRYPTION_INFO 0x21    /* encrypted segment information */
#define    LC_DYLD_INFO     0x22    /* compressed dyld information */
#define    LC_DYLD_INFO_ONLY (0x22|LC_REQ_DYLD)    /* compressed dyld information only */
#define    LC_LOAD_UPWARD_DYLIB (0x23 | LC_REQ_DYLD) /* load upward dylib */
#define LC_VERSION_MIN_MACOSX 0x24   /* build for MacOSX min OS version */
#define LC_VERSION_MIN_IPHONEOS 0x25 /* build for iPhoneOS min OS version */
#define LC_FUNCTION_STARTS 0x26 /* compressed table of function start addresses */
#define LC_DYLD_ENVIRONMENT 0x27 /* string for dyld to treat
like environment variable */
#define LC_MAIN (0x28|LC_REQ_DYLD) /* replacement for LC_UNIXTHREAD */
#define LC_DATA_IN_CODE 0x29 /* table of non-instructions in __text */
#define LC_SOURCE_VERSION 0x2A /* source version used to build binary */
#define LC_DYLIB_CODE_SIGN_DRS 0x2B /* Code signing DRs copied from linked dylibs */
#define    LC_ENCRYPTION_INFO_64 0x2C /* 64-bit encrypted segment information */
#define LC_LINKER_OPTION 0x2D /* linker options in MH_OBJECT files */
#define LC_LINKER_OPTIMIZATION_HINT 0x2E /* optimization hints in MH_OBJECT files */
#define LC_VERSION_MIN_TVOS 0x2F /* build for AppleTV min OS version */
#define LC_VERSION_MIN_WATCHOS 0x30 /* build for Watch min OS version */
#define LC_NOTE 0x31 /* arbitrary data included within a Mach-O file */
#define LC_BUILD_VERSION 0x32 /* build for platform min OS version */
```
