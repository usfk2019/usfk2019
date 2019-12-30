$PBExportHeader$b1u_dbmgr13.sru
$PBExportComments$[juede] 서비스개통신청(선불) - 선납품목 추가 - 애니유저넷
forward
global type b1u_dbmgr13 from u_cust_a_db
end type
end forward

global type b1u_dbmgr13 from u_cust_a_db
end type
global b1u_dbmgr13 b1u_dbmgr13

forward prototypes
public subroutine uf_prc_db_05 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_05 ();/*************************************************************
/ 2005.04.06 juede 서비스 신청 개통 처리 (후불제) : AnyUserNet
**************************************************************/

String ls_ref_desc, ls_status, ls_customerid, ls_cus_status, ls_activedt, ls_svccod, ls_priceplan
String ls_prmtype, ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_partner, ls_orderdt
String ls_requestdt, ls_bil_fromdt, ls_settle_partner, ls_contractno, ls_reg_prefixno, ls_remark
String ls_pgm_id, ls_term_status, ls_enter_status, ls_dlvstat, ls_validkey, ls_todt_tmp, ls_svctype
String ls_levelcod, ls_temp, ls_payid
Datetime ldt_crtdt
Long   ll_row, ll_cnt
Dec{0} ldc_contractseq, ldc_orderno

//"b1w_reg_svc_actprc_pre_1_aun%save"
String ls_refilltype[], ls_pricemodel
Decimal{2} ldc_first_refill_amt, ldc_first_sale_amt
String ls_hotbillflag

//2005.04.06 juede anyusernet 인증키분리 추가--------- start
Date ld_fromdt
Long ll_validkey_cnt
//2005.04.06 juede anyusernet -------------------------- end

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actprc_1_aun%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_1%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//2004.12.07. khpark modify start
		ls_payid = Trim(idw_data[1].object.customerm_payid[1])
		IF IsNull(ls_payid) Then ls_payid = ""
		
	    Select hotbillflag
         Into :ls_hotbillflag
         From customerm
        Where customerid = :ls_payid;
		
		If SQLCA.SQLCode = 100 Then		//Not Found
		   f_msg_usr_err(201,is_Title, "select not found(payid)")
		   ii_rc = -1
		   Return
		End If

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT customerm(hotbillflag)")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	

		If IsNull(ls_hotbillflag) Then ls_hotbillflag = ""
		If ls_hotbillflag = 'S' Then    //현재 Hotbilling고객이면 개통신청 못하게 한다.
		   f_msg_usr_err(201, is_Title, "즉시불처리중인고객")
		   ii_rc = -1
		   return
		End If
		//2004.12.07. khpark modify end
		
		//contractseq 가져 오기
		Select seq_contractseq.nextval
		Into :ldc_contractseq
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		idw_data[1].object.contractseq[1] = string(ldc_contractseq)
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt = String(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt = String(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_cus_status) Then ls_cus_status = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""						
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_requestdt) Then ls_requestdt = ""						
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		If IsNull(ls_contractno) Then ls_contractno = ""
		If IsNull(ls_remark) Then ls_remark = ""
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			Return 
		End If	
			
		// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
		//해지상태
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		//가입상태
		ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)

		If ls_cus_status = ls_term_status Then
			
			Update customerm
			Set status    = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt    = :ldt_crtdt
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]

		Update svcorder
		Set status          = :ls_status,
		    ref_contractseq = :ldc_contractseq,
			 remark          = :ls_remark,
			 updt_user       = :gs_user_id,
			 updtdt          = :ldt_crtdt,
			 pgm_id          = :ls_pgm_id
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
				
		Update contractdet
		Set contractseq = :ldc_contractseq
		Where orderno   = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
			Return 
		End If

		Update quota_info
		Set contractseq = :ldc_contractseq,
			 updt_user   = :gs_user_id,
			 updtdt      = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If
		
		//장비금액을 할부로 안하고 일시불로 처리했을 경우 oncepayment Update
		Update oncepayment
		Set contractseq = :ldc_contractseq,
			 updt_user   = :gs_user_id,
			 updtdt      = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update ONCEPAYMENT Table")				
			Return 
		End If
		
		//배송대기(개통완료)
		ls_dlvstat = fs_get_control("E1", "A410", ls_ref_desc)
		
		Update admst
		Set contractseq = :ldc_contractseq,
		    dlvstat     = :ls_dlvstat
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update ADMST Table")				
			Return 
		End If
		
		//Valid Key Update
		String ls_itemcod
		String ls_reqactive //개통 신청 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		
		DECLARE cur_validkey_check CURSOR FOR
//			Select validkey, to_char(fromdt,'yyyymmdd'), svctype
// 			  From validinfo
//			 Where customerid = :ls_customerid 
//			   and status = :ls_reqactive 
//			   and priceplan = :ls_priceplan;
			   
			Select validkey, to_char(fromdt,'yyyymmdd'), svctype
 			  From validinfo
			 Where orderno = :ldc_orderno;
		  
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
				Return 
			End If

		OPEN cur_validkey_check;
		Do While(True)
			FETCH cur_validkey_check
			Into :ls_validkey, :ls_todt_tmp, :ls_svctype;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ll_cnt = 0
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			  from validinfo
			 where ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					 ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
					 :ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and validkey = :ls_validkey
			   and to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
				Return 
			End If
			
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check;
		
		Update validinfo
		Set fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			 use_yn = 'Y',												//사용여부
			 status = :ls_status,
			 contractseq = :ldc_contractseq,
			 svccod = :ls_svccod,
       	     priceplan = :ls_priceplan,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;
//		Where customerid = :ls_customerid and status = :ls_reqactive and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If

		//validinfo_sub update  2005.04.06 juede anyusernet ---------------------------start			  
		SELECT count(*)
		INTO :ll_validkey_cnt
		FROM validinfo
		WHERE orderno = :ldc_orderno;
		
		If ll_validkey_cnt >0  Then
		
			DECLARE validinfo_key CURSOR FOR
				Select validkey, fromdt,svctype
				From   validinfo
				Where  orderno = :ldc_orderno;
			
			OPEN validinfo_key;
			
			Do While(True)
				FETCH validinfo_key INTO :ls_validkey, :ld_fromdt,:ls_svctype;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Select Error(VALIDINFO_VALIDKEY)")
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If		
				
				Update validinfo_sub
					Set fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
						 updt_user = :gs_user_id,
							 updtdt = :ldt_crtdt,
							 pgm_id = :ls_pgm_id
				 Where validkey = :ls_validkey
				  AND  fromdt = :ld_fromdt
				  AND  svctype = :ls_svctype;
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If			  
							
				
			Loop					
			CLOSE validinfo_key;			
			
		Else
				SELECT validkey, fromdt, svctype
				INTO   :ls_validkey, :ld_fromdt, :ls_svctype
				FROM   validinfo
				WHERE  orderno = :ldc_orderno;
								
			
				Update validinfo_sub
					Set fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
						 updt_user = :gs_user_id,
							 updtdt = :ldt_crtdt,
							 pgm_id = :ls_pgm_id
				 Where validkey = :ls_validkey
				  AND  fromdt = :ld_fromdt
				  AND  svctype = :ls_svctype;
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If			  
			  
		End If
		//validinfo_sub update  2005.04.06 juede anyusernet -------------------------------end	
		
		//대리점의 여신관리여부가 Y일경우의 처리
 		//총출고금액(tot_samt)에 ADMODEL의 이동기준금액(partner_amt)을 update 한다. 2003.10.31 김은미 수정. (sale_amt)로 변경.
		ls_ref_desc = ""
		ls_levelcod = fs_get_control("A1","C100", ls_ref_desc)
			
		Update partnermst
		Set tot_samt = nvl(tot_samt,0) + nvl((select nvl(a.sale_amt,0)
											             from admodel a, admst b
   													   where a.modelno = b.modelno 
 															  and b.orderno = :ldc_orderno ),0),
			 updt_user = :gs_user_id,
			 updtdt    = sysdate,
			 pgm_id    = :gs_pgm_id[gi_open_win_no]
		Where partner = ( select partner 
    		              from partnermst
								 where levelcod = :ls_levelcod
								   and :ls_reg_prefixno like prefixno||'%'
									and credit_yn = 'Y');

		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update partnermst Table")				
			Return 
		End If
		
		//가격정책별 인증Key Type에 해당하는 validkey 인 경우(2004.06.03 김은미 추가)
		Update validkeymst
		Set    contractseq = :ldc_contractseq,
		       activedt    = to_date(:ls_activedt,'yyyy-mm-dd')
		Where  orderno     = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")				
			Return 
		End If
			 
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")
		
	Case "b1w_reg_svc_actprc_pre_1%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_pre%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])

		//contractseq 가져 오기
		Select seq_contractseq.nextval
		Into :ldc_contractseq
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		idw_data[1].object.contractseq[1] = string(ldc_contractseq)
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt = STring(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt = STring(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark = Trim(idw_data[1].object.remark[1])

		ls_pricemodel = Trim(idw_data[1].object.svcorder_pricemodel[1])
		ldc_first_refill_amt  = idw_data[1].object.svcorder_first_refill_amt[1]
		ldc_first_sale_amt = idw_data[1].object.svcorder_first_sale_amt[1]
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_cus_status) Then ls_cus_status = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""						
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_requestdt) Then ls_requestdt = ""						
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		If IsNull(ls_contractno) Then ls_contractno = ""
		
		If IsNull(ls_pricemodel) Then ls_pricemodel = ""
		If IsNull(ldc_first_refill_amt) Then ldc_first_refill_amt = 0
		If IsNull(ldc_first_sale_amt) Then ldc_first_sale_amt = 0
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
			   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
			   pricemodel, refillsum_amt, salesum_amt, balance, 
			   first_refill_amt, first_sale_amt, last_refill_amt, last_refilldt)
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno,
			   :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt,
			   :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt, to_date(:ls_activedt,'yyyy-mm-dd'));

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			Return 
		End If	
			
		//Insert refilllog
		insert into refilllog
			(  refillseq, contractseq, customerid, refilldt, 
			   refill_type, refill_amt, sale_amt,
			   remark, partner_prefix, crtdt, crt_user)
		values ( seq_refilllogseq.nextval, :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), 
			   :ls_refilltype[1], :ldc_first_refill_amt, :ldc_first_sale_amt,
			   '최초충전', :ls_reg_prefixno, sysdate, :gs_user_id);
			   
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(refilllog)")
			Return 
		End If	

			
		// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
		//해지상태
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		//가입상태
		ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)

		If ls_cus_status = ls_term_status Then
			
			Update customerm
			Set status = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt = :ldt_crtdt
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]

		Update svcorder
		Set status = :ls_status,
		    ref_contractseq = :ldc_contractseq,
			remark = :ls_remark,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
				
		Update contractdet
		Set contractseq = :ldc_contractseq
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
			Return 
		End If

		Update quota_info
		Set contractseq = :ldc_contractseq,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If

		//Valid Key Update
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		

		DECLARE cur_validkey_check1 CURSOR FOR
			Select validkey, to_char(fromdt,'yyyymmdd'), svctype
			  From validinfo
			Where orderno = :ldc_orderno;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check1")				
				Return 
			End If

		OPEN cur_validkey_check1;
		Do While(True)
			FETCH cur_validkey_check1
			Into :ls_validkey, :ls_todt_tmp, :ls_svctype;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check1")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ll_cnt = 0
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					  ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
						:ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey
			   and  to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and  svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
				Return 
			End If
			
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check1;
		
		Update validinfo
		Set  fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			 use_yn = 'Y',												//사용여부
			 status = :ls_status,
			 contractseq = :ldc_contractseq,
			 svccod = :ls_svccod,
       		 priceplan = :ls_priceplan,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;			 
//		Where customerid = :ls_customerid and status = :ls_reqactive and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If
		
		//가격정책별 인증Key Type에 해당하는 validkey 인 경우(2004.06.03 김은미 추가)
		Update validkeymst
		Set    contractseq = :ldc_contractseq,
		       activedt    = to_date(:ls_activedt,'yyyy-mm-dd')
		Where  orderno     = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")				
			Return 
		End If
			 
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")
		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_01 ();/*************************************************************
/ 2005.04.06 juede 신청취소처리 : AnyUserNet
**************************************************************/
//"b1w_inq_svcorder_b%cancel"
String ls_ref_desc, ls_result_code[], ls_temp, ls_customerid, ls_validkeystatus
String ls_order_status, ls_tmp, ls_serialno, ls_mv_partner, ls_status
Long   ll_hwseq
Integer li_cnt

//2005.04.06 juede anyusernet 인증키분리 추가--------- start
Date ld_fromdt
Long ll_validkey_cnt
String ls_svctype, ls_validkey
//2005.04.06 juede anyusernet -------------------------- end

ii_rc = -2
Choose Case is_caller
	Case "b1w_inq_svcorder_c_aun%cancel"
