$PBExportHeader$b1w_inq_contmst_popup_v20.srw
$PBExportComments$[ohj] 고객에 따른 후불개통 품목popup v20
forward
global type b1w_inq_contmst_popup_v20 from w_base
end type
type dw_detail3 from u_d_sort within b1w_inq_contmst_popup_v20
end type
type st_2 from statictext within b1w_inq_contmst_popup_v20
end type
type dw_detail2 from u_d_sort within b1w_inq_contmst_popup_v20
end type
type p_close from u_p_close within b1w_inq_contmst_popup_v20
end type
type st_1 from statictext within b1w_inq_contmst_popup_v20
end type
type dw_detail from u_d_sort within b1w_inq_contmst_popup_v20
end type
type ln_2 from line within b1w_inq_contmst_popup_v20
end type
type ln_1 from line within b1w_inq_contmst_popup_v20
end type
type st_customerid from statictext within b1w_inq_contmst_popup_v20
end type
type st_name from statictext within b1w_inq_contmst_popup_v20
end type
end forward

global type b1w_inq_contmst_popup_v20 from w_base
integer width = 3927
integer height = 2236
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
dw_detail3 dw_detail3
st_2 st_2
dw_detail2 dw_detail2
p_close p_close
st_1 st_1
dw_detail dw_detail
ln_2 ln_2
ln_1 ln_1
st_customerid st_customerid
st_name st_name
end type
global b1w_inq_contmst_popup_v20 b1w_inq_contmst_popup_v20

type variables
String is_contractseq, is_orderno, is_customerid
end variables

event ue_ok;
Long ll_row, ll_det, ll_det1

//조회
ll_row = dw_detail.Retrieve(is_contractseq)

If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If


//단말할부정보
if ll_row > 0 then
	dw_detail3.dataobject = 'ubs_dw_reg_activation_det2_mobile'
	dw_detail3.settransobject(SQLCA)
	ll_det = dw_detail3.retrieve( is_contractseq , is_customerid)
	IF ll_det = 0 then
			dw_detail3.dataobject = 'ubs_dw_reg_activation_det2_self'
			dw_detail3.settransobject(SQLCA)
			ll_det = dw_detail3.retrieve( is_contractseq , is_customerid)
	end if
		
	ll_det1 = dw_detail2.Retrieve(is_contractseq, is_orderno)
	this.height = 1188
	if ll_det + ll_det1 > 0 then
		st_2.visible = true
		dw_detail2.visible = true
		this.height = 2232
	end if
	
else
	this.height = 1188
end if
end event

event ue_close;Close(This)
end event

on b1w_inq_contmst_popup_v20.create
int iCurrent
call super::create
this.dw_detail3=create dw_detail3
this.st_2=create st_2
this.dw_detail2=create dw_detail2
this.p_close=create p_close
this.st_1=create st_1
this.dw_detail=create dw_detail
this.ln_2=create ln_2
this.ln_1=create ln_1
this.st_customerid=create st_customerid
this.st_name=create st_name
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail3
this.Control[iCurrent+2]=this.st_2
this.Control[iCurrent+3]=this.dw_detail2
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.dw_detail
this.Control[iCurrent+7]=this.ln_2
this.Control[iCurrent+8]=this.ln_1
this.Control[iCurrent+9]=this.st_customerid
this.Control[iCurrent+10]=this.st_name
end on

on b1w_inq_contmst_popup_v20.destroy
call super::destroy
destroy(this.dw_detail3)
destroy(this.st_2)
destroy(this.dw_detail2)
destroy(this.p_close)
destroy(this.st_1)
destroy(this.dw_detail)
destroy(this.ln_2)
destroy(this.ln_1)
destroy(this.st_customerid)
destroy(this.st_name)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b1w_inq_contmst_popup_v20
	Desc	:  해당고객의 서비스 신청 정보
	Ver	: 	1.0
	Date	: 	2002.09.29
	Programer : Choi Bo Ra (ceusee)
-------------------------------------------------------------------------*/

String ls_customerid, ls_customernm, ls_svccod
iu_cust_msg = Message.PowerObjectParm

st_2.visible = false
dw_detail2.visible = false

f_center_window(b1w_inq_contmst_popup_v20)
is_contractseq = iu_cust_msg.is_data[1]
is_customerid = iu_cust_msg.is_data[2]
ls_customernm = iu_cust_msg.is_data[3]

st_customerid.Text = is_customerid

st_name.Text = ls_customernm


select orderno, svccod into :is_orderno, :ls_svccod 
from svcorder
where contractseq = :is_contractseq;



If is_contractseq <> "" Then
	Post Event ue_ok()
End If

Return 0 
end event

type dw_detail3 from u_d_sort within b1w_inq_contmst_popup_v20
integer x = 23
integer y = 1080
integer width = 3854
integer height = 488
integer taborder = 20
string dataobject = "ubs_dw_reg_activation_det2_mobile"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type st_2 from statictext within b1w_inq_contmst_popup_v20
integer x = 46
integer y = 1592
integer width = 507
integer height = 60
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 255
long backcolor = 29478337
string text = "[단말 할부정보]"
boolean focusrectangle = false
end type

type dw_detail2 from u_d_sort within b1w_inq_contmst_popup_v20
integer x = 27
integer y = 1656
integer width = 3854
integer height = 428
integer taborder = 10
string dataobject = "b1dw_reg_customer_t6_pop_v20_quota"
borderstyle borderstyle = stylebox!
end type

type p_close from u_p_close within b1w_inq_contmst_popup_v20
integer x = 2295
integer y = 32
boolean originalsize = false
end type

type st_1 from statictext within b1w_inq_contmst_popup_v20
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

type dw_detail from u_d_sort within b1w_inq_contmst_popup_v20
integer x = 23
integer y = 148
integer width = 3854
integer height = 896
integer taborder = 10
string dataobject = "b1dw_reg_customer_t6_pop_v20"
borderstyle borderstyle = stylebox!
end type

type ln_2 from line within b1w_inq_contmst_popup_v20
long linecolor = 27306400
integer linethickness = 1
integer beginx = 773
integer beginy = 124
integer endx = 1998
integer endy = 124
end type

type ln_1 from line within b1w_inq_contmst_popup_v20
long linecolor = 27306400
integer linethickness = 1
integer beginx = 357
integer beginy = 124
integer endx = 731
integer endy = 124
end type

type st_customerid from statictext within b1w_inq_contmst_popup_v20
integer x = 343
integer y = 60
integer width = 347
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
alignment alignment = right!
boolean focusrectangle = false
end type

type st_name from statictext within b1w_inq_contmst_popup_v20
integer x = 773
integer y = 60
integer width = 1266
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

