#include %A_LineFile%\..\CArgyBargyBase.ahk

DetectHiddenWindows, On

class CArgyBargyServerCore extends CArgyBargyBase
{
    ; An array of windows handles that have registered to receive messages from this server
    _rghRcvrs := []

    ; Use the keys as a hash set
    _rghMaybeInvalidRcvrs := {}

    __New(sServerId)
    {
        global AB_GOODBYE

        OnExit(this.OnExit.Bind(this), 1)
        OnError(this.OnError.Bind(this), 1)

        this._nAddRcvrMsgId := this.GetAddRcvrMsgId(sServerId)

        OnMessage(this._nAddRcvrMsgId, this.AB_ADDRCVR.Bind(this))
        OnMessage(AB_GOODBYE, this.AB_GOODBYE.Bind(this))

        global fn_Reval_rcvr := this.OnRevalidateClients.Bind(this)
        SetTimer, % fn_reval_rcvr, -5000 
    }

    AdviseRcvrsChanged(fnOnRcvrsChanged)
    {
        this._fnOnRcvrsChanged := fnOnRcvrsChanged
    }

    OnExit(sExitReason, nExitCode)
    {
        global AB_GOODBYE
        OutputDebug % A_ThisFunc " ExitReason: " sExitReason " ExitCode: " nExitCode
        this.PostMessage(AB_GOODBYE, A_ScriptHwnd)
        return 0
    }

    OnError(pException)
    {
        global AB_FAULT
        OutputDebug % A_ThisFunc " Line: " pException.Line " Message: " pException.Message
        this.PostMessage(AB_FAULT, A_ScriptHwnd)
        return 1
    }

    OnRevalidateClients()
    {
        global AB_PING, AB_ACK, AB_GOODBYE, fn_reval_rcvr

        Thread, Interrupt, 0
        Thread, Priority, -10
        
        rgh_maybe_invalid_clone := this._rghMaybeInvalidRcvrs.Clone()
        this._rghMaybeInvalidRcvrs := {}

        for h_rcvr in rgh_maybe_invalid_clone {
            SendMessage, AB_PING, A_ScriptHwnd,,, ahk_id %h_rcvr%
            if (ErrorLevel == AB_ACK) {
                OutputDebug % "The rcvr has been revalidated: " AS_HEX16(h_rcvr)
            } else {
                OutputDebug % "The rcvr has been invalidated: " AS_HEX16(h_rcvr)
                this.DetachClient(h_rcvr)
                PostMessage, AB_GOODBYE, A_ScriptHwnd, AB_PING,, ahk_id %h_rcvr%
            }
        }

        SetTimer, % fn_reval_rcvr, -10000
    }

    PostMessage(nMsgId, wParam, lParam := "")
    {
        Critical
        rgh_rcvrs_clone := this._rghRcvrs.Clone()
        loop % rgh_rcvrs_clone.Length() {
            h_rcvr := rgh_rcvrs_clone[A_Index]
            PostMessage, nMsgId, wParam, lParam,, ahk_id %h_rcvr%
            if (ErrorLevel) {
                this._rghMaybeInvalidRcvrs[h_rcvr] := 0
            }
            OutputDebug % A_ThisFunc " msgId: " AS_HEX16(nMsgId) " wParam: " AS_HEX16(wParam) " lParam: " AS_HEX16(lParam) " rcvr: " AS_HEX16(h_rcvr) " LastError: " A_LastError " ErrorLevel: " ErrorLevel
        }

        return (ErrorLevel == 0)
    }

    PostError(nErrorCode)
    {
        global AB_ERROR
        this.PostMessage(AB_ERROR, A_ScriptHwnd, nErrorCode)
    }

    DetachClient(hRcvr)
    {
        loop % this._rghRcvrs.Length() {
            if (this._rghRcvrs[A_Index] == hRcvr)
                idx_remove := A_Index
        }

        if (idx_remove) {
            this._rghRcvrs.RemoveAt(idx_remove)
            this._fnOnRcvrsChanged.Call(hRcvr, false)
            OutputDebug % A_ThisFunc " Removed rcvr: " AS_HEX16(hRcvr)
            return AB_ACK
        } else {
            OutputDebug % A_ThisFunc " Failed to remove rcvr: " AS_HEX16(hRcvr)
            return false
        }
    }

    AB_ADDRCVR(wParam, lParam, msg, hwnd)
    {
        global AB_ACK, AB_WELCOME
        SendMessage, AB_WELCOME, A_ScriptHwnd,,, ahk_id %wParam%,,,, 500

        if (ErrorLevel == AB_ACK) {
            OutputDebug % A_ThisFunc " Adding rcvr: " AS_HEX16(wParam) " ScriptHandle: " A_ScriptHwnd
            this._rghRcvrs.Push(wParam)
            this._fnOnRcvrsChanged.Call(wParam, true)
        }
        else
            OutputDebug % A_ThisFunc " AB_WELCOME not acknowledged within timeout. " AS_HEX16(wParam) " ErrorLevel: " AS_HEX16(ErrorLevel)
    }

    AB_GOODBYE(wParam, lParam, msg, hwnd)
    {
        global AB_ACK
        OutputDebug % A_ThisFunc " wParam: " AS_HEX16(wParam)
        return this.DetachClient(wParam)
    }
}