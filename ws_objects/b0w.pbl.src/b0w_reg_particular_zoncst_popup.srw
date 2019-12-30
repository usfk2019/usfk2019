$PBExportHeader$b0w_reg_particular_zoncst_popup.srw
$PBExportComments$[kem] 고객 popup
forward
global type b0w_reg_particular_zoncst_popup from w_base
end type
type dw_cond from u_d_external within b0w_reg_particular_zoncst_popup
end type
type dw_detail from u_d_sgl_sel within b0w_reg_particular_zoncst_popup
end type
type p_1 from u_p_find within b0w_reg_particular_zoncst_popup
end type
type p_ok from u_p_ok within b0w_reg_particular_zoncst_popup
end type
type p_close from u_p_close within b0w_reg_particular_zoncst_popup
end type
type gb_1 from groupbox within b0w_reg_particular_zoncst_popup
end type
end forward

global type b0w_reg_particular_zoncst_popup from w_base
integer width = 3063
integer height = 1864
string title = "고객정보"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event ue_find ( )
dw_cond dw_cond
dw_detail dw_detail
p_1 p_1
p_ok p_ok
p_close p_close
gb_1 gb_1
end type
global b0w_reg_particular_zoncst_popup b0w_reg_particular_zoncst_popup

type variables
String is_orderno, is_contractseq, is_closed
Boolean ib_data
end variables

event ue_ok();//선택한 값을 parent window에 보냄.
String ls_customerid
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
	ls_customerid = Trim(dw_detail.Object.customerid[ll_row])
	If IsNull(ls_customerid) Then ls_customerid = ""
	Returnparm.is_data[1] = ls_customerid
	
	CloseWithReturn(This, Returnparm)
End If




end event

event ue_close();str_item Returnparm

Returnparm.ib_data[1] = False

CloseWithReturn(This, Returnparm)
end event

event ue_find();String ls_where
String ls_value, ls_name, ls_status, ls_ctype
Long ll_row

ls_value 	= Trim(dw_cond.object.value[1])
ls_name 		= Trim(dw_cond.object.name[1])
ls_status 	= Trim(dw_cond.object.status[1])
ls_ctype 	= Trim(dw_cond.object.ctype[1])
If IsNull(ls_value) 	Then ls_value 	= ""
If IsNull(ls_name) 	Then ls_name 	= ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_ctype) 	Then ls_ctype 	= ""
ls_where = ""

If ls_value <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_value
			Case "customerid"
				ls_where += "customerid like '" + ls_name + "%' "
			Case "customernm"
				ls_where += "Upper(customernm) like '%" + Upper(ls_name) + "%' "
			Case "payid"
				ls_where += "payid like '" + ls_name + "%' "
			Case "logid"
				ls_where += "Upper(logid) like '%" + Upper(ls_name) + "%' "
			Case "ssno"
				ls_where += "socialsecurity like '" + ls_name + "%' "
			Case "corpno"
				ls_where += "corpno like '" + ls_name + "%' "
			Case "corpnm"
				ls_where += "Upper(corpnm) like '%" + Upper(ls_name) + "%' "
			Case "cregno"
				ls_where += "cregno like '" + ls_name + "%' "
			Case "phone1"
				ls_where += "phone1 like '" + ls_name + "%' "
			Case "email"
				ls_where += "Upper(EMAIL1) like '%" + Upper(ls_name) + "%' "
		End Choose		
	End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "status = '" + ls_status + "'"
End If

If ls_ctype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "ctype1 = '" + ls_ctype + "'"
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

on b0w_reg_particular_zoncst_popup.create
int iCurrent
call super::create
this.dw_cond=create dw_cond
this.dw_detail=create dw_detail
this.p_1=create p_1
this.p_ok=create p_ok
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cond
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.p_1
this.Control[iCurrent+4]=this.p_ok
this.Control[iCurrent+5]=this.p_close
this.Control[iCurrent+6]=this.gb_1
end on

on b0w_reg_particular_zoncst_popup.destroy
call super::destroy
destroy(this.dw_cond)
destroy(this.dw_detail)
destroy(this.p_1)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b0w_reg_particular_zoncst_popup
	Desc	:  조건에 해당하는 고객 정보
	Ver	: 	1.0
	Date	: 	2003.10.08
	Programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
String ls_customerid, ls_pgm_id
str_item Newparm

f_center_window(b0w_reg_particular_zoncst_popup)
Newparm = Message.PowerObjectParm

Newparm.ib_data[1] = False //초기화(Help 값이 설정되지 않았음)..

ib_data       = Newparm.ib_data[1]
is_closed     = Newparm.is_data[1]
ls_customerid = Newparm.is_data[2]
ls_pgm_id     = Newparm.is_data[3]

This.Title = "고객정보"
If Not IsNull(ls_customerid) and ls_customerid <> "" Then
  dw_cond.object.name[1] = ls_customerid
  dw_cond.object.value[1] = "customernm"
End If
dw_cond.SetFocus()
end event

type dw_cond from u_d_external within b0w_reg_particular_zoncst_popup
integer x = 46
integer y = 52
integer width = 1833
integer height = 200
integer taborder = 20
string dataobject = "b1dw_cnd_hlp_customerm"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type dw_detail from u_d_sgl_sel within b0w_reg_particular_zoncst_popup
integer x = 27
integer y = 288
integer width = 3003
integer height = 1472
integer taborder = 0
string dataobject = "b0dw_reg_particular_zoncst_pop"
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.customerid_t
uf_init(ldwo_sort)
end event

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

type p_1 from u_p_find within b0w_reg_particular_zoncst_popup
integer x = 2002
integer y = 52
integer width = 288
boolean originalsize = false
end type

type p_ok from u_p_ok within b0w_reg_particular_zoncst_popup
integer x = 2304
integer y = 52
end type

type p_close from u_p_close within b0w_reg_particular_zoncst_popup
integer x = 2606
integer y = 52
boolean originalsize = false
end type

type gb_1 from groupbox within b0w_reg_particular_zoncst_popup
integer x = 27
integer width = 1870
integer height = 268
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

