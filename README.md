ParaCraftSDK
============

Open Source SDK and tools for ParaCraft

---++ 创意空间ParaCraftSDK使用说明
| Authors | LiXizhi, ... |
| Date 	  | 2014.3.21 |
| 最新版  | https://github.com/LiXizhi/ParaCraftSDK | 

---++ 介绍
ParaCraftSDK是ParaEngine和NPL语言的一个面向学生用户的开发环境。 目的是让感兴趣的同学可以更深入的学习和研究创意空间和它的创作语言NPL。 时间有限， 这次的版本只提供了4个简单的例子。 我们在未来的几个月，会开放10万行左右的代码给大家学习. 并且会不断的增加这方面的教程。 以及整理我们内部的NPL语言开发环境，开放给大家学习和使用。

希望更多的青年人可以从玩游戏， 到了解制作游戏，到学会自己写程序；并掌握最领先的语言和开发环境。

创意空间SDK的目标是让用户可以做自己的产品（不限于哈奇和ParaCraft插件）， 并发布到PC, Web, Android, iOS等平台。

一切刚刚开始...

---++ 如何运行
点击start.bat。 

【注】SDK每天都可能更新，请与[[https://github.com/LiXizhi/ParaCraftSDK]] 持同步
最新版下载地址 [[https://github.com/LiXizhi/ParaCraftSDK/archive/master.zip]]

---+++ 背后发生了什么？
首次运行start.bat会自动安装ParaCraft。但是第二次运行，SDK版本不会自动更新，
所以如果你希望与最新的官方ParaCraft软件同步， 请运行upgrade.bat手工升级。 
这点非常重要。 

---+++ 目录说明
./samples 			例子程序和源代码。运行每个子目录中的start.bat
./redist 			发布与运行环境，模拟用户的安装目录
./src				引擎部分源代码
./apps				用户自己开发的应用在这里
./tutorials			教程应用

---++ 文件说明
./Start.bat		启动创意空间（但不更新）
./Upgrade.bat	更新Redist下的创意空间
./CreateApp.bat	创建你自己的应用
./Publish.bat   发布你的应用
./samples/[foldername]/Run.bat     运行各种演示程序
./samples/[foldername]/Source      程序的原代码


---++ 更多介绍
ParaCraftSDK是ParaEngine和NPL语言的子集。 随着我们将功能逐步开放， 会和ParaEngineSDK合并。 
ParaCraftSDK和ParaEngine都是围绕NPL语言展开的。 我们使用的底层代码是跨平台的C++， 脚本层是基于Lua的NPL语言。 
软件可以使用C++和NPL语言来扩展，所以几乎支持所有C++可以扩展到的语言系统。例如我们有部分插件和工具是用mono C#完成的。
我们建议开发者尽可能的使用NPL来写应用代码，保证未来可以更顺利的发布到多个平台上。 

您可以选择自己喜欢的开发环境， 但是我们自己在用Visual Studio。 并且我们开发了基于Visual Studio的NPL语言调试与开发环境。 
我们的软件在微软的VS平台上是下载和使用量最多的Lua语言编辑环境，可以从VisualStudio Gallery中直接安装. 

---++ 目标用户
目前我们主要针对学生（从小学5年级到大学生都可以）. 
人类从很早就可以理解和使用计算机语言了。 NPL（Lua）作为一种语言很适合学生学习，并且终身授拥。
你知道么？ 下面这些产品有90%的逻辑代码都是用Lua语言写的。 

1. MMO: 魔兽世界 2. 魔法哈奇(包括服务器端)  3. 手机版：植物大战僵尸，愤怒的小鸟 4. PC游戏：文明V,
5. 第一人称（PC/XBox/PS3）：孤岛危机(Crysis, Far Cry2等)  6. 模拟人生2(Sims 2) 7. 模拟城市Sims City4  8. 侠盗飞车 Multi Theft Auto

以及下面这些：
[[http://en.wikipedia.org/wiki/Category:Lua-scripted_video_games]]

