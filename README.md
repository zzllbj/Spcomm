# Spcomm
2018-04-02
1、升级到2.2

2、增加AES加解密功能

2018-03-28

1、调整窗体长宽和高

2018-03-28

1、修复当选择输入数据为HEX时，输入的是中文，会引起出错的问题


2018-03-27

1、升级到2.1

2、增加hash256功能

3、HEX输入长度有问题时提示补0

2018-03-23

1、升级到2.0

2、增加SM4功能

2018-03-09

1、升级到1.09

2、修复计算DES的时候，数据末尾为0时返回失败的情况

2017-09-13
修改发送区界面，更方便操作、直观

2017-05-09

1、增加外网IP获取的准确率


2017-05-09

1、增加230400、460800两个波特率

2、选择波特率时可以手动输入

2017-03-28

程序关闭时，如果memo中有字符才提示是否关闭，没有则直接关闭

2017-03-16

将皮肤控件改5.6的版本，解决程序退出时返回错误的提示

V1.8 2017-03-10

1、在扩展板里增加DES的加解密功能

2、增加字符形式的16进制数转换成ASCII码的功能


V1.7 2016-09-07

1、indy的 TIdIPWatch 控件的historyenabled设为false，这样将不在桌面显示iphist.dat文件

V1.7-DEBUG 2016-08-04
1、使用vclskin2.60 For Delphi7 Cracked皮肤，去掉XPmain，避免按ALT后button消失的现象。
2、修复关闭串口后、端口会变的问题


V1.6  2016-07-03

1、增加多字符串能发送的分包总数（大屏幕下可发送更多）

2、添加实时保存功能


V1.5   2016-06-26

1、增加多字符串能发送的分包总数

2、将多字符串保存功能移到关闭应用的时候


V1.4   2016-06-17

1、优化TCP服务器功能

2、修复自动回复发送的字节数不显示在状态栏的问题

3、如果能连外网，则在TCP服务器上显示的是外网IP，否则显示本地IP

4、增加退出前再次确认操作


V1.3   2016-05-29

1、增加TCP功能


V1.2    2016-05-19

1、在扩展功能中增加HID收发的功能


V1.1    2016-05-16

1、优化列举串口列表操作

------------------------------------------------------------------------------------------------

V1.0    2016-05-13

1、自动检测串口数，并列举出来，如无串口则显示1-16的串口

2、发送区增加右键功能，可选择清除；点击、回车发送，双击可发送文件

3、点击扩展按键，可以循环发送16组不能的字符串数据

4、接收超过20万行自动保存程序目录下的log文件中，自动保存后会清空数据，并且重新接收。也可手动保存

5、接收时可选择是否带时间戳、是否需要转化成HEX显示、可暂停

6、对发送的数据可进行异或、累加和校验

7、可显示发送、接收的字节、当前窗口的总行数
