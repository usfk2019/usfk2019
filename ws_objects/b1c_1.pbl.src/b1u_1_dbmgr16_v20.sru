$PBExportHeader$b1u_1_dbmgr16_v20.sru
forward
global type b1u_1_dbmgr16_v20 from u_cust_a_db
end type
end forward

global type b1u_1_dbmgr16_v20 from u_cust_a_db
end type
global b1u_1_dbmgr16_v20 b1u_1_dbmgr16_v20

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();
ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_contractupload_err_v20%ue_request"
		// Data Move
		Insert Into contractupload_req
		 (
	   			file_code,  filename, filerownum, workno, validkey, fromdt, todt,
					bil_fromdt, bil_todt, svccod, svctype, priceplan, customernm,
					ssno, cregno, corpno, corpnm, representative, businesstype,
					businessitem, zipcod, addr1, addr2, phone1, phone2, faxno, bil_email,
					bil_zipcod, bil_addr1, bil_addr2, creditreqdt, card_type, card_no,
					card_expdt, card_holder, card_ssno, card_remark1, card_group1,
					bank, acctno, acct_owner, acct_ssno,
					crt_user, crtdt, pgm_id
		)
		(
			select file_code, filename, filerownum, null, validkey, fromdt, todt,
					bil_fromdt, bil_todt, svccod, svctype, priceplan, customernm,
					ssno, cregno, corpno, corpnm, representative, businesstype,
					businessitem, zipcod, addr1, addr2, phone1, phone2, faxno, bil_email,
					bil_zipcod, bil_addr1, bil_addr2, creditreqdt, card_type, card_no,
					card_expdt, card_holder, card_ssno, card_remark1, card_group1,
					bank, acctno, acct_owner, acct_ssno,
					crt_user, crtdt, pgm_id
			from	contractupload_err
			where	file_code = :is_data[1]
			and	filename = :is_data[2]);
		
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_Title, "Insert Error(contractupload_req)")
			Return
		End If
		
		DELETE FROM contractupload_err
		WHERE file_code = :is_data[1]
		AND	filename = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_Title, "DELETE Error(contractupload_err)")
			Return
		End If
		
		// Fileupload_worklog update
		Update fileupload_worklog
		SET	status = :is_data[3]
		WHERE	seqno = :il_data[1];
		
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_Title, "Update Error(contractupload_worklog)")
			Return
		End If
		
		ii_rc = 0
End Choose

Commit;
Return
end subroutine

on b1u_1_dbmgr16_v20.create
call super::create
end on

on b1u_1_dbmgr16_v20.destroy
call super::destroy
end on

