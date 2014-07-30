using System;
using System.Collections.Generic;
using System.Text;
using NPLMono;

namespace SampleMonoLib
{
    public class MyClass
    {
        // <summary>
        /// To test the mono interface, call following from any NPL script.
        /// 
        /// NPL.activate("NPLMonoInterface.dll/NPLMonoInterface.cs", {});
        /// NPL.activate("SampleMonoLib.dll/SampleMonoLib.MyClass.cs", {});
        /// </summary>
        public static void activate(ref int nType, ref IntPtr npl_runtime_state)
        {
            // example 1: getting input message and write to application log
            string msg = NPL.GetCurrentMsg(npl_runtime_state);
            ParaGlobal.applog("This is from Mono C# files: " + msg);
            Console.Write("hello world!");
        }
    }
}
