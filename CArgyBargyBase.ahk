#include %A_LineFile%\..\AB_MSG.ahk

class CArgyBargyBase
{
    GetAddRcvrMsgId(sServerKind)
    {
        msg_id := DllCall("RegisterWindowMessage", Str, sServerKind)
        OutputDebug % A_ThisFunc " " Format("msg_id:0x{1:04X}", msg_id) " LastError: " A_LastError " ErrorLevel: " ErrorLevel

        if (!msg_id)
            throw Exception(ErrorLevel,, A_LastError)

        return msg_id
    }
}

AS_HEX16(n) {
    return Format("0x{1:04x}", n)
}