//		lu_dbmgr.is_caller = "b1w_inq_svcorder_c%cancel"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data  Order Number
//		lu_dbmgr.is_data[2] = is_partner
//		lu_dbmgr.is_data[3] = is_status_1
//		lu_dbmgr.is_data[4] = is_status_2
//		lu_dbmgr.is_data[6] = gs_user_id
//		lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.ii_data[1]  = ii_cnt 

		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[idw_data[1].getrow()])
		ls_order_status = Trim(idw_data[1].object.svcorder_status[idw_data[1].getrow()])

		//1.서비스신청(svcorder) 테이블 Delete
		DELETE FROM svcorder 
		WHERE to_char(orderno) = :is_data[1];

		String ls_reqactive, ls_reqactive1 //개통 신청 상태, 개통신청(단말기미등록) 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		ls_reqactive1 = fs_get_control("B0", "P241", ls_ref_desc)
		
		
		//개통신청인 경우 validinfo 삭제...
		IF ls_reqactive = ls_order_status or ls_reqactive1 = ls_order_status Then
			
			//validinfo_sub update  2005.04.06 juede anyusernet ---------------------------start			  
			SELECT count(*)
			INTO :ll_validkey_cnt
			FROM validinfo
			WHERE to_char(orderno) = :is_data[1];
			
			If ll_validkey_cnt >0  Then
			
				DECLARE validinfo_key CURSOR FOR
					Select validkey, fromdt, svctype
					From   validinfo
					Where  to_char(orderno) = :is_data[1];
				
				OPEN validinfo_key;
				
				Do While(True)
					FETCH validinfo_key INTO :ls_validkey, :ld_fromdt,:ls_svctype;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Select Error(VALIDINFO_VALIDKEY)")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If		
					
					DELETE validinfo_sub
					 Where validkey = :ls_validkey
					  AND  fromdt = :ld_fromdt
					  AND  svctype = :ls_svctype;
				  
				  If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " DELETE Error(VALIDINFO_SUB)")
						Rollback;
						ii_rc = -1
						Return  
				  End If			  
								
					
				Loop					
				CLOSE validinfo_key;			
				
			Else
					SELECT validkey, fromdt, svctype
					INTO   :ls_validkey, :ld_fromdt, :ls_svctype
					FROM   validinfo
					WHERE  to_char(orderno) = :is_data[1];
									
				
					DELETE validinfo_sub
					 Where validkey = :ls_validkey
					  AND  fromdt = :ld_fromdt
					  AND  svctype = :ls_svctype;
				  
				  If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " DELETE Error(VALIDINFO_SUB)")
						Rollback;
						ii_rc = -1
						Return  
				  End If			  
				  
			End If
			//validinfo_sub update  2005.04.06 juede anyusernet -------------------------------end						
			
			//Validinfo 삭제
			DELETE FROM validinfo
			WHERE to_char(orderno) = :is_data[1];
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " DETELE Error(VALIDINFO)")
				RollBack;
				Return 
			End If
			
		
			
		End IF
		
		//2.계약품목디테일(contractdet) 테이블 Delete
		DELETE FROM contractdet 
		WHERE to_char(orderno) = :is_data[1];
		
		//3.할부정보(quota_info) 테이블 Delete
		DELETE FROM quota_info
		WHERE to_char(orderno) = :is_data[1];
		
		//4.해당 Order 번호에 해당하는 하드웨어 정보가 있는지 확인
		Select count(*)
		Into :li_cnt
		From customer_hw
		Where to_char(orderno) = :is_data[1];
		
		If li_cnt > 0 Then
			
			SetNull(ls_tmp)		//Null Setting
			
			DECLARE serialno CURSOR FOR
				Select serialno
				From customer_hw
				Where to_char(orderno) = :is_data[1];
			
			
			Open serialno;
		 	Do While(True)										//looping
				Fetch serialno
				into :ls_serialno;
						 //error
						 If SQLCA.SQLCODE < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select Error(CUSTOMER_HW)")
							Close serialno;
							Return 
						 
						 ElseIf SQLCA.SQLCODE = 100 Then
							exit;
				       End If
						 
						 
						 
					 	//장비 마스터에 Update
						Select mv_partner, adseq
						Into :ls_mv_partner, :ll_hwseq
						From admst
						Where serialno = :ls_serialno;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
							RollBack;
							Return 
						End If
						
						If ls_mv_partner = is_data[2] Then  // 본사이면
			   			ls_status = is_data[3]
						Else
							ls_status = is_data[4]				//대리점
						End If
			
						Update admst
						Set status = :ls_status,
						saledt = :ls_tmp,
						customerid = :ls_tmp,
						sale_amt = :ls_tmp,
						sale_flag = '0',
						updt_user = :is_data[6],
						pgm_id = :is_data[7]
						Where serialno = :ls_serialno;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
							RollBack;
							Return 
						End If
			
						//admstlog insert	장비 이력
						Insert Into admstlog ( adseq, seq, action, status, actdt, customerid, fr_partner,
													  crt_user, crtdt, pgm_id)
										Values( :ll_hwseq, seq_admstlog.nextval, :is_data[5], :ls_status,
													sysdate, :ls_customerid, :ls_mv_partner, :is_data[6], sysdate,:is_data[7]);
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG)")
							RollBack;
							Return 
						End If							
				
				Loop
			CLOSE serialno;
			
			//4.고객HW정보(customer_hw) 테이블 Delete
			DELETE FROM customer_hw
			WHERE orderno = :is_data[1];
			
		End If		
				
		   
		//5.위약금내역(penaltydet)테이블 Delete  
		DELETE FROM penaltydet  
		WHERE to_char(orderno) = :is_data[1];
		
		//6.일시불정보내역(oncepayment)테이블 Delete
		DELETE FROM oncepayment
		WHERE to_char(orderno) = :is_data[1];
		
				
		//7.가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
		If ii_data[1] > 0 Then
			
			//인증Key 관리상태
			ls_temp = fs_get_control("B1","P400", ls_ref_desc)
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_result_code[])
			
			//인증Key 관리상태(개통:00)
			ls_validkeystatus = ls_result_code[1]
			
							
			//인증Key 마스터 Update
			Update validkeymst
			Set    status      = :ls_validkeystatus,
					 sale_flag   = '0',
					 activedt    = null,
					 customerid  = null,
					 orderno     = 0,
					 contractseq = 0,
					 updt_user   = :gs_user_id,
					 updtdt      = sysdate
			Where  orderno     = :is_data[1];
			
		End If
		
		//8.선납판매정보에 따른 처리 추가 (2004.12.10 kem)
		DELETE FROM PREPAYMENT
		WHERE TO_CHAR(ORDERNO) = :is_data[1];
		
		//9.선수금등록에 따른 처리 추가 (2004.12.20 kem)
		DELETE FROM REQPAY
		WHERE TO_CHAR(ORDERNO) = :is_data[1];
	
End Choose	
ii_rc = 0
end subroutine

public subroutine uf_prc_db_06 ();/*************************************************************
/ 2005.04.06 juede 서비스 해지 처리 ALL(인증키) : AnyUserNet
**************************************************************/
String ls_act_yn, ls_customerid, ls_payid, ls_enddt, ls_termdt, ls_ref_desc
String ls_orderno, ls_contractseq, ls_svccod, ls_termtype, ls_customerid_1, ls_act_status
String ls_sysdt, ls_activedt, ls_remark, ls_validkeystatus, ls_validkey, ls_pgm_id
String ls_svctype, ls_svctype_pre, ls_svctype_post, ls_svctype_post1, ls_temp, ls_result_code[]
String ls_reg_partner, ls_validkeystatus1
Long ll_cnt, ll_cnt1, ll_svccnt

//"b1w_inq_svcorder_b%cancel"
String ls_order_status, ls_tmp, ls_serialno, ls_mv_partner, ls_status
Long   ll_hwseq
Integer li_cnt

//2005.04.06 juede anyusernet 인증키분리 추가--------- start
Date ld_fromdt
Long ll_validkey_cnt
//2005.04.06 juede anyusernet -------------------------- end

ii_rc = -2
Choose Case is_caller
	Case "b1w_reg_svc_termprc_b_aun%save"
//	lu_dbmgr.is_caller = "b1w_reg_svc_termprc%save"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = is_reqterm
//	lu_dbmgr.is_data[2] = is_term
//	lu_dbmgr.is_data[3] = gs_user_group
//	lu_dbmgr.is_data[4] = is_requestactive
//	lu_dbmgr.is_data[5] = is_termstatus
//	lu_dbmgr.is_data[6] = gs_user_id
//	lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
//	lu_dbmgr.idw_data[1] = dw_detail

		//서비스type - 선불제
		ls_ref_desc = ""
		ls_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)
		
		//서비스type - 후불제
		ls_ref_desc = ""
		ls_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)
		
		//서비스type -  비과금후불제
		ls_ref_desc = ""
		ls_svctype_post1 = fs_get_control("B0", "P103", ls_ref_desc)

		//필수 항목 Check
		ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')		
		ls_termdt = String(idw_data[1].object.termdt[1], 'yyyymmdd')
		ls_enddt = String(idw_data[1].object.enddt[1],'yyyymmdd')
		ls_activedt = String(idw_data[1].object.contractmst_activedt[1],'yyyymmdd')
		ls_termtype = Trim(idw_data[1].object.svcorder_termtype[1])	
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])		
		ls_svctype = Trim(idw_data[1].object.svcmst_svctype[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		If IsNull(ls_termdt) Then ls_termdt = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		If IsNull(ls_activedt) Then ls_activedt = ""		
		If IsNull(ls_termtype) Then ls_termtype = ""
		If IsNull(ls_customerid) Then ls_customerid = ""		
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_remark) Then ls_remark = ""
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""
		
		ls_pgm_id = is_data[7]

		If ls_termdt = "" Then
			f_msg_usr_err(200, is_title, "해지일자")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("termdt")
			Return
		End If

		If ls_svctype = ls_svctype_pre Then
			
		ElseIf ls_svctype = ls_svctype_post Then
			
			If fb_reqdt_check(is_Title,ls_customerid,ls_termdt,"해지요청일") Then
			Else
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("termdt")
				Return 
			End If
		
		End If
		
	   If is_data[8] = "Y" Then //날짜 Check
// ---2005.04.15 juede anyusernet 주석처리 -------start		
//			If ls_termdt <= ls_sysdt Then
//				f_msg_usr_err(200, is_Title, "해지요청일은 오늘날짜 이상이여야 합니다.")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("termdt")
//				Return
//			End If		
// ---2005.04.15 juede anyusernet 주석처리  -------end
	  	End If
	
		If ls_termdt <= ls_activedt Then
			f_msg_usr_err(200, is_Title, "'해지요청일은 개통일보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("termdt")
			Return
		End If		
		
		If ls_enddt = "" Then
			f_msg_usr_err(200, is_title, "과금종료일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("enddt")
			Return
		End If
		
		//modify pkh : 2003-09-29 (과금종료일 <= 해지요청일)
		If  ls_termdt <= ls_enddt Then
			f_msg_usr_err(200, is_title, "과금종료일은 해지요청일보다 작아야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("enddt")
			Return
		End If
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

		ls_contractseq = String(idw_data[1].object.contractmst_contractseq[1])
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_termdt
		   and to_char(contractseq) = :ls_contractseq
		   and status = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "해지요청일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("termdt")
			ii_rc = -2
			Return
		End If
		
		
		//해지 할 수 있는지 권한 여부 
		Select act_yn
		Into :ls_act_yn
		From partnermst
		Where partner = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
			ii_rc = -1
			Return  
		End If
		
		If ls_act_yn = "N" Then
			f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
			Return
		End If
		
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
		ls_payid = Trim(idw_data[1].object.customerm_payid[1])
		
	  //서비스 개통 상태 갯수 확인	 
	  Select count(*) 
	  Into :ll_cnt
	  From contractmst 
	  Where customerid = :ls_customerid and status <> :is_data[2];
	  
	  If SQLCA.SQLCode < 0 Then
		  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
		  ii_rc = -1
		  Return
	  End If
	  
	 //마시막 서비스 해지 하려 하면 
	 //가입자로 들어있는 고객 확인
	 If ll_cnt = 1 Then	
		//납입 고객일 경우 
		If ls_customerid = ls_payid  Then
			Select cus.customerid
			Into :ls_customerid_1
			From customerm cus, contractmst cnt
			Where cus.customerid = cnt.customerid And
					cus.payid = :ls_payid and cnt.customerid <> :ls_customerid and
					cnt.status <> :is_data[2] and rownum = 1;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " SELECT Error(CUSTOMERM)")
				ii_rc = -1
				Return  
			End If
			
			If IsNull(ls_customerid_1) Then ls_customerid_1  = ""
			If ls_customerid_1 <> "" Then
				
				
				f_msg_usr_err(9000, is_title , "납입고객 : " + ls_payid + " 에 " + &
														 "포함되는 ~r가입고객 : " + ls_customerid_1 + "이 존재합니다. ~r" + &
														 "먼저 가입고객의 서비스를 해지하십시오.")
				Return
			End If
		End If	
	 End If	
		
		//해지처리.
		//svcorder update
		ls_orderno = STring(idw_data[1].object.svcorder_orderno[1])
		Update svcorder 
		   Set  status = :is_data[2],
			     remark = :ls_remark,
				updt_user = :is_data[6],
				updtdt = sysdate,
				pgm_id = :is_data[7]
		Where to_char(orderno) = :ls_orderno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
			Rollback;
			ii_rc = -1
			Return  
		End If

		//contractmst Update
		Update contractmst 
		Set status = :is_data[2],
			termtype = :ls_termtype,
			termdt = to_date(:ls_termdt, 'yyyy-mm-dd'),
			bil_todt = to_date(:ls_enddt, 'yyyy-mm-dd'),
			updt_user = :is_data[6],
			updtdt = sysdate,
			pgm_id = :is_data[7]
		Where to_char(contractseq) = :ls_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
			Rollback;
			ii_rc = -1
			Return  
		End If
		
		//인증 정보 Update
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		
		If ls_svctype <> ls_svctype_post1 Then
		   Update validinfo
			Set todt = nvl(todt,to_date(:ls_termdt, 'yyyy-mm-dd')),
			status = :is_data[2],
			use_yn = 'N',
			updt_user = :is_data[6],
			updtdt = sysdate,
			pgm_id = :is_data[7]
			Where to_char(contractseq) = :ls_contractseq;
									
//Where svccod = :ls_svccod and customerid = :ls_customerid and
//				decode(todt, null, to_date(:ls_termdt, 'yyyy-mm-dd'), to_char(todt, 'yyyymmdd')) > = :ls_termdt;
	  
		  If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
				Rollback;
				ii_rc = -1
				Return  
		  End If
		  
			//validinfo_sub update  2005.04.06 juede anyusernet ---------------------------start			  
			SELECT count(*)
			INTO :ll_validkey_cnt
			FROM validinfo
			WHERE to_char(contractseq) = :ls_contractseq;
			
			If ll_validkey_cnt >0  Then
			
				DECLARE validinfo_key CURSOR FOR
					Select validkey, fromdt, svctype
					From   validinfo
					Where  to_char(contractseq) = :ls_contractseq;
				
				OPEN validinfo_key;
				
				Do While(True)
					FETCH validinfo_key INTO :ls_validkey, :ld_fromdt,:ls_svctype;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Select Error(VALIDINFO_VALIDKEY)")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If		
					
					Update validinfo_sub
						Set todt = nvl(todt,to_date(:ls_termdt, 'yyyy-mm-dd')), //해지일
							 updt_user = :is_data[6],
							 updtdt = sysdate,
							 pgm_id = :is_data[7]
					 Where validkey = :ls_validkey
					  AND  fromdt = :ld_fromdt
					  AND  svctype = :ls_svctype;
				  
				  If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
						Rollback;
						ii_rc = -1
						Return  
				  End If			  
								
					
				Loop					
				CLOSE validinfo_key;			
				
			Else
					SELECT validkey, fromdt, svctype
					INTO   :ls_validkey, :ld_fromdt, :ls_svctype
					FROM   validinfo
					WHERE  to_char(contractseq) = :ls_contractseq;
									
				
					Update validinfo_sub
						Set todt = nvl(todt,to_date(:ls_termdt, 'yyyy-mm-dd')), //해지일
							 updt_user = :is_data[6],
							 updtdt = sysdate,
							 pgm_id = :is_data[7]
					 Where validkey = :ls_validkey
					  AND  fromdt = :ld_fromdt
					  AND  svctype = :ls_svctype;
				  
				  If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
						Rollback;
						ii_rc = -1
						Return  
				  End If			  
				  
			End If
			//validinfo_sub update  2005.04.06 juede anyusernet -------------------------------end			  
		  
		End If
		
		
		
		//가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
		If ii_data[1] > 0 Then
				
			//인증Key 관리상태
			ls_temp = fs_get_control("B1","P400", ls_ref_desc)
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_result_code[])
			
			//인증Key 관리상태(개통:99)
			ls_validkeystatus = ls_result_code[1]
			ls_validkeystatus1 = ls_result_code[3]
			
			//인증Key 마스터 Log Insert
			Insert into validkeymst_log ( validkey, seq, status, actdt,
													customerid, contractseq, partner, crt_user,
													crtdt, pgm_id )
											select validkey, seq_validkeymstlog.nextval, :ls_validkeystatus1, sysdate,
													 customerid, contractseq, :ls_reg_partner, :gs_user_id,
													 sysdate, :ls_pgm_id
											from   validkeymst
											where  to_char(contractseq) = :ls_contractseq;
	
							
			//인증Key 마스터 Update
			Update validkeymst
			Set    status      = :ls_validkeystatus,
					 sale_flag   = '0',
					 activedt    = null,
					 customerid  = null,
					 orderno     = 0,
					 contractseq = 0,
					 updt_user   = :gs_user_id,
					 updtdt      = sysdate
			Where  to_char(contractseq) = :ls_contractseq;
			
		End If
	  
	   //서비스 개통 상태 갯수 확인	 
	  Select count(*) 
	  Into :ll_cnt
	  From contractmst 
	  Where customerid = :ls_customerid and status <> :is_data[2];
	  
	  If SQLCA.SQLCode < 0 Then
		  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
		  ii_rc = -1
		  Return  
	  End If
	  
	  //현 신청 상태 확인
	  Select count(*)
	  Into :ll_cnt1
	  From svcorder
	  Where customerid = :ls_customerid and status = :is_data[4];
	  
	  If SQLCA.SQLCode < 0 Then
		  f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
		  ii_rc = -1
		  Return  
	  End If
	  
	 //고객 해지 처리
	 If ll_cnt = 0 and ll_cnt1	= 0 Then
			
	      Update customerm
			Set status = :is_data[5],
				 termtype = :ls_termtype,
				 termdt = to_date(:ls_termdt, 'yyyy-mm-dd'),
				 updt_user = :is_data[6],
				 updtdt = sysdate,
				 pgm_id = :is_data[7]
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMERM)")
				Rollback;
				ii_rc = -1
				Return  
	  		End If
	End If
	
	Case "b1w_inq_svcorder_b%cancel"
//		lu_dbmgr.is_caller = "b1w_inq_svcorder%cancel"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data  Order Number
//		lu_dbmgr.is_data[2] = is_partner
//		lu_dbmgr.is_data[3] = is_status_1
//		lu_dbmgr.is_data[4] = is_status_2
//		lu_dbmgr.is_data[6] = gs_user_id
//		lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.ii_data[1]  = ii_cnt 

		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[idw_data[1].getrow()])
		ls_order_status = Trim(idw_data[1].object.svcorder_status[idw_data[1].getrow()])

		//1.서비스신청(svcorder) 테이블 Delete
		DELETE FROM svcorder 
		WHERE to_char(orderno) = :is_data[1];

		String ls_reqactive, ls_reqactive1 //개통 신청 상태, 개통신청(단말기미등록) 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		ls_reqactive1 = fs_get_control("B0", "P241", ls_ref_desc)
		
		
		//개통신청인 경우 validinfo 삭제...
		IF ls_reqactive = ls_order_status or ls_reqactive1 = ls_order_status Then
			
			//Validinfo 삭제
			DELETE FROM validinfo
			WHERE to_char(orderno) = :is_data[1];
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " DETELE Error(VALIDINFO)")
				RollBack;
				Return 
			End If
			
		End IF
		
		//2.계약품목디테일(contractdet) 테이블 Delete
		DELETE FROM contractdet 
		WHERE to_char(orderno) = :is_data[1];
		
		//3.할부정보(quota_info) 테이블 Delete
		DELETE FROM quota_info
		WHERE to_char(orderno) = :is_data[1];
		
		//4.해당 Order 번호에 해당하는 하드웨어 정보가 있는지 확인
		Select count(*)
		Into :li_cnt
		From customer_hw
		Where to_char(orderno) = :is_data[1];
		
		If li_cnt > 0 Then
			
			SetNull(ls_tmp)		//Null Setting
			
			DECLARE serialno CURSOR FOR
				Select serialno
				From customer_hw
				Where to_char(orderno) = :is_data[1];
			
			
			Open serialno;
		 	Do While(True)										//looping
				Fetch serialno
				into :ls_serialno;
						 //error
						 If SQLCA.SQLCODE < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select Error(CUSTOMER_HW)")
							Close serialno;
							Return 
						 
						 ElseIf SQLCA.SQLCODE = 100 Then
							exit;
				       End If
						 
						 
						 
					 	//장비 마스터에 Update
						Select mv_partner, adseq
						Into :ls_mv_partner, :ll_hwseq
						From admst
						Where serialno = :ls_serialno;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
							RollBack;
							Return 
						End If
						
						If ls_mv_partner = is_data[2] Then  // 본사이면
			   			ls_status = is_data[3]
						Else
							ls_status = is_data[4]				//대리점
						End If
			
						Update admst
						Set status = :ls_status,
						saledt = :ls_tmp,
						customerid = :ls_tmp,
						sale_amt = :ls_tmp,
						sale_flag = '0',
						updt_user = :is_data[6],
						pgm_id = :is_data[7]
						Where serialno = :ls_serialno;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
							RollBack;
							Return 
						End If
			
						//admstlog insert	장비 이력
						Insert Into admstlog ( adseq, seq, action, status, actdt, customerid, fr_partner,
													  crt_user, crtdt, pgm_id)
										Values( :ll_hwseq, seq_admstlog.nextval, :is_data[5], :ls_status,
													sysdate, :ls_customerid, :ls_mv_partner, :is_data[6], sysdate,:is_data[7]);
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG)")
							RollBack;
							Return 
						End If							
				
				Loop
			CLOSE serialno;
			
			//4.고객HW정보(customer_hw) 테이블 Delete
			DELETE FROM customer_hw
			WHERE orderno = :is_data[1];
			
		End If		
				
		   
		//5.위약금내역(penaltydet)테이블 Delete  
		DELETE FROM penaltydet  
		WHERE to_char(orderno) = :is_data[1];
		
		//6.일시불정보내역(oncepayment)테이블 Delete
		DELETE FROM oncepayment
		WHERE to_char(orderno) = :is_data[1];
		
				
		//가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
		If ii_data[1] > 0 Then
			
			//인증Key 관리상태
			ls_temp = fs_get_control("B1","P400", ls_ref_desc)
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_result_code[])
			
			//인증Key 관리상태(개통:00)
			ls_validkeystatus = ls_result_code[1]
			
							
			//인증Key 마스터 Update
			Update validkeymst
			Set    status      = :ls_validkeystatus,
					 sale_flag   = '0',
					 activedt    = null,
					 customerid  = null,
					 orderno     = 0,
					 contractseq = 0,
					 updt_user   = :gs_user_id,
					 updtdt      = sysdate
			Where  orderno     = :is_data[1];
			
		End If
	
