$PBExportHeader$b8w_outing_popup.srw
$PBExportComments$[parkkh] 출고내역 popup
forward
global type b8w_outing_popup from w_base
end type
type p_close from u_p_close within b8w_outing_popup
end type
type dw_detail from u_d_sort within b8w_outing_popup
end type
type st_model from statictext within b8w_outing_popup
end type
type ln_2 from line within b8w_outing_popup
end type
end forward

global type b8w_outing_popup from w_base
integer width = 3278
integer height = 1356
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
event ue_ok ( )
event ue_close ( )
p_close p_close
dw_detail dw_detail
st_model st_model
ln_2 ln_2
end type
global b8w_outing_popup b8w_outing_popup

type variables
String is_orderno
String is_seq_no, is_partner, is_modelno
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_partner, is_modelno)
//If ll_row = 0 Then
//	f_msg_info(1000, title, "")
//End If

end event

event ue_close;Close(This)
end event

on b8w_outing_popup.create
int iCurrent
call super::create
this.p_close=create p_close
this.dw_detail=create dw_detail
this.st_model=create st_model
this.ln_2=create ln_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_close
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.st_model
this.Control[iCurrent+4]=this.ln_2
end on

on b8w_outing_popup.destroy
call super::destroy
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.st_model)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b8w_outing_popup
	Desc	:  대리점 출고내역의 상세정보
	Ver	: 	1.0
	Date	: 	2002.10.29
	Programer : Park Kyung Hae (Parkkh)
-------------------------------------------------------------------------*/
String ls_modelnm

f_center_window(b8w_outing_popup)
is_partner = ""
is_modelno = ""
iu_cust_msg = Message.PowerObjectParm

select modelnm
  into :ls_modelnm
 from admodel
where modelno = :iu_cust_msg.is_data[2];

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "select admodel")
	Return 
End If

is_partner = iu_cust_msg.is_data[1]
is_modelno = iu_cust_msg.is_data[2]

st_model.text = " [ " + ls_modelnm + " 출고내역 ]"

If is_partner <> "" and is_modelno <> "" Then
	Post Event ue_ok()
End If
end event

type p_close from u_p_close within b8w_outing_popup
integer x = 2953
integer y = 1156
boolean originalsize = false
end type

type dw_detail from u_d_sort within b8w_outing_popup
integer x = 23
integer y = 136
integer width = 3214
integer height = 888
integer taborder = 10
string dataobject = "b8dw_outing_popup"
boolean hscrollbar = false
end type

type st_model from statictext within b8w_outing_popup
integer x = 41
integer y = 48
integer width = 1637
integer height = 72
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 12632256
boolean focusrectangle = false
end type

type ln_2 from line within b8w_outing_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

