## ParaCraftSDK
Open Source SDK and tools for ParaCraft.

> Please see video tutorial first. [Source code of paracraft](https://github.com/NPLPackages/paracraft) is released as [NPL package](https://github.com/LiXizhi/NPLRuntime/wiki/npl_packages).

* [Video Tutorial](https://github.com/LiXizhi/NPLRuntime/wiki/TutorialParacraftMod)
* [ParaCraftSDK Guide](https://github.com/LiXizhi/ParaCraftSDK/wiki)
   * [View Paracraft Source Code](https://github.com/NPLPackages/paracraft)
* [ParaCraft Guide](https://github.com/LiXizhi/ParaCraft/wiki)
* [NPL Guide](https://github.com/LiXizhi/NPLRuntime/wiki)
   * [View NPL Source Code](https://github.com/NPLPackages/paracraft)

## Tutorial: Create Mod With ParacraftSDK

In this tutorial, you will learn how to create 3D applications with NPL. 

### 3D Graphics Powered By ParaEngine
NPL's graphics API is powered by a built-in 3D computer game engine called ParaEngine, which is written as early as 2005 (NPL was started in 2004). Its development goes side-by-side with NPL in the same repository. If you read the [source code](https://github.com/LiXizhi/NPLRuntime) of NPLRuntime, you will notice two namespaces called `NPL` and `ParaEngine`.

In the past years, I have made several attempts to make the ParaEngine portion more modular, but even so, I did not separate it from the NPLRuntime code tree, because I want the minimum build of NPLRuntime to support all 3D API, just like JAVA, C# and Chrome/NodeJS does. However, if you build NPLRuntime with no `OpenGL/DirectX` graphics, such as on Linux server, these 3D APIs are still available to NPL script but will not draw anythings to your screen.

### Introducing Our 3D World Editor: Paracraft
First of all, creating 3D applications isn't easy in general. Fortunately, NPL offers a free and [open source](https://github.com/NPLPackages/paracraft) NPL package called Paracraft, which is 3d world editor written in NPL. 

Paracraft itself is also a standard alone software product for every one (including kids above 7 years old) to create 3D world, animated characters, movies and codes all in a single application. See [[http://www.paracraft.cn/]] for its official website. Actually there are hundreds of interactive 3D worlds, movies and games created by paracraft users without the need of any third-party software. 

![image](https://cloud.githubusercontent.com/assets/94537/19154692/2fad2be8-8c0e-11e6-938e-fa0d5ea202ef.png)

_Fig. Screen shot of Paracraft_

> Note: Yes, the look of it are inspired by a great sandbox game called `minecraft` (I love it very much), but using blocks is just the methodology we adopt for crafting objects almost exclusively. Blocks in paracraft can be resized and turned into animated characters. The block methodology (rather than using triangles) allows everyone (including kids) to create models, animations, and even rigging characters very easily, and it is lots of fun. Remember you can still import polygon models from `MAYA/3dsmax`, etc, if you are that professional. 

Let us look at some features of Paracraft.
- Everything is a block, entity or item, a block or entity can contain other items in it. 
- Every operation is a command and most of them support undo and redo.  
- There are items like scripts, movie blocks, bones, terrain brush, physics blocks, etc. 
- Use NPL Code Wiki to view and debug.
- Network enabled, you can host your own private world and website in your world directory. 

### Creating Paracraft Plugin(Mod)
If you want to control more of the logic and looks of your 3D world, you need to write NPL code as professionally as we wrote paracraft itself. This is what this tutorial is really about. 

#### Why Using Mod?
Because paracraft is also released as an [open source NPL package](https://github.com/NPLPackages/paracraft), you can just modify the source code of Paracraft and turn it into anything you like or even write everything from scratch. 

However, this is not the recommended way, because paracraft is maintained by us and regularly updated. If you directly modify paracraft without informing us, it may be very difficult to stay up to date with us. Unless you find a bug or wrote a new feature which we can merge into our main branch, you are recommended to use Paracraft Mod to create plugins to extend paracraft or even applications that looks entirely different from it. 

Paracraft Mod or plugin system exposes many extension points to various aspects of the system. One can use it to add new blocks, commands, web page in NPL code wiki, or even replace the entire user interface and IO of paracraft. 

![image](https://cloud.githubusercontent.com/assets/94537/19157826/25c0966e-8c19-11e6-86db-6f6760076f8b.png)

_Fig. Above Image is an [online game](http://ps.61.com/) created via Paracraft Mod by one of our partners. _

You can see how much difference there is from paracraft. 

#### Creating Your First Paracraft Mod

##### Install ParacraftSDK
* Install [Git](https://git-scm.com/) so that you can call `git` command from your cmd line.
* Download [ParacraftSDK](https://github.com/LiXizhi/ParaCraftSDK/archive/master.zip)
  * or you can clone it by running: 
```
git clone https://github.com/LiXizhi/ParaCraftSDK.git
```
   * Make sure you have updated to the latest version, by running `./redist/paracraft.exe` at least once
* Download and install [Visual Studio Community Edition](https://www.visualstudio.com/): the free version of `visual studio`
  * In visual studio, select `menu::Tools::Extensions`, and search online for `npl` or `lua` to install following plugins:
[NPL/Lua language service for visual studio](https://visualstudiogallery.msdn.microsoft.com/7782dc20-924a-4726-8656-d876cdbb3417): this will give you all the syntax highlighting, intellisense and debugging capability for NPL in visual studio. 

see [[Install Guide|InstallGuide]] and [ParaCraftSDK Simple Plugin](https://github.com/LiXizhi/ParaCraftSDK/wiki/TutorialSimplePlugin) for more information.

##### Create `HelloWorld` Mod
- Run `./bin/CreateParacraftMod.bat` and enter the name of your plugin, such as `HelloWorld`. A folder at `./_mod/HelloWorld ` will be generated.
- Run `./_mod/HelloWorld/Run.bat` to test your plugin with your copy of paracraft in the ./redist folder.

The empty plugin does not do anything yet, except printing a log when it is loaded. 

##### Command line and runtime environment
If you open Run.bat with a text editor, you will see following lines.
```
@echo off 
pushd "%~dp0../../redist/" 
call "ParaEngineClient.exe" dev="%~dp0" mod="HelloWorld" isDevEnv="true"  
popd 
```
It specifies following things:
* the application is started via ParaEngineClient.exe in `./redist` folder
* the `dev` parameter specifies the development directory (which is the plugin directory ./_mod/HelloWorld/), basically what this means is that NPLRuntime will always look for files in this folder first and then in working directory (`./redist` folder). 
* the `mod` and `isDevEnv` parameters simply tells paracraft to load the given plugin from the development directory, so that you do not have to load and enable it manually in paracraft GUI.

##### Install Source Code From NPL Package
All APIs of paracraft are available as source code from NPL package. 
Run `./_mod/HelloWorld/InstallPackages.bat` to get them or you can create `./_mod/HelloWorld/npl_packages` and install manually like this.
```
cd npl_packages
git clone https://github.com/NPLPackages/main.git
git clone https://github.com/NPLPackages/paracraft.git
```
You may edit `InstallPackages.bat` to install other packages, and run it regularly to stay up-to-date with git source.  

> it is NOT advised to modify or add files in the ./npl_packages folder, instead create a similar directory structure in your mod directory if you want to add or modify package source code.  Read [[npl_packages]] for how to contribute.

##### Setup Project Files
NPL is a dynamic language, it does not require you to build anything in order to run, so you can create any type of visual studio project you like and begin adding files to it. Open `ModProject.sln` with visual studio in your mod directory, everything should already have been setup for you. You can `Ctrl+F5` to run. 

To manually create project solution file, follow following steps:
- create an empty visual studio project: such as a C# library and remove all cs files from it.
- add `npl_packages/main/*.csproj` and `npl_packages/paracraft/*.csproj` to your solutions, so that you have all the source code of NPL core lib and paracraft, where you can easily search for documentation and implementation. 
- configure the project property to tell visual studio to start NPLRuntime with proper command line parameters when we press Ctrl+F5. The following does exactly the same thing as the `./Run.bat` in mod folder. 
   - For the external program: we can use `ParaEngineClient.exe`, see below
   - external program: `D:\lxzsrc\ParaCraftSDKGit\redist\ParaEngineClient.exe`
   - command line parameters: `mod="HelloWorld" isDevEnv="true"  dev="D:/lxzsrc/ParaCraftSDKGit/redist/_mod/HelloWorld/"`
   - working directory: `D:/lxzsrc/ParaCraftSDKGit/redist/_mod/HelloWorld/`
     - Note: the `dev` param and working directory should be the root of your mod project folder. 
