$PBExportHeader$u_cust_db_app.sru
$PBExportComments$Application/common용
forward
global type u_cust_db_app from u_cust_a_db
end type
end forward

global type u_cust_db_app from u_cust_a_db
end type
global u_cust_db_app u_cust_db_app

type prototypes

end prototypes

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_temp
Long ll_i

ii_rc = -1

Choose Case is_caller
	/*******************************************************************************/
	Case "CONNECT"
		Choose Case is_data[1]
			Case "ORACLE", "ORACLE7"
				SQLCA.DBMS       = ProfileString(is_data[2],"sqlca_oracle","dbms","x")
				SQLCA.database   = ProfileString(is_data[2],"sqlca_oracle","database","x")
				SQLCA.userid     = ProfileString(is_data[2],"sqlca_oracle","userid","x")
				SQLCA.dbpass     = ProfileString(is_data[2],"sqlca_oracle","dbpass","x")
				SQLCA.logid      = ProfileString(is_data[2],"sqlca_oracle","logid","x")
				SQLCA.logpass    = fs_hex2char(ProfileString(is_data[2],"sqlca_oracle","logpassword","x"))
				SQLCA.servername = ProfileString(is_data[2],"sqlca_oracle","servername","x")
				SQLCA.dbparm	  = ProfileString(is_data[2],"sqlca_oracle","dbparm","x")
				If SQLCA.DBMS = 'x' OR SQLCA.database = 'x' Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "ORACLE8"
				SQLCA.DBMS       = ProfileString(is_data[2],"sqlca_oracle8","DBMS","x")
				SQLCA.LogPass    = fs_hex2char(ProfileString(is_data[2],"sqlca_oracle8","LogPass","x"))
				SQLCA.ServerName = ProfileString(is_data[2],"sqlca_oracle8","ServerName","x")
				SQLCA.LogId      = ProfileString(is_data[2],"sqlca_oracle8","LogId","x")
				If Upper(ProfileString(is_data[2],"sqlca_oracle8","LogId","x")) = "TRUE" Then
					SQLCA.AutoCommit = True
				Else
					SQLCA.AutoCommit = False
				End If
				SQLCA.DBParm	  = ProfileString(is_data[2],"sqlca_oracle8","DBParm","x")
				If SQLCA.DBMS = 'x' Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "ORACLE10"
				SQLCA.DBMS       = ProfileString(is_data[2],"sqlca_oracle10","DBMS","x")
				SQLCA.LogPass    = fs_hex2char(ProfileString(is_data[2],"sqlca_oracle10","LogPass","x"))
				SQLCA.ServerName = ProfileString(is_data[2],"sqlca_oracle10","ServerName","x")
				SQLCA.LogId      = ProfileString(is_data[2],"sqlca_oracle10","LogId","x")
				If Upper(ProfileString(is_data[2],"sqlca_oracle10","LogId","x")) = "TRUE" Then
					SQLCA.AutoCommit = True
				Else
					SQLCA.AutoCommit = False
				End If
				SQLCA.DBParm	  = ProfileString(is_data[2],"sqlca_oracle10","DBParm","x")
				If SQLCA.DBMS = 'x' Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "ACCESS"
				SQLCA.DBMS       = ProfileString(is_data[2],"sqlca_access","dbms","x")
				SQLCA.database   = ProfileString(is_data[2],"sqlca_access","database","x")
				SQLCA.userid     = ProfileString(is_data[2],"sqlca_access","userid","x")
				SQLCA.dbpass     = ProfileString(is_data[2],"sqlca_access","dbpass","x")
				SQLCA.logid      = ProfileString(is_data[2],"sqlca_access","logid","x")
				SQLCA.logpass    = fs_hex2char(ProfileString(is_data[2],"sqlca_access","logpassword","x"))
				SQLCA.servername = ProfileString(is_data[2],"sqlca_access","servername","x")
				SQLCA.dbparm	  = ProfileString(is_data[2],"sqlca_access","dbparm","x")
				If SQLCA.DBMS = 'x' OR SQLCA.database = 'x' Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "SQLSERVER"
				SQLCA.DBMS       = ProfileString(is_data[2],"sqlca_sqlserver","dbms","x")
				SQLCA.database   = ProfileString(is_data[2],"sqlca_sqlserver","database","x")
				SQLCA.userid     = ProfileString(is_data[2],"sqlca_sqlserver","userid","x")
				SQLCA.dbpass     = ProfileString(is_data[2],"sqlca_sqlserver","dbpass","x")
				SQLCA.logid      = ProfileString(is_data[2],"sqlca_sqlserver","logid","x")
				SQLCA.logpass    = fs_hex2char(ProfileString(is_data[2],"sqlca_sqlserver","logpassword","x"))
				SQLCA.servername = ProfileString(is_data[2],"sqlca_sqlserver","servername","x")
				SQLCA.dbparm	  = ProfileString(is_data[2],"sqlca_sqlserver","dbparm","x")
				If SQLCA.DBMS = 'x' OR SQLCA.database = 'x' Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case Else
				f_msg_usr_err_app(600, "SQL Database Section Parm Error", "")
				Return
		End Choose
		
	/*******************************************************************************/
	
	Case "DISCONNECT"
		DISCONNECT;
		If SQLCA.SQLCode < 0 Then
			//f_msg_sql_err("DB Disconnect Error", is_caller)
			MessageBox("DB Disconnect Error", String(SQLCA.SQLCode) + " : " + SQLCA.SQLErrText)
			Return
		End If

	/*******************************************************************************/
	
	Case "COMMIT"
		COMMIT;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err("DB Disconnect Error", is_caller)
			Return
		End If

	/*******************************************************************************/
	
	Case "ROLLBACK"
		ROLLBACK;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err("DB Disconnect Error", is_caller)
			Return
		End If

	/*******************************************************************************/
	
	Case "NOW"   
		Choose Case gs_database
			Case "ORACLE", "ORACLE7", "ORACLE8", "ORACLE10"
				SELECT distinct sysdate, to_char( sysdate, 'YYYYMMDD' )
				INTO :idt_data[1], :is_data[1]
				FROM dual ;

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If
         Case "ACCESS"
