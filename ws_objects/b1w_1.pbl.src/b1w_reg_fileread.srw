$PBExportHeader$b1w_reg_fileread.srw
$PBExportComments$[kem] 고객정보수신파일생성
forward
global type b1w_reg_fileread from w_a_reg_m_sql
end type
type p_reset from u_p_reset within b1w_reg_fileread
end type
type p_fileread from u_p_fileread within b1w_reg_fileread
end type
type cb_1 from commandbutton within b1w_reg_fileread
end type
end forward

global type b1w_reg_fileread from w_a_reg_m_sql
integer width = 2011
integer height = 1500
windowstate windowstate = normal!
event type integer ue_reset ( )
event ue_fileread ( )
p_reset p_reset
p_fileread p_fileread
cb_1 cb_1
end type
global b1w_reg_fileread b1w_reg_fileread

type variables
String is_req_status, is_act_status
end variables

event type integer ue_reset();p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_disable")
p_fileread.TriggerEvent("ue_disable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

Return 0
end event

event ue_fileread();Boolean lb_return
Integer li_return, li_value
String ls_curdir, ls_pathname, ls_filename, ls_count, ls_workmm, ls_comcd
Long   ll_rc
u_api lu_api
lu_api = Create u_api

//처리상태가 파일요청인 발생년월 Select
SELECT max(workmm)
INTO   :ls_workmm
FROM   reqtelworklog;
//WHERE  comcd  = :ls_comcd;
//AND    status = :is_req_status;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "")
	Return
ElseIf SQLCA.SQLCode = 100 Then
	f_msg_info(9000, title, "처리할 자료가 없습니다.")
	p_fileread.TriggerEvent("ue_disable")
	Return
End If

If IsNull(ls_workmm) Or ls_workmm = "" Then
	f_msg_info(9000, Title, "처리할 자료가 없습니다.")
	p_fileread.TriggerEvent("ue_disable")
	Return 
End If


ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, Title, "Current Directory에 대한 정보가 없습니다.")
	Destroy lu_api
	Return
End If

li_value = GetFileOpenName("Select File", &
									ls_pathname, ls_filename, "doc", &
									"Text Files (*.txt), *.txt" ) 

If li_value < 0 Then
	f_msg_info(1200, Title, ls_filename)
	dw_detail.SetFocus()
	Return
End If
dw_detail.SetFocus()
lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)

Destroy lu_api


If f_msg_ques_yesno2(9000, Title, "파일[ " + ls_filename + " ]이 선택되었습니다. 선택된 파일을 수신하시겠습니까?", 1) = 2 Then
	Return
End If

ls_comcd = Trim(dw_cond.Object.comcd[1])

b1u_dbmgr15 lu_dbmgr
lu_dbmgr = Create b1u_dbmgr15

ll_rc = lu_dbmgr.ii_rc
lu_dbmgr.is_title   = This.Title
lu_dbmgr.is_caller  = "FILE READ"
lu_dbmgr.is_data[1] = ls_pathname   // 파일명(경로포함)
lu_dbmgr.is_data[2] = ls_workmm     // 발생년월
lu_dbmgr.is_data[3] = ls_comcd      // 사업자
lu_dbmgr.is_data[4] = is_act_status // 파일수신상태
lu_dbmgr.is_data[5] = ls_filename   // 파일명만

lu_dbmgr.uf_prc_db_01()
ll_rc = lu_dbmgr.ii_rc


//***** 결과 *****
If ll_rc < 0 Then	//실패
	Destroy lu_dbmgr
	Return
Else					//성공
	ls_count = lu_dbmgr.is_data2[1]
End If

Destroy lu_dbmgr

f_msg_info(3000, Title, "고객수신파일")

p_ok.TriggerEvent("Clicked")
end event

on b1w_reg_fileread.create
int iCurrent
call super::create
this.p_reset=create p_reset
this.p_fileread=create p_fileread
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reset
this.Control[iCurrent+2]=this.p_fileread
this.Control[iCurrent+3]=this.cb_1
end on

on b1w_reg_fileread.destroy
call super::destroy
destroy(this.p_reset)
destroy(this.p_fileread)
destroy(this.cb_1)
end on

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
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

p_ok.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")
p_fileread.TriggerEvent("ue_enable")
end event

event open;call super::open;dw_cond.object.comcd[1] = '1000'

TriggerEvent('ue_ok')
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b1w_reg_fileread
integer y = 72
integer width = 1289
integer height = 160
string dataobject = "b1dw_cnd_reg_filewrite"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within b1w_reg_fileread
integer x = 37
integer y = 316
end type

type p_close from w_a_reg_m_sql`p_close within b1w_reg_fileread
integer x = 914
integer y = 316
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b1w_reg_fileread
integer x = 37
integer y = 20
integer width = 1833
integer height = 252
end type

type p_save from w_a_reg_m_sql`p_save within b1w_reg_fileread
boolean visible = false
integer x = 2601
integer y = 188
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b1w_reg_fileread
integer y = 464
integer width = 1851
integer height = 836
string dataobject = "b1dw_reg_filewrite"
boolean ib_sort_use = false
boolean ib_highlight = true
end type

type p_reset from u_p_reset within b1w_reg_fileread
integer x = 622
integer y = 316
boolean bringtotop = true
end type

type p_fileread from u_p_fileread within b1w_reg_fileread
integer x = 329
integer y = 316
boolean bringtotop = true
end type

type cb_1 from commandbutton within b1w_reg_fileread
integer x = 1344
integer y = 320
integer width = 494
integer height = 88
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = roman!
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
iu_cust_msg.is_pgm_name = "고객정보List"
iu_cust_msg.is_grp_name = "고객정보"
iu_cust_msg.is_data[1] = ls_seq

OpenWithParm(b1w_inq_reqtelmst_pop, iu_cust_msg, gw_mdi_frame)
end event

