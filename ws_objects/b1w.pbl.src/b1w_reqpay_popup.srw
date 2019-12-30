$PBExportHeader$b1w_reqpay_popup.srw
$PBExportComments$[parkkh] 입금내역 popup
forward
global type b1w_reqpay_popup from w_base
end type
type st_2 from statictext within b1w_reqpay_popup
end type
type p_close from u_p_close within b1w_reqpay_popup
end type
type dw_detail from u_d_sort within b1w_reqpay_popup
end type
type st_paytype from statictext within b1w_reqpay_popup
end type
type st_paydt from statictext within b1w_reqpay_popup
end type
type st_1 from statictext within b1w_reqpay_popup
end type
type ln_1 from line within b1w_reqpay_popup
end type
type ln_2 from line within b1w_reqpay_popup
end type
type ln_3 from line within b1w_reqpay_popup
end type
end forward

global type b1w_reqpay_popup from w_base
integer width = 3342
integer height = 1320
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
st_2 st_2
p_close p_close
dw_detail dw_detail
st_paytype st_paytype
st_paydt st_paydt
st_1 st_1
ln_1 ln_1
ln_2 ln_2
ln_3 ln_3
end type
global b1w_reqpay_popup b1w_reqpay_popup

type variables
String is_orderno
String is_seq_no
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_seq_no)
//If ll_row = 0 Then
//	f_msg_info(1000, title, "")
//End If

end event

event ue_close;Close(This)
end event

on b1w_reqpay_popup.create
int iCurrent
call super::create
this.st_2=create st_2
this.p_close=create p_close
this.dw_detail=create dw_detail
this.st_paytype=create st_paytype
this.st_paydt=create st_paydt
this.st_1=create st_1
this.ln_1=create ln_1
this.ln_2=create ln_2
this.ln_3=create ln_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_2
this.Control[iCurrent+2]=this.p_close
this.Control[iCurrent+3]=this.dw_detail
this.Control[iCurrent+4]=this.st_paytype
this.Control[iCurrent+5]=this.st_paydt
this.Control[iCurrent+6]=this.st_1
this.Control[iCurrent+7]=this.ln_1
this.Control[iCurrent+8]=this.ln_2
this.Control[iCurrent+9]=this.ln_3
end on

on b1w_reqpay_popup.destroy
call super::destroy
destroy(this.st_2)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.st_paytype)
destroy(this.st_paydt)
destroy(this.st_1)
destroy(this.ln_1)
destroy(this.ln_2)
destroy(this.ln_3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b1w_reqpay_popup
	Desc	:  해당 입금내역의 상세정보
	Ver	: 	1.0
	Date	: 	2002.10.12
	Programer : Park Kyung Hae (Parkkh)
-------------------------------------------------------------------------*/
String ls_paytypenm

f_center_window(b1w_reqpay_popup)
is_seq_no = ""
iu_cust_msg = Message.PowerObjectParm

select codenm
  into :ls_paytypenm
 from syscod2t
where grcode = 'B512'
  and use_yn = 'Y'
  and code = :iu_cust_msg.is_data[4];

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "select syscod2t")
	Return 
End If

is_seq_no = iu_cust_msg.is_data[2]
st_paydt.text = iu_cust_msg.is_data[3]
st_paytype.text = ls_paytypenm
//st_row.text = "[ " +iu_cust_msg.is_data[4] + "행 상세 자료 ]"

If is_seq_no <> "" Then
	Post Event ue_ok()
End If
end event

type st_2 from statictext within b1w_reqpay_popup
integer x = 818
integer y = 60
integer width = 347
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "입금유형:"
alignment alignment = right!
boolean focusrectangle = false
end type

type p_close from u_p_close within b1w_reqpay_popup
integer x = 2999
integer y = 1064
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_reqpay_popup
integer x = 23
integer y = 164
integer width = 3269
integer height = 828
integer taborder = 10
string dataobject = "b1dw_reqpay_popup"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

type st_paytype from statictext within b1w_reqpay_popup
integer x = 1166
integer y = 60
integer width = 512
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

type st_paydt from statictext within b1w_reqpay_popup
integer x = 357
integer y = 60
integer width = 352
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_1 from statictext within b1w_reqpay_popup
integer x = 14
integer y = 60
integer width = 334
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "입금일자:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ln_1 from line within b1w_reqpay_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 361
integer beginy = 124
integer endx = 736
integer endy = 124
end type

type ln_2 from line within b1w_reqpay_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

type ln_3 from line within b1w_reqpay_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 1175
integer beginy = 124
integer endx = 1650
integer endy = 124
end type

