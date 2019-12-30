$PBExportHeader$b1w_inq_popup_contdetitem.srw
$PBExportComments$[ceusee] 해지처리- 상세품목조회 PopUp Window
forward
global type b1w_inq_popup_contdetitem from w_base
end type
type p_1 from u_p_close within b1w_inq_popup_contdetitem
end type
type dw_detail from u_d_sort within b1w_inq_popup_contdetitem
end type
end forward

global type b1w_inq_popup_contdetitem from w_base
integer width = 2464
integer height = 1300
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
event ue_ok ( )
event ue_close ( )
p_1 p_1
dw_detail dw_detail
end type
global b1w_inq_popup_contdetitem b1w_inq_popup_contdetitem

type variables

end variables

event ue_close();Close( this )
end event

on b1w_inq_popup_contdetitem.create
int iCurrent
call super::create
this.p_1=create p_1
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.dw_detail
end on

on b1w_inq_popup_contdetitem.destroy
call super::destroy
destroy(this.p_1)
destroy(this.dw_detail)
end on

event open;call super::open;String ls_seq
Long ll_row

f_center_window(b1w_inq_popup_contdetitem)

iu_cust_msg = Message.PowerObjectParm
ls_seq = iu_cust_msg.is_data[1]

//조회
ll_row = dw_detail.Retrieve(ls_seq)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If

end event

type p_1 from u_p_close within b1w_inq_popup_contdetitem
integer x = 2107
integer y = 980
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_popup_contdetitem
integer x = 23
integer y = 24
integer width = 2368
integer height = 924
integer taborder = 10
string dataobject = "b1dw_inq_popup_contractdet"
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

