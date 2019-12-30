$PBExportHeader$w_a_condition.srw
$PBExportComments$Condition Ancestor(From w_base)
forward
global type w_a_condition from w_base
end type
type dw_cond from u_d_external within w_a_condition
end type
type p_ok from u_p_ok within w_a_condition
end type
type p_close from u_p_close within w_a_condition
end type
type gb_cond from groupbox within w_a_condition
end type
end forward

global type w_a_condition from w_base
event ue_ok ( )
event ue_close ( )
dw_cond dw_cond
p_ok p_ok
p_close p_close
gb_cond gb_cond
end type
global w_a_condition w_a_condition

type variables

end variables

event ue_ok;If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망
	dw_cond.SetFocus()
	Return
End If

end event

event ue_close;call super::ue_close;Close(This)
end event

on w_a_condition.create
int iCurrent
call super::create
this.dw_cond=create dw_cond
this.p_ok=create p_ok
this.p_close=create p_close
this.gb_cond=create gb_cond
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cond
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.gb_cond
end on

on w_a_condition.destroy
call super::destroy
destroy(this.dw_cond)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.gb_cond)
end on

event open;call super::open;//윈도우를 좌상단으로 이동
This.X = 1
This.Y = 1

end event

type dw_cond from u_d_external within w_a_condition
event ue_key pbm_dwnkey
integer x = 50
integer y = 48
integer width = 2281
integer height = 228
boolean border = false
borderstyle borderstyle = stylebox!
end type

event ue_key;Choose Case key
	Case KeyEnter!
		Parent.TriggerEvent(is_default)
	Case KeyEscape!
		Parent.TriggerEvent(is_close)
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

type p_ok from u_p_ok within w_a_condition
integer x = 2459
integer y = 64
end type

type p_close from u_p_close within w_a_condition
integer x = 2761
integer y = 64
end type

type gb_cond from groupbox within w_a_condition
integer x = 32
integer width = 2327
integer height = 296
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

