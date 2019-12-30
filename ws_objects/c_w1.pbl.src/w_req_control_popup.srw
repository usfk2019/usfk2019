$PBExportHeader$w_req_control_popup.srw
$PBExportComments$sysctl1t Note
forward
global type w_req_control_popup from w_base
end type
type p_1 from u_p_reset within w_req_control_popup
end type
type mle_note_pop from multilineedit within w_req_control_popup
end type
type p_close from u_p_close within w_req_control_popup
end type
type p_ok from u_p_ok within w_req_control_popup
end type
end forward

global type w_req_control_popup from w_base
integer width = 2363
integer height = 1160
string title = "Rating Change"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
event type integer ue_reset ( )
p_1 p_1
mle_note_pop mle_note_pop
p_close p_close
p_ok p_ok
end type
global w_req_control_popup w_req_control_popup

type variables
Long il_row
end variables

event ue_close;Close(This)
end event

event ue_ok();//
iu_cust_msg.idw_data[1].object.note[il_row] = mle_note_pop.text

Close(This)
end event

event type integer ue_reset();mle_note_pop.Text = ""
mle_note_pop.SetFocus()
Return 0 
end event

on w_req_control_popup.create
int iCurrent
call super::create
this.p_1=create p_1
this.mle_note_pop=create mle_note_pop
this.p_close=create p_close
this.p_ok=create p_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.mle_note_pop
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.p_ok
end on

on w_req_control_popup.destroy
call super::destroy
destroy(this.p_1)
destroy(this.mle_note_pop)
destroy(this.p_close)
destroy(this.p_ok)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: w_req_control_popup
	Desc.	: sysctl1t Note 관리
	Ver.	: 1.0
	Date	: 2005.03.17
---------------------------------------------------------*/

f_center_window(w_req_control_popup)

mle_note_pop.text = iu_cust_msg.is_data[1]

il_row = iu_cust_msg.il_data[1]



end event

type p_1 from u_p_reset within w_req_control_popup
integer x = 2039
integer y = 336
boolean originalsize = false
end type

type mle_note_pop from multilineedit within w_req_control_popup
integer x = 37
integer y = 28
integer width = 1961
integer height = 1024
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
integer limit = 1024
integer tabstop[] = {3}
borderstyle borderstyle = stylelowered!
end type

type p_close from u_p_close within w_req_control_popup
integer x = 2039
integer y = 156
integer taborder = 30
boolean originalsize = false
end type

type p_ok from u_p_ok within w_req_control_popup
integer x = 2039
integer y = 48
integer taborder = 20
end type

