$PBExportHeader$b1u_dbmgr_v20.sru
$PBExportComments$[parkkh] DBmanager
forward
global type b1u_dbmgr_v20 from u_cust_a_db
end type
end forward

global type b1u_dbmgr_v20 from u_cust_a_db
end type
global b1u_dbmgr_v20 b1u_dbmgr_v20

forward prototypes
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_04 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_03 ();String   ls_payid, ls_hotbillflag, ls_ref_desc, ls_status, ls_customerid, ls_cus_status     , &
         ls_activedt, ls_svccod, ls_priceplan, ls_prmtype, ls_reg_partner, ls_sale_partner  , &
		   ls_maintain_partner, ls_partner, ls_settle_partner, ls_orderdt, ls_requestdt       , &
		   ls_bil_fromdt, ls_contractno, ls_reg_prefixno, ls_remark, ls_pgm_id, ls_term_status, &
		   ls_enter_status, ls_dlvstat, ls_validkey, ls_todt_tmp, ls_svccod_1, ls_levelcod    , &
			ls_refilltype[], ls_temp, ls_enddt, ls_direct_paytype, ls_pricemodel, ls_prebil_yn 
Datetime ldt_crtdt
Long     ll_row, ll_cnt
Dec{0}   ldc_contractseq, ldc_orderno
Boolean  lb_flag

String  ls_method[], ls_M_method, ls_D_method,ls_callforward_code[]
String  ls_itemcod, ls_addition_code, ls_item_method
Long    ll_addunit, ll_validity_term, ll_insmonths
DateTime	ld_item_todt,ld_bil_fromdt,ld_call_todt, ld_activedt

ii_rc = -1

//2005-07-13 khpark add start
//부가서비스유형코드(착신전환부가서비스코드)
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_callforward_code[])		

//과금방식코드
ls_temp = fs_get_control("B0", "P106" , ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])
ls_M_method  = ls_method[1]    //월정액
ls_D_method  = ls_method[8]    //Daily정액	

//2005-07-13 khpark add end

Choose Case is_caller
	//후불개통처리
	Case "b1w_reg_svc_actprc_1_v20_moohan%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_1_v20%save"
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
		
		//2005-07-13 khpark add start
		ld_activedt   = idw_data[1].object.activedt[1]
		ld_bil_fromdt    = idw_data[1].object.bil_fromdt[1]		
      IF Isnull(ld_bil_fromdt) Then ld_bil_fromdt = ld_activedt
		//2005-07-13 khpark add end
		
		//2005-08-29 kem add start
		ll_insmonths = idw_data[1].object.insmonths[1]
      IF Isnull(ll_insmonths) Then ll_insmonths = 0
		//2005-08-29 kem add end
		
				
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
		
		//2005-07-13 khpark modify start (update contractdet & callforwarding_info update)
		//개통신청시 개통요청일과 개통시 과금시작일이 같을경우 contractdet의 contractseq만 update한다.
		IF ls_requestdt = ls_bil_fromdt Then
			
			Update contractdet
			Set contractseq = :ldc_contractseq
			Where orderno   = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1	
				f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
				Return 
			End If
			
			//착신전환정보 update
			 Update callforwarding_info
			   Set contractseq = :ldc_contractseq,
			       fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),
				   updt_user   = :gs_user_id,
				   updtdt      = :ldt_crtdt,
				   pgm_id      = :ls_pgm_id
			 Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1	
				f_msg_sql_err(is_title, is_caller + " Update callforwarding_info table")				
				Return 
			End If			 					
			
    	Else //개통신청시 개통요청일과 개통시 과금시작일이 다를경우 contractdet의 bil_todt 재계산한다.
			
			DECLARE cur_contractdet CURSOR FOR			
				Select c.itemcod, i.addition_code
				  From contractdet c, itemmst i
				 Where c.orderno = :ldc_orderno
				   and c.itemcod = i.itemcod;
			
				If SQLCA.SQLCode <> 0 Then
					RollBack;		
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " CURSOR cur_contractdet")				
					Return 
				End If
	
			OPEN cur_contractdet;
				Do While(True)
					FETCH cur_contractdet
					Into :ls_itemcod, :ls_addition_code;
		
					If SQLCA.sqlcode < 0 Then
						RollBack;		
						ii_rc = -1			
						f_msg_sql_err(is_title, is_caller + " CURSOR cur_contractdet")				
						Return 
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
					
					ls_item_method = ''
					ll_addunit = 0
					ll_validity_term = 0
					
					select method,nvl(addunit,0),nvl(validity_term,0)
					  into :ls_item_method,:ll_addunit,:ll_validity_term
					 from priceplan_rate2
					where priceplan = :ls_priceplan
					 and itemcod = :ls_itemcod
					 and fromdt = (select max(fromdt)
									from priceplan_rate2
								   where priceplan = :ls_priceplan 
									and itemcod = :ls_itemcod
									and fromdt <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
									
					If sqlca.sqlcode < 0 Then
						f_msg_sql_err(is_title, is_caller +"Select priceplan_rate2")				
						Return 
					ElseIF sqlca.sqlcode = 100 Then
						setnull(ld_item_todt)
					End If		
					
					setnull(ld_item_todt)   //item todt 계산
					Choose Case ls_item_method		
						Case ls_M_method     //월정액방식일경우		
							IF ll_validity_term > 0 Then
								ld_item_todt = datetime(relativedate(fd_month_next(date(ld_bil_fromdt),ll_addunit*ll_validity_term),-1))
							End IF
							 
						Case ls_D_method     //Daily정액방식일경우						
							IF ll_validity_term > 0 Then
								ld_item_todt = datetime(relativedate(date(ld_bil_fromdt),ll_addunit*ll_validity_term - 1))
							End IF
							
						Case Else
							 setnull(ld_item_todt)
					End Choose
					
					//착신전환부가서비스 품목일때 callforwarding_info.todt 값 셋팅
					IF ls_addition_code = ls_callforward_code[1] or ls_addition_code = ls_callforward_code[2] or &
					    ls_addition_code = ls_callforward_code[3] Then
						ld_call_todt = ld_item_todt
					End IF

					Update contractdet
					Set contractseq = :ldc_contractseq,
					    bil_fromdt  = to_date(:ls_bil_fromdt,'yyyy-mm-dd'),
						bil_todt    = :ld_item_todt
					Where orderno   = :ldc_orderno
					  and itemcod   = :ls_itemcod;
					
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						ii_rc = -1	
						f_msg_sql_err(is_title, is_caller + " Update contractdet Table")				
						Return 
					End If
				Loop
			CLOSE cur_contractdet;					
			
			//착신전환정보 update
			 Update callforwarding_info
			   Set contractseq = :ldc_contractseq,
			       fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),
				   todt = :ld_call_todt,
				   updt_user   = :gs_user_id,
				   updtdt      = :ldt_crtdt,
				   pgm_id      = :ls_pgm_id
			 Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1	
				f_msg_sql_err(is_title, is_caller + " Update callforwarding_info table")				
				Return 
			End If			 
			
		End IF
		//2005-07-13 khpark modify end				
				
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
		String ls_reqactive //개통 신청 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		
		DECLARE cur_validkey_check CURSOR FOR
		
			Select validkey
			     , to_char(fromdt,'yyyymmdd')
				  , svccod // svctype
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
				Into :ls_validkey, :ls_todt_tmp, :ls_svccod_1;
	
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
				//적용시작일과 적용종료일의 중복일자를 막는다.  ( svctype 가아닌 svccod로 중복체크 - 05.04.25 ohj)
				select count(validkey)
				  into :ll_cnt
				  from validinfo
				 where ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) 
				    Or ( to_char(fromdt,'yyyymmdd') <= :ls_activedt   
					And :ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
					and validkey = :ls_validkey
					and to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
					and svccod   = :ls_svccod_1                      ; //:ls_svctype ;
						  
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
		   Set fromdt      = to_date(:ls_activedt,'yyyy-mm-dd')  //개통일
			  , use_yn      = 'Y'											//사용여부
			  , status      = :ls_status
			  , contractseq = :ldc_contractseq
			  , svccod      = :ls_svccod
			  , priceplan   = :ls_priceplan
			  , updt_user   = :gs_user_id
			  , updtdt      = :ldt_crtdt
			  , pgm_id      = :ls_pgm_id
		 Where orderno     = :ldc_orderno      ;
//		Where customerid = :ls_customerid and status = :ls_reqactive and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If
		
		//무한넷 Trigger 영향으로 계약정보를 나중에 Insert 한다.
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno, insmonths )
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno, :ll_insmonths);

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
		
						
End Choose
ii_rc = 0
end subroutine

public subroutine uf_prc_db_01 ();//"b1w_inq_svcorder_b%cancel"
String ls_ref_desc, ls_result_code[], ls_temp, ls_customerid, ls_validkeystatus
String ls_order_status, ls_tmp, ls_serialno, ls_mv_partner, ls_status
Long   ll_hwseq
Integer li_cnt


ii_rc = -2
Choose Case is_caller
	Case "b1w_inq_svcorder_c_v20%cancel"
//		lu_dbmgr.is_caller = "b1w_inq_svcorder_c_v20%cancel"
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

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " DETELE Error(svcorder)")
			RollBack;
			Return 
		End If		

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
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(contractdet)")
			RollBack;
			Return 
		End If						
		
		//3.할부정보(quota_info) 테이블 Delete
		DELETE FROM quota_info
		WHERE to_char(orderno) = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(quota_info)")
			RollBack;
			Return 
		End If						
		
		//4.해당 Order 번호에 해당하는 하드웨어 정보가 있는지 확인
		Select count(hwseq)
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
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Delete Error(customer_hw)")
				RollBack;
				Return 
			End If						
		End If		
				
		//5.위약금내역(penaltydet)테이블 Delete  
		DELETE FROM penaltydet  
		WHERE to_char(orderno) = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(penaltydet)")
			RollBack;
			Return 
		End If			
		
		//6.일시불정보내역(oncepayment)테이블 Delete
		DELETE FROM oncepayment
		WHERE to_char(orderno) = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(oncepayment)")
			RollBack;
			Return 
		End If					
				
		//7.가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
		//If ii_data[1] > 0 Then  --> 제외 o.h.j.
			
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
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Update Error(validkeymst)")
				RollBack;
				Return 
			End If			
			
		//End If
		
		//8.선납판매정보에 따른 처리 추가 (2004.12.10 kem)
		DELETE FROM PREPAYMENT
		WHERE TO_CHAR(ORDERNO) = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(prepayment)")
			RollBack;
			Return 
		End If			
		
		//9.선수금등록에 따른 처리 추가 (2004.12.20 kem)
		DELETE FROM REQPAY
		WHERE TO_CHAR(ORDERNO) = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(reqpay)")
			RollBack;
			Return 
		End If			
		
        //10. 2005-07-13 khpark add 
		// 착신전환정보 및 발신가능정화번호 삭제처리
		// callforwarding_auth 먼저 delete 하고 차후 callforwarding_info delete 해야한다.

        // callforwarding_auth delete : callforwarding_info에 해당 orderno로 여러건일 경우있으므로 in 으로 처리
		DELETE FROM callforwarding_auth
		WHERE seq in ( SELECT seq FROM callforwarding_info
		              WHERE TO_CHAR(ORDERNO) = :is_data[1] );

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(callforwarding_auth)")
			RollBack;
			Return 
		End If							

		DELETE FROM callforwarding_info
		WHERE TO_CHAR(ORDERNO) = :is_data[1];					  

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "Delete Error(callforwarding_info)")
			RollBack;
			Return 
		End If							
	
