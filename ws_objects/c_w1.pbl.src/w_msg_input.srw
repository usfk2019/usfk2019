$PBExportHeader$w_msg_input.srw
$PBExportComments$Get starting date for generating individual work schedule
forward
global type w_msg_input from window
end type
type p_2 from u_p_cancel within w_msg_input
end type
type p_1 from u_p_ok within w_msg_input
end type
type dw_1 from u_d_external within w_msg_input
end type
end forward

global type w_msg_input from window
integer x = 1111
integer y = 876
integer width = 1595
integer height = 516
boolean titlebar = true
string title = "Untitled"
windowtype windowtype = response!
long backcolor = 29478337
event ue_ok ( )
event ue_cancel ( )
p_2 p_2
p_1 p_1
dw_1 dw_1
end type
global w_msg_input w_msg_input

event ue_ok;String ls_d_start

dw_1.AcceptText()

ls_d_start = Trim(String(dw_1.Object.start[1]))
If IsNull(ls_d_start) Then ls_d_start = ""

//** start MONTH : Check Date
If ls_d_start = '00/00/00' Or ls_d_start = '' Then
	f_msg_usr_err(200, This.title, 'STARTING DATE')
	dw_1.SetFocus()
	dw_1.SetColumn("start")
	Return
End If

CloseWithReturn(This, ls_d_start)
end event

event ue_cancel;CloseWithReturn(This, "cancel")
end event

on w_msg_input.create
this.p_2=create p_2
this.p_1=create p_1
this.dw_1=create dw_1
this.Control[]={this.p_2,&
this.p_1,&
this.dw_1}
end on

on w_msg_input.destroy
destroy(this.p_2)
destroy(this.p_1)
destroy(this.dw_1)
end on

event open;This.Title = 'Get starting Date'

DateTime ldt_now

ldt_now = fdt_get_dbserver_now()

dw_1.Object.start[1] = Date(ldt_now)
end event

type p_2 from u_p_cancel within w_msg_input
integer x = 1243
integer y = 196
integer width = 283
integer height = 96
boolean originalsize = false
end type

type p_1 from u_p_ok within w_msg_input
integer x = 1243
integer y = 68
end type

type dw_1 from u_d_external within w_msg_input
integer x = 32
integer y = 32
integer width = 1184
integer height = 368
string dataobject = "d_msg_input"
borderstyle borderstyle = stylebox!
end type

