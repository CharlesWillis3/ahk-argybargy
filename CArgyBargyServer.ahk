#include %A_LineFile%\..\CArgyBargyServerCore.ahk

class CArgyBargyServer extends CArgyBargyServerCore
{
    _mpsnMessages :={}

    __New(sServerIniPath)
    {
        IniRead, sSectionNames, % sServerIniPath

        if (!sSectionNames)
            throw "The path is not a valid INI file: " sServerIniPath

        OutputDebug % A_ThisFunc " sServerIniPath: " sServerIniPath " sSectionNames:`n" sSectionNames

        IniRead, sServerId, % sServerIniPath, Server, Id
        if (!sServerId)
            throw "The ini file does not contain the required key: [Server]\Id"

        OutputDebug % "Server Id: " sServerId

        IniRead, sServerDescription, % sServerIniPath, Server, Description
        if (!sServerDescription)
            throw "The ini file does not contain the required key: [Server]\Description"

        OutputDebug % "Server Description: " sServerDescription

        this.ServerDescription := sServerDescription

        IniRead, sMessagesSection, % sServerIniPath, Messages
        if (!sMessagesSection)
            throw "The required section '[Messages]' is missing or empty"

        mpsn_messages := {}
        loop, parse, sMessagesSection, `n
        {
            rgs_parts := StrSplit(A_LoopField, "=")
            s_msg_name := rgs_parts[1]
            n_msg_id   := rgs_parts[2]

            if (n_msg_id is not integer)
                throw "The value of key [Messages]\" s_msg_name " is not a valid integer"

            mpsn_messages[s_msg_name] := n_msg_id
            OutputDebug % "Add message msg_name: " s_msg_name " msg_id: " AS_HEX16(n_msg_id)
        }

        ;Initialize the ServerCore
        base.__New(sServerId)
        if (!this.RegisterMessages(mpsn_messages))
            throw "Server could not be initialized."
    }

    __Call(sMsgName, args*)
    {
        if (this._mpsnMessages.HasKey(sMsgName))
        {
            OutputDebug % A_ThisFunc " sMsgName: " sMsgName " wParam: " args[1] " lParam: " args[2]
            return base.PostMessage(this._mpsnMessages[sMsgName], args[1], args[2])
        }
    }

    RegisterMessages(mpsnMessages)
    {
        if (mpsnMessages is not object) {
            OutputDebug % A_ThisFunc " mpsnMessages is not an object: " mpsnMessages
            return false
        }

        OutputDebug % A_ThisFunc " count: " mpsnMessages.Count()

        this._mpsnMessages := mpsnMessages
        return true
    }
}