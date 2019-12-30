$PBExportHeader$b1u_dbmgr.sru
$PBExportComments$[ceusee] DB 접속
forward
global type b1u_dbmgr from u_cust_a_db
end type
end forward

global type b1u_dbmgr from u_cust_a_db
end type
global b1u_dbmgr b1u_dbmgr

forward prototypes
public subroutine uf_prc_db_05 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_05 ();//b1w_reg_svc_actorder_pre%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item           
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result 
string ls_validkey_loc, ls_coid, ls_temp, ls_result_code[], ls_pricemodel, ls_refilltype[], ls_langtype, ls_remark
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec
Time lt_now_time, lt_after_time    
Decimal ldc_first_refill_amt, ldc_first_sale_amt

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre%save"    //선불제
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
					status, svccod, priceplan, prmtype, reg_partner, sale_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id,
					pricemodel, first_refill_amt, first_sale_amt)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, 
				 :ls_partner, :ll_contractseq, :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id,
				 :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt );
							
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
				   prmtype, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
				   pricemodel, refillsum_amt, salesum_amt, balance, 
				   first_refill_amt, first_sale_amt, last_refill_amt, last_refilldt)
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner,
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
					 orderno, contractseq, validkey_loc,
					 auth_method, validitem1, validitem2, validitem3,
					 crt_user, updt_user, crtdt, updtdt, pgm_id)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_gkid, :ls_customerid, :ls_svccod, :ls_priceplan, 
					   :ll_orderno, :ll_contractseq, :ls_validkey_loc,
					   :ls_auth_method, :ls_customerm, :ls_ip_address, :ls_h323id,
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
		
	Case "b1w_reg_svc_actorder_pre_1%save"    //선불제- langtype 추가
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
					   :ll_orderno, :ll_contractseq, :ls_langtype,
					   :ls_auth_method, :ls_customerm, :ls_ip_address, :ls_h323id,
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
		

End Choose

ii_rc = 0

Return 
end subroutine

public subroutine uf_prc_db_03 ();String ls_suspenddt, ls_act_yn, ls_orderno, ls_customerid, ls_svccod, ls_remark, ls_suspend_type
String ls_sysdt, ls_activedt, ls_ref_desc, ls_act_status, ls_svctype, ls_svctype_post1, &
		 ls_suspend_status, ls_enter_status // hcjung
Long ll_contractseq, ll_svccnt, ll_contract

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_suspend%save"
	//lu_dbmgr.is_data[1] = is_suspendreq
	//lu_dbmgr.is_data[2] = is_suspend
	//lu_dbmgr.is_data[3] = gs_user_group
	//lu_dbmgr.is_data[4] = gs_user_id
	//lu_dbmgr.idw_data[1] = dw_detail
	

		ls_sysdt 		= String(fdt_get_dbserver_now(),'yyyymmdd')	
		ls_suspenddt 	= String(idw_data[1].object.suspenddt[1], 'yyyymmdd')
		ls_activedt 	= String(idw_data[1].object.contractmst_activedt[1], 'yyyymmdd')
		ls_remark 		= Trim(idw_data[1].object.remark[1])
		
		If IsNull(ls_suspenddt)  	Then ls_suspenddt 	= ""
		If IsNull(ls_activedt)  	Then ls_activedt 		= ""
		If IsNull(ls_remark) 		Then ls_remark 		= ""
		
		ls_svccod 		= Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid 	= Trim(idw_data[1].object.contractmst_customerid[1])
		
		If ls_suspenddt = "" Then
			f_msg_usr_err(200, is_title, "일시정지일자")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspenddt")
			ii_rc = -2
			Return
		End If
		
		If ls_suspenddt <= ls_activedt Then
			f_msg_usr_err(210, is_Title, "일시정지일은 개통일보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspenddt")
			ii_rc = -2
			Return
		End If		
//삼성렌탈 요청으로 당분간..  --2006-09-19
		
//		If ls_suspenddt < ls_sysdt Then
//			f_msg_usr_err(210, is_Title, "일시정지일은 오늘날짜 이상이여야 합니다.")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("suspenddt")
//			ii_rc = -2
//			Return
//		End If		
//		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

		ll_contractseq = idw_data[1].object.contractmst_contractseq[1]
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_suspenddt 
		   and contractseq = :ll_contractseq
		   and status = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "일시정지일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspenddt")
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
			Return  
		End If
		
		If ls_act_yn = "N" Then
			f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
			ii_rc = -2
			Return
		End If
		
		//Suspend 처리
		//svcorder update
		ls_orderno = String(idw_data[1].object.svcorder_orderno[1])
		Update svcorder
		 Set status = :is_data[2],  //일시정지 상태 변경
		     remark = :ls_remark,
			 updt_user = :is_data[4],
			 updtdt = sysdate,
			 pgm_id = :is_data[5]
		Where to_char(orderno) = :ls_orderno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
			Return  
		End If
		
		//contractmst update
		Update contractmst
		Set     status = :is_data[2],
				updt_user = :is_data[4],
				updtdt = sysdate,
				pgm_id = :is_data[5]
		Where contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
			Return  
		End If
		
		//suspendinfo insert
		Insert Into suspendinfo
				(seq, customerid, contractseq, fromdt, crt_user, updt_user,
				 crtdt, updtdt, pgm_id)
		Values (seq_suspendinfo.nextval, :ls_customerid, :ll_contractseq,
				  to_date(:ls_suspenddt, 'yyyy-mm-dd'), :is_data[4], :is_data[4],
				  sysdate, sysdate, :is_data[5]);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SUSPENDINFO)")
			Return  
		End If


		ls_ref_desc = ""
		ls_svctype_post1 = fs_get_control("B0","P103", ls_ref_desc)
		
		ls_svctype = Trim(idw_data[1].object.svcmst_svctype[1])
		
		If IsNull(ls_svctype) Then ls_svctype = ""
		
		If ls_svctype <> ls_svctype_post1 Then
		
			//인증정보 UPDATE
			Update validinfo
			Set use_yn = 'N',
				status = :is_data[2],
				updt_user = :is_data[4],
				updtdt = sysdate,
				pgm_id = :is_data[5]
			Where contractseq = :ll_contractseq
			  and use_yn = 'Y';
		//Where svccod = :ls_svccod and customerid = :ls_customerid;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
				Return  
			End If
			
		End If
		
	//일시정지 사유코드 추가로 로직변경 ohj 2004.12.21
	Case "b1dw_reg_svc_suspend_b%save"

		ls_sysdt        = String(fdt_get_dbserver_now(),'yyyymmdd')	
		ls_suspenddt    = String(idw_data[1].object.suspenddt[1], 'yyyymmdd')
		ls_activedt     = String(idw_data[1].object.contractmst_activedt[1], 'yyyymmdd')
		ls_remark       = Trim(idw_data[1].object.remark[1])
		ls_suspend_type = Trim(idw_data[1].object.suspend_type[1])
		
		If IsNull(ls_suspenddt)    Then ls_suspenddt    = ""
		If IsNull(ls_activedt)     Then ls_activedt     = ""
		If IsNull(ls_remark)       Then ls_remark       = ""
		If IsNull(ls_suspend_type) Then ls_suspend_type = ""
		
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
		
		If ls_suspenddt = "" Then
			f_msg_usr_err(200, is_title, "일시정지일자")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspenddt")
			ii_rc = -2
			Return
		End If
		
		If ls_suspenddt <= ls_activedt Then
			f_msg_usr_err(210, is_Title, "일시정지일은 개통일보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspenddt")
			ii_rc = -2
			Return
		End If		
		
		//삼성렌탈 요청으로 당분간..  --2006-09-19

//		If ls_suspenddt < ls_sysdt Then
//			f_msg_usr_err(210, is_Title, "일시정지일은 오늘날짜 이상이여야 합니다.")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("suspenddt")
//			ii_rc = -2
//			Return
//		End If
		
		If ls_suspend_type = "" Then
			f_msg_usr_err(200, is_title, "일시정지사유")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspend_type")
			ii_rc = -2
			Return
		End If		
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

		ll_contractseq = idw_data[1].object.contractmst_contractseq[1]
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_suspenddt 
		   and contractseq = :ll_contractseq
		   and status = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "일시정지일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspenddt")
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
			Return  
		End If
		
		If ls_act_yn = "N" Then
			f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
			ii_rc = -2
			Return
		End If
		
		//Suspend 처리
		//svcorder update
		ls_orderno = String(idw_data[1].object.svcorder_orderno[1])
		Update svcorder
		   Set status       = :is_data[2],  //일시정지 상태 변경
			    suspend_type = :ls_suspend_type,
		       remark       = :ls_remark,
			    updt_user    = :is_data[4],
			    updtdt       = sysdate,
			    pgm_id       = :is_data[5]
		 Where to_char(orderno) = :ls_orderno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
			Return  
		End If
		
		//contractmst update
		Update contractmst
		   Set status       = :is_data[2],
			    suspend_type = :ls_suspend_type,
				 updt_user    = :is_data[4],
				 updtdt       = sysdate,
				 pgm_id       = :is_data[5]
		 Where contractseq  = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
			Return  
		End If
		
		//suspendinfo insert
		Insert Into suspendinfo
				(seq, customerid, contractseq, fromdt, crt_user, updt_user,
				 crtdt, updtdt, pgm_id)
		Values (seq_suspendinfo.nextval, :ls_customerid, :ll_contractseq,
				  to_date(:ls_suspenddt, 'yyyy-mm-dd'), :is_data[4], :is_data[4],
				  sysdate, sysdate, :is_data[5]);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SUSPENDINFO)")
			Return  
		End If


		ls_ref_desc = ""
		ls_svctype_post1 = fs_get_control("B0","P103", ls_ref_desc)
		
		ls_svctype = Trim(idw_data[1].object.svcmst_svctype[1])
		
		If IsNull(ls_svctype) Then ls_svctype = ""
		
		If ls_svctype <> ls_svctype_post1 Then
		
			//인증정보 UPDATE
			Update validinfo
			Set use_yn = 'N',
				status = :is_data[2],
				updt_user = :is_data[4],
				updtdt = sysdate,
				pgm_id = :is_data[5]
			Where contractseq = :ll_contractseq
			  and use_yn = 'Y';
		//Where svccod = :ls_svccod and customerid = :ls_customerid;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
				Return  
			End If
			
		End If		
		
		// 개통 상태인 계약이 없으면 고객 상태를 일시정지로 변경한다. by hcjung (2007-05-15)
		//일시정지상태
		ls_suspend_status = fs_get_control("B0", "P206", ls_ref_desc)
		//계약 개통 상태
		ls_enter_status = fs_get_control("B0", "P223", ls_ref_desc)

		Select count(*)
		  Into :ll_contract
		  from contractmst
 		 Where customerid = :ls_customerid
		   and status = :ls_enter_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(contractmst)")
			Return  
		End If
			
		IF ll_contract = 0 THEN
			UPDATE customerm
			   SET status    = :ls_suspend_status,
				    updt_user = :gs_user_id,
				    updtdt    = sysdate
			 WHERE customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
End Choose

ii_rc = 0

Return 
end subroutine

public subroutine uf_prc_db_01 ();String ls_act_yn, ls_customerid, ls_payid, ls_enddt, ls_termdt, ls_ref_desc
String ls_orderno, ls_contractseq, ls_svccod, ls_termtype, ls_customerid_1, ls_act_status
String ls_sysdt, ls_activedt, ls_remark
String ls_svctype, ls_svctype_pre, ls_svctype_post, ls_svctype_post1
Long ll_cnt, ll_cnt1, ll_svccnt

