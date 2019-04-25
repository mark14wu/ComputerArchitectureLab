# 			                    			体系结构Lab1报告

PB16001800 吴昊

## 1 未完成模块设计思路

### 	0X01  ALU

有三个输入参数AluContrl、Operand1和Operand2，一个输出参数AluOut，设计思路是主体一个case语句，根据AluContrl的值来对Operand1、Operand2进行操作，然后赋值给AluOut。

| **ALU运算** |    **指令**    |                        **操作**                         |
| :---------: | :------------: | :-----------------------------------------------------: |
| SLL  (0000) |    sll,slli    | 根据Operand2的低五位shamt，Operand1左移shamt次，低位补0 |
| SLR (0001)  |    srl,srli    |              Operand1右移shamt次，高位补0               |
| SRA (0010)  |    sra,srai    |            Operand1右移shamt次，高位补符号位            |
| ADD (0011)  | add,addi,auipc |                        加法运算                         |
| SUB (0100)  |      sub       |                    Operand1-Operand2                    |
| XOR (0101)  |    xor,xori    |                        异或运算                         |
|  OR (0110)  |     or,ori     |                         或运算                          |
| AND (0111)  |    and,andi    |                         与运算                          |
| SLT (1000)  |    slt,slti    |  有符号数比较，如果Operand1<Operand2，输出1，否则输出0  |
| SLTU (1001) |   sltu,sltiu   |  无符号数比较，如果Operand1<Operand2，输出1，否则输出0  |
| LUI (1010)  |      lui       |                  输出等于第二个操作数                   |

### 	0X02  BranchDecisionMaking

三个输入BranchTypeE、Operand1、Operand2, 一个输出BranchE，根据BranchType不同进行不同的比较，结果为真时，BranchE = 1，否则BranchE = 0。

### 	0X03  ControlUnit

三个输入参数Op、Fn3、Fn7，十二个输出参数如下：
	JalD==1          表示Jal指令到达ID译码阶段
	JalrD==1         表示Jalr指令到达ID译码阶段
	RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在	Parameters.v中
	MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,    
	MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
	LoadNpcD==1      表示将NextPC输出到ResultM    
	RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理    
	BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
	AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
	AluSrc2D         表示Alu输入源2的选择
	AluSrc1D         表示Alu输入源1的选择
	ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中 

下面根据指令类型分析：

- load类：

  load类的Op码都为0000011,区别在Fn3，共同需求如下：

  - **ID**: ImmType = ITYPE

  - **EX**: RegReadD = 10, AluSrc1D = 0, AluSrc2D = 10, AluContrlD = ADD

  - **MEM**: MemWriteD = 0000, LoadNpcD = 0

  - **WB**: LoadedBytesSelect取自计算出的地址的最低两位，RegWriteD根据不同指令不同：

    | funct3    | lb(000) | lh(001) | lw(010) | lbu(100) | lhu(101) |
    | --------- | ------- | ------- | ------- | -------- | -------- |
    | RegWriteD | LB(001) | LH(010) | LW(011) | LBU(100) | LHU(101) |

- store类：
  store类的Op码都为0100011,区别在Fn3，共同需求如下：

  - **ID**: ImmType = STYPE

  - **EX**: RegReadD = 11, AluSrc1D = 0, AluSrc2D = 10, AluContrlD = ADD

  - **MEM**: LoadNpcD = 0，MemWriteD根据不同指令不同：

    | Fn3       | sb(000) | sh(001) | s(010) |
    | --------- | ------- | ------- | ------ |
    | MemWriteD | 0001    | 0011    | 1111   |

  - **WB**: store指令无需写回，**WB**所有控制信号为缺省值

- 寄存器-寄存器类算逻指令：

  这一类指令的Op码都为0110011，由Fn3和Fn7决定具体的指令操作
  - **ID**: ImmType = RTYPE

  - **EX**: RegReadD = 11, AluSrc1D = 0, AluSrc2D = 00, AluContrlD 见ALU模块

  - **MEM**: 无必要操作

  - **WB**: MemToRegD = 0

