$PBExportHeader$c0u_dbmgr.sru
$PBExportComments$[ceusee] DB 접속
forward
global type c0u_dbmgr from u_cust_a_db
end type
end forward

global type c0u_dbmgr from u_cust_a_db
end type
global c0u_dbmgr c0u_dbmgr

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();Integer li_cnt
ii_rc = -1
Choose Case is_caller
	Case "w_mdi_main%timer_term"
//	lu_dbmgr.is_caller = "w_mdi_main%timer"
//	lu_dbmgr.is_data[1] = is_reqactive
//	lu_dbmgr.is_data[2] = is_reqterm

		//개통신청이 있는지
		Select count(*)
		Into :li_cnt
		From svcorder
		Where status = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, " Select Error(SVCCORDER)")
			Return
		End If
		
		If li_cnt = 0 Then
			ii_rc = 1
		   Return
		End IF
	
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db ();Integer li_cnt, li_pos, i, li_row
String  ls_status, ls_ref_desc, ls_name[], ls_status1
ii_rc = -1
Choose Case is_caller
	Case "w_mdi_main%timer_active"
//		lu_dbmgr.is_caller = "w_mdi_main%timer_active"
//		lu_dbmgr.is_data[1] = is_beep_status

		Select count(*)
		Into :li_cnt
		From svcorder
		Where status = :is_data[1];
		
		If SQLCA.SQLCode < 0  Then
			f_msg_sql_err(is_caller, " Select Error(SVCCORDER)")
			Return
		End If
			If li_cnt = 0 Then
			ii_rc = 1
		   Return
		End IF
	
End Choose

ii_rc = 0

Return 
end subroutine

on c0u_dbmgr.create
call super::create
end on

on c0u_dbmgr.destroy
call super::destroy
end on

