$PBExportHeader$b1w_inq_cdr_v20.srw
$PBExportComments$[jwlee] CDR상세조회
forward
global type b1w_inq_cdr_v20 from w_a_inq_m
end type
type dw_tmp from u_d_base within b1w_inq_cdr_v20
end type
type p_1 from u_p_saveas within b1w_inq_cdr_v20
end type
type p_2 from u_p_reset within b1w_inq_cdr_v20
end type
end forward

global type b1w_inq_cdr_v20 from w_a_inq_m
integer width = 3950
integer height = 1844
event ue_saveas ( )
event ue_reset ( )
dw_tmp dw_tmp
p_1 p_1
p_2 p_2
end type
global b1w_inq_cdr_v20 b1w_inq_cdr_v20

type variables
String is_format
Integer ii_cnt
end variables

forward prototypes
public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid)
public function integer wf_cdr_inq_1 (string as_svctype, string as_workdt_fr, string as_customerid, string as_pid)
public function integer wf_cdr_inq_2 (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid)
end prototypes

event ue_saveas();
f_excel_ascii1(dw_detail,'b1dw_inq_mst_cdr')

//Boolean lb_return
//Integer li_return
//String ls_curdir
//u_api lu_api
//
//If dw_detail.RowCount() <= 0 Then
//	f_msg_info(1000, This.Title, "Data exporting")
//	Return
//End If
//
//lu_api = Create u_api
//ls_curdir = lu_api.uf_getcurrentdirectorya()
//If IsNull(ls_curdir) Or ls_curdir = "" Then
//	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
//	Destroy lu_api
//	Return
//End If
//
//li_return = dw_detail.SaveAs("", Excel!, True)
//
//lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
//If li_return <> 1 Then
//	f_msg_info(9000, This.Title, "User cancel current job.")
//	
//Else
//	f_msg_info(9000, This.Title, "Data export finished.")
//End If
//
//Destroy lu_api
//
////저장을 못하거나 완료 하면 삭제한다.
////Delete curr_tmpcdr
////where emp_id = :gs_user_id
////and to_char(stime, 'yyyymmddhh24') >= :is_fromdt 
////and to_char(stime, 'yyyymmddhh24') <= :is_todt;
////
////If sqlca.sqlcode < 0 Then
////	f_msg_sql_err(title, "Delete curr_tmpcdr")				
////	Return 
////End If
////
////commit;
////
//
////p_1.TriggerEvent("ue_disable")

end event

event ue_reset();

dw_cond.reset()
dw_cond.insertrow(1)

dw_detail.reset()


dw_detail.reset()
end event

public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_finish_flag
String ls_format
String ls_svccode
String ls_result, ls_svcdesc

//선불 서비스 Type
ls_svctype = fs_get_control("B1", "P211", ls_ref_desc)
li_cnt= fi_cut_string(ls_svctype, ";", ls_pre_svctype[])	
//후불 서비스 Type
ls_svctype = fs_get_control("B1", "P212", ls_ref_desc)
li_cnt_1= fi_cut_string(ls_svctype, ";", ls_post_svctype[])	
ll_insrow = 0

ls_format = "##0"
For i = 1 To integer(is_format)
   If i = 1 Then ls_format += "."
   ls_format += "0"
Next

dw_detail.Modify("bilamt.Format = '" + ls_format + "'")

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
ls_finish_flag = Trim(dw_cond.Object.finish_flag[1])
If Isnull(ls_finish_flag) Then ls_finish_flag = ""
ls_svccode = Trim(dw_cond.object.svccode[1])
If Isnull(ls_svccode) Then ls_svccode =""

//기본 Where 문
ls_where = " a.areacod = b.areacod(+) And a.zoncod = z.zoncod(+) And a.svccod = s.svccod(+) "
If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.validkey = '" + ls_validkey + "'"
End if

If as_svctype <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svctype = '" + as_svctype+ "'"
End if

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.customerid = '" + ls_customerid + "'"

End If

If ls_svccode <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod ='" + ls_svccode + "'"
End if

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pid = '" + ls_pid + "'"
End If

If ls_rtelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.rtelnum like '" + ls_rtelnum + "%'"
End if