ii_rc = -2
Choose Case is_caller
	Case "b1w_reg_svc_termprc%save"
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
		If IsNull(ls_termdt) Then ls_termdt = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		If IsNull(ls_activedt) Then ls_activedt = ""		
		If IsNull(ls_termtype) Then ls_termtype = ""
		If IsNull(ls_customerid) Then ls_customerid = ""		
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_remark) Then ls_remark = ""

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
			If ls_termdt <= ls_sysdt Then
				f_msg_usr_err(200, is_Title, "해지요청일은 오늘날짜 이상이여야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("termdt")
				Return
			End If		
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
	

	Case "b1w_reg_svc_termprc_batch%save"
//	lu_dbmgr.is_caller = "b1w_reg_svc_termprc%save"
//	lu_dbmgr.is_title = Title
//lu_dbmgr.is_data[1] = is_reqterm
//lu_dbmgr.is_data[2] = is_term
//lu_dbmgr.is_data[3] = gs_user_group
//lu_dbmgr.is_data[4] = is_requestactive
//lu_dbmgr.is_data[5] = is_termstatus
//lu_dbmgr.is_data[6] = gs_user_id
//lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
//lu_dbmgr.is_data[8] = ls_termdt
//lu_dbmgr.is_data[9] = ls_enddt
//lu_dbmgr.is_data[10] = ls_termtype
//lu_dbmgr.is_data[11] = ls_prm_check
//	lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.idw_data[2] = dw_ext

		//필수 항목 Check		
		ls_termdt = is_data[8]
		ls_enddt = is_data[9]
		ls_termtype = is_data[10]
		ls_remark = Trim(idw_data[2].object.remark[1])
		If IsNull(ls_termdt) Then ls_termdt = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		If IsNull(ls_termtype) Then ls_termtype = ""
		If IsNull(ls_remark) Then ls_remark = ""

		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)
		
		String ls_yn
		Long ll_rows
		ll_rows = idw_data[1].rowcount()
		Long ll_cur
		
FOR ll_cur=1 TO ll_rows
	
	ls_yn = idw_data[1].object.check_yn[ll_cur]
	
	IF ls_yn = "Y" THEN
		
		ls_activedt = String(idw_data[1].object.contractmst_activedt[ll_cur],'yyyymmdd')
		If IsNull(ls_activedt) Then ls_activedt = ""		
				

		ls_contractseq = String(idw_data[1].object.contractmst_contractseq[ll_cur])
		
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
		
		If ls_enddt = "" Then
			f_msg_usr_err(200, is_title, "과금종료일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("enddt")
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
		
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[ll_cur])
		ls_payid = Trim(idw_data[1].object.customerm_payid[ll_cur])
		
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
		ls_orderno = STring(idw_data[1].object.svcorder_orderno[ll_cur])
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
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[ll_cur])
		
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
	END IF
NEXT	

		
End Choose	
ii_rc = 0
end subroutine

