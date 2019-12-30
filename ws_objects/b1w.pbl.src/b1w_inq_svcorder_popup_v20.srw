$PBExportHeader$b1w_inq_svcorder_popup_v20.srw
$PBExportComments$[ohj] 고객에 따른 서비스신청 품목popup v20
forward
global type b1w_inq_svcorder_popup_v20 from w_base
end type
type dw_detail2 from u_d_sort within b1w_inq_svcorder_popup_v20
end type
type st_2 from statictext within b1w_inq_svcorder_popup_v20
end type
type p_close from u_p_close within b1w_inq_svcorder_popup_v20
end type
type dw_detail from u_d_sort within b1w_inq_svcorder_popup_v20
end type
type st_name from statictext within b1w_inq_svcorder_popup_v20
end type
type st_customerid from statictext within b1w_inq_svcorder_popup_v20
end type
type st_1 from statictext within b1w_inq_svcorder_popup_v20
end type
type ln_1 from line within b1w_inq_svcorder_popup_v20
end type
type ln_2 from line within b1w_inq_svcorder_popup_v20
end type
type ln_3 from line within b1w_inq_svcorder_popup_v20
end type
end forward

global type b1w_inq_svcorder_popup_v20 from w_base
integer width = 4142
integer height = 1664
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
dw_detail2 dw_detail2
st_2 st_2
p_close p_close
dw_detail dw_detail
st_name st_name
st_customerid st_customerid
st_1 st_1
ln_1 ln_1
ln_2 ln_2
ln_3 ln_3
end type
global b1w_inq_svcorder_popup_v20 b1w_inq_svcorder_popup_v20

type variables
String is_orderno, is_contractseq, is_status
end variables

event ue_ok;Long ll_row, ll_det

Choose Case is_status
	Case '80', '85'
	   This.Title = "번호변경정보"
		dw_detail.dataobject = 'b1dw_reg_customer_t5_pop_v20_1'
		dw_detail.SetTransObject(sqlca)	
	
	//모바일 기기변경신청 내역 - 2015.03.09. lys
	Case '60'
		This.Title = "기기변경정보"
		dw_detail.dataobject = 'b1dw_inq_admstlog_new_mobile_t5_pop_v20'
		dw_detail.SetTransObject(sqlca)
		
	Case Else
		dw_detail.dataobject = 'b1dw_reg_customer_t5_pop_v20'	
		dw_detail.SetTransObject(sqlca)	
End Choose


//조회
ll_row = dw_detail.Retrieve(is_orderno, is_contractseq)
If ll_row = 0 Then
	this.height = 1144
	f_msg_info(1000, title, "")
End If

//ContractSeq가 Null이거나 0이면(신청만 된경우)
if is_contractseq = '0000000' then is_contractseq = '%'

//단말할부정보
if ll_row > 0 then
	ll_det = dw_detail2.Retrieve(is_contractseq, is_orderno)
	this.height = 1144
	if ll_det > 0 then
		st_2.visible = true
		dw_detail2.visible = true
		this.height = 1664
	end if
	
else
	this.height = 1144
end if

//2013-06-26 START by hmk
//[RQ-UBS-201306-04]급![UBS] 화면창 개수 제어 이상처리 문제 확인요청 
//아래 스크립트 막음.

//gi_open_win_no = gi_open_win_no + 1
//2013-06-26 END by hmk
end event

event ue_close;Close(This)
end event

on b1w_inq_svcorder_popup_v20.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.st_2=create st_2
this.p_close=create p_close
this.dw_detail=create dw_detail
this.st_name=create st_name
this.st_customerid=create st_customerid
this.st_1=create st_1
this.ln_1=create ln_1
this.ln_2=create ln_2
this.ln_3=create ln_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.st_2
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.st_name
this.Control[iCurrent+6]=this.st_customerid
this.Control[iCurrent+7]=this.st_1
this.Control[iCurrent+8]=this.ln_1
this.Control[iCurrent+9]=this.ln_2
this.Control[iCurrent+10]=this.ln_3
end on

on b1w_inq_svcorder_popup_v20.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.st_2)
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
	Nmae	:	b1w_inq_svcorder_popup_v20
	Desc	:  해당고객의 서비스 신청 정보
	Ver	: 	1.0
	Date	: 	2002.09.29
	Programer : Choi Bo Ra (ceusee)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm

st_2.visible = false
dw_detail2.visible = false

f_center_window(b1w_inq_svcorder_popup_v20)
is_orderno = ""
iu_cust_msg = Message.PowerObjectParm

is_orderno = iu_cust_msg.is_data[1]
ls_customerid = iu_cust_msg.is_data[2]
ls_customernm = iu_cust_msg.is_data[3]
is_contractseq = iu_cust_msg.is_data[4]
is_status = iu_cust_msg.is_data[5]

//ContractSeq가 Null이거나 0이면(신청만 된경우)
If IsNull(is_contractseq) or is_contractseq = '0' Then is_contractseq = '0000000'

st_customerid.Text = ls_customerid
st_name.Text = ls_customernm

If is_orderno <> "" Then
	Post Event ue_ok()
End If
end event

type dw_detail2 from u_d_sort within b1w_inq_svcorder_popup_v20
integer x = 23
integer y = 1080
integer width = 4055
integer height = 428
integer taborder = 20
string dataobject = "b1dw_reg_customer_t6_pop_v20_quota"
borderstyle borderstyle = stylebox!
end type

type st_2 from statictext within b1w_inq_svcorder_popup_v20
integer x = 41
integer y = 1016
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

type p_close from u_p_close within b1w_inq_svcorder_popup_v20
integer x = 1577
integer y = 28
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_svcorder_popup_v20
integer x = 23
integer y = 144
integer width = 4055
integer height = 836
integer taborder = 10
string dataobject = "b1dw_reg_customer_t5_pop_v20"
boolean hscrollbar = false
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

type st_name from statictext within b1w_inq_svcorder_popup_v20
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

type st_customerid from statictext within b1w_inq_svcorder_popup_v20
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

type st_1 from statictext within b1w_inq_svcorder_popup_v20
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

type ln_1 from line within b1w_inq_svcorder_popup_v20
long linecolor = 27306400
integer linethickness = 1
integer beginx = 343
integer beginy = 120
integer endx = 718
integer endy = 120
end type

type ln_2 from line within b1w_inq_svcorder_popup_v20
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

type ln_3 from line within b1w_inq_svcorder_popup_v20
long linecolor = 27306400
integer linethickness = 1
integer beginx = 759
integer beginy = 116
integer endx = 1518
integer endy = 116
end type