If ls_finish_flag = 'A' Then
ElseIf ls_finish_flag = '9' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag = '9'"
ElseIf ls_finish_flag = '1' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag <> '9' "
End IF	
	
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
	ls_sql_1 = " SELECT a.customerid, a.rtime, a.STIME, a.ETIME, a.BILTIME, a.Stelnum, a.RTELNUM, a.BILAMT, a.VALIDKEY, to_char(a.SEQNO), a.CRTDT, a.pid," + &
	            " a.nodeno, a.originnum, a.areacod, a.countrycod, a.zoncod, b.areanm, z.zonnm, a.result, s.svcdesc " + &
			    " FROM " + ls_tname + " a, areamst b, zone z , svcmst s  Where " + &
				 + ls_where + &
			  " ORDER BY a.stime DESC "
			  
   clipboard(ls_sql_1)			  
	PREPARE SQLSA FROM :ls_sql_1;
	OPEN DYNAMIC cur_read_cdr;

	Do While True
		FETCH cur_read_cdr
		INTO :ls_customerid, :ldt_rtime, :ldt_stime,:ldt_etime, :ll_biltime, :ls_stelnum,
		     :ls_rtelnum, :ldc_bilamt, :ls_validkey, :ls_seqno,  :ldt_crtdt, :ls_pid, :ls_nodeno,
			 :ls_originnum, :ls_areacod, :ls_countrycod, :ls_zoncod, :ls_areanm, :ls_zonnm, :ls_result, :ls_svcdesc;
		 
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
		dw_detail.Object.customerid[ll_insrow] = ls_customerid
		dw_detail.Object.rtime[ll_insrow] = ldt_rtime
		dw_detail.Object.stime[ll_insrow] = ldt_stime
		dw_detail.Object.etime[ll_insrow] = ldt_etime
		dw_detail.Object.biltime[ll_insrow] = ll_biltime
		dw_detail.Object.sTELNUM[ll_insrow] = ls_stelnum
		dw_detail.Object.RTELNUM[ll_insrow] = ls_RTELNUM
		dw_detail.Object.bilamt[ll_insrow] = ldc_bilamt
		dw_detail.Object.validkey[ll_insrow] = ls_validkey
		dw_detail.Object.crtdt[ll_insrow] = ldt_crtdt
		dw_detail.Object.pid[ll_insrow] = ls_pid

     	dw_detail.Object.originnum[ll_insrow] = ls_originnum
		dw_detail.Object.nodeno[ll_insrow] = ls_nodeno
		dw_detail.Object.areacod[ll_insrow] = ls_areacod
		dw_detail.Object.countrycod[ll_insrow] = ls_countrycod
		dw_detail.Object.zoncod[ll_insrow] = ls_zoncod
		dw_detail.Object.areanm[ll_insrow] = ls_areanm
		dw_detail.Object.zonnm[ll_insrow] = ls_zonnm
//		dw_detail.SetItemStatus(ll_insrow, 0, Primary!, NotModified!)

		ll_rows++
	Loop
	CLOSE cur_read_cdr ;
Loop
CLOSE cur_read_cdr_table;

If ll_insrow > 0 Then
	dw_detail.SetSort("rtime D, customerid A, pid A, STIME D")
	dw_detail.Sort()
End If

return 1
end function

