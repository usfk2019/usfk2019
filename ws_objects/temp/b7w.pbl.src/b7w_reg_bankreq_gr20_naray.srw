﻿$PBExportHeader$b7w_reg_bankreq_gr20_naray.srw
$PBExportComments$[jwlee]자동이체(EDI) 신청 응답_naray용
forward
global type b7w_reg_bankreq_gr20_naray from w_a_reg_m_sql
end type
type p_1 from u_p_fileread within b7w_reg_bankreq_gr20_naray
end type
end forward

global type b7w_reg_bankreq_gr20_naray from w_a_reg_m_sql
integer width = 3232
integer height = 1880
event ue_fileread ( )
event type long ue_open ( )
p_1 p_1
end type
global b7w_reg_bankreq_gr20_naray b7w_reg_bankreq_gr20_naray

event ue_fileread();Constant Integer EA20_SIZE = 150, li_MAX_DIR = 255, li_MAX_FILES = 4097
Boolean	lb_return
Integer	li_return, li_filenum
Integer	li_read_bytes
String	ls_buffer
String	ls_curdir
String	ls_pathname, ls_filename, ls_extension, ls_filter
Long		ll_rows, ll_return
String ls_mmdd
String ls_filenames[], ls_temp, ls_ref_desc
String ls_file_name, ls_receiptdt_mmdd, ls_prc_filename
Date ld_receiptdt

ls_file_name = Trim(dw_cond.object.bankreqstatus_file_name[1])
ld_receiptdt = dw_cond.object.bankreqstatus_receiptdt[1]
ls_receiptdt_mmdd = string(dw_cond.object.bankreqstatus_receiptdt[1],'mmdd')

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

// 신청파일이름의 mmdd
ls_mmdd = MidA(dw_cond.object.bankreqstatus_file_name[1], 5, 4)

// file name
ls_temp = fs_get_control("B7", "A605", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_filenames)

//디렉토리
ls_pathname = fs_get_control("B7", "A400", ls_ref_desc)

ls_filename = ""
ls_extension = ""
ls_filter = ls_filenames[3] + " Files (" + ls_filenames[3] + "*.*), " + ls_filenames[3] +  "*.*"
li_return = GetFileOpenName("Select File", ls_pathname, ls_filename, ls_extension, ls_filter)

If li_return <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_info(1001, Title, ls_filename)
	Return
End If

SetPointer(Arrow!)

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api

SetPointer(HourGlass!)

ls_pathname = Upper(ls_pathname)
ls_filename = Upper(ls_filename)

ls_prc_filename = ls_filenames[3] + ls_receiptdt_mmdd

If ls_filename <> ls_prc_filename Then
	f_msg_usr_err(9000, Title,"'"+ ls_prc_filename + "' File을 선택하셔야 합니다.")
	return 
End if

b7u_dbmgr3_naray lu_dbmgr
lu_dbmgr = Create b7u_dbmgr3_naray

lu_dbmgr.is_caller  = "EDI GR20%FileRead"
lu_dbmgr.is_title   = This.Title
lu_dbmgr.is_data[1] = ls_pathname
lu_dbmgr.is_data[2] = ls_filename   //GR20파일
lu_dbmgr.is_data[3] = ls_file_name  //GR22파일
lu_dbmgr.is_data[4] = Trim(String(ld_receiptdt, 'yyyymmdd'))
lu_dbmgr.is_data[5] = gs_user_id

lu_dbmgr.uf_prc_db_02()

If lu_dbmgr.ii_rc = -1 Then
	Destroy lu_dbmgr	
	return
Elseif lu_dbmgr.ii_rc = 0 then
	dw_cond.object.bankreq_file_name[1] = ls_file_name
	TriggerEvent('ue_open')
	TriggerEvent('ue_ok')
End IF

Destroy lu_dbmgr

return
end event

event type long ue_open();String ls_file_name, ls_worktype, ls_temp, ls_worktypes[], ls_ref_desc, ls_status[]
Integer li_result, li_cnt
Date ld_receiptdt
String ls_filter
DatawindowChild ldc_filename

// worktype = 출금이체신청-이용기관
ls_temp = fs_get_control("B7", "A500",ls_ref_desc)
li_result = fi_cut_string(ls_temp, ";", ls_worktypes) 
// status = 신청
ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
li_result = fi_cut_string(ls_temp, ";", ls_status)


