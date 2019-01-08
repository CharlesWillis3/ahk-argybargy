#include %A_LineFile%\..\CArgyBargyClient.ahk

c := new CArgyBargyClient("9BDB9C0F-732E-47B6-BA78-14907137AE39")
c.AdviseStatusChanged(Func("StatusChanged"))
c.Attach()

Sleep, 1000
c.Detach()

StatusChanged(sStatus)
{
    OutputDebug % A_ThisFunc " sStatus: " sStatus 
}