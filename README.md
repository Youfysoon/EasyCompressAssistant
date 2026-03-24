# Easy Compress Assistant

Easy Compress Assistant is a easy-to-use utility used for compressing and decompressing files.

中文版本在英文版本下方。



<div align="center">
	<pre style="font-family: Consolas, Monaco, 'Courier New', monospace; line-height: 1; font-size: 12px;">
	@@@@@@@    @@@     @@@@@   @       @     
	@         @   @   @     @   @     @      
	@         @   @    @@        @   @       
	@@@@@@@  @@@@@@@     @@@      @ @        
	@        @     @       @@      @         
	@        @     @  @    @       @         
	@@@@@@@  @     @   @@@@        @         
	</pre>
	<pre style="font-family: Consolas, Monaco, 'Courier New', monospace; line-height: 1; font-size: 12px;">
		  @@@@@    @@@@@   @       @  @@@@@@   @@@@@@   @@@@@@@   @@@@@    @@@@@ 
		 @     @  @     @  @@     @@  @     @  @     @  @        @     @  @     @
		 @        @     @  @ @   @ @  @     @  @     @  @         @@       @@    
		 @        @     @  @ @   @ @  @@@@@@   @@@@@@   @@@@@@@     @@@      @@@ 
		 @        @     @  @  @ @  @  @        @ @      @             @@       @@
		 @     @  @     @  @  @ @  @  @        @  @@    @        @    @   @    @ 
		  @@@@@    @@@@@   @   @   @  @        @    @@  @@@@@@@   @@@@     @@@@  
	</pre>
	<pre style="font-family: Consolas, Monaco, 'Courier New', monospace; line-height: 1; font-size: 13px;">
			  @@@     @@@@@    @@@@@     @@@     @@@@@   @@@@@@@    @@@    @     @  @@@@@@@
			 @   @   @     @  @     @     @     @     @     @      @   @   @@    @     @   
			 @   @    @@       @@         @      @@         @      @   @   @ @   @     @   
			@@@@@@@     @@@      @@@      @        @@@      @     @@@@@@@  @  @  @     @   
			@     @       @@       @@     @          @@     @     @     @  @   @ @     @   
			@     @  @    @   @    @      @     @    @      @     @     @  @    @@     @   
			@     @   @@@@     @@@@      @@@     @@@@       @     @     @  @     @     @   
	</pre>
</div>

​	A fashionable gadget made by a college student who has been troubled by other swollen compress software.

​	<img src=".\.github\pictures\github_top_image.png" alt="github_top_image" style="zoom: 25%;" />



<pre style="font-size: 13px; color:grey;" align="center">
A cute image drawn by myself.
</pre>


​	This repository will continue to be updated!

## ⭐Core Features

#### One-Click Compression (Android Only)

​	You can find a “一键打包并分享” button when you are selecting a opening method for file(s).(Mysterious Eastern characters? It will be fixed recently!).It will compress all selected files to an archive and open a new share dialog to send this archive.

​	It's useful to send many images and Videos on Instant messaging Apps and make the chat log neat.

#### Responsive Design

​	Wide-screens will display the navigation bar on the left, while narrow-screens will display the navigation bar on the bottom.

####  Cache Management

​	It's natural for a App to generate some cache and junk during using it. When compressing documents, it's inevitable to store temporary files. But I have specifically studied the Android application cache mechanism for this purpose. The temporary file directory is separated from the application data directory (in the current version, only one configuration file are stored). Moreover, a setting item for automatically clearing the cache when the application is closed has been added in the settings. If enabled, it leaves almost no junk on your device! (Windows version also supports this.)

#### Multilingualism 

​	This App Supports displaying in two languages (Chinese and English) . The default language is Chinese. It can be switched in the settings. 😘

#### Rich comments in source code

​	The code (in Dart) is well-commented for each function, and the code directory and structure are clear, making it suitable for beginners to learn basic grammar of Flutter, font introduction, the use of FluentUI, and other functions.

#### Cross-platform 

​	Currently, it is available for Android, Windows. HarmonyOS, and Linux support is also scheduled for the future!



### ⚠ Known issues

#### Multilingualism imperfection

​	As you see,  'One-click to Compress' feature will display 'Mysterious Eastern characters'(“一键打包并分享”). This problem will be fix very recently, It is reasoned by Kotlin code.

#### Can't Compress extremely large files

​	In the Android version, when using the one-click packaging function to package extremely large files (> 1.5GB), there is a probability that the application may become unresponsive. The cause is currently under investigation. Currently, a hard limit is set that the operation will be refused when the total volume of the selected files exceeds 1GB.


### 🔨 Future Updates

*Number of 🔥 indicates priority.*

1. Fix multilingual bugs. 🔥
2. Add one-click extraction from outside the app. 🔥
3. Add in-app archive browsing functionality.
4. Add iOS support and aim for App Store release. 🔥🔥🔥
5. Add HarmonyOS (OpenHarmony) mobile support. 🔥🔥
6. Add HarmonyOS PC support.
7. Optimize in-app operation logic. 🔥🔥
8. Update the app icon and draw a detailed image of the mascot for the app 💦. 🔥
9. Improve README and other documentation. 🔥🔥🔥
10. Optimize responsive design. 🔥🔥🔥
11. Desktop optimization (supporting file dragging, Windows context menu registration and opening methods, etc.) 🔥🔥

### 🙇‍Open Source & Acknowledgments

​	This project relies on the following frameworks and libraries. Without the contributions of the open-source community, this small tool would not have been possible. Sincere thanks to the authors of these projects!

