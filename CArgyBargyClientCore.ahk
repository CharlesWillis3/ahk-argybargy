#include %A_LineFile%\..\CArgyBargyBase.ahk

class CArgyBargyClientCore extends CArgyBargyBase
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
                this.fnOnStatusChanged.Call(this._sStatus)
            }
        }
    }

    __New(sServerId)
    {
        global AB_WELCOME, AB_GOODBYE, AB_ERROR, AB_PING
        this.nAddRcvrMsgId := this.GetAddRcvrMsgId(sServerId)

        ;Bind the known ArgyBargy messages
        OnMessage(AB_WELCOME, this.AB_WELCOME.Bind(this))
        OnMessage(AB_GOODBYE, this.AB_GOODBYE.Bind(this))
        OnMessage(AB_PING,    this.AB_PING.Bind(this))
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

    AdviseServerError(fnOnServerError)
    {
        this.fnOnServerError := fnOnServerError
    }

    AdviseServerFaulted(fnOnServerFaulted)
    {
        this.fnOnServerFaulted := fnOnServerFaulted
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

    AB_PING(wParam, lParam, msg, hwnd)
    {
        global AB_ACK
        OutputDebug % A_ThisFunc " wParam: " AS_HEX16(wParam) " ScriptHandle: " A_ScriptHwnd
        if (this.hServer == wParam)
            return AB_ACK
    }

    AB_GOODBYE(wParam, lParam, msg, hwnd)
    {
        this.Status := CArgyBargyClient.STATUS_DETACHED
    }

    AB_ERROR(wParam, lParam, msg, hwnd)
    {
        if (this.fnOnServerError)
            this.fnOnServerError.Call()
    }

    AB_FAULT(wParam, lParam, msg, hwnd)
    {
        this.Status := CArgyBargyClient.STATUS_DETACHED
        if (this.fnOnServerFaulted)
            this.fnOnServerFaulted.Call()
    }
}