$PBExportHeader$p1w_reg_ani_num.srw
$PBExportComments$[parkkh] ani번호 등록/변경/해지
forward
global type p1w_reg_ani_num from w_a_inq_m
end type
type p_new from u_p_new within p1w_reg_ani_num
end type
type p_change from u_p_change within p1w_reg_ani_num
end type
type p_term from u_p_term within p1w_reg_ani_num
end type
end forward

global type p1w_reg_ani_num from w_a_inq_m
integer width = 2446
integer height = 1824
event ue_new ( )
event ue_term ( )
event ue_change ( )
p_new p_new
p_change p_change
p_term p_term
end type
global p1w_reg_ani_num p1w_reg_ani_num

type variables
p1u_dbmgr1 iu_check
String is_ani_syscod[]
end variables

forward prototypes
public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to)
end prototypes

event ue_new();Integer	li_return
String ls_where, ls_validkey, ls_contractseq, ls_itemcod, ls_svctype
Long ll_row, ll_cnt

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "Ani#등록"
iu_cust_msg.is_grp_name = "Ani#등록/NEW"

OpenWithParm(p1w_reg_new_ani_popup, iu_cust_msg)

end event

event ue_term();Integer	li_return
String ls_where, ls_anino, ls_fromdt
Long ll_row, ll_cnt

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

ls_anino = Trim(dw_cond.object.anino[1])

If IsNull(ls_anino) Then ls_anino = ""

If ls_anino = "" Then
	f_msg_info(200, Title, "Ani#")
	dw_cond.SetFocus()
	dw_cond.SetColumn("anino")
	Return
End If

//Ani#(Validkey) 선불카드 서비스인지..
//Ani#(validkey) 상태가 해지가능상태 인지... CHECK
iu_check = Create p1u_dbmgr1
iu_check.is_caller = "p1w_reg_ani_num%ue_term"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond  		
iu_check.is_data[1] = ls_anino  		//Ani#(validkey)

//SetPointer(HourGlass!)
iu_check.uf_prc_db_01()
//SetPointer(Arrow!)
If iu_check.ii_rc = -1 Then 
	Destroy iu_check
	Return
end If

ls_fromdt = iu_check.is_data[4]

Destroy iu_check

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "Ani# 등록"
iu_cust_msg.is_grp_name = "Ani# 등록/TERM"
iu_cust_msg.is_data[1] = ls_anino	     //ani#
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
iu_cust_msg.is_data[3] = ls_fromdt      //fromdt

OpenWithParm(p1w_reg_term_ani_popup, iu_cust_msg)

//Post Event ue_ok()
end event

event ue_change();Integer	li_return
String ls_where, ls_anino, ls_fromdt
Long ll_row, ll_cnt

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

ls_anino = Trim(dw_cond.object.anino[1])

If IsNull(ls_anino) Then ls_anino = ""

If ls_anino = "" Then
	f_msg_info(200, Title, "Ani#")
	dw_cond.SetFocus()
	dw_cond.SetColumn("anino")
	Return
End If

//Ani#(Validkey) 선불카드 서비스인지..
//Ani#(validkey) 사용여부 = 'Y' 일때만 변경가능... CHECK
iu_check = Create p1u_dbmgr1
iu_check.is_caller = "p1w_reg_ani_num%ue_change"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond  		
iu_check.is_data[1] = ls_anino  		//Ani#(validkey)

//SetPointer(HourGlass!)
iu_check.uf_prc_db_02()
//SetPointer(Arrow!)
If iu_check.ii_rc = -1 Then 
	Destroy iu_check
	Return
end If

ls_fromdt = iu_check.is_data[4]

Destroy iu_check

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "Ani# 등록"
iu_cust_msg.is_grp_name = "Ani# 등록/CHANGE"
iu_cust_msg.is_data[1] = ls_anino	     //ani#
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
iu_cust_msg.is_data[3] = ls_fromdt      //fromdt

OpenWithParm(p1w_reg_change_ani_popup, iu_cust_msg)

//Post Event ue_ok()
end event

public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt
Dec ldc_bilamt