//				SELECT distinct  now(),  {fn curdate()}  
//				INTO :idt_data[1], :is_data[1]
//				FROM sysusr1t ;	

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If 
			Case "SQLSERVER"
//				SELECT distinct getdate(), convert( varchar,getdate(), 112 )
//				INTO :idt_data[1], :is_data[1]
//				FROM sysusr1t ;	

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If
		End Choose

	/*******************************************************************************/
	
	Case "GET_COMPANY_NAME"
		Choose Case gs_database
			Case "ORACLE", "ORACLE7", "ORACLE8", "ORACLE10"
				SELECT REF_CONTENT
				INTO :is_data[1]
				FROM SYSCTL1T
				WHERE MODULE = '00'
				AND REF_NO = 'S101' ;

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If
		End Choose
   
	/*******************************************************************************/
	
	Case "Get User's Authority"
		SELECT emp_id, emp_group, emp_auth
		INTO :ls_temp, :gs_user_group, :gi_auth
		FROM sysusr1t
		WHERE emp_id = :is_data[1]
		 And password = :is_data[2];

		If SQLCA.SQLCode = 100 Then
			is_rc = "NOTHING"
		ElseIf SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		Else
			is_rc = "SOMETHING"
		End If

	/*******************************************************************************/
	
	Case "New User Password Update"
		
		UPDATE sysusr1t
		SET password = :is_data[2],
			 upd_dt = sysdate		
		WHERE emp_id = :is_data[1];

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If
		
	/*******************************************************************************/
	
	Case "Record Login-Time"
		UPDATE sysusr1t
		SET login_dt = :idt_data[1]
		WHERE emp_id = :is_data[1];

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If
		
		INSERT INTO SYSUSR_LOG
			( EMP_ID, SEQ, GUBUN, LOG_STATUS, TIMESTAMP,
			  CRT_USER, CRTDT, PGM_ID )
		VALUES
		   ( :is_data[1], SEQ_SYSUSR.NEXTVAL, 'LOG', '400', :idt_data[1],
			  :is_data[1], SYSDATE, 'LOGIN' );

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If			  
		

	/*******************************************************************************/
	
	Case "Read Logout & Login-Time"
		SELECT login_dt, logout_dt
		INTO :idt_data[1], :idt_data[2]
		FROM sysusr1t
		WHERE emp_id = :is_data[1];

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If
	
	/*******************************************************************************/
	
	Case "Record Logout-Time"
		UPDATE sysusr1t
		SET logout_dt = :idt_data[1]
		WHERE emp_id = :is_data[1];

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If
		
		INSERT INTO SYSUSR_LOG
			( EMP_ID, SEQ, GUBUN, LOG_STATUS, TIMESTAMP,
			  CRT_USER, CRTDT, PGM_ID )
		VALUES
		   ( :is_data[1], SEQ_SYSUSR.NEXTVAL, 'LOG', '500', :idt_data[1],
			  :is_data[1], SYSDATE, 'LOGOUT' );

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If			  		

	/*******************************************************************************/
	
	Case "Read User's Information"
