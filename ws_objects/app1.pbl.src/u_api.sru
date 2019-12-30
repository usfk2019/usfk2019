$PBExportHeader$u_api.sru
$PBExportComments$[homy] Window API
forward
global type u_api from nonvisualobject
end type
end forward

global type u_api from nonvisualobject
end type
global u_api u_api

type prototypes
//Windows API
Function ulong GetCurrentDirectoryA (ulong textlen, ref string dirtext) library "KERNEL32.DLL" alias for "GetCurrentDirectoryA;Ansi"
Function boolean SetCurrentDirectoryA(ref string dirtext) library "KERNEL32.DLL" alias for "SetCurrentDirectoryA;Ansi"

//T&C API
Function boolean PBGetOpenFileNameA(unsignedlong hwnd, ref string pTitle, ref string pFileName) Library "PB_COMDLG.dll" alias for "PBGetOpenFileNameA;Ansi"

//T&C TCP socket
Function long PBTcpConnectA(ref string pIp, ref string pPort) library "TNCTCP.DLL" alias for "PBTcpConnectA;Ansi"
Function boolean PBTcpCloseA(long socket) library "TNCTCP.DLL"
Function long PBTcpWriteA(long socket, ref string pData, long len) library "TNCTCP.DLL" alias for "PBTcpWriteA;Ansi"
Function long PBTcpReadA(long socket, ref string pData, long len) library "TNCTCP.DLL" alias for "PBTcpReadA;Ansi"

end prototypes

forward prototypes
public function boolean uf_SetCurrentDirectoryA (ref string as_curdir)
public function string uf_getcurrentdirectorya ()
end prototypes

public function boolean uf_SetCurrentDirectoryA (ref string as_curdir);Boolean lb_return

lb_return = SetCurrentDirectoryA(as_curdir)

Return lb_return

end function

public function string uf_getcurrentdirectorya ();String ls_curdir
uLong l_buf

l_buf = 100
ls_curdir = Space(l_buf)
GetCurrentDirectoryA(l_buf, ls_curdir)

Return ls_curdir
end function

on u_api.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_api.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

