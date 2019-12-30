$PBExportHeader$p0c_dbmgr2.sru
$PBExportComments$[jsha] 반품카드 수정/조회
forward
global type p0c_dbmgr2 from u_cust_a_db
end type
end forward

global type p0c_dbmgr2 from u_cust_a_db
end type
global p0c_dbmgr2 p0c_dbmgr2

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db ();Long ll_row, ll_cnt, ll_returnseq
String ls_pid
String ls_temp, ls_ref_desc, ls_result[]

ii_rc = -1

Choose Case is_caller
	Case "p0w_reg_return_up%delete"
		//lu_dbmgr.idw_data[1] = dw_detail
		ll_row = idw_data[1].GetRow()
		ls_pid  = idw_data[1].object.p_cardmst_pid[ll_row]
		ll_returnseq = idw_data[1].object.p_cardreturn_returnseq[ll_row]
		
		Select count(*) 
		Into :ll_cnt
		From p_cardreturn Where pid = :ls_pid
		AND returnseq <> :ll_returnseq;
				
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, " Select Error(P_CARDRETURN)")
			Return
		End If		
				
		//카드 상태
		ls_ref_desc = ""
		ls_temp = fs_get_control("P0", "P101", ls_ref_desc)
      fi_cut_string(ls_temp, ";" , ls_result[])
		
		//Update
		If ll_cnt = 0 Then
			Update p_cardmst set status = :ls_result[3], sale_flag = '0',
			       updtdt = sysdate, updt_user = :gs_user_id, pgm_id = :gs_pgm_id[1]
			Where pid = :ls_pid;
		End If
     
  	   If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "Update Error(P_CARDMST)")
			RollBack;
			Return
		End If		
		
End Choose

ii_rc = 0 

end subroutine

public subroutine uf_prc_db_01 ();String ls_where
Long ll_row, ll_count, ll_srow, i
String ls_return_type, ls_remark, ls_pid, ls_contno , ls_partner_prefix
String ls_sale_flag, ls_partner, ls_priceplan, ls_model
String ls_opendt
Integer li_return, li_ret, li_rc
Dec{4} lc_balance
Dec{2} lc_sale_amt, lc_rate

ii_rc = -1
ll_srow = 0

Do While(True)
	
	ll_srow = idw_data[1].getSelectedRow(ll_srow)
	If ll_srow = 0 Then Exit
	
	ls_pid = idw_data[1].Object.pid[ll_srow]
	If IsNull(ls_pid) Then ls_pid = ""
		
	//반품카드 상태
	idw_data[1].Object.status[ll_srow] =  is_data[5]
	idw_data[1].Object.sale_flag[ll_srow] = is_data[4]
	idw_data[1].Object.remark[ll_srow] = is_data[2]
	lc_balance = idw_data[1].Object.balance[ll_srow]
	ls_contno = idw_data[1].Object.contno[ll_srow]
	ls_priceplan = idw_data[1].Object.priceplan[ll_srow]
	ls_opendt = String(idw_data[1].Object.opendt[ll_srow], 'YYYYMMDD')
	ls_partner_prefix =  idw_data[1].Object.partner_prefix[ll_srow]
	idw_data[1].Object.pgm_id[ll_srow]  = gs_pgm_id[1]
	idw_data[1].Object.updtdt[ll_srow]  = fdt_get_dbserver_now();
	idw_data[1].Object.last_refill_amt[ll_srow]  = lc_balance * -1
	
	Select partner
	Into :ls_partner
	From partnermst
	Where prefixno = :ls_partner_prefix;
	
	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(is_data[7],  " Insert Error(PARTNERMST)" )
		Return 
	End If
	
	lc_rate = fdc_refill_rate(ls_partner, ls_priceplan, ls_opendt, lc_balance)
			
	If lc_rate < -1 Then
		f_msg_usr_err(2100, is_data[7], " Select Error(REFILLPOLICY)")
		Return 
	End If
	
	lc_sale_amt = lc_balance * (lc_rate /100)
	
	//반품 정보 Insert
	Insert Into p_cardreturn 
			( returnseq, pid, returndt, return_type, remark, 
			  crt_user, crtdt, pgm_id, updtdt, updt_user,balance, partner_prefix)
	Values 
		  ( seq_cardreturn.Nextval, :ls_pid, to_date(:is_data[3],'yyyymmdd'), :is_data[1], :is_data[2], 
			:is_data[8], sysdate, :gs_pgm_id[gi_open_win_no], sysdate, :is_data[8], :lc_balance, :ls_partner_prefix);
	
	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(is_data[7],  " Insert Error(P_CARDRETURN)" )
		Return 
	End If
	
	SELECT pricemodel
	INTO :ls_model
	FROM p_cardmst
	WHERE pid = :ls_pid;
	
	//충전 이력 Insert
	Insert Into P_REFILLLOG
		( REFILLSEQ, pid, refilldt, contno, REFILL_TYPE, 
		  refill_amt, sale_amt , remark, eday, partner_prefix, crtdt, crt_user,
		  pricemodel, priceplan)
	Values 
		( SEQ_REFILLLOG.nextval, :ls_pid, to_date(:is_data[3],'yyyymmdd'), :ls_contno, :is_data[6],
		(:lc_balance * -1 ), :lc_sale_amt, :is_data[2], null, :ls_partner_prefix, sysdate, :is_data[8],
		:ls_model, :ls_priceplan);
		
	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(is_data[7],  " Insert Error(P_REFILLLOG)" )
		Return 
	End If
Loop	

	
ii_rc = 0
Return
end subroutine

on p0c_dbmgr2.create
call super::create
end on

on p0c_dbmgr2.destroy
call super::destroy
end on