//		SELECT dept, costct
//		INTO :gs_dept, :gs_costct
//		FROM permas1t
//		WHERE emp_id = :is_data[1];
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller)
//			Return
//		End If
//
//		If SQLCA.SQLCode = 100 Then
//			gs_access_i_dept[1] = Char(1)
//		End If
//

		//***** Dept(Internal Dept) Secutrity 관련 정보 읽기 *****
		//** 접속가능한 기준부서 갯수
//		SELECT Count(emp_id) + 1
//		INTO :gi_access_i_dept_no
//		FROM sysusr4t
//		WHERE emp_id = :is_data[1];
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller)
//			Return
//		End If
//
//		gs_access_i_dept[gi_access_i_dept_no] = ""
//
//		//** 접속가능한 기준부서코드
//		//자신 부서
//		SELECT i_dept
//		INTO :gs_access_i_dept[1]
//		FROM orgdep1t
//		WHERE dept = :gs_dept;
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller)
//			Return
//		End If
//
//		//추가 부서
//		DECLARE cur_read_int_dept CURSOR FOR
//		SELECT i_dept
//		FROM sysusr4t
//		WHERE emp_id = :is_data[1];
//
//		OPEN cur_read_int_dept;
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller)
//			Return
//		End If
//
//		ll_i = 2
//		Do While(True)
//			FETCH cur_read_int_dept
//			INTO :gs_access_i_dept[ll_i];
//
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(is_title, is_caller)
//				Return
//			End If
//
//			If SQLCA.SQLCode <> 0 Then Exit
//
//			SQLCA.SQLCode = 0
//			ll_i ++
//		Loop

	/*******************************************************************************/
	
	Case "fs_get_control()"
		SELECT ref_desc, ref_content
		INTO :is_data[3], :is_data[4]
		FROM sysctl1t
		WHERE module = :is_data[1]
		 And ref_no = :is_data[2];

		If SQLCA.SQLCode = 100 Then
			ii_rc = 100
			Return
		ElseIf SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If
	
	Case "fi_set_control()"
		UPDATE SYSCTL1T 
		SET ref_content = :is_data[3]
		WHERE module = :is_data[1] AND ref_no = :is_data[2];
		If SQLCA.SQLCode = 100 Then
			ii_rc = 100
			Return
		ElseIf SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If

	/*******************************************************************************/
	
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")

End Choose

ii_rc = 0

end subroutine

on u_cust_db_app.create
call super::create
end on

on u_cust_db_app.destroy
call super::destroy
end on