End Choose	
ii_rc = 0
end subroutine

public subroutine uf_prc_db_02 ();//b1w_reg_svc_actorder_6_moohan%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix, ls_validloc_gu
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_h323id, ls_ip_address, ls_result  
string ls_validkey_loc[], ls_temp, ls_result_code[], ls_quota_yn, ls_langtype
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec, ll_priority
Time lt_now_time, lt_after_time
String ls_n_auth_method[], ls_n_validitem3[], ls_n_validitem2[], ls_n_langtype[], ls_chk_yn, ls_n_validitem1[]
String ls_validkey_type[]//, ls_callforwardno[]
String ls_vpricecod, ls_acttype, ls_hopenum, ls_remark, ls_quota_status, ls_validkeystatus
String ls_validkey_msg //인증Key MSG
integer li_return, li_random_length 
String ls_validkey_typenm[],ls_crt_kind[],ls_prefix[],ls_auth_method[],ls_type[],ls_used_level[], ls_crt_kind_code[]
string ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ls_auth_method_h,ls_type_h,ls_used_level_h
Long ll_length[],ll_length_h
string ls_auto_validkey, ls_auto_validitem
string ls_callforward_type, ls_callforward_code[], ls_callforwardno[], ls_password[], ls_callingnum_all[], ls_callingnum[]
//khpark add 2005-07-07
string ls_callforward_info, ls_callforward_auth,ls_addition_itemcod, ls_item_method,ls_method[],ls_M_method,ls_D_method
long ll_callforwarding_info_seq, ll_addunit,ll_validity_term, ll_callingnum_cnt
date ld_call_fromdt, ld_call_todt, ld_item_todt[], ld_requestdt, ld_bil_fromdt
String ls_bil_fromdt
//kem add 2005-08-25
String ls_gkid1[], ls_validitem[], ls_subseq[]

