$PBExportHeader$b5u_dbmgr3.sru
$PBExportComments$[jsha]
forward
global type b5u_dbmgr3 from u_cust_a_db
end type
end forward

global type b5u_dbmgr3 from u_cust_a_db
end type
global b5u_dbmgr3 b5u_dbmgr3

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Long ll_rows, ll_i
String ls_send_yn, ls_seq, ls_payid, ls_customernm, ls_email, ls_mailtype
Date ld_use_fromdt, ld_use_todt

Choose Case is_caller
	Case "b5w_reg_sendemail%send"
//		lu_dbmgr.is_caller = "b5w_reg_sendemail%send"
//		lu_dbmgr.is_title = This.Title
//		lu_dbmgr.is_data[1] = ls_bilcycle
//		lu_dbmgr.is_data[2] = ls_file_name
//		lu_dbmgr.is_data[3] = ls_sender
//		lu_dbmgr.is_data[4] = ls_result[1] 		// 미전송
//    lu_dbmgr.is_data[5] = ls_mailtype      // 메일타입
//    lu_dbmgr.is_data[6] = ls_table_option  // history or current
//		lu_dbmgr.id_data[1] = ld_trdt
//		lu_dbmgr.id_data[2] = ld_closedt
//		lu_dbmgr.id_data[3] = ld_send_date
//		lu_dbmgr.idw_data[1] = dw_detail

		ll_rows = idw_data[1].RowCount()
		For ll_i = 1 To ll_rows
			ls_send_yn = Trim(idw_data[1].Object.send_check[ll_i])
			If ls_send_yn = 'N' Then Continue
			
			//Sequence
			SELECT to_char(seq_emaildata.nextval)
			INTO :ls_seq
			FROM dual;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT seq_emaildata.nextval")
				RollBack;
				Return
			End If
			
			ls_payid = Trim(idw_data[1].Object.customerm_customerid[ll_i])
			ls_customernm = Trim(idw_data[1].Object.customerm_customernm[ll_i])			
			ls_email = Trim(idw_data[1].Object.bil_email[ll_i])
			//ld_use_fromdt = fd_pre_month(id_data[1], 1)
			ld_use_fromdt = id_data[1]
			//ld_use_todt = RelativeDate(id_data[1], -1)
			ld_use_todt = RelativeDate(fd_next_month(id_data[1],1),-1)
			
			// Insert   2006.02.20 juede modify  table_option add
			INSERT INTO emaildata(seq, mailtype,to_name, to_email, filenm, trdt, chargedt, use_fromdt, use_todt, 
										priority, mtitle, content, sender, reqdt, senddt, result, flag, closedt, table_option)
			VALUES (:ls_seq, :is_data[5], :ls_customernm, :ls_email, :is_data[2], :id_data[1], :is_data[1], :ld_use_fromdt, 
						:ld_use_todt, '0', :is_data[7], :ls_payid, :is_data[3], :id_data[3], :id_data[3], :is_data[4], 'N', :id_data[2], :is_data[6]);
						
			If SQLCA.SQLCode < 0 Then
				RollBack;
				f_msg_info(3010, is_title,"Send")
				ii_rc = -1
				Return
			End If	
						
		Next
		
		Commit;
		
End Choose
end subroutine

on b5u_dbmgr3.create
call super::create
end on

on b5u_dbmgr3.destroy
call super::destroy
end on

