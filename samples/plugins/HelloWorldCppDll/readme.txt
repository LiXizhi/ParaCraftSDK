
Author:LiXizhi
Date:2014.1.25

## How To Build
   * Install Boost and add BOOST_ROOT to environment variable, so that our cmake script can find it
   * Install NPLRuntime source code by running `./NPLRuntime/install_src.bat`, we only use its header files
   * Run CMake and build (both linux and window) should work. 

## How To Test
Copy `HelloWorldPlugin(_d).dll` to the working directory where you start NPL runtime such as `./redist`.
Then run 

```lua
NPL.activate("HelloWorldPlugin.dll", {cmd="hello"})
```

check log.txt: the following output should be there
```
Plug-in loaded: HelloWorldPlugin.dll
echo:"================test.echo================"
echo:{sample_number_output=1234567,result="hello world!",succeed="true",}
```