- 寄存器-立即数类算逻指令：

  这一类指令的Op码都为0010011，由Fn3决定具体的指令操作
  - **ID**: ImmType = ITYPE

  - **EX**: RegReadD = 10, AluSrc1D = 0, AluSrc2D = 10, AluContrlD 见ALU模块

  - **MEM**: 无必要操作

  - **WB**: MemToRegD = 0

- 寄存器-寄存器类算逻指令：

  这一类指令的Op码都为0110011，由Fn3和Fn7决定具体的指令操作
  - **ID**: ImmType = RTYPE

  - **EX**: RegReadD = 11, AluSrc1D = 0, AluSrc2D = 00, AluContrlD 见ALU模块

  - **MEM**: 无必要操作

  - **WB**: MemToRegD = 0

- 其他算逻指令：
  LUI的Op码都为0110111，AUIPC的Op码为0010111，两条指令均可以用Op码唯一标识。

  - **ID**: ImmType = UTYPE

  - **EX**: RegReadD = 00, AluSrc1D = 1(LUI此处取0也可以), AluSrc2D = 10, LUI指令的ALU操作为LUI，AUIPC的ALU操作为ADD

  - **MEM**: 无必要操作

  - **WB**: MemToRegD = 0

- 跳转指令：
  JAL的Op码都为1101111，JALR的Op码为1100111，两条指令均可以用Op码唯一标识。

  JAL：

  - **ID**: ImmType = JTYPE

  - **EX**: RegReadD = 00, AluSrc1D = 1, AluSrc2D = 10, AluContrlD = ADD

  - **MEM**: 无必要操作

  - **WB**: MemToRegD = 0

  JALR：

  - **ID**: ImmType = ITYPE

  - **EX**: RegReadD = 10, AluSrc1D = 0, AluSrc2D = 10, AluContrlD = ADD

  - **MEM**: LoadNpcD = 1 

  - **WB**: MemToRegD = 0

- 分支指令：
  分支指令的Op码都为1100011，根据不同的Fn3来标识不同的指令：

  - **ID**: ImmType = BTYPE
  - **EX**: RegReadD = 11, AluSrc1D = 1, AluSrc2D = 00, BranchTypeD如下图中所示
  - **MEM**: 无必要操作
  - **WB**: 无必要操作

总的数据指令和控制单元输出的相关信号如下：

![1554026414574](C:\Users\kotori\AppData\Roaming\Typora\typora-user-images\1554026414574.png)

### 	0X04  DataExt

该模块用来处理非字对齐load的情形，同时根据load的不同模式对Data Mem中load的数进行符号或者无符号拓展，组合逻辑电路，本模块由两个阶段组成，第一个阶段选择合适的字节，第二个阶段将对应的字节进行有符号扩展，得到32位数据并输出。
	这里不同的 RegWriteW 信号表明不同的读取方式， LoadedByteSelect 为计算出的地址的低两位，表示读取的位置的起点。

### 	0X05  HarzardUnit

HarzardUnit用来处理流水线冲突，通过插入气泡，forward以及冲刷流水段解决数据相关和控制相关，组合逻辑电路。

输入

CpuRst                                    				外部信号，用来初始化CPU，当CpuRst==1时CPU全局复位清零（所有段寄存器flush），Cpu_Rst==0时cpu开始执行指令

ICacheMiss, DCacheMiss                    		用来处理cache miss

BranchE, JalrE, JalD                      			用来处理控制相关

Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW         用来处理数据相关，分别表示源寄存器1号码，源寄存器2号码，目标寄存器号码

RegReadE RegReadD[1]==1                               表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理

RegWriteM, RegWriteW                      		用来处理数据相关，RegWrite!=3'b0说明对目标寄存器有写入操作

MemToRegE                                 			表示Ex段当前指令 从Data Memory中加载数据到寄存器中

输出

StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW    控制五个段寄存器进行stall（维持状态不变）和flush（清零）

Forward1E, Forward2E                                        控制forward

发生冲突的可能情况：

1. cache失效
2. 数据相关
3. 分支指令和跳转

