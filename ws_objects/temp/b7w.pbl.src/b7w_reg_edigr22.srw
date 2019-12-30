$PBExportHeader$b7w_reg_edigr22.srw
$PBExportComments$[jsha] 출금의뢰응답
forward
global type b7w_reg_edigr22 from w_a_reg_m_sql
end type
type p_1 from u_p_fileread within b7w_reg_edigr22
end type
type p_payment from u_p_payment within b7w_reg_edigr22
end type
end forward

global type b7w_reg_edigr22 from w_a_reg_m_sql
integer width = 3209
integer height = 1988
event ue_fileread ( )
event type long ue_open ( )
event ue_payment ( )
p_1 p_1
p_payment p_payment
end type
global b7w_reg_edigr22 b7w_reg_edigr22

type variables
String is_paytype
end variables

event ue_fileread();// EA22 File Search
Constant Integer EA22_SIZE = 120, li_MAX_DIR = 255, li_MAX_FILES = 4097
Boolean	lb_return
Integer	li_return, li_filenum
Integer	li_read_bytes
String	ls_buffer
String	ls_curdir
String	ls_title, ls_pathname, ls_filename, ls_extension, ls_filter
Long		ll_rows, ll_return
String ls_mmdd
String ls_filenames[], ls_temp, ls_ref_desc
String ls_file_name, ls_outdt_mmdd, ls_prc_filename
Date ld_outdt

ls_file_name = Trim(dw_cond.object.s_file_name[1])
ld_outdt = dw_cond.object.s_outdt[1]
ls_outdt_mmdd = string(dw_cond.object.s_outdt[1],'mmdd')

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

ls_mmdd = String(dw_cond.object.s_outdt[1], 'mmdd')

// file name
ls_temp = fs_get_control("B7", "A420", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_filenames)

ls_title = "Select File"
ls_pathname = ""
ls_filename = ""
ls_extension = ""
ls_filter = ls_filenames[2] + " Files (" + ls_filenames[2] +"*.*), " + ls_filenames[2] + "*.*, All Files (*.*),*.*"
li_return = GetFileOpenName(ls_title, ls_pathname, ls_filename, ls_extension, ls_filter)

If li_return <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_usr_err(9000, Title, "File 정보가 없습니다.")
	Return
End If


ls_prc_filename = ls_filenames[2] + ls_outdt_mmdd

If ls_filename <> ls_prc_filename Then
	f_msg_usr_err(9000, Title,"'"+ ls_prc_filename + "' File을 선택하셔야 합니다.")
	return 
End if

SetPointer(Arrow!)

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api

SetPointer(HourGlass!)
ls_pathname = Upper(ls_pathname)
ls_filename = Upper(ls_filename)

b7u_dbmgr1 lu_dbmgr1 
lu_dbmgr1 = Create b7u_dbmgr1

lu_dbmgr1.is_caller = "b7w_reg_edigr22"
lu_dbmgr1.is_Title = This.Title
lu_dbmgr1.is_data[1] = ls_pathname
lu_dbmgr1.is_data[2] = ls_filename
lu_dbmgr1.is_data[3] = ls_file_name
lu_dbmgr1.is_data[4] = Trim(String(ld_outdt, 'yyyymmdd'))
lu_dbmgr1.is_data[5] = gs_user_id

lu_dbmgr1.uf_prc_db()

If lu_dbmgr1.ii_rc = -1 THen
	Destroy lu_dbmgr1
	return
Elseif lu_dbmgr1.ii_rc = 0 then
	This.TriggerEvent("ue_payment")
End IF

TriggerEvent('ue_open')
TriggerEvent('ue_ok')
end event

event type long ue_open();String ls_temp, ls_ref_desc, ls_status[]
Integer li_return
String ls_file_name
Date ld_outdt

ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_status[])

SELECT file_name, outdt
INTO :ls_file_name, :ld_outdt
FROM banktextstatus
WHERE status = :ls_status[2]; // status = 신청

If ls_file_name <> "" Then
	dw_cond.object.s_file_name[1] = ls_file_name
	dw_cond.object.s_outdt[1] = ld_outdt
	dw_cond.object.msg_1.visible = True
	dw_cond.object.msg_2.visible = False
	p_1.TriggerEvent('ue_enable')
Else
	dw_cond.object.msg_2.visible = True
	dw_cond.object.msg_1.visible = False
	p_1.TriggerEvent('ue_disable')
End If

ls_file_name = ""
setnull(ld_outdt)
SELECT file_name, outdt
INTO :ls_file_name, :ld_outdt
FROM banktextstatus
WHERE status = :ls_status[3]; // status = 응답확인

If ls_file_name <> "" Then
	dw_cond.object.s_file_name[1] = ls_file_name
	dw_cond.object.s_outdt[1] = ld_outdt
	p_payment.TriggerEvent('ue_enable')
Else
	p_payment.TriggerEvent('ue_disable')
End If

Return 0
end event

