$text = $env:CODE

if (-not $text) {
    Write-Host "Set CODE environment variable and run again."
    exit 1
}

$code = @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

public class Program
{
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int VK_RSHIFT = 0xA1;
    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static LowLevelKeyboardProc _proc = HookCallback;
    private static IntPtr _hookId;

    [StructLayout(LayoutKind.Sequential)]
    struct INPUT
    {
        public uint type;
        public InputUnion U;
        public static int Size
        {
            get { return Marshal.SizeOf(typeof(INPUT)); }
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    struct InputUnion
    {
        [FieldOffset(0)]
        public KEYBDINPUT ki;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct KEYBDINPUT
    {
        public ushort wVk;
        public ushort wScan;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    [DllImport("user32.dll")]
    static extern uint SendInput(uint cInputs, INPUT[] pInputs, int cbSize);

    [DllImport("user32.dll", SetLastError = true)]
    static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll")]
    static extern int GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

    [StructLayout(LayoutKind.Sequential)]
    struct MSG
    {
        public IntPtr hwnd;
        public uint message;
        public IntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public int pt_x;
        public int pt_y;
    }

    private static string _textToSend;
    private static volatile bool _exitRequested;

    public static void Run(string text)
    {
        _textToSend = text;
        using (Process cur = Process.GetCurrentProcess())
        using (ProcessModule mod = cur.MainModule)
            _hookId = SetWindowsHookEx(WH_KEYBOARD_LL, _proc, GetModuleHandle(mod.ModuleName), 0);
        if (_hookId == IntPtr.Zero)
        {
            Console.WriteLine("Hook failed");
            return;
        }
        Console.WriteLine("Waiting for RShift...");
        while (!_exitRequested)
        {
            MSG msg;
            if (GetMessage(out msg, IntPtr.Zero, 0, 0) > 0) { }
        }
        UnhookWindowsHookEx(_hookId);
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN)
        {
            if (Marshal.ReadInt32(lParam) == VK_RSHIFT)
            {
                DoSequence();
                _exitRequested = true;
                return (IntPtr)1;
            }
        }
        return CallNextHookEx(_hookId, nCode, wParam, lParam);
    }

    static void DoSequence()
    {
        string fullText = "/link " + _textToSend;
        for (int i = 0; i < 2; i++)
        {
            PressKey(0x54); Thread.Sleep(30);
            SendUnicodeString(fullText); Thread.Sleep(30);
            PressKey(0x0D); Thread.Sleep(50);
        }
        PressKeyWithModifier(0x73, 0x12); // Alt+F4
    }

    static void PressKey(ushort vk)
    {
        INPUT[] inputs = new INPUT[2];
        inputs[0] = MakeKeyInput(vk, false);
        inputs[1] = MakeKeyInput(vk, true);
        SendInput(2, inputs, INPUT.Size);
    }

    static void PressKeyWithModifier(ushort vk, ushort mod)
    {
        INPUT[] inputs = new INPUT[4];
        inputs[0] = MakeKeyInput(mod, false);
        inputs[1] = MakeKeyInput(vk, false);
        inputs[2] = MakeKeyInput(vk, true);
        inputs[3] = MakeKeyInput(mod, true);
        SendInput(4, inputs, INPUT.Size);
    }

    static void SendUnicodeString(string text)
    {
        foreach (char c in text)
        {
            INPUT[] inputs = new INPUT[2];
            inputs[0].type = 1;
            inputs[0].U.ki.wVk = 0;
            inputs[0].U.ki.wScan = c;
            inputs[0].U.ki.dwFlags = 0x0004;
            inputs[0].U.ki.time = 0;
            inputs[0].U.ki.dwExtraInfo = IntPtr.Zero;

            inputs[1].type = 1;
            inputs[1].U.ki.wVk = 0;
            inputs[1].U.ki.wScan = c;
            inputs[1].U.ki.dwFlags = 0x0004 | 0x0002;
            inputs[1].U.ki.time = 0;
            inputs[1].U.ki.dwExtraInfo = IntPtr.Zero;

            SendInput(2, inputs, INPUT.Size);
            Thread.Sleep(1);
        }
    }

    static INPUT MakeKeyInput(ushort vk, bool up)
    {
        INPUT input = new INPUT
        {
            type = 1,
            U = new InputUnion
            {
                ki = new KEYBDINPUT
                {
                    wVk = vk,
                    wScan = 0,
                    dwFlags = up ? 0x0002u : 0u,
                    time = 0,
                    dwExtraInfo = IntPtr.Zero
                }
            }
        };
        return input;
    }
}
'@

Add-Type -TypeDefinition $code
[Program]::Run($text)$text = $env:CODE

if (-not $text) {
    Write-Host "Set CODE environment variable and run again."
    exit 1
}

$code = @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

public class Program
{
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int VK_RSHIFT = 0xA1;
    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static LowLevelKeyboardProc _proc = HookCallback;
    private static IntPtr _hookId;

    [StructLayout(LayoutKind.Sequential)]
    struct INPUT
    {
        public uint type;
        public InputUnion U;
        public static int Size
        {
            get { return Marshal.SizeOf(typeof(INPUT)); }
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    struct InputUnion
    {
        [FieldOffset(0)]
        public KEYBDINPUT ki;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct KEYBDINPUT
    {
        public ushort wVk;
        public ushort wScan;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    [DllImport("user32.dll")]
    static extern uint SendInput(uint cInputs, INPUT[] pInputs, int cbSize);

    [DllImport("user32.dll", SetLastError = true)]
    static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll")]
    static extern int GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

    [StructLayout(LayoutKind.Sequential)]
    struct MSG
    {
        public IntPtr hwnd;
        public uint message;
        public IntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public int pt_x;
        public int pt_y;
    }

    private static string _textToSend;
    private static volatile bool _exitRequested;

    public static void Run(string text)
    {
        _textToSend = text;
        using (Process cur = Process.GetCurrentProcess())
        using (ProcessModule mod = cur.MainModule)
            _hookId = SetWindowsHookEx(WH_KEYBOARD_LL, _proc, GetModuleHandle(mod.ModuleName), 0);
        if (_hookId == IntPtr.Zero)
        {
            Console.WriteLine("Hook failed");
            return;
        }
        Console.WriteLine("Waiting for RShift...");
        while (!_exitRequested)
        {
            MSG msg;
            if (GetMessage(out msg, IntPtr.Zero, 0, 0) > 0) { }
        }
        UnhookWindowsHookEx(_hookId);
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN)
        {
            if (Marshal.ReadInt32(lParam) == VK_RSHIFT)
            {
                DoSequence();
                _exitRequested = true;
                return (IntPtr)1;
            }
        }
        return CallNextHookEx(_hookId, nCode, wParam, lParam);
    }

    static void DoSequence()
    {
        string fullText = "/link " + _textToSend;
        for (int i = 0; i < 2; i++)
        {
            PressKey(0x54); Thread.Sleep(30);
            SendUnicodeString(fullText); Thread.Sleep(30);
            PressKey(0x0D); Thread.Sleep(50);
        }
        PressKeyWithModifier(0x73, 0x12); // Alt+F4
    }

    static void PressKey(ushort vk)
    {
        INPUT[] inputs = new INPUT[2];
        inputs[0] = MakeKeyInput(vk, false);
        inputs[1] = MakeKeyInput(vk, true);
        SendInput(2, inputs, INPUT.Size);
    }

    static void PressKeyWithModifier(ushort vk, ushort mod)
    {
        INPUT[] inputs = new INPUT[4];
        inputs[0] = MakeKeyInput(mod, false);
        inputs[1] = MakeKeyInput(vk, false);
        inputs[2] = MakeKeyInput(vk, true);
        inputs[3] = MakeKeyInput(mod, true);
        SendInput(4, inputs, INPUT.Size);
    }

    static void SendUnicodeString(string text)
    {
        foreach (char c in text)
        {
            INPUT[] inputs = new INPUT[2];
            inputs[0].type = 1;
            inputs[0].U.ki.wVk = 0;
            inputs[0].U.ki.wScan = c;
            inputs[0].U.ki.dwFlags = 0x0004;
            inputs[0].U.ki.time = 0;
            inputs[0].U.ki.dwExtraInfo = IntPtr.Zero;

            inputs[1].type = 1;
            inputs[1].U.ki.wVk = 0;
            inputs[1].U.ki.wScan = c;
            inputs[1].U.ki.dwFlags = 0x0004 | 0x0002;
            inputs[1].U.ki.time = 0;
            inputs[1].U.ki.dwExtraInfo = IntPtr.Zero;

            SendInput(2, inputs, INPUT.Size);
            Thread.Sleep(1);
        }
    }

    static INPUT MakeKeyInput(ushort vk, bool up)
    {
        INPUT input = new INPUT
        {
            type = 1,
            U = new InputUnion
            {
                ki = new KEYBDINPUT
                {
                    wVk = vk,
                    wScan = 0,
                    dwFlags = up ? 0x0002u : 0u,
                    time = 0,
                    dwExtraInfo = IntPtr.Zero
                }
            }
        };
        return input;
    }
}
'@

Add-Type -TypeDefinition $code
[Program]::Run($text)