End Choose	
ii_rc = 0
end subroutine

public subroutine uf_prc_db_03 ();// "b1w_reg_svc_termorder%save"
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_pgm_id, ls_requestactive, ls_termstatus, ls_ref_desc
String ls_act_gu , ls_status, ls_enddt, ls_act_yn, ls_payid, ls_customerid_1
Datetime ldt_crtdt
Long ll_cnt, ll_row, ll_cnt1, ll_cur
Dec ldc_orderno
String ls_contractseq, ls_result_code[]
String ls_check_yn, ls_remark, ls_temp, ls_validkeystatus, ls_validkey, ls_validkeystatus1

//2005.04.06 juede anyusernet 인증키분리 추가--------- start
String ls_svctype
Date ld_fromdt
Long ll_validkey_cnt
//2005.04.06 juede anyusernet -------------------------- end


ii_rc = -2

Choose Case is_caller
	Case "b1w_reg_svc_termorder_2_aun%save"   //2005.04.06 juede anyusernet 인증키분리
//		lu_dbmgr.is_caller = "b1w_reg_svc_termorder_1%save"
//		lu_dbmgr.is_title  = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = ls_contractseq
//		lu_dbmgr.is_data[2] = is_termstatus[1]			//해지신청상태코드
//		lu_dbmgr.is_data[3] = ls_termdt
//		lu_dbmgr.is_data[4] = ls_partner
//		lu_dbmgr.is_data[5] = ls_termtype
//		lu_dbmgr.is_data[6] = ls_prm_check
//		lu_dbmgr.is_data[7] = is_termstatus[2]        //해지상태코드
//    lu_dbmgr.idt_data[1] = ldt_termdt
//		lu_dbmgr.ii_data[1] = ii_cnt                  //가격정책별 인증Key Type 여부

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//해지처리확정일때..
		ls_act_gu = String(idw_data[1].object.act_gu[1])
		ls_enddt = String(idw_data[1].object.enddt[1],'yyyymmdd')
		If IsNull(ls_act_gu) Then ls_act_gu = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		
		If ls_act_gu = 'Y' Then
			If ls_enddt = "" Then
				f_msg_usr_err(200, is_title, "과금종료일")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("enddt")
				Return
			End If
			
			//modify pkh : 2003-09-29 (과금종료일 <= 해지요청일)
			If ls_enddt > is_data[3] Then
				f_msg_usr_err(200, is_title, "과금종료일은 해지요청일 보다 작아야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("enddt")
				Return
			End If				
			
			ls_status = is_data[7]     //해지상태
		Else
			ls_status = is_data[2]	   //해지신청상태
		End If
		
		
		ll_cnt = 0
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])		
		//해지신청내역 존재 여부 check
		Select count(*)
		 Into :ll_cnt
		 From svcorder
		Where to_char(ref_contractseq) = :is_data[1]
		  and status = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT svcorder")
	  	   ii_rc = -1													 			
			RollBack;
			Return 
		End If	
		
		If ll_cnt > 0 Then
			 f_msg_Usr_err(9000, is_caller, "고객 [" + ls_customerid + "] 계약Seq[" + &
			 										is_data[1] + "]로 이미 해지신청이 있습니다.")
		  	 ii_rc = -2													 
			 return
		End If	
		
		//서비스번호가져 오기
		Select seq_orderno.nextval
		Into :ldc_orderno
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT seq_orderno.nextval")				
	  	   ii_rc = -1													 						
			RollBack;
			Return 
		End If	
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])		
		If IsNull(ls_prmtype) Then ls_prmtype = ""								
		//해지처리확정
		ls_act_gu = Trim(idw_data[1].object.act_gu[1])				
		If IsNull(ls_act_gu) Then ls_act_gu = ""										
		
		//약정유형이 있을 경우 위약금 check procedure call 
		IF is_data[6] = '1' and ls_prmtype <> "" Then
			
			String ls_errmsg
			Long ll_return, ll_count
			Double ld_count
			
			ll_return = -1
			ls_errmsg = space(256)
			
			//처리부분...
			//subroutine B1CALCPANALTY(string P_CUSTOMERID,string P_CONTRACTSEQ,string P_TERMDT,string P_ORDERNO,string P_USER,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"B1CALCPANALTY~""			
			SQLCA.B1CALCPENALTY(ls_customerid,is_data[1],idt_data[1],string(ldc_orderno),gs_user_id,ls_pgm_id,ll_return,ls_errmsg, ld_count)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(is_Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
				ii_rc = -1
				Return
			ElseIf ll_return < 0 Then	//For User
				MessageBox(is_Title, ls_errmsg, StopSign!)
				ii_rc = -2
				Return
			End If
	
//			//Message표시
//			is_msg_process = "Completed Records: " + String(lb_count)
	
			If ll_return <> 0 Then	//실패
				ii_rc = -1
				Return 
			Else				//성공
				ii_rc = 0
			End If		
		END If		
		
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""		
		If IsNull(ls_remark) Then ls_remark = ""
		
		//Insert
		insert into svcorder
		    ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt, remark )
	   values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, :idt_data[1], :ls_status, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_data[4],
			   :is_data[1], :is_data[5], :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_remark);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Err(SVCORDER)")				
			ii_rc = -1
			Return 
		End If	
		
		
 		//해지처리루틴
		If ls_act_gu = 'Y' Then 
		
				ls_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
				ls_termstatus = fs_get_control("B0", "P201", ls_ref_desc)
		
				//해지 할 수 있는지 권한 여부 
				Select act_yn
				Into :ls_act_yn
				From partnermst
				Where partner = :gs_user_group;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
					ii_rc = -1
					Return  
				End If
				
				If ls_act_yn = "N" Then
					f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
					Return
				End If
				
				ls_payid = Trim(idw_data[1].object.customerm_payid[1])
				
			  //서비스 개통 상태 갯수 확인	 
			  Select count(*) 
			  Into :ll_cnt
			  From contractmst 
			  Where customerid = :ls_customerid and status <> :is_data[7];
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
				  ii_rc = -1
				  Return
			  End If
			  
			 //마시막 서비스 해지 하려 하면 
			 //가입자로 들어있는 고객 확인
			 If ll_cnt = 1 Then	
				//납입 고객일 경우 
				If ls_customerid = ls_payid  Then
					Select cus.customerid
					Into :ls_customerid_1
					From customerm cus, contractmst cnt
					Where cus.customerid = cnt.customerid And
							cus.payid = :ls_payid and cnt.customerid <> :ls_customerid and
							cnt.status <> :is_data[7] and rownum = 1;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " SELECT Error(CUSTOMERM)")
						ii_rc = -1
						Return  
					End If
					
					If IsNull(ls_customerid_1) Then ls_customerid_1  = ""
					If ls_customerid_1 <> "" Then
						
						
						f_msg_usr_err(9000, is_title , "납입고객 : " + ls_payid + " 에 " + &
																 "포함되는 ~r가입고객 : " + ls_customerid_1 + "이 존재합니다. ~r" + &
																 "먼저 가입고객의 서비스를 해지하십시오.")
						Return
					End If
				End If	
			End If	
				
				//해지처리.
				//contractmst Update
				Update contractmst 
				Set  status = :ls_status,
					 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
					 termtype = :is_data[5],
					 bil_todt = to_date(:ls_enddt, 'yyyy-mm-dd'),
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id
			    Where to_char(contractseq) = :is_data[1];
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
					Rollback;
					ii_rc = -1
					Return  
				End If
				
				//인증 정보 Update
			   Update validinfo
				Set todt = nvl(todt, to_date(:is_data[3], 'yyyy-mm-dd')),
				status = :ls_status,
				use_yn = 'N',
				updt_user = :gs_user_id,
				updtdt = sysdate,
				pgm_id = :ls_pgm_id
				Where to_char(contractseq) = :is_data[1];
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If
			  
			  //validinfo_sub update  2005.04.06 juede anyusernet ---------------------------start			  
			  SELECT count(*)
			  INTO :ll_validkey_cnt
			  FROM validinfo
			  WHERE to_char(contractseq) = :is_data[1];
			  
			  If ll_validkey_cnt >0  Then
				
					DECLARE validinfo_key CURSOR FOR
						Select validkey, fromdt,svctype
						From   validinfo
						Where  to_char(contractseq) = :is_data[1];
					
					OPEN validinfo_key;
					
					Do While(True)
						FETCH validinfo_key INTO :ls_validkey, :ld_fromdt,:ls_svctype;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select Error(VALIDINFO_VALIDKEY)")
							Return
						ElseIf SQLCA.SQLCode = 100 Then
							Exit
						End If		
						
						Update validinfo_sub
							Set todt = nvl(todt, to_date(:is_data[3], 'yyyy-mm-dd')),
								 updt_user = :gs_user_id,
								 updtdt = sysdate,
								 pgm_id = :ls_pgm_id
						 Where validkey = :ls_validkey
						  AND  fromdt = :ld_fromdt
						  AND  svctype = :ls_svctype;
					  
					  If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
							Rollback;
							ii_rc = -1
							Return  
					  End If			  
									
						
					Loop					
					CLOSE validinfo_key;			
					
				Else
						SELECT validkey, fromdt, svctype
						INTO   :ls_validkey, :ld_fromdt, :ls_svctype
						FROM   validinfo
						WHERE  to_char(contractseq) = :is_data[1];
										
					
						Update validinfo_sub
						   Set todt = nvl(todt, to_date(:is_data[3], 'yyyy-mm-dd')),
						       updt_user = :gs_user_id,
						       updtdt = sysdate,
						       pgm_id = :ls_pgm_id
						 Where validkey = :ls_validkey
						 	AND fromdt = :ld_fromdt
							AND svctype = :ls_svctype;
					  
					  If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
							Rollback;
							ii_rc = -1
							Return  
					  End If			  
					  
				End If
				//validinfo_sub update  2005.04.06 juede anyusernet -------------------------------end		
			  

			  
			  
				//가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
				If ii_data[1] > 0 Then
					
					//인증Key 관리상태
					ls_temp = fs_get_control("B1","P400", ls_ref_desc)
					If ls_temp = "" Then Return 
					fi_cut_string(ls_temp, ";" , ls_result_code[])
					
					//인증Key 관리상태(해지:99)
					ls_validkeystatus  = ls_result_code[1]
					ls_validkeystatus1 = ls_result_code[3]
					
					//인증Key 마스터 Log Insert
					Insert into validkeymst_log ( validkey, seq, status, actdt,
													customerid, contractseq, partner, crt_user,
													crtdt, pgm_id )
											select validkey, seq_validkeymstlog.nextval, :ls_validkeystatus1, sysdate,
													 customerid, contractseq, :ls_reg_partner, :gs_user_id,
													 sysdate, :ls_pgm_id
											from   validkeymst
											where  to_char(contractseq) = :is_data[1];
					
						
					//인증Key 마스터 Update
					Update validkeymst
					Set    status      = :ls_validkeystatus,
					       sale_flag   = '0',
							 activedt    = null,
							 customerid  = null,
							 orderno     = 0,
							 contractseq = 0,
							 updt_user   = :gs_user_id,
					       updtdt      = sysdate
					Where  to_char(contractseq) = :is_data[1];
					
				End If	   
			  
			   //서비스 개통 상태 갯수 확인	 
			  Select count(*) 
			  Into :ll_cnt
			  From contractmst 
			  Where customerid = :ls_customerid and status <> :ls_status;
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
				  ii_rc = -1
				  Return  
			  End If
			  
			  //현 신청 상태 확인
			  Select count(*)
			  Into :ll_cnt1
			  From svcorder
			  Where customerid = :ls_customerid and status = :ls_requestactive;
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
				  ii_rc = -1
				  Return  
			  End If
			  
			 //고객 해지 처리
			 If ll_cnt = 0 and ll_cnt1	= 0 Then
					
					Update customerm
					Set status = :ls_termstatus,
						termtype = :is_data[5],
						 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
						updt_user = :gs_user_id,
						updtdt = sysdate,
						pgm_id = :ls_pgm_id
					Where customerid = :ls_customerid;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMERM)")
						Rollback;
						ii_rc = -1
						Return  
					End If
			End If	
		End If
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0


