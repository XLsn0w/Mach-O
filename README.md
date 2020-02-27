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

二、ipa内容介绍
首先来介绍下ipa包。ipa实际上是一个压缩包，我们从App Store下载的应用实际上都是压缩包。压缩包中包含.app的文件，.app文件实际上是一个带后缀的文件夹。在app中，存在如下文件：
1）资源文件
资源文件包括我们常用的内置文件，如图片、plist以及生成的.car文件等。
2）可执行程序
 


可执行程序是最核心的文件，除了代码和数据外，里面包含code signature和ENCRYPTION。
 



 
上图中展示的是code signature和ENCRYPTION在LoadCommad中的索引。展开ENCRYPTION后可以看到ENCRYPTION的偏移地址和大小。Crypt ID标记该Mach-O文件是否被加密，如果加密则Crypt ID = 1，否则为0。
 


那么这个ENCRYPTION是什么？谁负责加密的？谁负责解密的？如果文件没有加密是否还能被运行？
实际上加密的ENCRYPTION就是我们所说的壳，砸壳就是将ENCRYPTION进行解密操作。从上面的截图我们可以看出，ENCRYPTION的起始偏移地址为文件的0x4000位置，而结束位置可以计算出为0x4000+0x424000 = 0x428000。这个范围正好对应着Mach-O的文本段（不是1:1的，起始位置0x4000，而不是0x0）。也就是说加密实际上是对TEXT段进行加密。TEXT内存储的是代码信息，包括函数指令、类名、方法名、字符串信息等。
 


对TEXT进行加密，加密后的Mach-O文件无法获取到代码信息，也就是说指令信息我们无法直接获取到了。除了指令外，在DATA段中，有些数据存储的是指针信息，指向TEXT段的数据，这样的数据也无法解析出来。
 


 
加壳之后的应用，在不解密的情况下，无法暴露指令和文本数据，这能很好地保护应用。这个壳是在上传到App Store由App Store进行加密的，用户下载的应用也是被加壳的应用。存储在手机的文件也是被加密的，只有在应用运行时，iOS才会对文件进行解密，也就是说在用户手机上运行的文件都是解密脱壳后的文件。我们在进行真机调试时，安装到手机上的文件是未加密的，这个时候Crypt ID标记为0。iOS系统在识别Crypt ID为0时不会进行解密处理。
3）code signature
 


code signature 包含资源文件的签名信息，如果资源文件被更改替换，那么签名是无法验证通过的。因此下载XIB等方式实现UI的动态布局是无法实现的。那么这里的code signature与Mach-O文件里的signature是一样的吗？当然是不一样的。这里的签名验证的是资源文件，而Mach-O文件中的code signature 是验证Mach-O是否被篡改以及是否是apple允许安装的应用。
三、dumpdecrypted砸壳原理简介
砸壳的技术方案可以分为两种，一种是静态砸壳，一种是动态砸壳。静态砸壳的原理是硬破解apple的加密算法，目前是一种使用频率极低的技术方案。动态砸壳是利用iOS将文件解密后加载到内存后，将解密数据拷贝到磁盘的方案。动态砸壳目前成熟的方案很多，在这里介绍下dumpdecrypted的方式。
dumpdecrypted是以动态库的方式，将代码注入到目标进程中。那么如何让一个应用程序在运行时加载我们的动态库呢？目前的方案主要有两种：
1）修改Mach-O文件，在LC中，添加LC_LOAD_DYLIB信息，然后重签名运行。
这需要开发者对Mach-O文件有足够的了解，否则很容易损毁文件。不过已经有相应的工具：https://github.com/Tyilo/insert_dylib。有兴趣的可以试验下。
2）通过在手机的终端输入DYLD_INSERT_LIBRARIES="动态库"  APP路径  命令（这就要求手机必须是越狱的），指定应用加载动态库，dumpdecrypted采用的就是这种方式。
DYLD_INSERT_LIBRARIES是系统的环境变量。通过在终端输入man dyld 可以查看环境变量及其解释。DYLD_INSERT_LIBRARIES的解释如下：
 


除了DYLD_INSERT_LIBRARIES变量外，我们可以打印看到还有许多环境变量，
 


这些变量的解释和用处都在终端中有说明，在此不再一一解释。额外提一句，我们可以在应用中通过getenv函数检测是否存在环境变量，这可以作为安全监测数据。
在动态库被加载后，标记为__attribute__((constructor))的函数会被执行。启动函数执行后，核心步骤只做3件事
1）在加密的原文件中复制从起始位置开始的未加密的数据。
2）从内存中的文件复制解密的数据。
3）在加密原文件中跳过加密部分，拷贝剩余未加密数据。
 


这3件事做完后，应用程序脱壳就完成了。在阅读代码时，我有两个问题：
1）函数为什么指定成
void dumptofile(int argc, const char **argv, const char **envp, const char **apple, struct ProgramVars *pvars)类型？
后来发现实际上这是__attribute__((constructor))固定的函数类型，5个参数分别代表了(参数个数，参数列表，环境变量，可执行程序路径，文件信息)。
2）如何获取应用在磁盘的路径？
argv[0]，也就是参数列表的第一个，代表的是可执行文件的路径。这与main函数类似。通过apple也可以获取到文件路径，dumpdecrypted使用的是argv[0]。
 


