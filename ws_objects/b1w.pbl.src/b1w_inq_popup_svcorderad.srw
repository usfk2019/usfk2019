﻿$PBExportHeader$b1w_inq_popup_svcorderad.srw
$PBExportComments$[kem] 구매확인Call - 장비조회 PopUp Window
forward
global type b1w_inq_popup_svcorderad from w_base
end type
type p_1 from u_p_close within b1w_inq_popup_svcorderad
end type
type dw_detail from u_d_sort within b1w_inq_popup_svcorderad
end type
end forward

global type b1w_inq_popup_svcorderad from w_base
integer width = 2752
integer height = 1132
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
p_1 p_1
dw_detail dw_detail
end type
global b1w_inq_popup_svcorderad b1w_inq_popup_svcorderad

type variables

end variables

event ue_close();Close( this )
end event

on b1w_inq_popup_svcorderad.create
int iCurrent
call super::create
this.p_1=create p_1
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.dw_detail
end on

on b1w_inq_popup_svcorderad.destroy
call super::destroy
destroy(this.p_1)
destroy(this.dw_detail)
end on

event open;call super::open;f_center_window(b1w_inq_popup_svcorderad)

String ls_orderno

iu_cust_msg = Message.PowerObjectParm

ls_orderno = iu_cust_msg.is_data[1]


Long ll_row
//조회
ll_row = dw_detail.Retrieve(ls_orderno)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If

end event

type p_1 from u_p_close within b1w_inq_popup_svcorderad
integer x = 2382
integer y = 904
integer width = 288
integer height = 100
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_popup_svcorderad
integer x = 23
integer y = 24
integer width = 2661
integer height = 844
integer taborder = 10
string dataobject = "b1dw_inq_popup_svcorderad"
boolean ib_sort_use = false
end type