String ls_ins_yn
Long   ll_insmonths    //보증보험 개월수


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_v20_moohan%save"  //장비임대 포함 수정,입중계출중계서비스추가,인증KeyType별추가,착신전환부가서비스추가
//		lu_dbmgr.is_caller   = "b1w_regsvc_actorder_v20%save"
//		lu_dbmgr.is_title    = is_title
//		lu_dbmgr.idw_data[1] = dw_cond                   //입력정보
//		lu_dbmgr.idw_data[2] = dw_detail2                //품목정보
//		lu_dbmgr.idw_data[3] = dw_detail		         //인증정보
//		lu_dbmgr.is_data[1]  = gs_user_id
//		lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[3]  = is_act_gu                 //개통처리 check
//		lu_dbmgr.is_data[4]  = is_cus_status             //고객상태
//		lu_dbmgr.is_data[5]  = is_svctype                //svctype
//		lu_dbmgr.is_data[6]  = string(il_validkey_cnt)   //인증KEY갯수
//		lu_dbmgr.is_data[7]  = is_type          		 //MVNO svctype
//		lu_dbmgr.is_data[8]  = is_inout_svc_gu    		 //입중계출중계 서비스여부
//		//khpark add 2005-07-07
//		lu_dbmgr.is_data[9]  = is_callforward_type    	 //착신전환부가서비스선택유형
//		lu_dbmgr.is_data[10]  = is_addition_itemcod    	 //착신전환품목서비스선택유형	

		//부가서비스품목 & 유형
		ls_callforward_type = is_data[9]
		ls_addition_itemcod = is_data[10]
		ls_callforward_info = "N" 
		
		If is_data[8] = 'Y' Then
			 ls_validkey_msg = 'Route-No.'
		Else
			 ls_validkey_msg = '인증KEY'
		End IF

		//부가서비스유형코드(착신전환부가서비스코드)
		ls_ref_desc = ""
		ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_callforward_code[])		

		//과금방식코드
		ls_temp = fs_get_control("B0", "P106" , ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_method[])
		ls_M_method  = ls_method[1]    //월정액
		ls_D_method  = ls_method[8]    //Daily정액		
		
		ls_customerid   = Trim(idw_data[1].object.customerid[1])
		ls_customerm    = Trim(idw_data[1].object.customernm[1])
		ls_orderdt      = String(idw_data[1].object.orderdt[1],'yyyymmdd')
		ls_requestdt    = String(idw_data[1].object.requestdt[1], 'yyyymmdd')
		ld_requestdt    = idw_data[1].object.requestdt[1]
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
//		ls_auth_method  = Trim(idw_data[1].object.auth_method[1])
		ls_h323id       = Trim(idw_data[1].object.h323id[1])
		ls_ip_address   = Trim(idw_data[1].object.ip_address[1])
		ls_langtype 	= Trim(idw_data[1].object.langtype[1])
		ls_userid       = is_data[1]
		ls_pgm_id       = is_data[2]
		//2005-07-09 khpark add start
		ls_bil_fromdt    = String(idw_data[1].object.bil_fromdt[1], 'yyyymmdd')
		ld_bil_fromdt    = idw_data[1].object.bil_fromdt[1]		
		IF Isnull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_requestdt
		IF Isnull(ld_bil_fromdt) Then ld_bil_fromdt = ld_requestdt
		//2005-07-09 khpark add end
		
		//2005-08-29 kem add start
		ls_ins_yn    = Trim(idw_data[1].Object.ins_yn[1])
		ll_insmonths = idw_data[1].Object.insmonths[1]
		//2005-08-29 kem add end
				
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
		
		//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";" , ls_crt_kind_code[])		
		
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

				ls_item_method = ''
				ll_addunit = 0
				ll_validity_term = 0
				
				select method,nvl(addunit,0),nvl(validity_term,0)
				  into :ls_item_method,:ll_addunit,:ll_validity_term
				 from priceplan_rate2
				where priceplan = :ls_priceplan
				 and itemcod = :ls_itemcod[j] 
				 and fromdt = (select max(fromdt)
								from priceplan_rate2
							   where priceplan = :ls_priceplan 
								and itemcod = :ls_itemcod[j]
								and fromdt <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
								
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select priceplan_rate2")				
					Return 
				ElseIF sqlca.sqlcode = 100 Then
					setnull(ld_item_todt[j])
				End If		
				
				setnull(ld_item_todt[j])   //item todt 계산
				Choose Case ls_item_method		
					Case ls_M_method     //월정액방식일경우		
						IF ll_validity_term > 0 Then
							ld_item_todt[j] = relativedate(fd_month_next(ld_bil_fromdt,ll_addunit*ll_validity_term),-1)
						End IF
						 
					Case ls_D_method     //Daily정액방식일경우						
						IF ll_validity_term > 0 Then
							ld_item_todt[j] = relativedate(ld_bil_fromdt,ll_addunit*ll_validity_term - 1)
						End IF
						
					Case Else
						 setnull(ld_item_todt[j])
				End Choose		
				//착신전환부가서비스 품목일때 callforwarding_info.todt 값 셋팅
				IF ls_itemcod[j] = ls_addition_itemcod Then
					ld_call_todt = ld_item_todt[j]
				End IF
				j ++
			End If
		Next
		
		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
		
		If li_return = -1 Then
		    return
		End IF

		//인증KEY 갯수가 0보다 클때 입력한 인증KEY check
		If integer(is_data[6]) > 0 Then
			
			ll_row = idw_data[3].RowCount()
			
			ls_temp = fs_get_control("B1","P400", ls_ref_desc)			
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_result_code[])
			
			//인증Key 관리상태(개통:20)
			ls_validkeystatus = ls_result_code[2]			
			
			For i = 1 To ll_row
				
				ls_validkey_type[i] = Trim(idw_data[3].object.validkey_type[i])
				
        		//인증KEY의 validkey_type에 따른 처리
				li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type[i],ls_validkey_typenm[i],ls_crt_kind[i],ls_prefix[i],ll_length[i],ls_auth_method[i],ls_type[i],ls_used_level[i]) 
				
				If li_return = -1 Then
				    return
				End IF
				
				Choose Case ls_crt_kind[i]		
					Case ls_crt_kind_code[1]   //수동Manual
						
					Case ls_crt_kind_code[2]   //AutoRandom
                        
						ls_auto_validkey = ""
				        //validkey 생성에 따른 prefix 및 길이 Check
						IF isnull(ls_prefix[i]) or ls_prefix[i] = "" Then
	                        ls_prefix[i] = ""
							li_random_length = ll_length[i]
						Else
     						li_random_length = ll_length[i] - LenA(ls_prefix[i])
						END IF
								
						DO  //validkey random 생성
							ls_auto_validkey = ls_prefix[i] + fs_get_randomize_v20(li_random_length)
			
							select count(validkey)
							  into :ll_cnt
							  from validinfo
							 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
									 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
									 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
							   and validkey = :ls_auto_validkey
							   and svccod = :ls_svccod;	
							   
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Select Error(validinfo check)")
								RollBack;
								ii_rc = -1				
								Return 
							End If				
	
	                        IF ll_cnt = 0 Then
								//자동발생 인증KEY중 같은 인증 KEY가 있는지 check			
								CHOOSE CASE i
									CASE 1  // Row가 1행일때 
										IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", i + 1, ll_row)
									CASE ll_row // Row가 맨 마지막
										IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", 1, i -1)
									CASE ELSE	  
										IF  ll_row > 1 THEN
											ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", 1, i -1)
											IF  ll_cnt > 0 THEN
											else
												ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", i + 1, ll_row)
											END IF
										END IF
								END CHOOSE
							End IF
							
						LOOP WHILE(ll_cnt>0)		
						
			            idw_data[3].object.validkey[i] = ls_auto_validkey
			
					Case ls_crt_kind_code[3]   //AutoSeq
						
                        ls_auto_validkey = ""
						//Order Sequence
						Select to_char(seq_auto_validkey.nextval)
						  Into :ls_auto_validkey
						  From dual;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, " Sequence Error(seq_auto_validkey)")
							RollBack;
							ii_rc = -1				
							Return 
						End If				

			            idw_data[3].object.validkey[i] = ls_auto_validkey
						
					Case ls_crt_kind_code[4]   //자원관리Resource
						
					Case ls_crt_kind_code[5]   //고객대체				
						
				End Choose                
				
            ls_validkey[i]     = Trim(idw_data[3].object.validkey[i])			
			  	ls_vpasswd[i]      = Trim(idw_data[3].object.vpassword[i])
				ls_validkey_loc[i] = Trim(idw_data[3].object.validkey_loc[i])
     		   If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
				If IsNull(ls_validkey_loc[i]) Then ls_validkey_loc[i] = ""
				
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				
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
					f_msg_usr_err(9000, is_title, ls_validkey_msg+"[" + ls_validkey[i]+ "]가 중복됩니다.")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					return
				End if

				//인증KEY 중복 check  
				//적용시작일과 적용종료일의 중복일자를 막는다. 
				select count(validkey)
				  into :ll_cnt
				  from validinfo
				 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				   and validkey = :ls_validkey[i]
				   and svccod = :ls_svccod;
						  
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
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
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""				 

				IF ls_validitem_yn = 'Y' Then	
					
					Choose Case ls_crt_kind_h	
						Case ls_crt_kind_code[1]   //수동Manual
							
						Case ls_crt_kind_code[2]   //AutoRandom

							ls_auto_validitem = ""							
							//validitem(H323id) 생성에 따른 prefix 및 길이 Check
							IF isnull(ls_prefix_h) or ls_prefix_h = "" Then
								ls_prefix_h= ""
								li_random_length = ll_length_h
							Else
								li_random_length = ll_length_h - LenA(ls_prefix_h)
							END IF
									
							DO  //validitem random 생성
							   ls_auto_validitem = ls_prefix_h + fs_get_randomize_v20(li_random_length)

                               ll_cnt = 0
							   IF MidA(ls_n_auth_method[i],7,4) = "H323" Then
				
									select count(validkey)
									  into :ll_cnt
									  from validinfo
									 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
										   ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
										   :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
									   and validitem3 = :ls_n_validitem3[i]
									   and svccod = :ls_svccod;									 
									   
									If sqlca.sqlcode < 0 Then
										f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
										Return 
									End If
									   
									IF ll_cnt = 0 Then
										//자동랜던발생한 validitem(h323id) 중 같은 validitem(h323id)가 있는지 check			
										CHOOSE CASE i
											CASE 1  // Row가 1행일때 
												IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", i + 1, ll_row)
											CASE ll_row // Row가 맨 마지막
												IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", 1, i -1)
											CASE ELSE	  
												IF  ll_row > 1 THEN
													ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", 1, i -1)
													IF  ll_cnt > 0 THEN
													else
														ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", i + 1, ll_row)
													END IF
												END IF
										END CHOOSE
									
									End IF
								End IF  
								 
							LOOP WHILE(ll_cnt>0)		
							
							idw_data[3].object.validitem3[i] = ls_auto_validitem

						Case ls_crt_kind_code[3]   //AutoSeq							
							
							ls_auto_validitem = ""							
							//Order Sequence
							 Select to_char(seq_auto_validitem.nextval)
							  Into :ls_auto_validitem
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Sequence Error(seq_auto_validitem)")
								RollBack;
								ii_rc = -1				
								Return 
							End If				
	
							idw_data[3].object.validitem3[i] = ls_auto_validitem
							
						Case ls_crt_kind_code[4]   //자원관리Resource
							
						Case ls_crt_kind_code[5]   //고객대체
						
					End Choose
				End IF	 
				
				ls_n_langtype[i]  = Trim(idw_data[3].object.langtype[i])
				ls_n_validitem2[i] = idw_data[3].object.validitem2[i]
				ls_n_validitem3[i] = idw_data[3].object.validitem3[i]
				ls_n_validitem1[i] = idw_data[3].object.validitem1[i]
				If IsNull(ls_n_langtype[i]) Then ls_n_langtype[i] = ""
				If IsNull(ls_n_validitem2[i]) Then ls_n_validitem2[i] = ""				
				If IsNull(ls_n_validitem3[i]) Then ls_n_validitem3[i] = ""							
				If IsNull(ls_n_validitem1[i]) Then ls_n_validitem1[i] = ""										
			
			    //인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
			    ll_cnt = 0
        	    IF MidA(ls_n_auth_method[i],7,4) = "H323" Then

					 select count(validkey)
					  into :ll_cnt
					  from validinfo
				     where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						   ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						   :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
                       and validitem3 = :ls_n_validitem3[i]
		    		   and svccod = :ls_svccod;
					   
					If sqlca.sqlcode < 0 Then
						f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
						Return 
					End If
					   
					If ll_cnt > 0 Then
						f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("validitem3")
						ii_rc = -3					
						return 
					End if
				
					//입력한 validitem(h323id) 중 같은 validitem(h323id)가 있는지 check			
					CHOOSE CASE i
						CASE 1  // Row가 1행일때 
							IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", i + 1, ll_row)
						CASE ll_row // Row가 맨 마지막
							IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", 1, i -1)
						CASE ELSE	  
							IF  ll_row > 1 THEN
								ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", 1, i -1)
								IF  ll_long > 0 THEN
								else
									ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", i + 1, ll_row)
								END IF
							END IF
					END CHOOSE
				
					If ll_long > 0 Then
						// messagebox(validitem3(h323id)중복)	
						f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3[i]+ "]가 중복됩니다.")
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("validitem3")
						ii_rc = -3
						return
					End if
					
				End IF  
				
				//khpark add 2005-07-07 start(착신전환부가서비스추가)
				ls_callforwardno[i] = Trim(idw_data[3].object.callforwardno[i])
				ls_password[i] = Trim(idw_data[3].object.password[i])
				ls_callingnum_all[i] = Trim(idw_data[3].object.callingnum[i])
								
				If IsNull(ls_callforwardno[i]) or ls_callforwardno[i] = "" Then
					ls_callforwardno[i] = ""
				Else
					ls_callforward_info = "Y"
				End IF
				
				If IsNull(ls_password[i]) Then ls_password[i] = ""
				If IsNull(ls_callingnum_all[i]) Then ls_callingnum_all[i] = ""
				//khpark add 2005-07-07 end
				
				//kem add 2005-08-25 (서버ip/port# 추가)
				ls_gkid1[i] = idw_data[3].Object.gkid[i]
				ls_validitem[i] = idw_data[3].Object.validitem[i]
				ls_subseq[i] = idw_data[3].Object.subseq[i]
				
				If IsNull(ls_gkid1[i]) Then ls_gkid1[i] = ""
				If IsNull(ls_validitem[i]) Then ls_validitem[i] = ""
				If IsNull(ls_subseq[i]) Then ls_subseq[i] = ""
				//kem add 200508-25 end
				
			Next
			
			//khpark add 2005-07-07 start
			//착신전환 부가서비스 품목 선택했을 경우 착신전환번호 한건 이상은 꼭 입력해야한다.
			CHOOSE CASE ls_callforward_type   
				CASE ls_callforward_code[1],ls_callforward_code[2],ls_callforward_code[3]      //착신전환부가서비스유형일때 
					If ls_callforward_info <> "Y" Then
						f_msg_usr_err(9000, is_title, "착신전환부가서비스유형 품목 선택 시~r~n~r~n착신전환번호를  한건 이상은 입력하셔야합니다.!!")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(1)
						idw_data[3].ScrollToRow(1)
						idw_data[3].SetColumn("callforwardno")
						ii_rc = -3					
						return 						
					End If					
			END CHOOSE
			//khpark add 2005-07-07 start			
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
					crt_user, updt_user, crtdt, updtdt, pgm_id, remark, insmonths)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_maintain_partner, :ls_reg_partner, :ls_sale_partner, 
				 :ll_priority, :ls_hopenum, :ls_acttype, :ls_vpricecod, :ls_partner, :ll_contractseq, 
				 :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id, :ls_remark, :ll_insmonths);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SVCORDER)")
			ii_rc = -1				
			RollBack;
			Return 
		End If

      
		
		//contractdet insert
	   For i =1 To UpperBound(ls_itemcod[])
			Insert Into contractdet(orderno, itemcod, contractseq, bil_fromdt,bil_todt)
			    Values(:ll_orderno, :ls_itemcod[i], :ll_contractseq, to_date(:ls_bil_fromdt,'yyyy-mm-dd'),:ld_item_todt[i]);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACDET)")
				ii_rc = -1					
				RollBack;
				Return 
			End If
		Next
		
		//인증KEY가 존재할 경우
		If integer(is_data[6]) > 0  Then
			
			
			//validinfo insert
			For i =1 To UpperBound(ls_validkey[])
				
				Insert Into validinfo
				    	(validkey, fromdt, status, 
						 use_yn, vpassword, svctype,
						 customerid, svccod, priceplan, 
						 orderno, contractseq, langtype,
						 auth_method, validitem1, validitem2, validitem3,
						 crt_user, updt_user, crtdt, updtdt, pgm_id, 
						 validkey_loc, gkid, validitem, subseq)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_customerid, :ls_svccod, :ls_priceplan,
					   :ll_orderno, :ll_contractseq, :ls_n_langtype[i],
					   :ls_n_auth_method[i], :ls_n_validitem1[i], :ls_n_validitem2[i], :ls_n_validitem3[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id, 
						:ls_validkey_loc[i], :ls_gkid1[i], :ls_validitem[i], :ls_subseq[i]);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
					ii_rc = -1						
					RollBack;
					Return 
				End If
				
				If ls_crt_kind[i] = ls_crt_kind_code[4]  Then   //인증KEY 인증KeyType이 자원관리인 경우만 처리
				
					//인증Key 마스터 Update
					Update validkeymst
					Set    status        = :ls_validkeystatus,
					       sale_flag     = '1',
						    activedt      = to_date(:ls_requestdt,'yyyy-mm-dd'),
						    customerid    = :ls_customerid,
						    orderno       = :ll_orderno,
						    contractseq   = :ll_contractseq,
						    updt_user     = :gs_user_id,
						    updtdt        = sysdate
					Where  validkey      = :ls_validkey[i]
					  and  validkey_type = :ls_validkey_type[i] ;
					
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

				If ls_crt_kind_h = ls_crt_kind_code[4]  Then   //validitem3(H323ID) KeyType이 자원관리인 경우만 처리
				
					//인증Key 마스터 Update
					Update validkeymst
					Set    status        = :ls_validkeystatus,
					       sale_flag     = '1',
						    activedt      = to_date(:ls_requestdt,'yyyy-mm-dd'),
						    customerid    = :ls_customerid,
					 	    orderno       = :ll_orderno,
						    contractseq   = :ll_contractseq,
						    updt_user     = :gs_user_id,
						    updtdt        = sysdate
					Where  validkey      = :ls_n_validitem3[i]
					  and  validkey_type = :ls_validkey_type_h;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(Validkeymst)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
				
					Insert Into validkeymst_log ( validkey, seq, status, actdt,
														   customerid, contractseq, partner, crt_user,
														   crtdt, pgm_id )
												Values ( :ls_n_validitem3[i], seq_validkeymstlog.nextval, :ls_validkeystatus, to_date(:ls_requestdt,'yyyy-mm-dd'),
														   :ls_customerid, :ll_contractseq, :ls_reg_partner, :gs_user_id,
														   sysdate, :ls_pgm_id );
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(Validkeymst_log)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
					
				End If
				
			   //khpark add 2005-07-07 start(착신전환부가서비스)
	            CHOOSE CASE ls_callforward_type   
					CASE ls_callforward_code[1]   //착신전환일반유형일때 
						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );
									 
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 

						End IF
							
					CASE ls_callforward_code[2]     //착신전환비밀번호인증일때

						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );

							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 

						End IF						
						
					CASE ls_callforward_code[3]     //착신전환발신번호인증일때
						
						For j = 1 To UpperBound(ls_callingnum[])
							ls_callingnum[j] = ''							
						Next
						
						ll_callingnum_cnt = fi_cut_string(ls_callingnum_all[i], ";" , ls_callingnum[])

						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );

							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 
							
							//발신가능전화번호 insert
							For j = 1 To ll_callingnum_cnt	
								Insert Into callforwarding_auth
								( seq,callingnum,
								  crt_user,crtdt, pgm_id ) 
								Values ( :ll_callforwarding_info_seq,:ls_callingnum[j],
									 :gs_user_id,sysdate, :ls_pgm_id );

								If SQLCA.SQLCode < 0 Then
									f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
									ii_rc = -1						
									RollBack;
									Return 
								End If									 
									 
							Next

						End IF						
						
				END CHOOSE
			    //khpark add 2005-07-07 start				
			Next
			
      End if
		
		//개통처리확정 시 로직
		If is_data[3]='Y' Then
			
			//Insert contractmst
			insert into contractmst
				( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
				   prmtype, maintain_partner, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno, insmonths )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_maintain_partner, :ls_reg_partner, :ls_sale_partner, :ls_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				   :gs_user_id, sysdate, :ls_pgm_id, :gs_user_id, sysdate, :ls_reg_prefix, :ll_insmonths);
				   
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
		
		ll_cnt = 0
		//할부품목이 있는지 체크하여 svcorder의 상태 변경.
		For i = 1 To idw_data[2].Rowcount()
			ls_quota_yn = Trim(idw_data[2].object.quota_yn[i])
			ls_chk_yn   = Trim(idw_data[2].object.chk[i])
			If (ls_quota_yn = 'Y' or ls_quota_yn = 'R') and ls_chk_yn = 'Y' Then
				ll_cnt ++
			End If
		Next
		
		If ll_cnt > 0 Then
			Update svcorder
				Set status    = :ls_quota_status,
					 updt_user = :gs_user_id,
					 updtdt    = sysdate,
					 pgm_id    = :ls_pgm_id					 
			 Where orderno   = :ll_orderno;
				
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

