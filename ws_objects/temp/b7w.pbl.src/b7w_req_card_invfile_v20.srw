$PBExportHeader$b7w_req_card_invfile_v20.srw
$PBExportComments$[jsha] 신용카드 결제청구
forward
global type b7w_req_card_invfile_v20 from w_a_reg_m
end type
type cb_transfer from commandbutton within b7w_req_card_invfile_v20
end type
end forward

global type b7w_req_card_invfile_v20 from w_a_reg_m
integer width = 3141
integer height = 1812
event ue_request ( )
cb_transfer cb_transfer
end type
global b7w_req_card_invfile_v20 b7w_req_card_invfile_v20

event ue_request();String ls_ipaddress, ls_port, ls_ref_desc, ls_result[]
String ls_header, ls_body, ls_buffer, ls_code, ls_segno, ls_id, ls_auth, ls_rsp_code, ls_rsp_msg
String ls_van, ls_file_transfer, ls_filename, ls_approvaldt
Char lch_seg_sep, lch_attr_sep
Long ll_socket, ll_length, ll_return
Int li_rc
u_api lu_api
lu_api = Create u_api

dw_cond.AcceptText()

ls_van = dw_cond.Object.van[1]
ls_file_transfer = dw_cond.Object.file_transfer[1]
ls_filename = fs_snvl(dw_cond.Object.filename[1], "")
ls_approvaldt = String(dw_cond.Object.approvaldt[1], 'yyyymmdd') + "000000"

// File Name 입력 Check
If ls_filename = "" Then
	f_msg_usr_err(200, This.Title, "File Name")
	dw_cond.SetRow(1)
	dw_cond.SetColumn("filename")
	dw_cond.SetFocus()
	Return
End IF

//	IP : B7, C300
// PORT : B7, C310
ls_ipaddress = fs_get_control("B7", "C300", ls_ref_desc)
ls_port = fs_get_control("B7", "C310", ls_ref_desc)

//	Socket Open
ll_socket = lu_api.PBTcpConnectA(ls_ipaddress, ls_port)
If ll_socket > 0 Then
	ls_buffer = ""
Else
	f_msg_usr_err(9000, This.Title, "청구요청에 대한 통신Error가 발생하였습니다.(Socket Open Error)~r~n전산관리자에게 문의 바랍니다.")
	Return
End If

// Segment Seperator : 0X1D
//	Attribute Seperator : 0X1C
lch_seg_sep = CharA(29)
lch_attr_sep = CharA(28)

// Packet Header Definition
ls_code = "8010"
ls_segno = "001"
ls_id = "9999999999"
ls_auth = "0123456789012345"

// Body
ls_body = "04"		// Attribute No.
ls_body += "0204" + ls_van + lch_attr_sep		// Attr1 : VAN Flag
ls_body += "0205" + ls_file_transfer + lch_attr_sep		// Attr2 : EDI파일 전송여부(Y/N)
ls_body += "0206" + ls_filename + lch_attr_sep		//	Attr3 : EDI파일 이름
ls_body += "0207" + ls_approvaldt	// Attr4 : 신용카드 승인일자

// Header
ls_header = ls_code + "0000" + fs_fill_zeroes(String(LenA(ls_body)), -4) + ls_segno + ls_id + ls_auth

// Entire Packet
ls_buffer = ls_header + lch_seg_sep + ls_body

// TCP Send
ll_length = LenA(ls_buffer)
ll_return = lu_api.PBTcpWriteA(ll_socket, ls_buffer, ll_length)
If ll_return <> ll_length Then
	f_msg_usr_err(9000, This.Title, "청구요청에 대한 통신 Error가 발생하였습니다.~r~n전산관리자에게 문의 바랍니다.")
	lu_api.PBTcpCloseA(ll_socket)
	Return
End If

