$PBExportHeader$p1w_inq_cdryyyymmdd_1_v20.srw
$PBExportComments$[ssong] 고객관리/일자별통화내역
forward
global type p1w_inq_cdryyyymmdd_1_v20 from w_a_inq_m
end type
type dw_tmp from u_d_base within p1w_inq_cdryyyymmdd_1_v20
end type
type p_1 from u_p_saveas within p1w_inq_cdryyyymmdd_1_v20
end type
end forward

global type p1w_inq_cdryyyymmdd_1_v20 from w_a_inq_m
integer width = 3950
integer height = 1864
event ue_saveas ( )
dw_tmp dw_tmp
p_1 p_1
end type
global p1w_inq_cdryyyymmdd_1_v20 p1w_inq_cdryyyymmdd_1_v20

type variables
String is_format
Integer ii_cnt
end variables

forward prototypes
public function integer wf_cdr_inq_2 (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid)
public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid)
public function integer wf_cdr_inq_1 (string as_svctype, string as_workdt_fr, string as_customerid, string as_pid)
end prototypes

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
	
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

//저장을 못하거나 완료 하면 삭제한다.
//Delete curr_tmpcdr
//where emp_id = :gs_user_id
//and to_char(stime, 'yyyymmddhh24') >= :is_fromdt 
//and to_char(stime, 'yyyymmddhh24') <= :is_todt;
//
//If sqlca.sqlcode < 0 Then
//	f_msg_sql_err(title, "Delete curr_tmpcdr")				
//	Return 
//End If
//
//commit;
//

//p_1.TriggerEvent("ue_disable")




end event