If dw_cond.GetChild('bankreq_file_name', ldc_filename) = - 1 Then 
   MessageBox("Error", "Not a DataWindowChild")
End If

// 파일이름 dddw Filter
ls_filter = "worktype = '"+ ls_worktypes[2] +"'"
ldc_filename.setFilter(ls_filter)
ldc_filename.filter()
ldc_filename.SetTransObject(SQLCA)
ldc_filename.Retrieve()

//신청인 파일을 가져옴
SELECT file_name, receiptdt
INTO :ls_file_name, :ld_receiptdt 
FROM bankreqstatus
WHERE worktype = :ls_worktypes[2]
AND status = :ls_status[2];

If ls_file_name <> "" Then
	dw_cond.object.bankreqstatus_file_name[1] = ls_file_name
	dw_cond.object.bankreqstatus_receiptdt[1] = ld_receiptdt
	dw_cond.object.worktype[1] = ls_worktypes[2]
	dw_cond.object.msg_1.visible = True
	dw_cond.object.msg_2.visible = False
Else
	dw_cond.object.msg_2.visible = True
	dw_cond.object.msg_1.visible = False
	p_1.TriggerEvent('ue_disable')
End If

Return 0
end event

on b7w_reg_bankreq_gr20_naray.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b7w_reg_bankreq_gr20_naray.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;String ls_where
String ls_file_name, ls_payid, ls_result_code, ls_error_code, ls_receiptdt_fr, ls_receiptdt_to
Date ld_receiptdt_fr, ld_receiptdt_to
Long ll_row



ls_file_name = Trim(dw_cond.object.bankreq_file_name[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_result_code = Trim(dw_cond.object.result_code[1])
ls_error_code = Trim(dw_cond.object.error_code[1])
ld_receiptdt_fr = dw_cond.object.bankreq_receiptdt_fr[1]
ld_receiptdt_to = dw_cond.object.bankreq_receiptdt_to[1]
ls_receiptdt_fr = Trim(String(ld_receiptdt_fr, 'yyyymmdd'))
ls_receiptdt_to = Trim(String(ld_receiptdt_to, 'yyyymmdd'))

If IsNull(ls_file_name) Then ls_file_name = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_result_code) Then ls_result_code = ""
If IsNull(ls_error_code) Then ls_error_Code = ""
If IsNull(ls_receiptdt_fr) Then ls_receiptdt_fr = ""
If IsNull(ls_receiptdt_to) Then ls_receiptdt_to = ""

// Dynamic SQL
ls_where = ""

If ls_file_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " file_name = '" + ls_file_name + "' "
End If

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " payid = '" + ls_payid + "' "
End If

If ls_result_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " result_code = '" + ls_result_code + "' "
End If

If ls_error_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " error_code = '" + ls_error_code + "' "
End If

If ls_receiptdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(receiptdt, 'yyyymmdd') >= '" + ls_receiptdt_fr + "' "
End If

If ls_receiptdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(receiptdt, 'yyyymmdd') <= '" + ls_receiptdt_to + "' "
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

event open;call super::open;TriggerEvent('ue_open')
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b7w_reg_bankreq_gr20_naray
integer y = 56
integer width = 2469
integer height = 528
string dataobject = "b7dw_cnd_reg_bankreq_gr20"
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.payid
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

type p_ok from w_a_reg_m_sql`p_ok within b7w_reg_bankreq_gr20_naray
integer x = 2642
integer y = 96
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b7w_reg_bankreq_gr20_naray
integer x = 2642
integer y = 224
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b7w_reg_bankreq_gr20_naray
integer y = 16
integer width = 2501
integer height = 600
end type

type p_save from w_a_reg_m_sql`p_save within b7w_reg_bankreq_gr20_naray
boolean visible = false
integer x = 2830
integer y = 496
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b7w_reg_bankreq_gr20_naray
integer x = 37
integer y = 644
integer width = 3109
integer height = 1100
string dataobject = "b7dw_reg_bankreq_gr20_m"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ib_highlight = True

ldwo_sort = Object.receiptdt_t
uf_init(ldwo_sort)

end event

type p_1 from u_p_fileread within b7w_reg_bankreq_gr20_naray
integer x = 2642
integer y = 352
boolean bringtotop = true
end type

