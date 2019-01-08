#include %A_LineFile%\..\CArgyBargyBase.ahk

DetectHiddenWindows, On

class CArgyBargyServer extends CArgyBargyBase
{
    ; An array of windows handles that have registered to receive messages from this server
    rghRcvrs := []

    __New(sServerKind)
    {
        global AB_GOODBYE

        OnExit(ObjBindMethod(this, "OnExit"), 1)
        OnError(ObjBindMethod(this, "OnError"), 1)

        this.nAddRcvrMsgId := this.GetAddRcvrMsgId(sServerKind)

        OnMessage(this.nAddRcvrMsgId, this.AB_ADDRCVR.Bind(this))
        OnMessage(AB_GOODBYE, this.AB_GOODBYE.Bind(this))
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

    PostMessage(nMsgId, wParam, lParam := "")
    {
        rgh_rcvrs_clone := this.rghRcvrsClone()
        loop % rgh_rcvrs_clone.Length() {
            h_rcvr := rgh_rcvrs_clone[A_Index]
            PostMessage, nMsgId, wParam, lParam,, ahk_id %h_rcvr%
        }
    }

    PostError(nErrorCode)
    {
        global AB_ERROR
        this.PostMessage(AB_ERROR, A_ScriptHwnd, nErrorCode)
    }

    AB_ADDRCVR(wParam, lParam, msg, hwnd)
    {
        global AB_ACK, AB_WELCOME
        SendMessage, AB_WELCOME, A_ScriptHwnd,,, ahk_id %wParam%,,,, 500

        if (ErrorLevel == AB_ACK) {
            OutputDebug % A_ThisFunc " Adding rcvr: " AS_HEX16(wParam) " ScriptHandle: " A_ScriptHwnd
            this.rghRcvrs.Push(wParam)
        }
        else
            OutputDebug % A_ThisFunc " AB_WELCOME not acknowledged within timeout. " AS_HEX16(wParam) " ErrorLevel: " AS_HEX16(ErrorLevel)
    }

    AB_GOODBYE(wParam, lParam, msg, hwnd)
    {
        global AB_ACK
        OutputDebug % A_ThisFunc " wParam: " AS_HEX16(wParam)
        loop % this.rghRcvrs.Length() {
            if (this.rghRcvrs[A_Index] == wParam)
                idx_remove := A_Index
        }

        if (idx_remove) {
            this.rghRcvrs.RemoveAt(idx_remove)
            OutputDebug % A_ThisFunc " Removed rcvr: " AS_HEX16(wParam)
            return AB_ACK
        } else {
            OutputDebug % A_ThisFunc " Failed to remove rcvr: " AS_HEX16(wParam)
            return false
        }
    }
}