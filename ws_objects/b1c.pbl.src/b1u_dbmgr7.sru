$PBExportHeader$b1u_dbmgr7.sru
$PBExportComments$[kem] DB Manager/서비스신청(장비임대포함)
forward
global type b1u_dbmgr7 from u_cust_a_db
end type
end forward

global type b1u_dbmgr7 from u_cust_a_db
end type
global b1u_dbmgr7 b1u_dbmgr7

forward prototypes
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_03 ();
//b1w_reg_svc_actorder_pre_2%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_validkeyloc[], ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item           
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result 
string ls_validkey_loc, ls_coid, ls_temp, ls_result_code[], ls_pricemodel, ls_refilltype[], ls_langtype, ls_remark
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec
Time lt_now_time, lt_after_time    
Decimal ldc_first_refill_amt, ldc_first_sale_amt
String ls_quota_yn, ls_chk_yn, ls_quota_status
String ls_n_auth_method[],	ls_n_langtype[], ls_n_validitem2[], ls_n_validitem3[], ls_n_validitem1[] 

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre_2%save"    //선불제 - 장비모듈 추가
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
		
		ls_pricemodel = Trim(idw_data[1].object.pricemodel[1])
		ldc_first_refill_amt  = idw_data[1].object.first_refill_amt[1]
		ldc_first_sale_amt = idw_data[1].object.first_sale_amt[1]
		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""

		If IsNull(ldc_first_refill_amt) Then ldc_first_refill_amt = 0
		If IsNull(ldc_first_sale_amt) Then ldc_first_sale_amt = 0

		ls_ref_desc = ""
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		 
		//개통신청상태코드(단말기미등록)
		ls_quota_status = fs_get_control("B0", "P241", ls_ref_desc)

		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)		

		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		
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
				
				If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
				If IsNull(ls_validkeyloc[i]) Then ls_validkeyloc[i] = ""
				
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, "인증KEY")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				
				If ls_vpasswd[i] = "" Then
					f_msg_info(200, is_title, "인증Passwrod")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("vpassword")
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
				ls_n_langtype[i]  = Trim(idw_data[3].object.langtype[i])
				ls_n_validitem2[i] = idw_data[3].object.validitem2[i]
				ls_n_validitem3[i] = idw_data[3].object.validitem3[i]
				ls_n_validitem1[i] = idw_data[3].object.validitem1[i]
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""
				If IsNull(ls_n_langtype[i]) Then ls_n_langtype[i] = ""
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
				
				If ls_validkeyloc[i] = "" Then
					f_msg_info(200, is_title, "인증KeyLocation")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey_loc")
					ii_rc = -3					
					Return	
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
					pricemodel, first_refill_amt, first_sale_amt, remark)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner,
				 :ls_partner, :ll_contractseq, :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id,
				 :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :ls_remark);
							
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
				   prmtype, reg_partner, sale_partner,partner, maintain_partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
				   pricemodel, refillsum_amt, salesum_amt, balance, 
				   first_refill_amt, first_sale_amt, last_refill_amt, last_refilldt)
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner, :ls_maintain_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				   :gs_user_id, sysdate, :ls_pgm_id, :gs_user_id, sysdate, :ls_reg_prefix,
				   :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt,
				   :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt, to_date(:ls_requestdt,'yyyy-mm-dd'));
				   
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
				   refill_type, refill_amt, sale_amt,
				   remark, partner_prefix, crtdt, crt_user)
			values ( seq_refilllogseq.nextval, :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), 
				   :ls_refilltype[1], :ldc_first_refill_amt, :ldc_first_sale_amt,
				   '최초충전', :ls_reg_prefix, sysdate, :gs_user_id);
				   
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
					 crt_user, updt_user, crtdt, updtdt, pgm_id)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_gkid, :ls_customerid, :ls_svccod, :ls_priceplan, 
					   :ll_orderno, :ll_contractseq, :ls_n_langtype[i],
					   :ls_n_auth_method[i], :ls_n_validitem1[i], :ls_n_validitem2[i], :ls_n_validitem3[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
					ii_rc = -1						
					RollBack;
					Return 
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

public subroutine uf_prc_db_01 ();//b1w_reg_svc_actorder%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result  
string ls_validkey_loc[], ls_coid, ls_temp, ls_result_code[], ls_quota_yn, ls_langtype
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec, ll_priority
Time lt_now_time, lt_after_time
String ls_n_auth_method[], ls_n_validitem3[], ls_n_validitem2[], ls_n_langtype[], ls_chk_yn, ls_n_validitem1[]
String ls_vpricecod, ls_acttype, ls_hopenum, ls_remark, ls_quota_status

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_4%save"    //장비임대 포함 수정
//		lu_dbmgr.is_caller   = "b1w_reg_svc_actorder_4%save"
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

		// SYSCTL1T의 사업자 ID
		ls_ref_desc = ""
		ls_coid = fs_get_control("00","G200", ls_ref_desc)
		
		//작업결과(Server인증Key) 코드 
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","P300", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_result_code[])

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
			  	ls_validkey[i] = Trim(idw_data[3].object.validkey[i])
			  	ls_vpasswd[i] = Trim(idw_data[3].object.vpassword[i])

		   	    If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
				If ls_validkey[i] = "" Then
					f_msg_info(200, is_title, "인증KEY")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey")
					ii_rc = -3
					Return	
				End If
				If ls_vpasswd[i] = "" Then
					f_msg_info(200, is_title, "인증Passwrod")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("vpassword")
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
					f_msg_usr_err(9000, is_title, "인증KEY가 중복됩니다.")
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
					f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey[i]+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
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
			
				If ls_n_langtype[i] = "" Then
					f_msg_info(200, is_title, "멘트 언어")		
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("langtype")
					ii_rc = -3					
					Return 
				End If
				
				ls_validkey_loc[i]  = Trim(idw_data[3].object.validkey_loc[i])
				If IsNull(ls_validkey_loc[i]) Then ls_validkey_loc[i] = ""
				
				If ls_validkey_loc[i] = "" Then
					f_msg_info(200, is_title, "인증KeyLocation")		
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("validkey_loc")
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
				
					If MidA(ls_n_auth_method[i],7,1) <> 'E' Then
						
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
						 crt_user, updt_user, crtdt, updtdt, pgm_id)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_gkid, :ls_customerid, :ls_svccod, :ls_priceplan,
					   :ll_orderno, :ll_contractseq, :ls_n_langtype[i],
					   :ls_n_auth_method[i], :ls_n_validitem1[i], :ls_n_validitem2[i], :ls_n_validitem3[i],
					   :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
					ii_rc = -1						
					RollBack;
					Return 
				End If
				
			Next
			
			//여기서 commit을 해야지만 처리결과를 알수가 있다.(server에 validinfoserver trigger가 실행되어야 하므로)
			Commit;
		
			//개통처리까지 한 경우 - 대기초 후에 validinfoserver(h)정보를 읽어 와서 GK에 인증KEY가 
			//바로 처리 되었는지 결과를 바로 보여준다.

			If is_data[3] = 'Y' Then
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

