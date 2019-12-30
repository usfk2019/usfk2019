$PBExportHeader$b5u_dbmgr8.sru
$PBExportComments$[jsha]
forward
global type b5u_dbmgr8 from u_cust_a_db
end type
end forward

global type b5u_dbmgr8 from u_cust_a_db
end type
global b5u_dbmgr8 b5u_dbmgr8

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Long ll_rows, ll_i
String ls_payid , ls_paydt  , ls_trcod, ls_transdt
String ls_pgm_id, ls_user_id, ls_remark, ls_paycod
Long   ll_rc    , ll_seq
Dec    ld_payamt

Choose Case is_caller
	Case "Insert Reqpay prepay Kilt"

			//lu_dbmgr.is_data[1] = ls_payid
			//lu_dbmgr.is_data[2] = ls_paycod
			//lu_dbmgr.is_data[3] = ls_trcod
			//lu_dbmgr.is_data[4] = ls_paydt
			//lu_dbmgr.is_data[5] = ls_remark
			//lu_dbmgr.ic_data[6] = ld_payamt
			//lu_dbmgr.is_data[7] = ls_transdt
			ls_payid = is_data[1]
			ls_paycod = is_data[2]
			ls_trcod = is_data[3]
			ls_paydt = is_data[4]
			ls_remark = is_data[5]
			ld_payamt = ic_data[6]
			ls_transdt = is_data[7]
			
			

			//수동 입금 반영 Table Insert
			Insert Into reqpay (seqno,payid, paytype, trcod, paydt,
									  remark, prc_yn, payamt, transdt,
									  crt_user, crtdt,updt_user, updtdt, pgm_id)
			values ( seq_reqpay.nextval, :ls_payid, :ls_paycod, :ls_trcod, to_date(:ls_paydt, 'yyyy-mm-dd'),
						:ls_remark, 'N', :ld_payamt, to_date(:ls_transdt, 'yyyy-mm-dd'),
						:gs_user_id, sysdate, :gs_user_id, sysdate, :gs_pgm_id[1] );

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "Insert Error(REQPAY)")
				Return
			End If	

End Choose
end subroutine

on b5u_dbmgr8.create
call super::create
end on

on b5u_dbmgr8.destroy
call super::destroy
end on

