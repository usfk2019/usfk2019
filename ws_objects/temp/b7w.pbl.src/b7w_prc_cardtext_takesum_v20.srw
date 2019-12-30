$PBExportHeader$b7w_prc_cardtext_takesum_v20.srw
$PBExportComments$[jsha] 신용카드결제청구결과파일 수신
forward
global type b7w_prc_cardtext_takesum_v20 from w_a_reg_m_m
end type
type cb_req from commandbutton within b7w_prc_cardtext_takesum_v20
end type
end forward

global type b7w_prc_cardtext_takesum_v20 from w_a_reg_m_m
integer height = 1676
event ue_request ( )
cb_req cb_req
end type
global b7w_prc_cardtext_takesum_v20 b7w_prc_cardtext_takesum_v20

event ue_request();String ls_ipaddress, ls_port, ls_ref_desc, ls_result[]
String ls_header, ls_body, ls_buffer, ls_code, ls_segno, ls_id, ls_auth, ls_rsp_msg, ls_rsp_code
String ls_van
Char lch_seg_sep, lch_attr_sep
Long ll_socket, ll_length, ll_return
Int li_rc
u_api lu_api
lu_api = Create u_api

ls_van = fs_get_control("B7", "C150", ls_ref_desc)

//	IP : B7, C300
// PORT : B7, C310
ls_ipaddress = fs_get_control("B7", "C300", ls_ref_desc)
ls_port = fs_get_control("B7", "C310", ls_ref_desc)

// Segment Seperator : 0X1D
//	Attribute Sepserator : 0X1C
lch_seg_sep = CharA(29)
lch_attr_sep = CharA(28)

//	Socket Open
ll_socket = lu_api.PBTcpConnectA(ls_ipaddress, ls_port)
If ll_socket > 0 Then
	ls_buffer = ""
Else
	f_msg_usr_err(9000, This.Title, "통신Error가 발생하였습니다.(Socket Open Error)~r~n전산관리자에게 문의 바랍니다.")
	Return
End If

// Packet Header Definition
ls_code = "8020"
ls_segno = "001"
ls_id = "9999999999"
ls_auth = "0123456789012345"

// Body
ls_body = "01"		// Attribute No.
ls_body += "0204" + ls_van		// Attr1 : VAN Flag

// Header
ls_header = ls_code + "0000" + fs_fill_zeroes(String(LenA(ls_body)), -4) + ls_segno + ls_id + ls_auth

// Entire Packet
ls_buffer = ls_header + lch_seg_sep + ls_body

// TCP Send
ll_length = LenA(ls_buffer)
ll_return = lu_api.PBTcpWriteA(ll_socket, ls_buffer, ll_length)
If ll_return <> ll_length Then
	f_msg_usr_err(9000, This.Title, "입금파일 수신요청에 대한 통신 Error가 발생하였습니다.~r~n전산관리자에게 문의 바랍니다.")
	lu_api.PBTcpCloseA(ll_socket)
	Return
End If

// TCP Receive
ll_return = lu_api.PBTcpReadA(ll_socket, ls_buffer, ll_length)
If ll_return <> ll_length Then
	f_msg_usr_err(9000, This.Title, "입금파일 수신요청에 대한 통신 Error가 발생하였습니다.~r~n전산관리자에게 문의 바랍니다.")
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
	f_msg_info(3000, This.Title, "입금파일 수신요청작업 완료")
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

// Result Display
This.TriggerEvent('ue_ok')
end event

event ue_ok();call super::ue_ok;Long ll_row

ll_row = dw_master.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If
end event

event open;call super::open;This.TriggerEvent('ue_ok')
end event

on b7w_prc_cardtext_takesum_v20.create
int iCurrent
call super::create
this.cb_req=create cb_req
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_req
end on

on b7w_prc_cardtext_takesum_v20.destroy
call super::destroy
destroy(this.cb_req)
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	cb_req.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	cb_req.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_reg_m_m`dw_cond within b7w_prc_cardtext_takesum_v20
boolean visible = false
string dataobject = "b7dw_m_prc_cardtext_takesum_v20"
end type

event dw_cond::ue_init();call super::ue_init;//dwObject ldwo_sort
//
//ldwo_sort = Object.file_name_t
//uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

type p_ok from w_a_reg_m_m`p_ok within b7w_prc_cardtext_takesum_v20
boolean visible = false
end type

type p_close from w_a_reg_m_m`p_close within b7w_prc_cardtext_takesum_v20
integer x = 535
integer y = 1440
end type

type gb_cond from w_a_reg_m_m`gb_cond within b7w_prc_cardtext_takesum_v20
boolean visible = false
end type

type dw_master from w_a_reg_m_m`dw_master within b7w_prc_cardtext_takesum_v20
integer x = 32
integer y = 24
integer width = 3031
integer height = 644
string dataobject = "b7dw_m_prc_cardtext_takesum_v20"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.file_name_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

type dw_detail from w_a_reg_m_m`dw_detail within b7w_prc_cardtext_takesum_v20
integer x = 32
integer y = 704
integer width = 3031
integer height = 704
string dataobject = "b7dw_det_prc_cardtext_takesum_v20"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_where, ls_filename, ls_work_type, ls_temp, ls_ref_desc, ls_result[]
Long ll_row
Int li_rc

ls_filename = fs_snvl(dw_master.Object.file_name[al_select_row], "")
ls_work_type = fs_snvl(dw_master.Object.work_type[al_select_row], "")

ls_temp = fs_get_control("B7", "C260", ls_ref_desc)
li_rc = fi_cut_string(ls_temp, ";", ls_result[])

If ls_work_type = ls_result[1] Then	// 청구파일전송작업
	dw_detail.dataobject = "b7dw_det_prc_cardtext_takesum_v20"
	dw_detail.SetTransObject(SQLCA)
ElseIf ls_work_type = ls_result[2] Then		// 청구파일수신작업
	dw_detail.dataobject = "b7dw_det_prc_cardtext_takesum2_v20"
	dw_detail.SetTransObject(SQLCA)
End If

If ls_filename <> "" Then
	ls_where = " file_name = '" + ls_filename + "' "
End If

This.is_where = ls_where
ll_row = This.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return -1
ElseIf ll_Row = 0 Then
	//f_msg_info(1000, This.Title, "")
	Return 0
End If

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b7w_prc_cardtext_takesum_v20
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b7w_prc_cardtext_takesum_v20
boolean visible = false
end type

type p_save from w_a_reg_m_m`p_save within b7w_prc_cardtext_takesum_v20
boolean visible = false
end type

type p_reset from w_a_reg_m_m`p_reset within b7w_prc_cardtext_takesum_v20
boolean visible = false
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b7w_prc_cardtext_takesum_v20
integer x = 32
integer y = 668
end type

type cb_req from commandbutton within b7w_prc_cardtext_takesum_v20
integer x = 37
integer y = 1440
integer width = 453
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "파일수신요청"
end type

event clicked;Parent.TriggerEvent('ue_request')
end event