// TCP Receive
ll_return = lu_api.PBTcpReadA(ll_socket, ls_buffer, ll_length)
//If ll_return <> ll_length Then
If ll_return < 0 Then
	f_msg_usr_err(9000, This.Title, "청구요청에 대한 통신 Error가 발생하였습니다.~r~n전산관리자에게 문의 바랍니다.")
	lu_api.PBTcpCloseA(ll_socket)
	Return
End If

// Packet Decode
li_rc = fi_cut_string(ls_buffer, lch_seg_sep, ls_result[])
ls_header = ls_result[1]
ls_body = ls_result[2]
ls_rsp_code = MidA(ls_header, 5, 4)

li_rc = fi_cut_String(MidA(ls_body, 3), lch_attr_sep, ls_result[])
ls_rsp_msg = MidA(ls_result[1], 5)
If ls_rsp_code = "0000" Then
	f_msg_info(3000, This.Title, "청구요청작업 완료")
ElseIf ls_rsp_code = "6000" Then
	f_msg_usr_err(9000, This.Title, "INTERNAL ERROR(" + ls_rsp_msg + ")")
	lu_api.PBTcpCloseA(ll_socket)
	Return
ElseIf ls_rsp_code = "6002" Then
	f_msg_usr_err(9000, This.Title, "EDI FILE CREATE FAIL(" + ls_rsp_msg + ")")
	lu_api.PBTcpCloseA(ll_socket)
	Return
ElseIf ls_rsp_code = "6003" Then
	f_msg_usr_err(9000, This.Title, "EDI FILE SEND FAIL(" + ls_rsp_msg + ")")
	lu_api.PBTcpCloseA(ll_socket)
	Return
ElseIf ls_rsp_code = "6004" Then
	f_msg_usr_err(9000, This.Title, "EDI FILE RECEIVE FAIL(" + ls_rsp_msg + ")")
	lu_api.PBTcpCloseA(ll_socket)
	Return
ElseIf ls_rsp_code = "8099" Then
	f_msg_usr_err(9000, This.Title, "UNKNOWN ERROR(" + ls_rsp_msg + ")")
	lu_api.PBTcpCloseA(ll_socket)
	Return
End If

//	Socket Close
lu_api.PBTcpCloseA(ll_socket)

// Reset
This.TriggerEvent('ue_ok')

// Result Display : Popup Window Open
iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "청구파일전송결과"
iu_cust_msg.is_grp_name = "신용카드결제"
iu_cust_msg.is_data[1] = ls_filename
OpenWithParm(b7w_pop_inq_cardtext_sendsum_v20, iu_cust_msg)
end event

on b7w_req_card_invfile_v20.create
int iCurrent
call super::create
this.cb_transfer=create cb_transfer
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_transfer
end on

on b7w_req_card_invfile_v20.destroy
call super::destroy
destroy(this.cb_transfer)
end on

event open;call super::open;String ls_ref_desc, ls_van, ls_file_transfer, ls_file_prefix, ls_mmdd, ls_filename, ls_day, ls_nextday
Date ld_nextday
Int li_cnt

ls_van = fs_get_control("B7", "C150", ls_ref_desc)
ls_file_transfer = fs_get_control("B7", "C160", ls_ref_desc)
ls_file_prefix = fs_get_control("B7", "C180", ls_ref_desc)

// Filename : mmdd --> 다음 영업일
ld_nextday = Date(fdt_get_dbserver_now())
Do While True
	ld_nextday = fd_date_next(ld_nextday, 1)
	ls_nextday = String(ld_nextday, 'yyyy-mm-dd')
	
	SELECT to_char(to_date(:ls_nextday, 'yyyy-mm-dd'), 'd')
	INTO	:ls_day	
	FROM	dual;
	
	If ls_day <> '1' AND ls_day <> '7' Then
		SELECT count(*)
		INTO :li_cnt
		FROM holiday
		WHERE	to_char(hday, 'yyyy-mm-dd') = :ls_nextday;
		
		If li_cnt = 0 Then
			Exit;
		End If
	End If
