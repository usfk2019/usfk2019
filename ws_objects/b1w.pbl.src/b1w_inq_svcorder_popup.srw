$PBExportHeader$b1w_inq_svcorder_popup.srw
$PBExportComments$[ceusee] 고객 서비스 신청 item popup
forward
global type b1w_inq_svcorder_popup from w_base
end type
type p_close from u_p_close within b1w_inq_svcorder_popup
end type
type dw_detail from u_d_sort within b1w_inq_svcorder_popup
end type
type st_name from statictext within b1w_inq_svcorder_popup
end type
type st_customerid from statictext within b1w_inq_svcorder_popup
end type
type st_1 from statictext within b1w_inq_svcorder_popup
end type
type ln_1 from line within b1w_inq_svcorder_popup
end type
type ln_2 from line within b1w_inq_svcorder_popup
end type
type ln_3 from line within b1w_inq_svcorder_popup
end type
end forward

global type b1w_inq_svcorder_popup from w_base
integer width = 1733
integer height = 1268
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
p_close p_close
dw_detail dw_detail
st_name st_name
st_customerid st_customerid
st_1 st_1
ln_1 ln_1
ln_2 ln_2
ln_3 ln_3
end type
global b1w_inq_svcorder_popup b1w_inq_svcorder_popup

type variables
String is_orderno, is_contractseq
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_orderno, is_contractseq)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If

end event

event ue_close;Close(This)
end event

on b1w_inq_svcorder_popup.create
int iCurrent
call super::create
this.p_close=create p_close
this.dw_detail=create dw_detail
this.st_name=create st_name
this.st_customerid=create st_customerid
this.st_1=create st_1
this.ln_1=create ln_1
this.ln_2=create ln_2
this.ln_3=create ln_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_close
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.st_name
this.Control[iCurrent+4]=this.st_customerid
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.ln_1
this.Control[iCurrent+7]=this.ln_2
this.Control[iCurrent+8]=this.ln_3
end on

on b1w_inq_svcorder_popup.destroy
call super::destroy
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.st_name)
destroy(this.st_customerid)
destroy(this.st_1)
destroy(this.ln_1)
destroy(this.ln_2)
destroy(this.ln_3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b1w_inq_svcorder_popup
	Desc	:  해당고객의 서비스 신청 정보
	Ver	: 	1.0
	Date	: 	2002.09.29
	Programer : Choi Bo Ra (ceusee)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm

f_center_window(b1w_inq_svcorder_popup)
is_orderno = ""
iu_cust_msg = Message.PowerObjectParm

is_orderno = iu_cust_msg.is_data[1]
ls_customerid = iu_cust_msg.is_data[2]
ls_customernm = iu_cust_msg.is_data[3]
is_contractseq = iu_cust_msg.is_data[4]

//ContractSeq가 Null이거나 0이면(신청만 된경우)
If IsNull(is_contractseq) or is_contractseq = '0' Then is_contractseq = '@@@@@@@'

st_customerid.Text = ls_customerid
st_name.Text = ls_customernm

If is_orderno <> "" Then
	Post Event ue_ok()
End If
end event

type p_close from u_p_close within b1w_inq_svcorder_popup
integer x = 1385
integer y = 1028
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_svcorder_popup
integer x = 23
integer y = 144
integer width = 1646
integer height = 848
integer taborder = 10
string dataobject = "b1dw_reg_customer_t5_pop"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

type st_name from statictext within b1w_inq_svcorder_popup
integer x = 754
integer y = 48
integer width = 736
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_customerid from statictext within b1w_inq_svcorder_popup
integer x = 338
integer y = 56
integer width = 352
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

type st_1 from statictext within b1w_inq_svcorder_popup
integer x = 46
integer y = 60
integer width = 297
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

type ln_1 from line within b1w_inq_svcorder_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 343
integer beginy = 120
integer endx = 718
integer endy = 120
end type

type ln_2 from line within b1w_inq_svcorder_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

type ln_3 from line within b1w_inq_svcorder_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 759
integer beginy = 116
integer endx = 1518
integer endy = 116
end type

