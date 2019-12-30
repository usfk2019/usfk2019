$PBExportHeader$b1w_inq_actcancel_popup.srw
$PBExportComments$[parkkh] 계약철회- 상세품목조회 PopUp
forward
global type b1w_inq_actcancel_popup from w_base
end type
type p_1 from u_p_close within b1w_inq_actcancel_popup
end type
type dw_detail from u_d_sort within b1w_inq_actcancel_popup
end type
end forward

global type b1w_inq_actcancel_popup from w_base
integer width = 2501
integer height = 1288
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
event ue_ok ( )
event ue_close ( )
p_1 p_1
dw_detail dw_detail
end type
global b1w_inq_actcancel_popup b1w_inq_actcancel_popup

type variables

end variables

event ue_close();Close( this )
end event

on b1w_inq_actcancel_popup.create
int iCurrent
call super::create
this.p_1=create p_1
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.dw_detail
end on

on b1w_inq_actcancel_popup.destroy
call super::destroy
destroy(this.p_1)
destroy(this.dw_detail)
end on

event open;call super::open;String ls_contractseq
Long ll_row

//window 중앙에
f_center_window(b1w_inq_actcancel_popup)

iu_cust_msg = Message.PowerObjectParm

ls_contractseq = iu_cust_msg.is_data[1]

//조회
ll_row = dw_detail.Retrieve(ls_contractseq)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If

end event

type p_1 from u_p_close within b1w_inq_actcancel_popup
integer x = 2149
integer y = 992
integer height = 100
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_actcancel_popup
integer x = 23
integer y = 24
integer width = 2427
integer height = 924
integer taborder = 10
string dataobject = "b1dw_inq_termorder_popup"
end type