event ue_payment();//입력한 내역을 입금 반영 처리
String ls_errmsg, ls_pgm_id, ls_check_yn, ls_filenm
String ls_temp, ls_ref_desc, ls_pay_type[]
Double lb_count
Long  ll_return
Int    li_cnt

ls_filenm = dw_cond.Object.s_file_name[1]
ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ll_return = -1

//입금유형(REQDTL:PAYTYPE)
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_pay_type[])
//입금유형- 자동이체type
If IsNull(ls_pay_type[3]) Or ls_pay_type[3] = "" Then Return 

////해당 row의 자료가 없을때..
//If dw_detail.RowCount() = 0  Then Return

//SELECT BANKTEXT -> INSERT REQPAY
SQLCA.B7CMSREQPAY(ls_filenm, gs_user_id,ls_pgm_id,ll_return,ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return 
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

//지로 입금 처리
SQLCA.B5REQPAY2DTL_NOSEQ(ls_pay_type[3], gs_user_id, ls_pgm_id,ll_return, ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return 

ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

If ll_return <> 0 Then	//실패
	f_msg_info(3000, Title, "입금TR생성이 되지 않았습니다.")
	Return 
Else							//성공
	f_msg_info(3000, Title, "은행이체 입금 처리 반영(건수 : " + String(lb_count)+ ")")
	Return
End If

end event

on b7w_reg_edigr22.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_payment=create p_payment
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_payment
end on

on b7w_reg_edigr22.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_payment)
end on

event open;call super::open;TriggerEvent('ue_open')
end event

event ue_ok();call super::ue_ok;String ls_file_name, ls_payid, ls_result_code, ls_error_code, ls_outdt_fr, ls_outdt_to
String ls_s_file_name, ls_s_outdt
Date ld_outdt_fr, ld_outdt_to, ld_s_outdt
String ls_where
Long ll_rows

ls_s_file_name = Trim(dw_cond.object.s_file_name[1])
ls_s_outdt = String(dw_cond.object.s_outdt[1],'yyyymmdd')
ld_s_outdt = dw_cond.object.s_outdt[1]
If IsNull(ls_s_file_name) Then ls_s_file_name = ""
If IsNull(ls_s_outdt) Then ls_s_outdt = ""

ls_file_name = Trim(dw_cond.object.file_name[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_result_code = Trim(dw_cond.object.result_code[1])
ls_error_code = Trim(dw_cond.object.error_code[1])
ld_outdt_fr = dw_cond.object.outdt_fr[1]
ld_outdt_to = dw_cond.object.outdt_to[1]
ls_outdt_fr = Trim(String(ld_outdt_fr, 'yyyymmdd'))
ls_outdt_to = Trim(String(ld_outdt_to, 'yyyymmdd'))

If IsNull(ls_file_name) Then ls_file_name = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_result_code) Then ls_result_code = ""
If IsNull(ls_error_code) Then ls_error_code = ""
If IsNull(ls_outdt_fr) Then ls_outdt_fr = ""
If IsNull(ls_outdt_to) Then ls_outdt_to = ""

// Dynamic SQL
ls_where = ""

If ls_file_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "file_name = '" + ls_file_name + "' "
//Else
//	If ls_s_file_name <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//		ls_where += "file_name = '" + ls_s_file_name + "' "
//	End If
//
//	If ls_s_outdt <> "" Then
//		If ls_where <> "" Then ls_where += " AND "
//		ls_where += "to_char(outdt, 'yyyymmdd') = '" + ls_s_outdt + "' "
//	End If
End If

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "payid = '" + ls_payid + "' "
End If

If ls_result_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "result_code = '" + ls_result_code + "' "
End If

If ls_error_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "error_code = '" + ls_error_code + "' "
End If

If ls_outdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(outdt, 'yyyymmdd') >= '" + ls_outdt_fr + "' "
End If

If ls_outdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(outdt, 'yyyymmdd') <= '" + ls_outdt_to + "' "
End If

dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b7w_reg_edigr22
integer width = 2094
integer height = 576
string dataobject = "b7dw_cnd_reg_edigr22"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b1w_hlp_payid"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data[1]
		End If
End Choose
end event

type p_ok from w_a_reg_m_sql`p_ok within b7w_reg_edigr22
integer x = 2309
integer y = 116
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b7w_reg_edigr22
integer x = 2619
integer y = 116
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b7w_reg_edigr22
integer width = 2149
integer height = 648
end type

type p_save from w_a_reg_m_sql`p_save within b7w_reg_edigr22
boolean visible = false
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b7w_reg_edigr22
integer x = 37
integer y = 664
integer width = 3113
integer height = 1196
string dataobject = "b7dw_reg_edigr22_m"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ib_highlight = True

ldwo_sort = Object.payid_t
uf_init(ldwo_sort)

end event

type p_1 from u_p_fileread within b7w_reg_edigr22
integer x = 2309
integer y = 244
boolean bringtotop = true
boolean originalsize = false
end type

type p_payment from u_p_payment within b7w_reg_edigr22
integer x = 2619
integer y = 244
boolean bringtotop = true
boolean originalsize = false
end type