四、重签名
在脱壳后，只能保证Mach-O文件变成可读的，即函数指令和字符信息能暴露出来，但是此时的文件并不能运行。这是由于apple除了做代码可读化的加密外，还做了签名验证，从而保证在iOS系统中成功运行的程序都是被苹果校验过的，被篡改的或其他的渠道程序不能被加载。因此需要对砸壳后的文件进行重签名。
1）签名的作用
在应用ipa内，存在多处签名，不同的签名有不同的作用。但是这些签名整体目的只有一个：所有安装和运行的APP必须是苹果允许的。也就是说，在安装时iOS会验证一些文件的签名，在启动时iOS系统也会验证一部分文件的签名。
2）签名文件
从App Store下载的应用验证最简单，只要iOS系统用公钥验证APP 在App Store后台用私钥生成的签名即可。但是我们开发过程中的真机调试是如何进行签名验证呢？首先来看下面这个流程图（图片摘自http://blog.cnbang.net/tech/3386/）
 


签名的秘钥一共有两对，针对这些步骤我们来一步步解释这些步骤在什么时候操作的，如何操作的以及形式是什么。
首先，两对秘钥中，App Store 的私钥和iOS系统内部的公钥我们接触不到，因此不做解释。但是Mac 中的公钥和私钥我们确实使用过。
MAC 公钥：公钥即是我们在钥匙串中申请的.certSigningRequest文件。
MAC 私钥：在申请certSigningRequest文件文件时生成的配对的私钥，保存在本地电脑中。
证书生成：证书生成对应图中步骤3，我们将MAC的公钥上传到苹果后台通过苹果的私钥进行签名，签名后生成的文件即是开发者证书。
描述文件：由于苹果要限制安装的设备、安装的APP以及所具备的权限（如推送），苹果将这些信息连同证书合并再签名得到的文件就是描述文件。描述文件在开发阶段存放在APP包内，文件名为embedded.mobileprovision。至此，我们可以知道已经存在两处签名了，1是苹果对本地公钥的签名，2是对证书描述文件的签名，这两处签名都是App Store的私钥进行签名的。
在通过Xcode打包时，Xcode会通过本地私钥对APP进行签名，这个签名上图中表现出一部分，实际上签名有两处：一处是对资源进行签名，也就是说ipa内所有的资源文件包括xib、png等都需要进行签名，签名存放在code signature中。另一处签名是针对代码的签名（这个签名不是加密壳），ipa内的Mach-O文件的code signature存放着打包时的签名信息。
3、验证流程
有了这么多的签名，那么这些签名是在什么时候进行验证的呢？验证分两个步骤进行，分别是安装时验证和启动时验证。
1）安装时验证
在安装时，iOS系统会取出code signature验证各个资源文件的签名。如果资源文件都验证通过，那么取出embedded.mobileprovision，验证设备ID，如果该设备在设备列表中并且相符，那么安装成功。但是INHOUSE 版本和 App Store版的APP不需要验证embedded.mobileprovision。（因为不存在这个文件，这是由于发布市场不需要放开验证权限，与你的Mac和iPhone无关，所以也就不需要你的公钥）
2）启动时验证
验证bundle id 与embedded.mobileprovision中的APPID是否一致，验证entitlements与embedded.mobileprovision的entitlements是否一致。如果一致则尝试将执行可执行程序。在iOS内核执行execve函数调用Mach-O可执行文件之前，会先获取Mach-O的code signature。那么code signature里到底存的啥？可以通过codesign -dvvvvv 查看Mach-O的code signature，里面存的都是签名信息。
 


 
五、iOS应用包扫描
在我们ipa包提交到苹果审核后，苹果会通过代码扫描我们应用程序所使用到的API。那么苹果根据我们提交的应用包，能扫描到什么内容呢？
1、示例
符号信息在打包时存储在两个Mach-O文件中：1、可执行程序。2、DSYM文件。可执行程序中存在类相关信息及动态链接相关符号。DSYM是在打包时从可执行文件中剥离出来的Mach-O文件，包含静态链接相关符号、代码路径等完备信息。如果打包时不选用苹果自带的崩溃统计工具，DSYM只上传给buggly使用。苹果所能扫描的只有资源文件以及可执行程序。但是除了可执行程序除了符号信息外，还包含其他信息。
1）扫描类信息
类关键信息包括类名、方法名、方法描述（参数、返回值类型等）、类是否被使用、方法是否被使用。
 


从上图中我们可以看出APP中有个KFYGoodDetailsViewController这个类。
 


我们还能知道代码中包含changeStarForegrandViewWithPoint:方法。
我们还能拿到所有函数的描述

 
可以知道函数的返回值类型是什么，参数类型是什么，参数有多少，但是参数的命名获取不到（NSString*） name，这个name获取不到。
 


还能知道有哪些类被使用过，包括系统的类已经自己的声明的类。但是通过XIB 绑定的类不会被加入到classref。字符串动态调用的类也不被加入。
2）扫描动态链接符号
动态链接符号包括动态库的函数、变量、私有函数。
 


扫描符号可以通过nm 命令快速扫描输出到文件
 

U代表是未定义符号（动态库中的函数），而T表示的是符号定义在Text段（自己写的函数）。
 
3）扫描字符串
字符串包括：OC字符串和C字符串
 


使用到的@"%.2f"，@“backgroundStar”等



六、总结
Mach-O文件的作用其实跟打孔纸带的作用是一样的，只不过Mach-O文件描述的内容更加丰富。除了代码和数据外，Mach-O还包含了加密、验证这样的机制，使得代码更加安全。