public subroutine uf_prc_db ();//b1w_reg_rental_pop%hw_save
String ls_modelno, ls_serialno, ls_sale_flag, ls_adtype, ls_modelnm, ls_levelcod, ls_reg_prefixno, ls_gubun
String ls_sale_flag_hw, ls_itemcod1, ls_status, ls_ref_desc, ls_adstatus
Long   ll_hwseq, li_cnt, li_cnt1, ll_rows, i, ll_orderno


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_rental_pop%getdata"
//		lu_dbmgr.is_data[1] = is_orderno
//		lu_dbmgr.is_data[2] = is_customerid
      
		//Svcorder
		Select svccod,  priceplan, to_char(orderdt, 'yyyymmdd'), status, vpricecod, reg_partner
		  Into :is_data[3], :is_data[4], :is_data[5], :is_data[6], :is_data[7], :is_data[8]
		  From svcorder
		 Where to_char(orderno) = :is_data[1] and customerid = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
			Return 
		End If
		
		
	Case "b1w_reg_rental_pop%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.is_data[8] = is_reg_partner
//    lu_dbmgr.is_data[9] = is_svccod
//		lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_detail

		ls_modelno = Trim(idw_data[2].object.modelno[1])
		ls_serialno = Trim(idw_data[2].object.serialno[1])
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		 
		//장비임대코드(customer_hw)
		ls_sale_flag_hw = fs_get_control("E1", "A710", ls_ref_desc)
		ls_sale_flag    = '1'
		
		//장비재고상태코드
		ls_adstatus = fs_get_control("E1", "A103", ls_ref_desc)  //임대(출고)
		
			
		If IsNull(ls_modelno) Or ls_modelno = "" Then  //장비 등록할 내용이 없다는 것임
			f_msg_info(200, is_title, "모델번호")
			idw_data[1].SetRow(i)
			idw_data[1].ScrollToRow(i)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("modelno")
			ii_rc = -3
			Return	
		
		Else
			ll_orderno = Long(is_data[3])  //주문번호 Long값으로 바꾸기
			
			//svcorder에 status update
			Update svcorder
			Set    status = :ls_status
			Where  orderno = :ll_orderno ;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
				RollBack;
				Return 
			End If
			
			
			//장비가 여러건일 경우의 처리 때문에 로직 수정. 2003.11.05 김은미
			For ll_rows = 1 To idw_data[2].RowCount()
				ls_modelno    = Trim(idw_data[2].object.modelno[ll_rows])
				ls_serialno   = Trim(idw_data[2].object.serialno[ll_rows])
				ls_modelnm    = Trim(idw_data[2].object.modelnm[ll_rows])		//모델 명
				ls_adtype     = Trim(idw_data[2].object.adtype[ll_rows])
				ll_hwseq      = idw_data[2].object.adseq[ll_rows]
				ls_itemcod1   = idw_data[2].object.itemcod[ll_rows]
			
				//customer_hw insert
				Insert Into customer_hw (hwseq, rectype, customerid, sale_flag, adtype,
												 serialno, modelnm, orderno, crt_user, updt_user,
												 crtdt, updtdt, pgm_id, itemcod)
								Values ( seq_customerhwno.nextval, 'A', :is_data[1], :ls_sale_flag_hw, :ls_adtype,
											:ls_serialno, :ls_modelnm, :ll_orderno, :is_data[4], :is_data[4],
											sysdate, sysdate, :is_data[5], :ls_itemcod1);
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(CUSTOMER_HW)")
					RollBack;
					Return 
				End If
			
				//admst update	
				Update admst 
				Set sale_flag  = :ls_sale_flag, 
					 status     = :ls_adstatus,
					 saledt     = sysdate,
					 customerid = :is_data[1],
					 orderno    = :ll_orderno,
					 updt_user  = :is_data[4],
					 updtdt     = sysdate,
					 pgm_id     = :is_data[5]
				Where adseq    = :ll_hwseq;
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
				End If
			
				//admstlog insert		장비 이력
				Insert Into admstlog ( adseq, seq, action, status, actdt,
											  customerid, fr_partner, crt_user, crtdt, pgm_id)
								Values( :ll_hwseq, seq_admstlog.nextval, :is_data[7], :is_data[6], sysdate,
										  :is_data[1], :is_data[8], :is_data[4], sysdate,:is_data[5]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG)")
					RollBack;
					Return 
				End If
			
				ls_modelno  = ""
				ls_serialno = ""
				ls_modelnm  = ""
				ls_adtype   = ""
				ll_hwseq    = 0
				ls_itemcod1  = ""
			Next
		
		End IF
		
	Case "b1w_reg_rental_pop%inq"
		//장비 정보 가져오기