end subroutine

public subroutine uf_prc_db ();
//b1w_reg_svc_actorder_6_aun%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix, ls_validloc_gu
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result  
string ls_validkey_loc[], ls_coid, ls_temp, ls_result_code[], ls_quota_yn, ls_langtype
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec, ll_priority
Time lt_now_time, lt_after_time
String ls_n_auth_method[], ls_n_validitem3[], ls_n_validitem2[], ls_n_langtype[], ls_chk_yn, ls_n_validitem1[]
String ls_vpricecod, ls_acttype, ls_hopenum, ls_remark, ls_quota_status, ls_validkeystatus
String ls_validkey_msg //인증Key MSG


//2005.04.06 juede 인증키분리-------start
String ls_validkey1[], ls_validkey2[], ls_validkey3[], ls_validkey4[]
//2005.04.06 juede -------------------end

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_6_aun%save"    //장비임대 포함 수정, 입중계출중계서비스추가
//		lu_dbmgr.is_caller   = "b1w_regsvc_actorder_5%save"
//		lu_dbmgr.is_title    = is_title
//		lu_dbmgr.idw_data[1] = idw_data[3]
//		lu_dbmgr.idw_data[2] = dw_detail2                //품목
//		lu_dbmgr.idw_data[3] = dw_detail		             //인증KEY
//		lu_dbmgr.is_data[1]  = gs_user_id
//		lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[3]  = is_act_gu                 //개통처리 check
//		lu_dbmgr.is_data[4]  = is_cus_status             //고객상태
//		lu_dbmgr.is_data[5]  = is_svctype                //svctype
//		lu_dbmgr.is_data[6]  = string(il_validkey_cnt)   //인증KEY갯수
//		lu_dbmgr.is_data[7]  = is_type          			 //MVNO svctype
//		lu_dbmgr.is_data[8]  = is_xener_svc    			 //xener 서비여부  khpark modify 2004.04.09
//		lu_dbmgr.is_data[9]  = is_inout_svc_gu    		 //입중계출중계 서비스여부 khpark modify 2004.08.26
//		lu_dbmgr.ii_data[1]  = ii_cnt                    //가격정책별 인증Key 사용:1, 미사용:0

		// SYSCTL1T의 사업자 ID
		ls_ref_desc = ""
		ls_coid = fs_get_control("00","G200", ls_ref_desc)
		
		//작업결과(Server인증Key) 코드 
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","P300", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_result_code[])

      If is_data[9] = 'Y' Then
			 ls_validkey_msg = 'Route-No.'
		Else
			 ls_validkey_msg = '인증KEY'
		End IF
		
		//2005.02.14 ohj  validkey_loc 관리
		ls_ref_desc = ""
		//발신지 Origin유형 (접속번호(S); 발신지prefix(T); 인증Key location(L))
		ls_validloc_gu  = fs_get_control("00","Z400", ls_ref_desc)	
				
		ls_customerid   = Trim(idw_data[1].object.customerid[1])
		ls_customerm    = Trim(idw_data[1].object.customernm[1])
		ls_orderdt      = String(idw_data[1].object.orderdt[1],'yyyymmdd')
		ls_requestdt    = String(idw_data[1].object.requestdt[1], 'yyyymmdd')
		ls_svccod       = Trim(idw_data[1].object.svccod[1])		
		ls_priceplan    = Trim(idw_data[1].object.priceplan[1])
		ls_vpricecod    = Trim(idw_data[1].object.vpricecod[1])
		ls_prmtype      = Trim(idw_data[1].object.prmtype[1])
		ls_maintain_partner = Trim(idw_data[1].object.maintain_partner[1])
		ls_reg_partner  = Trim(idw_data[1].object.reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.sale_partner[1])
		ls_partner      = Trim(idw_data[1].object.partner[1])
		ls_contractno   = Trim(idw_data[1].object.contract_no[1])
		ll_priority     = Long(idw_data[1].object.priority[1])
		ls_acttype      = Trim(idw_data[1].object.acttype[1])
		ls_hopenum      = Trim(idw_data[1].object.hopenum[1])
		ls_remark       = Trim(idw_data[1].object.remark[1])
		ls_gkid         = Trim(idw_data[1].object.gkid[1])
		ls_auth_method  = Trim(idw_data[1].object.auth_method[1])
		ls_h323id       = Trim(idw_data[1].object.h323id[1])
		ls_ip_address   = Trim(idw_data[1].object.ip_address[1])
		ls_langtype 	= Trim(idw_data[1].object.langtype[1])
		ls_userid       = is_data[1]
		ls_pgm_id       = is_data[2]

		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""
			
		ls_ref_desc = ""
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)		 
		//개통신청상태코드(단말기미등록)
		ls_quota_status = fs_get_control("B0", "P241", ls_ref_desc)
		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)
		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		
		If ls_reg_partner <> "" Then
			//대리점 Prefix
			Select prefixno
			  Into :ls_reg_prefix
			  From partnermst
			 Where partner = :ls_reg_partner;
		End If

		//신청 품목  check
		ll_row = idw_data[2].RowCount()
		j = 1
		For i = 1 To ll_row
		   ls_check[i] = Trim(idw_data[2].object.chk[i])
			If ls_check[i] = "Y" Then
				ls_itemcod[j] = Trim(idw_data[2].object.itemcod[i])
				j ++
			End If
		Next

		//인증KEY 갯수가 0보다 클때 입력한 인증KEY check
		If integer(is_data[6]) > 0 Then
			ll_row = idw_data[3].RowCount()
			For i = 1 To ll_row
			  	ls_validkey[i]    = Trim(idw_data[3].object.validkey[i])
			  	ls_vpasswd[i]     = Trim(idw_data[3].object.vpassword[i])
				ls_validkey_loc[i] = Trim(idw_data[3].object.validkey_loc[i])
				
				//2005.04.06 juede anyusernet validkey 분리---------start
				ls_validkey1[i]	 = Trim(idw_data[3].object.validkey1[i])
				ls_validkey2[i]	 = Trim(idw_data[3].object.validkey2[i])
				ls_validkey3[i] 	 = Trim(idw_data[3].object.validkey3[i])
				ls_validkey4[i]	 = Trim(idw_data[3].object.validkey4[i])
				//2005.04.06 juede anyusernet validkey 분리---------end				

		   	If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
				If IsNull(ls_validkey_loc[i]) Then ls_validkey_loc[i] = ""
				
				//2005.04.06 juede anyusernet validkey 분리---------start
		   	If IsNull(ls_validkey1[i]) Then ls_validkey1[i] = ""				
		   	If IsNull(ls_validkey2[i]) Then ls_validkey2[i] = ""				
		   	If IsNull(ls_validkey3[i]) Then ls_validkey3[i] = ""				
		   	If IsNull(ls_validkey4[i]) Then ls_validkey4[i] = ""												
				//2005.04.06 juede anyusernet validkey 분리---------end	
				
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				
				//2005.04.06 juede anyusernet validkey 분리---------start
				If ls_validkey1[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey1")
					ii_rc = -3
					Return	
				End If
				
				If ls_validkey2[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey2")
					ii_rc = -3
					Return	
				End If
				
				If ls_validkey3[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey3")
					ii_rc = -3
					Return	
				End If	
				
				If ls_validkey4[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey4")
					ii_rc = -3
					Return	
				End If										
				//2005.04.06 juede anyusernet validkey 분리---------end
				
//				If is_data[9] = 'N' and ls_vpasswd[i] = "" Then
//					f_msg_info(200, is_title, "인증Passwrod")
//					idw_data[3].SetRow(i)
//					idw_data[3].ScrollToRow(i)
//					idw_data[3].SetFocus()
//					idw_data[3].SetColumn("vpassword")
//					ii_rc = -3					
//					Return	
//				End If
				
				//입력한 인증KEY가 같은 인증 KEY가 있는지 check			
				CHOOSE CASE i
					CASE 1  // Row가 1행일때 
						IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", i + 1, ll_row)
					CASE ll_row // Row가 맨 마지막
						IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", 1, i -1)
					CASE ELSE	  
						IF  ll_row > 1 THEN
							ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", 1, i -1)
							IF  ll_long > 0 THEN
							else
								ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", i + 1, ll_row)
							END IF
						END IF
				END CHOOSE
				
				If ll_long > 0 Then
					// messagebox(인증KEY중복)	
					f_msg_usr_err(9000, is_title, ls_validkey_msg+"가 중복됩니다.")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					return
				End if

				If ls_validloc_gu = 'L' Then
					If ls_validkey_loc[i] = "" Then
						f_msg_info(200, is_title, ls_validkey_msg)
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetFocus()
						idw_data[3].SetColumn("validkey_loc")
						ii_rc = -3
						Return	
					End If
				End IF
				
				//인증KEY 중복 check  
				//적용시작일과 적용종료일의 중복일자를 막는다. 
				select count(*)
				  into :ll_cnt
				  from validinfo
				 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				   and validkey = :ls_validkey[i]
				   and svctype = :is_data[5];
						  
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
					Return 
				End If
				
				If ll_cnt > 0 Then
					f_msg_usr_err(9000, is_title, ls_validkey_msg +"[" + ls_validkey[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
					idw_data[3].SetFocus()
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3					
					return 
				End if
	 
				ls_n_auth_method[i] = Trim(idw_data[3].object.auth_method[i])
				ls_n_langtype[i]  = Trim(idw_data[3].object.langtype[i])
				ls_n_validitem2[i] = idw_data[3].object.validitem2[i]
				ls_n_validitem3[i] = idw_data[3].object.validitem3[i]
				ls_n_validitem1[i] = idw_data[3].object.validitem1[i]
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""
				If IsNull(ls_n_langtype[i]) Then ls_n_langtype[i] = ""
				If IsNull(ls_n_validitem2[i]) Then ls_n_validitem2[i] = ""				
				If IsNull(ls_n_validitem3[i]) Then ls_n_validitem3[i] = ""							
				If IsNull(ls_n_validitem1[i]) Then ls_n_validitem1[i] = ""		
			
				If is_data[9] = 'N' and ls_n_langtype[i] = "" Then
					f_msg_info(200, is_title, "멘트 언어")		
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("langtype")
					ii_rc = -3					
					Return 
				End If
				
				//제너서비스여부 is_data[8] = 'Y'/'N'
				If is_data[8] = 'Y' Then
					
					If ls_n_auth_method[i] = "" Then
						f_msg_info(200, is_title, "인증방법")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("auth_method")
     					ii_rc = -3						
						Return 
					End If		
				
					If LeftA(ls_n_auth_method[i],1) = 'S' Then
						
						If ls_n_validitem2[i] = "" Then
							f_msg_info(200, is_title, "IP ADDRESS")
							idw_data[3].SetFocus()
					    	idw_data[3].SetRow(i)
							idw_data[3].ScrollToRow(i)
							idw_data[3].SetColumn("validitem2")
         					ii_rc = -3							
							Return
						End If		
						
					End if
				
					If MidA(ls_n_auth_method[i],7,1) = 'B' Then
						If ls_n_validitem3[i] = "" Then
							f_msg_info(200, is_title, "H323ID")
							idw_data[3].SetFocus()
							idw_data[3].SetRow(i)
							idw_data[3].ScrollToRow(i)
							idw_data[3].SetColumn("validitem3")
         					ii_rc = -3							
							Return 
						End If		
					End if

					If LeftA(ls_auth_method,1) = 'P' Then
						If ls_vpasswd[i] = "" Then
							f_msg_info(200, is_title, "Valid Password")
							idw_data[3].SetRow(i)
							idw_data[3].ScrollToRow(i)
							idw_data[3].SetFocus()
							idw_data[3].SetColumn("vpassword")
							ii_rc = -3					
							Return	
						End If
					End If
										
				End If
		
			Next
		End If
		
		//Order Sequence
		Select seq_orderno.nextval
		  Into :ll_orderno
		  From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, " Sequence Error")
			RollBack;
			ii_rc = -1				
			Return 
		End If		

		setnull(ll_contractseq)
		
      //개통처리까지 check일 경우 : 개통처리까지 하는지 여부에 따라 status/사용여부가 바뀐다.
		If is_data[3] = 'Y' Then
			
			//contractseq 가져 오기
			Select seq_contractseq.nextval
			  Into :ll_contractseq
			  From dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
				ii_rc = -1			
				RollBack;
				Return 
			End If
			
			//개통 처리시  계약 seq 자료 가져감 -> 할부 등록을 위해
			il_data[2] = ll_contractseq
			ls_use_yn = 'Y'
		Else
			ls_act_status = ls_status
			ls_use_yn = 'N'
			
		End If
		
		il_data[1] = ll_orderno		//ordernumber 넘겨줌
		
		//svcorder insert
		Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt,
					status, svccod, priceplan, prmtype, maintain_partner, reg_partner, sale_partner,
					order_priority, hopenum, acttype, vpricecod, partner, ref_contractseq,
					crt_user, updt_user, crtdt, updtdt, pgm_id, remark)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_maintain_partner, :ls_reg_partner, :ls_sale_partner, 
				 :ll_priority, :ls_hopenum, :ls_acttype, :ls_vpricecod, :ls_partner, :ll_contractseq, 
				 :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id, :ls_remark);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SVCORDER)")
			ii_rc = -1				
			RollBack;
			Return 
		End If

		If is_data[3]='Y' Then
			
			//Insert contractmst
			insert into contractmst
				( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
				   prmtype, maintain_partner, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_maintain_partner, :ls_reg_partner, :ls_sale_partner, :ls_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				   :gs_user_id, sysdate, :ls_pgm_id, :gs_user_id, sysdate, :ls_reg_prefix);
				   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
				Return 
			End If	

//			//해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
			//가입상태
			ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)
	
			If is_data[4] = ls_term_status Then
				
				Update customerm
				Set status = :ls_enter_status,
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id					 
				Where customerid = :ls_customerid;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					ii_rc = -1
					f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
					Return 
				End If
				
			End If		
				   
		End If
		
		//contractdet insert
	   For i =1 To UpperBound(ls_itemcod[])
			Insert Into contractdet(orderno, itemcod, contractseq)
			    Values(:ll_orderno, :ls_itemcod[i], :ll_contractseq);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACDET)")
				ii_rc = -1					
				RollBack;
				Return 
			End If
		Next
		
		If integer(is_data[6]) > 0  Then
			
			//validinfo insert
			For i =1 To UpperBound(ls_validkey[])
				
				Insert Into validinfo
				    	(validkey, fromdt, status, 
						 use_yn, vpassword, svctype,
						 gkid, customerid, svccod, priceplan, 
						 orderno, contractseq, langtype,
						 auth_method, validitem1, validitem2, validitem3,
						 crt_user, updt_user, crtdt, updtdt, pgm_id, validkey_loc)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_gkid, :ls_customerid, :ls_svccod, :ls_priceplan,
					   :ll_orderno, :ll_contractseq, :ls_n_langtype[i],
					   :ls_n_auth_method[i], :ls_n_validitem1[i], :ls_n_validitem2[i], :ls_n_validitem3[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id, :ls_validkey_loc[i]);										
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
					ii_rc = -1						
					RollBack;
					Return 
				End If
				
				//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------start
				Insert Into validinfo_sub
				    	(validkey, fromdt,svctype,
						 validkey1, validkey2, validkey3,validkey4,
						 crt_user, updt_user, crtdt, updtdt, pgm_id)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :is_data[5],
						:ls_validkey1[i], :ls_validkey2[i], :ls_validkey3[i], :ls_validkey4[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);	

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo_sub)")
					ii_rc = -1						
					RollBack;
					Return 
				End If												
				//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------end				
				
				If ii_data[1] > 0 Then   //가격정책별 인증Key Type이 존재할 경우
				
					ls_temp = fs_get_control("B1","P400", ls_ref_desc)
					If ls_temp = "" Then Return 
					fi_cut_string(ls_temp, ";" , ls_result_code[])
					
					//인증Key 관리상태(개통:20)
					ls_validkeystatus = ls_result_code[2]
					
					//인증Key 마스터 Update
					Update validkeymst
					Set    status      = :ls_validkeystatus,
					       sale_flag   = '1',
							 activedt    = to_date(:ls_requestdt,'yyyy-mm-dd'),
							 customerid  = :ls_customerid,
							 orderno     = :ll_orderno,
							 contractseq = :ll_contractseq,
							 updt_user   = :gs_user_id,
							 updtdt      = sysdate
					Where  validkey    = :ls_validkey[i]
					  and  validkey_type = ( select validkey_type from priceplan_validkey_type 
					                          where priceplan = :ls_priceplan) ;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(Validkeymst)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
				
					Insert Into validkeymst_log ( validkey, seq, status, actdt,
														   customerid, contractseq, partner, crt_user,
														   crtdt, pgm_id )
												Values ( :ls_validkey[i], seq_validkeymstlog.nextval, :ls_validkeystatus, to_date(:ls_requestdt,'yyyy-mm-dd'),
														   :ls_customerid, :ll_contractseq, :ls_reg_partner, :gs_user_id,
														   sysdate, :ls_pgm_id );
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(Validkeymst_log)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
					
				End If
				
			Next
			
			//여기서 commit을 해야지만 처리결과를 알수가 있다.(server에 validinfoserver trigger가 실행되어야 하므로)
			Commit;
		
			//개통처리까지 한 경우 - 대기초 후에 validinfoserver(h)정보를 읽어 와서 GK에 인증KEY가 
			//바로 처리 되었는지 결과를 바로 보여준다.
			If is_data[3] = 'Y' and is_data[9] = 'N' Then
				//개통처리 결과 대기 초
				ll_result_sec = Long(fs_get_control("B1", "P100", ls_ref_desc))
		
				lt_now_time = Time(fdt_get_dbserver_now())
				lt_after_time = relativetime(lt_now_time, ll_result_sec)
	
			   do while lt_now_time < lt_after_time
				   lt_now_time = Time(fdt_get_dbserver_now())
				LOOP
			
				For i =1 To UpperBound(ls_validkey[])
					
					ls_result = ls_result_code[1]
						 
					If ls_coid = "*" Then
						Select result
						  Into :ls_result
						  From ( Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
									  From validinfoserver
								    Union
									Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
									  From validinfoserverh
								    Where to_char(cworkdt,'yyyymmdd') = :ls_requestdt ) vs
								   Where vs.validkey = :ls_validkey[i]
									and vs.cworkdt = :ls_requestdt;
								  
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select result(Validinfoserver)1")
							ii_rc = -3
							RollBack;
							Return 
						End If					 
					Else 
						Select result
						  Into :ls_result
						  From ( Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
									  From validinfoserver Where coid = :ls_coid									  
									 Union
									Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
									  From validinfoserverh
									 Where to_char(cworkdt,'yyyymmdd') = :ls_requestdt 
									   and coid = :ls_coid ) vs
									Where vs.validkey = :ls_validkey[i]
									  and vs.cworkdt = :ls_requestdt;
								  
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select result(Validinfoserver)2")
							ii_rc = -3
							RollBack;
							Return 
							End If					 
						End If	
											 
						idw_data[3].object.act_result[i] = ls_result
						idw_data[3].SetItemStatus(i, 0, Primary!, NotModified!)
				
				Next	
			
			End If	
		End if
		
		ll_cnt = 0
		//할부품목이 있는지 체크하여 svcorder의 상태 변경.
		For i = 1 To idw_data[2].Rowcount()
			ls_quota_yn     = Trim(idw_data[2].object.quota_yn[i])
			ls_chk_yn = Trim(idw_data[2].object.chk[i])
			If (ls_quota_yn = 'Y' or ls_quota_yn = 'R') and ls_chk_yn = 'Y' Then
				ll_cnt ++
			End If
		Next
		
		If ll_cnt > 0 Then
			Update svcorder
				Set status = :ls_quota_status,
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id					 
			 Where orderno = :ll_orderno;
				
			If SQLCA.SQLCode <> 0 Then
				RollBack;
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table(STATUS)")				
				Return 
			End If
		End If
		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_02 ();//b1w_reg_svc_actorder_pre_2%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_validkeyloc[], ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item           
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result 
string ls_validkey_loc, ls_coid, ls_temp, ls_result_code[], ls_pricemodel, ls_refilltype[], ls_langtype, ls_remark
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec, ll_endday, ll_rows
Time lt_now_time, lt_after_time    
Decimal ldc_first_refill_amt, ldc_first_sale_amt
String ls_quota_yn, ls_chk_yn, ls_quota_status, ls_validkeystatus
String ls_n_auth_method[],	ls_n_langtype[], ls_n_validitem2[], ls_n_validitem3[], ls_n_validitem1[]
Date   ld_enddt, ld_bil_fromdt
	