public function integer wf_cdr_inq_1 (string as_svctype, string as_workdt_fr, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_finish_flag
String ls_format
String ls_table, ls_order_sql
String ls_svccode

//선불 서비스 Type
ls_svctype = fs_get_control("B1", "P211", ls_ref_desc)
li_cnt= fi_cut_string(ls_svctype, ";", ls_pre_svctype[])	
//후불 서비스 Type
ls_svctype = fs_get_control("B1", "P212", ls_ref_desc)
li_cnt_1= fi_cut_string(ls_svctype, ";", ls_post_svctype[])	
ll_insrow = 0

ls_format = "##0"
For i = 1 To integer(is_format)
   If i = 1 Then ls_format += "."
   ls_format += "0"
Next
dw_detail.Modify("bilamt.Format = '" + ls_format + "'")

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

ls_table = ls_type + as_workdt_fr
ls_sql = " SELECT a.customerid, " + &
		"		a.rtime, " + &
		"		a.STIME, " + &
		"		a.ETIME, " + &
		"		a.BILTIME, " + &
		"		a.Stelnum, " + &
		"		a.RTELNUM, " + &
		"		a.BILAMT,  " + &
		"		a.VALIDKEY,  " + &
		"		to_char(a.SEQNO),  " + &
		"		a.CRTDT,  " + &
		"		a.pid, " + &
		"		a.nodeno,  " + &
		"		a.originnum,  " + &
		"		a.areacod,  " + &
		"		a.countrycod,  " + &
		"		a.zoncod,  " + &
		"		b.areanm,  " + &
		"		z.zonnm, " + &
		"     a.result," + &
		"		s.svcdesc," + &
		"		a.inid," + &
		"		a.outid," + &
		"		a.flag" + &
		"	FROM " + ls_table + " a, areamst b, zone z , svcmst s" + &
		"  Where a.areacod = b.areacod(+) " + &
		"    And a.zoncod = z.zoncod(+) " + &
		"    And a.svccod = s.svccod(+) "

ls_order_sql  = " ORDER BY a.rtime desc, a.customerid asc, a.pid asc "

ls_customerid = as_customerid
ls_pid = as_pid
ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
ls_finish_flag = Trim(dw_cond.Object.finish_flag[1])
If Isnull(ls_finish_flag) Then ls_finish_flag = ""
ls_svccode =  Trim(dw_cond.object.svccode[1])
If Isnull(ls_svccode) Then ls_svccode = ""


//기본 Where 문
ls_where = " "
If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.validkey = '" + ls_validkey + "'"
End if

If as_svctype <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svctype = '" + as_svctype+ "'"
End if

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.customerid = '" + ls_customerid + "'"

End If

If ls_svccode <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccode + "'"
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pid = '" + ls_pid + "'"
End If

If ls_rtelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.rtelnum like '" + ls_rtelnum + "%'"
End if

If ls_finish_flag = 'A' Then
ElseIf ls_finish_flag = '9' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag = '9'"
ElseIf ls_finish_flag = '1' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag <> '9' and a.flag <> '8'"
ElseIf ls_finish_flag = '8' Then	
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag = '8' "
End IF	
	
ls_sql = ls_sql + ls_where + ls_order_sql

dw_detail.SetSqlSelect(ls_sql)

//조회
dw_detail.Retrieve()

return 1
end function

public function integer wf_cdr_inq_2 (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_finish_flag
String ls_format, ls_length_sql
STring ls_ws_sql, ls_ws_sql_1
String ls_svccode

//선불 서비스 Type
ls_svctype = fs_get_control("B1", "P211", ls_ref_desc)
li_cnt= fi_cut_string(ls_svctype, ";", ls_pre_svctype[])	
//후불 서비스 Type
ls_svctype = fs_get_control("B1", "P212", ls_ref_desc)
li_cnt_1= fi_cut_string(ls_svctype, ";", ls_post_svctype[])	
ll_insrow = 0

ls_format = "##0"
For i = 1 To integer(is_format)
   If i = 1 Then ls_format += "."
   ls_format += "0"
Next
dw_detail.Modify("bilamt.Format = '" + ls_format + "'")

For i = 1 To li_cnt
	If as_svctype = ls_pre_svctype[i] Then
		ls_type = 'PRE_CDR'
		ls_length_sql = 'LENGTH(TNAME) = 15 '
		Exit;
   End If
Next

For i = 1 To li_cnt_1
	If as_svctype = ls_post_svctype[i] Then
		ls_type = 'POST_CDR'
		ls_length_sql = 'LENGTH(TNAME) = 16 '		
		Exit;
   End If
Next

ls_ws_sql = " SELECT a.customerid, " + &
		"		a.rtime, " + &
		"		a.STIME, " + &
		"		a.ETIME, " + &
		"		a.BILTIME, " + &
		"		a.Stelnum, " + &
		"		a.RTELNUM, " + &
		"		a.BILAMT,  " + &
		"		a.VALIDKEY,  " + &
		"		to_char(a.SEQNO),  " + &
		"		a.CRTDT,  " + &
		"		a.pid, " + &
		"		a.nodeno,  " + &
		"		a.originnum,  " + &
		"		a.areacod,  " + &
		"		a.countrycod,  " + &
		"		a.zoncod,  " + &
		"		b.areanm,  " + &
		"		z.zonnm, "  + &
		"     a.result, " + &
		"     s.svcdesc, " + &
		"     a.inid, " + &
		"     a.outid, " + &
		"     a.flag "
		
ls_customerid = as_customerid
ls_pid = as_pid
ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
ls_finish_flag = Trim(dw_cond.Object.finish_flag[1])
If Isnull(ls_finish_flag) Then ls_finish_flag = ""
ls_svccode =  Trim(dw_cond.object.svccode[1])
If Isnull(ls_svccode) Then ls_svccode = ""

//기본 Where 문
ls_where = " a.areacod = b.areacod(+) And a.zoncod = z.zoncod(+) And a.svccod = s.svccod(+) "
If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.validkey = '" + ls_validkey + "'"
End if

If as_svctype <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svctype = '" + as_svctype+ "'"
End if

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.customerid = '" + ls_customerid + "'"

End If

If ls_svccode <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccode + "'"
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pid = '" + ls_pid + "'"
End If

If ls_rtelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.rtelnum like '" + ls_rtelnum + "%'"
End if

If ls_finish_flag = 'A' Then
ElseIf ls_finish_flag = '9' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag = '9'"
ElseIf ls_finish_flag = '1' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag <> '9' and a.flag <> '8' "
ElseIf ls_finish_flag = '8' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.flag = '8' "
End IF	
	
DECLARE cur_read_cdr_table DYNAMIC CURSOR FOR SQLSA;
DECLARE cur_read_cdr DYNAMIC CURSOR FOR SQLSA;

ls_sql = "SELECT tname " + &
			"FROM tab " + &
			"WHERE tabtype = 'TABLE' " + &
			" AND " + "tname >= '" + ls_type + as_workdt_fr + "' " + &
			" AND " + "tname <= '" + ls_type + as_workdt_to + "' "  + &
			" AND " + "substr(tname,1,7) = '" + LeftA(ls_type,7) + "'"  + &
			" AND " + ls_length_sql + &
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
	ls_sql_1 = ls_ws_sql + " FROM " + ls_tname + " a, areamst b, zone z , svcmst s Where " + &
				 + ls_where + &
			  " ORDER BY a.rtime DESC, a.customerid asc, a.pid asc "
	
	dw_tmp.SetSqlSelect(ls_sql_1)
	
	//조회
	ll_rows = dw_tmp.Retrieve()
	If ll_rows > 0 Then
		//복사한다.
		dw_tmp.RowsCopy(1,dw_tmp.RowCount(), &
										Primary!,dw_detail ,1, Primary!)
	End If    
Loop
CLOSE cur_read_cdr_table;

If dw_detail.rowcount() > 0 Then
	dw_detail.SetSort(" a.rtime D, a.customerid A, a.pid A, a.STIME D")
	dw_detail.Sort()
End If

return 1
end function

on b1w_inq_cdr_v20.create
int iCurrent
call super::create
this.dw_tmp=create dw_tmp
this.p_1=create p_1
this.p_2=create p_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_tmp
this.Control[iCurrent+2]=this.p_1
this.Control[iCurrent+3]=this.p_2
end on

on b1w_inq_cdr_v20.destroy
call super::destroy
destroy(this.dw_tmp)
destroy(this.p_1)
destroy(this.p_2)
end on

event open;call super::open;/*--------------------------------------------------------------------
	Name	:	b1w_inq_cdr
	Desc	:	CDR상세조회
	Ver.	: 	1.0
	Date	: 	2006.02.09
	Programer : jwlee(이진원)
--------------------------------------------------------------------*/
dw_cond.SetFocus()
dw_cond.SetColumn(1)


end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_fromdt, ls_todt, ls_starttime, ls_endtime, ls_srcno, ls_callere164, &
         ls_callerh323id, ls_dstno, ls_inport, ls_outport

dw_cond.Accepttext()

ls_fromdt		 = Trim(dw_cond.Object.fromdt[1])
ls_todt			 = Trim(dw_cond.Object.todt[1])
ls_starttime	 = Trim(dw_cond.object.starttime[1])
ls_endtime		 = Trim(dw_cond.object.endtime[1])
ls_srcno			 = Trim(dw_cond.Object.srcno[1])
ls_callere164	 = Trim(dw_cond.object.callere164[1])
ls_callerh323id = Trim(dw_cond.object.callerh323id[1])
ls_dstno			 = Trim(dw_cond.Object.dstno[1])
ls_inport		 = Trim(dw_cond.Object.inport[1])
ls_outport		 = Trim(dw_cond.Object.outport[1])

If LenA(ls_starttime) = 8 Then
	ls_starttime = ls_starttime+'000000'
	dw_cond.object.starttime[1] = ls_starttime
End If

If LenA(ls_endtime) = 8 Then
	ls_endtime = ls_endtime+'240000'
	dw_cond.object.endtime[1] = ls_endtime
End If
	
If( IsNull(ls_fromdt) )       Then ls_fromdt       = ""
If( IsNull(ls_todt) )         Then ls_todt         = ""
If( IsNull(ls_starttime) )    Then ls_starttime    = ""
If( IsNull(ls_endtime) )      Then ls_endtime      = ""
If( IsNull(ls_srcno) )        Then ls_srcno        = ""
If( IsNull(ls_callere164) )   Then ls_callere164   = ""
If( IsNull(ls_callerh323id) ) Then ls_callerh323id = ""
If( IsNull(ls_dstno) )        Then ls_dstno        = ""
If( IsNull(ls_inport) )       Then ls_inport       = ""
If( IsNull(ls_outport) )      Then ls_outport      = ""

IF ls_fromdt <> "" AND ls_todt = "" THEN
	ls_todt = ls_fromdt
	dw_cond.object.todt[1] = ls_fromdt
END IF

IF ls_starttime <> "" AND ls_endtime = "" THEN
	Messagebox('확인','통화시작시간을 입력하시면 종료시간은 필수항목입니다.')
	dw_cond.SetFocus()
	dw_cond.SetColumn('endtime')
	Return
END IF

//Dynamic SQL

ls_where = ""
If( ls_fromdt <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "YYYYMMDD >= '"+ ls_fromdt +"'"
End If

If( ls_todt <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "YYYYMMDD <= '"+ ls_todt +"'"
End If

If( ls_starttime <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "starttime >= '"+ ls_starttime +"'"
End If

If( ls_endtime <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "endtime <= '"+ ls_endtime +"'"
End If

If( ls_srcno <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "srcno like '"+ ls_srcno + "%' "
End If

If( ls_callere164 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "callere164 like '"+ ls_callere164 + "%' "
End If

If( ls_callerh323id <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "callerh323id like '"+ ls_callerh323id + "%' "
End If

If( ls_dstno <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "dstno like '"+ ls_dstno + "%' "
End If

If( ls_inport <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "inport like '"+ ls_inport + "%' "
End If

If( ls_outport <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "outport like '"+ ls_outport + "%' "
End If

dw_detail.is_where	= ls_where

//Retrieve
ll_rows	= dw_detail.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

type dw_cond from w_a_inq_m`dw_cond within b1w_inq_cdr_v20
integer x = 59
integer y = 52
integer width = 2578
integer height = 316
string dataobject = "b1dw_cnd_cdr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;dw_cond.Accepttext()
Choose Case Dwo.Name
	Case "starttime"
		If LenA(data) = 8 Then
			dw_cond.Object.starttime[1] = data+'000000'
			return
		End If
	Case "endtime"
		If LenA(data) = 8 Then
			dw_cond.Object.endtime[1] = data+'240000'
			return
		End If
End Choose

end event

type p_ok from w_a_inq_m`p_ok within b1w_inq_cdr_v20
integer x = 2949
integer y = 44
end type

type p_close from w_a_inq_m`p_close within b1w_inq_cdr_v20
integer x = 3278
integer y = 192
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_inq_cdr_v20
integer width = 2638
integer height = 384
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_inq_cdr_v20
integer y = 404
integer width = 3849
integer height = 1320
string dataobject = "b1dw_inq_mst_cdr"
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.seqno_t
//uf_init(ldwo_SORT)
uf_init(ldwo_sort,'A', RGB(0,0,128))
end event

event dw_detail::rowfocuschanged;call super::rowfocuschanged;Long ll_row
ll_row = this.GetRow()
if ll_row < 1 then return
this.SelectRow (0, false)			// Turn off previous highlight
this.SelectRow (ll_row, true)		// Highlight current row


end event

type dw_tmp from u_d_base within b1w_inq_cdr_v20
boolean visible = false
integer x = 41
integer y = 1776
integer width = 3456
integer height = 248
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_inq_cdryyyymmdd"
end type

type p_1 from u_p_saveas within b1w_inq_cdr_v20
integer x = 2949
integer y = 192
boolean bringtotop = true
boolean originalsize = false
end type

type p_2 from u_p_reset within b1w_inq_cdr_v20
integer x = 3278
integer y = 44
boolean bringtotop = true
boolean originalsize = false
end type