//선불 서비스 Type
ls_svctype = fs_get_control("B1", "P211", ls_ref_desc)
li_cnt= fi_cut_string(ls_svctype, ";", ls_pre_svctype[])	
//후불 서비스 Type
ls_svctype = fs_get_control("B1", "P212", ls_ref_desc)
li_cnt_1= fi_cut_string(ls_svctype, ";", ls_post_svctype[])	
ll_insrow = 0


For i = 1 To li_cnt
	If as_svctype = ls_pre_svctype[i] Then
		ls_type = 'PRE_CDR'
		Exit;
   End If
Next

For i = 1 To li_cnt_1
	If as_svctype = ls_post_svctype[i] Then
		ls_type = 'POST_CDR'
		Exit;
   End If
Next



ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
ls_where = ""
If ls_validkey <> "" then
	ls_where = "WHERE validkey = '" + ls_validkey + "'"
End if

If ls_rtelnum <> "" then
	If ls_where <> "" Then
		ls_where += " And rtelnum = '" + ls_rtelnum + "'"
	Else
		ls_where = "Where rtelnum = '" + ls_rtelnum + "'"
	End if
End if

DECLARE cur_read_cdr_table DYNAMIC CURSOR FOR SQLSA;
DECLARE cur_read_cdr DYNAMIC CURSOR FOR SQLSA;

ls_sql = "SELECT tname " + &
			"FROM tab " + &
			"WHERE tabtype = 'TABLE' " + &
			" AND " + "tname >= '" + ls_type + as_workdt_fr + "' " + &
			" AND " + "tname <= '" + ls_type + as_workdt_to + "' "  + &
			" AND " + "substr(tname,1,7) = '" + LeftA(ls_type,7) + "'"  + &
			" ORDER BY tname DESC"
	
PREPARE SQLSA FROM :ls_sql;
OPEN DYNAMIC cur_read_cdr_table;

//DW 초기화
ll_rows = dw_detail.RowCount()
If ll_rows > 0 Then dw_detail.RowsDiscard(1, ll_rows, Primary!)
ll_rows = 0

Do While(True)
	FETCH cur_read_cdr_table
	INTO :ls_tname;

	If SQLCA.SQLCode < 0 Then
		clipboard(ls_sql)
		f_msg_sql_err(title, " cur_read_cdr_table")
		CLOSE cur_read_cdr_table;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If

		  
	//검색된 테이블에서 자료를 읽기
	ls_sql_1 = " SELECT STIME, ETIME, BILTIME, NODENO, RTELNUM, BILAMT, VALIDKEY, to_char(SEQNO), CRTDT, pid" + &
			    ", customerid FROM " + ls_tname + " " + &
				 + ls_where + &
			  " ORDER BY stime DESC "
			  

	PREPARE SQLSA FROM :ls_sql_1;
	OPEN DYNAMIC cur_read_cdr;

	Do While True
		FETCH cur_read_cdr
		INTO :ldt_stime,:ldt_etime, :ll_biltime, :ls_nodeno,
		     :ls_rtelnum, :ldc_bilamt, :ls_validkey, :ls_seqno,  :ldt_crtdt, :ls_pid, :ls_customerid;
		 
		If SQLCA.SQLCode < 0 Then
			clipboard(ls_sql)			
			f_msg_sql_err(title, "cur_read_cdr")
			CLOSE cur_read_cdr;
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
		End If

		ll_insrow = dw_detail.InsertRow(0)
		dw_detail.Object.SEQNO[ll_insrow] = ls_SEQNO   			
		dw_detail.Object.stime[ll_insrow] = ldt_stime
		dw_detail.Object.etime[ll_insrow] = ldt_etime
		dw_detail.Object.biltime[ll_insrow] = ll_biltime
		dw_detail.Object.sTELNUM[ll_insrow] = ls_nodeno
		dw_detail.Object.RTELNUM[ll_insrow] = ls_RTELNUM
		dw_detail.Object.bilamt[ll_insrow] = ldc_bilamt
		dw_detail.Object.validkey[ll_insrow] = ls_validkey
		dw_detail.Object.crtdt[ll_insrow] = ldt_crtdt
		dw_detail.Object.pid[ll_insrow] = ls_pid
		dw_detail.Object.customerid[ll_insrow] = ls_customerid
