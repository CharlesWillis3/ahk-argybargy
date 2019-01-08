#include %A_LineFile%\..\CArgyBargyBase.ahk

class CArgyBargyClient extends CArgyBargyBase
{
    static STATUS_ATTACHED := "Attached"
    static STATUS_DETACHED := "Detached"

    _sStatus := CArgyBargyClient.STATUS_DETACHED

    Status[]
    {
        get {
            return this._sStatus
        }

        set {
            if (this._sStatus != value) {
                this._sStatus := value
                if (IsFunc(this.fnOnStatusChanged))
                    this.fnOnStatusChanged.Call(this._sStatus)
            }
        }
    }

    __New(sServerKind)
    {
        global AB_WELCOME, AB_GOODBYE, AB_ERROR
        this.nAddRcvrMsgId := this.GetAddRcvrMsgId(sServerKind)

        ;Bind the known ArgyBargy messages
        OnMessage(AB_WELCOME, this.AB_WELCOME.Bind(this))
        OnMessage(AB_GOODBYE, this.AB_GOODBYE.Bind(this))
        OnMessage(AB_ERROR,   this.AB_ERROR.Bind(this))
        OnMessage(AB_FAULT,   this.AB_FAULT.Bind(this))
    }

    __Delete()
    {
        this.Detach()
    }

    AdviseStatusChanged(fnOnStatusChanged)
    {
        this.fnOnStatusChanged := fnOnStatusChanged
    }

    Attach()
    {
        ;Broadcast the AB_ADDRCVR for the desired server, passing the hWnd of the receiver as wParam.
        ;If a server of the right type exists and receives the message, it will respond with AB_WELCOME
        PostMessage, this.nAddRcvrMsgId, A_ScriptHwnd,,, ahk_id 0xFFFF
    }

    Detach()
    {
        global AB_ACK, AB_GOODBYE
        sPrevDetect := A_DetectHiddenWindows
        DetectHiddenWindows, On
        OutputDebug % A_ThisFunc " ScriptHwnd: " A_ScriptHwnd " hServer: " AS_HEX16(this.hServer)
        SendMessage, AB_GOODBYE, A_ScriptHwnd,,, % "ahk_id " this.hServer,,,, 500
        if (ErrorLevel != AB_ACK) {
            OutputDebug % A_ThisFunc " AB_GOODBYE not acknowledged within timeout. ErrorLevel: " ErrorLevel
        }

        this.Status := CArgyBargyClient.STATUS_DETACHED
        DetectHiddenWindows, %sPrevDetect%
    }

    AB_WELCOME(wParam, lParam, msg, hwnd)
    {
        global AB_ACK
        this.hServer := wParam
        OutputDebug % A_ThisFunc " wParam: " AS_HEX16(wParam) " ScriptHandle: " A_ScriptHwnd
        this.Status := CArgyBargyClient.STATUS_ATTACHED
        return AB_ACK
    }

    AB_GOODBYE(wParam, lParam, msg, hwnd)
    {
        this.Status := CArgyBargyClient.STATUS_DETACHED
    }

    AB_FAULT(wParam, lParam, msg, hwnd)
    {
        this.Status := CArgyBargyClient.STATUS_DETACHED
    }
}