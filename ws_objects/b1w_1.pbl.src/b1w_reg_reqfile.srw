$PBExportHeader$b1w_reg_reqfile.srw
$PBExportComments$[ceusee] 고객정보요청
forward
global type b1w_reg_reqfile from w_a_reg_m_sql
end type
type p_reset from u_p_reset within b1w_reg_reqfile
end type
type p_filewrite from u_p_filewrite within b1w_reg_reqfile
end type
type cb_1 from commandbutton within b1w_reg_reqfile
end type
end forward

global type b1w_reg_reqfile from w_a_reg_m_sql
integer width = 1970
integer height = 1212
windowstate windowstate = normal!
event type long ue_reset ( )
event type long ue_filewrite ( )
p_reset p_reset
p_filewrite p_filewrite
cb_1 cb_1
end type
global b1w_reg_reqfile b1w_reg_reqfile

type variables
String is_noprce, is_prce
end variables

event type long ue_reset();p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_disable")
p_filewrite.TriggerEvent("ue_disable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

Return 0
end event

event type long ue_filewrite();Constant Integer li_MAX_DIR = 255
Boolean	lb_return
Integer	li_return, li_rc
Integer	li_read_bytes, li_holiday
String	ls_buffer
String	ls_curdir
String   ls_filename, ls_filter, ls_pathname, ls_workmm, ls_comcd
b1u_dbmgr15  lu_dbmgr


//처리상태가 파일요청인 발생년월 Select
ls_comcd = Trim(dw_cond.Object.comcd[1])
SELECT to_char(add_months(to_date(max(workmm), 'yyyymm'),1) , 'yyyymm')
INTO   :ls_workmm
FROM   reqtelworklog
WHERE  comcd  = :ls_comcd
AND    status = :is_prce;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error(reqtelworklog)")
	Return 0
ElseIf SQLCA.SQLCode = 100 Then
	f_msg_info(9000, Title, "처리할 자료가 없습니다.")
	p_filewrite.TriggerEvent("ue_disable")
	Return 0

End If

If IsNull(ls_workmm) Or ls_workmm = "" Then
	f_msg_info(9000, Title, "처리할 자료가 없습니다.")
	p_filewrite.TriggerEvent("ue_disable")
	Return 0
End If


//현재 폴더 설정
u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)
ls_filter = "TXT Files (*.txt),*.txt"
ls_filename = ""

//File Save
li_return = GetFileSaveName("Save File", ls_pathname, ls_filename, "", ls_filter)

If li_return <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_usr_err(1200, Title, ls_filename)
	Return 0
End If

lu_dbmgr = Create b1u_dbmgr15
lu_dbmgr.is_caller = "b1w_reg_reqfile%File Save"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_noprce
lu_dbmgr.is_data[2] = is_prce
lu_dbmgr.is_data[3] = ls_workmm
lu_dbmgr.is_data[4] = ls_pathname
lu_dbmgr.is_data[5] = ls_filename
lu_dbmgr.is_data[6] = ls_comcd
lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc
Destroy lu_dbmgr

If li_rc < 0 Then
	f_msg_info(3010, Title, "고객요청파일생성")
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
   Destroy lu_api
	Return  0
End If	

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api

f_msg_info(3000, Title, "고객요청파일생성")
p_filewrite.TriggerEvent("ue_disable")

p_ok.TriggerEvent("Clicked")

Return 0
end event

on b1w_reg_reqfile.create
int iCurrent
call super::create
this.p_reset=create p_reset
this.p_filewrite=create p_filewrite
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reset
this.Control[iCurrent+2]=this.p_filewrite
this.Control[iCurrent+3]=this.cb_1
end on

on b1w_reg_reqfile.destroy
call super::destroy
destroy(this.p_reset)
destroy(this.p_filewrite)
destroy(this.cb_1)
end on

event open;call super::open;String ls_ref_desc, ls_temp, ls_result[]

dw_cond.object.comcd[1] = '1000'

p_filewrite.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

ls_temp = fs_get_control("K1","K100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_result[])		
is_noprce  = ls_result[1]  //미처리 상태
is_prce  = ls_result[2]    //파일요청

TriggerEvent('ue_ok')


end event

event ue_ok();call super::ue_ok;String ls_comcd, ls_where
Long  ll_row

dw_cond.AcceptText()

ls_comcd = Trim(dw_cond.Object.comcd[1])

//Null Check
If IsNull(ls_comcd) Or ls_comcd = "" Then ls_comcd = ""

	
If ls_comcd = "" Then
	f_msg_info(200, Title, "사업자")
	dw_cond.SetFocus()
	dw_cond.setColumn("comcd")
	Return
End If
		

ls_where = ""

If ls_comcd <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " comcd = '" + ls_comcd + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	p_filewrite.TriggerEvent("ue_disable")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

p_ok.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")
p_filewrite.TriggerEvent("ue_enable")


		
		


end event

type dw_cond from w_a_reg_m_sql`dw_cond within b1w_reg_reqfile
integer y = 84
integer width = 1486
integer height = 132
string dataobject = "b1dw_cnd_reg_filewrite"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within b1w_reg_reqfile
integer x = 55
integer y = 312
end type

type p_close from w_a_reg_m_sql`p_close within b1w_reg_reqfile
integer x = 974
integer y = 316
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b1w_reg_reqfile
integer x = 14
integer y = 8
integer width = 1861
integer height = 260
end type

type p_save from w_a_reg_m_sql`p_save within b1w_reg_reqfile
boolean visible = false
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b1w_reg_reqfile
integer x = 23
integer y = 456
integer width = 1851
integer height = 572
string dataobject = "b1dw_reg_filewrite"
boolean ib_sort_use = false
boolean ib_highlight = true
end type

type p_reset from u_p_reset within b1w_reg_reqfile
integer x = 667
integer y = 316
boolean bringtotop = true
end type

type p_filewrite from u_p_filewrite within b1w_reg_reqfile
integer x = 366
integer y = 316
boolean bringtotop = true
end type

type cb_1 from commandbutton within b1w_reg_reqfile
integer x = 1381
integer y = 316
integer width = 494
integer height = 88
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "고객수신정보"
end type

event clicked;String ls_where, ls_seq
Long ll_row

If dw_detail.RowCount() <= 0 Then Return

ll_row = dw_detail.GetSelectedRow(0)

ls_seq = String(dw_detail.object.seq[ll_row])

If IsNull(ls_seq) OR ls_seq = '' Then Return

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "고객수신정보"
iu_cust_msg.is_grp_name = "고객정보"
iu_cust_msg.is_data[1] = ls_seq

OpenWithParm(b1w_inq_reqtelmst_pop, iu_cust_msg, gw_mdi_frame)
end event