public subroutine uf_prc_db_02 ();Long ll_cnt, ll_contractseq
String ls_orderno, ls_customerid, ls_orderdt, ls_requestdt,  ls_svccod
String ls_prmtype, ls_priceplan, ls_reg_partner, ls_maintain_partner, ls_settle_partner
String ls_sale_partner, ls_contractseq, ls_partner, ls_reqdt, ls_partnernm
String ls_status, ls_act_gu, ls_act_yn, ls_sysdt, ls_activedt
String ls_ref_desc, ls_act_status, ls_remark, ls_suspend_type
Long ll_svccnt 

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_suspendorder%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_suspendorder%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = is_suspendreq			  //일시정지신청code
//		lu_dbmgr.is_data[2] = is_reqactive
//		lu_dbmgr.is_data[3] = gs_user_group
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[6] = is_suspend              //일시정지code
//		lu_dbmgr.idw_data[1] = dw_detail

		//필수 항목 Check
		ls_sysdt = String(fdt_get_dbserver_now(),'yyyy-mm-dd')		
		ls_reqdt = String(idw_data[1].object.reqdt[1], 'yyyy-mm-dd')
		ls_partner = Trim(idw_data[1].object.partner[1])
      ls_activedt = idw_data[1].object.activedt[1]
		ls_requestdt = String(idw_data[1].object.reactivedt[1], 'yyyy-mm-dd')		//재개통 요청일
		ls_act_gu = Trim(idw_data[1].object.act_gu[1])  		//일시정지확정
		ls_remark = Trim(idw_data[1].object.remark[1])
		If IsNull(ls_reqdt) Then ls_reqdt = ""
		If IsNull(ls_partner) Then ls_partner = ""
		If IsNull(ls_requestdt) Then ls_requestdt = ""
		If IsNull(ls_act_gu) Then ls_act_gu = ""
		If IsNull(ls_remark) Then ls_remark = ""
		
		If ls_reqdt = "" Then
			f_msg_usr_err(200, is_title, "일시정지요청일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		If ls_reqdt <= ls_activedt Then
			f_msg_usr_err(210, is_Title, "일시정지요청일은 개통일보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		If ls_reqdt < ls_sysdt Then
			f_msg_usr_err(210, is_Title, "일시정지요청일은 오늘날짜 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

		ll_contractseq = idw_data[1].object.contractmst_contractseq[1]
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyy-mm-dd') >= :ls_reqdt
		   and contractseq = :ll_contractseq
		   and status = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "일시정지요청일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		
		If ls_partner = "" Then
			f_msg_usr_err(200, is_title, "수행처")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("partner")
			ii_rc = -2
			Return
		Else
			Select count(*)
			Into :ll_cnt
			From partnermst
			Where partner = :ls_partner and act_yn ='Y';
			
			If ll_cnt = 0 Then
				f_msg_info(100, is_title, "수행처")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("partner")
				ii_rc = -2
				Return 
			End If
		End If
  		
		If ls_requestdt <> "" Then
			If ls_reqdt >= ls_requestdt Then
				f_msg_usr_err(210, is_title, "일시정지요청일 보다 커야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("reactivedt")
				ii_rc = -2
				Return
			End If
		End If
		
		//중복 Check
		ls_contractseq = String(idw_data[1].object.contractmst_contractseq[1])
		ll_contractseq = Long(ls_contractseq)
		ls_customerid = Trim(idw_data[1].object.customerm_customerid[1])
		
		Select count(*)
		Into :ll_cnt
		From svcorder
		Where ref_contractseq = :ls_contractseq and status = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
			Return  
		End If
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, is_title, "고객번호 : " + ls_customerid + &
							  "~r계약 Seq : " + ls_contractseq + "는 ~r이미 신청되었습니다.")
			ii_rc = -2
			Return
		End If
	   
		//svcorder Insert
		ls_reqdt = String(idw_data[1].object.reqdt[1],'yyyymmdd')			//일시정지 시작요청일
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		
		//일시정시확정이면 일시정지처리 루틴까지 적용
		IF ls_act_gu = 'Y' Then
			ls_status = is_data[6]        //일시정지
		Else
			ls_status = is_data[1]        //일시정지신청
		End IF
		
		
		Insert Into svcorder
				 (orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
					prmtype, reg_partner, sale_partner, maintain_partner, settle_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id, remark)
		Values (seq_orderno.nextval, :ls_customerid, sysdate, to_date(:ls_reqdt, 'yyyy-mm-dd'),
					:ls_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, 
					:ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
					:ll_contractseq, :is_data[4], :is_data[4], sysdate, sysdate, :is_data[5], :ls_remark);

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " 일시정시 신청(SVCORDER)")
			Return  
		End If
		
		//재개통 날짜가 있으면 
		If ls_requestdt <> "" Then
			Select count(*)
			Into :ll_cnt
			From svcorder
			Where to_char(ref_contractseq) = :ls_contractseq and status = :is_data[2];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
				Return  
			End If
			
			If ll_cnt  = 0 Then			//중복 신청이 없을 경우
				Insert Into svcorder
				 	(orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
					prmtype, reg_partner, sale_partner, maintain_partner, settle_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id, remark)
				Values (seq_orderno.nextval, :ls_customerid, sysdate, to_date(:ls_requestdt, 'yyyy-mm-dd'),
							:is_data[2], :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, 
							:ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
							:ll_contractseq, :is_data[4], :is_data[4], sysdate, sysdate, :is_data[5], ls_remark);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " 재개통 신청(SVCORDER)")
					Return  
				End If
			End IF
		End If
		
		//일시정지확정 일때 일시정지처리 루틴 - khpark add-
		If ls_act_gu = 'Y' Then
			//해지 할 수 있는지 권한 여부 
			Select act_yn
			Into :ls_act_yn
			From partnermst
			Where partner = :is_data[3];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
				Return  
			End If
			
			If ls_act_yn = "N" Then
				f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
				ii_rc = -2
				Return
			End If
			
			//contractmst update
			Update contractmst
			Set     status = :ls_status,
					updt_user = :is_data[4],
					updtdt = sysdate,
					pgm_id = :is_data[5]
			Where contractseq = :ll_contractseq;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
				Return  
			End If

			//suspendinfo insert
			Insert Into suspendinfo
					(seq, customerid, contractseq, fromdt,
					 crt_user, updt_user, crtdt, updtdt, pgm_id)
			Values (seq_suspendinfo.nextval, :ls_customerid, :ll_contractseq, to_date(:ls_reqdt, 'yyyy-mm-dd'),
					  :is_data[4], :is_data[4], sysdate, sysdate, :is_data[5]);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(SUSPENDINFO)")
				Return  
			End If	
			
			//인증정보 UPDATE
//			ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
//			ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
			Update validinfo
			Set use_yn = 'N',
				status = :ls_status,
				updt_user = :is_data[4],
				updtdt = sysdate,
				pgm_id = :is_data[5]
			Where contractseq = :ll_contractseq
			  and use_yn = 'Y';
			//Where svccod = :ls_svccod and customerid = :ls_customerid;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
				Return  
			End If
			
		End If
		
	//일시정지 사유코드 추가로 로직변경 ohj 2004.12.22
	Case "b1dw_reg_svc_suspendorder_b%save"
		//필수 항목 Check
		ls_sysdt        = String(fdt_get_dbserver_now(),'yyyymmdd')		
		ls_reqdt        = String(idw_data[1].object.reqdt[1], 'yyyymmdd')
		ls_partner      = Trim(idw_data[1].object.partner[1])
      ls_activedt     = idw_data[1].object.activedt[1]
		ls_requestdt    = String(idw_data[1].object.reactivedt[1], 'yyyymmdd')		//재개통 요청일
		ls_act_gu       = Trim(idw_data[1].object.act_gu[1])  							//일시정지확정
		ls_remark       = Trim(idw_data[1].object.remark[1])
		ls_suspend_type = Trim(idw_data[1].object.suspend_type[1])

		If IsNull(ls_reqdt)        Then ls_reqdt        = ""
		If IsNull(ls_partner)      Then ls_partner      = ""
		If IsNull(ls_requestdt)    Then ls_requestdt    = ""
		If IsNull(ls_act_gu)       Then ls_act_gu       = ""
		If IsNull(ls_remark)       Then ls_remark       = ""
		If IsNull(ls_suspend_type) Then ls_suspend_type = ""
		
		If ls_reqdt = "" Then
			f_msg_usr_err(200, is_title, "일시정지요청일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		If ls_reqdt <= ls_activedt Then
			f_msg_usr_err(210, is_Title, "일시정지요청일은 개통일보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		If ls_reqdt < ls_sysdt Then
			f_msg_usr_err(210, is_Title, "일시정지요청일은 오늘날짜 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		If ls_suspend_type = "" Then
			f_msg_usr_err(200, is_title, "일시정지사유")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("suspend_type")
			ii_rc = -2
			Return
		End If
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

		ll_contractseq = idw_data[1].object.contractmst_contractseq[1]
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_reqdt
		   and contractseq = :ll_contractseq
		   and status = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "일시정지요청일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		
		If ls_partner = "" Then
			f_msg_usr_err(200, is_title, "수행처")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("partner")
			ii_rc = -2
			Return
		Else
			Select count(*)
			Into :ll_cnt
			From partnermst
			Where partner = :ls_partner and act_yn ='Y';
			
			If ll_cnt = 0 Then
				f_msg_info(100, is_title, "수행처")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("partner")
				ii_rc = -2
				Return 
			End If
		End If
  		
		If ls_requestdt <> "" Then
			If ls_reqdt >= ls_requestdt Then
				f_msg_usr_err(210, is_title, "일시정지요청일 보다 커야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("reactivedt")
				ii_rc = -2
				Return
			End If
		End If
		
		//중복 Check
		ls_contractseq = String(idw_data[1].object.contractmst_contractseq[1])
		ll_contractseq = Long(ls_contractseq)
		ls_customerid = Trim(idw_data[1].object.customerm_customerid[1])
		
		Select count(*)
		Into :ll_cnt
		From svcorder
		Where ref_contractseq = :ls_contractseq and status = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
			Return  
		End If
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, is_title, "고객번호 : " + ls_customerid + &
							  "~r계약 Seq : " + ls_contractseq + "는 ~r이미 신청되었습니다.")
			ii_rc = -2
			Return
		End If
	   
		//svcorder Insert
		ls_reqdt = String(idw_data[1].object.reqdt[1],'yyyymmdd')			//일시정지 시작요청일
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		
		//일시정시확정이면 일시정지처리 루틴까지 적용
		IF ls_act_gu = 'Y' Then
			ls_status = is_data[6]        //일시정지
		Else
			ls_status = is_data[1]        //일시정지신청
		End IF
		
		//일시정지사유 코드 추가
		Insert Into svcorder
				    ( orderno, customerid, orderdt, requestdt, status,
					   svccod, priceplan, prmtype, reg_partner, sale_partner,
						maintain_partner, settle_partner, partner, ref_contractseq, crt_user,
						updt_user, crtdt, updtdt, pgm_id, remark,
						suspend_type, order_type)
         Values ( seq_orderno.nextval, :ls_customerid, sysdate, to_date(:ls_reqdt, 'yyyy-mm-dd'), :ls_status
					 , :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner
					 , :ls_maintain_partner, :ls_settle_partner, :ls_partner,	:ll_contractseq, :is_data[4],
					   :is_data[4], sysdate,  sysdate, :is_data[5], :ls_remark,
						:ls_suspend_type, :ls_status);

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " 일시정시 신청(SVCORDER)")
			Return  
		End If
		
		//재개통 날짜가 있으면 
		If ls_requestdt <> "" Then
			Select count(*)
			Into :ll_cnt
			From svcorder
			Where to_char(ref_contractseq) = :ls_contractseq and status = :is_data[2];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
				Return  
			End If
			
			If ll_cnt  = 0 Then			//중복 신청이 없을 경우
				Insert Into svcorder
				 	(orderno, customerid, orderdt, requestdt, status,
					 svccod, priceplan, prmtype, reg_partner, sale_partner,
					 maintain_partner, settle_partner, partner, ref_contractseq, crt_user,
					 updt_user, crtdt, updtdt, pgm_id, remark, order_type)
				Values (seq_orderno.nextval, :ls_customerid, sysdate, to_date(:ls_requestdt, 'yyyy-mm-dd'), :is_data[2],
				        :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner,
						  :ls_maintain_partner, :ls_settle_partner, :ls_partner, :ll_contractseq, :is_data[4],
						  :is_data[4], sysdate, sysdate, :is_data[5], :ls_remark, :is_data[2]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " 재개통 신청(SVCORDER)")
					Return  
				End If
			End IF
		End If
		
		//일시정지확정 일때 일시정지처리 루틴 - khpark add-
		If ls_act_gu = 'Y' Then
			//해지 할 수 있는지 권한 여부 
			Select act_yn
			Into :ls_act_yn
			From partnermst
			Where partner = :is_data[3];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
				Return  
			End If
			
			If ls_act_yn = "N" Then
				f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
				ii_rc = -2
				Return
			End If
			
			//contractmst update
			//일시정지사유 코드 추가
			Update contractmst
			   Set status       = :ls_status,
				    suspend_type = :ls_suspend_type,
					 updt_user    = :is_data[4],
					 updtdt       = sysdate,
					 pgm_id       = :is_data[5]
			 Where contractseq  = :ll_contractseq;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
				Return  
			End If

			//suspendinfo insert
			Insert Into suspendinfo
					(seq, customerid, contractseq, fromdt,
					 crt_user, updt_user, crtdt, updtdt, pgm_id)
			Values (seq_suspendinfo.nextval, :ls_customerid, :ll_contractseq, to_date(:ls_reqdt, 'yyyy-mm-dd'),
					  :is_data[4], :is_data[4], sysdate, sysdate, :is_data[5]);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(SUSPENDINFO)")
				Return  
			End If	
			
			//인증정보 UPDATE
//			ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
//			ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
			Update validinfo
			Set use_yn = 'N',
				status = :ls_status,
				updt_user = :is_data[4],
				updtdt = sysdate,
				pgm_id = :is_data[5]
			Where contractseq = :ll_contractseq
			  and use_yn = 'Y';
			//Where svccod = :ls_svccod and customerid = :ls_customerid;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
				Return  
			End If
			
		End If
		
End Choose

ii_rc = 0 

Return
end subroutine

public subroutine uf_prc_db_06 ();
//b1w_reg_svc_actorder%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            //parkkh add
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result  //parkkh add 
string ls_validkey_loc, ls_coid, ls_temp, ls_result_code[], ls_quota_yn, ls_langtype
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec
Time lt_now_time, lt_after_time     //parkkh add

//b1w_reg_quotainfo_pop%insert
Dec ldc_div[], ldc_mod, ldc_qty
Date ld_date[], ldt_nextmonth
DateTime ldt_date[]
String ls_date[]
Time lt_time

//b1w_reg_quotainfo_pop%hw_save
String ls_modelno, ls_serialno, ls_sale_flag, ls_adtype, ls_modelnm, ls_levelcod, ls_reg_prefixno, ls_gubun
Long ll_hwseq, li_cnt, li_cnt1
Dec{6} lc_baseamt

//b1w_reg_svc_actorder_cl%save
String ls_vpricecod, ls_hopenum, ls_acttype, ls_remark, ls_quota_status, ls_sale_flag_hw
Long   ll_priority, ll_rows

//b1w_reg_quotainfo_pop_cl%insert
String ls_bilcycle, ls_artrcod, ls_itemcod1
Date   ld_reqdt
Dec{2} ldc_beforeamt, ldc_deposit, ldc_saleamt
Long   ll_quotacnt

//b1w_reg_svc_actorder_3%save   //modify khpark 2004.04.09
String ls_n_auth_method[], ls_n_validitem3[], ls_n_validitem2[], ls_n_langtype[], ls_chk_yn, ls_n_validitem1[]

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_cl%save"    //Com-n-Life
//		lu_dbmgr.is_caller   = "b1w_reg_svc_actorder_cl%save"
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
		
		//개통 신청 같은 서비스 & 가격정책이 있으면 신청 중복 error
//		Select count(*)
//		  Into :ll_cnt
//		  From svcorder
//		 Where customerid = :ls_customerid and svccod = :ls_svccod 
//		   and priceplan = :ls_priceplan and status = :ls_status;
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
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					ii_rc = -3					
					return 
				End if
	 
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
			ls_use_yn = 'Y'
			
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
					   :ll_orderno, :ll_contractseq, :ls_langtype,
					   :ls_auth_method, :ls_customerm, :ls_ip_address, :ls_h323id,
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
		
		//할부품목이 있는지 체크하여 svcorder의 상태 변경.
		For i = 1 To idw_data[2].Rowcount()
			ls_quota_yn    = Trim(idw_data[2].object.quota_yn[i])
			If ls_quota_yn = 'Y' Then
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
		
	Case "b1w_reg_svc_actorder_3%save"    //Com-n-Life 포함 다시 수정
//		lu_dbmgr.is_caller   = "b1w_reg_svc_actorder_3%save"
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
			If ls_quota_yn = 'Y' and ls_chk_yn = 'Y' Then
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
		
	Case "b1w_reg_quotainfo_pop_cl%getdata"
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
		
	Case "b1w_reg_quotainfo_pop_cl%insert"
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
		
	Case "b1w_reg_quotainfo_pop_cl%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.is_data[8] = is_reg_partner
//    lu_dbmgr.is_data[9] = is_svccod
//		lu_dbmgr.idw_data[1] = idw_data[3]
//    lu_dbmgr.idw_data[2] = dw_detail2

		ls_modelno = Trim(idw_data[2].object.modelno[1])
		ls_serialno = Trim(idw_data[2].object.serialno[1])
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
			
		If IsNull(ls_modelno) Or ls_modelno = "" Then  //장비 등록할 내용이 없다는 것임
			f_msg_info(200, is_title, "모델번호")
			idw_data[1].SetRow(i)
			idw_data[1].ScrollToRow(i)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("modelno")
			ii_rc = -3
			Return	
		
		Else
			ls_sale_flag = '1'   //판매
			ls_sale_flag_hw = '100'  //판매
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

End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db ();//b1w_reg_svc_actorder%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            //parkkh add
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result  //parkkh add 
string ls_validkey_loc, ls_coid, ls_temp, ls_result_code[], ls_remark, ls_langtype															 //parkkh add 
Long ll_orderno, ll_cnt, ll_contractseq
Long i, j, ll_row, ll_long, ll_result_sec
Time lt_now_time, lt_after_time     //parkkh add

//b1w_reg_quotainfo_pop%insert
Dec ldc_div[], ldc_mod, ldc_qty
Date ld_date[], ldt_nextmonth
DateTime ldt_date[]
String ls_date[]
Time lt_time

//b1w_reg_quotainfo_pop%hw_save
String ls_modelno, ls_serialno, ls_sale_flag, ls_adtype, ls_modelnm
Long ll_hwseq, li_cnt, li_cnt1
Dec{6} lc_baseamt

//"b1w_reg_quotainfo_pop_cl%inq"
String ls_artrcod, ls_sunsu, ls_deposit
Dec{6} lc_tramt, lc_beforeamt, lc_deposit


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_quotainfo_pop_1%getdata"
//		lu_dbmgr.is_data[1] = is_orderno
//		lu_dbmgr.is_data[2] = is_customerid
      
		//Svcorder
		Select svccod,  priceplan, to_char(orderdt, 'yyyymmdd'), status
		Into :is_data[3], :is_data[4], :is_data[5], :is_data[6]
		From svcorder
		Where to_char(orderno) = :is_data[1] and customerid = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
			Return 
		End If
		
	Case "b1w_reg_svc_actorder%save"    //통합빌링..
//		lu_dbmgr.is_caller = "b1w_reg_svc_actorder%save"
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
		ls_auth_method = Trim(idw_data[1].object.auth_method[1])
		ls_h323id = Trim(idw_data[1].object.h323id[1])
		ls_ip_address = Trim(idw_data[1].object.ip_address[1])
		ls_langtype = Trim(idw_data[1].object.langtype[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		ls_userid = is_data[1]
		ls_pgm_id = is_data[2]
		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""
			
		ls_ref_desc = ""
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)

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
				   and	validkey = :ls_validkey[i]
   				   and  svctype = :is_data[5];
						  
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
		
		//svccod insert
		Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt,
					status, svccod, priceplan, prmtype, reg_partner, sale_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id, remark)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, 
				 :ls_partner, :ll_contractseq, :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id, :ls_remark);
							
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
				   prmtype, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner,
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
					   :ll_orderno, :ll_contractseq, :ls_langtype, 
					   :ls_auth_method, :ls_customerm, :ls_ip_address, :ls_h323id,
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
		
	Case "b1w_reg_svc_actorder_x1%save"                       //xener
//		lu_dbmgr.is_caller = "b1w_reg_svc_actorder%save"
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
		ls_userid = is_data[1]
		ls_pgm_id = is_data[2]
		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""
			
		ls_ref_desc = ""
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)

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
				   and	validkey = :ls_validkey[i];
						  
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
					status, svccod, priceplan, prmtype, reg_partner, sale_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, 
				 :ls_partner, :ll_contractseq, :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id);
							
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
				   prmtype, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				   :gs_user_id, sysdate, :ls_pgm_id, :gs_user_id, sysdate, :ls_reg_prefix );
				   
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
					 orderno, contractseq, validkey_loc,
					 auth_method, validitem1, validitem2, validitem3,
					 crt_user, updt_user, crtdt, updtdt, pgm_id)
			    Values(:ls_validkey[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5],
				       :ls_gkid, :ls_customerid, :ls_svccod, :ls_priceplan,
					   :ll_orderno, :ll_contractseq, :ls_validkey_loc,
					   :ls_auth_method, :ls_customerm, :ls_ip_address, :ls_h323id,
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

		
	Case "b1w_reg_svc_actorder_cv%save"    //CVnet..
//		lu_dbmgr.is_caller = "b1w_reg_svc_actorder%save"
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

//		// SYSCTL1T의 사업자 ID
//		ls_ref_desc = ""
//		ls_coid = fs_get_control("00","G200", ls_ref_desc)
//		
//		//작업결과(Server인증Key) 코드 
//		ls_ref_desc = ""
//		ls_temp = fs_get_control("B1","P300", ls_ref_desc)
//		If ls_temp = "" Then Return 
//		fi_cut_string(ls_temp, ";" , ls_result_code[])

		ls_customerid = Trim(idw_data[1].object.customerid[1])
		ls_customerm = Trim(idw_data[1].object.customernm[1])
		ls_orderdt = String(idw_data[1].object.orderdt[1],'yyyymmdd')
		ls_requestdt = String(idw_data[1].object.requestdt[1], 'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svccod[1])
		ls_priceplan = Trim(idw_data[1].object.priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.prmtype[1])
		ls_partner = Trim(idw_data[1].object.partner[1])
		ls_reg_partner = ls_partner
		ls_sale_partner = ls_partner
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_gkid = Trim(idw_data[1].object.gkid[1])
		ls_auth_method = Trim(idw_data[1].object.auth_method[1])
		ls_h323id = Trim(idw_data[1].object.h323id[1])
		ls_ip_address = Trim(idw_data[1].object.ip_address[1])
		ls_userid = is_data[1]
		ls_pgm_id = is_data[2]
		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""
			
		ls_ref_desc = ""
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)

		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)		

		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		
		//서비스 중복 신청 Check
		//해지 상태가 아닌 같은 서비스 & 가격정책이 있으면 신청 중복 error
		Select count(*)
		Into :ll_cnt
		From contractmst
		Where customerid = :ls_customerid and svccod = :ls_svccod 
		 and priceplan = :ls_priceplan and status <> :ls_term_status;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
			Return 
		End If		
		
		If ll_cnt <> 0 Then
			ii_rc = -2
			Return
		End If
		
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
					status, svccod, priceplan, prmtype, reg_partner, sale_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, 
				 :ls_partner, :ll_contractseq, :ls_userid, :ls_userid, sysdate, sysdate, :ls_pgm_id);
							
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
				   prmtype, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner,
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
		
	//장비 등록 
	Case "b1w_reg_quotainfo_pop%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = ls_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.idw_data[1] = dw_cond

		ls_modelno = Trim(idw_data[1].object.modelno[1])
		ls_serialno = Trim(idw_data[1].object.serialno[1])
		
			
		If IsNull(ls_modelno) Or ls_modelno = "" Then  //장비 등록할 내용이 있다는 것임
		    ii_rc = 0
			Return
		Else
			ls_sale_flag = Trim(idw_data[1].object.sale_flag[1])
			ls_adtype = Trim(idw_data[1].object.adtype[1])
			ll_hwseq = idw_data[1].object.hwseq[1]
			lc_baseamt = idw_data[1].object.basicamt[1]
			ls_modelnm = Trim(idw_data[1].object.modelnm[1])		//모델 명
			
			//customer_hw insert
			Insert Into customer_hw (hwseq, rectype, customerid, sale_flag, adtype,
											 serialno, modelnm, orderno, crt_user, updt_user,
											 crtdt, updtdt, pgm_id, itemcod)
							Values ( seq_customerhwno.nextval, 'A', :is_data[1], :ls_sale_flag, :ls_adtype,
										:ls_serialno, :ls_modelnm, :is_data[3], :is_data[4], :is_data[4],
										sysdate, sysdate, :is_data[5], :is_data[2]);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(CUSTOMER_HW)")
				RollBack;
				Return 
			End If
			
			//admst update	
			Update admst 
			Set sale_flag = :ls_sale_flag, 
				 status = :is_data[6],
				 saledt = sysdate,
				 customerid = :is_data[1],
				 sale_amt = :lc_baseamt,
				 updt_user = :is_data[4],
				 updtdt = sysdate,
				 pgm_id = :is_data[5]
			Where adseq = :ll_hwseq;
			
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
				 
		End IF
	
   Case "b1w_reg_quotainfo_pop%inq"
		//장비 정보 가져오기
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.idw_data[1] = dw_cond
      
		
		Select sale_flag, adtype, serialno
		Into :ls_sale_flag, :ls_adtype, :ls_serialno
		From customer_hw
		Where itemcod = :is_data[2] and customerid = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(CUSTOMER_HW)")
			Return 
		End If
		
		//모델 번호 가져옴
		Select modelno, adseq
		Into :ls_modelno, :ll_hwseq
		From admst
		Where serialno = :ls_serialno;
		
		idw_data[1].object.hwseq[1] = ll_hwseq
		idw_data[1].object.modelno[1] = ls_modelno
		idw_data[1].object.adtype[1] = ls_adtype
		idw_data[1].object.serialno[1] = ls_serialno
		idw_data[1].object.sale_flag[1] = ls_sale_flag
		
	Case "b1w_reg_quotainfo_pop_cl%inq"
		//장비 정보 가져오기