Loop

ls_mmdd = String(ld_nextday, 'mmdd')
ls_filename = ls_file_prefix + ls_mmdd

dw_cond.Object.van[1] = ls_van
dw_cond.Object.file_transfer[1] = ls_file_transfer
dw_cond.Object.filename[1] = ls_filename

Return 0
end event

event ue_ok();call super::ue_ok;String ls_where, ls_approvaldt, ls_result[], ls_status, ls_ref_desc, ls_temp
Long ll_row
Int li_return
b7u_check_v20 lu_check

//	승인성공상태 : B7, C110의 두번째 Value
ls_temp = fs_get_control("B7", "C110", ls_ref_desc)
li_return = fi_cut_String(ls_temp, ";", ls_result[])
ls_status = ls_result[2]

// 승인/매출일자 입력 Check
ls_approvaldt = fs_snvl(String(dw_cond.Object.approvaldt[1], 'yyyy-mm-dd'), "")
If ls_approvaldt = "" Then
	f_msg_usr_err(200, This.Title, "승인/매출일자")
	dw_cond.SetRow(1)
	dw_cond.SetColumn("approvaldt")
	dw_cond.SetFocus()
	Return
End If

// 승인일자 Check
lu_check = Create b7u_check_v20
lu_check.is_title = This.Title
lu_check.is_caller = "b7w_req_card_invfile_v20%ue_ok"
lu_check.is_data[1] = ls_approvaldt
lu_check.uf_prc_db()
li_return = lu_check.ii_rc

If li_return < 0 Then
	Return
End If

// Retrieve
ls_where = " cardtext.approvaldt <= to_date('" + ls_approvaldt + "', 'yyyy-mm-dd') + 0.99999 "
ls_where += " AND cardtext.status = '" + ls_status + "' "
dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
Else
	cb_transfer.Enabled = True
End If

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
	//cb_transfer.Y = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	//cb_transfer.Y = newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

event type integer ue_reset();call super::ue_reset;cb_transfer.Enabled = False

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b7w_req_card_invfile_v20
integer x = 27
integer y = 60
integer width = 2181
integer height = 364
string dataobject = "b7dw_cnd_req_card_invfile_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b7w_req_card_invfile_v20
integer x = 2336
integer y = 60
end type

type p_close from w_a_reg_m`p_close within b7w_req_card_invfile_v20
integer x = 2642
integer y = 60
end type

type gb_cond from w_a_reg_m`gb_cond within b7w_req_card_invfile_v20
integer x = 9
integer width = 2222
integer height = 428
end type

type p_delete from w_a_reg_m`p_delete within b7w_req_card_invfile_v20
boolean visible = false
integer x = 311
integer y = 1832
end type

type p_insert from w_a_reg_m`p_insert within b7w_req_card_invfile_v20
boolean visible = false
integer x = 18
integer y = 1832
end type

type p_save from w_a_reg_m`p_save within b7w_req_card_invfile_v20
boolean visible = false
integer x = 608
integer y = 1832
end type

type dw_detail from w_a_reg_m`dw_detail within b7w_req_card_invfile_v20
integer x = 9
integer y = 440
integer width = 3031
integer height = 1264
string dataobject = "b7dw_m_req_card_invfile_v20"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;dw_cond.Enabled = True
p_ok.TriggerEvent("ue_enable")
end event

type p_reset from w_a_reg_m`p_reset within b7w_req_card_invfile_v20
boolean visible = false
integer x = 1125
integer y = 1832
end type

type cb_transfer from commandbutton within b7w_req_card_invfile_v20
integer x = 2336
integer y = 196
integer width = 517
integer height = 100
integer taborder = 12
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean enabled = false
string text = "결제청구요청전송"
end type

event clicked;Parent.TriggerEvent('ue_request')
end event

