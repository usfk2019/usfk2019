$PBExportHeader$b7w_prc_req_card_approval_v20.srw
$PBExportComments$[jsha] 신용카드결제승인요청
forward
global type b7w_prc_req_card_approval_v20 from w_a_reg_m
end type
type cb_1 from commandbutton within b7w_prc_req_card_approval_v20
end type
end forward

global type b7w_prc_req_card_approval_v20 from w_a_reg_m
integer width = 3447
integer height = 1456
event ue_request ( )
event ue_after_request ( )
cb_1 cb_1
end type
global b7w_prc_req_card_approval_v20 b7w_prc_req_card_approval_v20

type variables
Int ii_app_cnt
end variables

event ue_request();Long ll_rowcount, ll_cnt, ll_socket, ll_return, ll_length, ll_workno, ll_checked_cnt
String ls_checkbox
String ls_header, ls_body, ls_buffer, ls_code, ls_segno, ls_id, ls_auth, ls_rsp_code, ls_rsp_msg
String ls_ipaddress, ls_port
String ls_ref_desc, ls_temp, ls_result[], ls_status1, ls_status2
Char lch_seg_sep, lch_attr_sep
Int li_rc

u_api lu_api
lu_api = Create u_api

ll_rowcount = dw_detail.RowCount()
If ll_rowcount <= 0 Then Return

//	IP : B7, C300
// PORT : B7, C310
ls_ipaddress = fs_get_control("B7", "C300", ls_ref_desc)
ls_port = fs_get_control("B7", "C310", ls_ref_desc)

// Segment Seperator : 0X1D
//	Attribute Seperator : 0X1C
lch_seg_sep = CharA(29)
lch_attr_sep = CharA(28)

// Packet Header Definition
ls_code = "8000"
ls_segno = "001"
ls_id = "9999999999"
ls_auth = "0123456789012345"

ls_temp = fs_get_control("B7", "C100", ls_ref_desc)
ll_return = fi_cut_string(ls_temp, ";", ls_result[])
ls_status1 = ls_result[2]	// 승인요청중
ls_Status2 = ls_result[3]	// 승인성공

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "승인요청결과"
iu_cust_msg.is_grp_name = "신용카드결제"

ii_app_cnt = 0

For ll_cnt = 1 To ll_rowcount
	ls_checkbox = dw_detail.Object.checkbox[ll_cnt]
	If ls_checkbox = 'Y' Then
		ii_app_cnt += 1
	End If
Next

If ii_app_cnt = 0 Then
	f_msg_usr_err(9000, This.Title, "승인요청할 레코드가 선택되지 않았습니다.")
	Return
End If

iu_cust_msg.ii_data[1] = ii_app_cnt

ll_checked_cnt = 0
For ll_cnt = 1 To ll_rowcount
	ls_checkbox = dw_detail.Object.checkbox[ll_cnt]
	If ls_checkbox = 'Y' Then
		ll_checked_cnt = ll_checked_cnt + 1
		
		ll_workno = dw_detail.Object.workno[ll_cnt]
		iu_cust_msg.il_data[ll_checked_cnt] = ll_workno
		
		//	Socket Open
		ll_socket = lu_api.PBTcpConnectA(ls_ipaddress, ls_port)
		If ll_socket > 0 Then
			ls_buffer = ""
		Else
			f_msg_usr_err(9000, This.Title, "승인요청에 대한 통신Error가 발생하였습니다.(Socket Open)~r~n전산관리자에게 문의 바랍니다.")
			Return
		End If
		
		// Packet Body
		ls_body = "01"
		ls_body += "0200" + String(ll_workno)
		
		// Packet Header
		ls_header = ls_code + "0000" + fs_fill_zeroes(String(LenA(ls_body)),-4) + ls_segno + ls_id + ls_auth
		
		// Entire Packet
		ls_buffer = ls_header + lch_seg_sep + ls_body

		// Tcp Send
		ll_length = LenA(ls_buffer)
		ll_return = lu_api.PBTcpWriteA(ll_socket, ls_buffer, ll_length)
		If ll_return <> ll_length Then
			f_msg_usr_err(9000, This.Title, "승인요청에 대한 통신Error가 발생하였습니다.~r~n전산관리자에게 문의 바랍니다.")
			lu_api.PBTcpCloseA(ll_socket)
			Return
		End If
		
		//	CardReqStatus Update(status : 승인요청)
		UPDATE	CARDREQSTATUS
		SET	status = :ls_status1,
				reqprcdt = decode(reqprcdt, null, sysdate, reqprcdt)	//	최초승인인 경우만 update
		WHERE	workno = :ll_workno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "UPDATE CARDREQSTATUS ERROR(STATUS1 : "+ls_status1+")")
			Rollback;
			lu_api.PBTcpCloseA(ll_socket)
			Return
		End If
		
		Commit;
		
		//	Tcp Receive
		ll_length = LenA(ls_buffer)
		ll_return = lu_api.PBTcpReadA(ll_socket, ls_buffer, ll_length)
		If ll_return <> ll_length Then
			f_msg_usr_err(9000, This.Title, "승인처리 결과 수신중 통신Error가 발생하였습니다.~r~n전산관리자에게 문의 바랍니다.")
			lu_api.PBTcpCloseA(ll_socket)
			Return
		End IF
		
		// Packet Decode
		li_rc = fi_cut_string(ls_buffer, lch_seg_sep, ls_result[])
		ls_header = ls_result[1]
		ls_body = ls_result[2]
		ls_rsp_code = MidA(ls_header, 5, 4)
		
		li_rc = fi_cut_String(MidA(ls_body, 3), lch_attr_sep, ls_result[])
		ls_rsp_msg = MidA(ls_result[1], 5)
		If ls_rsp_code = "0000" Then
			f_msg_info(3000, This.Title, "승인요청작업 완료")
		ElseIf ls_rsp_code = "6000" Then
			f_msg_usr_err(9000, This.Title, "INTERNAL ERROR(" + ls_rsp_msg + ")")
		ElseIf ls_rsp_code = "6002" Then
			f_msg_usr_err(9000, This.Title, "EDI FILE CREATE FAIL(" + ls_rsp_msg + ")")
		ElseIf ls_rsp_code = "6003" Then
			f_msg_usr_err(9000, This.Title, "EDI FILE SEND FAIL(" + ls_rsp_msg + ")")
		ElseIf ls_rsp_code = "6004" Then
			f_msg_usr_err(9000, This.Title, "EDI FILE RECEIVE FAIL(" + ls_rsp_msg + ")")
		ElseIf ls_rsp_code = "8099" Then
			f_msg_usr_err(9000, This.Title, "UNKNOWN ERROR(" + ls_rsp_msg + ")")
		End If
		
		//	CardReqStatus Update(Status : 승인완료)
		UPDATE	CARDREQSTATUS
		SET	status = :ls_status2,
				resultprcdt = sysdate
		WHERE	workno = :ll_workno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "UPDATE CARDREQSTATUS ERROR(STATUS2 : "+ls_status2+")")
			Rollback;
			lu_api.PBTcpCloseA(ll_socket)
			Return
		End If
		
		Commit;
		
		//	Socket Close
		lu_api.PBTcpCloseA(ll_socket)
		
	End If
