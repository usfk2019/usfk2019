$PBExportHeader$p1c_dbmgr.sru
$PBExportComments$[y.k.min]
forward
global type p1c_dbmgr from u_cust_a_db
end type
end forward

global type p1c_dbmgr from u_cust_a_db
end type
global p1c_dbmgr p1c_dbmgr

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();String ls_pricemodle, ls_pid, ls_from_pid, ls_contno, ls_from_contno
String ls_tmp, ls_card_status[], ls_ref_desc, ls_refilltype, ls_refilltype_1
String ls_priceplan,ls_partner_prefix
Dec  ldc_balance, ldc_from_balance, ldc_refillsum_amt
Date ld_enddt, ld_next_enddt
Integer  li_extdays
ii_rc = -1

Choose Case is_caller
	Case "p1w_reg_pintopin%save"
//		lu_dbmgr.is_caller = "p1w_reg_pintopin%save"
//		lu_dbmgr.is_title  = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.is_data[1] = ls_from_pricemodel
//lu_dbmgr.is_data[2] = ls_from_partner_prefix
//lu_dbmgr.is_data[3] = ls_from_priceplan
		
		ls_pid = Trim(idw_data[1].object.pid[1])
		ls_from_pid = Trim(idw_data[1].object.from_pin[1])
		ls_pricemodle = Trim(idw_data[1].object.pricemodel[1])
		ls_contno = Trim(idw_data[1].object.contno[1])
		ls_from_contno = Trim(idw_data[1].object.from_contno[1])
		ls_priceplan = Trim(idw_data[1].object.priceplan[1])
		ls_partner_prefix = Trim(idw_data[1].object.partner_prefix[1])
		ld_enddt = Date(idw_data[1].object.enddt[1])   //유효기간
		ldc_balance = idw_data[1].object.balance[1]
		ldc_refillsum_amt = idw_data[1].object.refillsum_amt[1] //충전누적금액
		ldc_from_balance = idw_data[1].object.from_balance[1]  //충전하려는 Pin의 잔액
		
		//카드 상태
		ls_tmp =fs_get_control("P0", "P101", ls_ref_desc)
		fi_cut_string(ls_tmp, ";", ls_card_status[])
		
		//충전 이력 구분
		ls_refilltype=fs_get_control("P0", "P109", ls_ref_desc)
		ls_refilltype_1 = fs_get_control("P0", "P110", ls_ref_desc)
		
		
		
	
		//연장일수 구하기
		Select to_number(extdays)
		Into :li_extdays
		From salepricemodel
		where pricemodel = :ls_pricemodle;
		
		
		If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(is_title, " Select Error(salepricemodle)")
			Return
		End If
		
		
		//충전 하기 To Pin
	   Insert Into p_refilllog (refillseq, pid, contno, refilldt, refill_type,
		                         refill_amt, sale_amt, remark, eday, crtdt, crt_user,
										 priceplan, pricemodel, partner_prefix)
		values(seq_refilllog.nextval, :ls_pid, :ls_contno, sysdate, :ls_refilltype,
		      :ldc_from_balance, 0, 'From Pin = ' || :ls_from_pid, :li_extdays, sysdate, :gs_user_id,
				:ls_priceplan, :ls_pricemodle, :ls_partner_prefix);
				
		
		If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(is_title, " Insert Error 1(p_refilllog)")
			Return
		End If
		
		
		Insert Into p_refilllog (refillseq, pid, contno, refilldt, refill_type,
		                         refill_amt, sale_amt, remark, crtdt, crt_user,
										  priceplan, pricemodel, partner_prefix)
		values(seq_refilllog.nextval, :ls_from_pid, :ls_from_contno, sysdate, :ls_refilltype_1,
		      (:ldc_from_balance * -1), 0, 'To Pin = ' || :ls_pid, sysdate, :gs_user_id,
				:is_data[3], :is_data[1], :is_data[2]);
	  
		If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(is_title, " Insert Error 2(p_refilllog)")
			Return
		End If
		
		//From Pin Update
		Update p_cardmst set status = :ls_card_status[5], balance = 0
		where pid = :ls_from_pid;
		
		If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(is_title, " Update Error (p_cardmst)")
			Return
		End If
		
		If IsNull(ld_enddt) Then ld_enddt = Date(fdt_get_dbserver_now())
		
		ld_next_enddt = fd_date_next(ld_enddt, li_extdays)
		idw_data[1].object.enddt[1] = DateTime(ld_next_enddt)     //유효간 연장
		
		
		//카드 상태 사용으로 변경
		idw_data[1].object.status[1] = ls_card_status[3]
		idw_data[1].object.balance[1] = ldc_balance + ldc_from_balance
		idw_data[1].object.refillsum_amt[1] = ldc_refillsum_amt + ldc_from_balance
		idw_data[1].object.last_refill_amt[1] = ldc_from_balance
		idw_data[1].object.last_refilldt[1] = Date(fdt_get_dbserver_now())
		idw_data[1].object.pgm_id[1] = gs_pgm_id[gi_open_win_no]
		idw_data[1].object.updt_user[1] = gs_user_id
		idw_data[1].object.updtdt[1] = Date(fdt_get_dbserver_now())
		
		idw_data[1].object.from_balance[1] = 0
		
	
	End Choose