public subroutine uf_prc_db_04 ();//b1w_reg_svc_actorder_pre_3_v20_moohan%save   선불서비스신청v20

String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_validkeyloc[], ls_cid[], ls_prebil[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item           
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_ip_address, ls_result
string ls_coid, ls_temp, ls_result_code[], ls_pricemodel, ls_refilltype[], ls_langtype, ls_remark
Long ll_orderno, ll_cnt, ll_contractseq, ll_validity[]
Long i, j, ll_row, ll_long, ll_result_sec, ll_endday, ll_rows
Time lt_now_time, lt_after_time    
Decimal ldc_first_refill_amt, ldc_first_sale_amt
String ls_quota_yn, ls_chk_yn, ls_quota_status, ls_validkeystatus
String ls_n_auth_method[],	ls_n_langtype[], ls_n_validitem2[], ls_n_validitem3[], ls_n_validitem1[]
Date   ld_enddt, ld_bil_fromdt
	
String ls_prebil_yn, ls_oneoffcharge_yn, ls_itemcod1, ls_day, ls_direct_paytype
Long   ll_validity_term, ll_i
Decimal ldc_unitcharge, ldc_payamt, ldc_price, ldc_rate_first, ldc_basic_fee_first, ldc_basic_rate_first
Date   ld_salemonth, ld_inputclosedt
Boolean lb_flag = False
String ls_crt_kind_code[]
Integer li_return, li_random_length
String ls_validkey_typenm[],ls_crt_kind[],ls_prefix[],ls_auth_method[],ls_type[],ls_used_level[]//, ls_crt_kind_code[]
string ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ls_auth_method_h,ls_type_h,ls_used_level_h
Long ll_length[],ll_length_h
string ls_auto_validkey, ls_auto_validitem, ls_validkey_type[], ls_validkey_loc[] //ls_callforwardno[]
//khpark add 2005-07-08
string ls_callforward_type, ls_callforward_code[], ls_callforwardno[], ls_password[], ls_callingnum_all[], ls_callingnum[]
string ls_callforward_info, ls_callforward_auth,ls_addition_itemcod, ls_item_method,ls_method_code[],ls_M_method,ls_D_method
long ll_callforwarding_info_seq, ll_item_addunit,ll_item_validity_term, ll_callingnum_cnt, ll_len
date ld_call_fromdt, ld_call_todt, ld_item_todt[], ld_requestdt
String ls_bil_fromdt, ls_paytype_method[], ls_sale_prefix, ls_level_code, ls_partner_main

//kem add 2005-10-13
String ls_gkid1[], ls_validitem[], ls_subseq[]

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre_3_v20_moohan%save"    //선불제(선납포함) - 장비모듈 추가, 인증KeyLocation 필수 체크 포함.
//		lu_dbmgr = Create b1u_dbmgr1_v20
//		lu_dbmgr.is_caller = "b1w_reg_svc_actorder_pre_3_v20%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_cond
//		lu_dbmgr.idw_data[2] = dw_detail2                //품목
//		lu_dbmgr.idw_data[3] = dw_detail			     //인증KEY
//		lu_dbmgr.is_data[1] = gs_user_id
//		lu_dbmgr.is_data[2] = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[3] = is_act_gu                  //개통처리 check
//		lu_dbmgr.is_data[4] = is_cus_status              //고객상태
//		lu_dbmgr.is_data[5] = is_svctype                 //svctype
//		lu_dbmgr.is_data[6] = string(il_validkey_cnt)    //인증KEY갯수
//		//khpark add 2005-07-08
//		lu_dbmgr.is_data[7]  = is_callforward_type    	 //착신전환부가서비스선택유형
//		lu_dbmgr.is_data[8]  = is_addition_itemcod    	 //착신전환품목서비스선택유형

		//부가서비스품목 & 유형
		ls_callforward_type = is_data[7]
		ls_addition_itemcod = is_data[8]
		ls_callforward_info = "N"
		
		//부가서비스유형코드(착신전환부가서비스코드)
		ls_ref_desc = ""
		ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_callforward_code[])		

		//과금방식코드
		ls_temp = fs_get_control("B0", "P106" , ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_method_code[])
		ls_M_method  = ls_method_code[1]    //월정액
		ls_D_method  = ls_method_code[8]    //Daily정액
		
		//청구서발송방식;직접입금방식 100 200
		ls_temp = fs_get_control("B1", "P600" , ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_paytype_method[])

		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])

    	ls_customerid   = Trim(idw_data[1].object.customerid[1])
		ls_customerm    = Trim(idw_data[1].object.customernm[1])
		ls_orderdt      = String(idw_data[1].object.orderdt[1],'yyyymmdd')
		ls_requestdt    = String(idw_data[1].object.requestdt[1], 'yyyymmdd')
		ld_requestdt    = idw_data[1].object.requestdt[1]		
		ls_svccod       = Trim(idw_data[1].object.svccod[1])
		ls_priceplan    = Trim(idw_data[1].object.priceplan[1])
		ls_prmtype      = Trim(idw_data[1].object.prmtype[1])
		ls_reg_partner  = Trim(idw_data[1].object.reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.sale_partner[1])
		ls_partner      = Trim(idw_data[1].object.partner[1])
		ls_contractno   = Trim(idw_data[1].object.contract_no[1])
		ls_gkid         = Trim(idw_data[1].object.gkid[1])
		ls_langtype     = Trim(idw_data[1].object.langtype[1])
		ls_remark       = Trim(idw_data[1].object.remark[1])		
		ls_userid       = is_data[1]
		ls_pgm_id       = is_data[2]
	
		ls_maintain_partner  = Trim(idw_data[1].object.maintain_partner[1])		
		ls_direct_paytype    = Trim(idw_data[1].object.direct_paytype[1])		
		ls_pricemodel        = Trim(idw_data[1].object.pricemodel[1])
		ldc_first_refill_amt = idw_data[1].object.first_refill_amt[1]
		ldc_first_sale_amt   = idw_data[1].object.first_sale_amt[1]

		If IsNull(ldc_first_refill_amt) Then ldc_first_refill_amt = 0
		If IsNull(ldc_first_sale_amt) Then ldc_first_sale_amt = 0
		
		//2004-12-08 kem 추가
		ld_enddt      = idw_data[1].Object.enddt[1]
		ld_bil_fromdt = idw_data[1].Object.bil_fromdt[1]	
		//2005-07-09 khpark add start		
		ls_bil_fromdt = String(idw_data[1].object.bil_fromdt[1], 'yyyymmdd')
		IF Isnull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_requestdt
		IF Isnull(ld_bil_fromdt) Then ld_bil_fromdt = ld_requestdt
		//2005-07-09 khpark add end						
		
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
		 
		//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";" , ls_crt_kind_code[])				 
		 
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
		    ls_check[i]        = Trim(idw_data[2].object.chk[i])
			
			If ls_check[i] = "Y" Then
				ls_itemcod[j] = Trim(idw_data[2].object.itemcod[i])
	
				ls_item_method = ''
				ll_item_addunit = 0
				ll_item_validity_term = 0
				
				select method,nvl(addunit,0),nvl(validity_term,0)
				  into :ls_item_method,:ll_item_addunit,:ll_item_validity_term
				 from priceplan_rate2
				where priceplan = :ls_priceplan
				 and itemcod = :ls_itemcod[j] 
				 and fromdt = (select max(fromdt)
								from priceplan_rate2
							   where priceplan = :ls_priceplan 
								and itemcod = :ls_itemcod[j]
								and fromdt <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
								
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select priceplan_rate2")				
					Return 
				ElseIF sqlca.sqlcode = 100 Then
					setnull(ld_item_todt[j])
				End If		
				
				setnull(ld_item_todt[j])   //item todt 계산
				Choose Case ls_item_method		
					Case ls_M_method     //월정액방식일경우		
						IF ll_item_validity_term > 0 Then
							ld_item_todt[j] = relativedate(fd_month_next(ld_bil_fromdt,ll_item_addunit*ll_item_validity_term),-1)
						End IF
						 
					Case ls_D_method     //Daily정액방식일경우						
						IF ll_item_validity_term > 0 Then
							ld_item_todt[j] = relativedate(ld_bil_fromdt,ll_item_addunit*ll_item_validity_term - 1)
						End IF
						
					Case Else
						 setnull(ld_item_todt[j])
				End Choose		
				//착신전환부가서비스 품목일때 callforwarding_info.todt 값 셋팅
				IF ls_itemcod[j] = ls_addition_itemcod Then
					ld_call_todt = ld_item_todt[j]
				End IF				
				
				j ++
			End If		
			
		Next
		
		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
		
		If li_return = -1 Then
		    return
		End IF
		
		//인증KEY 갯수가 0보다 클때 입력한 인증KEY check
		If integer(is_data[6]) > 0 Then
			
			ll_row = idw_data[3].RowCount()
			
			ls_temp = fs_get_control("B1","P400", ls_ref_desc)			
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_result_code[])
			
			//인증Key 관리상태(개통:20)
			ls_validkeystatus = ls_result_code[2]			
			
			For i = 1 To ll_row
				
				ls_validkey_type[i] = Trim(idw_data[3].object.validkey_type[i])
				
        		//인증KEY의 validkey_type에 따른 처리
				li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type[i],ls_validkey_typenm[i],ls_crt_kind[i],ls_prefix[i],ll_length[i],ls_auth_method[i],ls_type[i],ls_used_level[i]) 
				
				If li_return = -1 Then
				    return
				End IF

				Choose Case ls_crt_kind[i]		
					Case ls_crt_kind_code[1]   //수동Manual
						
					Case ls_crt_kind_code[2]   //AutoRandom
                        
						ls_auto_validkey = ""
				        //validkey 생성에 따른 prefix 및 길이 Check
						IF isnull(ls_prefix[i]) or ls_prefix[i] = "" Then
	                        ls_prefix[i] = ""
							li_random_length = ll_length[i]
						Else
     						li_random_length = ll_length[i] - LenA(ls_prefix[i])
						END IF
								
						DO  //validkey random 생성
							ls_auto_validkey = ls_prefix[i] + fs_get_randomize_v20(li_random_length)
			
							select count(validkey)
							  into :ll_cnt
							  from validinfo
							 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
									 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
									 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
							   and validkey = :ls_auto_validkey
							   and svccod = :ls_svccod;	
							   
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Select Error(validinfo check)")
								RollBack;
								ii_rc = -1				
								Return 
							End If				
	
	                        IF ll_cnt = 0 Then
								//자동발생 인증KEY중 같은 인증 KEY가 있는지 check			
								CHOOSE CASE i
									CASE 1  // Row가 1행일때 
										IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", i + 1, ll_row)
									CASE ll_row // Row가 맨 마지막
										IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", 1, i -1)
									CASE ELSE	  
										IF  ll_row > 1 THEN
											ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", 1, i -1)
											IF  ll_cnt > 0 THEN
											else
												ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", i + 1, ll_row)
											END IF
										END IF
								END CHOOSE
							End IF
							
						LOOP WHILE(ll_cnt>0)		
						
			            idw_data[3].object.validkey[i] = ls_auto_validkey
			
					Case ls_crt_kind_code[3]   //AutoSeq
						
                        ls_auto_validkey = ""
						//Order Sequence
						Select to_char(seq_auto_validkey.nextval)
						  Into :ls_auto_validkey
						  From dual;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, " Sequence Error(seq_auto_validkey)")
							RollBack;
							ii_rc = -1				
							Return 
						End If				

			            idw_data[3].object.validkey[i] = ls_auto_validkey
						
					Case ls_crt_kind_code[4]   //자원관리Resource
						
					Case ls_crt_kind_code[5]   //고객대체				
						
				End Choose                
				
            ls_validkey[i]     = Trim(idw_data[3].object.validkey[i])			
			  	ls_vpasswd[i]      = Trim(idw_data[3].object.vpassword[i])
				ls_validkey_loc[i] = Trim(idw_data[3].object.validkey_loc[i])
     		   If IsNull(ls_validkey[i])     Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i])      Then ls_vpasswd[i] = ""
				If IsNull(ls_validkey_loc[i]) Then ls_validkey_loc[i] = ""
				
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, '인증KEY')
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				
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
					f_msg_usr_err(9000, is_title, "인증KEY [" + ls_validkey[i]+ "]가 중복됩니다.")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					return
				End if

				//인증KEY 중복 check  
				//적용시작일과 적용종료일의 중복일자를 막는다. 
				select count(validkey)
				  into :ll_cnt
				  from validinfo
				 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				   and validkey = :ls_validkey[i]
				   and svccod = :ls_svccod;
						  
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
					Return 
				End If
				
				If ll_cnt > 0 Then
					f_msg_usr_err(9000, is_title, "인증KEY [" + ls_validkey[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
					idw_data[3].SetFocus()
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3					
					return 
				End if
	 
 				ls_n_auth_method[i] = Trim(idw_data[3].object.auth_method[i])
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""				 

				IF ls_validitem_yn = 'Y' Then	
					
					Choose Case ls_crt_kind_h	
						Case ls_crt_kind_code[1]   //수동Manual
							
						Case ls_crt_kind_code[2]   //AutoRandom

							ls_auto_validitem = ""							
							//validitem(H323id) 생성에 따른 prefix 및 길이 Check
							IF isnull(ls_prefix_h) or ls_prefix_h = "" Then
								ls_prefix_h= ""
								li_random_length = ll_length_h
							Else
								li_random_length = ll_length_h - LenA(ls_prefix_h)
							END IF
									
							DO  //validitem random 생성
							   ls_auto_validitem = ls_prefix_h + fs_get_randomize_v20(li_random_length)

                               ll_cnt = 0
							   IF MidA(ls_n_auth_method[i],7,4) = "H323" Then
				
									select count(validkey)
									  into :ll_cnt
									  from validinfo
									 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
										   ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
										   :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
									   and validitem3 = :ls_n_validitem3[i]
									   and svccod = :ls_svccod;									 
									   
									If sqlca.sqlcode < 0 Then
										f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
										Return 
									End If
									   
									IF ll_cnt = 0 Then
										//자동랜던발생한 validitem(h323id) 중 같은 validitem(h323id)가 있는지 check			
										CHOOSE CASE i
											CASE 1  // Row가 1행일때 
												IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", i + 1, ll_row)
											CASE ll_row // Row가 맨 마지막
												IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", 1, i -1)
											CASE ELSE	  
												IF  ll_row > 1 THEN
													ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", 1, i -1)
													IF  ll_cnt > 0 THEN
													else
														ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", i + 1, ll_row)
													END IF
												END IF
										END CHOOSE
									
									End IF
								End IF  
								 
							LOOP WHILE(ll_cnt>0)		
							
							idw_data[3].object.validitem3[i] = ls_auto_validitem

						Case ls_crt_kind_code[3]   //AutoSeq							
							
							ls_auto_validitem = ""							
							//Order Sequence
							 Select to_char(seq_auto_validitem.nextval)
							  Into :ls_auto_validitem
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Sequence Error(seq_auto_validitem)")
								RollBack;
								ii_rc = -1				
								Return 
							End If				
	
							idw_data[3].object.validitem3[i] = ls_auto_validitem
							
						Case ls_crt_kind_code[4]   //자원관리Resource
							
						Case ls_crt_kind_code[5]   //고객대체
						
					End Choose
				End IF	 
				
				ls_n_langtype[i]  = Trim(idw_data[3].object.langtype[i])
				ls_n_validitem2[i] = idw_data[3].object.validitem2[i]
				ls_n_validitem3[i] = idw_data[3].object.validitem3[i]
				ls_n_validitem1[i] = idw_data[3].object.validitem1[i]
				If IsNull(ls_n_langtype[i]) Then ls_n_langtype[i] = ""
				If IsNull(ls_n_validitem2[i]) Then ls_n_validitem2[i] = ""				
				If IsNull(ls_n_validitem3[i]) Then ls_n_validitem3[i] = ""							
				If IsNull(ls_n_validitem1[i]) Then ls_n_validitem1[i] = ""										
			
			    //인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
			    ll_cnt = 0
        	    IF MidA(ls_n_auth_method[i],7,4) = "H323" Then

					 select count(validkey)
					  into :ll_cnt
					  from validinfo
				     where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						   ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						   :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
                       and validitem3 = :ls_n_validitem3[i]
		    		   and svccod = :ls_svccod;
					   
					If sqlca.sqlcode < 0 Then
						f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
						Return 
					End If
					   
					If ll_cnt > 0 Then
						f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("validitem3")
						ii_rc = -3					
						return 
					End if
				
					//입력한 validitem(h323id) 중 같은 validitem(h323id)가 있는지 check			
					CHOOSE CASE i
						CASE 1  // Row가 1행일때 
							IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", i + 1, ll_row)
						CASE ll_row // Row가 맨 마지막
							IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", 1, i -1)
						CASE ELSE	  
							IF  ll_row > 1 THEN
								ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", 1, i -1)
								IF  ll_long > 0 THEN
								else
									ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", i + 1, ll_row)
								END IF
							END IF
					END CHOOSE
				
					If ll_long > 0 Then
						// messagebox(validitem3(h323id)중복)	
						f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3[i]+ "]가 중복됩니다.")
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("validitem3")
						ii_rc = -3
						return
					End if
					
				End IF  
			
				//khpark add 2005-07-08 start(착신전환부가서비스추가)
				ls_callforwardno[i] = Trim(idw_data[3].object.callforwardno[i])
				ls_password[i] = Trim(idw_data[3].object.password[i])
				ls_callingnum_all[i] = Trim(idw_data[3].object.callingnum[i])
				If IsNull(ls_callforwardno[i]) or ls_callforwardno[i] = "" Then
					ls_callforwardno[i] = ""
				Else
					ls_callforward_info = "Y"
				End IF
				If IsNull(ls_password[i]) Then ls_password[i] = ""
				If IsNull(ls_callingnum_all[i]) Then ls_callingnum_all[i] = ""
				//khpark add 2005-07-08 end
			
			
				//kem add 2005-10-13 (서버ip/port# 추가)
				ls_gkid1[i] = idw_data[3].Object.gkid[i]
				ls_validitem[i] = idw_data[3].Object.validitem[i]
				ls_subseq[i] = idw_data[3].Object.subseq[i]
				
				If IsNull(ls_gkid1[i]) Then ls_gkid1[i] = ""
				If IsNull(ls_validitem[i]) Then ls_validitem[i] = ""
				If IsNull(ls_subseq[i]) Then ls_subseq[i] = ""
				//kem add 2005-10-13 end
				
			Next
			
			//khpark add 2005-07-08 start
			//착신전환 부가서비스 품목 선택했을 경우 착신전환번호 한건 이상은 꼭 입력해야한다.
			CHOOSE CASE ls_callforward_type   
				CASE ls_callforward_code[1],ls_callforward_code[2],ls_callforward_code[3]      //착신전환부가서비스유형일때 
					If ls_callforward_info <> "Y" Then
						f_msg_usr_err(9000, is_title, "착신전환부가서비스유형 품목 선택 시~r~n~r~n착신전환번호를  한건 이상은 입력하셔야합니다.!!")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(1)
						idw_data[3].ScrollToRow(1)
						idw_data[3].SetColumn("callforwardno")
						ii_rc = -3					
						return 						
					End If					
			END CHOOSE
			//khpark add 2005-07-08 end			
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

		//개통처리 확정 로직
		If is_data[3]='Y' Then
			
			//2005-08-08 Modify kem  Start
			//선불제 충전정책 판매금액 및 기본료 계산 후 적용
			//선불 모델에 따른 충전금액 결정
			Select nvl(price,0)
			  Into :ldc_price
			  From salepricemodel
			 where pricemodel  = :ls_pricemodel;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT Error(salepricemodel)")
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
				f_msg_sql_err(is_title, is_caller + "SELECT Error(refillpolicy)")
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
				f_msg_sql_err(is_title, is_caller + "Select Error(PARTNERMST)-관리대상대리점" )
				RollBack;
				Return
			End If
			
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
				   :ls_refilltype[1], :ldc_price, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt, 
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
			Insert Into contractdet(orderno, itemcod, contractseq, bil_fromdt,bil_todt)
			    Values(:ll_orderno, :ls_itemcod[i], :ll_contractseq, to_date(:ls_bil_fromdt,'yyyy-mm-dd'),:ld_item_todt[i]);
					 
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
						 customerid, svccod, priceplan, 
						 orderno, contractseq, langtype,
						 auth_method, validitem1, validitem2, validitem3,
						 crt_user, updt_user, crtdt, updtdt, pgm_id, 
						 validkey_loc, gkid, validitem, subseq)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_customerid, :ls_svccod, :ls_priceplan,
					    :ll_orderno, :ll_contractseq, :ls_n_langtype[i],
					    :ls_n_auth_method[i], :ls_n_validitem1[i], :ls_n_validitem2[i], :ls_n_validitem3[i],
					    :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id, 
						 :ls_validkey_loc[i], :ls_gkid1[i], :ls_validitem[i], :ls_subseq[i]);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
					ii_rc = -1						
					RollBack;
					Return 
				End If
				
				If ls_crt_kind[i] = ls_crt_kind_code[4]  Then   //인증KEY 인증KeyType이 자원관리인 경우만 처리
				
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
					  and  validkey_type = :ls_validkey_type[i] ;
					
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

				If ls_crt_kind_h = ls_crt_kind_code[4]  Then   //validitem3(H323ID) KeyType이 자원관리인 경우만 처리
				
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
					Where  validkey    = :ls_n_validitem3[i]
					  and  validkey_type = :ls_validkey_type_h;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(Validkeymst)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
				
					Insert Into validkeymst_log ( validkey, seq, status, actdt,
														   customerid, contractseq, partner, crt_user,
														   crtdt, pgm_id )
												Values ( :ls_n_validitem3[i], seq_validkeymstlog.nextval, :ls_validkeystatus, to_date(:ls_requestdt,'yyyy-mm-dd'),
														   :ls_customerid, :ll_contractseq, :ls_reg_partner, :gs_user_id,
														   sysdate, :ls_pgm_id );
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(Validkeymst_log)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
					
				End If
				
			   //khpark add 2005-07-07 start(착신전환부가서비스)
	            CHOOSE CASE ls_callforward_type   
					CASE ls_callforward_code[1]   //착신전환일반유형일때 
						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );
									 
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 

						End IF
							
					CASE ls_callforward_code[2]     //착신전환비밀번호인증일때

						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );

							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 

						End IF						
						
					CASE ls_callforward_code[3]     //착신전환발신번호인증일때
						
						For j = 1 To UpperBound(ls_callingnum[])
							ls_callingnum[j] = ''							
						Next
						
						ll_callingnum_cnt = fi_cut_string(ls_callingnum_all[i], ";" , ls_callingnum[])

						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );

							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 
							
							//발신가능전화번호 insert
							For j = 1 To ll_callingnum_cnt	
								Insert Into callforwarding_auth
								( seq,callingnum,
								  crt_user,crtdt, pgm_id ) 
								Values ( :ll_callforwarding_info_seq,:ls_callingnum[j],
									 :gs_user_id,sysdate, :ls_pgm_id );

								If SQLCA.SQLCode < 0 Then
									f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
									ii_rc = -1						
									RollBack;
									Return 
								End If									 
									 
							Next

						End IF						
						
				END CHOOSE
			    //khpark add 2005-07-07 start					
			Next			
        End if			
		
	    //2004-12-08 kem 수정
		//선납품목이 있는 경우 선납판매정보 Insert		
		//납부방식, 과금방식추가로 인한 로직추가  ohj 2005.03.18
		//납부방식  - 청구서발송방식, 직접입금방식		
		long ll_addunit, ll_use
		string ls_bilfromdt,ls_method, ls_additem //ls_direct_paytype
		Date ldt_date_next, ldt_date_next_1
		
		For ll_rows = 1 To idw_data[2].RowCount()
			ls_check[ll_rows] = Trim(idw_data[2].object.chk[ll_rows])
			If ls_check[ll_rows] = "Y" Then
				ls_prebil_yn = Trim(idw_data[2].Object.prebil_yn[ll_rows])
				
				If IsNull(ls_prebil_yn) Then ls_prebil_yn = 'N'
				
				If ls_prebil_yn = 'Y' Then
					ls_itemcod1        = Trim(idw_data[2].Object.itemcod[ll_rows])
				    ls_oneoffcharge_yn = Trim(idw_data[2].Object.oneoffcharge_yn[ll_rows])
				
					//서비스별 요율등록에서 선납품목에 대한 정보 가져오기
					SELECT UNITCHARGE
					     , ADDUNIT
						  , METHOD
						  , NVL(ADDITEM, '') ADDITEM
						  , nvl(validity_term,0) 
					  INTO :ldc_unitcharge
					     , :ll_addunit
						  , :ls_method
						  , :ls_additem
						  , :ll_validity_term
					  FROM PRICEPLAN_RATE2
					 WHERE PRICEPLAN = :ls_priceplan
					   AND ITEMCOD   = :ls_itemcod1
					   and fromdt = (select max(fromdt) 
					                  from priceplan_rate2
									  where priceplan = :ls_priceplan
									    and itemcod = :ls_itemcod1
										and fromdt <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
					
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
					If ls_method = ls_D_method Then  //daily 정액
					
						ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_use)
						
						SELECT :ldt_date_next_1 -1 
						  INTO :ldt_date_next
						  FROM DUAL                 ;					
					
					ElseIf ls_method = ls_M_method Then //월정액
						
						SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_use) -1
						  INTO :ldt_date_next
						  FROM DUAL;
					End If							
				
					//납부방식에 따른 구분.. 청구서발송방식(100) = 첫달만 insert, 직접입금방식(200) = 사용기간수만큼 
					If ls_direct_paytype = ls_paytype_method[1] Then
										
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
								
								If ls_method = ls_D_method Then  //daily 정액
								
									ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_use)
									
									SELECT :ldt_date_next_1 -1 
									  INTO :ldt_date_next
									  FROM DUAL                 ;									
									
								ElseIf ls_method = ls_M_method Then //월정액
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
				Set status    = :ls_quota_status,
					 updt_user = :gs_user_id,
					 updtdt    = sysdate,
					 pgm_id    = :ls_pgm_id					 
			 Where orderno   = :ll_orderno;
				
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