public function integer wf_cdr_inq_2 (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_flag_group
String ls_format, ls_length_sql
STring ls_ws_sql, ls_ws_sql_1
String ls_svccode, ls_sacnum, ls_priceplan

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
      "     d.customernm, " + &
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
		"     a.flag, " + &
		"     c.flag_group, " + &
		"     a.sacnum, " + &
		"     a.pbxno, " + &
		"     a.priceplan, " + &
		"     a.itemcod, " + &
		"     a.rtelnum2, " + &
		"     a.stelnum2 "
		
ls_customerid = as_customerid
ls_pid = as_pid
ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
ls_stelnum = Trim(dw_cond.Object.stelnum[1])
ls_flag_group = Trim(dw_cond.Object.flag_group[1])
ls_svccode =  Trim(dw_cond.object.svccode[1])
ls_sacnum = Trim(dw_cond.object.sacnum[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
If Isnull(ls_stelnum) Then ls_stelnum = ""
If Isnull(ls_flag_group) Then ls_flag_group = ""
If Isnull(ls_svccode) Then ls_svccode = ""
If Isnull(ls_sacnum) Then ls_sacnum = ""
If Isnull(ls_priceplan) Then ls_priceplan = ""

//기본 Where 문
ls_where = " a.areacod = b.areacod(+) And a.customerid = d.customerid(+) And a.zoncod = z.zoncod(+) And a.svccod = s.svccod(+) And a.flag = c.flag"
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

If ls_stelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stelnum like '" + ls_stelnum + "%'"
End if

If ls_flag_group <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " c.flag_group = '" + ls_flag_group + "'"
End If

If ls_sacnum <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.sacnum = '" + ls_sacnum + "'"
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "'"
End If
	
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
	ls_sql_1 = ls_ws_sql + " FROM " + ls_tname + " a, areamst b, customerm d, zone z , svcmst s , cdrflag_info c Where " + &
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

public function integer wf_cdr_inq (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_flag_group
String ls_format
String ls_svccode, ls_pbxno, ls_itemcod, ls_stelnum2, ls_rtelnum2
String ls_result, ls_svcdesc, ls_sacnum, ls_priceplan

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
ls_stelnum = Trim(dw_cond.Object.stelnum[1])
ls_flag_group = Trim(dw_cond.Object.flag_group[1])
ls_svccode = Trim(dw_cond.object.svccode[1])
ls_sacnum = Trim(dw_cond.object.sacnum[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
If Isnull(ls_stelnum) Then ls_stelnum = ""
If Isnull(ls_flag_group) Then ls_flag_group = ""
If Isnull(ls_svccode) Then ls_svccode =""
If Isnull(ls_sacnum) Then ls_sacnum = ""
If Isnull(ls_priceplan) Then ls_priceplan = ""

//기본 Where 문
ls_where = " a.areacod = b.areacod(+) And a.zoncod = z.zoncod(+) And a.svccod = s.svccod(+) And a.flag = c.flag "
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

If ls_stelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stelnum like '" + ls_stelnum + "%'"
End if

If ls_flag_group <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " c.flag_group = '" + ls_flag_group + "'"
End If

If ls_sacnum <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.sacnum = '" + ls_sacnum + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "' "
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
	ls_sql_1 = " SELECT a.customerid, a.rtime, a.STIME, a.ETIME, a.BILTIME, a.Stelnum, a.RTELNUM, a.BILAMT, a.VALIDKEY, to_char(a.SEQNO), a.CRTDT, a.pid," + &
	            " a.nodeno, a.originnum, a.areacod, a.countrycod, a.zoncod, b.areanm, z.zonnm, a.result, s.svcdesc , c.flag_group, a.sacnum, a.pbxno, a.priceplan, a.itemcod, a.rtelnum2, a.stelnum2 " + &
			    " FROM " + ls_tname + " a, areamst b, zone z , svcmst s, cdrflag_info c  Where " + &
				 + ls_where + &
			  " ORDER BY a.stime DESC "
			  
   clipboard(ls_sql_1)			  
	PREPARE SQLSA FROM :ls_sql_1;
	OPEN DYNAMIC cur_read_cdr;

	Do While True
		FETCH cur_read_cdr
		INTO :ls_customerid, :ldt_rtime, :ldt_stime,:ldt_etime, :ll_biltime, :ls_stelnum,
		     :ls_rtelnum, :ldc_bilamt, :ls_validkey, :ls_seqno,  :ldt_crtdt, :ls_pid, :ls_nodeno,
			 :ls_originnum, :ls_areacod, :ls_countrycod, :ls_zoncod, :ls_areanm, :ls_zonnm, :ls_result, :ls_svcdesc, :ls_flag_group, :ls_sacnum, :ls_pbxno, :ls_priceplan, :ls_itemcod, :ls_rtelnum2, :ls_stelnum2;
		 
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
		dw_detail.Object.pbxno[ll_insrow] = ls_pbxno
		dw_detail.Object.itemcod[ll_insrow] = ls_itemcod
		dw_detail.Object.stelnum2[ll_insrow] = ls_stelnum2
		dw_detail.Object.rtelnum2[ll_insrow] = ls_rtelnum2
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
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_flag_group
String ls_format
String ls_table, ls_order_sql
String ls_svccode, ls_sacnum, ls_priceplan

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
		"     d.customernm, " + &
		"		a.rtime, " + &
		"		a.STIME, " + &
		"		a.ETIME, " + &
		"		a.BILTIME, " + &
		"		a.STELNUM, " + &
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
		"		a.flag," + &
		"     c.flag_group," + &
		"     a.sacnum," + &
		"     a.pbxno," + &
		"     a.priceplan," + &
		"     a.itemcod," + &
		"     a.rtelnum2," + &
		"     a.stelnum2" + &
		"	FROM " + ls_table + " a, areamst b, customerm d, zone z , svcmst s , cdrflag_info c" + &
		"  Where a.areacod = b.areacod(+) " + &
		"    And a.customerid = d.customerid(+) " + &
		"    And a.zoncod = z.zoncod(+) " + &
		"    And a.svccod = s.svccod(+) " + &
		"    And a.flag = c.flag "

ls_order_sql  = " ORDER BY a.rtime desc, a.customerid asc, a.pid asc "

ls_customerid = as_customerid
ls_pid = as_pid
ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
ls_stelnum = Trim(dw_cond.Object.stelnum[1])
ls_flag_group = Trim(dw_cond.Object.flag_group[1])
ls_svccode =  Trim(dw_cond.object.svccode[1])
ls_sacnum = Trim(dw_cond.object.sacnum[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
If Isnull(ls_stelnum) Then ls_stelnum = ""
If Isnull(ls_flag_group) Then ls_flag_group = ""
If Isnull(ls_svccode) Then ls_svccode = ""
If Isnull(ls_sacnum) Then ls_sacnum = ""
If Isnull(ls_priceplan) Then ls_priceplan = ""


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

If ls_stelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stelnum like '" + ls_stelnum + "%'"
End if

If ls_flag_group <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " c.flag_group = '" + ls_flag_group + "'"
End if

If ls_sacnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.sacnum = '" + ls_sacnum + "'"
End if

If ls_priceplan <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "'"
End if
	
ls_sql = ls_sql + ls_where + ls_order_sql

dw_detail.SetSqlSelect(ls_sql)

//조회
dw_detail.Retrieve()

return 1
end function

on p1w_inq_cdryyyymmdd_1_v20.create
int iCurrent
call super::create
this.dw_tmp=create dw_tmp
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_tmp
this.Control[iCurrent+2]=this.p_1
end on

on p1w_inq_cdryyyymmdd_1_v20.destroy
call super::destroy
destroy(this.dw_tmp)
destroy(this.p_1)
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b1w_inq_cdryyyymmdd
	Desc.	:	고객관리/일자별통화내역
	Ver	: 	1.0
	Date	: 	2002.11.15
	Prgromer : Park Kyung Hae(parkkh)
---------------------------------------------------------------------------*/
Date ld_sysdate
String ls_ref_desc

p_1.TriggerEvent("ue_disable")

//손모양 없애기
dw_detail.SetRowFocusIndicator(Off!)

ld_sysdate = Date(fdt_get_dbserver_now())
dw_cond.Object.workdt_fr[1] = ld_sysdate
//dw_cond.Object.workdt_to[1] = ld_sysdate

dw_cond.Object.workdt_to.visible = False
dw_cond.Object.t_1.visible = False

//일자별CDR 조회 금액 format 정의
is_format = fs_get_control("B1", "Z200" , ls_ref_desc)

end event

event ue_ok;call super::ue_ok;//조회
String ls_svctype, ls_workdt_fr, ls_workdt_to, ls_validkey, ls_stelnum, ls_rtelnum
String ls_pid, ls_customerid, ls_flag_group, ls_gu, ls_svccode, ls_sacnum, ls_priceplan


//필수입력사항 check
ls_svctype = Trim(dw_cond.object.svctype[1])
ls_workdt_fr = String(dw_cond.Object.workdt_fr[1], "yyyymmdd")
ls_workdt_to = String(dw_cond.Object.workdt_to[1], "yyyymmdd")
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_pid = Trim(dw_cond.object.pid[1])
ls_flag_group = Trim(dw_cond.object.flag_group[1])
ls_gu = Trim(dw_cond.object.gu[1])
ls_svccode = Trim(dw_cond.object.svccode[1])
ls_stelnum = Trim(dw_cond.object.stelnum[1])
ls_sacnum = Trim(dw_cond.object.sacnum[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])

If Isnull(ls_svctype) Then ls_svctype = ""				
If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
If Isnull(ls_workdt_to) Then ls_workdt_to = ""
If Isnull(ls_customerid) Then ls_customerid = ""
If Isnull(ls_pid) Then ls_pid = ""
If Isnull(ls_flag_group) Then ls_flag_group = ""
If Isnull(ls_gu) Then ls_gu = ""
If Isnull(ls_svccode) Then ls_svccode =""
If Isnull(ls_stelnum) Then ls_stelnum = ""
If Isnull(ls_sacnum) Then ls_sacnum = ""
If Isnull(ls_priceplan) Then ls_priceplan = ""

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

If ls_gu = 'Y' Then
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

End IF


p_1.TriggerEvent("ue_enable")

SetPointer(HourGlass!)
dw_detail.setredraw(False)

If ls_gu = 'Y' Then
	If wf_cdr_inq_2(ls_svctype, ls_workdt_fr, ls_workdt_to, ls_customerid, ls_pid) = -1 Then
		dw_detail.setredraw(True)
		SetPointer(Arrow!)
		return 
	End if
Else
	If wf_cdr_inq_1(ls_svctype, ls_workdt_fr, ls_customerid, ls_pid) = -1 Then
		dw_detail.setredraw(True)
		SetPointer(Arrow!)
		return 
	End if
End IF

If dw_detail.rowcount() = 0 Then
	f_msg_info(1000, Title, "")
End If

dw_detail.setredraw(True)
SetPointer(Arrow!)
end event

type dw_cond from w_a_inq_m`dw_cond within p1w_inq_cdryyyymmdd_1_v20
integer x = 59
integer y = 52
integer width = 2862
integer height = 384
string dataobject = "p1dw_cnd_inq_cdryyyymmdd_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name

	Case "customerid"
		
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 SELECT customernm
		 INTO :ls_customernm
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select 고객명")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
//				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_customernm
		 
	Case "gu"

         If Data = 'Y' Then
			dw_cond.Object.workdt_to.visible = True
			dw_cond.Object.t_1.visible = True
		 Else 
			dw_cond.Object.workdt_to.visible = False
			dw_cond.Object.t_1.visible = False
		End IF
		
End Choose

Return 0 
end event

type p_ok from w_a_inq_m`p_ok within p1w_inq_cdryyyymmdd_1_v20
integer x = 2967
integer y = 68
end type

type p_close from w_a_inq_m`p_close within p1w_inq_cdryyyymmdd_1_v20
integer x = 3561
integer y = 68
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within p1w_inq_cdryyyymmdd_1_v20
integer width = 2912
integer height = 456
end type

type dw_detail from w_a_inq_m`dw_detail within p1w_inq_cdryyyymmdd_1_v20
integer y = 480
integer width = 3849
integer height = 1244
string dataobject = "p1dw_inq_cdryyyymmdd_1_v20"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.rtime_t
//uf_init(ldwo_SORT)
uf_init(ldwo_sort,'D', RGB(0,0,128))
end event

type dw_tmp from u_d_base within p1w_inq_cdryyyymmdd_1_v20
boolean visible = false
integer x = 41
integer y = 1776
integer width = 3456
integer height = 248
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_inq_cdryyyymmdd_2_v20"
end type

type p_1 from u_p_saveas within p1w_inq_cdryyyymmdd_1_v20
integer x = 3264
integer y = 68
boolean bringtotop = true
end type

