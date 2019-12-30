$PBExportHeader$b1w_inq_reqdtl_popup.srw
$PBExportComments$[cuesee] 청구내역 상세조회 POPUP
forward
global type b1w_inq_reqdtl_popup from w_base
end type
type st_2 from statictext within b1w_inq_reqdtl_popup
end type
type p_close from u_p_close within b1w_inq_reqdtl_popup
end type
type dw_detail from u_d_sort within b1w_inq_reqdtl_popup
end type
type st_paytype from statictext within b1w_inq_reqdtl_popup
end type
type st_paydt from statictext within b1w_inq_reqdtl_popup
end type
type st_1 from statictext within b1w_inq_reqdtl_popup
end type
type ln_1 from line within b1w_inq_reqdtl_popup
end type
type ln_2 from line within b1w_inq_reqdtl_popup
end type
type ln_3 from line within b1w_inq_reqdtl_popup
end type
end forward

global type b1w_inq_reqdtl_popup from w_base
integer width = 3035
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
global b1w_inq_reqdtl_popup b1w_inq_reqdtl_popup

type variables
String is_reqnum
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_reqnum)


end event

event ue_close;Close(This)
end event

on b1w_inq_reqdtl_popup.create
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

on b1w_inq_reqdtl_popup.destroy
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

//청구금액 자릿수 조정
String ls_pos, ls_desc

//금액의 소숫점 자리수 가져오기(B5:H200)
ls_pos = fs_get_control("B5","H200",ls_desc)


If ls_pos = "1" Then
	dw_detail.object.tramt.Format = "#,##0.0"
ElseIf ls_pos = "2" Then
	dw_detail.object.tramt.Format = "#,##0.00"
Else
	dw_detail.object.tramt.Format = "#,##0"
End If


f_center_window(b1w_inq_reqdtl_popup)
is_reqnum = ""
iu_cust_msg = Message.PowerObjectParm


is_reqnum = iu_cust_msg.is_data[2]
st_paydt.text = iu_cust_msg.is_data[3]
st_paytype.text = is_reqnum


If is_reqnum <> "" Then
	Post Event ue_ok()
End If
end event

event close;call super::close;////프로그램을 삭제
//IF ii_pgm_index >= 0 then
//	gs_pgm_id[ii_pgm_index] = ""
//END IF
//
////열린 윈도우 갯수 감소
//gi_open_win_no --
//
//Destroy iu_cust_msg
//
//If gi_open_win_no < 1 Then
//	w_mdi_main.st_resize.Show()
//	w_mdi_main.tv_menu.Show()
//	m_mdi_main.ib_visible = True
//End If	
//
//Destroy(iu_cust_w_resize)
//
end event

type st_2 from statictext within b1w_inq_reqdtl_popup
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
string text = "청구번호:"
alignment alignment = right!
boolean focusrectangle = false
end type

type p_close from u_p_close within b1w_inq_reqdtl_popup
integer x = 2683
integer y = 1064
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_reqdtl_popup
integer x = 23
integer y = 164
integer width = 2944
integer height = 828
integer taborder = 10
string dataobject = "b1dw_inq_reqdlt_popup"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

type st_paytype from statictext within b1w_inq_reqdtl_popup
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

type st_paydt from statictext within b1w_inq_reqdtl_popup
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

type st_1 from statictext within b1w_inq_reqdtl_popup
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
string text = "청구기준일:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ln_1 from line within b1w_inq_reqdtl_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 361
integer beginy = 124
integer endx = 736
integer endy = 124
end type

type ln_2 from line within b1w_inq_reqdtl_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

type ln_3 from line within b1w_inq_reqdtl_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 1175
integer beginy = 124
integer endx = 1650
integer endy = 124
end type

