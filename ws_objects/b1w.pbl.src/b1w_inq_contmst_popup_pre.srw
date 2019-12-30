﻿$PBExportHeader$b1w_inq_contmst_popup_pre.srw
$PBExportComments$[ceusee] 고객에따른계약정보팝업-선불제
forward
global type b1w_inq_contmst_popup_pre from w_base
end type
type st_name from statictext within b1w_inq_contmst_popup_pre
end type
type st_customerid from statictext within b1w_inq_contmst_popup_pre
end type
type st_1 from statictext within b1w_inq_contmst_popup_pre
end type
type p_close from u_p_close within b1w_inq_contmst_popup_pre
end type
type dw_detail from u_d_sort within b1w_inq_contmst_popup_pre
end type
type ln_2 from line within b1w_inq_contmst_popup_pre
end type
type ln_1 from line within b1w_inq_contmst_popup_pre
end type
end forward

global type b1w_inq_contmst_popup_pre from w_base
integer width = 2779
integer height = 1424
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
st_name st_name
st_customerid st_customerid
st_1 st_1
p_close p_close
dw_detail dw_detail
ln_2 ln_2
ln_1 ln_1
end type
global b1w_inq_contmst_popup_pre b1w_inq_contmst_popup_pre

type variables
String is_contractseq
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_contractseq)

If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If
end event

event ue_close;Close(This)
end event

on b1w_inq_contmst_popup_pre.create
int iCurrent
call super::create
this.st_name=create st_name
this.st_customerid=create st_customerid
this.st_1=create st_1
this.p_close=create p_close
this.dw_detail=create dw_detail
this.ln_2=create ln_2
this.ln_1=create ln_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_name
this.Control[iCurrent+2]=this.st_customerid
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.dw_detail
this.Control[iCurrent+6]=this.ln_2
this.Control[iCurrent+7]=this.ln_1
end on

on b1w_inq_contmst_popup_pre.destroy
call super::destroy
destroy(this.st_name)
destroy(this.st_customerid)
destroy(this.st_1)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
destroy(this.ln_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b1w_inq_contmst_popup
	Desc	:  해당고객의 서비스 신청 정보
	Ver	: 	1.0
	Date	: 	2002.09.29
	Programer : Choi Bo Ra (ceusee)
-------------------------------------------------------------------------*/

String ls_customerid, ls_customernm
iu_cust_msg = Message.PowerObjectParm

f_center_window(b1w_inq_contmst_popup_pre)
is_contractseq = iu_cust_msg.is_data[1]
ls_customerid = iu_cust_msg.is_data[2]
ls_customernm = iu_cust_msg.is_data[3]

st_customerid.Text = ls_customerid

st_name.Text = ls_customernm

If is_contractseq <> "" Then
	Post Event ue_ok()
End If

Return 0 
end event

type st_name from statictext within b1w_inq_contmst_popup_pre
integer x = 773
integer y = 60
integer width = 736
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_customerid from statictext within b1w_inq_contmst_popup_pre
integer x = 352
integer y = 60
integer width = 393
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
alignment alignment = center!
boolean focusrectangle = false
end type

type st_1 from statictext within b1w_inq_contmst_popup_pre
integer x = 69
integer y = 60
integer width = 361
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "고객번호 :"
boolean focusrectangle = false
end type

type p_close from u_p_close within b1w_inq_contmst_popup_pre
integer x = 2437
integer y = 1192
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_contmst_popup_pre
integer x = 37
integer y = 140
integer width = 2688
integer height = 1020
integer taborder = 10
string dataobject = "b1dw_reg_customer_t6_pop_pre"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

type ln_2 from line within b1w_inq_contmst_popup_pre
long linecolor = 27306400
integer linethickness = 1
integer beginx = 773
integer beginy = 124
integer endx = 1536
integer endy = 124
end type

type ln_1 from line within b1w_inq_contmst_popup_pre
long linecolor = 27306400
integer linethickness = 1
integer beginx = 357
integer beginy = 124
integer endx = 731
integer endy = 124
end type
