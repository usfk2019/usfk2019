$PBExportHeader$b1w_1_prc_contractupload_req_v20.srw
$PBExportComments$[jsha] 계약정보파일자동처리
forward
global type b1w_1_prc_contractupload_req_v20 from w_a_inq_m
end type
type cb_1 from commandbutton within b1w_1_prc_contractupload_req_v20
end type
end forward

global type b1w_1_prc_contractupload_req_v20 from w_a_inq_m
integer width = 3159
event ue_process ( )
cb_1 cb_1
end type
global b1w_1_prc_contractupload_req_v20 b1w_1_prc_contractupload_req_v20

event ue_process();Long ll_row
String ls_file_code, ls_filename, ls_pgm_id, ls_errmsg
Long ll_return
double ll_seqno,ll_prccount

ll_row = dw_detail.GetRow()
If ll_row <= 0 Then Return

ll_seqno = dw_detail.Object.fileupload_worklog_seqno[ll_row]
ls_file_code = dw_detail.Object.fileupload_worklog_file_code[ll_row]
ls_filename = dw_detail.Object.fileupload_worklog_filename[ll_row]
ll_return = -1
ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]

//계약정보파일처리 = 2005.11.10
//CONTRACTUPLOAD_PRC(double P_SEQNO,string P_FILE_CODE,string P_FILENAME,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BILLING~".~"CONTRACTUPLOAD_PRC~""

SQLCA.CONTRACTUPLOAD_PRC(ll_seqno, ls_file_code, ls_filename, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, ll_prccount)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	Return 
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	Return 
ElseIf ll_return >= 0 Then
	MessageBox(This.Title, "Process Completed.")
End If

This.TriggerEvent('ue_ok')
end event

on b1w_1_prc_contractupload_req_v20.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on b1w_1_prc_contractupload_req_v20.destroy
call super::destroy
destroy(this.cb_1)
end on

event ue_ok();call super::ue_ok;Long ll_row
Int li_return
String ls_file_code, ls_file_status, ls_status
String ls_where, ls_temp, ls_ref_desc, ls_result[]

ls_temp = fs_get_control("B1", "P320", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result[])

ls_file_code = dw_cond.Object.file_code[1]
ls_file_status = dw_cond.Object.file_status[1]
ls_status = dw_cond.Object.status[1]

If IsNull(ls_file_code) Then ls_file_code = ""
If IsNull(ls_file_status) Then ls_file_status = ""
If IsNull(ls_status) Then ls_status = ""

ls_where = ""
If ls_file_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.file_code='" + ls_file_code + "' "
End If
If ls_file_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.file_status='" + ls_file_status + "' "
End If
If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.status='" + ls_status + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(ls_result[1])

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

Return
end event

type dw_cond from w_a_inq_m`dw_cond within b1w_1_prc_contractupload_req_v20
integer width = 2126
string dataobject = "b1dw_cnd_reg_contractupload_err_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within b1w_1_prc_contractupload_req_v20
integer x = 2327
end type

type p_close from w_a_inq_m`p_close within b1w_1_prc_contractupload_req_v20
integer x = 2629
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_1_prc_contractupload_req_v20
integer width = 2199
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_1_prc_contractupload_req_v20
integer height = 1164
string dataobject = "b1dw_m_reg_contractupload_err_v20"
boolean ib_sort_use = false
end type

event dw_detail::ue_init();call super::ue_init;//dwObject ldwo_SORT
//
//ib_sort_use = True
//ldwo_SORT = Object.fileupload_worklog_etime_t
//uf_init(ldwo_SORT)
end event

event dw_detail::clicked;call super::clicked;String ls_file_status, ls_status, ls_temp, ls_ref_desc, ls_result1[], ls_result2[]
int li_return

// System Parameter
ls_temp = fs_get_control("B1", "P330", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result1[])

ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P331", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result2[])

If row = 0 then Return

If IsSelected(row) then
	SelectRow(row , FALSE)
	
	// button deactivate
	cb_1.enabled = False
Else
   SelectRow(0, FALSE)
	SelectRow(row , TRUE)
	
	// button activate
	ls_file_status = dw_detail.Object.fileupload_worklog_file_status[row]
	ls_status = dw_detail.Object.fileupload_worklog_status[row]
	
	If ls_file_status = ls_result1[2] AND ls_status = ls_result2[1] Then
		cb_1.enabled = True
	ElseIf ls_file_status = ls_result1[2] AND ls_status = ls_result2[5] Then
		cb_1.enabled = True
	Else
		cb_1.enabled = False
	End If
End If
end event

type cb_1 from commandbutton within b1w_1_prc_contractupload_req_v20
integer x = 2331
integer y = 180
integer width = 581
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean enabled = false
string text = "계약처리"
end type

event clicked;Parent.TriggerEvent('ue_process')
end event

