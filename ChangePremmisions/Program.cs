using System;
using System.Diagnostics;
using System.IO;

namespace ConsoleProgram
{
    class Program
    {
        static int Main(string[] args)
        {
            int result = 0;
            if (args.Length > 0) 
            {
                for(int i = 0; i < args.Length; i++)
                {
                    if(args[i] == "ChangePremission")
                    {
                        result += ChangePremission("System32");
                        result += ChangePremission("SysWOW64");
                    }

                    if(args[i] == "FindAndUninstall")
                    {
                        result += FindAndUninstall();
                    }

                    if (args[i] == "DeleteMacromedia")
                    {
                        result += DeleteMacromedia("System32");
                        result += DeleteMacromedia("SysWOW64");
                    }
                }
            }
            return result;
        }

        static int FindAndUninstall()
        {
            try
            {
                ProcessStartInfo processInfo = new ProcessStartInfo();
                processInfo.FileName = @"powershell.exe";
                processInfo.Arguments = @"$string = get - package 'adobe flash player*' | % { $_.metadata['uninstallstring'] } | Out - String;" +
                                            @"$result = $string.Substring(0, $string.Length - 20);" +
                                            @"$result += "" - uninstall activex"";" +
                                            @"Invoke - Expression $result;";

                processInfo.UseShellExecute = false;
                processInfo.WindowStyle = ProcessWindowStyle.Hidden;
                processInfo.CreateNoWindow = true;

                Process process = new Process();
                process.StartInfo = processInfo;
                process.Start();
                process.WaitForExit();
            }
            catch (Exception error)
            {
                Console.WriteLine(error.ToString());
                return -1;
            }
            Console.WriteLine("Adobe Flash uninstallation successful!");
            return 1;
        }

        static int DeleteMacromedia(string folderPath)
        {
            try
            {
                string[] filePaths = Directory.GetFiles(@"C:\\Windows\\"+folderPath+@"\\Macromed\\Flash");
                foreach (string filePath in filePaths)
                {
                    File.SetAttributes(filePath, FileAttributes.Normal);
                    File.Delete(filePath);
                }
            }
            catch (Exception error)
            {
                Console.WriteLine(error.ToString());
                return 1;
            }
            Console.WriteLine("Macromedia folder deleted successful!");
            return 0;
        }

        static int ChangePremission(string folderPath)
        {
            try
            {
                ProcessStartInfo processInfo = new ProcessStartInfo();
                processInfo.FileName = @"powershell.exe";
                processInfo.Arguments = @"$BuiltinUsersSID = New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-545';"+
                    @"$ACL = Get-ACL ""C:\Windows\"+folderPath+@"\Macromed\Flash"";" + 
                    @"$Group = New-Object System.Security.Principal.SecurityIdentifier($BuiltinUsersSID);"+
                    @"$ACL.SetOwner($Group);" +
                    @"Set-Acl -Path C:\Windows\"+folderPath+@"\Macromed\Flash\* -AclObject $ACL;";

                processInfo.UseShellExecute = false;
                processInfo.WindowStyle = ProcessWindowStyle.Hidden;
                processInfo.CreateNoWindow = true;

                Process process = new Process();
                process.StartInfo = processInfo;
                process.Start();
                process.WaitForExit();
            }
            catch (Exception error)
            {
                Console.WriteLine(error.ToString());
                return 1;
            }
            Console.WriteLine(folderPath + " - permission changed successful!");
            return 0;
        }
    }
}
