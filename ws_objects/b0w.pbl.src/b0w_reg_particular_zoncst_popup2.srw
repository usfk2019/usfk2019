$PBExportHeader$b0w_reg_particular_zoncst_popup2.srw
$PBExportComments$[kem] 선불카드 popup
forward
global type b0w_reg_particular_zoncst_popup2 from w_base
end type
type dw_detail from u_d_sgl_sel within b0w_reg_particular_zoncst_popup2
end type
type dw_cond from u_d_external within b0w_reg_particular_zoncst_popup2
end type
type p_1 from u_p_find within b0w_reg_particular_zoncst_popup2
end type
type p_ok from u_p_ok within b0w_reg_particular_zoncst_popup2
end type
type p_close from u_p_close within b0w_reg_particular_zoncst_popup2
end type
type gb_1 from groupbox within b0w_reg_particular_zoncst_popup2
end type
end forward

global type b0w_reg_particular_zoncst_popup2 from w_base
integer width = 3118
integer height = 1316
string title = "선불카드정보"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event ue_find ( )
dw_detail dw_detail
dw_cond dw_cond
p_1 p_1
p_ok p_ok
p_close p_close
gb_1 gb_1
end type
global b0w_reg_particular_zoncst_popup2 b0w_reg_particular_zoncst_popup2

type variables
String is_orderno, is_contractseq, is_closed
Boolean ib_data 
end variables

event ue_ok();//선택한 값을 parent window에 보냄.
String ls_pin
Long ll_row
Integer li_ret
str_item Returnparm

ll_row = dw_detail.GetSelectedRow(0) 

If ll_row = 0 Then
	f_msg_info(3020, This.Title, "Select Column")
	Return
End If

ib_data = True

If Upper(is_closed) = "CLOSEWITHRETURN" Then	
	Returnparm.ib_data[1] = ib_data
	ls_pin = Trim(dw_detail.Object.pid[ll_row])
	If IsNull(ls_pin) Then ls_pin = ""
	Returnparm.is_data[1] = ls_pin
	
	CloseWithReturn(This, Returnparm)
	
End If





end event

event ue_close();str_item Returnparm

Returnparm.ib_data[1] = False

CloseWithReturn(This, Returnparm)
end event

event ue_find();// 조회
String ls_pin, ls_confno, ls_where
Long   ll_row

ls_pin      = Trim(dw_cond.object.pid[1])
ls_confno = Trim(dw_cond.object.contno[1])


If IsNull(ls_pin) Then ls_pin = ""
If IsNull(ls_confno) Then ls_confno = ""


ls_where = ""
If ls_pin <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " pid Like '" + ls_pin + "%' "
End If

If ls_confno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " confno Like '" + ls_confno + "%' "
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If

end event

on b0w_reg_particular_zoncst_popup2.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.dw_cond=create dw_cond
this.p_1=create p_1
this.p_ok=create p_ok
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.dw_cond
this.Control[iCurrent+3]=this.p_1
this.Control[iCurrent+4]=this.p_ok
this.Control[iCurrent+5]=this.p_close
this.Control[iCurrent+6]=this.gb_1
end on

on b0w_reg_particular_zoncst_popup2.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.dw_cond)
destroy(this.p_1)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b0w_reg_particular_zoncst_popup1
	Desc	:  조건에 해당하는 선불카드 정보
	Ver	: 	1.0
	Date	: 	2003.10.08
	Programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
String ls_pin, ls_pgm_id
str_Item Newparm

f_center_window(b0w_reg_particular_zoncst_popup2)
Newparm = Message.PowerObjectParm

Newparm.ib_data[1] = False //초기화(Help 값이 설정되지 않았음)..

ib_data    = Newparm.ib_data[1]
is_closed  = Newparm.is_data[1]
ls_pin     = Newparm.is_data[2]
ls_pgm_id  = Newparm.is_data[3]

This.Title = "선불카드정보"
dw_cond.object.pid[1] = ls_pin
dw_cond.SetFocus()

end event

type dw_detail from u_d_sgl_sel within b0w_reg_particular_zoncst_popup2
integer x = 23
integer y = 244
integer width = 3054
integer height = 944
integer taborder = 0
string dataobject = "b0dw_reg_particular_zoncst_pop2"
end type

event doubleclicked;call super::doubleclicked;Long ll_row
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

event constructor;call super::constructor;dwObject ldwo_SORT
ldwo_SORT = Object.contno_t
uf_init(ldwo_SORT)
end event

type dw_cond from u_d_external within b0w_reg_particular_zoncst_popup2
integer x = 41
integer y = 32
integer width = 1248
integer height = 184
integer taborder = 20
string dataobject = "b0dw_cnd_hlp_cardmst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type p_1 from u_p_find within b0w_reg_particular_zoncst_popup2
integer x = 1422
integer y = 40
end type

type p_ok from u_p_ok within b0w_reg_particular_zoncst_popup2
integer x = 1714
integer y = 40
end type

type p_close from u_p_close within b0w_reg_particular_zoncst_popup2
integer x = 2007
integer y = 40
boolean originalsize = false
end type

type gb_1 from groupbox within b0w_reg_particular_zoncst_popup2
integer x = 23
integer width = 1285
integer height = 232
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