//		lu_dbmgr.is_data[1] = is_customerid
////		lu_dbmgr.is_data[2] = is_itemcod
//		lu_dbmgr.is_data[3]  = is_orderno
//		lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_detail

		//장비임대코드
		ls_sale_flag_hw = fs_get_control("E1", "A710", ls_ref_desc)
		      
		idw_data[2].ReSet()
		DECLARE customer_hw_c CURSOR FOR
			Select sale_flag, adtype, serialno
			From   customer_hw
			Where  customerid = :is_data[1]
			and    orderno    = :is_data[3]
			and    sale_flag  = :ls_sale_flag_hw;
		
		OPEN customer_hw_c;
		
		Do While(True)
			FETCH customer_hw_c INTO :ls_sale_flag, :ls_adtype, :ls_serialno;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(CUSTOMER_HW)")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			//모델 번호 가져옴
			Select a.modelno, a.adseq, b.modelnm
			Into :ls_modelno, :ll_hwseq, :ls_modelnm
			From admst a, admodel b
			Where a.modelno = b.modelno
			and   a.serialno = :ls_serialno;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
				Return 
			End If
			
			i = idw_data[2].InsertRow(0)
			
			idw_data[2].object.adseq[i]    = ll_hwseq
			idw_data[2].object.modelno[i]  = ls_modelno
			idw_data[2].object.modelnm[i]  = ls_modelnm
			idw_data[2].object.adtype[i]   = ls_adtype
			idw_data[2].object.serialno[i] = ls_serialno
			
		Loop
		
		CLOSE customer_hw_c;
		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_02 ();//b1w_reg_quotainfo_pop_2%insert
