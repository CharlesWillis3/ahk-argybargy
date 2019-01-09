/* ABServerMsg.ahk
   Server/Client management messages for ArgyBargy messaging
*/

; AB_WELCOME(hServerHwnd)
AB_WELCOME  := 0x8000

; AB_GOODBYTE(hServerHwnd, nExitCode)
AB_GOODBYE  := 0x8001

; Acknowledge receipt of certain messages
AB_ACK      := 0x8002

; These values are reserved for future use by ArgyBargy
AB_RESERVED := 0x8003
AB_RESERVED := 0x8004
AB_RESERVED := 0x8005
AB_RESERVED := 0x8006
AB_RESERVED := 0x8007
AB_RESERVED := 0x8008
AB_RESERVED := 0x8009
AB_RESERVED := 0x800A
AB_RESERVED := 0x800B
AB_RESERVED := 0x800C
AB_RESERVED := 0x800D

; The server encountered an error
; AB_ERROR(nErrorCode)
AB_ERROR    := 0x800E

; The server encountered an unrecoverable error
; AB_FAULT(hServerHwnd)
AB_FAULT    := 0x800F

/* ERROR CODES */