//		lu_dbmgr.is_data[1] = is_customerid
////		lu_dbmgr.is_data[2] = is_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_detail2
      
		idw_data[2].ReSet()
		DECLARE customer_hw_c CURSOR FOR
			Select sale_flag, adtype, serialno
			From customer_hw
			Where customerid = :is_data[1] and orderno = :is_data[3];
		
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
		
	Case "b1w_reg_quotainfo_pop%insert"
//		lu_dbmgr.ii_data[1] = li_cnt
//		lu_dbmgr.id_data[1] = ld_startdate
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = ls_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = ls_startdate
//		lu_dbmgr.ic_data[1] = ldc_basicamt
//		lu_dbmgr.idw_data[1] = dw_detail
		//같은 Item Code와 order no로 두번 Insert 될 수 없다.
	   //1. 장비를 사용하지 않았거나 판매일때
		Select count(*)
		Into :li_cnt
		From quota_info
		Where to_char(orderno) = :is_data[3] and customerid = :is_data[1] and itemcod = :is_data[2] 
				and rownum = 1;
		
				
		//2. 임대일때
		Select count(*)
		Into :li_cnt1
		From customer_hw
		Where customerid = :is_data[1] and orderno = :is_data[3] and itemcod = :is_data[2]
				and rownum = 1;
		
		
		If li_cnt <> 0  Or li_cnt <> 0 Then
			f_msg_usr_err(3400, is_title, "")
			Return
		End If
		
		
		//금액을 나눈다.
		ldc_mod = Mod(ic_data[1],ii_data[1])
		ldc_qty = (ic_data[1] - ldc_mod) / ii_data[1]
		
		For i = 1 To ii_data[1] 
			ldc_div[i] = ldc_qty
		Next
		ldc_div[1] = ldc_div[1] + ldc_mod //첫달에 많이 부과
		
		//다음달 구하기
		ld_date[1] = id_data[1]
		For i = 2 To ii_data[1] 
			ld_date[i] = fd_next_month(ld_date[i - 1], 0)
		Next
      

		lt_time = Time("00:00:00")
		For i =1 To ii_data[1]
			ldt_date[i] = DateTime(ld_date[i], lt_time)
		Next
		
		
		For i = 1 To ii_data[1]
			idw_data[1].InsertRow(i)
			idw_data[1].object.amt[i] = ldc_div[i]
			idw_data[1].object.sale_amt[i] = ldc_div[i]
			idw_data[1].object.customerid[i] = is_data[1]
			idw_data[1].object.orderno[i] = Long(is_data[3])
			idw_data[1].object.itemcod[i] = is_data[2]
			idw_data[1].object.sale_month[i] =DateTime(ld_date[i], lt_time)
			
			
			//Log
			idw_data[1].object.crt_user[i] = is_data[4]
			idw_data[1].object.crtdt[i] = fdt_get_dbserver_now()
			idw_data[1].object.pgm_id[i] = is_data[5]
			idw_data[1].object.updt_user[i] = is_data[4]
			idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
			
		Next	
		
	
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_04 ();String ls_chg_priceplan, ls_priceplan, ls_reqdt, ls_customerid
String ls_bil_fromdt, ls_svccod, ls_activedt, ls_sale_partner, ls_partner
String ls_maintain_partner, ls_settle_partner, ls_reg_partner, ls_prmtype
String ls_contractno, ls_itemcod
String ls_sysdt, ls_act_status, ls_term_status, ls_ref_desc, ls_name[], ls_temp_status
String ls_validkey, ls_fromdt, ls_errmsg,	ls_sysdate
String ls_bil_todt_old,	ls_bil_tomon_old,	ls_bil_todt, ls_itemcod_old, ls_bil_fromdt_new
String ls_pre_reqdt
				
Date ld_reqdt, ld_pre_reqdt
Long ll_contractseq, i , ll_svccnt, ll_return, ll_boss03, ll_boss04, j, ll_non_valid_cnt, ll_priceplan_cnt
//Integer li_orderno