ii_rc = 0 
end subroutine

public subroutine uf_prc_db ();Long ll_count, ll_srow
String ls_extdays, ls_contno, ls_ref_desc, ls_pid, ls_partner_prefix
String ls_model, ls_priceplan, ls_refilldt, ls_enddt
Date ld_enddt, ld_refilldt
Int li_return
Dec{2} lc_balance

ii_rc = -1
ll_srow = 0

//ls_eday = fs_get_control('P0', 'P110', ls_ref_desc)
//If ls_eday = "" Then Return
		
Do While(True)
	
	ll_srow = idw_data[1].getSelectedRow(ll_srow)
	If ll_srow = 0 Then Exit
	
	If ic_data[1] < 0 Then
		lc_balance = idw_data[1].Object.balance[ll_srow]
		If lc_balance + ic_data[1] < 0 Then 
			MessageBox(is_title, "마이너스 충전금액이 카드잔액을 초과하였습니다.")
			Return
		End If
	End If
	
	ls_pid = idw_data[1].Object.pid[ll_srow]
	If IsNull(ls_pid) Then ls_pid = ""
	
	ls_contno = idw_data[1].Object.contno[ll_srow]
	If IsNull(ls_contno) Then ls_contno = ""
	
	ls_extdays = String(idw_data[1].Object.extdays[ll_srow])
	If IsNull(ls_extdays) Then ls_extdays = ""
	ls_refilldt = MidA(is_data[3], 1,4) + "-" + MidA(is_data[3], 5,2) + "-" + MidA(is_data[3], 7,2)
	ld_refilldt = Date(ls_refilldt)
	ld_enddt = fd_date_next(ld_refilldt, Long(ls_extdays))
	ls_enddt = String(ld_enddt, 'yyyymmdd')
	
	
	//카드 정보 Update
	Update p_cardmst Set
			enddt = to_date(:ls_enddt, 'yyyymmdd'),
			refillsum_amt = refillsum_amt + :ic_data[1],
			balance = balance + :ic_data[1],
			salesum_amt = salesum_amt + :ic_data[2],
			last_refill_amt = :ic_data[1],
			last_refilldt = to_date(:is_data[3], 'yyyy-mm-dd'),
			remark = :is_data[4],
			status = :is_data[5]
	Where pid = :ls_pid;
	
	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(is_title, " Update Error(P_CARDMST)" )
		Return
	End If
	
	Select prefixno
	Into :ls_partner_prefix
	From partnermst
	Where partner = :is_data[1];
	
	Select pricemodel, priceplan
	Into :ls_model, :ls_priceplan
	From p_cardmst
	Where pid = :ls_pid;
	
	//충전 이력 Insert
	Insert Into P_REFILLLOG
		( REFILLSEQ, pid, refilldt, contno, refill_type, 
		  refill_amt, sale_amt, remark, eday, partner_prefix, crtdt, crt_user,
		  pricemodel, priceplan)
	Values 
		( SEQ_REFILLLOG.nextval, :ls_pid, to_date(:is_data[3],'yyyy-mm-dd'), :ls_contno, :is_data[2],
		:ic_data[1], :ic_data[2], :is_data[4], :ls_extdays, :ls_partner_prefix, sysdate, :gs_user_id,
		:ls_model, :ls_priceplan);
		
	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(is_title,  " Insert Error(P_RFILLLOG)" )
		Return 
	End If
Loop	


ii_rc = 0
Return 
end subroutine

on p1c_dbmgr.create
call super::create
end on

on p1c_dbmgr.destroy
call super::destroy
end on