String ls_prebil_yn, ls_oneoffcharge_yn, ls_itemcod1, ls_validloc_gu, ls_day, ls_direct_paytype
String ls_sale_prefix, ls_level_code, ls_partner_main
Long   ll_validity_term, ll_i, ll_len
Decimal ldc_unitcharge, ldc_payamt, ldc_price, ldc_rate_first, ldc_basic_fee_first, ldc_basic_rate_first
Date   ld_salemonth, ld_inputclosedt
Boolean lb_flag = False

//2005.04.06 juede 인증키분리-------start
String ls_validkey1[], ls_validkey2[], ls_validkey3[], ls_validkey4[]
//2005.04.06 juede -------------------end

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre_3_aun%save"    //선불제(선납포함) - 장비모듈 추가, 인증KeyLocation 필수 체크 포함.
//		lu_dbmgr.is_caller = "b1w_reg_svc_actorder_pre%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_cond
//		lu_dbmgr.idw_data[2] = dw_detail2 			 	//품목
//		lu_dbmgr.idw_data[3] = dw_detail             	//인증Key
//		lu_dbmgr.is_data[1] = gs_user_id			
//		lu_dbmgr.is_data[2] = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[3] = is_act_gu        			//개통처리 check
//		lu_dbmgr.is_data[4] = is_cus_status   	 		//고객상태
//		lu_dbmgr.is_data[5] = is_svctype      			//svctype
//		lu_dbmgr.is_data[6] = string(il_validkey_cnt)    //인증KEY갯수
//		lu_dbmgr.is_data[7] = is_xener_svc  			 //xener svc 여부

		// SYSCTL1T의 사업자 ID
		ls_ref_desc = ""
		ls_coid = fs_get_control("00","G200", ls_ref_desc)

		//작업결과(Server인증Key) 코드 
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","P300", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_result_code[])
		
		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])

		//2005.02.14 ohj  validkey_loc 관리
		ls_ref_desc = ""
		ls_validloc_gu  = fs_get_control("00","Z400", ls_ref_desc)
		
		ls_customerid = Trim(idw_data[1].object.customerid[1])
		ls_customerm = Trim(idw_data[1].object.customernm[1])
		ls_orderdt = String(idw_data[1].object.orderdt[1],'yyyymmdd')
		ls_requestdt = String(idw_data[1].object.requestdt[1], 'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svccod[1])
		ls_priceplan = Trim(idw_data[1].object.priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.sale_partner[1])
		ls_partner = Trim(idw_data[1].object.partner[1])
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_gkid = Trim(idw_data[1].object.gkid[1])
		ls_validkey_loc = Trim(idw_data[1].object.validkey_loc[1])		
		ls_auth_method = Trim(idw_data[1].object.auth_method[1])
		ls_h323id = Trim(idw_data[1].object.h323id[1])
		ls_ip_address = Trim(idw_data[1].object.ip_address[1])
		ls_langtype = Trim(idw_data[1].object.langtype[1])
		ls_remark = Trim(idw_data[1].object.remark[1])		
		ls_maintain_partner = Trim(idw_data[1].object.maintain_partner[1])		
		ls_userid = is_data[1]
		ls_pgm_id = is_data[2]
		ls_direct_paytype= Trim(idw_data[1].object.direct_paytype[1])
		
		ls_pricemodel = Trim(idw_data[1].object.pricemodel[1])
		ldc_first_refill_amt  = idw_data[1].object.first_refill_amt[1]
		ldc_first_sale_amt = idw_data[1].object.first_sale_amt[1]
		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""

		If IsNull(ldc_first_refill_amt) Then ldc_first_refill_amt = 0
		If IsNull(ldc_first_sale_amt) Then ldc_first_sale_amt = 0
		
		//2004-12-08 kem 추가
		ld_enddt      = idw_data[1].Object.enddt[1]
		//ll_endday     = idw_data[1].Object.endday[1]
		ld_bil_fromdt = idw_data[1].Object.bil_fromdt[1]
		
		
		ls_ref_desc = ""
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		 
		//개통신청상태코드(단말기미등록)
		ls_quota_status = fs_get_control("B0", "P241", ls_ref_desc)

		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)		

		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		
		//납기일자
 		ls_day = fs_get_control("B1", "P601", ls_ref_desc)	
		 