ii_rc  = -1
Choose Case is_caller
	Case "b1w_reg_chg_priceplan%save"
		//lu_dbmgr.is_data[1] = is_active
		//lu_dbmgr.is_data[2] = is_term
		//lu_dbmgr.is_data[3] = gs_user_group
		//lu_dbmgr.is_data[4] = gs_user_id
		//lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
		//lu_dbmgr.idw_data[1] = dw_detail2
		//lu_dbmgr.idw_data[2] = dw_detail
		//lu_dbmgr.idw_data[3] = dw_validkey   //khpark add
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)
		
		//해지신청 상태코드 가져오기
		ls_ref_desc =""
		ls_temp_status = fs_get_control("B0", "P221", ls_ref_desc)
		fi_cut_string(ls_temp_status, ";", ls_name[])		
		ls_term_status = ls_name[2]
		
		//필수 Check
		ls_chg_priceplan = Trim(idw_data[1].object.chg_priceplan[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ld_reqdt = Date(idw_data[1].object.reqdt[1])
		ls_reqdt = String(ld_reqdt ,'yyyymmdd')
		ls_bil_fromdt = String(idw_data[1].object.contractmst_bil_fromdt[1],'yyyymmdd')
		ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')		
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
		ll_contractseq = idw_data[1].object.contractmst_contractseq[1]
		
		If IsNull(ls_chg_priceplan) Then ls_chg_priceplan = ""
		If IsNull(ls_reqdt) Then ls_reqdt = ""
		
		If ls_chg_priceplan = "" Then
			f_msg_usr_err(200, is_title, "변경할 가격정책")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("chg_priceplan")
			ii_rc = -2
			Return
	    End If
	/*  Else
			If ls_priceplan = ls_chg_priceplan Then
				f_msg_usr_err(9000, is_title, "변경할 가격정책이 기존의 가격정책과 같습니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("chg_priceplan")
				ii_rc = -2
				Return
			End If
		End If */
		
		If ls_reqdt = "" Then
			f_msg_usr_err(200, is_title, "변경적용일자")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		ElseIf Long(ls_reqdt) <= Long(ls_bil_fromdt) Then
			f_msg_usr_err(210, is_title, "변경적용일자는 과금기간 시작날짜보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		If ls_reqdt <= ls_sysdt Then
			f_msg_usr_err(210, is_Title, "변경적용일자는 오늘날짜보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 변경요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_reqdt
		   and contractseq = :ll_contractseq
		   and status = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "변경적용일자는 해당가격정책의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
			
		
//		//khpark add start
//		//서비스 중복 신청 Check
//		//해지 상태가 아닌 같은 서비스 & 가격정책이 있으면 신청 중복 error
//		Select count(*)
//		Into :ll_svccnt
//		From contractmst
//		Where customerid = :ls_customerid and svccod = :ls_svccod 
//		 and priceplan = :ls_chg_priceplan and status <> :ls_term_status;
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller + " Select Error(contractmst)")
//			Return 
//		End If		
//		
//		If ll_svccnt <> 0 Then
//			f_msg_usr_err(210, is_Title, "변경할가격정책은 이미 사용중인 서비스 입니다.")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("chg_priceplan")
//			ii_rc = -2
//			Return
//		End IF
//		//khpark add end
				
		//contractmst update  -- 기존의 서비스 해지
		ld_pre_reqdt = fd_date_pre(ld_reqdt, 1)		//하루전날 과금종료일셋팅..
		Update contractmst
		Set status = :is_data[2],
			termdt = to_date(:ls_reqdt,'yyyy-mm-dd'),
			bil_todt = :ld_pre_reqdt,
			updt_user = :is_data[4],
			updtdt = sysdate,
			pgm_id = :is_data[5]
		Where contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
			Return  
		End If
		
		//contractmst insert  -- 신규 계약건 insert
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.contractmst_partner[1])
		ls_contractno = Trim(idw_data[1].object.contractmst_contractno[1])
		ls_activedt = String(idw_data[1].object.contractmst_activedt[1], 'yyyymmdd')
		
		Long ll_cnt
		Select seq_contractseq.nextval
		Into :ll_cnt
		From dual;
		
		Insert Into contractmst
				(contractseq, customerid, activedt, status,
				 svccod, priceplan, prmtype, reg_partner, sale_partner,
				 maintain_partner, settle_partner, partner,
				 bil_fromdt, change_flag, contractno, crt_user, updt_user,
				 crtdt, updtdt, pgm_id, bef_contractseq)
		Values (:ll_cnt, :ls_customerid, to_date(:ls_activedt, 'yyyy-mm-dd'), :is_data[1],
				 :ls_svccod, :ls_chg_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner,
				 :ls_maintain_partner, :ls_settle_partner, :ls_partner,
				 :ld_reqdt, 'C', :ls_contractno, :is_data[4], :is_data[4],
				 sysdate, sysdate, :is_data[5], :ll_contractseq);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			RollBack;
			Return 
		End If
		
		//Item 선택
		Long ll_orderno
		Select seq_orderno.nextval
		Into :ll_orderno
		From dual;

		For i = 1 to idw_data[2].RowCount()
			If idw_data[2].object.chk[i] = "Y" Then		//선택이면
				ls_itemcod = idw_data[2].object.itemcod[i]
				
				//CONTRACT Insert
				Insert Into contractdet (orderno, itemcod, contractseq)
			    Values(:ll_orderno, :ls_itemcod, :ll_cnt);
					
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTDET)")
					RollBack;
					Return 
				End If
			End If
			
		Next 
		
		//인터페이스에 delete 먼저 가고
	    Update validinfo
		Set todt = nvl(todt,to_date(:ls_reqdt, 'yyyy-mm-dd')),
			status = :ls_term_status,
			use_yn = 'N',
			updt_user = :gs_user_id,
			updtdt = sysdate,
			pgm_id = :is_data[5]
		Where contractseq = :ll_contractseq;
	  
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
			RollBack;
			Return 
		End If 
		
		//인터페이스에 create 정보 두번째로 간다.
		For i = 1 to idw_data[3].RowCount()
			
			ls_validkey = idw_data[3].object.validkey[i]
			ls_fromdt = string(idw_data[3].object.fromdt[i],'yyyymmdd')
			
			//ValidKey Insert & Update
			Insert into validinfo 
			 ( VALIDKEY,  FROMDT, STATUS, USE_YN,  VPASSWORD, VALIDITEM, 
			   GKID, CUSTOMERID, SVCCOD, SVCTYPE, PRICEPLAN, ORDERNO, CONTRACTSEQ,
			   PID, VALIDITEM1, VALIDITEM2, VALIDITEM3, AUTH_METHOD, VALIDKEY_LOC,
			   CRT_USER, UPDT_USER, CRTDT, UPDTDT, PGM_ID, langtype )
			 Select VALIDKEY, to_date(:ls_reqdt,'yyyy-mm-dd'), :ls_act_status, 'Y',  VPASSWORD, VALIDITEM, 
					GKID, CUSTOMERID, SVCCOD, SVCTYPE, :ls_chg_priceplan, :ll_orderno, :ll_cnt,
					PID, VALIDITEM1, VALIDITEM2, VALIDITEM3, AUTH_METHOD, VALIDKEY_LOC,
					:gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[5], langtype
			  From validinfo
			 Where contractseq = :ll_contractseq 
			   and validkey = :ls_validkey
			   and to_char(fromdt,'yyyymmdd') = :ls_fromdt;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(VALIDINFO)")
				RollBack;
				Return 
			End If
			
		Next
		
		//할부정보가 있으면 계약번호를 다시 update한다.
		Update quota_info
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq
		And    to_char(sale_month,'yyyymm') > to_char(:ld_pre_reqdt,'yyyymm');
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(QUOTA_INFO)")
			RollBack;
			Return 
		End If
		
		//2004.01.08 Update 수정...
		//기존계약마스타의 주문번호(orderno)를 얻는다.
		Long ll_orderno_old
		
		Select orderno
		Into   :ll_orderno_old
		From   admst
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
			RollBack;
			Return
		End If
		
		//장비가 있으면 계약번호를 다시 update한다.
		Update admst
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
			RollBack;
			Return 
		End If
		
		//고객H/W 정보가 있으면 주문번호를 다시 update한다.
		Update customer_hw
		Set    orderno     = :ll_orderno,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    orderno     = :ll_orderno_old;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMER_HW)")
			RollBack;
			Return 
		End If
		
		//즉시불(일시불) 정보가 있으면 주문번호를 다시 update한다.
		Update oncepayment
		Set    orderno     = :ll_orderno,
		       contractseq = : ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(ONCEPAYMENT)")
			RollBack;
			Return 
		End If
	   
	
	Case "b1w_reg_chg_priceplan_1%save"
		//lu_dbmgr.is_data[1] = is_active
		//lu_dbmgr.is_data[2] = is_term
		//lu_dbmgr.is_data[3] = gs_user_group
		//lu_dbmgr.is_data[4] = gs_user_id
		//lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
		//lu_dbmgr.idw_data[1] = dw_detail2
		//lu_dbmgr.idw_data[2] = dw_detail
		//lu_dbmgr.idw_data[3] = dw_validkey   //khpark add
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)
		
		//해지신청 상태코드 가져오기
		ls_ref_desc =""
		ls_temp_status = fs_get_control("B0", "P221", ls_ref_desc)
		fi_cut_string(ls_temp_status, ";", ls_name[])		
		ls_term_status = ls_name[2]
		
		//필수 Check
		ls_chg_priceplan = Trim(idw_data[1].object.chg_priceplan[1])
		ls_priceplan     = Trim(idw_data[1].object.contractmst_priceplan[1])
		ld_reqdt         = Date(idw_data[1].object.reqdt[1])
		ls_reqdt         = String(ld_reqdt ,'yyyymmdd')
		ls_bil_fromdt    = String(idw_data[1].object.contractmst_bil_fromdt[1],'yyyymmdd')
		ls_sysdt         = String(fdt_get_dbserver_now(),'yyyymmdd')		
		ls_svccod        = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid    = Trim(idw_data[1].object.contractmst_customerid[1])
		ll_contractseq   = idw_data[1].object.contractmst_contractseq[1]
		
		If IsNull(ls_chg_priceplan) Then ls_chg_priceplan = ""
		If IsNull(ls_reqdt) Then ls_reqdt = ""
		
		If ls_chg_priceplan = "" Then
			f_msg_usr_err(200, is_title, "변경할 가격정책")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("chg_priceplan")
			ii_rc = -2
			Return
	    End If
	/*  Else
			If ls_priceplan = ls_chg_priceplan Then
				f_msg_usr_err(9000, is_title, "변경할 가격정책이 기존의 가격정책과 같습니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("chg_priceplan")
				ii_rc = -2
				Return
			End If
		End If */
		
		If ls_reqdt = "" Then
			f_msg_usr_err(200, is_title, "변경적용일자")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		ElseIf Long(ls_reqdt) <= Long(ls_bil_fromdt) Then
			f_msg_usr_err(210, is_title, "변경적용일자는 과금기간 시작날짜보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		If ls_reqdt <= ls_sysdt Then
			f_msg_usr_err(210, is_Title, "변경적용일자는 오늘날짜보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 변경요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_reqdt
		   and contractseq = :ll_contractseq
		   and status      = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "변경적용일자는 해당가격정책의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
			
		
//		//khpark add start
//		//서비스 중복 신청 Check
//		//해지 상태가 아닌 같은 서비스 & 가격정책이 있으면 신청 중복 error
//		Select count(*)
//		Into :ll_svccnt
//		From contractmst
//		Where customerid = :ls_customerid and svccod = :ls_svccod 
//		 and priceplan = :ls_chg_priceplan and status <> :ls_term_status;
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller + " Select Error(contractmst)")
//			Return 
//		End If		
//		
//		If ll_svccnt <> 0 Then
//			f_msg_usr_err(210, is_Title, "변경할가격정책은 이미 사용중인 서비스 입니다.")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("chg_priceplan")
//			ii_rc = -2
//			Return
//		End IF
//		//khpark add end
				
		//contractmst update  -- 기존의 서비스 해지
		ld_pre_reqdt = fd_date_pre(ld_reqdt, 1)		//하루전날 과금종료일셋팅..
		Update contractmst
		Set    status    = :is_data[2],
			    termdt    = to_date(:ls_reqdt,'yyyy-mm-dd'),
			    bil_todt  = :ld_pre_reqdt,
			    updt_user = :is_data[4],
			    updtdt    = sysdate,
			    pgm_id    = :is_data[5]
		Where  contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
			Return  
		End If
		
		//contractmst insert  -- 신규 계약건 insert
		ls_svccod           = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid       = Trim(idw_data[1].object.contractmst_customerid[1])
		ls_priceplan        = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_prmtype          = Trim(idw_data[1].object.contractmst_prmtype[1])
		ls_reg_partner      = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner     = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner   = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_partner          = Trim(idw_data[1].object.contractmst_partner[1])
		ls_contractno       = Trim(idw_data[1].object.contractmst_contractno[1])
		ls_activedt         = String(idw_data[1].object.contractmst_activedt[1], 'yyyymmdd')
		
		
		Select seq_contractseq.nextval
		Into :ll_cnt
		From dual;
		
		
		Insert Into contractmst
				(contractseq, customerid, activedt, status,
				 svccod, priceplan, prmtype, reg_partner, sale_partner,
				 maintain_partner, settle_partner, partner,
				 bil_fromdt, change_flag, contractno, crt_user, updt_user,
				 crtdt, updtdt, pgm_id, bef_contractseq,
				 pricemodel, reg_prefixno, pointdt, curpoint, prepoint,
				 openusedt, lastusedt, refillsum_amt, usedsum_amt,
				 salesum_amt, balance, last_use_amt, first_refill_amt,
				 first_sale_amt, last_refill_amt, last_refilldt, enddt, remark )
		Select :ll_cnt, :ls_customerid, to_date(:ls_reqdt,'yyyy-mm-dd'), :is_data[1],
				 :ls_svccod, :ls_chg_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner,
				 :ls_maintain_partner, :ls_settle_partner, :ls_partner,
				 :ld_reqdt, 'C', :ls_contractno, :is_data[4], :is_data[4],
				 sysdate, sysdate, :is_data[5], :ll_contractseq,
				 pricemodel, reg_prefixno, pointdt, curpoint, prepoint,
				 openusedt, lastusedt, refillsum_amt, usedsum_amt,
				 salesum_amt, balance, last_use_amt, first_refill_amt,
				 first_sale_amt, last_refill_amt, last_refilldt, enddt, remark
		From   contractmst
		Where  contractseq = :ll_contractseq;
				 
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			RollBack;
			Return 
		End If
		
		//Item 선택
		Select seq_orderno.nextval
		Into :ll_orderno
		From dual;

		For i = 1 to idw_data[2].RowCount()
			If idw_data[2].object.chk[i] = "Y" Then		//선택이면
				ls_itemcod = idw_data[2].object.itemcod[i]
				
				//CONTRACT Insert
				Insert Into contractdet (orderno, itemcod, contractseq)
			    Values(:ll_orderno, :ls_itemcod, :ll_cnt);
					
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTDET)")
					RollBack;
					Return 
				End If
			End If
			
		Next 
		
		//인터페이스에 delete 먼저 가고
	   Update validinfo
		Set    todt = :ld_pre_reqdt,
			    status = :ls_term_status,
			    use_yn = 'N',
			    updt_user = :gs_user_id,
			    updtdt = sysdate,
			    pgm_id = :is_data[5]
		Where  contractseq = :ll_contractseq;
	  
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
			RollBack;
			Return 
		End If 
		
		//인터페이스에 create 정보 두번째로 간다.
		For i = 1 to idw_data[3].RowCount()
			
			ls_validkey = idw_data[3].object.validkey[i]
			ls_fromdt   = string(idw_data[3].object.fromdt[i],'yyyymmdd')
			
			//ValidKey Insert & Update
			Insert into validinfo 
			 ( VALIDKEY,  FROMDT, STATUS, USE_YN,  VPASSWORD, VALIDITEM, 
			   GKID, CUSTOMERID, SVCCOD, SVCTYPE, PRICEPLAN, ORDERNO, CONTRACTSEQ,
			   PID, VALIDITEM1, VALIDITEM2, VALIDITEM3, AUTH_METHOD, VALIDKEY_LOC,
			   CRT_USER, UPDT_USER, CRTDT, UPDTDT, PGM_ID, langtype )
			 Select VALIDKEY, to_date(:ls_reqdt,'yyyy-mm-dd'), :ls_act_status, 'Y',  VPASSWORD, VALIDITEM, 
					GKID, CUSTOMERID, SVCCOD, SVCTYPE, :ls_chg_priceplan, :ll_orderno, :ll_cnt,
					PID, VALIDITEM1, VALIDITEM2, VALIDITEM3, AUTH_METHOD, VALIDKEY_LOC,
					:gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[5], langtype
			  From validinfo
			 Where contractseq = :ll_contractseq 
			   and validkey    = :ls_validkey
			   and to_char(fromdt,'yyyymmdd') = :ls_fromdt;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(VALIDINFO)")
				RollBack;
				Return 
			End If
			
		Next
		
		//할부정보가 있으면 계약번호를 다시 update한다.
		Update quota_info
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq
		And    to_char(sale_month,'yyyymm') > to_char(:ld_pre_reqdt,'yyyymm');
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(QUOTA_INFO)")
			RollBack;
			Return 
		End If
		
		//2004.01.08 Update 수정...
		//기존계약마스타의 주문번호(orderno)를 얻는다.
		Select orderno
		Into   :ll_orderno_old
		From   admst
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
			RollBack;
			Return
		End If
		
		//장비가 있으면 계약번호를 다시 update한다.
		Update admst
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
			RollBack;
			Return 
		End If
		
		//고객H/W 정보가 있으면 주문번호를 다시 update한다.
		Update customer_hw
		Set    orderno     = :ll_orderno,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    orderno     = :ll_orderno_old;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMER_HW)")
			RollBack;
			Return 
		End If
		
		//즉시불(일시불) 정보가 있으면 주문번호를 다시 update한다.
		Update oncepayment
		Set    orderno     = :ll_orderno,
		       contractseq = : ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(ONCEPAYMENT)")
			RollBack;
			Return 
		End If
		
	Case "b1w_reg_chg_priceplan_2%save"
		//lu_dbmgr.is_data[1] = is_active
		//lu_dbmgr.is_data[2] = is_term
		//lu_dbmgr.is_data[3] = gs_user_group
		//lu_dbmgr.is_data[4] = gs_user_id
		//lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
		//lu_dbmgr.idw_data[1] = dw_detail2
		//lu_dbmgr.idw_data[2] = dw_detail
		//lu_dbmgr.idw_data[3] = dw_validkey   //khpark add
		//lu_dbmgr.idw_data[4] = dw_old		   //jhchoi add		
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)
		
		//해지신청 상태코드 가져오기
		ls_ref_desc =""
		ls_temp_status = fs_get_control("B0", "P221", ls_ref_desc)
		fi_cut_string(ls_temp_status, ";", ls_name[])		
		ls_term_status = ls_name[2]
		
		//필수 Check
		ls_chg_priceplan = Trim(idw_data[1].object.chg_priceplan[1])
		ls_priceplan     = Trim(idw_data[1].object.contractmst_priceplan[1])
		ld_reqdt         = Date(idw_data[1].object.reqdt[1])
		ls_reqdt         = String(ld_reqdt ,'yyyymmdd')
		ls_bil_fromdt    = String(idw_data[1].object.contractmst_bil_fromdt[1],'yyyymmdd')
		ls_sysdt         = String(fdt_get_dbserver_now(),'yyyymmdd')		
		ls_svccod        = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid    = Trim(idw_data[1].object.contractmst_customerid[1])
		ll_contractseq   = idw_data[1].object.contractmst_contractseq[1]
		
		If IsNull(ls_chg_priceplan) Then ls_chg_priceplan = ""
		If IsNull(ls_reqdt) Then ls_reqdt = ""
		
		If ls_chg_priceplan = "" Then
			f_msg_usr_err(200, is_title, "변경할 가격정책")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("chg_priceplan")
			ii_rc = -2
			Return
	    End If
		
		If ls_reqdt = "" Then
			f_msg_usr_err(200, is_title, "변경적용일자")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		ElseIf Long(ls_reqdt) <= Long(ls_bil_fromdt) Then
			f_msg_usr_err(210, is_title, "변경적용일자는 과금기간 시작날짜보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If
		
		If ls_reqdt <= ls_sysdt Then
			f_msg_usr_err(210, is_Title, "변경적용일자는 오늘날짜보다 커야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If		
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 변경요청일이 커야한다.
		Select count(*)
		  Into :ll_svccnt
		  from validinfo
 		 Where to_char(fromdt,'yyyymmdd') >= :ls_reqdt
		   and contractseq = :ll_contractseq
		   and status      = :ls_act_status;	
		   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select count Error(validinfo)")
			Return  
		End If
		
		If ll_svccnt > 0 Then
			f_msg_usr_err(210, is_Title, "변경적용일자는 해당가격정책의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -2
			Return
		End If	
		
		//인증 받지 않는 장비관리 서비스
		SELECT COUNT(*) INTO :ll_non_valid_cnt
		FROM SYSCOD2T
		WHERE GRCODE = 'BOSS06'
		AND USE_YN = 'Y'
		AND CODE = :ls_svccod;
		
		SELECT COUNT(*)  INTO :ll_priceplan_cnt
		FROM SYSCOD2T A, PRICEPLANMST B, PRICEPLAN_EQUIP C
		WHERE A.GRCODE = 'BOSS06'
			 AND A.USE_YN = 'Y'
			 AND A.CODE = :ls_svccod
			 AND A.CODE = B.SVCCOD
			 AND B.PRICEPLAN = C.PRICEPLAN
			 AND C.PRICEPLAN = :ls_priceplan;

		
//		IF  ll_non_valid_cnt > 0  and  ll_priceplan_cnt > 0 Then
//			f_msg_usr_err(210, is_Title, "이전 서비스에 연결된 장비가 있으므로 플랜변경 할 수 없습니다..")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("chg_priceplan")
//			ii_rc = -2
//			Return
//		End If	
		
		
				
		//contractmst update  -- 기존의 서비스 해지
		ld_pre_reqdt = fd_date_pre(ld_reqdt, 1)		//하루전날 과금종료일셋팅..
		Update contractmst
		Set    status    = :is_data[2],
			    termdt    = to_date(:ls_reqdt,'yyyy-mm-dd'),
			    bil_todt  = :ld_pre_reqdt,
			    updt_user = :is_data[4],
			    updtdt    = sysdate,
			    pgm_id    = :is_data[5]
		Where  contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
			Return  
		End If
		
		//2010.02.25 JHCHOI 변경. 하단에서 처리하도록 변경
//		//2009.10.20 JHCHOI 변경. 이미 할부아이템의 경우 해지일이 들어가 있으면 변경되지 않도록!!!
//		Update contractdet
//		Set    bil_todt  = :ld_pre_reqdt
//		Where  contractseq = :ll_contractseq;
//		//2009.11.30 JHCHOI 변경. 할부아이템이라도 BIL_TODT 변경해야한다. 박자연씨 요청.
//		//UPDATE CONTRACTDET
//		//SET	 BIL_TODT = :ld_pre_reqdt
//		//WHERE  CONTRACTSEQ = :ll_contractseq
//		//AND    BIL_TODT IS NULL;	
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTDET)")
//			Return  
//		End If		
		
		//contractmst insert  -- 신규 계약건 insert
		ls_svccod           = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_customerid       = Trim(idw_data[1].object.contractmst_customerid[1])
		ls_priceplan        = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_prmtype          = Trim(idw_data[1].object.contractmst_prmtype[1])
		ls_reg_partner      = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner     = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner   = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_partner          = Trim(idw_data[1].object.contractmst_partner[1])
		ls_contractno       = Trim(idw_data[1].object.contractmst_contractno[1])
		ls_activedt         = String(idw_data[1].object.contractmst_activedt[1], 'yyyymmdd')	
		
		Select seq_contractseq.nextval
		Into :ll_cnt
		From dual;	
		
		Insert Into contractmst
				(contractseq, customerid, activedt, status,
				 svccod, priceplan, prmtype, reg_partner, sale_partner,
				 maintain_partner, settle_partner, partner,
				 bil_fromdt, change_flag, contractno, crt_user, updt_user,
				 crtdt, updtdt, pgm_id, bef_contractseq,
				 pricemodel, reg_prefixno, pointdt, curpoint, prepoint,
				 openusedt, lastusedt, refillsum_amt, usedsum_amt,
				 salesum_amt, balance, last_use_amt, first_refill_amt,
				 first_sale_amt, last_refill_amt, last_refilldt, enddt, remark, related_contractseq )
		Select :ll_cnt, :ls_customerid, to_date(:ls_reqdt,'yyyy-mm-dd'), :is_data[1],
				 :ls_svccod, :ls_chg_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner,
				 :ls_maintain_partner, :ls_settle_partner, :ls_partner,
				 :ld_reqdt, 'C', :ls_contractno, :is_data[4], :is_data[4],
				 sysdate, sysdate, :is_data[5], :ll_contractseq,
				 pricemodel, reg_prefixno, pointdt, curpoint, prepoint,
				 openusedt, lastusedt, refillsum_amt, usedsum_amt,
				 salesum_amt, balance, last_use_amt, first_refill_amt,
				 first_sale_amt, last_refill_amt, last_refilldt, enddt, remark, related_contractseq
		From   contractmst
		Where  contractseq = :ll_contractseq;
				
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			RollBack;
			Return 
		End If	
				
      If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST.RELATED_CONTRACTSEQ)")
			RollBack;
			Return 
		End If		
		
		// DUMY ORDER INSERT -- 20071214 hcjung
		SELECT seq_orderno.nextval 
		INTO :ll_orderno 
		FROM dual;
//2010.04.22 수정. 이윤주 대리 요청. ORDERDT 는 요청일, REQUESTDT 는 변경요청일로 넣어달라고 함.		
//		insert into svcorder 
//		select :ll_orderno, customerid, orderdt, requestdt,'20', svccod, :ls_chg_priceplan,
//		pricemodel,prmtype,reg_prefixno,reg_partner,sale_partner,maintain_partner,settle_partner,
//		partner,:ll_cnt,termtype,suspend_type,'dumy order',first_refill_amt,first_sale_amt,order_priority,
//		hopenum,acttype,chgopt,vpricecod,bil_fromdt,direct_paytype,enddt,crt_user,updt_user,sysdate,sysdate,
//		pgm_id,'10',related_orderno, '' 
//		from svcorder 
//		where ref_contractseq = :ll_contractseq and order_type = '10';

		insert into svcorder 
		select :ll_orderno, customerid, TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'), TO_DATE(:ls_reqdt,'yyyy-mm-dd'), '20', svccod, :ls_chg_priceplan,
		pricemodel,prmtype,reg_prefixno,reg_partner,sale_partner,maintain_partner,settle_partner,
		partner,:ll_cnt,termtype,suspend_type,'dumy order',first_refill_amt,first_sale_amt,order_priority,
		hopenum,acttype,chgopt,vpricecod,bil_fromdt,direct_paytype,enddt,:is_data[4], :is_data[4],sysdate,sysdate,
		pgm_id,'10',related_orderno, '' 
		from svcorder 
		where ref_contractseq = :ll_contractseq and order_type = '10';

      If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(Dumy Order)")
			RollBack;
			Return 
		End If
		
		Update contractmst
		set related_contractseq = :ll_cnt
		where related_contractseq = :ll_contractseq;
				
      If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST.RELATED_CONTRACTSEQ)")
			RollBack;
			Return 
		End If
		
   	// service relation change -- 20071210 hcjung
		Update contractmst
		set related_contractseq = :ll_cnt
		where related_contractseq = :ll_contractseq;

