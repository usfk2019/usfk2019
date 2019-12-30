$PBExportHeader$b1w_inq_contractdet_info.srw
$PBExportComments$[parkkh] 계약품목 상세내역
forward
global type b1w_inq_contractdet_info from window
end type
type p_close from u_p_close within b1w_inq_contractdet_info
end type
type dw_detail from u_d_sort within b1w_inq_contractdet_info
end type
end forward

global type b1w_inq_contractdet_info from window
integer width = 2802
integer height = 1012
boolean titlebar = true
string title = "서비스 신청 상세품목내역"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29478337
event ue_close ( )
event ue_ok ( )
p_close p_close
dw_detail dw_detail
end type
global b1w_inq_contractdet_info b1w_inq_contractdet_info

type variables

end variables

event ue_close;Close(This)
end event

on b1w_inq_contractdet_info.create
this.p_close=create p_close
this.dw_detail=create dw_detail
this.Control[]={this.p_close,&
this.dw_detail}
end on

on b1w_inq_contractdet_info.destroy
destroy(this.p_close)
destroy(this.dw_detail)
end on

event open;/*-------------------------------------------------------
	Name	: b1w_inq_contractdet_info
	Desc.	: 계약품목 상세내역
	Ver.	: 1.0
	Date	: 2002.10.03
	Programer : Park Kyung Hae(parkkh)
---------------------------------------------------------*/
Long  ll_row
String ls_orderno, ls_where
ls_orderno = Message.StringParm

//window 중앙에
f_center_window(b1w_inq_contractdet_info)


If ls_orderno <>  "" Then

	If ls_orderno = "" Then
		f_msg_info(200, Title, "신청번호가 없습니다.")
		Return
	End If
	
	ls_where = "contractdet.orderno = " + ls_orderno + " "
	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		 Return
	End If
	
End If
Return 0


end event

type p_close from u_p_close within b1w_inq_contractdet_info
integer x = 2491
integer y = 24
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_contractdet_info
integer x = 23
integer y = 24
integer width = 2455
integer height = 848
integer taborder = 10
string dataobject = "b1dw_contrsctdet_info"
boolean hscrollbar = false
end type