//		modify : pkh  2003-09-29 중복 check 뻄...
//		//서비스 중복 신청 Check
//		//해지 상태가 아닌 같은 서비스 & 가격정책이 있으면 신청 중복 error
//		Select count(*)
//		Into :ll_cnt
//		From contractmst
//		Where customerid = :ls_customerid and svccod = :ls_svccod 
//		 and priceplan = :ls_priceplan and status <> :ls_term_status;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
//			Return 
//		End If		
//		
//		If ll_cnt <> 0 Then
//			ii_rc = -2
//			Return
//		End If
		
		//개통 신청 같은 서비스 & 가격정책이 있으면 신청 중복 error
		Select count(*)
		Into :ll_cnt
		From svcorder
		Where customerid = :ls_customerid and svccod = :ls_svccod 
		 and priceplan = :ls_priceplan and status = :ls_status;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
			Return 
		End If		
		
		If ll_cnt <> 0 Then
			ii_rc = -2
			Return
		End If
		
		If ls_reg_partner <> "" Then
			//대리점 Prefix
			Select prefixno
			Into :ls_reg_prefix
			From partnermst
			Where partner = :ls_reg_partner;
		End If
		
		If ls_sale_partner <> "" Then
			//매출대리점 Prefix
			Select prefixno
			  Into :ls_sale_prefix
			  From partnermst
			 Where partner = :ls_sale_partner;
		End If
		
		
		//신청 품목  check
		ll_row = idw_data[2].RowCount()
		j = 1
		For i = 1 To ll_row
		   ls_check[i] = Trim(idw_data[2].object.chk[i])
			If ls_check[i] = "Y" Then
				ls_itemcod[j] = Trim(idw_data[2].object.itemcod[i])
				j ++
			End If
		Next

		//인증KEY 갯수가 0보다 클때 입력한 인증KEY check
		If integer(is_data[6]) > 0 Then
			ll_row = idw_data[3].RowCount()
			For i = 1 To ll_row
				ls_validkey[i]    = Trim(idw_data[3].object.validkey[i])
				ls_vpasswd[i]     = Trim(idw_data[3].object.vpassword[i])
				ls_validkeyloc[i] = Trim(idw_data[3].object.validkey_loc[i])
				ls_n_auth_method[i] = Trim(idw_data[3].object.auth_method[i])
				
				//2005.04.06 juede anyusernet validkey 분리---------start
				ls_validkey1[i]	 = Trim(idw_data[3].object.validkey1[i])
				ls_validkey2[i]	 = Trim(idw_data[3].object.validkey2[i])
				ls_validkey3[i] 	 = Trim(idw_data[3].object.validkey3[i])
				ls_validkey4[i]	 = Trim(idw_data[3].object.validkey4[i])
				//2005.04.06 juede anyusernet validkey 분리---------end				
				
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""
				If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
				If IsNull(ls_validkeyloc[i]) Then ls_validkeyloc[i] = ""

				//2005.04.06 juede anyusernet validkey 분리---------start
		   	If IsNull(ls_validkey1[i]) Then ls_validkey1[i] = ""				
		   	If IsNull(ls_validkey2[i]) Then ls_validkey2[i] = ""				
		   	If IsNull(ls_validkey3[i]) Then ls_validkey3[i] = ""				
		   	If IsNull(ls_validkey4[i]) Then ls_validkey4[i] = ""												
				//2005.04.06 juede anyusernet validkey 분리---------end	
				
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, "인증KEY")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				//2005.04.06 juede anyusernet validkey 분리---------start
				If ls_validkey1[i] = "" Then
					f_msg_info(200, is_title, "국가코드")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey1")
					ii_rc = -3
					Return	
				End If
				
				If ls_validkey2[i] = "" Then
					f_msg_info(200, is_title, "국번")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey2")
					ii_rc = -3
					Return	
				End If
				
				If ls_validkey3[i] = "" Then
					f_msg_info(200, is_title, "지역")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey3")
					ii_rc = -3
					Return	
				End If	
				
				If ls_validkey4[i] = "" Then
					f_msg_info(200, is_title, "번호")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey4")
					ii_rc = -3
					Return	
				End If										
				//2005.04.06 juede anyusernet validkey 분리---------end			
				
//				If ls_vpasswd[i] = "" Then
//					f_msg_info(200, is_title, "인증Passwrod")
//					idw_data[3].SetRow(i)
//					idw_data[3].ScrollToRow(i)
//					idw_data[3].SetFocus()
//					idw_data[3].SetColumn("vpassword")
//					ii_rc = -3					
//					Return	
//				End If
				
				//입력한 인증KEY가 같은 인증 KEY가 있는지 check			
				CHOOSE CASE i
					CASE 1  // Row가 1행일때 
						IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", i + 1, ll_row)

					CASE ll_row // Row가 맨 마지막
						IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", 1, i -1)
						
					CASE ELSE	  
						IF  ll_row > 1 THEN
							ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", 1, i -1)
							IF  ll_long > 0 THEN
							else
								ll_long = idw_data[3].Find(" validkey = '" + ls_validkey[i] + "'", i + 1, ll_row)
							END IF
						END IF
				END CHOOSE
				
				If ll_long > 0 Then
					// messagebox(인증KEY중복)	
					f_msg_usr_err(9000, is_Title, "인증KEY가 중복됩니다.")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					return
				End if
				
				//인증KEY 중복 check  
				//적용시작일과 적용종료일의 중복일자를 막는다. 
				select count(*)
				  into :ll_cnt
				 from validinfo
				where  ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						  ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						    :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				   and validkey = :ls_validkey[i]
				   and svctype = :is_data[5];
						  
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
					Return 
				End If
				
				If ll_cnt > 0 Then
					f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					ii_rc = -3					
					return 
				End if
				
				ls_n_auth_method[i] = Trim(idw_data[3].object.auth_method[i])
				ls_n_langtype[i]   = Trim(idw_data[3].object.langtype[i])
				ls_n_validitem2[i] = idw_data[3].object.validitem2[i]
				ls_n_validitem3[i] = idw_data[3].object.validitem3[i]
				ls_n_validitem1[i] = idw_data[3].object.validitem1[i]
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""
				If IsNull(ls_n_langtype[i])   Then ls_n_langtype[i]   = ""
				If IsNull(ls_n_validitem2[i]) Then ls_n_validitem2[i] = ""				
				If IsNull(ls_n_validitem3[i]) Then ls_n_validitem3[i] = ""							
				If IsNull(ls_n_validitem1[i]) Then ls_n_validitem1[i] = ""		
			
				If ls_n_langtype[i] = "" Then
					f_msg_info(200, is_title, "멘트 언어")		
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("langtype")
					ii_rc = -3					
					Return 
				End If
				
				If ls_n_langtype[i] = "" Then
					f_msg_info(200, is_title, "인증방법")		
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("auth_method")
					ii_rc = -3					
					Return 
				End If
				
				//제너 연동.. 'Y/N'
				If is_data[7]  = 'Y' Then 
					If ls_n_auth_method[i] = "" Then
						f_msg_info(200, is_title, "Method of authentication")		
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetFocus()
						idw_data[3].SetColumn("auth_method")
						ii_rc = -3					
						Return 
					End If	
					
					//ohj 2005.02.21 인증방법에 따른 체크 추가
					If LeftA(ls_n_auth_method[i],1) = 'S' Then
						If ls_n_validitem2[i] = "" Then
							f_msg_info(200, is_title, "IP ADDRESS")
							idw_data[3].SetRow(i)
							idw_data[3].ScrollToRow(i)
							idw_data[3].SetFocus()
							idw_data[3].SetColumn("validitem2")
							Return
						End If		
					End if
					
					If MidA(ls_n_auth_method[i],7,1) = 'B' Then
						If ls_n_validitem3[i] = "" Then
							f_msg_info(200, is_title, "H323ID")
							idw_data[3].SetRow(i)
							idw_data[3].ScrollToRow(i)
							idw_data[3].SetFocus()
							idw_data[3].SetColumn("validitem3")
							Return
						End If		
					End IF

					//패스워드 인증일때 
					If LeftA(ls_n_auth_method[i], 1) = 'P' Then
						If ls_vpasswd[i] = "" Then
							f_msg_info(200, is_title, "Valid Passwrod")
							idw_data[3].SetRow(i)
							idw_data[3].ScrollToRow(i)
							idw_data[3].SetFocus()
							idw_data[3].SetColumn("vpassword")
							ii_rc = -3					
							Return	
						End If
					End If
					
				End If
				
				// validkey_loc 관리 추가 
				If ls_validloc_gu = 'L' Then
					If ls_validkeyloc[i] = "" Then
						f_msg_info(200, is_title, "인증KeyLocation")
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetFocus()
						idw_data[3].SetColumn("validkey_loc")
						ii_rc = -3					
						Return	
					End If
				End If
				//ohj 끝
				
			Next
		End If
			
		//Order Sequence
		Select seq_orderno.nextval
		Into :ll_orderno
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, " Sequence Error")
			RollBack;
			ii_rc = -1				
			Return 
		End If		

		setnull(ll_contractseq)
        //개통처리까지 check일 경우 : 개통처리까지 하는지 여부에 따라 status/사용여부가 바뀐다.
		If is_data[3] = 'Y' Then
			
			//contractseq 가져 오기
			Select seq_contractseq.nextval
			Into :ll_contractseq
			From dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
				ii_rc = -1			
				RollBack;
				Return 
			End If	
			
			ls_use_yn = 'Y'
		Else
		  	ls_act_status = ls_status
			ls_use_yn = 'N'
		End If
		
		il_data[1] = ll_orderno		//ordernumber 넘겨줌
		
		//svccod insert
		Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt,
					status, svccod, priceplan, prmtype, reg_partner, sale_partner, maintain_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id,
					pricemodel, first_refill_amt, first_sale_amt, remark,
					enddt, bil_fromdt, DIRECT_PAYTYPE)//, endday, bil_fromdt)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner,
				 :ls_partner, :ll_contractseq, :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id,
				 :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :ls_remark,
				 :ld_enddt, :ld_bil_fromdt, :ls_direct_paytype);//, :ll_endday, :ld_bil_fromdt);
							
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SVCORDER)")
			ii_rc = -1				
			RollBack;
			Return 
		End If

		If is_data[3]='Y' Then
			
			//2005-08-08 Modify kem  Start
			//선불제 충전정책 판매금액 및 기본료 계산 후 적용
			//선불 모델에 따른 충전금액 결정
			Select nvl(price,0)
			  Into :ldc_price
			  From salepricemodel
			 where pricemodel  = :ls_pricemodel;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT price from salepricemodel")
				RollBack;
				Return
			End If	
	
	
			//1. 해당 Partner, 해당 Priceplan
			Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
			  From refillpolicy
			 where partner = :ls_sale_partner  
				and priceplan = :ls_priceplan 
				and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																  from refillpolicy 
																 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																	and partner   = :ls_sale_partner  
																	and priceplan = :ls_priceplan )
		 	   and fromamt <= :ldc_price
		 	   and nvl(toamt, :ldc_price) >= :ldc_price ;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
				RollBack;
				Return
				
			ElseIf SQLCA.SQLCode  = 100 Then
				lb_flag = False
				
			Else
				lb_flag = True
				
			End If
			
			//1.5 해당 Partner의 관리대상 Level Partner, 해당 Priceplan
			//관리대상 레벨 코드 A1 C100
			ls_level_code = fs_get_control("A1", "C100", ls_ref_desc)
			
			// 관리 대상대리점 prefixno  length  가져오기
			SELECT LENGTH(MAX(PREFIXNO))  
			  INTO :ll_len
			  FROM PARTNERMST  
			 WHERE LEVELCOD = :ls_level_code;
			 
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(partnermst) prefixno max length select error")
				RollBack;
				Return
			End If
			
			Select partner
			  Into :ls_partner_main
			  from partnermst
			 Where prefixno = substr(:ls_sale_prefix, 1, :ll_len);
			 
			If sqlca.sqlcode < 0 then
				f_msg_sql_err(is_title, is_caller + "Select Error(PARTNERmst)-관리대상대리점" )
				RollBack;
				Return
			End If
			
			If lb_flag = False Then
						
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
				  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_partner_main  
					and priceplan = :ls_priceplan 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_partner_main  
																		and priceplan = :ls_priceplan )
					and fromamt <= :ldc_price
					and nvl(toamt, :ldc_price) >= :ldc_price ;
	
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
					RollBack;
					Return
					
				ElseIf SQLCA.SQLCode  = 100 Then
					lb_flag = False
					
				Else
					lb_flag = True
					
				End If
			
			End If
		
			//2. 해당 Partner, 'ALL' Priceplan
			If lb_flag = False Then
				
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			     Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_partner_main  
					and priceplan = 'ALL' 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_partner_main  
																		and priceplan = 'ALL' )
					and fromamt <= :ldc_price
					and nvl(toamt, :ldc_price) >= :ldc_price ;
	
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
					RollBack;
					Return
					
				ElseIf SQLCA.SQLCode  = 100 Then
					lb_flag = False
						
				Else
					lb_flag = True
					
				End If
			
			End If
			
			//3. 'ALL' Partner, 'ALL' Priceplan
			If lb_flag = False Then
				
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			     Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = 'ALL'  
					and priceplan = 'ALL' 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = 'ALL'  
																		and priceplan = 'ALL' )
					and fromamt <= :ldc_price
					and nvl(toamt, :ldc_price) >= :ldc_price ;
	
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
					RollBack;
					Return
					
				ElseIf SQLCA.SQLCode  = 100 Then
