$PBExportHeader$w_a_hlp.srw
$PBExportComments$help window ( from w_base )
forward
global type w_a_hlp from w_base
end type
type p_1 from u_p_find within w_a_hlp
end type
type dw_cond from u_d_external within w_a_hlp
end type
type p_ok from u_p_ok within w_a_hlp
end type
type p_close from u_p_close within w_a_hlp
end type
type gb_cond from groupbox within w_a_hlp
end type
type dw_hlp from u_d_sgl_sel within w_a_hlp
end type
end forward

global type w_a_hlp from w_base
integer width = 2117
integer height = 1892
string title = "HELP"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event ue_find ( )
event ue_extra_ok ( long al_selrow,  ref integer ai_return )
event ue_extra_ok_with_return ( long al_selrow,  ref integer ai_return )
p_1 p_1
dw_cond dw_cond
p_ok p_ok
p_close p_close
gb_cond gb_cond
dw_hlp dw_hlp
end type
global w_a_hlp w_a_hlp

type variables
u_cust_a_msg iu_cust_help
datawindow dw_source
string is_data[]
long il_clicked_row
end variables

event ue_ok;Long ll_row
Integer li_ret
ll_row = dw_hlp.GetSelectedRow( 0 ) 

If ll_row = 0 Then
	f_msg_info(3020, This.Title, "Select Column")
	Return
End If

If Upper(iu_cust_help.is_data[1]) = "CLOSEWITHRETURN" Then
	Trigger Event ue_extra_ok_with_return(ll_row, li_ret)
	If li_ret < 0 Then
		Return
	End If
Else 
	Trigger Event ue_extra_ok( ll_row ,li_ret)
	If li_ret < 0 Then
		Return
	End If		
End If

iu_cust_help.ib_data[1] = True //Help값이 선정됨.
Close( This )

end event

event ue_close;call super::ue_close;Close( This )
end event

event ue_find;call super::ue_find;dw_cond.AcceptText()
end event

on w_a_hlp.create
int iCurrent
call super::create
this.p_1=create p_1
this.dw_cond=create dw_cond
this.p_ok=create p_ok
this.p_close=create p_close
this.gb_cond=create gb_cond
this.dw_hlp=create dw_hlp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.dw_cond
this.Control[iCurrent+3]=this.p_ok
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.gb_cond
this.Control[iCurrent+6]=this.dw_hlp
end on

on w_a_hlp.destroy
call super::destroy
destroy(this.p_1)
destroy(this.dw_cond)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.gb_cond)
destroy(this.dw_hlp)
end on

event open;// Overrided
Integer li_return
Environment le_env

iu_cust_help = Message.PowerObjectParm

iu_cust_help.ib_data[1] = False //초기화(Help 값이 설정되지 않았음)..

dw_source = iu_cust_help.idw_data[1]
is_data = iu_cust_help.is_data
il_clicked_row = iu_cust_help.il_data[1]

li_return = GetEnvironment(le_env)
If li_return = 1 Then
	X = (PixelsToUnits(le_env.ScreenWidth, XPixelsToUnits!) - Width) / 2
	Y = (PixelsToUnits(le_env.ScreenHeight, YPixelsToUnits!) - Height) / 2
End If

end event

event close;// Overrided

end event

type p_1 from u_p_find within w_a_hlp
integer x = 1198
integer y = 68
end type

type dw_cond from u_d_external within w_a_hlp
integer x = 55
integer y = 48
integer width = 1083
integer height = 336
integer taborder = 10
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;//SetTransObject(SQLCA)
//InsertRow( 0 )
end event

type p_ok from u_p_ok within w_a_hlp
integer x = 1504
integer y = 68
end type

type p_close from u_p_close within w_a_hlp
integer x = 1797
integer y = 68
boolean originalsize = false
end type

type gb_cond from groupbox within w_a_hlp
integer x = 37
integer width = 1129
integer height = 400
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

type dw_hlp from u_d_sgl_sel within w_a_hlp
integer x = 37
integer y = 432
integer width = 2034
integer height = 1324
integer taborder = 0
boolean hscrollbar = false
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event doubleclicked;Long ll_row
Integer li_ret

ll_row = row
If ll_row = 0 Then
	Return
Else
	SelectRow(0, False)
	SelectRow(ll_row, True)
End If

Trigger Event ue_ok()

end event