//		dw_detail.SetItemStatus(ll_insrow, 0, Primary!, NotModified!)
		ll_rows++
	Loop
	CLOSE cur_read_cdr ;
Loop
CLOSE cur_read_cdr_table;

If ll_insrow > 0 Then
	dw_detail.SetSort("STIME D")
	dw_detail.Sort()
End If

return 1
end function

on p1w_reg_ani_num.create
int iCurrent
call super::create
this.p_new=create p_new
this.p_change=create p_change
this.p_term=create p_term
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
this.Control[iCurrent+2]=this.p_change
this.Control[iCurrent+3]=this.p_term
end on

on p1w_reg_ani_num.destroy
call super::destroy
destroy(this.p_new)
destroy(this.p_change)
destroy(this.p_term)
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	p1w_reg_ani_num
	Desc.	:	Ani# 등록
	Ver	: 	1.0
	Date	: 	2003.08.22
	Prgromer : Park Kyung Hae(parkkh)
---------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp

//손모양 없애기
dw_detail.SetRowFocusIndicator(Off!)

//ani관리(pin필수여부;인증방법사용여부;인증방법;인증KEY개수)
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P001", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_ani_syscod[])   //ani관리 기본관리 셋팅코드

//인증방법사용여부의 사용여부에 따라 변경여부 적용
If is_ani_syscod[2] = 'Y' Then
	p_change.TriggerEvent("ue_enable")	
Else 
	p_change.TriggerEvent("ue_disable")	
End IF

end event

event ue_ok();call super::ue_ok;Long	ll_rows
String	ls_where
String	ls_anino, ls_pid, ls_ref_desc, ls_svctype

//입력 조건 처리 부분
ls_anino = Trim(dw_cond.Object.anino[1])
ls_pid = Trim(dw_cond.Object.pid[1])

//Error 처리부분
If IsNull(ls_anino) Then ls_anino = ""
If IsNull(ls_pid) Then ls_pid = ""

ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)	// 선불카드 서비스 타입

If ls_pid = "" and ls_anino = "" Then
	f_msg_usr_err(200, Title, "PIN# or ANI# 를 입력하세요.")
	dw_cond.SetColumn("pid")
	dw_cond.SetFocus()
	Return
End If

If ls_anino <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " validkey =  '" + ls_anino + "'"
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " pid = '" + ls_pid + "' "
End If

//선불카드 Type
If ls_where <> "" Then ls_where += " AND "
ls_where += " svctype = '" + ls_svctype + "' "

dw_detail.is_where = ls_where
//자료 읽기 및 관련 처리부분
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

type dw_cond from w_a_inq_m`dw_cond within p1w_reg_ani_num
integer x = 73
integer y = 44
integer width = 1079
integer height = 244
string dataobject = "p1dw_cnd_reg_ani_num"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "pid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.pid[row] =  &
			 dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.pid
This.is_help_win[1] = "p1w_hlp_p_cardmst"
This.is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_inq_m`p_ok within p1w_reg_ani_num
integer x = 1463
integer y = 52
end type

type p_close from w_a_inq_m`p_close within p1w_reg_ani_num
integer x = 1765
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within p1w_reg_ani_num
integer width = 1289
integer height = 308
end type

type dw_detail from w_a_inq_m`dw_detail within p1w_reg_ani_num
integer y = 328
integer width = 2345
integer height = 1380
string dataobject = "p1dw_inq_ani_num"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.pid_t
uf_init(ldwo_SORT)
end event

type p_new from u_p_new within p1w_reg_ani_num
integer x = 1463
integer y = 180
integer width = 283
integer height = 96
boolean bringtotop = true
end type

type p_change from u_p_change within p1w_reg_ani_num
integer x = 2066
integer y = 180
boolean bringtotop = true
end type

type p_term from u_p_term within p1w_reg_ani_num
integer x = 1765
integer y = 180
boolean bringtotop = true
boolean originalsize = false
end type