public subroutine uf_prc_db ();//b1w_reg_svc_actorder_6%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix, ls_validloc_gu
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_h323id, ls_ip_address, ls_result  
string ls_validkey_loc[], ls_temp, ls_result_code[], ls_quota_yn, ls_langtype
Long ll_orderno, ll_cnt, ll_contractseq, ll_related_orderno
Long i, j, ll_row, ll_long, ll_result_sec, ll_priority
Time lt_now_time, lt_after_time
String ls_n_auth_method[], ls_n_validitem3[], ls_n_validitem2[], ls_n_langtype[], ls_chk_yn, ls_n_validitem1[]
String ls_validkey_type[]//, ls_callforwardno[]
String ls_vpricecod, ls_acttype, ls_hopenum, ls_remark, ls_quota_status, ls_validkeystatus
String ls_validkey_msg //인증Key MSG
integer li_return, li_random_length 
String ls_validkey_typenm[],ls_crt_kind[],ls_prefix[],ls_auth_method[],ls_type[],ls_used_level[], ls_crt_kind_code[]
string ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ls_auth_method_h,ls_type_h,ls_used_level_h
Long ll_length[],ll_length_h
string ls_auto_validkey, ls_auto_validitem
string ls_callforward_type, ls_callforward_code[], ls_callforwardno[], ls_password[], ls_callingnum_all[], ls_callingnum[]
//khpark add 2005-07-07
string ls_callforward_info, ls_callforward_auth,ls_addition_itemcod, ls_item_method,ls_method[],ls_M_method,ls_D_method
long ll_callforwarding_info_seq, ll_addunit,ll_validity_term, ll_callingnum_cnt
date ld_call_fromdt, ld_call_todt, ld_item_todt[], ld_requestdt, ld_bil_fromdt
String ls_bil_fromdt


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_v20%save"  //장비임대 포함 수정,입중계출중계서비스추가,인증KeyType별추가,착신전환부가서비스추가
//		lu_dbmgr.is_caller   = "b1w_regsvc_actorder_v20%save"
//		lu_dbmgr.is_title    = is_title
//		lu_dbmgr.idw_data[1] = dw_cond                   //입력정보
//		lu_dbmgr.idw_data[2] = dw_detail2                //품목정보
//		lu_dbmgr.idw_data[3] = dw_detail		         //인증정보
//		lu_dbmgr.is_data[1]  = gs_user_id
//		lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[3]  = is_act_gu                 //개통처리 check
//		lu_dbmgr.is_data[4]  = is_cus_status             //고객상태
//		lu_dbmgr.is_data[5]  = is_svctype                //svctype
//		lu_dbmgr.is_data[6]  = string(il_validkey_cnt)   //인증KEY갯수
//		lu_dbmgr.is_data[7]  = is_type          		 //MVNO svctype
//		lu_dbmgr.is_data[8]  = is_inout_svc_gu    		 //입중계출중계 서비스여부
//		//khpark add 2005-07-07
//		lu_dbmgr.is_data[9]  = is_callforward_type    	 //착신전환부가서비스선택유형
//		lu_dbmgr.is_data[10]  = is_addition_itemcod    	 //착신전환품목서비스선택유형	

		//부가서비스품목 & 유형
		ls_callforward_type = is_data[9]
		ls_addition_itemcod = is_data[10]
		ls_callforward_info = "N" 
		
		If is_data[8] = 'Y' Then
			 ls_validkey_msg = 'Route-No.'
		Else
			 ls_validkey_msg = '인증KEY'
		End IF

		//부가서비스유형코드(착신전환부가서비스코드)
		ls_ref_desc = ""
		ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_callforward_code[])		

		//과금방식코드
		ls_temp = fs_get_control("B0", "P106" , ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_method[])
		ls_M_method  = ls_method[1]    //월정액
		ls_D_method  = ls_method[8]    //Daily정액		
		
		ls_customerid       = Trim(idw_data[1].object.customerid[1])
		ls_customerm        = Trim(idw_data[1].object.customernm[1])
		ls_orderdt          = String(idw_data[1].object.orderdt[1],'yyyymmdd')
		ls_requestdt        = String(idw_data[1].object.requestdt[1], 'yyyymmdd')
		ld_requestdt        = date(idw_data[1].object.requestdt[1])
		ls_svccod           = Trim(idw_data[1].object.svccod[1])		
		ls_priceplan        = Trim(idw_data[1].object.priceplan[1])
		ls_vpricecod        = Trim(idw_data[1].object.vpricecod[1])
		ls_prmtype          = Trim(idw_data[1].object.prmtype[1])
		ls_maintain_partner = Trim(idw_data[1].object.maintain_partner[1])
		ls_reg_partner      = Trim(idw_data[1].object.reg_partner[1])
		ls_sale_partner     = Trim(idw_data[1].object.sale_partner[1])
		ls_partner          = Trim(idw_data[1].object.partner[1])
		ls_contractno       = Trim(idw_data[1].object.contract_no[1])
		ll_priority         = Long(idw_data[1].object.priority[1])
		ls_acttype          = Trim(idw_data[1].object.acttype[1])
		ls_hopenum          = Trim(idw_data[1].object.hopenum[1])
		ls_remark           = Trim(idw_data[1].object.remark[1])
		ls_gkid             = Trim(idw_data[1].object.gkid[1])
