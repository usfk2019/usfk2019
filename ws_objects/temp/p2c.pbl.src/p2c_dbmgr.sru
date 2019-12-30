$PBExportHeader$p2c_dbmgr.sru
$PBExportComments$[y.k.min]
forward
global type p2c_dbmgr from u_cust_a_db
end type
end forward

global type p2c_dbmgr from u_cust_a_db
end type
global p2c_dbmgr p2c_dbmgr

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db ();String ls_fromdt, ls_todt, ls_ref_desc, ls_temp, ls_name[]
integer li_count, i
Long ll_cnt, ll_totcnt
Date ld_fromdt
ii_rc = -1
ll_totcnt = 0
Choose Case is_caller
	Case "p2w_prc_pre_item_cancle"
     ld_fromdt = idw_data[1].object.fromdt[1]
	  ls_fromdt = String(ld_fromdt, 'yyyymmdd')
	  ls_todt = String(idw_data[1].object.todt[1], 'yyyymmdd')
	  
	  //선불 Svctype 가져오기
	  ls_temp = fs_get_control("B1", "P211", ls_ref_desc)
	  li_count=fi_cut_string(ls_temp, ";", ls_name[])		
	  
	  //해당 하는 기간에 자료 삭제
	  For i = 1 To li_count
		Select nvl(count(*),0) into :ll_cnt from itemsale
		                where to_char(sale_month, 'yyyymmdd') >= :ls_fromdt
		                and to_char(sale_month, 'yyyymmdd') <= :ls_todt
							 and svctype = :ls_name[i];
		             
		Delete itemsale where to_char(sale_month, 'yyyymmdd') >= :ls_fromdt
		                and to_char(sale_month, 'yyyymmdd') <= :ls_todt
							 and svctype = :ls_name[i];
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(Itemsale)")
			Rollback;
			Return 
		End If
		ll_totcnt += ll_cnt
	Next
	
   ls_temp = String(fd_date_pre(ld_fromdt,1), 'yyyymmdd')

	//sysclt Upate
	Update  sysctl1t   
	Set     ref_content =  :ls_temp
	Where   module = 'S1' And ref_no = 'S103';

	If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(sysctl1t)")
			Rollback;
			Return 
		End If
	Commit;
End Choose
il_data[1] = ll_totcnt
ii_rc = 0 
end subroutine

public subroutine uf_prc_db_01 ();Integer li_count
DateTime ld_rtime
Long ll_call, ll_row, ll_count
String ls_validkey, ls_pid, ls_rtelnum, ls_errcode, ls_inid, ls_outid, ls_where
String ls_sql, ls_tablename
ii_rc = -1
Choose Case is_caller
	Case "p2w_prt_incomplete_cdr"
//		lu_dbmgr.is_caller = "p2w_prt_incomplete_cdr"
//	lu_dbmgr.is_data[1] = ls_yyyymmdd
//	lu_dbmgr.is_data[2] = ls_tm_fr
//	lu_dbmgr.is_data[3] = ls_tm_to
//	lu_dbmgr.is_data[4] = ls_rtelnum
//	lu_dbmgr.is_data[5] = ls_errcode
//lu_dbmgr.is_data[6] = ls_svctype
//조회하기 위해서 커서를 사용

il_data[1] = 0
//1. 테이블 찾기
Select count(tname)
Into :li_count
from tab where tabtype = 'TABLE'
and tname = 'PRE_CDR' || :is_data[1] ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_title, " Select Tab Error")
   Return 
End If

If li_count = 0 Then
	f_msg_info(1000, is_title , "")
	ii_rc = 0 
	Return
End If

ls_where = ""
If is_data[2] <> "" and is_data[3] <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(rtime, 'hh24mi') >= '" + is_data[2] + "' And to_char(rtime, 'hh24mi') <= '" + is_data[3] + "' "
End If

If is_data[4] <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "rtelnum like '" + is_data[4] + "%' "
End If

If is_data[5] <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "result ='" + is_data[5] + "' "
End If

ls_tablename = 'PRE_CDR' + is_data[1]
//2.자료를 읽으면서 Insert

ls_sql += " select rtime, validkey, pid, ( round((etime-rtime) * 24 * 60 * 60, 1)) call,"  + &
       "rtelnum, result, inid, outid " + &
		 "from " + ls_tablename + &
       " where svctype = '" + is_data[6] + "' " + " and flag = '9' And " +  ls_where + &
       "order by rtime, validkey, pid"

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_Title, "CURSOR cur_cdr")
	Return
End If


idw_data[1].Reset()
idw_data[1].SetSqlSelect(ls_sql)

//조회
il_data[1]= idw_data[1].Retrieve()  
 
End Choose
ii_rc = 0

end subroutine

on p2c_dbmgr.create
call super::create
end on

on p2c_dbmgr.destroy
call super::destroy
end on