String ls_bilcycle
DateTime ldt_date[]
Date   ld_reqdt, ld_date[]
Time   lt_time
Dec    ldc_mod, ldc_qty, ldc_div[]
Long   li_cnt, i

//b1w_reg_quotainfo_pop_2%hw_save
String ls_modelno, ls_serialno, ls_status, ls_ref_desc, ls_sale_flag, ls_sale_flag_hw
String ls_gubun, ls_modelnm, ls_adtype, ls_itemcod1, ls_artrcod, ls_levelcod
String ls_reg_prefixno
Dec{6} lc_baseamt
Dec{2} ldc_beforeamt, ldc_deposit, ldc_saleamt
Long   ll_orderno, ll_rows, ll_hwseq, ll_quotacnt

//b1w_reg_quotainfo_pop_2%inq
String ls_sunsu, ls_deposit
Dec{6} lc_tramt, lc_beforeamt, lc_deposit


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_quotainfo_pop_2%getdata"
//		lu_dbmgr.is_data[1] = is_orderno
//		lu_dbmgr.is_data[2] = is_customerid
      
		//Svcorder
		Select svccod,  priceplan, to_char(orderdt, 'yyyymmdd'), status, vpricecod, reg_partner
		  Into :is_data[3], :is_data[4], :is_data[5], :is_data[6], :is_data[7], :is_data[8]
		  From svcorder
		 Where to_char(orderno) = :is_data[1] and customerid = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
			Return 
		End If
		
	Case "b1w_reg_quotainfo_pop_2%insert"