//		For i = 1 to idw_data[2].RowCount()
//			If idw_data[2].object.chk[i] = "Y" Then		//선택이면
//				ls_itemcod = idw_data[2].object.itemcod[i]
//				
//				//CONTRACT Insert
//				Insert Into contractdet (orderno, itemcod, contractseq, bil_fromdt)
//			    Values(:ll_orderno, :ls_itemcod, :ll_cnt, to_date(:ls_reqdt,'yyyy-mm-dd'));
//					
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTDET)")
//					RollBack;
//					Return 
//				End If
//			End If
//			
//		Next 
		//2010.02.25일 변경함. 가격정책 변경시 할부아이템 시작일자, 종료일자 조정하기 위해서! jhchoi
		ls_pre_reqdt = STRING(ld_pre_reqdt, 'yyyymmdd')
		For i = 1 to idw_data[2].RowCount()
			If idw_data[2].object.chk[i] = "Y" Then		//선택이면
				ls_itemcod = idw_data[2].object.itemcod[i]
				
				ls_bil_todt_old	= ""
				ls_bil_tomon_old	= ""
				ls_bil_todt			= ""
				ls_bil_fromdt_new	= ""				
				
				FOR j = 1 TO idw_data[4].RowCount()		//기존 상세품목을 뒤진다. 아이템이 같다는 전제하에!
					ls_itemcod_old = idw_data[4].object.itemcod[j]
					
					ls_bil_todt_old	= ""
					ls_bil_tomon_old	= ""
					ls_bil_todt			= ""
					ls_bil_fromdt_new	= ""					
					
					IF ls_itemcod = ls_itemcod_old THEN
					
						SELECT TO_CHAR(BIL_TODT, 'YYYYMMDD'), TO_CHAR(BIL_TODT, 'YYYYMM')
						INTO   :ls_bil_todt_old, :ls_bil_tomon_old
						FROM   CONTRACTDET
						WHERE  CONTRACTSEQ = :ll_contractseq
						AND    ITEMCOD     = :ls_itemcod_old;
					
						IF IsNull(ls_bil_todt_old)  THEN ls_bil_todt_old  = "" 
						IF IsNull(ls_bil_tomon_old) THEN ls_bil_tomon_old = "" 					
					
						IF ls_bil_todt_old <> "" THEN		//BIL_TODT 가 NULL 이 아니면...즉 할부아이템 이란 소리
							IF ls_bil_todt_old > ls_pre_reqdt AND ls_bil_tomon_old > MidA(ls_pre_reqdt, 1, 6) THEN	//과금종료월이 해지월 보다 크면 날짜를 변경된 과금종료일의 다음달 1일로한다.
								SELECT TO_CHAR(ADD_MONTHS(TO_DATE(SUBSTR(:ls_pre_reqdt, 1, 6), 'YYYYMM'), 1), 'YYYYMM')||'01'
								INTO   :ls_bil_fromdt_new
								FROM   DUAL;	
									
								ls_bil_todt = ls_bil_todt_old
									
								EXIT
							END IF
						END IF
					END IF
				NEXT
				
				IF ls_bil_fromdt_new = "" THEN ls_bil_fromdt_new = ls_reqdt				
				
