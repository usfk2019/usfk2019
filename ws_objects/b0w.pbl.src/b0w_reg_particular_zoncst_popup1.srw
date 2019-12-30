$PBExportHeader$b0w_reg_particular_zoncst_popup1.srw
$PBExportComments$[kem] Partner popup
forward
global type b0w_reg_particular_zoncst_popup1 from w_base
end type
type dw_detail from u_d_sgl_sel within b0w_reg_particular_zoncst_popup1
end type
type dw_cond from u_d_external within b0w_reg_particular_zoncst_popup1
end type
type p_1 from u_p_find within b0w_reg_particular_zoncst_popup1
end type
type p_ok from u_p_ok within b0w_reg_particular_zoncst_popup1
end type
type p_close from u_p_close within b0w_reg_particular_zoncst_popup1
end type
type gb_1 from groupbox within b0w_reg_particular_zoncst_popup1
end type
end forward

global type b0w_reg_particular_zoncst_popup1 from w_base
integer width = 2994
integer height = 1692
string title = "대리점정보"
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
global b0w_reg_particular_zoncst_popup1 b0w_reg_particular_zoncst_popup1

type variables
String is_orderno, is_contractseq, is_closed
Boolean ib_data
end variables

event ue_ok();//선택한 값을 parent window에 보냄.
String ls_partner
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
	ls_partner = Trim(dw_detail.Object.partner[ll_row])
	If IsNull(ls_partner) Then ls_partner = ""
	Returnparm.is_data[1] = ls_partner
	
	CloseWithReturn(This, Returnparm)
	
End If



end event

event ue_close();str_item Returnparm

Returnparm.ib_data[1] = False

CloseWithReturn(This, Returnparm)
end event

event ue_find();// 조회
String ls_partner, ls_partnernm, ls_logid, ls_levelcod, ls_where
Long   ll_row


ls_partner   = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_logid     = Trim(dw_cond.object.logid[1])
ls_levelcod  = Trim(dw_cond.object.levelcod[1])

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partnernm) Then ls_partnernm = ""
If IsNull(ls_logid) Then ls_logid = ""
If IsNull(ls_levelcod) Then ls_levelcod = ""

ls_where = ""
If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(partner) like '" + Upper(ls_partner) + "%' "
End If

If ls_partnernm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(partnernm) like '%" + Upper(ls_partnernm) + "%' "
End If

If ls_levelcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "levelcod like '" + ls_levelcod + "' "
End If

If ls_logid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "logid like '" + ls_logid + "%' "
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

on b0w_reg_particular_zoncst_popup1.create
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

on b0w_reg_particular_zoncst_popup1.destroy
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
	Desc	:  조건에 해당하는 대리점 정보
	Ver	: 	1.0
	Date	: 	2003.10.08
	Programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
String ls_partner, ls_pgm_id
str_item Newparm

f_center_window(b0w_reg_particular_zoncst_popup1)
Newparm = Message.PowerObjectParm

Newparm.ib_data[1] = False //초기화(Help 값이 설정되지 않았음)..

ib_data    = Newparm.ib_data[1]
is_closed  = Newparm.is_data[1]
ls_partner = Newparm.is_data[2]
ls_pgm_id  = Newparm.is_data[3]

This.Title = "대리점정보"
dw_cond.object.partnernm[1] = ls_partner
dw_cond.SetFocus()

end event

type dw_detail from u_d_sgl_sel within b0w_reg_particular_zoncst_popup1
integer x = 23
integer y = 288
integer width = 2930
integer height = 1284
integer taborder = 0
string dataobject = "b0dw_reg_particular_zoncst_pop1"
borderstyle borderstyle = stylebox!
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
ldwo_SORT = Object.partner_t
uf_init(ldwo_SORT)
end event

type dw_cond from u_d_external within b0w_reg_particular_zoncst_popup1
integer x = 41
integer y = 36
integer width = 1979
integer height = 228
integer taborder = 20
string dataobject = "b0dw_cnd_hlp_partner"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type p_1 from u_p_find within b0w_reg_particular_zoncst_popup1
integer x = 2089
integer y = 52
end type

type p_ok from u_p_ok within b0w_reg_particular_zoncst_popup1
integer x = 2382
integer y = 52
end type

type p_close from u_p_close within b0w_reg_particular_zoncst_popup1
integer x = 2674
integer y = 52
boolean originalsize = false
end type

type gb_1 from groupbox within b0w_reg_particular_zoncst_popup1
integer x = 23
integer width = 2016
integer height = 276
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