//		lu_dbmgr.ii_data[1] = li_cnt
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.ic_data[1] = ldc_saleamt
//		lu_dbmgr.idw_data[1] = dw_detail

		
		//같은 order no로 두번 Insert 될 수 없다.
	   Select count(*)
		Into :li_cnt
		From quota_info
		Where to_char(orderno) = :is_data[3] and customerid = :is_data[1] and itemcod = :is_data[2] 
				and rownum = 1;
		
				
		If li_cnt <> 0 Then
			f_msg_usr_err(3400, is_title, "분납정보 중복 error")
			Return
		End If
		
		//청구년월 SELECT
		SELECT BILCYCLE
		  INTO :ls_bilcycle
		  FROM BILLINGINFO
		 WHERE CUSTOMERID = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(BILLINGINFO)")
			Return
		End If
		
		If ls_bilcycle <> "" Then
			SELECT ADD_MONTHS(REQDT, 1)
			  INTO :ld_reqdt
			  FROM REQCONF
			 WHERE CHARGEDT = :ls_bilcycle;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(REQCONF)")
				Return
			End If	
		End If
		
		//금액을 나눈다.
		ldc_mod = Mod(ic_data[1],ii_data[1])
		ldc_qty = (ic_data[1] - ldc_mod) / ii_data[1]
		
		For i = 1 To ii_data[1] 
			ldc_div[i] = ldc_qty
		Next
		ldc_div[ii_data[1]] = ldc_div[ii_data[1]] + ldc_mod //마지막 달에 많이 부과
		
		//다음달 구하기
		ld_date[1] = ld_reqdt
		For i = 2 To ii_data[1] 
			ld_date[i] = fd_next_month(ld_date[i - 1], 0)
		Next
      

		lt_time = Time("00:00:00")
		For i =1 To ii_data[1]
			ldt_date[i] = DateTime(ld_date[i], lt_time)
		Next
		
		
		For i = 1 To ii_data[1]
			idw_data[1].InsertRow(i)
			idw_data[1].object.amt[i]        = ldc_div[i]
			idw_data[1].object.sale_amt[i]   = ldc_div[i]
			idw_data[1].object.customerid[i] = is_data[1]
			idw_data[1].object.orderno[i]    = Long(is_data[3])
			idw_data[1].object.sale_month[i] = DateTime(ld_date[i], lt_time)
			
			
			//Log
			idw_data[1].object.crt_user[i]   = is_data[4]
			idw_data[1].object.crtdt[i]      = fdt_get_dbserver_now()
			idw_data[1].object.pgm_id[i]     = is_data[5]
			idw_data[1].object.updt_user[i]  = is_data[4]
			idw_data[1].object.updtdt[i]     = fdt_get_dbserver_now()
			
		Next
		
	Case "b1w_reg_quotainfo_pop_2%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status 판매(출고)
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.is_data[8] = is_reg_partner
//    lu_dbmgr.is_data[9] = is_svccod
//		lu_dbmgr.idw_data[1] = idw_data[3]
//    lu_dbmgr.idw_data[2] = dw_detail2

		ls_modelno = Trim(idw_data[2].object.modelno[1])
		ls_serialno = Trim(idw_data[2].object.serialno[1])
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		
		//장비판매코드
		ls_sale_flag_hw = fs_get_control("E1", "A700", ls_ref_desc)
		ls_sale_flag    = '1'
		
							
		If IsNull(ls_modelno) Or ls_modelno = "" Then  //장비 등록할 내용이 없다는 것임
			f_msg_info(200, is_title, "모델번호")
			idw_data[1].SetRow(i)
			idw_data[1].ScrollToRow(i)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("modelno")
			ii_rc = -3
			Return	
		
		Else
			lc_baseamt    = idw_data[1].object.basicamt[1]
			ldc_beforeamt = idw_data[1].object.beforeamt[1]          //선수금
			ldc_deposit   = idw_data[1].object.deposit[1]            //채권보전료
			ls_gubun      = idw_data[1].object.gubun[1]              //할부포함여부
			
			If IsNull(ldc_beforeamt) Then ldc_beforeamt = 0
			If IsNull(ldc_deposit) Then ldc_deposit = 0
			If IsNull(ls_gubun) Then ls_gubun = "N"
			
			ll_orderno = Long(is_data[3])  //주문번호 Long값으로 바꾸기
			
			//svcorder에 status update
			Update svcorder
			Set    status = :ls_status
			Where  orderno = :ll_orderno ;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
				RollBack;
				Return 
			End If
			
			
			//장비가 여러건일 경우의 처리 때문에 로직 수정. 2003.11.05 김은미
			For ll_rows = 1 To idw_data[2].RowCount()
				ls_modelno    = Trim(idw_data[2].object.modelno[ll_rows])
				ls_serialno   = Trim(idw_data[2].object.serialno[ll_rows])
				ls_modelnm    = Trim(idw_data[2].object.modelnm[ll_rows])		//모델 명
				ls_adtype     = Trim(idw_data[2].object.adtype[ll_rows])
				ll_hwseq      = idw_data[2].object.adseq[ll_rows]
				ls_itemcod1    = idw_data[2].object.itemcod[ll_rows]
			
				//customer_hw insert
				Insert Into customer_hw (hwseq, rectype, customerid, sale_flag, adtype,
												 serialno, modelnm, orderno, crt_user, updt_user,
												 crtdt, updtdt, pgm_id, itemcod)
								Values ( seq_customerhwno.nextval, 'A', :is_data[1], :ls_sale_flag_hw, :ls_adtype,
											:ls_serialno, :ls_modelnm, :ll_orderno, :is_data[4], :is_data[4],
											sysdate, sysdate, :is_data[5], :ls_itemcod1);
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(CUSTOMER_HW)")
					RollBack;
					Return 
				End If
			
				//admst update	
				Update admst 
				Set sale_flag  = :ls_sale_flag, 
					 status     = :is_data[6],
					 saledt     = sysdate,
					 customerid = :is_data[1],
					 orderno    = :ll_orderno,
					 sale_amt   = :lc_baseamt,
					 updt_user  = :is_data[4],
					 updtdt     = sysdate,
					 pgm_id     = :is_data[5]
				Where adseq    = :ll_hwseq;
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
				End If
			
				//admstlog insert		장비 이력
				Insert Into admstlog ( adseq, seq, action, status, actdt, customerid, fr_partner,
											  crt_user, crtdt, pgm_id)
								Values( :ll_hwseq, seq_admstlog.nextval, :is_data[7], :is_data[6],
											sysdate, :is_data[1], :is_data[8], :is_data[4], sysdate,:is_data[5]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG)")
					RollBack;
					Return 
				End If
			
				ls_modelno  = ""
				ls_serialno = ""
				ls_modelnm  = ""
				ls_adtype   = ""
				ll_hwseq    = 0
				ls_itemcod1  = ""
			Next
			
			ll_quotacnt = idw_data[1].object.cnt[1]      //할부개월수
			ldc_saleamt = idw_data[1].object.saleamt[1]  //총판매금액
			
			If ll_quotacnt = 0 Then
				
				Insert Into oncepayment ( onceseq, customerid, orderno, paydt, payamt,
													crt_user, updt_user, crtdt, updtdt, pgm_id)
										values( seq_oncepayment.nextval, :is_data[1], :ll_orderno, sysdate, :ldc_saleamt,
													:is_data[4], :is_data[4], sysdate, sysdate, :is_data[5] );
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(일시불-ONCEPAYMENT)")
					RollBack;
					Return 
				End If
				
				ls_artrcod = fs_get_control("B5", "T203", ls_ref_Desc)   //대리점직수
				
				Insert Into partner_ardtl ( seq, partner, trdt, artrcod, tramt, org_partner,
													customerid, orderno, svccod, itemcod, crt_user, updt_user,
													crtdt, updtdt, pgm_id)
								Values( seq_partnerar.nextval, :is_data[8], sysdate, :ls_artrcod, :ldc_saleamt, :is_data[8],
											:is_data[1], :ll_orderno, :is_data[9], null, :is_data[4], :is_data[4],
											sysdate, sysdate, :is_data[5]) ;
											
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(대리점직수-PARTNER_ARDTL)")
					RollBack;
					Return 
				End If
			End If
				
			//대리점미수금(partner_ardtl) insert
			If ldc_beforeamt <> 0 Then
				ls_artrcod = fs_get_control("B1", "H200", ls_ref_desc)   //선수금 거래유형
				
				Insert Into partner_ardtl ( seq, partner, trdt, artrcod, tramt, org_partner,
													customerid, orderno, svccod, itemcod, crt_user, updt_user,
													crtdt, updtdt, pgm_id)
								Values( seq_partnerar.nextval, :is_data[8], sysdate, :ls_artrcod, :ldc_beforeamt, :is_data[8],
											:is_data[1], :ll_orderno, :is_data[9], null, :is_data[4], :is_data[4],
											sysdate, sysdate, :is_data[5]) ;
										
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(선수금-PARTNER_ARDTL)")
					RollBack;
					Return 
				End If
			End If
			
			If ls_gubun = "N" Then   //할부포함여부가 "N"일 경우 채권보전료 처리
				If ldc_deposit <> 0 Then
					ls_artrcod = fs_get_control("B1", "H201", ls_ref_desc)   //채권보전료 거래유형
				
					Insert Into partner_ardtl ( seq, partner, trdt, artrcod, tramt, org_partner,
														customerid, orderno, svccod, itemcod, crt_user, updt_user,
														crtdt, updtdt, pgm_id)
									Values( seq_partnerar.nextval, :is_data[8], sysdate, :ls_artrcod, :ldc_deposit, :is_data[8],
												:is_data[1], :ll_orderno, :is_data[9], null, :is_data[4], :is_data[4],
												sysdate, sysdate, :is_data[5]) ;
										
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(채권보전료-PARTNER_ARDTL)")
						RollBack;
						Return 
					End If
				End If
			End If
			
			
			//대리점의 여신관리여부가 Y일경우의 처리
			//총출고금액(tot_samt)에 ADMODEL의 이동기준금액을 update 한다.
			ls_ref_desc = ""
			ls_levelcod = fs_get_control("A1","C100", ls_ref_desc)
			
			Update partnermst
			Set tot_samt = nvl(tot_samt,0) + nvl((select nvl(a.sale_amt,0)
												             from admodel a, admst b
   														   where a.modelno = b.modelno 
 																  and b.orderno = :ll_orderno ),0),
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
			
		End IF
		
	Case "b1w_reg_quotainfo_pop_2%inq"
		//장비 정보 가져오기
