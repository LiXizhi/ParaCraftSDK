using System;
using System.Collections.Generic;
using System.Windows.Forms;
using NPLMono;

namespace SampleMonoWinForm
{
    static class MainWindow
    {
        /// <summary>
        /// -- Run WinForm in a separate UI thread:
        /// NPL.CreateRuntimeState("ui", 0):Start();
        /// NPL.activate("(ui)SampleMonoWinForm.dll/SampleMonoWinForm.MainWindow.cs", {});
        /// -- Run WinForm in main UI thread:
        /// NPL.activate("SampleMonoWinForm.dll/SampleMonoWinForm.MainWindow.cs", {});
        /// </summary>
        /// <param name="nType"></param>
        /// <param name="npl_runtime_state"></param>
        public static void activate(ref int nType, ref IntPtr npl_runtime_state)
        {
            // example 1: getting input message and write to application log
            string msg = NPL.GetCurrentMsg(npl_runtime_state);
            ParaGlobal.applog("This is from Mono C# files: " + msg);

            Form1 myWindow = new Form1();
            myWindow.ShowDialog();
        }
    }
}