//		ls_auth_method      = Trim(idw_data[1].object.auth_method[1])
		ls_h323id           = Trim(idw_data[1].object.h323id[1])
		ls_ip_address       = Trim(idw_data[1].object.ip_address[1])
		ls_langtype 	     = Trim(idw_data[1].object.langtype[1])
		ll_related_orderno  = Long(idw_data[1].object.related_order[1])
		ls_userid           = is_data[1]
		ls_pgm_id           = is_data[2]
		
		//2005-07-09 khpark add start
		ls_bil_fromdt    = String(idw_data[1].object.bil_fromdt[1], 'yyyymmdd')
		ld_bil_fromdt    = idw_data[1].object.bil_fromdt[1]		
		IF Isnull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_requestdt
		IF Isnull(ld_bil_fromdt) Then ld_bil_fromdt = ld_requestdt
		//2005-07-09 khpark add end
				
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
		
		//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";" , ls_crt_kind_code[])		
		
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

				ls_item_method = ''
				ll_addunit = 0
				ll_validity_term = 0
				
				select method,nvl(addunit,0),nvl(validity_term,0)
				  into :ls_item_method,:ll_addunit,:ll_validity_term
				 from priceplan_rate2
				where priceplan = :ls_priceplan
				 and itemcod = :ls_itemcod[j] 
				 and fromdt = (select max(fromdt)
								from priceplan_rate2
							   where priceplan = :ls_priceplan 
								and itemcod = :ls_itemcod[j]
								and fromdt <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
								
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select priceplan_rate2")				
					Return 
				ElseIF sqlca.sqlcode = 100 Then
					setnull(ld_item_todt[j])
				End If		
				
				setnull(ld_item_todt[j])   //item todt 계산
				Choose Case ls_item_method		
					Case ls_M_method     //월정액방식일경우		
						IF ll_validity_term > 0 Then
							ld_item_todt[j] = relativedate(fd_month_next(ld_bil_fromdt,ll_addunit*ll_validity_term),-1)
						End IF
						 
					Case ls_D_method     //Daily정액방식일경우						
						IF ll_validity_term > 0 Then
							ld_item_todt[j] = relativedate(ld_bil_fromdt,ll_addunit*ll_validity_term - 1)
						End IF
						
					Case Else
						 setnull(ld_item_todt[j])
				End Choose		
				//착신전환부가서비스 품목일때 callforwarding_info.todt 값 셋팅
				IF ls_itemcod[j] = ls_addition_itemcod Then
					ld_call_todt = ld_item_todt[j]
				End IF
				j ++
			End If
		Next
		
		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
		
		If li_return = -1 Then
		    return
		End IF

		//인증KEY 갯수가 0보다 클때 입력한 인증KEY check
		If integer(is_data[6]) > 0 Then
			
			ll_row = idw_data[3].RowCount()
			
			ls_temp = fs_get_control("B1","P400", ls_ref_desc)			
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_result_code[])
			
			//인증Key 관리상태(개통:20)
			ls_validkeystatus = ls_result_code[2]			
			
			For i = 1 To ll_row
				
				ls_validkey_type[i] = Trim(idw_data[3].object.validkey_type[i])
				
        		//인증KEY의 validkey_type에 따른 처리
				li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type[i],ls_validkey_typenm[i],ls_crt_kind[i],ls_prefix[i],ll_length[i],ls_auth_method[i],ls_type[i],ls_used_level[i]) 
				
				If li_return = -1 Then
				    return
				End IF
				
				Choose Case ls_crt_kind[i]		
					Case ls_crt_kind_code[1]   //수동Manual
						
					Case ls_crt_kind_code[2]   //AutoRandom
                        
						ls_auto_validkey = ""
				        //validkey 생성에 따른 prefix 및 길이 Check
						IF isnull(ls_prefix[i]) or ls_prefix[i] = "" Then
	                        ls_prefix[i] = ""
							li_random_length = ll_length[i]
						Else
     						li_random_length = ll_length[i] - LenA(ls_prefix[i])
						END IF
								
						DO  //validkey random 생성
							ls_auto_validkey = ls_prefix[i] + fs_get_randomize_v20(li_random_length)
			
							select count(validkey)
							  into :ll_cnt
							  from validinfo
							 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
									 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
									 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
							   and validkey = :ls_auto_validkey
							   and svccod = :ls_svccod;	
							   
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Select Error(validinfo check)")
								RollBack;
								ii_rc = -1				
								Return 
							End If				
	
	                        IF ll_cnt = 0 Then
								//자동발생 인증KEY중 같은 인증 KEY가 있는지 check			
								CHOOSE CASE i
									CASE 1  // Row가 1행일때 
										IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", i + 1, ll_row)
									CASE ll_row // Row가 맨 마지막
										IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", 1, i -1)
									CASE ELSE	  
										IF  ll_row > 1 THEN
											ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", 1, i -1)
											IF  ll_cnt > 0 THEN
											else
												ll_cnt = idw_data[3].Find(" validkey = '" + ls_auto_validkey + "'", i + 1, ll_row)
											END IF
										END IF
								END CHOOSE
							End IF
							
						LOOP WHILE(ll_cnt>0)		
						
			            idw_data[3].object.validkey[i] = ls_auto_validkey
			
					Case ls_crt_kind_code[3]   //AutoSeq
						
                        ls_auto_validkey = ""
						//Order Sequence
						Select to_char(seq_auto_validkey.nextval)
						  Into :ls_auto_validkey
						  From dual;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, " Sequence Error(seq_auto_validkey)")
							RollBack;
							ii_rc = -1				
							Return 
						End If				

			            idw_data[3].object.validkey[i] = ls_auto_validkey
						
					Case ls_crt_kind_code[4]   //자원관리Resource
						
					Case ls_crt_kind_code[5]   //고객대체				
						
				End Choose                
				
                ls_validkey[i]    = Trim(idw_data[3].object.validkey[i])			
			  	ls_vpasswd[i]     = Trim(idw_data[3].object.vpassword[i])
				ls_validkey_loc[i] = Trim(idw_data[3].object.validkey_loc[i])
     		   	If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
				If IsNull(ls_validkey_loc[i]) Then ls_validkey_loc[i] = ""
				
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, ls_validkey_msg)
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				
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
					f_msg_usr_err(9000, is_title, ls_validkey_msg+"[" + ls_validkey[i]+ "]가 중복됩니다.")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					return
				End if

				//인증KEY 중복 check  
				//적용시작일과 적용종료일의 중복일자를 막는다. 
				select count(validkey)
				  into :ll_cnt
				  from validinfo
				 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				   and validkey = :ls_validkey[i]
				   and svccod = :ls_svccod;
						  
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
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
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""				 

				IF ls_validitem_yn = 'Y' Then	
					
					Choose Case ls_crt_kind_h	
						Case ls_crt_kind_code[1]   //수동Manual
							
						Case ls_crt_kind_code[2]   //AutoRandom

							ls_auto_validitem = ""							
							//validitem(H323id) 생성에 따른 prefix 및 길이 Check
							IF isnull(ls_prefix_h) or ls_prefix_h = "" Then
								ls_prefix_h= ""
								li_random_length = ll_length_h
							Else
								li_random_length = ll_length_h - LenA(ls_prefix_h)
							END IF
									
							DO  //validitem random 생성
							   ls_auto_validitem = ls_prefix_h + fs_get_randomize_v20(li_random_length)

                               ll_cnt = 0
							   IF MidA(ls_n_auth_method[i],7,4) = "H323" Then
				
									select count(validkey)
									  into :ll_cnt
									  from validinfo
									 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
										   ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
										   :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
									   and validitem3 = :ls_n_validitem3[i]
									   and svccod = :ls_svccod;									 
									   
									If sqlca.sqlcode < 0 Then
										f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
										Return 
									End If
									   
									IF ll_cnt = 0 Then
										//자동랜던발생한 validitem(h323id) 중 같은 validitem(h323id)가 있는지 check			
										CHOOSE CASE i
											CASE 1  // Row가 1행일때 
												IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", i + 1, ll_row)
											CASE ll_row // Row가 맨 마지막
												IF  ll_row > 1 THEN	ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", 1, i -1)
											CASE ELSE	  
												IF  ll_row > 1 THEN
													ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", 1, i -1)
													IF  ll_cnt > 0 THEN
													else
														ll_cnt = idw_data[3].Find(" validitem3 = '" + ls_auto_validitem + "'", i + 1, ll_row)
													END IF
												END IF
										END CHOOSE
									
									End IF
								End IF  
								 
							LOOP WHILE(ll_cnt>0)		
							
							idw_data[3].object.validitem3[i] = ls_auto_validitem

						Case ls_crt_kind_code[3]   //AutoSeq							
							
							ls_auto_validitem = ""							
							//Order Sequence
							 Select to_char(seq_auto_validitem.nextval)
							  Into :ls_auto_validitem
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Sequence Error(seq_auto_validitem)")
								RollBack;
								ii_rc = -1				
								Return 
							End If				
	
							idw_data[3].object.validitem3[i] = ls_auto_validitem
							
						Case ls_crt_kind_code[4]   //자원관리Resource
							
						Case ls_crt_kind_code[5]   //고객대체
						
					End Choose
				End IF	 
				
				ls_n_langtype[i]  = Trim(idw_data[3].object.langtype[i])
				ls_n_validitem2[i] = idw_data[3].object.validitem2[i]
				ls_n_validitem3[i] = idw_data[3].object.validitem3[i]
				ls_n_validitem1[i] = idw_data[3].object.validitem1[i]
				If IsNull(ls_n_langtype[i]) Then ls_n_langtype[i] = ""
				If IsNull(ls_n_validitem2[i]) Then ls_n_validitem2[i] = ""				
				If IsNull(ls_n_validitem3[i]) Then ls_n_validitem3[i] = ""							
				If IsNull(ls_n_validitem1[i]) Then ls_n_validitem1[i] = ""										
			
			    //인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
			    ll_cnt = 0
        	    IF MidA(ls_n_auth_method[i],7,4) = "H323" Then

					 select count(validkey)
					  into :ll_cnt
					  from validinfo
				     where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						   ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						   :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
                       and validitem3 = :ls_n_validitem3[i]
		    		   and svccod = :ls_svccod;
					   
					If sqlca.sqlcode < 0 Then
						f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
						Return 
					End If
					   
					If ll_cnt > 0 Then
						f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("validitem3")
						ii_rc = -3					
						return 
					End if
				
					//입력한 validitem(h323id) 중 같은 validitem(h323id)가 있는지 check			
					CHOOSE CASE i
						CASE 1  // Row가 1행일때 
							IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", i + 1, ll_row)
						CASE ll_row // Row가 맨 마지막
							IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", 1, i -1)
						CASE ELSE	  
							IF  ll_row > 1 THEN
								ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", 1, i -1)
								IF  ll_long > 0 THEN
								else
									ll_long = idw_data[3].Find(" validitem3 = '" + ls_n_validitem3[i] + "'", i + 1, ll_row)
								END IF
							END IF
					END CHOOSE
				
					If ll_long > 0 Then
						// messagebox(validitem3(h323id)중복)	
						f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3[i]+ "]가 중복됩니다.")
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("validitem3")
						ii_rc = -3
						return
					End if
					
				End IF  
				
				//khpark add 2005-07-07 start(착신전환부가서비스추가)
				ls_callforwardno[i] = Trim(idw_data[3].object.callforwardno[i])
				ls_password[i] = Trim(idw_data[3].object.password[i])
				ls_callingnum_all[i] = Trim(idw_data[3].object.callingnum[i])
				If IsNull(ls_callforwardno[i]) or ls_callforwardno[i] = "" Then
					ls_callforwardno[i] = ""
				Else
					ls_callforward_info = "Y"
				End IF
				If IsNull(ls_password[i]) Then ls_password[i] = ""
				If IsNull(ls_callingnum_all[i]) Then ls_callingnum_all[i] = ""
				//khpark add 2005-07-07 end
				
			Next
			
			//khpark add 2005-07-07 start
			//착신전환 부가서비스 품목 선택했을 경우 착신전환번호 한건 이상은 꼭 입력해야한다.
			CHOOSE CASE ls_callforward_type   
				CASE ls_callforward_code[1],ls_callforward_code[2],ls_callforward_code[3]      //착신전환부가서비스유형일때 
					If ls_callforward_info <> "Y" Then
						f_msg_usr_err(9000, is_title, "착신전환부가서비스유형 품목 선택 시~r~n~r~n착신전환번호를  한건 이상은 입력하셔야합니다.!!")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(1)
						idw_data[3].ScrollToRow(1)
						idw_data[3].SetColumn("callforwardno")
						ii_rc = -3					
						return 						
					End If					
			END CHOOSE
			//khpark add 2005-07-07 start			
		End If
		
		//Order Sequence
		Select seq_orderno.nextval
		  Into :ll_orderno
		  From dual;
		  
		il_data[1] = ll_orderno		//ordernumber 넘겨줌	  
		
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
		
		
		
		//svcorder.related_orderno 가져오기 
		
		//선행 서비스가 있는 경우 선행 서비스 오더를 Update
   	Update svcorder set related_orderno = :ll_orderno where orderno = :ll_related_orderno;
	
		//svcorder insert
		//svcorder.order_type 필드 추가 - 어떤 신청인지 확인하는 목적 20070912 hcjung
		//svcorder.related_orderno 필드 추가 - 선행 서비스의 orderno 입력 20071022 hcjung
		Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt,
					status, svccod, priceplan, prmtype, maintain_partner, reg_partner, sale_partner,
					order_priority, hopenum, acttype, vpricecod, partner, ref_contractseq,
					crt_user, updt_user, crtdt, updtdt, pgm_id, remark,order_type,related_orderno)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_maintain_partner, :ls_reg_partner, :ls_sale_partner, 
				 :ll_priority, :ls_hopenum, :ls_acttype, :ls_vpricecod, :ls_partner, :ll_contractseq, 
				 :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id, :ls_remark, :ls_act_status,:ll_related_orderno);
				 	
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SVCORDER)")
			ii_rc = -1				
			RollBack;
			Return 
		End If

        //개통처리확정 시 로직
		If is_data[3]='Y' Then
			
			//Insert contractmst
			insert into contractmst
				( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
				   prmtype, maintain_partner, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_maintain_partner, :ls_reg_partner, :ls_sale_partner, :ls_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
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
			Insert Into contractdet(orderno, itemcod, contractseq, bil_fromdt,bil_todt)
			    Values(:ll_orderno, :ls_itemcod[i], :ll_contractseq, to_date(:ls_bil_fromdt,'yyyy-mm-dd'),:ld_item_todt[i]);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACDET)")
				ii_rc = -1					
				RollBack;
				Return 
			End If
		Next
		
		//인증KEY가 존재할 경우
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
				
				If ls_crt_kind[i] = ls_crt_kind_code[4]  Then   //인증KEY 인증KeyType이 자원관리인 경우만 처리
				
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
					  and  validkey_type = :ls_validkey_type[i] ;
					
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

				If ls_crt_kind_h = ls_crt_kind_code[4]  Then   //validitem3(H323ID) KeyType이 자원관리인 경우만 처리
				
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
					Where  validkey    = :ls_n_validitem3[i]
					  and  validkey_type = :ls_validkey_type_h;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(Validkeymst)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
				
					Insert Into validkeymst_log ( validkey, seq, status, actdt,
														   customerid, contractseq, partner, crt_user,
														   crtdt, pgm_id )
												Values ( :ls_n_validitem3[i], seq_validkeymstlog.nextval, :ls_validkeystatus, to_date(:ls_requestdt,'yyyy-mm-dd'),
														   :ls_customerid, :ll_contractseq, :ls_reg_partner, :gs_user_id,
														   sysdate, :ls_pgm_id );
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(Validkeymst_log)")
						ii_rc = -1						
						RollBack;
						Return 
					End If
					
				End If
				
			   //khpark add 2005-07-07 start(착신전환부가서비스)
	            CHOOSE CASE ls_callforward_type   
					CASE ls_callforward_code[1]   //착신전환일반유형일때 
						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );
									 
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 

						End IF
							
					CASE ls_callforward_code[2]     //착신전환비밀번호인증일때

						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );

							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 

						End IF						
						
					CASE ls_callforward_code[3]     //착신전환발신번호인증일때
						
						For j = 1 To UpperBound(ls_callingnum[])
							ls_callingnum[j] = ''							
						Next
						
						ll_callingnum_cnt = fi_cut_string(ls_callingnum_all[i], ";" , ls_callingnum[])

						If ls_callforwardno[i] <> "" Then
							//callforwarding_info_seq 가져 오기
							Select seq_callforwarding_info.nextval
							  Into :ll_callforwarding_info_seq
							  From dual;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
								ii_rc = -1			
								RollBack;
								Return 
							End If
							
							Insert Into callforwarding_info
								( seq,orderno,contractseq,itemcod,
								  addition_code,validkey,password,
								  callforwardno,fromdt,todt,
								  crt_user,crtdt, pgm_id ) 
							Values ( :ll_callforwarding_info_seq, :ll_orderno,:ll_contractseq,:ls_addition_itemcod,
							         :ls_callforward_type,:ls_validkey[i],:ls_password[i],
									 :ls_callforwardno[i],to_date(:ls_requestdt,'yyyy-mm-dd'),:ld_call_todt,
									 :gs_user_id,sysdate, :ls_pgm_id );

							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
								ii_rc = -1						
								RollBack;
								Return 
							End If									 
							
							//발신가능전화번호 insert
							For j = 1 To ll_callingnum_cnt	
								Insert Into callforwarding_auth
								( seq,callingnum,
								  crt_user,crtdt, pgm_id ) 
								Values ( :ll_callforwarding_info_seq,:ls_callingnum[j],
									 :gs_user_id,sysdate, :ls_pgm_id );

								If SQLCA.SQLCode < 0 Then
									f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
									ii_rc = -1						
									RollBack;
									Return 
								End If									 
									 
							Next

						End IF						
						
				END CHOOSE
			    //khpark add 2005-07-07 start				
			Next
			
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

on b1u_dbmgr_v20.create
call super::create
end on

on b1u_dbmgr_v20.destroy
call super::destroy
end on