//		lu_dbmgr.is_data[1] = is_customerid
////		lu_dbmgr.is_data[2] = is_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_detail2
      
		//장비판매코드
		ls_sale_flag_hw = fs_get_control("E1", "A700", ls_ref_desc)
		
		idw_data[2].ReSet()
		DECLARE customer_hw_c CURSOR FOR
			Select sale_flag, adtype, serialno
			From   customer_hw
			Where  customerid = :is_data[1]
			and    orderno    = :is_data[3]
			and    sale_flag  = :ls_sale_flag_hw;
		
		OPEN customer_hw_c;
		
		Do While(True)
			FETCH customer_hw_c INTO :ls_sale_flag, :ls_adtype, :ls_serialno;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(CUSTOMER_HW)")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			//모델 번호 가져옴
			Select a.modelno, a.adseq, b.modelnm
			Into :ls_modelno, :ll_hwseq, :ls_modelnm
			From admst a, admodel b
			Where a.modelno = b.modelno
			and   a.serialno = :ls_serialno;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
				Return 
			End If
			
			i = idw_data[2].InsertRow(0)
			
			idw_data[2].object.adseq[i]    = ll_hwseq
			idw_data[2].object.modelno[i]  = ls_modelno
			idw_data[2].object.modelnm[i]  = ls_modelnm
			idw_data[2].object.adtype[i]   = ls_adtype
			idw_data[2].object.serialno[i] = ls_serialno
			
		Loop
		
		CLOSE customer_hw_c;
		
		ls_sunsu = fs_get_control("B1", "H200", ls_ref_desc)
		
		DECLARE partner_ardtl_c CURSOR FOR
			Select artrcod, tramt
			From   partner_ardtl
			Where  customerid = :is_data[1] and orderno = :is_data[3] ;
			
		OPEN partner_ardtl_c;
		
		Do While(True)
			FETCH partner_ardtl_c INTO :ls_artrcod, :lc_tramt;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " CURSOR partner_ardtl_c")				
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
		
			ls_sunsu = fs_get_control("B1", "H200", ls_ref_desc)
			
			If ls_artrcod = ls_sunsu Then
				lc_beforeamt = lc_tramt
			End If
			
			ls_deposit = fs_get_control("B1", "H201", ls_ref_desc)
			
			If ls_artrcod = ls_deposit Then
				lc_deposit = lc_tramt
			End If
			
		Loop
		
		CLOSE partner_ardtl_c;
		
		idw_data[1].object.beforeamt[1] = lc_beforeamt
		idw_data[1].object.deposit[1]   = lc_deposit

End Choose
ii_rc = 0
Return 
end subroutine

on b1u_dbmgr7.create
call super::create
end on

on b1u_dbmgr7.destroy
call super::destroy
end on

