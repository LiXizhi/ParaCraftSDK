Author:LiXizhi
Date:2014.1.25

---++ How To Build
   * Install Boost to /Server/trunk/boost_XXXXX/
   * Edit CMakeLists.txt to point to the correct folder
   * Run CMake and build (both linux and window) should be fine. 

---++ How To Test
Copy HelloWorldPlugin(_d).dll to the game directory.
Then run 
<verbatim>
NPL.activate("HelloWorldPlugin.dll", {cmd="hello"})
</verbatim>

check log.txt: the following output should be there
<verbatim>
Plug-in loaded: HelloWorldPlugin.dll
echo:"================test.echo================"
echo:{sample_number_output=1234567,result="hello world!",succeed="true",}
</verbatim>