//					ldc_first_refill_amt = ldc_price
//					ldc_first_sale_amt   = ldc_price
					f_msg_usr_err(9000, is_title, is_caller + "해당 충전정책이 정의되지 않았습니다.")
					RollBack;
					Return
						
				Else
					lb_flag = True
					
				End If
			
			End If
			
			If lb_flag = True Then
				ldc_first_refill_amt = ldc_price
				ldc_first_sale_amt   = ldc_price
				
				//판매가 적용
				If ldc_rate_first = 0 Then
					ldc_first_sale_amt = ldc_price
				Else
					ldc_first_sale_amt = ldc_price * ldc_rate_first/100
				End If
				
				//dw_cond 판매가 셋팅
				idw_data[1].Object.first_sale_amt[1] = ldc_first_sale_amt
				
				//Balance 적용가
				If ldc_basic_rate_first = 0 Then
					ldc_first_refill_amt = ldc_price
				Else
					ldc_first_refill_amt = ldc_price * (100 - ldc_basic_rate_first)/100
				End If
				
				If ldc_basic_fee_first = 0 Then
					ldc_first_refill_amt = ldc_first_refill_amt
				Else
					ldc_first_refill_amt = ldc_first_refill_amt - ldc_basic_fee_first
				End If
				
			End If
			
			
			//Insert contractmst
			insert into contractmst
				( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
				   prmtype, reg_partner, sale_partner,partner, maintain_partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
				   pricemodel, refillsum_amt, salesum_amt, balance, 
				   first_refill_amt, first_sale_amt, last_refill_amt, last_refilldt,
					enddt, direct_paytype) //, endday)
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner, :ls_maintain_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), :ld_bil_fromdt, null, null, null, :ls_contractno,
				   :gs_user_id, sysdate, :ls_pgm_id, :gs_user_id, sysdate, :ls_reg_prefix,
				   :ls_pricemodel, :ldc_price, :ldc_first_sale_amt, :ldc_first_refill_amt,
				   :ldc_price, :ldc_first_sale_amt, :ldc_price, to_date(:ls_requestdt,'yyyy-mm-dd'),
					:ld_enddt, :ls_direct_paytype);//, :ll_endday);
				   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
				Return 
			End If	
			//Insert contractmst
			insert into refilllog
				(  refillseq, contractseq, customerid, refilldt, 
				   refill_type, refill_amt, sale_amt, basicamt,
				   remark, partner_prefix, crtdt, crt_user)
			values ( seq_refilllogseq.nextval, :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), 
				   :ls_refilltype[1], :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt,
				   '최초충전', :ls_sale_prefix, sysdate, :gs_user_id);
				   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(refilllog)")
				Return 
			End If	

//			//해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
			//가입상태
			ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)
			If is_data[4] = ls_term_status Then
				
				Update customerm
				Set status = :ls_enter_status,
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id					 
				Where customerid = :ls_customerid;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					ii_rc = -1
					f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
					Return 
				End If
				
			End If		
				   
		End If
		
		//contractdet insert
	    For i =1 To UpperBound(ls_itemcod[])
			Insert Into contractdet(orderno, itemcod, contractseq)
			    Values(:ll_orderno, :ls_itemcod[i], :ll_contractseq);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACDET)")
				ii_rc = -1					
				RollBack;
				Return 
			End If
		Next
		
		If integer(is_data[6]) > 0  Then
			
			//validinfo insert
			For i =1 To UpperBound(ls_validkey[])
				
				Insert Into validinfo
				    (validkey, fromdt, status, 
					 use_yn, vpassword, svctype,
					 gkid, customerid, svccod, priceplan, 
					 orderno, contractseq, langtype,
					 auth_method, validitem1, validitem2, validitem3,
					 crt_user, updt_user, crtdt, updtdt, pgm_id, validkey_loc)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_gkid, :ls_customerid, :ls_svccod, :ls_priceplan, 
					   :ll_orderno, :ll_contractseq, :ls_n_langtype[i],
					   :ls_n_auth_method[i], :ls_n_validitem1[i], :ls_n_validitem2[i], :ls_n_validitem3[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id, :ls_validkeyloc[i]);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
					ii_rc = -1						
					RollBack;
					Return 
				End If
				
				//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------start
				Insert Into validinfo_sub
				    	(validkey, fromdt,svctype,
						 validkey1, validkey2, validkey3,validkey4,
						 crt_user, updt_user, crtdt, updtdt, pgm_id)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :is_data[5],
						:ls_validkey1[i], :ls_validkey2[i], :ls_validkey3[i], :ls_validkey4[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);	

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo_sub)")
					ii_rc = -1						
					RollBack;
					Return 
				End If												
				//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------end						
				
				If ii_data[1] > 0 Then   //가격정책별 인증Key Type이 존재할 경우 - 2004.06.03 kem
				
					ls_temp = fs_get_control("B1","P400", ls_ref_desc)
					If ls_temp = "" Then Return 
					fi_cut_string(ls_temp, ";" , ls_result_code[])
					
					//인증Key 관리상태(개통:20)
					ls_validkeystatus = ls_result_code[2]
					
					//인증Key 마스터 Update
					Update validkeymst
					Set    status      = :ls_validkeystatus,
					       sale_flag   = '1',
							 activedt    = to_date(:ls_requestdt,'yyyy-mm-dd'),
							 customerid  = :ls_customerid,
							 orderno     = :ll_orderno,
							 contractseq = :ll_contractseq,
							 updt_user   = :gs_user_id,
							 updtdt      = sysdate
					Where  validkey    = :ls_validkey[i];
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(Validkeymst)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
				
					Insert Into validkeymst_log ( validkey, seq, status, actdt,
														   customerid, contractseq, partner, crt_user,
														   crtdt, pgm_id )
												Values ( :ls_validkey[i], seq_validkeymstlog.nextval, :ls_validkeystatus, to_date(:ls_requestdt,'yyyy-mm-dd'),
														   :ls_customerid, :ll_contractseq, :ls_reg_partner, :gs_user_id,
														   sysdate, :ls_pgm_id );
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(Validkeymst_log)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
					
				End If
				
			Next
			
			//여기서 commit을 해야지만 처리결과를 알수가 있다.(server에 validinfoserver trigger가 실행되어야 하므로)
			Commit;
			
			//개통처리까지 한 경우 - 대기초 후에 validinfoserver(h)정보를 읽어 와서 GK에 인증KEY가 
			//바로 처리 되었는지 결과를 바로 보여준다.
			If is_data[3] = 'Y' Then
				//Serial Phone svccode는 interface 안 하므로 validinfoserver 정보 읽어올 필요없다.
				If is_data[7]  = 'N' Then
				
					ls_result = ''
					For i =1 To UpperBound(ls_validkey[])
				
						idw_data[3].object.act_result[i] = ls_result
						idw_data[3].SetItemStatus(i, 0, Primary!, NotModified!)
				
					Next	

				ElseIf is_data[7] = 'Y' Then
						//개통처리 결과 대기 초
						ll_result_sec = Long(fs_get_control("B1", "P100", ls_ref_desc))
				
						lt_now_time = Time(fdt_get_dbserver_now())
						lt_after_time = relativetime(lt_now_time, ll_result_sec)
		
					   do while lt_now_time < lt_after_time
						   lt_now_time = Time(fdt_get_dbserver_now())
					   LOOP
				
					   For i =1 To UpperBound(ls_validkey[])
					
							 ls_result = ls_result_code[1]
							 
							 //사업자 코드 없는 서비스는 "*"입력해야함...
							 If ls_coid = "*" Then							 
									  Select result
										Into :ls_result
										From ( Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
												From validinfoserver
											   Union
											   Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
												From validinfoserverh
											   Where to_char(cworkdt,'yyyymmdd') = :ls_requestdt ) vs
									  Where vs.validkey = :ls_validkey[i]
										and vs.cworkdt = :ls_requestdt;
									  
									 If SQLCA.SQLCode < 0 Then
										 f_msg_sql_err(is_title, is_caller + " Select result(Validinfoserver)1")
										 ii_rc = -3
										 RollBack;
										 Return 
									 End If					 
							Else 
								  Select result
									Into :ls_result
									From ( Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
											From validinfoserver Where coid = :ls_coid									  
										   Union
										   Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
											From validinfoserverh
										   Where to_char(cworkdt,'yyyymmdd') = :ls_requestdt 
											 and coid = :ls_coid ) vs
								  Where vs.validkey = :ls_validkey[i]
									and vs.cworkdt = :ls_requestdt;
								  
								 If SQLCA.SQLCode < 0 Then
									 f_msg_sql_err(is_title, is_caller + " Select result(Validinfoserver)2")
									 ii_rc = -3
									 RollBack;
									 Return 
								 End If					 
							End If		
							 
							idw_data[3].object.act_result[i] = ls_result						
							idw_data[3].SetItemStatus(i, 0, Primary!, NotModified!)
					
						Next	
				 End If
			End If
		End if
		
		
		//2004-12-08 kem 수정
		//선납품목이 있는 경우 선납판매정보 Insert
		long ll_addunit, ll_use
		string ls_bilfromdt,ls_method, ls_additem //ls_direct_paytype
		Date ldt_date_next, ldt_date_next_1
		
		//납부방식, 과금방식추가로 인한 로직추가  ohj 2005.03.18
		//납부방식  - 청구서발송방식, 직접입금방식
		
		For ll_rows = 1 To idw_data[2].RowCount()
			ls_check[ll_rows] = Trim(idw_data[2].object.chk[ll_rows])
			If ls_check[ll_rows] = "Y" Then
				ls_prebil_yn = Trim(idw_data[2].Object.prebil_yn[ll_rows])
				
				If IsNull(ls_prebil_yn) Then ls_prebil_yn = 'N'
				
				If ls_prebil_yn = 'Y' Then
					ls_itemcod1        = Trim(idw_data[2].Object.itemcod[ll_rows])
				   ls_oneoffcharge_yn = Trim(idw_data[2].Object.oneoffcharge_yn[ll_rows])
					ll_validity_term   = idw_data[2].Object.validity_term[ll_rows]
					
					//서비스별 요율등록에서 선납품목에 대한 정보 가져오기
					SELECT UNITCHARGE
					     , ADDUNIT
						  , METHOD
						  , NVL(ADDITEM, '') ADDITEM
					  INTO :ldc_unitcharge
					     , :ll_addunit
						  , :ls_method
						  , :ls_additem
					  FROM PRICEPLAN_RATE2
					 WHERE PRICEPLAN = :ls_priceplan
					   AND ITEMCOD   = :ls_itemcod1;
					
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						ii_rc = -1
						f_msg_sql_err(is_title, is_caller + " Select PRICEPLAN_RATE2 Table(UNITCHARGE)")				
						Return 
					End If
					
					If ls_oneoffcharge_yn = 'Y' Then
						ldc_payamt = Round(ldc_unitcharge / ll_validity_term, 0)
					Else
						ldc_payamt = ldc_unitcharge
					End If
				
					//사용가능일(월)
					ll_use        = ll_addunit	
					//첫째판매fr
					ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
					//첫째납기일
					ld_inputclosedt = fd_date_next(ld_bil_fromdt, long(ls_day)) 
					//첫째 판매to
					If ls_method = 'A' Then  //daily 정액
					
						ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_use)
						
						SELECT :ldt_date_next_1 -1 
						  INTO :ldt_date_next
						  FROM DUAL                 ;					
					
					ElseIf ls_method = 'M' Then //월정액
						
						SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_use) -1
						  INTO :ldt_date_next
						  FROM DUAL;
					End If							
				
					//납부방식에 따른 구분.. 청구서발송방식(100) = 첫달만 insert, 직접입금방식(200) = 사용기간수만큼 
					If ls_direct_paytype = '100' Then
										
						INSERT INTO PREPAYMENT ( seq, customerid, orderno, contractseq,
														 itemcod, salemonth, salefromdt, saletodt, sale_amt, inputclosedt, remark,
														 crt_user, updt_user, crtdt, updtdt, pgm_id)
											 VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
														 :ls_itemcod1, :ld_bil_fromdt, :ld_bil_fromdt, :ldt_date_next, :ldc_payamt,
														 :ld_inputclosedt, :ls_remark,
														 :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);
														 
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " INSERT Error(PREPAYMENT)")
							ii_rc = -1						
							RollBack;
							Return 
						End If						
					Else  //직접입금방식(200)

						For ll_i = 0 To ll_validity_term - 1
							If ll_i <> 0 Then
								//두번째 ROW부터는ADDITEM NOT NULL일때 ADDITEM으로...
								If ls_additem <> '' Then
									ls_itemcod1 = ls_additem
								End If
								
								ld_bil_fromdt = fd_date_next(ldt_date_next, 1)
								
								If ls_method = 'A' Then  //daily 정액
								
									ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_use)
									
									SELECT :ldt_date_next_1 -1 
									  INTO :ldt_date_next
									  FROM DUAL                 ;									
									
								ElseIf ls_method = 'M' Then //월정액
									ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
									
									SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_use) -1
									  INTO :ldt_date_next
									  FROM DUAL;
								End If	

								ld_inputclosedt = fd_date_next(ld_bil_fromdt, long(ls_day))			
							End If
							
						INSERT INTO PREPAYMENT ( seq, customerid, orderno, contractseq,
														 itemcod, salemonth, salefromdt, saletodt, sale_amt, inputclosedt, remark,
														 crt_user, updt_user, crtdt, updtdt, pgm_id)
											 VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
														 :ls_itemcod1, :ld_bil_fromdt, :ld_bil_fromdt, :ldt_date_next, :ldc_payamt,
														 :ld_inputclosedt, :ls_remark,
														 :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);
															 
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " INSERT Error(PREPAYMENT)")
								ii_rc = -1						
								RollBack;
								Return 
							End If
							
						Next
					End If
										
				End If
			End If
		Next		
		
//		For ll_rows = 1 To idw_data[2].RowCount()
//			ls_check[ll_rows] = Trim(idw_data[2].object.chk[ll_rows])
//			If ls_check[ll_rows] = "Y" Then
//				ls_prebil_yn = Trim(idw_data[2].Object.prebil_yn[ll_rows])
//				
//				If IsNull(ls_prebil_yn) Then ls_prebil_yn = 'N'
//				
//				If ls_prebil_yn = 'Y' Then
//					ls_itemcod1 = Trim(idw_data[2].Object.itemcod[ll_rows])
//				   ls_oneoffcharge_yn = Trim(idw_data[2].Object.oneoffcharge_yn[ll_rows])
//					ll_validity_term   = idw_data[2].Object.validity_term[ll_rows]
//					
//					//서비스별 요율등록에서 선납품목에 대한 금액 가져오기
//					SELECT UNITCHARGE
//					  INTO :ldc_unitcharge
//					  FROM PRICEPLAN_RATE2
//					 WHERE PRICEPLAN = :ls_priceplan
//					   AND ITEMCOD   = :ls_itemcod1;
//					
//					If SQLCA.SQLCode <> 0 Then
//						RollBack;	
//						ii_rc = -1
//						f_msg_sql_err(is_title, is_caller + " Select PRICEPLAN_RATE2 Table(UNITCHARGE)")				
//						Return 
//					End If
//					
//					If ls_oneoffcharge_yn = 'Y' Then
//						ldc_payamt = Round(ldc_unitcharge / ll_validity_term, 0)
//					Else
//						ldc_payamt = ldc_unitcharge
//					End If
//					
//					
//					For ll_i = 0 To ll_validity_term - 1
//						If ll_i = 0 Then
//							ld_salemonth = ld_bil_fromdt
//							ld_inputclosedt = Date(String(ld_salemonth,'yyyy-mm-') + String(ll_endday, '00'))
//						Else
//							ld_salemonth = fd_month_next(ld_bil_fromdt, ll_i)
//							ld_inputclosedt = Date(String(ld_salemonth,'yyyy-mm-') + String(ll_endday, '00'))
//						End If
//						
//						INSERT INTO PREPAYMENT ( seq, customerid, orderno, contractseq,
//														 itemcod, salemonth, sale_amt, paytype,
//														 paydt, payamt, inputclosedt, remark,
//														 crt_user, updt_user, crtdt, updtdt, pgm_id)
//											 VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
//														 :ls_itemcod1, :ld_salemonth, :ldc_payamt, null,
//														 null, :ldc_payamt, :ld_inputclosedt, :ls_remark,
//														 :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);
//														 
//						If SQLCA.SQLCode < 0 Then
//							f_msg_sql_err(is_title, is_caller + " INSERT Error(PREPAYMENT)")
//							ii_rc = -1						
//							RollBack;
//							Return 
//						End If
//						
//					Next
//										
//				End If
//			End If
//		Next
		
		
		ll_cnt = 0
		//할부품목이 있는지 체크하여 svcorder의 상태 변경.
		For i = 1 To idw_data[2].Rowcount()
			ls_quota_yn     = Trim(idw_data[2].object.quota_yn[i])
			ls_chk_yn = Trim(idw_data[2].object.chk[i])
			If (ls_quota_yn = 'Y' or ls_quota_yn = 'R') and ls_chk_yn = 'Y' Then
				ll_cnt ++
			End If
		Next
		
		If ll_cnt > 0 Then
			Update svcorder
				Set status = :ls_quota_status,
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id					 
			 Where orderno = :ll_orderno;
				
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table(STATUS)")				
				Return 
			End If
		End If
	
	
	Case "b1w_reg_prepayment_pop%getdata"