不同的情况需要具体分析并给出对应的解决方案。

### 	0X06 ImmOperandUnit

ImmOperandUnit利用正在被译码的指令的部分编码值，生成不同类型的32bit立即数

输入

IN        是指令除了opcode以外的部分编码值

Type      表示立即数编码类型，全部类型定义在Parameters.v中

输出

OUT       表示指令对应的立即数32bit实际值

这里根据不同的控制模块输出的ImmTypeD为输入的Type ，即指令的类型，可以判断并整合出不同的立即数。具体实现表如下：

| ImmTypeD(Type) | OUT                                                       |
| :------------: | --------------------------------------------------------- |
|   000(RTYPE)   | 0                                                         |
|   001(ITYPE)   | IN[31: 20]为低12位                                        |
|   010(STYPE)   | IN[31: 25] + IN[11: 7]为低12位                            |
|   011(BTYPE)   | IN[31] + IN[7] + IN[30: 25] + IN[11: 8]为低12位           |
|   100(UTYPE)   | IN[31: 12]为高20位，低位补0                               |
|   101(JTYPE)   | IN[31] + IN[19: 12] + IN[20] + IN[30: 21] + 0,最低位恒为0 |

### 	0X07  NPC_Generator

NPC_Generator是用来生成Next PC值得模块，根据不同的跳转信号选择不同的新PC值，如下表：

| BrE  | JalrE | JalD | PC_in   |
| ---- | ----- | ---- | ------- |
| 0    | 0     | 0    | PCF + 4 |
| 1    | 0     | *    | BrT     |
| 0    | 1     | *    | JalrT   |
| 0    | 0     | 1    | JalT    |

## 2 回答问题

1. 为什么将DataMemory和InstructionMemory嵌入在段寄存器中？

   如果不这样做，ID段和MEM段都需要耗费两个时钟周期才能完成，这就降低了流水线的效率。

2. DataMemory和InstructionMemory输入地址是字（32bit）地址，如何将访存地址转化为字地址输入进去？

   将访存地址的低两位清零，从而生成能被存储器识别的字地址，低两位保存在LoadedBytesSelect 中。

3. 如何实现DataMemory的非字对齐的Load？

   通过DataExt模块实现。

4. 如何实现DataMemory的非字对齐的Store？

   通过4位的MemWriteM信号实现。

5. 为什么RegFile的时钟要取反？

   如果RegFile在上升沿写入的话，相当于WB段需要耗费两个周期才能完成。

6. NPC_Generator中对于不同跳转target的选择有没有优先级？

   有，流水级深的跳转target优先级高，因为流水级深的指令按照指令顺序最靠前。

7. ALU模块中，默认wire变量是有符号数还是无符号数？

   wire变量可以直接指定为有符号数或无符号数。

8. AluSrc1E执行哪些指令时等于1’b1？

   执行AUIPC指令时。

9. AluSrc2E执行哪些指令时等于2‘b01？

   执行立即数移位类指令：slli、srli、srai。

10. 哪条指令执行过程中会使得LoadNpcD==1？

    JAL和JALR

11. DataExt模块中，LoadedBytesSelect的意义是什么？

    保存了访存地址的低两位

12. Harzard模块中，有哪几类冲突需要插入气泡？

    load类指令在EX段执行时，若其写入寄存器与ID段读取寄存器相同时，需要插入stall。

13. Harzard模块中采用默认不跳转的策略，遇到branch指令时，如何控制flush和stall信号？

    当遇到branch指令时，默认不跳转继续执行。当EX段产生branchE信号时，若 branchE=1 ，向IF和ID段寄存器发出flush信号，并生成新的PC继续执行；若 branchE=0 ，顺序执行指令。分支指令时不用stall。

14. Harzard模块中，RegReadE信号有什么用？

    判断某指令是否用到寄存器（而不是立即数指令）

15. 0号寄存器值始终为0，是否会对forward的处理产生影响？

    会。先写后读冒险时若写入的寄存器为0号，则不用转发写入数据到读取寄存器处（认为写入无效，寄存器值不变）。