| Project / Library           | License      |
| --------------------------- | ------------ |
| Flutter Framework           | BSD 3-Clause |
| fluent_ui                   | MIT License  |
| archive                     | MIT License  |
| permission_handler          | BSD 3-Clause |
| file_selector               | BSD 3-Clause |
| shared_preferences          | BSD 3-Clause |
| url_launcher                | BSD 3-Clause |
| flutter_local_notifications | BSD 3-Clause |

​	This project is open-sourced under the **BSD 3-Clause License**. Please use this project in compliance with the relevant provisions of the license!

### 🌏 Contact & Sponsorship

**Author Email:** youfy6@outlook.com
	*(Please contact in Chinese or English. Only emails related to the project will be accepted; please note that your inquiry originates from GitHub. Other emails will be rejected.)*

**Sponsor the Author:** Although I am just an ordinary college student, I hope that friends who are able to do so might consider a small sponsorship. Every bit of your support is the motivation that encourages me to continue updating this project! (QR-code for Sponsorship is at the bottom of this README,only WechatPay and Alipay now)

**About Issue:** I am busy with student affairs and my own life, so I can only check 'Issues' once a week, nevertheless, I'll be grateful if you can give me some advice or find some bugs and tell me in 'Issues'. I'll reply one by one if I see.



I'm not a English first speaker,please excuse me if my expression is not clear.


# Easy Compress Assistant极速压缩助手

#### 一个基于Flutter制作的简单压缩小工具

​	一个大学生因受不了手机端各种垃圾压缩软件选择自己制造的时尚小垃圾。



<img src=".\.github\pictures\github_top_image.png" alt="github_top_image" style="zoom: 25%;" />

<pre style="font-size: 13px; color:grey;" align="center">
自己画的
</pre>

​	将持续更新，喜欢的朋友点个星😘。

## ⭐亮点功能

#### 安卓版本带有一键打包功能，一键快捷压缩，手机也能办到！

​    安卓设备可在文件或多文件打开方式中以及图像视频分享界面找到“一键打包并分享”按钮。避免社交软件压缩画质的同时也方便多文件发送并减少流量消耗。

#### 响应式设计，横屏或窄屏，都能适配！

​    宽型屏幕会显示左侧导航栏，而手机等窄型屏幕将会显示底部导航栏。

#### 缓存管理

​    应用使用过程中产生缓存？那是自然，压缩文档时不可避免需要存放临时文件，但是我专门为此研究了安卓的应用缓存机制，临时文件目录与应用数据目录（目前版本仅存放配置文件）分离，并且在设置中加入了在应用关闭时自动清除缓存的设置项，只要你想，它就几乎不会在你手机中留下一堆垃圾！

#### 多语言

​    支持中英双语，默认中文，可在设置中切换。😘

#### 代码注释丰富，结构清晰

​    代码（dart）每个函数都做了注释，且代码目录和结构清晰，适合初学者学习响应式设计，引入字体，FluentUI的使用等功能；

#### 跨平台

​    目前已经支持Android,Windows，鸿蒙和Linux的支持已在日程上！



## ⚠当前版本已知问题

#### 多语言不完善

​	目前多语言是手动设置的，而没有根据系统语言来自动设置，这导致使用英文的人会有些难受，以及一键打包的子进程目前没有做英文适配。

#### 一键打包功能打包超大文件有概率无响应

​	安卓版本中，使用一键打包功能打包超大文件(>1.5GB)时有概率导致应用程序无响应，原因正在排查中，当前设置硬性限制在选择的文件总体积大于1GB时拒绝操作。

#### 响应式设计尚未完善

​	部分支持强制横屏的竖屏安卓设备在强制横屏后，会导致整体页面被“压扁”而不是切换成横屏版。



### 🔨未来更新

​	*火焰数量表示优先程度

​	1.修复多语言的bug。🔥

​	2.添加应用外一键解压功能。🔥

​	3.添加应用内解压界面浏览压缩文件内容功能。🔥🔥

​	4.添加IOS设备的支持并争取上架AppStore。🔥🔥🔥

​	5.添加鸿蒙手机支持。🔥🔥

​	6.添加鸿蒙PC支持。

​	7.优化应用内操作逻辑。🔥🔥

​	8.更新图标和给压缩娘画人设图💦。🔥

​	9.README文档完善及编写代码文档。🔥

​	10.响应式设计优化。🔥🔥🔥

​	11.桌面端优化（支持拖拽文件，Windows注册上下文菜单和打开方式等）🔥🔥

### 🙇‍开源与致谢

​	项目依赖以下框架和库，没有开源社区的贡献者，这个小工具就无从落地，向这些项目的作者致以诚挚谢意！

| 项目/库                      | 许可证        |
| --------------------------- | ------------ |
| Flutter Framework           | BSD 3-Clause |
| fluent_ui                   | MIT License  |
| archive                     | MIT License  |
| permission_handler          | BSD 3-Clause |
| file_selector               | BSD 3-Clause |
| shared_preferences          | BSD 3-Clause |
| url_launcher                | BSD 3-Clause |
| flutter_local_notifications | BSD 3-Clause |

  本项目将以BSD 3-Clause协议进行开源，请在遵守协议的相关规定下使用本项目！

### 🌏联系与赞助

​	作者邮箱：youfy6@outlook.com(请使用中文或英文联系，请只发出与项目有关的邮件并注明来处是Github，否则会被拒收)

​	赞助作者：虽然我只是一个普普通通大学生，仍然希望有能力的朋友可以小小地赞助一下，您的每一点赞助都是激励我继续更新的动力！

​	关于Issue: 本人平时比较忙，Github上的Issue每周回复一次，有建议或者发现bug可以直接在Issue中提出，看到都会回复，感谢一切提出问题和建议的大佬！

​	<img src=".\.github\pictures\weixinAlipay.jpg" alt="weixinAlipay" style="zoom:20%;" align="center"/>