//				//CONTRACT Insert
//				Insert Into contractdet (orderno, itemcod, contractseq, bil_fromdt)
//			    Values(:ll_orderno, :ls_itemcod, :ll_cnt, to_date(:ls_reqdt,'yyyy-mm-dd'));
				 
				//CONTRACT Insert
				INSERT INTO CONTRACTDET
					( ORDERNO,		ITEMCOD,		CONTRACTSEQ,
					  BIL_FROMDT,	BIL_TODT )
				VALUES ( :ll_orderno, :ls_itemcod, :ll_cnt,
					      TO_DATE(:ls_bil_fromdt_new, 'YYYYMMDD'), TO_DATE(:ls_bil_todt, 'YYYYMMDD') );
					
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTDET NEW)")
					RollBack;
					Return 
				End If
			End If			
		Next 
		
		//2010.02.25 JHCHOI 변경. 이미 할부아이템의 경우 해지일이 들어가 있으면 상황봐서 변경되도록!!!
		FOR j = 1 TO idw_data[4].RowCount() 
			ls_itemcod_old = idw_data[4].object.itemcod[j]
			
			SELECT TO_CHAR(BIL_TODT, 'YYYYMMDD')
			INTO   :ls_bil_todt_old
			FROM   CONTRACTDET
			WHERE  CONTRACTSEQ = :ll_contractseq
			AND    ITEMCOD     = :ls_itemcod_old
			AND    BIL_TODT IS NOT NULL; // 2016-02-03 조건추가 RQ-YJ-UBS-201602-03 의거
			
			IF IsNull(ls_bil_todt_old)  THEN ls_bil_todt_old  = "" 
			
			IF ls_bil_todt_old <> "" THEN
				IF ls_bil_todt_old > ls_pre_reqdt THEN
					UPDATE CONTRACTDET
					SET    BIL_TODT 	 = :ld_pre_reqdt
					WHERE  CONTRACTSEQ = :ll_contractseq
					AND    ITEMCOD     = :ls_itemcod_old;
				END IF
			ELSE
				UPDATE CONTRACTDET
				SET    BIL_TODT = :ld_pre_reqdt
				WHERE  CONTRACTSEQ = :ll_contractseq
				AND    ITEMCOD     = :ls_itemcod_old;
			END IF				
						
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTDET)")
				RollBack;				
				Return  
			End If	
		NEXT			
		
		
		
		//인터페이스에 delete 먼저 가고
	   Update validinfo
		Set   // todt = :ld_pre_reqdt,   //2005.12.08 juede comment
				 todt = nvl(todt,to_date(:ls_reqdt, 'yyyy-mm-dd')), //2005.12.08 juede modify
			    status = :ls_term_status,
			    use_yn = 'N',
			    updt_user = :gs_user_id,
			    updtdt = sysdate,
			    pgm_id = :is_data[5]
		Where  contractseq = :ll_contractseq;
	  
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
			RollBack;
			Return 
		End If 
		
		//인터페이스에 create 정보 두번째로 간다.
		For i = 1 to idw_data[3].RowCount()
			
			ls_validkey = idw_data[3].object.validkey[i]
			ls_fromdt   = string(idw_data[3].object.fromdt[i],'yyyymmdd')
			
			//ValidKey Insert & Update
			Insert into validinfo 
			 ( VALIDKEY,  FROMDT, STATUS, USE_YN,  VPASSWORD, VALIDITEM, 
			   GKID, CUSTOMERID, SVCCOD, SVCTYPE, PRICEPLAN, ORDERNO, CONTRACTSEQ,
			   PID, VALIDITEM1, VALIDITEM2, VALIDITEM3, AUTH_METHOD, VALIDKEY_LOC,
			   CRT_USER, UPDT_USER, CRTDT, UPDTDT, PGM_ID, langtype )
			 Select VALIDKEY, to_date(:ls_reqdt,'yyyy-mm-dd'), :ls_act_status, 'Y',  VPASSWORD, VALIDITEM, 
					GKID, CUSTOMERID, SVCCOD, SVCTYPE, :ls_chg_priceplan, :ll_orderno, :ll_cnt,
					PID, VALIDITEM1, VALIDITEM2, VALIDITEM3, AUTH_METHOD, VALIDKEY_LOC,
					:gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[5], langtype
			  From validinfo
			 Where contractseq = :ll_contractseq 
			   and validkey    = :ls_validkey
			   and to_char(fromdt,'yyyymmdd') = :ls_fromdt;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(VALIDINFO)")
				RollBack;
				Return 
			End If

			// validkeymst 테이블 Update 2008-05006 hcjung
			UPDATE	validkeymst
			SET		orderno = :ll_orderno,
						contractseq = :ll_cnt,
						activedt	= to_date(:ls_reqdt,'yyyy-mm-dd'),
						updt_user = :gs_user_id,
						updtdt = sysdate
			WHERE 	validkey    = :ls_validkey;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(VALIDKEYMST)")
				RollBack;
				Return 
			End If
			
		Next
		
		//할부정보가 있으면 계약번호를 다시 update한다.
		Update quota_info
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq
		And    to_char(sale_month,'yyyymm') > to_char(:ld_pre_reqdt,'yyyymm');
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(QUOTA_INFO)")
			RollBack;
			Return 
		End If
		
		//2004.01.08 Update 수정...
		//기존계약마스타의 주문번호(orderno)를 얻는다.
		Select orderno
		Into   :ll_orderno_old
		From   admst
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(ADMST)")
			RollBack;
			Return
		End If
		
		//장비가 있으면 계약번호를 다시 update한다.
		Update admst
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
			RollBack;
			Return 
		End If
		
		//고객H/W 정보가 있으면 주문번호를 다시 update한다.
		//2011.03.16 추가 계약번호 update 되도록...
