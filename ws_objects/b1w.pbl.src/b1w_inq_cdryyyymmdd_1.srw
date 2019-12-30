$PBExportHeader$b1w_inq_cdryyyymmdd_1.srw
$PBExportComments$[parkkh] 고객관리/일자별통화내역(svctype 추가 안된것)
forward
global type b1w_inq_cdryyyymmdd_1 from w_a_inq_m
end type
end forward

global type b1w_inq_cdryyyymmdd_1 from w_a_inq_m
integer width = 3323
integer height = 1824
end type
global b1w_inq_cdryyyymmdd_1 b1w_inq_cdryyyymmdd_1

forward prototypes
public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid)
end prototypes

public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
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

ls_customerid = as_customerid
ls_pid = as_pid
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

If ls_customerid <> "" Then
	If ls_where <> "" Then 
	  ls_where += " And customerid = '" + ls_customerid + "'"
   Else
	  ls_where += "Where customerid = '" + ls_customerid + "'"
	End If
End If

If ls_pid <> "" Then
	If ls_where <> "" Then 
	  ls_where += " And pid = '" + ls_pid + "'"
   Else
	  ls_where += "Where pid = '" + ls_pid + "'"
	End If
End If

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

on b1w_inq_cdryyyymmdd_1.create
call super::create
end on

on b1w_inq_cdryyyymmdd_1.destroy
call super::destroy
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b1w_inq_cdryyyymmdd
	Desc.	:	고객관리/일자별통화내역
	Ver	: 	1.0
	Date	: 	2002.11.15
	Prgromer : Park Kyung Hae(parkkh)
---------------------------------------------------------------------------*/
Date ld_sysdate

ld_sysdate = Date(fdt_get_dbserver_now())
dw_cond.Object.workdt_fr[1] = ld_sysdate
dw_cond.Object.workdt_to[1] = ld_sysdate

//손모양 없애기
dw_detail.SetRowFocusIndicator(Off!)
end event

event ue_ok();call super::ue_ok;//조회
String ls_svctype, ls_workdt_fr, ls_workdt_to, ls_validkey, ls_rtelnum
String ls_customerid, ls_pid

//필수입력사항 check
ls_svctype = Trim(dw_cond.object.svctype[1])
ls_workdt_fr = String(dw_cond.Object.workdt_fr[1], "yyyymmdd")
ls_workdt_to = String(dw_cond.Object.workdt_to[1], "yyyymmdd")
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_pid = Trim(dw_cond.object.pid[1])
If Isnull(ls_svctype) Then ls_svctype = ""				
If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
If Isnull(ls_workdt_to) Then ls_workdt_to = ""		
If Isnull(ls_customerid) Then ls_customerid = ""
If Isnull(ls_pid) Then ls_pid = ""			

If ls_svctype = "" Then
	f_msg_info(200, Title, "서비스구분")
	dw_cond.SetFocus()
	dw_cond.setColumn("svctype")
	Return 
End If
		
//***** 사용자 입력사항 검증 *****
If ls_workdt_fr = "" Then
	f_msg_info(200, Title, "일자(From)")
	dw_cond.setfocus()
	dw_cond.SetColumn("workdt_fr")
	Return
End If

If ls_workdt_to = "" Then
	f_msg_info(200, Title, "일자(To)")
	dw_cond.setfocus()
	dw_cond.SetColumn("workdt_to")
	Return
End If

If ls_workdt_to <> "" Then
	If ls_workdt_fr <> "" Then
		If ls_workdt_fr > ls_workdt_to Then
			f_msg_info(200, Title, "일자(From) <= 일자(To)")
			Return
		End If
	End If
End If

dw_detail.setredraw(False)

//If wf_cdr_inq(ls_svctype, ls_workdt_fr, ls_workdt_to) = -1 Then
//	return 
//End if

If dw_detail.rowcount() = 0 Then
	f_msg_info(1000, Title, "")
End If

dw_detail.setredraw(True)
end event

type dw_cond from w_a_inq_m`dw_cond within b1w_inq_cdryyyymmdd_1
integer y = 52
integer width = 2418
integer height = 264
string dataobject = "b1dw_cnd_inq_cdryyyymmdd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within b1w_inq_cdryyyymmdd_1
integer x = 2560
integer y = 44
end type

type p_close from w_a_inq_m`p_close within b1w_inq_cdryyyymmdd_1
integer x = 2862
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_inq_cdryyyymmdd_1
integer width = 2459
integer height = 340
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_inq_cdryyyymmdd_1
integer y = 364
integer width = 3223
integer height = 1332
string dataobject = "b1dw_inq_cdryyyymmdd"
boolean ib_sort_use = false
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.customerid_t
uf_init(ldwo_SORT)
end event