//		lu_dbmgr.is_data[1] = is_orderno
//		lu_dbmgr.is_data[2] = is_customerid
      
		//Svcorder
		Select svccod, priceplan, to_char(orderdt, 'yyyymmdd'), status
		  Into :is_data[3], :is_data[4], :is_data[5], :is_data[6]
		  From svcorder
		 Where to_char(orderno) = :is_data[1]
		   And customerid = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
			Return 
		End If
		
End Choose

ii_rc = 0

Return 
end subroutine

public subroutine uf_prc_db_04 ();/*************************************************************
/ 2005.04.06 juede 서비스 신청 개통 처리 (선불제) : AnyUserNet
**************************************************************/

//"b1w_reg_svc_actprc_pre_2_aun%save"
String ls_ref_desc, ls_temp, ls_status, ls_customerid, ls_priceplan, ls_prmtype
String ls_refilltype[], ls_pricemodel, ls_cus_status, ls_activedt, ls_svccod
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_partner, ls_orderdt, ls_requestdt, ls_contractno, ls_reg_prefixno
String ls_remark, ls_bil_fromdt, ls_pgm_id, ls_term_status, ls_enter_status
String ls_reqactive, ls_validkey, ls_todt_tmp, ls_svctype, ls_enddt, ls_direct_paytype
Decimal{2} ldc_first_refill_amt, ldc_first_sale_amt
Dec{0} ldc_contractseq, ldc_orderno, ldc_price, ldc_rate_first, ldc_basic_fee_first, ldc_basic_rate_first
String ls_hotbillflag, ls_sale_prefix, ls_level_code, ls_partner_main
DateTime ldt_crtdt
Long ll_row, ll_cnt, ll_len
Boolean lb_flag = False

//2005.04.06 juede anyusernet 인증키분리 추가--------- start
Date ld_fromdt
Long ll_validkey_cnt
//2005.04.06 juede anyusernet -------------------------- end

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actprc_pre_2_aun%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_pre_2%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])

		//contractseq 가져 오기
		Select seq_contractseq.nextval
		Into :ldc_contractseq
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		idw_data[1].object.contractseq[1] = string(ldc_contractseq)
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt = STring(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt = STring(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		ls_enddt = String(idw_data[1].object.svcorder_enddt[1],'yyyymmdd')
		ls_direct_paytype = idw_data[1].object.direct_paytype[1]
		
		ls_pricemodel = Trim(idw_data[1].object.svcorder_pricemodel[1])
		ldc_first_refill_amt  = idw_data[1].object.svcorder_first_refill_amt[1]
		ldc_first_sale_amt = idw_data[1].object.svcorder_first_sale_amt[1]
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_cus_status) Then ls_cus_status = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""						
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_requestdt) Then ls_requestdt = ""						
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		If IsNull(ls_contractno) Then ls_contractno = ""
		If IsNull(ls_direct_paytype) Then ls_direct_paytype = ""		
		
		If IsNull(ls_pricemodel) Then ls_pricemodel = ""
		If IsNull(ldc_first_refill_amt) Then ldc_first_refill_amt = 0
		If IsNull(ldc_first_sale_amt) Then ldc_first_sale_amt = 0
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		
		//2005-08-08 Modify kem  Start
		//선불제 충전정책 판매금액 및 기본료 계산 후 적용
		//선불 모델에 따른 충전금액 결정
		Select nvl(price,0)
		  Into :ldc_price
		  From salepricemodel
		 where pricemodel  = :ls_pricemodel;
	
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT price from salepricemodel")
			RollBack;
			Return
		End If	

		If ls_sale_partner <> "" Then
			//매출대리점 Prefix
			Select prefixno
			  Into :ls_sale_prefix
			  From partnermst
			 Where partner = :ls_sale_partner;
		End If
		
		//1. 해당 Partner, 해당 Priceplan
		Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
		  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
		  From refillpolicy
		 where partner = :ls_sale_partner  
			and priceplan = :ls_priceplan 
			and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
															  from refillpolicy 
															 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																and partner   = :ls_sale_partner  
																and priceplan = :ls_priceplan )
			and fromamt <= :ldc_price
			and nvl(toamt, :ldc_price) >= :ldc_price ;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
			RollBack;
			Return
			
		ElseIf SQLCA.SQLCode  = 100 Then
			lb_flag = False
			
		Else
			lb_flag = True
			
		End If
		
		//1.5 해당 Partner의 관리대상 Level Partner, 해당 Priceplan
		//관리대상 레벨 코드 A1 C100
		ls_level_code = fs_get_control("A1", "C100", ls_ref_desc)
		
		// 관리 대상대리점 prefixno  length  가져오기
		SELECT LENGTH(MAX(PREFIXNO))  
		  INTO :ll_len
		  FROM PARTNERMST  
		 WHERE LEVELCOD = :ls_level_code;
		 
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(partnermst) prefixno max length select error")
			RollBack;
			Return
		End If
		
		Select partner
		  Into :ls_partner_main
		  from partnermst
		 Where prefixno = substr(:ls_sale_prefix, 1, :ll_len);
		 
		If sqlca.sqlcode < 0 then
			f_msg_sql_err(is_title, is_caller + "Select Error(PARTNERmst)-관리대상대리점" )
			RollBack;
			Return
		End If
		
		If lb_flag = False Then
		
			Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
			  From refillpolicy
			 where partner = :ls_partner_main  
				and priceplan = :ls_priceplan 
				and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																  from refillpolicy 
																 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																	and partner   = :ls_partner_main  
																	and priceplan = :ls_priceplan )
				and fromamt <= :ldc_price
				and nvl(toamt, :ldc_price) >= :ldc_price ;
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
				RollBack;
				Return
				
			ElseIf SQLCA.SQLCode  = 100 Then
				lb_flag = False
				
			Else
				lb_flag = True
				
			End If
		End If
		
		//2. 해당 Partner, 'ALL' Priceplan
		If lb_flag = False Then
			
			Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
			  From refillpolicy
			 where partner = :ls_partner_main  
				and priceplan = 'ALL' 
				and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																  from refillpolicy 
																 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																	and partner   = :ls_partner_main  
																	and priceplan = 'ALL' )
				and fromamt <= :ldc_price
				and nvl(toamt, :ldc_price) >= :ldc_price ;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
				RollBack;
				Return
				
			ElseIf SQLCA.SQLCode  = 100 Then
				lb_flag = False
					
			Else
				lb_flag = True
				
			End If
		
		End If
		
		//3. 'ALL' Partner, 'ALL' Priceplan
		If lb_flag = False Then
			
			Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
			  From refillpolicy
			 where partner = 'ALL'  
				and priceplan = 'ALL' 
				and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																  from refillpolicy 
																 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																	and partner   = 'ALL'  
																	and priceplan = 'ALL' )
				and fromamt <= :ldc_price
				and nvl(toamt, :ldc_price) >= :ldc_price ;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
				RollBack;
				Return
				
			ElseIf SQLCA.SQLCode  = 100 Then
//				ldc_first_refill_amt = ldc_price
//				ldc_first_sale_amt   = ldc_price
				f_msg_usr_err(9000, is_title, is_caller + "해당 충전정책이 정의되지 않았습니다.")
				RollBack;
				Return
					
			Else
				lb_flag = True
				
			End If
		
		End If
		
		If lb_flag = True Then
			ldc_first_refill_amt = ldc_price
			ldc_first_sale_amt   = ldc_price
			
			//판매가 적용
			If ldc_rate_first = 0 Then
				ldc_first_sale_amt = ldc_price
			Else
				ldc_first_sale_amt = ldc_price * ldc_rate_first/100
			End If
			
			//Balance 적용가
			If ldc_basic_rate_first = 0 Then
				ldc_first_refill_amt = ldc_price
			Else
				ldc_first_refill_amt = ldc_price * (100 - ldc_basic_rate_first)/100
			End If
			
			If ldc_basic_fee_first = 0 Then
				ldc_first_refill_amt = ldc_first_refill_amt
			Else
				ldc_first_refill_amt = ldc_first_refill_amt - ldc_basic_fee_first
			End If
			
		End If
		
		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
			   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
			   pricemodel, refillsum_amt, salesum_amt, balance, 
			   first_refill_amt, first_sale_amt, last_refill_amt, last_refilldt,
				enddt, direct_paytype)
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno,
			   :ls_pricemodel, :ldc_price, :ldc_first_sale_amt, :ldc_first_refill_amt,
			   :ldc_price, :ldc_first_sale_amt, :ldc_price, to_date(:ls_activedt,'yyyy-mm-dd'),
				to_date(:ls_enddt,'yyyy-mm-dd'), :ls_direct_paytype);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			Return 
		End If	
			
		//Insert refilllog
		insert into refilllog
			(  refillseq, contractseq, customerid, refilldt, 
			   refill_type, refill_amt, sale_amt, basicamt,
			   remark, partner_prefix, crtdt, crt_user)
		values ( seq_refilllogseq.nextval, :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), 
			   :ls_refilltype[1], :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt,
			   '최초충전', :ls_sale_prefix, sysdate, :gs_user_id);
			   
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(refilllog)")
			Return 
		End If	

			
		// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
		//해지상태
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		//가입상태
		ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)

		If ls_cus_status = ls_term_status Then
			
			Update customerm
			Set status = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt = :ldt_crtdt
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]

		Update svcorder
		Set status = :ls_status,
		    ref_contractseq = :ldc_contractseq,
			remark = :ls_remark,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
				
		Update contractdet
		Set contractseq = :ldc_contractseq
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
			Return 
		End If

		Update quota_info
		Set contractseq = :ldc_contractseq,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If

		//Valid Key Update
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		

		DECLARE cur_validkey_check1 CURSOR FOR
			Select validkey, to_char(fromdt,'yyyymmdd'), svctype
			  From validinfo
			Where orderno = :ldc_orderno;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check1")				
				Return 
			End If

		OPEN cur_validkey_check1;
		Do While(True)
			FETCH cur_validkey_check1
			Into :ls_validkey, :ls_todt_tmp, :ls_svctype;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check1")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ll_cnt = 0
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					  ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
						:ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey
			   and  to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and  svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
				Return 
			End If
			
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check1;
		
		Update validinfo
		Set  fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			 use_yn = 'Y',												//사용여부
			 status = :ls_status,
			 contractseq = :ldc_contractseq,
			 svccod = :ls_svccod,
       	 priceplan = :ls_priceplan,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;			 
//		Where customerid = :ls_customerid and status = :ls_reqactive and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If
		
		//validinfo_sub update  2005.04.06 juede anyusernet ---------------------------start			  
		SELECT count(*)
		INTO :ll_validkey_cnt
		FROM validinfo
		WHERE orderno = :ldc_orderno;
		
		If ll_validkey_cnt >0  Then
		
			DECLARE validinfo_key CURSOR FOR
				Select validkey, fromdt,svctype
				From   validinfo
				Where  orderno = :ldc_orderno;
			
			OPEN validinfo_key;
			
			Do While(True)
				FETCH validinfo_key INTO :ls_validkey, :ld_fromdt,:ls_svctype;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Select Error(VALIDINFO_VALIDKEY)")
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If		
				
				Update validinfo_sub
					Set fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
						 updt_user = :gs_user_id,
							 updtdt = :ldt_crtdt,
							 pgm_id = :ls_pgm_id
				 Where validkey = :ls_validkey
				  AND  fromdt = :ld_fromdt
				  AND  svctype = :ls_svctype;
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If			  
							
				
			Loop					
			CLOSE validinfo_key;			
			
		Else
				SELECT validkey, fromdt, svctype
				INTO   :ls_validkey, :ld_fromdt, :ls_svctype
				FROM   validinfo
				WHERE  orderno = :ldc_orderno;
								
			
				Update validinfo_sub
					Set fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
						 updt_user = :gs_user_id,
							 updtdt = :ldt_crtdt,
							 pgm_id = :ls_pgm_id
				 Where validkey = :ls_validkey
				  AND  fromdt = :ld_fromdt
				  AND  svctype = :ls_svctype;
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If			  
			  
		End If
		//validinfo_sub update  2005.04.06 juede anyusernet -------------------------------end		
		
		//가격정책별 인증Key Type에 해당하는 validkey 인 경우(2004.06.03 김은미 추가)
		Update validkeymst
		Set    contractseq = :ldc_contractseq,
		       activedt    = to_date(:ls_activedt,'yyyy-mm-dd')
		Where  orderno     = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")				
			Return 
		End If
		
		
		//선납판매정보가 있는 경우 신청번호에 해당하는 Data Update(2004.12.10 김은미 추가)
		Update prepayment
		Set    contractseq = :ldc_contractseq,
		       updt_user   = :gs_user_id,
				 updtdt      = sysdate
		Where  orderno     = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update PREPAYMENT Table")				
			Return 
		End If
		
		
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")
		
		
End Choose
ii_rc = 0
Return 
end subroutine

on b1u_dbmgr13.create
call super::create
end on

on b1u_dbmgr13.destroy
call super::destroy
end on

