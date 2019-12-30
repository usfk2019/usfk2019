$PBExportHeader$p1w_reg_admst_temp_icn.srw
$PBExportComments$[jsha] 장비판매파일처리
forward
global type p1w_reg_admst_temp_icn from w_a_reg_m_sql
end type
type p_fileread from u_p_fileread within p1w_reg_admst_temp_icn
end type
end forward

global type p1w_reg_admst_temp_icn from w_a_reg_m_sql
integer width = 3721
event ue_fileread ( )
p_fileread p_fileread
end type
global p1w_reg_admst_temp_icn p1w_reg_admst_temp_icn

event ue_fileread();String ls_title, ls_pathname, ls_filename, ls_extension, ls_filter, ls_curdir
Integer li_return
Constant Integer li_MAX_DIR = 255
Boolean lb_return

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

ls_title = "SELECT FILE"
ls_pathname = "C:\"
ls_filename = ""
ls_extension = ""
ls_filter = "csv Files (*.csv), *.csv, All Files (*.*), *.*"
li_return = GetFileOpenName(ls_title, ls_pathname, ls_filename, ls_extension, ls_filter)

If li_return <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_usr_err(9000, Title, "File 정보가 없습니다.")
	Return
End If

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api

SetPointer(HourGlass!)

ls_pathname = Upper(ls_pathname)
ls_filename = Upper(ls_filename)

p1c_dbmgr1 lu_dbmgr
lu_dbmgr = Create p1c_dbmgr1

lu_dbmgr.is_title = This.title
lu_dbmgr.is_caller = "p1w_reg_admst_temp_icn%fileread"
lu_dbmgr.is_data[1] = ls_pathname
lu_dbmgr.is_data[2] = ls_filename
lu_dbmgr.is_data[3] = gs_user_id
lu_dbmgr.is_data[4] = gs_pgm_id[gi_open_win_no]

lu_dbmgr.uf_prc_db()

If lu_dbmgr.ii_rc < 0 Then
	f_msg_info(3010, This.title, "File Read")
	Destroy lu_dbmgr
	Return
Else 
	f_msg_info(3000, This.title, "File Read")
	Destroy lu_dbmgr
End If

TriggerEvent("ue_ok")
end event

on p1w_reg_admst_temp_icn.create
int iCurrent
call super::create
this.p_fileread=create p_fileread
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_fileread
end on

on p1w_reg_admst_temp_icn.destroy
call super::destroy
destroy(this.p_fileread)
end on

event ue_ok();call super::ue_ok;String ls_where, ls_updtdt_fr, ls_updtdt_to, ls_result
Date ld_updtdt_fr, ld_updtdt_to
Long ll_row

dw_cond.AcceptText()

ld_updtdt_fr = dw_cond.Object.updtdt_fr[1]
ld_updtdt_to = dw_cond.Object.updtdt_to[1]

ls_updtdt_fr = String(ld_updtdt_fr, 'yyyymmdd')
ls_updtdt_to = String(ld_updtdt_to, 'yyyymmdd')
ls_result = Trim(dw_cond.Object.result[1])

ls_where = ""
If ls_updtdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(crtdt,'yyyymmdd') >= '" + ls_updtdt_fr + "' "
End If
If ls_updtdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(crtdt,'yyyymmdd') <= '" + ls_updtdt_to + "' "
End If
If ls_result = 'Y' Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "result_yn = 'Y'"
End If
If ls_result = 'N' Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "result_yn = 'N'"
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

p_fileread.TriggerEvent("ue_enable")
	
end event

event open;call super::open;p_fileread.TriggerEvent("ue_disable")

Return 0
end event

type dw_cond from w_a_reg_m_sql`dw_cond within p1w_reg_admst_temp_icn
integer y = 104
integer width = 2130
integer height = 144
string dataobject = "p1dw_cnd_reg_admst_temp_icn"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within p1w_reg_admst_temp_icn
integer x = 2368
integer y = 64
end type

type p_close from w_a_reg_m_sql`p_close within p1w_reg_admst_temp_icn
integer x = 2674
integer y = 64
end type

type gb_cond from w_a_reg_m_sql`gb_cond within p1w_reg_admst_temp_icn
integer y = 24
integer width = 2235
integer height = 256
end type

type p_save from w_a_reg_m_sql`p_save within p1w_reg_admst_temp_icn
boolean visible = false
end type

type dw_detail from w_a_reg_m_sql`dw_detail within p1w_reg_admst_temp_icn
integer y = 300
integer width = 3589
string dataobject = "p1dw_reg_admst_temp_icn"
end type

event dw_detail::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.serialno_t
uf_init(ldwo_sort,'A', RGB(0,0,128))
end event

type p_fileread from u_p_fileread within p1w_reg_admst_temp_icn
integer x = 3195
integer y = 64
boolean bringtotop = true
boolean originalsize = false
end type