//		Update customer_hw
//		Set    orderno     = :ll_orderno,
//				 contractseq = :ll_cnt,
//		       updt_user   = :gs_user_Id,
//				 updtdt      = sysdate
//		Where  customerid  = :ls_customerid
//		And    orderno     = :ll_orderno_old;
		
		//2011.04.13 예전에 등록된 카드 때문에...쿼리 변경함.
		Update customer_hw
		Set    orderno     = :ll_orderno,
				 contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;		
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMER_HW)")
			RollBack;
			Return 
		End If
		
		//즉시불(일시불) 정보가 있으면 주문번호를 다시 update한다.
		Update oncepayment
		Set    orderno     = :ll_orderno,
		       contractseq = :ll_cnt,
		       updt_user   = :gs_user_Id,
				 updtdt      = sysdate
		Where  customerid  = :ls_customerid
		And    contractseq = :ll_contractseq;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(ONCEPAYMENT)")
			RollBack;
			Return 
		End If
		
		SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO :ls_sysdate
		FROM   DUAL;
		
		//2009.10.13 JHCHOI 수정 : 가격정책 변경시 인증을 하지 않더라고 가번, 장비정보는 변경시켜야 하기에...
		//기존 서비스가 인증서비스인지 확인.
		SELECT COUNT(*) INTO :ll_boss03
		FROM   SYSCOD2T
		WHERE  GRCODE = 'BOSS03'
		AND    CODE   = :ls_svccod;
		
		IF ll_boss03 > 0 THEN
			//기존 가격정책이 인증서비스인지 확인.
			SELECT COUNT(*) INTO :ll_boss04
			FROM   SYSCOD2T
			WHERE  GRCODE = 'BOSS04'
			AND    CODE   = :ls_priceplan;
			
			IF ll_boss04 <= 0 THEN
				//요청일이 현재일인 경우만 호출...
				//해당 서비스만 속도변경으로 인증처리함.
				IF ls_svccod = "510CM" OR ls_svccod = "500CM" OR ls_svccod = "910WF" OR ls_svccod = "520CM" THEN
					IF ls_sysdate = ls_reqdt THEN
						ls_errmsg = space(1000)
						SQLCA.UBS_PROVISIONNING(ll_orderno,				'INT320',		0,					&
														'',						gs_shopid,		is_data[5],		&
														ll_return,				ls_errmsg)
				
						IF SQLCA.SQLCODE < 0 THEN		//For Programer
							MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
							ROLLBACK;
							RETURN
						ELSEIF ll_return < 0 THEN		//For User
							MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
							ROLLBACK;
							RETURN
						END IF
						
						//가입자 번호 연결 데이터 수정...
						UPDATE SIID
						SET    ORDERNO = :ll_orderno,
								 CONTRACTSEQ = :ll_cnt,
								 UPDTDT = SYSDATE
						WHERE  CONTRACTSEQ = :ll_contractseq;
						
						IF SQLCA.SQLCODE < 0 THEN		//For Programer
							MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
							ROLLBACK;
							RETURN
						END IF				
						
						//장비 연결 데이터 수정...
						UPDATE EQUIPMST
						SET    ORDERNO     = :ll_orderno,
								 CONTRACTSEQ = :ll_cnt,
								 UPDTDT      = SYSDATE				
						WHERE  CONTRACTSEQ = :ll_contractseq;
						
						IF SQLCA.SQLCODE < 0 THEN		//For Programer
							MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
							ROLLBACK;
							RETURN 
						END IF								
						
						//변경 완료를 계약마스터에 표기
						UPDATE CONTRACTMST
						SET    CHANGE_FLAG = 'E'
						WHERE  CONTRACTSEQ = :ll_cnt;
					  
						IF SQLCA.SQLCODE < 0 THEN		//For Programer
							MESSAGEBOX("확인", 'UPDATE CONTRACTMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
							ROLLBACK;
							RETURN 
						END IF							
					END IF
				ELSE
					//가입자 번호 연결 데이터 수정...
					UPDATE SIID
					SET    ORDERNO     = :ll_orderno,
							 CONTRACTSEQ = :ll_cnt,
							 UPDTDT      = SYSDATE
					WHERE  CONTRACTSEQ = :ll_contractseq;
					
					IF SQLCA.SQLCODE < 0 THEN		//For Programer
						MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
						ROLLBACK;
						RETURN
					END IF				
					
					//장비 연결 데이터 수정...
					UPDATE EQUIPMST
					SET    ORDERNO     = :ll_orderno,
							 CONTRACTSEQ = :ll_cnt,
							 UPDTDT      = SYSDATE				
					WHERE  CONTRACTSEQ = :ll_contractseq;
					
					IF SQLCA.SQLCODE < 0 THEN		//For Programer
						MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
						ROLLBACK;
						RETURN 
					END IF								
					
					//변경 완료를 계약마스터에 표기
					UPDATE CONTRACTMST
					SET    CHANGE_FLAG = 'E'
					WHERE  CONTRACTSEQ = :ll_cnt;
				  
					IF SQLCA.SQLCODE < 0 THEN		//For Programer
						MESSAGEBOX("확인", 'UPDATE CONTRACTMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
						ROLLBACK;
						RETURN 
					END IF						
					
				END IF						

				
//				//가입자 번호 연결 데이터 수정...
//				UPDATE SIID
//				SET    ORDERNO = :ll_orderno,
//						 CONTRACTSEQ = :ll_cnt,
//						 UPDTDT = SYSDATE
//				WHERE  CONTRACTSEQ = :ll_contractseq;
//				
//				IF SQLCA.SQLCODE < 0 THEN		//For Programer
//					MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//					ROLLBACK;
//					RETURN
//				END IF				
//				
//				//장비 연결 데이터 수정...
//				UPDATE EQUIPMST
//				SET    ORDERNO = :ll_orderno,
//						 CONTRACTSEQ = :ll_cnt,
//						 UPDTDT  = SYSDATE				
//				WHERE  CONTRACTSEQ = :ll_contractseq;
//				
//				IF SQLCA.SQLCODE < 0 THEN		//For Programer
//					MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//					ROLLBACK;
//					RETURN 
//				END IF				
			END IF
		END IF	
		//2009.10.13 JHCHOI 수정 END
		
		
		//2018.09.18 수정  by HMK RQ-YJ-UBS-201809-01
	    	IF  ll_non_valid_cnt > 0  and  ll_priceplan_cnt > 0 Then  //비인증서비스이지만 장비연결이 되어 있는경우 
				
				//장비 연결 데이터 수정..
				UPDATE EQUIPMST
				SET    ORDERNO     = :ll_orderno,
						 CONTRACTSEQ = :ll_cnt,
						 UPDTDT      = SYSDATE				
				WHERE  CONTRACTSEQ = :ll_contractseq;
				
				IF SQLCA.SQLCODE < 0 THEN		//For Programer
					MESSAGEBOX("확인", 'UPDATE EQUIPMST2' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
					ROLLBACK;
					RETURN 
				END IF					

//				//INSERT EQUIPLOG
//				INSERT INTO EQUIPLOG
//				(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
//				 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
//				 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
//				 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
//				 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
//				 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
//				 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
//				 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
//				 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
//				 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
//				SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
//						 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
//						 MAKERCD,	MODELNO,						STATUS,		'900',			USE_YN,
//						 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
//						 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
//						 RETDT,			NULL,				NULL,			NULL,				CUST_NO,
//						 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
//						 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
//						 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
//						 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
//				FROM   EQUIPMST
//				WHERE  CONTRACTSEQ = :ls_contractseq;
//				
//				IF SQLCA.SQLCODE < 0 THEN		//For Programer
//					MESSAGEBOX("확인", 'INSERT EQUIPLOG' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//					RETURN -1
//				END IF


		End If	
		
//2009.10.13 JHCHOI 주석처리...		
//		IF ls_sysdate = ls_reqdt THEN    //요청일이 현재일인 경우만 호출...
//			//프로비져닝 프로시저 호출 - 2009.06.11
//			IF ls_svccod = "510CM" OR ls_svccod = "500CM" OR ls_svccod = "910WF" OR ls_svccod = "520CM" THEN
//				
//				UPDATE SIID
//				SET    ORDERNO = :ll_orderno,
//						 CONTRATCSEQ = :ll_cnt,
//						 UPDTDT = SYSDATE
//				WHERE  CONTRACTSEQ = :ll_contractseq;
//				
//				IF SQLCA.SQLCODE < 0 THEN		//For Programer
//					MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//					ROLLBACK;
//					RETURN
//				END IF				
//								
//				ls_errmsg = space(1000)
//				SQLCA.UBS_PROVISIONNING(ll_orderno,				'INT320',		0,					&
//												'',						gs_shopid,		is_data[5],		&
//												ll_return,				ls_errmsg)
//		
//				IF SQLCA.SQLCODE < 0 THEN		//For Programer
//					MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//					ROLLBACK;
//					RETURN
//				ELSEIF ll_return < 0 THEN		//For User
//					MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
//					ROLLBACK;
//					RETURN
//				END IF
//				
//				UPDATE EQUIPMST
//				SET    ORDERNO = :ll_orderno,
//						 CONTRACTSEQ = :ll_cnt,
//						 UPDTDT  = SYSDATE				
//				WHERE  CONTRACTSEQ = :ll_contractseq;
//				
//				IF SQLCA.SQLCODE < 0 THEN		//For Programer
//					MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//					ROLLBACK;
//					RETURN 
//				END IF			
//				
//			END IF
//		END IF
//2009.10.13 JHCHOI 주석처리 END--------------------------------------------------------------------			
End Choose

ii_rc = 0
Return
		
end subroutine

on b1u_dbmgr.create
call super::create
end on

on b1u_dbmgr.destroy
call super::destroy
end on

