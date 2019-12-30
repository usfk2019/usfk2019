$PBExportHeader$b1w_inq_customer_chg_mobile_popup_v20.srw
$PBExportComments$명의변경 신청 정보 팝업 - 2015.03.11. lys
forward
global type b1w_inq_customer_chg_mobile_popup_v20 from w_base
end type
type st_orderno from statictext within b1w_inq_customer_chg_mobile_popup_v20
end type
type st_2 from statictext within b1w_inq_customer_chg_mobile_popup_v20
end type
type p_close from u_p_close within b1w_inq_customer_chg_mobile_popup_v20
end type
type dw_detail from u_d_sort within b1w_inq_customer_chg_mobile_popup_v20
end type
type st_customerid from statictext within b1w_inq_customer_chg_mobile_popup_v20
end type
type st_1 from statictext within b1w_inq_customer_chg_mobile_popup_v20
end type
type ln_1 from line within b1w_inq_customer_chg_mobile_popup_v20
end type
type ln_2 from line within b1w_inq_customer_chg_mobile_popup_v20
end type
type ln_3 from line within b1w_inq_customer_chg_mobile_popup_v20
end type
end forward

global type b1w_inq_customer_chg_mobile_popup_v20 from w_base
integer width = 3749
integer height = 2564
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
st_orderno st_orderno
st_2 st_2
p_close p_close
dw_detail dw_detail
st_customerid st_customerid
st_1 st_1
ln_1 ln_1
ln_2 ln_2
ln_3 ln_3
end type
global b1w_inq_customer_chg_mobile_popup_v20 b1w_inq_customer_chg_mobile_popup_v20

type variables
String is_orderno, is_contractseq, is_status, is_customerid
end variables

event ue_ok();//조회
String	ls_where
Long		ll_row

//Dynamic SQL
ls_where  = "customer_log_delete.orderno = '" + is_orderno + "' AND "
ls_where += "customer_log_delete.customerid = '" + is_customerid + "' "

//Retrieve
dw_detail.is_where = ls_where
ll_row = dw_detail.retrieve()
If ll_row = 0 Then
	f_msg_info(1000, title, "")
Else
	st_customerid.Text = String(dw_detail.Object.transdt[1], 'YYYY-MM-DD')
End If
end event

event ue_close;Close(This)
end event

on b1w_inq_customer_chg_mobile_popup_v20.create
int iCurrent
call super::create
this.st_orderno=create st_orderno
this.st_2=create st_2
this.p_close=create p_close
this.dw_detail=create dw_detail
this.st_customerid=create st_customerid
this.st_1=create st_1
this.ln_1=create ln_1
this.ln_2=create ln_2
this.ln_3=create ln_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_orderno
this.Control[iCurrent+2]=this.st_2
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.st_customerid
this.Control[iCurrent+6]=this.st_1
this.Control[iCurrent+7]=this.ln_1
this.Control[iCurrent+8]=this.ln_2
this.Control[iCurrent+9]=this.ln_3
end on

on b1w_inq_customer_chg_mobile_popup_v20.destroy
call super::destroy
destroy(this.st_orderno)
destroy(this.st_2)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.st_customerid)
destroy(this.st_1)
destroy(this.ln_1)
destroy(this.ln_2)
destroy(this.ln_3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b1w_inq_customer_chg_popup_v20
	Desc	:  명의변경 신청 정보 
	Ver	: 	1.0
	Date	: 	2015.03.12
	Programer : lys
-------------------------------------------------------------------------*/
String ls_customernm

f_center_window(this)
is_orderno = ""
iu_cust_msg = Message.PowerObjectParm

is_orderno = iu_cust_msg.is_data[1]
is_customerid = iu_cust_msg.is_data[2]
ls_customernm = iu_cust_msg.is_data[3]
is_contractseq = iu_cust_msg.is_data[4]
is_status = iu_cust_msg.is_data[5]

//ContractSeq가 Null이거나 0이면(신청만 된경우)
If IsNull(is_contractseq) or is_contractseq = '0' Then is_contractseq = '@@@@@@@'

//st_customerid.Text = ls_customerid
//st_name.Text = ls_customernm
st_orderno.Text = is_orderno

If is_orderno <> "" Then
	Post Event ue_ok()
End If
end event

type st_orderno from statictext within b1w_inq_customer_chg_mobile_popup_v20
integer x = 1179
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

type st_2 from statictext within b1w_inq_customer_chg_mobile_popup_v20
integer x = 878
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
string text = "Order No :"
boolean focusrectangle = false
end type

type p_close from u_p_close within b1w_inq_customer_chg_mobile_popup_v20
integer x = 3410
integer y = 2332
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_customer_chg_mobile_popup_v20
integer x = 23
integer y = 180
integer width = 3675
integer height = 2116
integer taborder = 10
string dataobject = "b1dw_inq_customer_chg_mobile_popup_v20"
boolean hscrollbar = false
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

type st_customerid from statictext within b1w_inq_customer_chg_mobile_popup_v20
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

type st_1 from statictext within b1w_inq_customer_chg_mobile_popup_v20
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
string text = "처리일자 :"
boolean focusrectangle = false
end type

type ln_1 from line within b1w_inq_customer_chg_mobile_popup_v20
long linecolor = 27306400
integer linethickness = 1
integer beginx = 343
integer beginy = 120
integer endx = 718
integer endy = 120
end type

type ln_2 from line within b1w_inq_customer_chg_mobile_popup_v20
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

type ln_3 from line within b1w_inq_customer_chg_mobile_popup_v20
long linecolor = 27306400
integer linethickness = 1
integer beginx = 1184
integer beginy = 120
integer endx = 1559
integer endy = 120
end type