Next

cb_1.Enabled = False

// Result Display
This.TriggerEvent('ue_after_request')
end event

event ue_after_request();//Long ll_row
//
//dw_detail.dataObject = "b7dw_prc_req_card_approval2_v20"
//dw_detail.SetTransObject(SQLCA)
//
//ll_row = dw_detail.Retrieve()
//
//If ll_row < 0 Then
//	f_msg_usr_err(2100, This.Title, "Retrieve()")
//End If

// Result Popup Window Display
OpenWithParm(b7w_pop_req_card_approval_v20, iu_cust_msg)

This.TriggerEvent('ue_ok')


end event

on b7w_prc_req_card_approval_v20.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on b7w_prc_req_card_approval_v20.destroy
call super::destroy
destroy(this.cb_1)
end on

event ue_ok();call super::ue_ok;String ls_where, ls_ref_desc, ls_temp, ls_result[], ls_status1, ls_status2
Long ll_row
Int li_return

ls_temp = fs_get_control("B7", "C100", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result[])
ls_status1 = ls_result[1]
ls_status2 = ls_result[2]

ls_where = " (status = '" + ls_status1 + "' "
ls_where += " OR status = '" + ls_status2 + "') "

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	//f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
Else
	cb_1.Enabled = True
End IF
end event

event open;call super::open;This.TriggerEvent('ue_ok')
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	cb_1.Y 		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	cb_1.Y 		= newheight - iu_cust_w_resize.ii_button_space
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b7w_prc_req_card_approval_v20
boolean visible = false
end type

type p_ok from w_a_reg_m`p_ok within b7w_prc_req_card_approval_v20
boolean visible = false
integer x = 64
integer y = 968
end type

type p_close from w_a_reg_m`p_close within b7w_prc_req_card_approval_v20
integer x = 530
integer y = 1212
end type

type gb_cond from w_a_reg_m`gb_cond within b7w_prc_req_card_approval_v20
boolean visible = false
end type

type p_delete from w_a_reg_m`p_delete within b7w_prc_req_card_approval_v20
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b7w_prc_req_card_approval_v20
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b7w_prc_req_card_approval_v20
boolean visible = false
end type

type dw_detail from w_a_reg_m`dw_detail within b7w_prc_req_card_approval_v20
integer x = 23
integer y = 24
integer width = 3360
integer height = 1152
string dataobject = "b7dw_prc_req_card_approval_v20"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b7w_prc_req_card_approval_v20
boolean visible = false
end type

type cb_1 from commandbutton within b7w_prc_req_card_approval_v20
integer x = 41
integer y = 1212
integer width = 443
integer height = 96
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean enabled = false
string text = "승인요청"
end type

event clicked;Parent.TriggerEvent('ue_request')

Return 0
end event

