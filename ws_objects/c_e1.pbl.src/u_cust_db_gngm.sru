$PBExportHeader$u_cust_db_gngm.sru
$PBExportComments$[kEnn] Another DB Connection
forward
global type u_cust_db_gngm from u_cust_a_db
end type
end forward

global type u_cust_db_gngm from u_cust_a_db
end type
global u_cust_db_gngm u_cust_db_gngm

type prototypes

end prototypes

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();ii_rc = -1

Choose Case is_caller
	Case "CONNECT"
		iSQLCA = Create Transaction
		ib_data[1] = False

		is_database = ProfileString(is_data[1], "database", "database", "x")
		If is_database = "x" Then
			f_msg_usr_err_app(600, "SQL Parm Error", "")
			Return
		End If

		Choose Case is_database
			Case "ORACLE", "ORACLE7"
				iSQLCA.DBMS			= ProfileString(is_data[1], "sqlca_oracle", "dbms", "x")
				iSQLCA.database	= ProfileString(is_data[1], "sqlca_oracle", "database", "x")
				iSQLCA.userid		= ProfileString(is_data[1], "sqlca_oracle", "userid", "x")
				iSQLCA.dbpass		= ProfileString(is_data[1], "sqlca_oracle", "dbpass", "x")
				iSQLCA.logid		= ProfileString(is_data[1], "sqlca_oracle", "logid", "x")
				iSQLCA.logpass		= ProfileString(is_data[1], "sqlca_oracle", "logpassword", "x")
				iSQLCA.servername	= ProfileString(is_data[1], "sqlca_oracle", "servername", "x")
				iSQLCA.dbparm		= ProfileString(is_data[1], "sqlca_oracle", "dbparm", "x")
				If iSQLCA.DBMS = "x" Or iSQLCA.database = "x" Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT USING iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "ORACLE8"
				iSQLCA.DBMS			= ProfileString(is_data[1], "sqlca_oracle8", "DBMS", "x")
				iSQLCA.LogPass		= ProfileString(is_data[1], "sqlca_oracle8", "LogPass", "x")
				iSQLCA.ServerName	= ProfileString(is_data[1], "sqlca_oracle8", "ServerName", "x")
				iSQLCA.LogId		= ProfileString(is_data[1], "sqlca_oracle8", "LogId", "x")
				If Upper(ProfileString(is_data[1], "sqlca_oracle8", "LogId", "x")) = "TRUE" Then
					iSQLCA.AutoCommit = True
				Else
					iSQLCA.AutoCommit = False
				End If
				iSQLCA.DBParm		= ProfileString(is_data[1], "sqlca_oracle8", "DBParm", "x")
				If iSQLCA.DBMS = "x" Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT USING iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "ACCESS"
				iSQLCA.DBMS			= ProfileString(is_data[1], "sqlca_access", "dbms", "x")
				iSQLCA.database	= ProfileString(is_data[1], "sqlca_access", "database", "x")
				iSQLCA.userid		= ProfileString(is_data[1], "sqlca_access", "userid", "x")
				iSQLCA.dbpass		= ProfileString(is_data[1], "sqlca_access", "dbpass", "x")
				iSQLCA.logid		= ProfileString(is_data[1], "sqlca_access", "logid", "x")
				iSQLCA.logpass		= ProfileString(is_data[1], "sqlca_access", "logpassword", "x")
				iSQLCA.servername	= ProfileString(is_data[1], "sqlca_access", "servername", "x")
				iSQLCA.dbparm		= ProfileString(is_data[1], "sqlca_access", "dbparm", "x")
				If iSQLCA.DBMS = "x" Or iSQLCA.database = "x" Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT USING iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case "SQLSERVER"
				iSQLCA.DBMS			= ProfileString(is_data[1], "sqlca_sqlserver", "dbms", "x")
				iSQLCA.database	= ProfileString(is_data[1], "sqlca_sqlserver", "database", "x")
				iSQLCA.userid		= ProfileString(is_data[1], "sqlca_sqlserver", "userid", "x")
				iSQLCA.dbpass		= ProfileString(is_data[1], "sqlca_sqlserver", "dbpass", "x")
				iSQLCA.logid		= ProfileString(is_data[1], "sqlca_sqlserver", "logid", "x")
				iSQLCA.logpass		= ProfileString(is_data[1], "sqlca_sqlserver", "logpassword", "x")
				iSQLCA.servername	= ProfileString(is_data[1], "sqlca_sqlserver", "servername", "x")
				iSQLCA.dbparm		= ProfileString(is_data[1], "sqlca_sqlserver", "dbparm", "x")
				If iSQLCA.DBMS = "x" Or iSQLCA.database = "x" Then
					f_msg_usr_err_app(600, "SQL Parm Error", "")
					Return
				End If
				CONNECT USING iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err("DB Connect Error", is_caller)
					Return
				End If
			Case Else
				f_msg_usr_err_app(600, "SQL Database Section Parm Error", "")
				Return
		End Choose

		ib_data[1] = True

	Case "DISCONNECT"
		DISCONNECT USING iSQLCA;
		If iSQLCA.SQLCode < 0 Then
			f_msg_sql_err("DB Disconnect Error" + "~r~n" + String(iSQLCA.SQLCode) + "~rn" + iSQLCA.SQLErrText, is_caller)
			Return
		End If

		Destroy(iSQLCA)

	Case "COMMIT"
		COMMIT USING iSQLCA;
		If iSQLCA.SQLCode < 0 Then
			f_msg_sql_err("DB Disconnect Error", is_caller)
			Return
		End If

	Case "ROLLBACK"
		ROLLBACK USING iSQLCA;
		If iSQLCA.SQLCode < 0 Then
			f_msg_sql_err("DB Disconnect Error", is_caller)
			Return
		End If

	Case "NOW"
		Choose Case is_database
			Case "ORACLE", "ORACLE7", "ORACLE8"
				SELECT DISTINCT SYSDATE, TO_CHAR(SYSDATE, 'yyyymmdd')
				INTO   :idt_data[1], :is_data[1]
				FROM   dual
				USING  iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If
         Case "ACCESS"
				SELECT DISTICT now(),  {fn curdate()}
				INTO   :idt_data[1], :is_data[1]
				FROM   sysusr1t
				USING  iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If 
			Case "SQLSERVER"
				SELECT DISTICT getdate(), convert(varchar,getdate(), 112)
				INTO   :idt_data[1], :is_data[1]
				FROM   sysusr1t
				USING  iSQLCA;
				If iSQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller)
					Return
				End If
		End Choose

	Case Else
		f_msg_info_app(9000, "u_cust_db_gngm.uf_prc_db()", "Matching statement Not found.(" + String(is_caller) + ")")
End Choose

ii_rc = 0

end subroutine

on u_cust_db_gngm.create
call super::create
end on

on u_cust_db_gngm.destroy
call super::destroy
end on

