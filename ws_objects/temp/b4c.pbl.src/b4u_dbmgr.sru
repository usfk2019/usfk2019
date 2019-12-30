$PBExportHeader$b4u_dbmgr.sru
$PBExportComments$[juede]
forward
global type b4u_dbmgr from u_cust_a_db
end type
end forward

global type b4u_dbmgr from u_cust_a_db
event uf_prc_db_04 ( )
end type
global b4u_dbmgr b4u_dbmgr

type variables

end variables

forward prototypes
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db_01 ();Long ll_cnt=0 , ll_used_qty = 0, ll_move_qty = 0
String ls_adj_type
Dec lc_adj_amt, lc_use_amt

ii_rc = -1


//iu_db.is_data[1] = ls_payid      //대리점
//iu_db.is_data[2] = ls_svccod		//가격정책
//iu_db.is_data[3] = ls_adj_type		//유형
//iu_db.is_data[4] = ls_note	   	//비고
//iu_db.is_data[5] = gs_user_id
//iu_db.is_data[6] = gs_pgm_id[gi_open_win_no]
//iu_db.ic_data[1] = lc_adj_amt		   //할당금액

ls_adj_type =  is_data[3]
lc_adj_amt  =  ic_data[1]

If ls_adj_type = 'M' Then
	lc_adj_amt = lc_adj_amt * -1
ElseIf ls_adj_type ='C' Then
	lc_adj_amt = 0
End If

INSERT INTO CUSTOMER_USEDAMT_ADJ (				
				SEQ,
				PAYID,
				SVCCOD,
				ADJ_TYPE,
				ADJ_AMT,
				NOTE,
				CRTDT,
				CRT_USER,
				PGM_ID)
		VALUES(
				seq_customer_usedamt_adj.nextval,
				:is_data[1],
				:is_data[2],
				:is_data[3],
				:lc_adj_amt,
				:is_data[4],
				sysdate,
				:is_data[5],
				:is_data[6]);
				
If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " Insert Error(CUSTOMER_USEDAMT_ADJ)" )
	Return
End if
	
		
If ls_adj_type ='C' Then	
	UPDATE CUSTOMER_DEPOSIT
	SET	 USE_AMT = USE_AMT * :lc_adj_amt,
			 updt_user = :is_data[5],
			 updtdt = sysdate
	WHERE	 PAYID = :is_data[1]
	And    SVCCOD = :is_data[2];
Else
	UPDATE CUSTOMER_DEPOSIT
	SET	 USE_AMT = USE_AMT + :lc_adj_amt,
			 updt_user = :is_data[5],
			 updtdt = sysdate
	WHERE	 PAYID = :is_data[1]
	And    SVCCOD = :is_data[2];	
End If

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " update Error(CUSTOMER_DEPOSIT)" )
	Return
End if
	
		

	
ii_rc = 0

end subroutine

on b4u_dbmgr.create
call super::create
end on

on b4u_dbmgr.destroy
call super::destroy
end on

