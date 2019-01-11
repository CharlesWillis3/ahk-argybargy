#include %A_LineFile%\..\CArgyBargyClientCore.ahk

class CArgyBargyClient extends CArgyBargyClientCore
{
    __New(sServerIniPath, pMessageHandler = "")
    {
        if (!IsObject(pMessageHandler))
            throw "'pMessageHandler' must be an object"

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

        mpnfn_msg_handlers := {}
        loop, parse, sMessagesSection, `n
        {
            rgs_parts := StrSplit(A_LoopField, "=")
            s_msg_name := rgs_parts[1]
            n_msg_id   := rgs_parts[2]

            if (n_msg_id is not integer)
                throw "The value of key [Messages]\" s_msg_name " is not a valid integer"

            mpnfn_msg_handlers[n_msg_id] := ObjBindMethod(pMessageHandler, s_msg_name)
            OutputDebug % "Bind method msg_name: " s_msg_name " msg_id: " n_msg_id
        }

        ;Initialize the ClientCore
        base.__New(sServerId)
        if (!this.RegisterMessageHandlers(mpnfn_msg_handlers))
            throw "Client could not be initialized."
    }

    RegisterMessageHandlers(mpnfnServerMessageHandlers)
    {
        if (mpnfnServerMessageHandlers is not object) {
            OutputDebug % A_ThisFunc " mpnfnServerMessageHandler is not an object: " mpnfnServerMessageHandlers
            return false
        }

        OutputDebug % A_ThisFunc " count: " mpnfnServerMessageHandlers.Count()

        for n_msg_id, fn_msg_handler in mpnfnServerMessageHandlers {
            OnMessage(n_msg_id, fn_msg_handler)
        }

        return true
    }
}