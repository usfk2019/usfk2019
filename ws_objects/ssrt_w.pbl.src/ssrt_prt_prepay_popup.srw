$PBExportHeader$ssrt_prt_prepay_popup.srw
$PBExportComments$[1hera] 선수금현황조회-pop
forward
global type ssrt_prt_prepay_popup from w_base
end type
type st_2 from statictext within ssrt_prt_prepay_popup
end type
type p_close from u_p_close within ssrt_prt_prepay_popup
end type
type st_payer from statictext within ssrt_prt_prepay_popup
end type
type st_payid from statictext within ssrt_prt_prepay_popup
end type
type st_1 from statictext within ssrt_prt_prepay_popup
end type
type ln_1 from line within ssrt_prt_prepay_popup
end type
type ln_2 from line within ssrt_prt_prepay_popup
end type
type ln_3 from line within ssrt_prt_prepay_popup
end type
type dw_detail from u_d_sort within ssrt_prt_prepay_popup
end type
end forward

global type ssrt_prt_prepay_popup from w_base
integer width = 1787
integer height = 1888
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
st_2 st_2
p_close p_close
st_payer st_payer
st_payid st_payid
st_1 st_1
ln_1 ln_1
ln_2 ln_2
ln_3 ln_3
dw_detail dw_detail
end type
global ssrt_prt_prepay_popup ssrt_prt_prepay_popup

type variables
String is_cid
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_cid)
//If ll_row = 0 Then
//	f_msg_info(1000, title, "")
//End If

end event

event ue_close;Close(This)
end event

on ssrt_prt_prepay_popup.create
int iCurrent
call super::create
this.st_2=create st_2
this.p_close=create p_close
this.st_payer=create st_payer
this.st_payid=create st_payid
this.st_1=create st_1
this.ln_1=create ln_1
this.ln_2=create ln_2
this.ln_3=create ln_3
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_2
this.Control[iCurrent+2]=this.p_close
this.Control[iCurrent+3]=this.st_payer
this.Control[iCurrent+4]=this.st_payid
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.ln_1
this.Control[iCurrent+7]=this.ln_2
this.Control[iCurrent+8]=this.ln_3
this.Control[iCurrent+9]=this.dw_detail
end on

on ssrt_prt_prepay_popup.destroy
call super::destroy
destroy(this.st_2)
destroy(this.p_close)
destroy(this.st_payer)
destroy(this.st_payid)
destroy(this.st_1)
destroy(this.ln_1)
destroy(this.ln_2)
destroy(this.ln_3)
destroy(this.dw_detail)
end on

event open;call super::open;String ls_cid

f_center_window(this)
iu_cust_msg = Message.PowerObjectParm


is_cid = iu_cust_msg.is_data[1]

st_payid.text = iu_cust_msg.is_data[1]
st_payer.text = iu_cust_msg.is_data[2]

If is_cid <> "" Then
	Post Event ue_ok()
End If
end event

type st_2 from statictext within ssrt_prt_prepay_popup
integer y = 132
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
string text = "Payer:"
alignment alignment = right!
boolean focusrectangle = false
end type

type p_close from u_p_close within ssrt_prt_prepay_popup
integer x = 1339
integer y = 132
boolean originalsize = false
end type

type st_payer from statictext within ssrt_prt_prepay_popup
integer x = 357
integer y = 136
integer width = 896
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

type st_payid from statictext within ssrt_prt_prepay_popup
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

type st_1 from statictext within ssrt_prt_prepay_popup
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
string text = "PayID:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ln_1 from line within ssrt_prt_prepay_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 361
integer beginy = 124
integer endx = 736
integer endy = 124
end type

type ln_2 from line within ssrt_prt_prepay_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 352
integer beginy = 224
integer endx = 1257
integer endy = 224
end type

type ln_3 from line within ssrt_prt_prepay_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 384
integer beginy = 128
integer endx = 859
integer endy = 128
end type

type dw_detail from u_d_sort within ssrt_prt_prepay_popup
integer x = 37
integer y = 276
integer width = 1678
integer height = 1484
integer taborder = 10
string dataobject = "ssrt_prt_prepay_popup"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

