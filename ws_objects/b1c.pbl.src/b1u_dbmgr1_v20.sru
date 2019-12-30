$PBExportHeader$b1u_dbmgr1_v20.sru
$PBExportComments$[ohj] DBmanager
forward
global type b1u_dbmgr1_v20 from u_cust_a_db
end type
end forward

global type b1u_dbmgr1_v20 from u_cust_a_db
end type
global b1u_dbmgr1_v20 b1u_dbmgr1_v20

forward prototypes
public subroutine uf_prc_db_07 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_05 ()
public subroutine uf_prc_db_04 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_07 ();//b1w_reg_svc_actorder_pre_reserve_v20%save   예약 선불개통처리

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
	
String ls_prebil_yn, ls_oneoffcharge_yn, ls_itemcod1, ls_day, ls_direct_paytype, ls_reserve_st[]
Long   ll_validity_term, ll_i
Decimal ldc_unitcharge, ldc_payamt
Date   ld_salemonth, ld_inputclosedt
String ls_crt_kind_code[]
Integer li_return, li_random_length
String ls_validkey_typenm[],ls_crt_kind[],ls_prefix[],ls_auth_method[],ls_type[],ls_used_level[]//, ls_crt_kind_code[]
string ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ls_auth_method_h,ls_type_h,ls_used_level_h
Long ll_length[],ll_length_h
string ls_auto_validkey, ls_auto_validitem, ls_validkey_type[], ls_validkey_loc[]
//khpark add 2005-07-08
string ls_callforward_type, ls_callforward_code[], ls_callforwardno[], ls_password[], ls_callingnum_all[], ls_callingnum[]
string ls_callforward_info, ls_callforward_auth,ls_addition_itemcod, ls_item_method,ls_method_code[],ls_M_method,ls_D_method
long ll_callforwarding_info_seq, ll_item_addunit,ll_item_validity_term, ll_callingnum_cnt
date ld_call_fromdt, ld_call_todt, ld_item_todt[], ld_requestdt
String ls_bil_fromdt

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre_reserve_v20%save"    //선불제(선납포함) - 장비모듈 추가, 인증KeyLocation 필수 체크 포함.

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
		
		//가입자예약신청상태:가입예약;고객확정;계약확정  000;100;200
		ls_ref_desc = ""
		ls_temp = fs_get_control("B0", "P270", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";" , ls_reserve_st[])
		
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
				
                ls_validkey[i]    = Trim(idw_data[3].object.validkey[i])			
			  	ls_vpasswd[i]     = Trim(idw_data[3].object.vpassword[i])
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
				   :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt,
				   :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt, to_date(:ls_requestdt,'yyyy-mm-dd'),
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
	
		UPDATE PRE_SVCORDER
			SET STATUS      = :ls_reserve_st[3]   //개통확정
			  , CUSTOMERID  = :ls_customerid
			  , CONTRACTSEQ = :ll_contractseq
			  , UPDT_USER   = :gs_user_id
			  , UPDTDT      = sysdate
			  , PGM_ID      = :ls_pgm_id
		 WHERE PRESEQ      = :il_data[3]  ;
		 
		If SQLCA.SQLCODE < 0 Then
			RollBack;
			ii_rc = -1
			f_msg_sql_err(is_title, is_caller + "후불개통신청(처리) PRE_SVCORDER update 시 error")				
			Return 
		End If 
		
		UPDATE PRE_VALIDINFO
			SET VALIDKEY = :ls_validkey[1]
		 WHERE PRESEQ  = :il_data[3]   ; 
		If SQLCA.SQLCODE < 0 Then
			RollBack;
			ii_rc = -1
			f_msg_sql_err(is_title, is_caller + "후불개통신청(처리) PRE_VALIDINFO update 시 error")				
			Return 
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

public subroutine uf_prc_db_06 ();//b1w_reg_svc_actorder_reserve_v20%save    //예약 개통후불 처리시.... 
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix, ls_validloc_gu, ls_reserve_st[]
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


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_reserve_v20%save"  //장비임대 포함 수정,입중계출중계서비스추가,인증KeyType별추가,착신전환부가서비스추가

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
		
		//가입자예약신청상태:가입예약;고객확정;계약확정  000;100;200
		ls_ref_desc = ""
		ls_temp = fs_get_control("B0", "P270", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";" ,ls_reserve_st[]) 
		
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
		
		UPDATE PRE_SVCORDER
			SET STATUS      = :ls_reserve_st[3]   //개통확정
			  , CUSTOMERID  = :ls_customerid
			  , CONTRACTSEQ = :ll_contractseq
			  , UPDT_USER   = :gs_user_id
			  , UPDTDT      = sysdate
			  , PGM_ID      = :ls_pgm_id
		 WHERE PRESEQ      = :il_data[3]  ;
		 
		If SQLCA.SQLCODE < 0 Then
			RollBack;
			ii_rc = -1
			f_msg_sql_err(is_title, is_caller + "후불개통신청(처리) PRE_SVCORDER update 시 error")				
			Return 
		End If 
		
		UPDATE PRE_VALIDINFO
			SET VALIDKEY = :ls_validkey[1]
		 WHERE PRESEQ  = :il_data[3]   ; 
		If SQLCA.SQLCODE < 0 Then
			RollBack;
			ii_rc = -1
			f_msg_sql_err(is_title, is_caller + "후불개통신청(처리) PRE_VALIDINFO update 시 error")				
			Return 
		End If 
	
End Choose

ii_rc = 0

Return 
end subroutine

public subroutine uf_prc_db_03 ();//"b1w_reg_svc_reserve_v20%ue_extra_save"
String  ls_customernm, ls_logid, ls_password, ls_secuword, ls_ctype2, ls_ssno, ls_passportno, &
        ls_zipcod, ls_addr1, ls_addr2, ls_phone1, ls_email_yn, ls_sms_yn, ls_email1, ls_smsphone, &
		  ls_ref_desc, ls_corpnm, ls_corpno, ls_cregno, ls_representative, ls_businesstype, &
		  ls_businessitem, ls_bill_cycle, ls_inv_yn, ls_invtype, ls_inv_method, ls_pay_method, &
		  ls_currency_type, ls_taxtype, ls_bank, ls_acctno, ls_acct_owner, ls_acct_ssno, &
		  ls_card_type, ls_card_no, ls_card_expdt, ls_card_holder, ls_card_ssno, ls_card_remark1, &
		  ls_reservedt, ls_svccod, ls_priceplan, ls_validkey_type, ls_validkey, ls_temp, ls_validkey_typenm, &
		  ls_crt_kind, ls_crt_kind_code[], ls_prefix, ls_auth_method, ls_type, ls_used_level, &
		  ls_auto_validkey, ls_validkey_1, ls_ssn_check, ls_partner
		  
Integer li_cnt, li_pre_cnt, li_return, li_random_length
Long    ll_length, ll_cnt, ll_cnt_1
Boolean lb_check

ii_rc = -1

Choose Case is_caller
 Case	"b1w_reg_svc_reserve_v20%ue_extra_save"
	//lu_check.ii_data[1] = li_tab
	//lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
    //lu_check.is_title = Title
	//lu_check.ii_data[1] = li_tab
    //lu_check.ib_data[1] = ib_new
	//lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
	
	//주민등록번호 CHECK 2005.07.15 OHJ
	ls_ref_desc  = ""
	ls_ssn_check = fs_get_control("00", "Z920", ls_ref_desc)
		
	//필수 Check
	ls_customernm = fs_snvl(idw_data[1].object.customernm[1], '')
	ls_logid      = fs_snvl(idw_data[1].object.logid[1], '')
	ls_password   = fs_snvl(idw_data[1].object.password[1], '')
	ls_secuword   = fs_snvl(idw_data[1].object.secuword[1], '')

	ls_ctype2     = fs_snvl(idw_data[1].object.ctype2[1], '')
	ls_ssno       = fs_snvl(idw_data[1].object.ssno[1], '')
	ls_passportno = Trim(idw_data[1].object.passportno[1])
	
	ls_zipcod     = fs_snvl(idw_data[1].object.zipcod[1], '')
	ls_addr1      = fs_snvl(idw_data[1].object.addr1[1], '')
	ls_addr2      = fs_snvl(idw_data[1].object.addr2[1], '')
	ls_phone1     = fs_snvl(idw_data[1].object.phone1[1], '')
	ls_email_yn   = Trim(idw_data[1].object.email_yn[1])
	ls_sms_yn     = Trim(idw_data[1].object.sms_yn[1])
	ls_email1     = fs_snvl(idw_data[1].object.email1[1], '')
	ls_smsphone   = fs_snvl(idw_data[1].object.smsphone[1], '')
	ls_reservedt  = fs_snvl(string(idw_data[1].object.reservedt[1], 'yyyymmdd'), '')
	ls_svccod     = fs_snvl(idw_data[1].object.svccod[1], '')
	ls_priceplan  = fs_snvl(idw_data[1].object.priceplan[1], '')
	ls_validkey_type = fs_snvl(idw_data[1].object.validkey_type[1], '')
	
	//2005.11.17 kem Modify 대리점(partner) 추가
	ls_partner    = fs_snvl(idw_data[1].object.partner[1], '')
	
	If ls_customernm = "" Then
		f_msg_usr_err(200, is_title, "고객명")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("customernm")
		Return 
	End If
	
	//ib_data[1] -> 신규
	If ib_data[1] or idw_data[1].GetItemStatus(1,"logid", Primary!) = DataModified! THEN
		
		If ls_logid <> "" Then
			
			Select count(customerid)
			  Into :li_cnt
			  From customerm
			 Where logid = :ls_logid;
			
			//사용자WEB이 들어가면 pre_svcorder Check 한다.
			Select count(preseq)
			  Into :li_pre_cnt
			  From pre_svcorder
			 Where logid = :ls_logid;
	
				
			If li_cnt <> 0 or li_pre_cnt <> 0  Then
				f_msg_usr_err(9000, is_title, "이미 존재하는 ID 입니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("logid")
				Return
			End If
			
			If ls_password = "" Then
				f_msg_usr_err(200, is_title, "Password")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("password")
				Return 
			End If
			
			If ls_password <> ls_secuword Then
				f_msg_usr_err(9000, is_title, "password와 Security word는 동일해야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("password")
				Return 
			End If
		
		End If
	End IF

	If ls_ctype2 = "" Then
		f_msg_usr_err(200, is_title, "개인/법인구분")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("ctype2")
		Return 
	End If
	
	//개인*************************************************************************/
	b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check)
	If lb_check Then
		ls_ssno       = fs_snvl(idw_data[1].object.ssno[1], '')
		ls_passportno = fs_snvl(idw_data[1].object.passportno[1], '')
		
		If ls_ssno = "" AND ls_passportno = "" Then
			f_msg_usr_err(200, is_title, "주민등록번호 또는 여권번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("ssno")
			Return 
		End If
		
		//개인
		IF idw_data[1].GetItemStatus(1,"ssno", Primary!) = DataModified! THEN //ls_ssno <> ""  Or
			
			//주민번호 Check
			If ls_ssn_check = 'Y' Then				
				If fi_check_juminnum(ls_ssno) = -1 Then
					f_msg_usr_err(201, is_title, "주민등록번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ssno")
					Return
				End If
			End If
	
//				//주민번호 중복체크
//				IF ls_customerid <> "" THEN
//					SELECT COUNT(*)
//					  INTO :li_cnt
//					  FROM customerm
//					 WHERE ssno = :ls_ssno
//					   AND customerid <> :ls_customerid;
//				ELSE
//				SELECT COUNT(*)
//				  INTO :li_cnt
//				  FROM customerm
//				 WHERE ssno = :ls_ssno;
//				END IF
				SELECT COUNT(preseq)
				  INTO :li_cnt
				  FROM pre_svcorder
				 WHERE ssno = :ls_ssno;
			
			IF li_cnt <> 0 THEN
				f_msg_usr_err(9000, is_title, "이미 등록된 주민등록번호 입니다.")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("ssno")
//				Return
			END IF
		
		//외국인
		ELSEIF  idw_data[1].GetItemStatus(1,"passportno", Primary!) = DataModified! THEN //ls_passportno <> ""  Or
//				//여권번호 중복체크
//				IF ls_customerid <> "" THEN
//					SELECT COUNT(*)
//					  INTO :li_cnt
//					  FROM customerm
//					 WHERE passportno  = :ls_passportno
//					   AND customerid <> :ls_customerid;
//				ELSE
//				SELECT COUNT(*)
//				  INTO :li_cnt
//				  FROM customerm
//				 WHERE passportno = :ls_passportno;
//				END IF
				SELECT COUNT(preseq)
				  INTO :li_cnt
				  FROM pre_svcorder
				 WHERE passportno = :ls_passportno;			
			IF li_cnt <> 0 THEN
				f_msg_usr_err(9000, is_title, "이미 등록된 여권번호 입니다.")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("passportno")
//				Return
			END IF
		End If
	END IF
	
	/*************************************************************************/

	 //SMS여부 = 'Y' 일때 smsphone 필수
	If ls_sms_yn= 'Y' Then
		If ls_smsphone = "" Then
			f_msg_usr_err(200, is_title, "SMS수신전화번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("smsphone")
			Return 
		End IF				
	End IF
	
	//법인
	b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check)
	If lb_check Then
		ls_corpnm         = fs_snvl(idw_data[1].object.corpnm[1], '')
		ls_corpno         = fs_snvl(idw_data[1].object.corpno[1], '')
		ls_cregno         = fs_snvl(idw_data[1].object.cregno[1], '')
		ls_representative = fs_snvl(idw_data[1].object.representative[1], '')
		ls_businesstype   = fs_snvl(idw_data[1].object.businesstype[1], '')
		ls_businessitem   = fs_snvl(idw_data[1].object.businessitem[1], '')
		
		If ls_corpnm = "" Then
			f_msg_usr_err(200, is_title, "법인명")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("corpnm")
			Return 
		End If
	
//		If ls_corpno = "" Then
//			f_msg_usr_err(200, is_title, "법인등록번호")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("corpno")
//			Return 
//		End If
	
		If ls_cregno = "" Then
			f_msg_usr_err(200, is_title, "사업자등록번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("cregno")
			Return 
		End If
		
		If ls_representative = "" Then
			f_msg_usr_err(200, is_title, "대표자성명")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("representative")
			Return 
		End If
	
		If ls_businesstype = "" Then
			f_msg_usr_err(200, is_title, "업태")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("businesstype")
			Return 
		End If
		
		If ls_businessitem = "" Then
			f_msg_usr_err(200, is_title, "종목")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("businessitem")
			Return 
		End If
	End If
	
	If ls_zipcod = "" Then
		f_msg_usr_err(200, is_title, "우편번호")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("zipcod")
		Return 
	End If
	
	If ls_addr1 = "" Then
		f_msg_usr_err(200, is_title, "주소")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("addr1")
		Return 
	End If
		
	If ls_addr2 = "" Then
		f_msg_usr_err(200, is_title, "주소")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("addr2")
		Return 
	End If
	
//	If ls_phone1 = "" Then
//		f_msg_usr_err(200, is_title, "전화번호1")
//		idw_data[1].SetFocus()
//		idw_data[1].SetColumn("phone1")
//		Return 
//	End If
	
	//email여부 = 'Y' 일때 email1 필수
	If ls_email_yn= 'Y' Then
		If ls_email1 = "" Then
			f_msg_usr_err(200, is_title, "Email1")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("email1")
			Return 
		End IF				
	End IF
			
	// 청구
	ls_bill_cycle    = fs_snvl(idw_data[1].object.bilcycle[1], '')
	ls_inv_yn        = fs_snvl(idw_data[1].object.inv_yn[1], '')
	ls_invtype       = fs_snvl(idw_data[1].Object.inv_type[1], '')
	ls_inv_method    = fs_snvl(idw_data[1].object.inv_method[1], '')
	ls_pay_method    = fs_snvl(idw_data[1].object.pay_method[1], '')
	ls_taxtype       = fs_snvl(idw_data[1].object.taxtype[1], '')
	ls_currency_type = fs_snvl(idw_data[1].object.currency_type[1], '')

	//필수 Check
	If ls_bill_cycle= "" Then
		f_msg_usr_err(200, is_title, "청구주기")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("bilcycle")
		Return 
	End If

	If ls_invtype= "" Then
		f_msg_usr_err(200, is_title, "청구서유형")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("inv_type")
		Return 
	End If
	
	If ls_inv_yn = "" Then
		f_msg_usr_err(200, is_title, "청구서발송여부")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("inv_yn")
		Return 
	End If
		
	If ls_inv_method = "" Then
		f_msg_usr_err(200, is_title, "청구서발송방법")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("inv_method")
		Return 
	End If
	
	//화폐 단위
	If ls_currency_type = "" Then
		f_msg_usr_err(200, is_title, "통화 유형")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("currency_type")
		Return
	End If
	
	If ls_pay_method = "" Then
		f_msg_usr_err(200, is_title, "결제방법")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("pay_method")
		Return 
	End If
	
	If ls_taxtype = "" Then
		f_msg_usr_err(200, is_title, "TAX적용유형")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("taxtype")
		Return 
	End If
	
	//자동이체
	If is_data[1] = Trim(idw_data[1].object.pay_method[1]) Then
		ls_bank       = fs_snvl(idw_data[1].object.bank[1], '')
		ls_acctno     = fs_snvl(idw_data[1].object.acctno[1], '')
		ls_acct_owner = fs_snvl(idw_data[1].object.acct_owner[1], '') 
		ls_acct_ssno  = fs_snvl(idw_data[1].object.acct_ssno[1], '')
		
		If ls_bank = "" Then
			f_msg_usr_err(200, is_title, "은행")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bank")
			Return 
		End If
		
		If ls_acctno = "" Then
			f_msg_usr_err(200, is_title, "계좌번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("acctno")
			Return 
		End If
		
		If ls_acct_owner = "" Then
			f_msg_usr_err(200, is_title, "예금주명")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("acct_owner")
			Return 
		End If
		
		If ls_acct_ssno = "" Then
			f_msg_usr_err(200, is_title, "예금주 주민번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("acct_ssno")
			Return 
		End If
		
		/* 예금주 주민번호 유효성 체크 주석처리 (2004.06.29)
		//주민등록 번호(13자리),법인번호(10자리)format)
		If len(ls_acct_ssno) = 13 or len(ls_acct_ssno) = 10 Then 
		Else
			f_msg_usr_err(201, is_title, "예금주 주민번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("acct_ssno")
			Return 
		End If				

		If len(ls_acct_ssno) = 13 Then
			If fi_check_juminnum(ls_acct_ssno) = -1 Then
				f_msg_usr_err(201, is_title, "예금주 주민번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acct_ssno")
				Return
			End If
		End If	
		*/
		
	End If
	
	//신용카드
	If is_data[2] = Trim(idw_data[1].object.pay_method[1]) Then
		ls_card_type    = fs_snvl(idw_data[1].object.card_type[1], '')
		ls_card_no      = fs_snvl(idw_data[1].object.card_no[1], '')
		ls_card_expdt   = fs_snvl(String(idw_data[1].object.card_expdt[1],'yyyymmdd'), '')
		ls_card_holder  = fs_snvl(idw_data[1].object.card_holder[1], '')
		ls_card_ssno    = fs_snvl(idw_data[1].object.card_ssno[1], '')
		ls_card_remark1 = fs_snvl(idw_data[1].object.card_remark1[1], '')

		If ls_card_type = "" Then
			f_msg_usr_err(200, is_title, "카드사")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("card_type")
			Return 
		End If
		
		If ls_card_no = "" Then
			f_msg_usr_err(200, is_title, "신용카드 번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("card_no")
			Return 
		End If
		
		If ls_card_expdt = "" Then
			f_msg_usr_err(200, is_title, "신용카드 유효기간")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("card_expdt")
			Return 
		End If
		
		If ls_card_holder = "" Then
			f_msg_usr_err(200, is_title, "카드회원명")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("card_holder")
			Return 
		End If
		
		If ls_card_ssno = "" Then
			f_msg_usr_err(200, is_title, "카드회원 주민번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("card_ssno")
			Return 
		End If
		
		If ls_card_remark1 = "" Then
			f_msg_usr_err(200, is_title, "신용카드유형")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("card_remark1")
			Return 
		End If
	End If
		
	If ls_partner = "" Then
		f_msg_usr_err(200, is_title, "대리점")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("partner")
		Return 
	End If
	
	If ls_svccod = "" Then
		f_msg_usr_err(200, is_title, "서비스")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("svccod")
		Return 
	End If

	If ls_priceplan = "" Then
		f_msg_usr_err(200, is_title, "가격정책")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("pricepla")
		Return 
	End If
	
	If ls_validkey_type = "" Then
		f_msg_usr_err(200, is_title, "인증KeyType")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("validkey_type")
		Return 
	End If
	
	//청구 끝
	
	//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
	ls_ref_desc = ""
	ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
	If ls_temp = "" Then Return
	fi_cut_string(ls_temp, ";" , ls_crt_kind_code[])
	If idw_data[1].GetItemStatus(1,"validkey", Primary!) = DataModified! THEN
		If ii_data[1] > 0 Then
	
			ls_validkey_type = fs_snvl(idw_data[1].object.validkey_type[1], '')
			ls_priceplan     = fs_snvl(idw_data[1].object.priceplan[1], '')
			ls_validkey      = fs_snvl(idw_data[1].object.validkey[1], '')
			
			//인증KEY의 validkey_type에 따른 처리
			li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type,ls_validkey_typenm,ls_crt_kind,ls_prefix,ll_length,ls_auth_method,ls_type,ls_used_level) 
			If li_return = -1 Then
				 return
			End IF
			
			IF ls_crt_kind = ls_crt_kind_code[1] or ls_crt_kind = ls_crt_kind_code[4] or ls_crt_kind = ls_crt_kind_code[5] Then
				If ls_validkey = "" Then
					f_msg_usr_err(200, is_title, "인증KeyType")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("validkey")
					Return 
				End If
			End IF
			
			Choose Case ls_crt_kind		
				Case ls_crt_kind_code[1]   //수동Manual
					
				Case ls_crt_kind_code[2]   //AutoRandom
					If ls_validkey = '' Then
						ls_auto_validkey = ""
						
						//validkey 생성에 따른 prefix 및 길이 Check
						IF isnull(ls_prefix) or ls_prefix = "" Then
							ls_prefix = ""
							li_random_length = ll_length
						Else
							li_random_length = ll_length - LenA(ls_prefix)
						END IF
								
						DO  //validkey random 생성
							ls_auto_validkey = ls_prefix + fs_get_randomize_v20(li_random_length)
			
							select count(*)
							  into :ll_cnt
							  from validinfo
							 where ( (to_char(fromdt,'yyyymmdd') > :ls_reservedt ) Or
									 ( to_char(fromdt,'yyyymmdd') <= :ls_reservedt and
									 :ls_reservedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
								and validkey = :ls_auto_validkey
								and svccod   = :ls_svccod;	
								
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, " Select Error(validinfo check AutoRandom)")
								RollBack;
								ii_rc = -1				
								Return 
							End If		
						
						LOOP WHILE(ll_cnt>0)		
					
						idw_data[1].object.validkey[1] = ls_auto_validkey
					End If
		
				Case ls_crt_kind_code[3]   //AutoSeq
					If ls_validkey = '' Then
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
			
						idw_data[1].object.validkey[1] = ls_auto_validkey
					End If
					
				Case ls_crt_kind_code[4]   //자원관리Resource
					
				Case ls_crt_kind_code[5]   //고객대체				
					
			End Choose                
			
			If ls_auto_validkey <> '' Then
				ls_validkey_1 = ls_auto_validkey		//AUTO NEW
			Else
				ls_validkey_1 = ls_validkey  			//NEW
			End If
			
		
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			  from validinfo
			 where ( (to_char(fromdt,'yyyymmdd') > :ls_reservedt ) Or
					 ( to_char(fromdt,'yyyymmdd') <= :ls_reservedt and
					 :ls_reservedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				and validkey = :ls_validkey_1
				and svccod   = :ls_svccod;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
				Return 
			End If
			
			Select count(preseq)
			  into :ll_cnt_1
			  from pre_validinfo
			 where validkey = :ls_validkey_1;
				
			If ll_cnt > 0 Or ll_cnt_1 > 0 Then
				f_msg_usr_err(9000, is_title, "[" + ls_validkey_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("validkey")
				return 
			End If
			
		End If

		String ls_vk
		
		Select validkey
		  into :ls_vk
		  from pre_validinfo
		 where preseq   = :il_data[1];
		
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
			Return 
		ElseIF sqlca.sqlcode = 100 Then
			//pre_validinfo
			INSERT INTO PRE_VALIDINFO
						 ( PRESEQ
						 , VALIDKEY       )
				VALUES ( :il_data[1]
						 , :ls_validkey_1 );
						 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "Insert Error (PRE_VALIDINFO)")
				Return
			End If
		Else
			UPDATE PRE_VALIDINFO
				SET VALIDKEY = :ls_validkey_1
			 WHERE preseq   = :il_data[1]     ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "update Error (PRE_VALIDINFO)")
				Return
			End If		 
		End If			
	End If
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_05 ();//b1w_reg_svc_actorder_pre_3_v20%save   선불서비스신청v20

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
string ls_auto_validkey, ls_auto_validitem, ls_validkey_type[],  ls_validkey_loc[]
//khpark add 2005-07-08
string ls_callforward_type, ls_callforward_code[], ls_callforwardno[], ls_password[], ls_callingnum_all[], ls_callingnum[]
string ls_callforward_info, ls_callforward_auth,ls_addition_itemcod, ls_item_method,ls_method_code[],ls_M_method,ls_D_method
long ll_callforwarding_info_seq, ll_item_addunit,ll_item_validity_term, ll_callingnum_cnt, ll_len
date ld_call_fromdt, ld_call_todt, ld_item_todt[], ld_requestdt
String ls_bil_fromdt, ls_paytype_method[], ls_sale_prefix, ls_level_code, ls_partner_main

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre_3_v20%save"    //선불제(선납포함) - 장비모듈 추가, 인증KeyLocation 필수 체크 포함.
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

public subroutine uf_prc_db_04 ();//"b1w_reg_reserve_confirm_cust_popup_v20%ue_ok"
String ls_customerid, ls_status[], ls_ref_desc, ls_temp, ls_status_at[]
ii_rc = -1

Choose Case is_caller
		Case "b1w_reg_reserve_confirm_cust_popup_v20%ue_ok"
			
			//가입자예약신청상태:가입예약;고객확정;계약확정  000;100;200
			ls_ref_desc = ""
			ls_temp = fs_get_control("B0", "P270", ls_ref_desc)
			If ls_temp = "" Then Return
			fi_cut_string(ls_temp, ";" , ls_status[]) 
			
			ls_ref_desc = ""
			ls_temp = fs_get_control("B0", "P200", ls_ref_desc)
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";", ls_status_at[])
			
			Select to_char(seq_customerid.nextval) 
			  Into :ls_customerid
			  From dual;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Sequence Error")
				Return 
			End If		
			
			INSERT INTO CUSTOMERM
						 ( CUSTOMERID            , PAYID
						 , LOGID                 , PASSWORD
						 , SECUWORD              , CUSTOMERNM
						 , STITLE                , BIRTHDT
						 , ANNIVERSARY           , CTYPE1
						 , CTYPE2                , SSNO
						 , PASSPORTNO            , CREGNO
						 , CORPNO                , CORPNM
						 , REPRESENTATIVE        , BUSINESSTYPE
						 , BUSINESSITEM          , ADDRTYPE
						 , ZIPCOD                , ADDR1
						 , ADDR2                 , EMAIL1
						 , EMAIL2                , PHONE1
						 , PHONE2                , FAXNO
						 , URL                   , MACOD
                   , CONTACT               , CONTACTDEP
						 , LOCATION              , REMARK1
						 , JOB                   , CLEVEL
						 , SMSPHONE              , EMAIL_YN
						 , SMS_YN                , HOLDER
						 , HOLDER_SSNO           , HOLDER_ADDRTYPE
						 , HOLDER_ZIPCOD         , HOLDER_ADDR1
						 , HOLDER_ADDR2          , HOLDER_TYPE    
						 , HOLDER_ITEM				 , CRT_USER
						 , CRTDT                 , PGM_ID
						 , STATUS                                 )
 			     SELECT :ls_customerid        , :ls_customerid
					    , LOGID                 , PASSWORD
						 , SECUWORD              , CUSTOMERNM
						 , STITLE                , BIRTHDT
						 , ANNIVERSARY           , CTYPE1
						 , CTYPE2                , SSNO
						 , PASSPORTNO            , CREGNO
						 , CORPNO                , CORPNM
						 , REPRESENTATIVE        , BUSINESSTYPE
						 , BUSINESSITEM          , ADDRTYPE
						 , ZIPCOD                , ADDR1
						 , ADDR2                 , EMAIL1
						 , EMAIL2                , PHONE1
						 , PHONE2                , FAXNO
						 , URL                   , MACOD
						 , CONTACT               , CONTACTDEP
						 , LOCATION              , REMARK1
						 , JOB                   , CLEVEL
						 , SMSPHONE              , EMAIL_YN
						 , SMS_YN                , CUSTOMERNM
						 , SSNO                  , ADDRTYPE
						 , ZIPCOD                , ADDR1
						 , ADDR2                 , BUSINESSTYPE   
						 , BUSINESSITEM          , :is_data[2]
						 , SYSDATE               , :is_data[1]
						 , :ls_status_at[1]
				    FROM PRE_SVCORDER
				   WHERE PRESEQ       = :il_data[1]  ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "Insert Error (CUSTOMERM)")
				Return
			End If		
			
			INSERT INTO BILLINGINFO			
	                ( CUSTOMERID         , BILCYCLE
						 , INV_METHOD         , CURRENCY_TYPE
						 , PAY_METHOD         , INV_YN
						 , INV_TYPE           , TAXTYPE
						 , OVERDUE_YN         , BANK
						 , ACCTNO             , ACCT_OWNER
						 , ACCT_SSNO          , CARD_TYPE
						 , CARD_NO            , CARD_EXPDT
						 , CARD_HOLDER        , CARD_SSNO
						 , CARD_REMARK1       , BIL_ZIPCOD
						 , BIL_ADDRTYPE       , BIL_ADDR1
						 , BIL_ADDR2          , BIL_EMAIL
						 , CRT_USER           , CRTDT
						 , PGM_ID                                 )
				  SELECT :ls_customerid     , BILCYCLE           
						 , INV_METHOD         , CURRENCY_TYPE
						 , PAY_METHOD         , INV_YN
						 , INV_TYPE           , TAXTYPE
						 , OVERDUE_YN         , BANK
						 , ACCTNO             , ACCT_OWNER         
						 , ACCT_SSNO          , CARD_TYPE          
						 , CARD_NO            , CARD_EXPDT
						 , CARD_HOLDER        , CARD_SSNO
						 , CARD_REMARK1       , ZIPCOD
						 , ADDRTYPE           , ADDR1
						 , ADDR2              , EMAIL1
						 , :is_data[2]			 , SYSDATE
						 , :is_data[1] 
		          FROM PRE_SVCORDER
				   WHERE PRESEQ       = :il_data[1]  ;
					
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "Insert Error (BILLINGINFO)")
				Return
			End If	
        
			UPDATE PRE_SVCORDER
			   SET STATUS     = :ls_status[2]
				  , CUSTOMERID = :ls_customerid
				  , UPDT_USER  = :is_data[2]
				  , UPDTDT     = SYSDATE
				  , PGM_ID      = :is_data[1]
			 WHERE PRESEQ     = :il_data[1]       ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "Update Error (PRE_SVCORDER)")
				Return
			End If				 
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_01 ();//b1w_reg_validkey_update_1_v20
/*-------------------------------------------------------------------------
	name	: uf_prc_db_01()
	desc.	: Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2005.05.02
	programer : oh hye jin 
--------------------------------------------------------------------------*/	

//"b1w_reg_validkey_update%ue_change"
String ls_svctype, ls_status, ls_fromdt, ls_use_yn, ls_svccod, ls_validinfo, ls_contractseq
String ls_ref_desc, ls_svc_status[], ls_term, ls_temp
String ls_callforward_code[]

//"b1w_reg_validkey_update%ue_add"
Long ll_cnt, li_valid_cnt

//khpark modify add 2005-07-11 start
//부가서비스유형코드(착신전환부가서비스코드)
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_callforward_code[])		
//khpark modify add 2005-07-11 end

ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_validkey_update_1_v20%ue_change"		//통합빌링 & xener
	    
		//계약번호까지 비교 20031128
		SELECT svctype, status, to_char(fromdt,'yyyymmdd'), use_yn, svccod
	     INTO :is_data[2], :is_data[3], :is_data[4], :is_data[5], :is_data[6]
		 FROM validinfo
		WHERE validkey = :is_data[1]
		  AND fromdt = ( select max(fromdt)
		  				   from validinfo
						  where validkey = :is_data[1]
						   and to_char(contractseq) = :is_data[7] )
		  AND to_char(contractseq) = :is_data[7];
		
		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT svctype, status from validinfo")			
			ii_rc = -1			
			Return 		
		ELSEIF sqlca.sqlcode = 100 Then
			f_msg_info(9000, is_title, "인증KEY[" +is_data[1] +"]는 없는 인증KEY입니다.")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("validkey")			
			ii_rc = -1
			Return 	
		End If

		//khpark modify add 2005-07-11 start		
		//계약에 부가서비스품목 중 착신부가서비스가 있는지check한다.(착신전환번호)
		select c.itemcod, i.addition_code, c.bil_todt
		  into :is_data[8],:is_data[9], :id_data[1]
		 from contractdet c, itemmst i
		Where to_char(c.contractseq) = :is_data[7]
		 and c.itemcod = i.itemcod
		 and i.addition_code in (:ls_callforward_code[1],:ls_callforward_code[2],:ls_callforward_code[3]);

		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT itemcod,additon_code from contractdet, itemmst")			
			ii_rc = -1			
			Return 		
		ELSEIF sqlca.sqlcode = 100 Then
			is_data[10] = 'N'
			il_data[1] = 0
			is_data[11] = ''
			is_data[12] = ''
			ii_rc = 0
			Return 	
		End If		 
		 
		is_data[10] = 'Y'		 
		select seq, callforwardno, password
		  into :il_data[1],:is_data[11],:is_data[12]
		  from callforwarding_info
    	 where to_char(contractseq) = :is_data[7]
		   and validkey = :is_data[1]
		   and fromdt <= sysdate
		   and nvl(todt,sysdate) >= sysdate;	
		   
		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq,callforwardno from callforwarding_info")			
			ii_rc = -1			
			Return 		
		End If		 		   

		//khpark modify add 2005-07-11 end
		
	Case "b1w_reg_validkey_update_1_v20%ue_add"		
		//iu_check.is_data[1] = ls_contractseq  		//계약번호
		//iu_check.is_data[3] = ls_svctype    //해당 계약번호에 svctype
		//iu_check.is_data[4] = ls_status     //해당 계약번호에 status
		//iu_check.is_data[5] = priceplan     //해당 계약번호에 priceplan
		//iu_check.is_data[6] = ls_svccod     //해당 계약번호에 svccod		
		//iu_check.il_data[1]                 //해당 계약번호에 인증KEY 갯수
		//iu_check.il_data[2]                 //해당 계약번호에 priceplan의 validkeycnt
	
		ll_cnt = 0
		
		SELECT svc.svctype, con.status, con.priceplan, con.svccod
		  INTO :is_data[3], :is_data[4], :is_data[5], :is_data[6]
		  FROM contractmst con, svcmst svc
		 WHERE to_char(contractseq) = :is_data[1]
		  AND  con.svccod = svc.svccod;
		 
		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT contractmst")			
			ii_rc = -1
			Return 	
		ElseIf sqlca.sqlcode = 100 Then
			f_msg_info(9000, is_title, "계약 SEQ[" +is_data[1] +"]는  계약건이 없는 번호입니다.")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("contractseq")			
			ii_rc = -1
			Return 	
		End If		
		
		//해당 계약번호에 인증Key의 수를 가져온다.
		SELECT Nvl(count(validkey), 0)
		  INTO :il_data[1]
		  FROM validinfo
		 WHERE to_char(fromdt, 'yyyymmdd') <= to_char(sysdate, 'yyyymmdd')
		   AND to_char(nvl(todt, sysdate+1), 'yyyymmdd') >= to_char(sysdate, 'yyyymmdd')
			AND to_char(contractseq) = :is_data[1];
			
		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT validkeycnt")			
			ii_rc = -1
			Return 	
		End If
		
		//해당 계약번호에 Priceplan의 인증Key 수.
		SELECT validkeycnt
		  INTO :il_data[2]
		  FROM priceplanmst
		 WHERE priceplan = :is_data[5];
		 
		 IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT validkeycnt")			
			ii_rc = -1
			Return 	
		ElseIf sqlca.sqlcode = 100 Then
			f_msg_info(9000, is_title, "계약 SEQ[" +is_data[1] +"]는  해당 가격정책이 없는 번호입니다.")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("contractseq")			
			ii_rc = -1
			Return 	
		End If

		//khpark modify add 2005-07-12 start		
		//계약에 부가서비스품목 중 착신부가서비스가 있는지check한다.(착신전환번호)
		select c.itemcod, i.addition_code, c.bil_todt
		  into :is_data[7],:is_data[8], :id_data[1]
		 from contractdet c, itemmst i
		Where to_char(c.contractseq) = :is_data[1]
		 and c.itemcod = i.itemcod
		 and i.addition_code in (:ls_callforward_code[1],:ls_callforward_code[2],:ls_callforward_code[3]);

		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT itemcod,additon_code from contractdet, itemmst")			
			ii_rc = -1			
			Return 		
		ELSEIF sqlca.sqlcode = 100 Then
			is_data[9] = 'N'
			ii_rc = 0
			Return 	
		End If		 
		 
		is_data[10] = 'Y'		
		//khpark modify add 2005-07-12 end

		Case "b1w_reg_validkey_update_1_v20%ue_term"
	
			li_valid_cnt = 0 
			ls_validinfo = is_data[1]
			ls_contractseq = is_data[5]
			
			ls_status = fs_get_control("B0", "P221", ls_ref_desc)
			fi_cut_string(ls_status, ";", ls_svc_status[])		
			ls_term	 = ls_svc_status[2]
			
				SELECT count(validkey), to_char(fromdt, 'yyyymmdd'), svctype 
				INTO :li_valid_cnt, :ls_fromdt, :ls_svctype
				FROM validinfo
				WHERE validkey = :ls_validinfo
				AND fromdt = ( select max(fromdt)
								from validinfo
							  where validkey = :ls_validinfo and to_char(contractseq) = :ls_contractseq )
				and status <> :ls_term and to_char(contractseq) = :ls_contractseq
				group by fromdt, svctype;
				
				
			If li_valid_cnt = 0 Then
				f_msg_info(401, is_Title, "")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("validkey")
				Return
			End If	
			
		  is_data[2] = ls_fromdt
		  is_data[4] = ls_svctype

End Choose

ii_rc = 0 
end subroutine

public subroutine uf_prc_db ();String   ls_payid, ls_hotbillflag, ls_ref_desc, ls_status, ls_customerid, ls_cus_status     , &
         ls_activedt, ls_svccod, ls_priceplan, ls_prmtype, ls_reg_partner, ls_sale_partner  , &
		   ls_maintain_partner, ls_partner, ls_settle_partner, ls_orderdt, ls_requestdt       , &
		   ls_bil_fromdt, ls_contractno, ls_reg_prefixno, ls_remark, ls_pgm_id, ls_term_status, &
		   ls_enter_status, ls_dlvstat, ls_validkey, ls_todt_tmp, ls_svccod_1, ls_levelcod    , &
			ls_refilltype[], ls_temp, ls_enddt, ls_direct_paytype, ls_pricemodel, ls_prebil_yn 
Decimal{2} ldc_first_refill_amt, ldc_first_sale_amt
Datetime ldt_crtdt
Long     ll_row, ll_cnt
Dec{0}   ldc_contractseq, ldc_orderno, ldc_price, ldc_rate_first, ldc_basic_fee_first, ldc_basic_rate_first, ldc_related_orderno
Boolean  lb_flag

String  ls_method[], ls_M_method, ls_D_method,ls_callforward_code[]
String  ls_itemcod, ls_addition_code, ls_item_method, ls_sale_prefix, ls_level_code, ls_partner_main
Long    ll_addunit, ll_validity_term, ll_len
DateTime	ld_item_todt,ld_bil_fromdt,ld_call_todt, ld_activedt
String  ls_related_contractseq

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
	Case "b1w_reg_svc_actprc_1_v20%save"
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
		ldc_related_orderno = idw_data[1].object.svcorder_related_orderno[1]
		
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
		IF IsNull(ldc_related_orderno) THEN ldc_related_orderno = 0;
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//2005-07-13 khpark add start
		ld_activedt   = idw_data[1].object.activedt[1]
		ld_bil_fromdt    = idw_data[1].object.bil_fromdt[1]		
        IF Isnull(ld_bil_fromdt) Then ld_bil_fromdt = ld_activedt
		//2005-07-13 khpark add end
	
	   select ref_contractseq 
		  into :ls_related_contractseq 
		  from svcorder 
		 where orderno = :ldc_related_orderno;
		 
		If SQLCA.SQLCode = 100 Then		//Not Found
          ls_related_contractseq = "" 
		End If 
		 		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,related_contractseq )
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno,:ls_related_contractseq);

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
		ls_enter_status = fs_get_control("B0", "P202", ls_ref_desc)

// 해지고객뿐 아니라 서비스 개통시 고객 상태를 무조건 개통으로 변경한다. by hcjung (2007-05-15)

//		If ls_cus_status = ls_term_status Then
			
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
			
//		End If
		
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
		
	// 선불개통처리
	Case "b1w_reg_svc_actprc_pre_2_v20%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_pre_2_v20%save"
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
		
		//2005-07-13 khpark add start
		ld_activedt   = idw_data[1].object.activedt[1]
		ld_bil_fromdt    = idw_data[1].object.bil_fromdt[1]		
        IF Isnull(ld_bil_fromdt) Then ld_bil_fromdt = ld_activedt
		//2005-07-13 khpark add end
		
		
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
			   :ls_refilltype[1], :ldc_price, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt, 
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
				
//		Update contractdet
//		Set contractseq = :ldc_contractseq
//		Where orderno = :ldc_orderno;
//		
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			ii_rc = -1	
//			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
//			Return 
//		End If

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
			
			DECLARE cur_contractdet1 CURSOR FOR			
				Select c.itemcod, i.addition_code, nvl(i.prebil_yn, 'N')
				  From contractdet c, itemmst i
				 Where c.orderno = :ldc_orderno
				   and c.itemcod = i.itemcod;
			
				If SQLCA.SQLCode <> 0 Then
					RollBack;		
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " CURSOR cur_contractdet1")				
					Return 
				End If
	
			OPEN cur_contractdet1;
				Do While(True)
					FETCH cur_contractdet1
					Into :ls_itemcod, :ls_addition_code, :ls_prebil_yn;
		
					If SQLCA.sqlcode < 0 Then
						RollBack;		
						ii_rc = -1			
						f_msg_sql_err(is_title, is_caller + " CURSOR cur_contractdet1")				
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
					
					If ls_prebil_yn = 'Y' Then
						f_msg_usr_err(9000, is_title, "선납상품이 존재 합니다. 확인하세요!!")
					End If
				Loop
			CLOSE cur_contractdet1;					
			
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
			Select validkey, to_char(fromdt,'yyyymmdd'), svccod//, svctype
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
			Into :ls_validkey, :ls_todt_tmp, :ls_svccod_1 ;//:ls_svctype;

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
			//적용시작일과 적용종료일의 중복일자를 막는다. ( svctype 가아닌 svccod로 중복체크 - 05.04.25 ohj)
			select count(validkey)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					  ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
						:ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey
			   and  to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and  svccod = :ls_svccod_1; //:ls_svctype;
					  
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
		
		//선납판매정보가 있는 경우 신청번호에 해당하는 Data Update(2004.12.10 김은미 추가)
		Update prepayment
		   Set contractseq = :ldc_contractseq
		     , updt_user   = :gs_user_id
			  , updtdt      = sysdate
		 Where orderno     = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update PREPAYMENT Table")				
			Return 
		End If
		
		
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")
						
End Choose
ii_rc = 0
end subroutine

public subroutine uf_prc_db_02 ();//"b1w_validkey_update_popup_1_1_v20%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf, &
       ls_crt_kind_code[], ls_validkey_type, ls_validkey_typenm, ls_crt_kind, ls_prefix, &
		 ls_type, ls_used_level, ls_priceplan, ls_validitem_yn, ls_validkey_type_h, ls_crt_kind_h, &
		 ls_prefix_h, ls_auth_method_h, ls_type_h, ls_used_level_h, ls_auto_validkey, ls_validkey_loc, &
		 ls_n_auth_method, ls_auto_validitem, ls_n_validitem3, ls_n_validitem2, ls_n_validitem1, &
		 ls_n_langtype, ls_validkey_1, ls_n_validitem3_1 
Long   ll_cnt, li_return, ll_length_h, ll_length, li_random_length, ll_boss_check
//"b1w_validkey_update_popup_2_2%ue_save"
String ls_gkid, ls_auth_method, ls_cusnm, ls_ip_address, ls_h323id, ls_ref_desc, ls_act_status
String ls_customernm, ls_svccod, ls_sys_langtype, ls_langtype, ls_svctype
decimal ldc_svcorderno
//공통 
String ls_sysdt, ls_cid, ls_temp, ls_validkeyloc, ls_h323id_old, ls_validkey_type_old, ls_crt_kind_old

//Ver 2.0 추가
String ls_customerid, ls_contractseq, ls_partner, ls_orderno, ls_validkeymst_status[], ls_validkey_msg
String ls_activedt  //2005.04.18 juede [fromdt >= activedt ] 
String ls_addition_code, ls_addition_itemcod,ls_callforward_code[],ls_password_old,ls_password_new
String ls_callingnum_all, ls_callingnum[],ls_callforwardno_old,  ls_callforwardno_new, ls_call_todt
Date  ld_addition_item_todt
Long ll_callforward_seq_old, ll_callforward_seq_new,ll_callingnum_cnt
Int i

//2009.05.27 UBS 2차 추가
LONG		ll_new_orderno,	ll_return,			ll_validkey_chk
STRING	ls_validkey_old,	ls_fromdt_old,		ls_errmsg,		ls_sysdate

ii_rc = -1
//인증Key 관리모듈포함 version 2.0 khpark modify 2004.06.02.
//validkeymst 상태(is_caller 모두 사용함으로 상단에 코팅)
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P400", ls_ref_desc)   
If ls_temp = "" Then Return 
fi_cut_string(ls_temp, ";" , ls_validkeymst_status[])   //인증Key관리상태(생성;개통;해지)

//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_crt_kind_code[])		

//부가서비스유형코드(착신전환부가서비스코드)
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_callforward_code[])		

Choose Case is_caller
	Case "b1w_validkey_update_popup_1_1_v20%ue_save"          //인증Key 관리모듈포함 version 2.0
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_1_v20%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey						//변경전..
//		lu_dbmgr.is_data[3]  = is_pgm_id
//		lu_dbmgr.is_data[4]  = is_inout_svctype
//		//khpark add 2005-07-11
//		lu_dbmgr.is_data[5]  = is_addition_code      	 //착신전환부가서비스코드
//		lu_dbmgr.is_data[6]  = is_addition_itemcod    	 //착신전환부가서비스품목
//		lu_dbmgr.il_data[1]  = il_callforward_seq        //착신전환정보 seq
//		lu_dbmgr.id_data[1]  = id_addition_item_todt  	 //착신전환부가서비스품목 todt		
	
		idw_data[1].accepttext()
		
		ls_addition_code       = is_data[5]
		ls_addition_itemcod    = is_data[6]
		ll_callforward_seq_old = il_data[1]
		ld_addition_item_todt  = id_data[1]
    	If IsNull(ls_addition_code)    Then ls_addition_code = ""
		If IsNull(ls_addition_itemcod) Then ls_addition_itemcod = ""
		
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
        If is_data[4] = 'Y' Then
			 ls_validkey_msg = 'Route-No.'
		Else
			 ls_validkey_msg = '인증KEY'
		End IF
	
      ls_validkey     = fs_snvl(idw_data[1].object.new_validkey[1], '') //NEW
		ls_fromdt_1     = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt       = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt     = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf  = ls_new_todt
		ls_vpassword    = fs_snvl(idw_data[1].object.new_vpassword[1]   , '')
		ls_langtype     = idw_data[1].object.new_langtype[1]
		ls_svctype      = idw_data[1].object.svctype[1]
		ls_cid          = idw_data[1].object.cid[1]
		ls_validkey_loc = fs_snvl(idw_data[1].object.new_validkey_loc[1], '')
		
		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		If IsNull(ls_activedt) Then ls_activedt = ""
		//2005.04.18 juede  fromdt >= activedt 로 조건변경------end
				
		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
		If IsNull(ls_fromdt)   Then ls_fromdt = ""
		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
			ls_new_todt = ""
			ls_new_todt_cf = '99991231'
		End if
		If IsNull(ls_langtype) or ls_langtype = "" Then 
			ls_langtype = ls_sys_langtype
		End IF
		If IsNull(ls_cid) Then ls_cid = ""
	
		//인증키 관리하지 않는 서비스는 validinfo에 데이터 넣기 위해서 검색함! 2009.07.09 CJH
		SELECT COUNT(*) 
		INTO :ll_validkey_chk
		FROM   VALIDKEYMST
		WHERE  VALIDKEY = :ls_validkey;
		
		ls_svccod      = fs_snvl(idw_data[1].object.svccod[1]         , '')
		ls_ip_address  = fs_snvl(idw_data[1].object.ip_address[1]     , '')
		ls_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')
    	ls_h323id      = fs_snvl(idw_data[1].object.h323id[1]         , '')
		ls_customerid  = fs_snvl(idw_data[1].object.customerid[1]     , '')              // ver2.0 khpark add
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		ls_partner     = fs_snvl(idw_data[1].object.reg_partner[1]    , '')
		ls_orderno     = String(idw_data[1].object.orderno[1])   
		//2009.05.27 ubs 2차 개발시 추가.
      ls_validkey_old = fs_snvl(idw_data[1].object.validkey[1], '') //old
		ls_fromdt_old   = string(idw_data[1].object.fromdt[1],'yyyymmdd')		

		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		If IsNull(ls_orderno) Then ls_orderno = '0'
		
	   //변경전...  
		ls_priceplan         = fs_snvl(idw_data[1].object.priceplan[1]    , '')
		ls_h323id_old        = fs_snvl(idw_data[1].object.validitem3[1]   , '')
//		ls_validkey_type_old = fs_snvl(idw_data[1].object.validkey_type[1], '')
		
//		SELECT CRT_KIND
//		  INTO :ls_crt_kind_old
//        FROM VALIDKEY_TYPE
//       WHERE VALIDKEY_TYPE = :ls_validkey_type_old;
//		
//		If sqlca.sqlcode < 0 Then
//			f_msg_sql_err(is_title, is_caller +"Select VALIDKEY_TYPE(변경전 : CRT_KIND)")				
//			Return 
//		End If
//
		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크   2005.04.18 juede comment 처리
		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//If ls_fromdt <= ls_sysdt Then
		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜보다 커야합니다.")
		//	idw_data[1].SetFocus()
		//	idw_data[1].SetColumn("new_fromdt")
		//	Return
		//End If		
		
		
		//2013.01.17 SUNZU KIM ADD
		//적용시작일은 OPEN할때, defalut로 오늘+1일 후가 뜨고, 당일 개통이 있으므로,
		//오늘 날짜나, 혹은 그 이후로, 입력한 대로, SVCORDER.REQUESTDT에 반영되도록 수정함.
		//이에, 위의 날짜 체크를 막은 이유는 모르겠으나, 오늘 날짜 이전의 데이타가 들어가지 않도록
		//로직 추가함. 
		ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		If ls_fromdt < ls_sysdt Then
			f_msg_usr_err(210, is_Title, "적용시작일은 과거일자로 입력할 수 없습니다.!!")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If	
			
		
		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---start
		If ls_fromdt < ls_activedt Then
			f_msg_usr_err(210, is_Title, "적용시작일은 개통일자 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If				
		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---end		
		
	/* ----- */
		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
		
		If li_return = -1 Then
		    return
		End IF

     	ls_validkey_type = Trim(idw_data[1].object.new_validkey_type[1])
		ls_priceplan     = Trim(idw_data[1].object.priceplan[1])
		
		//인증KEY의 validkey_type에 따른 처리
		li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type,ls_validkey_typenm,ls_crt_kind,ls_prefix,ll_length,ls_auth_method,ls_type,ls_used_level) 
		
		If li_return = -1 Then
			 return
		End IF
		
		Choose Case ls_crt_kind		
			Case ls_crt_kind_code[1]   //수동Manual
				
			Case ls_crt_kind_code[2]   //AutoRandom
						
				ls_auto_validkey = ""
				
				//validkey 생성에 따른 prefix 및 길이 Check
				IF isnull(ls_prefix) or ls_prefix = "" Then
					ls_prefix = ""
					li_random_length = ll_length
				Else
					li_random_length = ll_length - LenA(ls_prefix)
				END IF
						
				DO  //validkey random 생성
					ls_auto_validkey = ls_prefix + fs_get_randomize_v20(li_random_length)
	
					select count(validkey)
					  into :ll_cnt
					  from validinfo
					 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
							 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
							 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
						and validkey = :ls_auto_validkey
						and svccod   = :ls_svccod;	
						
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, " Select Error(validinfo check)")
						RollBack;
						ii_rc = -1				
						Return 
					End If		
				
				LOOP WHILE(ll_cnt>0)		
				
				idw_data[1].object.new_validkey[1] = ls_auto_validkey
	
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

				idw_data[1].object.new_validkey[1] = ls_auto_validkey
				
			Case ls_crt_kind_code[4]   //자원관리Resource
				
			Case ls_crt_kind_code[5]   //고객대체				
				
		End Choose                
		
		If ls_auto_validkey <> '' Then
			ls_validkey_1 = ls_auto_validkey		//AUTO NEW
		Else
			ls_validkey_1 = ls_validkey  			//NEW
		End If
		
		IF ll_validkey_chk <= 0 THEN				//2009.07.09 CJH	인증키 관리하지 않는 서비스 이면
			//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
			ll_cnt = 0
			select count(validkey)
			  into :ll_cnt
			 from validinfo
			where validkey = :ls_validkey
			  and to_char(fromdt,'yyyymmdd') = :ls_fromdt 
			  and svccod = :ls_svccod;
			//and svctype = :ls_svctype;   ohj 05.05.03
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				return 
			End if
		END IF
		
		//인증KEY 중복 check  
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(validkey)
		  into :ll_cnt
		  from validinfo
		 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
				 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			and validkey = :ls_validkey_1
			and svccod   = :ls_svccod;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, ls_validkey_msg +"[" + ls_validkey_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			ii_rc = -3					
			return 
		End if

		ls_n_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')						 
		ls_n_validitem3  = fs_snvl(idw_data[1].object.h323id[1]         , '')  //new
		
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
						IF MidA(ls_n_auth_method,7,4) = "H323" Then
		
							select count(validkey)
							  into :ll_cnt
							  from validinfo
							 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
									( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
									:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
								and validitem3 = :ls_auto_validitem
								and svccod     = :ls_svccod;									 
								
							If sqlca.sqlcode < 0 Then
								f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
								Return 
							End If
						End IF  
						 
					LOOP WHILE(ll_cnt > 0)		
					
					idw_data[1].object.h323id[1] = ls_auto_validitem

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

					idw_data[1].object.h323id[1] = ls_auto_validitem
					
				Case ls_crt_kind_code[4]   //자원관리Resource
					
				Case ls_crt_kind_code[5]   //고객대체
				
			End Choose
		End IF	 
		
		ls_n_langtype    = idw_data[1].object.new_langtype[1]
		ls_n_validitem2  = idw_data[1].object.ip_address[1]
//			ls_n_validitem3  = idw_data[1].object.h323id[1]
		ls_n_validitem1  = idw_data[1].object.cid[1]
		
		If ls_auto_validitem <> '' Then
			ls_n_validitem3_1 = ls_auto_validitem
		Else
			ls_n_validitem3_1 = ls_n_validitem3
		End If
		
		//인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
		ll_cnt = 0
		IF MidA(ls_n_auth_method,7,4) = "H323" Then

			select count(validkey)
			  into :ll_cnt
			  from validinfo
			  where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
					( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
					  and validitem3 = :ls_n_validitem3_1
				and svccod = :ls_svccod;
				
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
				Return 
			End If
				
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("h323id")
				ii_rc = -3					
				return 
			End if
		End IF  
	/* ----- */

		//인증KEY 인증KeyType이 자원관리인 경우만 처리		
//		If ls_crt_kind_old = ls_crt_kind_code[4]  Then  		
			
			//VALIDKEYMST UPDATE  변경전 인증키 상태변경
//2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.
			Update validkeymst
				set status      = :ls_validkeymst_status[3]
				  , sale_flag   = '0'
				  , activedt    = null
				  , customerid  = null
				  , orderno     = null
				  , contractseq = null
				  , updt_user   = :gs_user_id
				  , updtdt      = sysdate
				  , pgm_id      = :is_data[3] 
			 Where validkey    = :is_data[2]
				and contractseq = :ls_contractseq ;
			  
			 If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table(old)")				
				Return 
			 End If
//2009.05.27------------------------------------------------------END			
			 
			//VALIDKEYMST_LOG INSERT   변경전 인증키 상태변경 로그남기기
//2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.			
			 Insert Into validkeymst_log
						  ( validkey
						  , seq
						  , status
						  , actdt
						  , customerid
						  , contractseq
						  , partner
						  , crt_user, crtdt, pgm_id )
					Select validkey
						  , seq_validkeymstlog.nextval
						  , :ls_validkeymst_status[3]
						  , to_date(:ls_fromdt,'yyyy-mm-dd')
						  , :ls_customerid
						  , :ls_contractseq
						  , :ls_partner
						  , :gs_user_id, sysdate, :is_data[3] 
					 From validkeymst
					Where validkey    = :is_data[2]
					  and contractseq = :ls_contractseq ;
			 
			 If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table(old)")				
				Return 
			 End If
//2009.05.27------------------------------------------------------END			
		
		//인증KEY 인증KeyType이 자원관리인 경우만 처리	
//2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.					
		If ls_crt_kind = ls_crt_kind_code[4]  Then 
			
			//변경된 인증key 상태 '개통'으로 update
			Update validkeymst
				set status      = :ls_validkeymst_status[2]
				  , sale_flag   = '1'
				  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
				  , customerid  = :ls_customerid
				  /*, orderno     = :ls_orderno */
				  , contractseq = :ls_contractseq 
				  , updt_user   = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
			 Where validkey    = :ls_validkey_1 
			   AND validkey_type = :ls_validkey_type  ;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table(new)")					
				Return 
			End If
			
			//변경된 인증key 로그 남기기 '개통'
			Insert Into validkeymst_log
						 ( validkey
						 , seq
						 , status
						 , actdt
						 , customerid
						 , contractseq
						 , partner
						 , crt_user, crtdt, pgm_id )
				  Select validkey
						 , seq_validkeymstlog.nextval
						 , :ls_validkeymst_status[2]
						 , to_date(:ls_fromdt,'yyyy-mm-dd')
						 , :ls_customerid
						 , :ls_contractseq
						 , :ls_partner
						 , :gs_user_id, sysdate, :is_data[3]
					 From validkeymst 
					Where validkey      = :ls_validkey_1
					  AND validkey_type = :ls_validkey_type  ;
					  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table(new)")				
				Return 
			End If
		End If
//2009.05.27------------------------------------------------------END			
		
		//h323id 관리
//2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.							
		If ls_h323id <> ls_h323id_old Then
			
			//validitem3(H323ID) KeyType이 자원관리인 경우만 처리   
//					If ls_crt_kind_h = ls_crt_kind_code[4]  Then  
				If ls_h323id_old <> '' Then
					//변경전 h323id'해지'
					Update validkeymst
						set status      = :ls_validkeymst_status[3]
						  , sale_flag   = '0'
						  , activedt    = null
						  , customerid  = null
						  , orderno     = null
						  , contractseq = null
						  , updt_user   = :gs_user_id
						  , updtdt      = sysdate
						  , pgm_id      = :is_data[3] 	
					 Where validkey    = :ls_h323id_old
					  and contractseq  = :ls_contractseq  ;
											 
					  
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						f_msg_sql_err(is_title, is_caller + " Update validkeymst Table (h323id: old")					
						Return 
					End If
						
					Insert Into validkeymst_log
								 ( validkey, seq, status, actdt, customerid
								 , contractseq, partner, crt_user, crtdt, pgm_id )
						  select :ls_h323id_old, seq_validkeymstlog.nextval, :ls_validkeymst_status[3],
									 to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
									:ls_partner, :gs_user_id, sysdate, :is_data[4] 
							  from validkeymst
							 Where validkey     = :ls_h323id_old
							 and contractseq  = :ls_contractseq  ;									  
									
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: h323id old")				
						Return 
					End If
				End If
				
			If ls_crt_kind_h = ls_crt_kind_code[4]  Then  										
		
				If ls_n_validitem3_1 <> '' Then
					//변경후 h323id '개통'
					Update validkeymst
						set status      = :ls_validkeymst_status[2]
						  , sale_flag   = '1'
						  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
						  , customerid  = :ls_customerid
						  , orderno     = :ls_orderno
						  , contractseq = :ls_contractseq 
						  , updt_user   = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
					 Where validkey    = :ls_n_validitem3_1   
						and validkey_type = :ls_validkey_type_h;													 
					  
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						f_msg_sql_err(is_title, is_caller + " Update validkeymst Table (h323id: new")					
						Return 
					End If
						
					Insert Into validkeymst_log
								 ( validkey, seq, status, actdt, customerid
								 , contractseq, partner, crt_user, crtdt, pgm_id )
						  values 
								 (:ls_n_validitem3_1, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
									 to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
									:ls_partner, :gs_user_id, sysdate, :is_data[4] );			
									
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: h323id new")				
						Return 
					End If
				End If
			End If
		End If
//2009.05.27------------------------------------------------------END			

		
//			End IF
		//2010.05.19 추가함. 인증키 변경할 때 인증서비스에 해당하는놈들만 인증받도록...나머지는 그냥 처리하도록
		IF ll_validkey_chk > 0 THEN
			
			SELECT COUNT(*) 
			INTO :ll_boss_check
			FROM   SYSCOD2T
			WHERE  GRCODE = 'BOSS03'
	      AND    CODE = :ls_svccod;
			
			IF ll_boss_check <= 0 THEN
				ll_validkey_chk = 0
			END IF
		END IF
		
		IF ll_validkey_chk > 0 THEN				//인증키 관리하는 서비스만 인증하도록! 2009.07.09 CJH
			//Get SVCORDER Sequence
			SELECT SEQ_ORDERNO.NEXTVAL 
			INTO :ll_new_orderno
			FROM   DUAL;
			
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;	
				f_msg_sql_err(is_title, is_caller + " SVCORDER SEQUENCE ERROR")
				RETURN 
			END IF				
			//Insert SVCORDER. STATUS=80 ( 번호변경신청 ) SYSCOD2T : B300 
			INSERT INTO SVCORDER ( ORDERNO,				CUSTOMERID,			ORDERDT,			REQUESTDT,
										  STATUS,				SVCCOD,				PRICEPLAN,		PRICEMODEL,
										  PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
										  MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
										  CRT_USER,	CRTDT,	PGM_ID )
			SELECT 	:ll_new_orderno,	CUSTOMERID,			TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),	
						/*SYSDATE, */     TO_DATE(:ls_fromdt, 'YYYYMMDD'),
						'80',					SVCCOD,				PRICEPLAN,		PRICEMODEL,
						PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
						MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
						:gs_user_id,		SYSDATE,				:is_data[3]
			FROM		SVCORDER
			WHERE    ORDERNO = TO_NUMBER(:ls_orderno);
			
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;	
				f_msg_sql_err(is_title, is_caller + " INSERT SVCORDER Table")
				RETURN 
			END IF
			//참고!!...SVCORDER INSERT시 TRG_SVCORDER 를 타고 VALIDINFO를 처리한다. 
			
			
			//변경된 인증key 상태 orderno 를 ll_new_orderno로 update
			Update validkeymst
				set orderno     = :ll_new_orderno
			 Where validkey    = :ls_validkey_1 
			   AND validkey_type = :ls_validkey_type  ;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table(new)")					
				Return 
			End If
			
			
			
			
			//Insert VALIDINFO_CHANGE . 변경전 인증키
			INSERT INTO VALIDINFO_CHANGE 
			       ( VALIDKEY,		   FROMDT,			TODT,
                  STATUS,			   USE_YN,			VPASSWORD,
                  VALIDITEM,		   GKID,				CUSTOMERID,
                  SVCCOD,			   SVCTYPE,			PRICEPLAN,
                  ORDERNO,		      CONTRACTSEQ,	VALIDITEM1,
                  VALIDITEM2,	      VALIDITEM3,		AUTH_METHOD,
                  VALIDKEY_LOC,	   LANGTYPE,		CRT_USER,
                  CRTDT,			   PGM_ID,			UPDT_USER,
                  UPDTDT,			   CHANGE_TYPE,	TIMESTAMP )
			SELECT	VALIDKEY,			FROMDT,			TO_DATE(:ls_fromdt, 'YYYYMMDD'),
						'99',					'N',				VPASSWORD,
						VALIDITEM,			GKID,				CUSTOMERID,
						SVCCOD,				SVCTYPE,			PRICEPLAN,
						:ll_new_orderno,	CONTRACTSEQ,	VALIDITEM1,
						VALIDITEM2,			VALIDITEM3,		AUTH_METHOD,
						VALIDKEY_LOC,		LANGTYPE,		:gs_user_id,
						SYSDATE,				:is_data[3],	:gs_user_id,
						SYSDATE,				'0',				''
			FROM		VALIDINFO
			WHERE    VALIDKEY = :is_data[2]
			AND      TO_CHAR(FROMDT, 'YYYYMMDD') = :ls_fromdt_old
			AND      SVCCOD = :ls_svccod;		
			
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;
				MessageBox("", ls_fromdt_old + ' ' +SQLCA.SQLERRTEXT )
				f_msg_sql_err(is_title, is_caller + " INSERT VALIDINFO_CHANGE(OLD) Table")
				RETURN 
			END IF		
	
			//Insert VALIDINFO_CHANGE . 변경후 인증키
			INSERT INTO VALIDINFO_CHANGE ( VALIDKEY,		FROMDT,			TODT,
													 STATUS,			USE_YN,			VPASSWORD,
													 VALIDITEM,		GKID,				CUSTOMERID,
													 SVCCOD,			SVCTYPE,			PRICEPLAN,
													 ORDERNO,		CONTRACTSEQ,	VALIDITEM1,
													 VALIDITEM2,	VALIDITEM3,		AUTH_METHOD,
													 VALIDKEY_LOC,	LANGTYPE,		CRT_USER,
													 CRTDT,			PGM_ID,			UPDT_USER,
													 UPDTDT,			CHANGE_TYPE,	TIMESTAMP )
			SELECT	:ls_validkey_1,	TO_DATE(:ls_fromdt, 'YYYYMMDD'),	TO_DATE(:ls_new_todt, 'YYYYMMDD'),
						STATUS,				'Y',										:ls_vpassword,
						VALIDITEM,			GKID,										CUSTOMERID,
						SVCCOD,				SVCTYPE,									PRICEPLAN,
						:ll_new_orderno,	CONTRACTSEQ,							:ls_cid,
						:ls_ip_address,	:ls_n_validitem3_1,					:ls_auth_method,
						:ls_validkey_loc,	:ls_langtype,							:gs_user_id,
						SYSDATE,				:is_data[3],							:gs_user_id,
						SYSDATE,				'N',										''
			FROM     VALIDINFO
			WHERE    VALIDKEY = :is_data[2]
			AND  		TO_CHAR(FROMDT, 'YYYYMMDD') = :is_data[1]
			AND 		SVCCOD = :ls_svccod;
	
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;	
				f_msg_sql_err(is_title, is_caller + " INSERT VALIDINFO_CHANGE(NEW) Table")
				RETURN 
			END IF	
			
			//2009.06.07 추가. SIID 오더번호 업데이트!!!
			UPDATE SIID
			SET    ORDERNO = :ll_new_orderno,
					 UPDTDT = SYSDATE
			WHERE  CONTRACTSEQ = :ls_contractseq;
			
			IF SQLCA.SQLCODE < 0 THEN		//For Programer
				MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
				ROLLBACK;				
				RETURN 
			END IF		
			
			//프로비져닝 프로시저 실패해도 롤백시키지 않기 위해서!
			commit;
			
			SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO :ls_sysdate
			FROM   DUAL;
			
			IF ls_sysdate = ls_fromdt THEN			//적용시작일이 현재일 이어야만 연동처리
				//프로비져닝 프로시저 호출
				ls_errmsg = space(1000)
				SQLCA.UBS_PROVISIONNING(ll_new_orderno,		'TEL322',		0,					&
												ls_validkey_1,			gs_shopid,		is_data[3],		&
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
			END IF
		ELSE		//인증키 관리하지 않는 케이스
			//Get SVCORDER Sequence
			SELECT SEQ_ORDERNO.NEXTVAL INTO :ll_new_orderno
			FROM   DUAL;
			
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;	
				f_msg_sql_err(is_title, is_caller + " SVCORDER SEQUENCE ERROR")
				RETURN  
			END IF				
			//Insert SVCORDER. STATUS=85 ( 번호변경완료 ) SYSCOD2T : B300 
			//2013.01.17 SUNZU KIM MODIFY
			//수정내용: 화면에서 사용자가 입력한 적용일자로 저장되도록.
			//        : REQUESTDT컬럼값에 sysdate--> TO_DATE(:ls_fromdt, 'YYYYMMDD')로 수정.      
			INSERT INTO SVCORDER ( ORDERNO,				CUSTOMERID,			ORDERDT,			REQUESTDT,
										  STATUS,				SVCCOD,				PRICEPLAN,		PRICEMODEL,
										  PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
										  MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
										  CRT_USER,	CRTDT,	PGM_ID )
			SELECT 	:ll_new_orderno,	CUSTOMERID,			TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),	
			         /*SYSDATE, */     TO_DATE(:ls_fromdt, 'YYYYMMDD'),
						'85',					SVCCOD,				PRICEPLAN,		PRICEMODEL,
						PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
						MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
						:gs_user_id,		SYSDATE,				:is_data[3]
			FROM		SVCORDER
			WHERE    ORDERNO = TO_NUMBER(:ls_orderno);
			
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;	
				f_msg_sql_err(is_title, is_caller + " INSERT SVCORDER Table")
				RETURN 
			END IF
			
			//2013/07/08 인증키 관리 품목이 아니더라도 VALIDINFO_CHANGE 에 INSERT되도록 수정
			//Insert VALIDINFO_CHANGE . 변경전 인증키
			INSERT INTO VALIDINFO_CHANGE 
			       ( VALIDKEY,		   FROMDT,			TODT,
                  STATUS,			   USE_YN,			VPASSWORD,
                  VALIDITEM,		   GKID,				CUSTOMERID,
                  SVCCOD,			   SVCTYPE,			PRICEPLAN,
                  ORDERNO,		      CONTRACTSEQ,	VALIDITEM1,
                  VALIDITEM2,	      VALIDITEM3,		AUTH_METHOD,
                  VALIDKEY_LOC,	   LANGTYPE,		CRT_USER,
                  CRTDT,			   PGM_ID,			UPDT_USER,
                  UPDTDT,			   CHANGE_TYPE,	TIMESTAMP , PROVISION_FLAG )
			SELECT	VALIDKEY,			FROMDT,			TO_DATE(:ls_fromdt, 'YYYYMMDD'),
						'99',					'N',				VPASSWORD,
						VALIDITEM,			GKID,				CUSTOMERID,
						SVCCOD,				SVCTYPE,			PRICEPLAN,
						:ll_new_orderno,	CONTRACTSEQ,	VALIDITEM1,
						VALIDITEM2,			VALIDITEM3,		AUTH_METHOD,
						VALIDKEY_LOC,		LANGTYPE,		:gs_user_id,
						SYSDATE,				:is_data[3],	:gs_user_id,
						SYSDATE,				'0',				'',			'NA'
			FROM		VALIDINFO
			WHERE    VALIDKEY = :is_data[2]
			AND      TO_CHAR(FROMDT, 'YYYYMMDD') = :ls_fromdt_old
			AND      SVCCOD = :ls_svccod;		
			
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;
				//MessageBox("", SQLCA.SQLERRTEXT )
				f_msg_sql_err(is_title, is_caller + " INSERT VALIDINFO_CHANGE(OLD) Table")
				RETURN 
			END IF		
	
			//Insert VALIDINFO_CHANGE . 변경후 인증키
			INSERT INTO VALIDINFO_CHANGE ( VALIDKEY,		FROMDT,			TODT,
													 STATUS,			USE_YN,			VPASSWORD,
													 VALIDITEM,		GKID,				CUSTOMERID,
													 SVCCOD,			SVCTYPE,			PRICEPLAN,
													 ORDERNO,		CONTRACTSEQ,	VALIDITEM1,
													 VALIDITEM2,	VALIDITEM3,		AUTH_METHOD,
													 VALIDKEY_LOC,	LANGTYPE,		CRT_USER,
													 CRTDT,			PGM_ID,			UPDT_USER,
													 UPDTDT,			CHANGE_TYPE,	TIMESTAMP, 	PROVISION_FLAG )
			SELECT	:ls_validkey_1,	TO_DATE(:ls_fromdt, 'YYYYMMDD'),	TO_DATE(:ls_new_todt, 'YYYYMMDD'),
						STATUS,				'Y',										:ls_vpassword,
						VALIDITEM,			GKID,										CUSTOMERID,
						SVCCOD,				SVCTYPE,									PRICEPLAN,
						:ll_new_orderno,	CONTRACTSEQ,							:ls_cid,
						:ls_ip_address,	:ls_n_validitem3_1,					:ls_auth_method,
						:ls_validkey_loc,	:ls_langtype,							:gs_user_id,
						SYSDATE,				:is_data[3],							:gs_user_id,
						SYSDATE,				'N',										'', 		'NA'
			FROM     VALIDINFO
			WHERE    VALIDKEY = :is_data[2]
			AND  		TO_CHAR(FROMDT, 'YYYYMMDD') = :is_data[1]
			AND 		SVCCOD = :ls_svccod;
	
			IF SQLCA.SQLCode <> 0 THEN
				ROLLBACK;	
				f_msg_sql_err(is_title, is_caller + " INSERT VALIDINFO_CHANGE(NEW) Table")
				RETURN 
			END IF	
			//2013/07/08 인증키 관리 품목이 아니더라도 VALIDINFO_CHANGE 에 INSERT되도록 수정
			
			//변경전 인증키 미사용으로 update
			Update validinfo
				Set use_yn    = 'N'
				  , status    = '99'  //20080825 hcjung
				  , todt      = to_date(:ls_fromdt,'yyyy-mm-dd')
				  , updt_user = :gs_user_id
				  , updtdt    = sysdate
				  , pgm_id    = :is_data[3]
			 Where validkey  = :is_data[2]
				And to_char(fromdt,'yyyymmdd') = :is_data[1] 
				and svccod    = :ls_svccod;
				//and svctype = :ls_svctype;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
				Return 
			End If

			//Insert  변경후 인증키 insert
			insert into validinfo
						 ( validkey      , fromdt     , todt
						 , status        , use_yn     , vpassword
						 , validitem     , gkid       , customerid
						 , svccod        , svctype    , priceplan
						 , orderno       , contractseq, validitem1
						 , validitem2    , validitem3 , auth_method
						 , validkey_loc  , langtype 
						 , crt_user      , crtdt  	   , pgm_id      
						 , updt_user     , updtdt                             )
				  select :ls_validkey_1, to_date(:ls_fromdt,'yyyy-mm-dd')
						 , to_date(:ls_new_todt,'yyyy-mm-dd')
						 , :ls_validkeymst_status[2], 'Y'   , :ls_vpassword
						 , validitem     , gkid, customerid
						 ,	svccod        , svctype
						 , priceplan     , orderno
						 , contractseq   , :ls_cid, :ls_ip_address
						 , :ls_n_validitem3_1 , :ls_auth_method,	:ls_validkey_loc
						 , :ls_langtype  
						 , :gs_user_id   , sysdate, :is_data[3]
						 , :gs_user_id   , sysdate
					 from validinfo
					where validkey  = :is_data[2]
					  and to_char(fromdt,'yyyymmdd') = :is_data[1] 
					  and svccod    = :ls_svccod;
					//and svctype = :ls_svctype;

			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
				Return 
			End If
			
			
			
		END IF			
//2009.05.27------------------------------------------END


//2009.05.27 UBS 2차 개발시 제외됨. 나중을 위하여 주석처리					
//		ls_callforwardno_old = idw_data[1].object.callforwardno[1]
//		ls_callforwardno_new = idw_data[1].object.new_callforwardno[1]
//    ls_password_new =  idw_data[1].object.new_password[1]
//    ls_callingnum_all = idw_data[1].object.callingnum[1]
//		ls_call_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')	//변경후 적용시작일 -1 일 
//		If IsNull(ls_callforwardno_old) Then ls_callforwardno_old = ""
//		If IsNull(ls_callforwardno_new) Then ls_callforwardno_new = ""
//		If IsNull(ls_password_new) Then ls_password_new = ""
//		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""
//		
//	   //khpark add 2005-07-11 start(착신전환부가서비스)
//		CHOOSE CASE ls_addition_code  
//			CASE ls_callforward_code[1]   //착신전환일반유형일때 
//
//				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
//					
//					Update callforwarding_info
//					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
//						  updtdt = sysdate,
//						  pgm_id = :is_data[3]
//					where seq = :ll_callforward_seq_old;						
//				End If
//				
//				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
//					
//					//callforwarding_info_seq 가져 오기
//					Select seq_callforwarding_info.nextval
//					  Into :ll_callforward_seq_new
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
//						ii_rc = -1			
//						RollBack;
//						Return 
//					End If
//					
//					Insert Into callforwarding_info
//						( seq,orderno,contractseq,itemcod,
//						  addition_code,validkey,password,
//						  callforwardno,fromdt,todt,
//						  crt_user,crtdt, pgm_id ) 
//					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
//							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
//							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
//							 :gs_user_id,sysdate, :is_data[3]);
//							 
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
//						ii_rc = -1						
//						RollBack;
//						Return 
//					End If									 
//
//				End IF
//					
//			CASE ls_callforward_code[2]     //착신전환비밀번호인증일때
//
//				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
//					
//					Update callforwarding_info
//					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
//						  updtdt = sysdate,
//						  pgm_id = :is_data[3]
//					where seq = :ll_callforward_seq_old;						
//				End If
//				
//				If ls_callforwardno_new <> "" Then    //변경후 착신전환번호가 있을 경우
//
//					//callforwarding_info_seq 가져 오기
//					Select seq_callforwarding_info.nextval
//					  Into :ll_callforward_seq_new
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
//						ii_rc = -1			
//						RollBack;
//						Return 
//					End If
//					
//					Insert Into callforwarding_info
//						( seq,orderno,contractseq,itemcod,
//						  addition_code,validkey,password,
//						  callforwardno,fromdt,todt,
//						  crt_user,crtdt, pgm_id ) 
//					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
//							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
//							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
//							 :gs_user_id,sysdate, :is_data[3] );
//
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
//						ii_rc = -1						
//						RollBack;
//						Return 
//					End If									 
//
//				End IF						
//				
//			CASE ls_callforward_code[3]     //착신전환발신번호인증일때
//				
//				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
//					
//					Update callforwarding_info
//					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
//						  updtdt = sysdate,
//						  pgm_id = :is_data[3]
//					where seq = :ll_callforward_seq_old;						
//				End If					
//				
//				ll_callingnum_cnt = fi_cut_string(ls_callingnum_all, ";" , ls_callingnum[])
//
//				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
//					//callforwarding_info_seq 가져 오기
//					Select seq_callforwarding_info.nextval
//					  Into :ll_callforward_seq_new
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
//						ii_rc = -1			
//						RollBack;
//						Return 
//					End If
//					
//					Insert Into callforwarding_info
//						( seq,orderno,contractseq,itemcod,
//						  addition_code,validkey,password,
//						  callforwardno,fromdt,todt,
//						  crt_user,crtdt, pgm_id ) 
//					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
//							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
//							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
//							 :gs_user_id,sysdate, :is_data[3] );
//
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
//						ii_rc = -1						
//						RollBack;
//						Return 
//					End If									 
//					
//					//발신가능전화번호 insert
//					For i = 1 To ll_callingnum_cnt	
//						Insert Into callforwarding_auth
//						( seq,callingnum,
//						  crt_user,crtdt, pgm_id ) 
//						Values ( :ll_callforward_seq_new,:ls_callingnum[i],
//							 :gs_user_id,sysdate, :is_data[3] );
//
//						If SQLCA.SQLCode < 0 Then
//							f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
//							ii_rc = -1						
//							RollBack;
//							Return 
//						End If									 
//							 
//					Next
//				End IF						
//				
//		END CHOOSE
//2009.05.27------------------------------------------------------END			

		//khpark add 2005-07-11 start							
		
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey_1 + "]로 변경되었습니다.")
		commit;
		
	Case "b1w_validkey_update_popup_2_1_v20%ue_save"			//인증Key 관리모듈포함 version 2.0
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_1_v20%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_itemcod
//		lu_dbmgr.is_data[2]  = is_contractseq
//		lu_dbmgr.is_data[3]  = is_svctype
//		lu_dbmgr.is_data[4]  = is_pgm_id
//		lu_dbmgr.is_data[5]  = is_inout_svctype
//		lu_dbmgr.is_data[6]  = is_status
//		//lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt      //validkeytype count
//		//khpark add 2005-07-12
//		lu_dbmgr.is_data[7]  = is_addition_code      	 //착신전환부가서비스코드
//		lu_dbmgr.is_data[8]  = is_addition_itemcod    	 //착신전환부가서비스품목
//		lu_dbmgr.id_data[1]  = id_addition_item_todt  	 //착신전환부가서비스품목 todt		

		idw_data[1].accepttext()
		
		ls_addition_code = is_data[7]
		ls_addition_itemcod = is_data[8]
		ld_addition_item_todt = id_data[1]	
    	If IsNull(ls_addition_code) Then ls_addition_code = ""
		If IsNull(ls_addition_itemcod) Then ls_addition_itemcod = ""
		
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
		If is_data[5] = 'Y' Then
			 ls_validkey_msg = 'Route-No.'
		Else
			 ls_validkey_msg = '인증KEY'
		End IF
		
		//gkid default 값
		ls_gkid = fs_get_control("00", "G100", ls_ref_desc)
		
		ls_validkey = idw_data[1].object.new_validkey[1]     //추가인증키
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_cid     = idw_data[1].object.cid[1]
		ls_validkeyloc = idw_data[1].object.new_validkey_loc[1]
		
		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		If IsNull(ls_activedt) Then ls_activedt = ""
		//2005.04.18 juede  fromdt >= activedt 로 조건변경------end
		
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
			ls_new_todt = ""
			ls_new_todt_cf = '99991231'
		End if
		If IsNull(ls_vpassword) Then ls_vpassword = ""
		ls_svccod = idw_data[1].object.svccod[1]
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_langtype) or ls_langtype = "" Then 
			ls_langtype = ls_sys_langtype
		End IF
		If IsNull(ls_cid) Then ls_cid = ""
		If IsNull(ls_validkeyloc) Then ls_validkeyloc = ""
		
		ls_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')
	    ls_ip_address  = fs_snvl(idw_data[1].object.ip_address[1]     , '')
		ls_h323id      = fs_snvl(idw_data[1].object.h323id[1]         , '')
		ls_customerid  = fs_snvl(idw_data[1].object.customerid[1]     , '')           // ver2.0 khpark add
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		ls_partner     = idw_data[1].object.reg_partner[1] 
		ls_priceplan   = Trim(idw_data[1].object.priceplan[1])
		
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		If IsNull(ls_partner) Then ls_partner = ""	

//		If ls_validkey = "" Then
//			f_msg_usr_err(200, is_title, "인증KEY")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_validkey")
//			Return
//		End If
//		
//		If ls_vpassword = "" Then
//			f_msg_usr_err(200, is_title, "인증PassWord")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_vpassword")
//			Return
//		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크 2005.04.18 juede comment 처리
		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//If ls_fromdt < ls_sysdt Then
		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜 이상이여야 합니다.")
		//	idw_data[1].SetFocus()
		//	idw_data[1].SetColumn("new_fromdt")
		//	Return
		//End If				
		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---start
		
		If ls_fromdt < ls_activedt Then
			f_msg_usr_err(210, is_Title, "적용시작일은 개통일자 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If		
		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---end		

/* ----- */
		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
		
		If li_return = -1 Then
		    return
		End IF

//			ls_temp = fs_get_control("B1","P400", ls_ref_desc)			
//			If ls_temp = "" Then Return 
//			fi_cut_string(ls_temp, ";" , ls_result_code[])
//			
//			//인증Key 관리상태(개통:20)
//			ls_validkeystatus = ls_result_code[2]			
			
		ls_validkey_type = Trim(idw_data[1].object.new_validkey_type[1])
		
		//인증KEY의 validkey_type에 따른 처리
		li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type,ls_validkey_typenm,ls_crt_kind,ls_prefix,ll_length,ls_auth_method,ls_type,ls_used_level) 
		
		If li_return = -1 Then
			 return
		End IF
		
		Choose Case ls_crt_kind		
			Case ls_crt_kind_code[1]   //수동Manual
				
			Case ls_crt_kind_code[2]   //AutoRandom
						
				ls_auto_validkey = ""
				  //validkey 생성에 따른 prefix 및 길이 Check
				IF isnull(ls_prefix) or ls_prefix = "" Then
							ls_prefix = ""
					li_random_length = ll_length
				Else
					li_random_length = ll_length - LenA(ls_prefix)
				END IF
						
				DO  //validkey random 생성
					ls_auto_validkey = ls_prefix + fs_get_randomize_v20(li_random_length)
	
					select count(validkey)
					  into :ll_cnt
					  from validinfo
					 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
							 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
							 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
						and validkey = :ls_auto_validkey
						and svccod = :ls_svccod;	
						
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, " Select Error(validinfo check)")
						RollBack;
						ii_rc = -1				
						Return 
					End If		
				
				LOOP WHILE(ll_cnt>0)		
				
				idw_data[1].object.new_validkey[1] = ls_auto_validkey
	
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

				idw_data[1].object.new_validkey[1] = ls_auto_validkey
				
			Case ls_crt_kind_code[4]   //자원관리Resource
				
			Case ls_crt_kind_code[5]   //고객대체				
				
		End Choose                
		
		If ls_auto_validkey <> '' Then
			ls_validkey_1 = ls_auto_validkey
		Else
			ls_validkey_1 = ls_validkey
		End If
//			If ls_validkey = "" Then
//				//f_msg_info(200, is_title, ls_validkey_msg)
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("new_validkey")
//				ii_rc = -3
//				Return	
//			End If
		
		//인증KEY 중복 check  
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(validkey)
		  into :ll_cnt
		  from validinfo
		 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
				 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			and validkey = :ls_validkey_1
			and svccod = :ls_svccod;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, ls_validkey_msg +"[" + ls_validkey_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			ii_rc = -3					
			return 
		End if

		ls_n_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')						 
	    ls_n_validitem3  = fs_snvl(idw_data[1].object.h323id[1]         , '')
		
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
						IF MidA(ls_n_auth_method,7,4) = "H323" Then
		
							select count(validkey)
							  into :ll_cnt
							  from validinfo
							 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
									( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
									:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
								and validitem3 = :ls_auto_validitem
								and svccod = :ls_svccod;									 
								
							If sqlca.sqlcode < 0 Then
								f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
								Return 
							End If
						End IF  
						 
					LOOP WHILE(ll_cnt > 0)		
					
					idw_data[1].object.h323id[1] = ls_auto_validitem

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

					idw_data[1].object.h323id[1] = ls_auto_validitem
					
				Case ls_crt_kind_code[4]   //자원관리Resource
					
				Case ls_crt_kind_code[5]   //고객대체
				
			End Choose
		End IF	 
		
		ls_n_langtype    = idw_data[1].object.new_langtype[1]
		ls_n_validitem2  = idw_data[1].object.ip_address[1]
//		ls_n_validitem3  = idw_data[1].object.h323id[1]
		ls_n_validitem1  = idw_data[1].object.cid[1]
		
		If ls_auto_validitem <> '' Then
			ls_n_validitem3_1 = ls_auto_validitem
		Else
			ls_n_validitem3_1 = ls_n_validitem3
		End If
		
		//인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
		ll_cnt = 0
		IF MidA(ls_n_auth_method,7,4) = "H323" Then

			select count(validkey)
			  into :ll_cnt
			  from validinfo
			  where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
					( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
					  and validitem3 = :ls_n_validitem3_1
				and svccod = :ls_svccod;
				
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
				Return 
			End If
				
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("h323id")
				ii_rc = -3					
				return 
			End if
				
		End IF  
		
/*  ---- */		
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
		select max(orderno) 
		  into :ldc_svcorderno
		  From svcorder 
	     Where to_char(ref_contractseq) = :is_data[2]
	       and status = :is_data[6];		
							 
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select svcorder (orderno)")				
			Return 
		End If
		
		//Insert   
		insert into validinfo
			 ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  customerid, svccod, 
			  svctype, priceplan,
			  orderno, contractseq, gkid,
			  validitem1, validitem2, validitem3, auth_method,
			  validkey_loc, crt_user, crtdt,
			  pgm_id, updt_user, updtdt, langtype)
		  select :ls_validkey_1, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
					 status, 'Y', :ls_vpassword,
				customerid, svccod,
				:is_data[3], priceplan,
				:ldc_svcorderno, contractseq, :ls_gkid,
				:ls_cid, :ls_ip_address, :ls_n_validitem3_1, :ls_auth_method,
				:ls_validkeyloc, :gs_user_id, sysdate,
				:is_data[4], :gs_user_id, sysdate, :ls_langtype
			from contractmst
		  where to_char(contractseq) = :is_data[2];

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		//인증KEY 인증KeyType이 자원관리인 경우만 처리
		If ls_crt_kind = ls_crt_kind_code[4]  Then   
			Update validkeymst
				set status      = :ls_validkeymst_status[2]
				  , sale_flag   = '1'
				  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
				  , customerid  = :ls_customerid
				  , orderno     = :ldc_svcorderno
				  , contractseq = :ls_contractseq 
				  , updt_user   = :gs_user_id    ,  updtdt = sysdate,   pgm_id = :is_data[4] 
			  Where validkey      = :ls_validkey_1
				and validkey_type = :ls_validkey_type ;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
				Return 
			End If
				
			Insert Into validkeymst_log
					   ( validkey, seq, status, actdt, customerid
						 , contractseq, partner, crt_user, crtdt, pgm_id )
				 values 
					   (:ls_validkey_1, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
							to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
						  :ls_partner, :gs_user_id, sysdate, :is_data[4] )	;					  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: 인증key")				
				Return 
			End If
		End If
		
		//validitem3(H323ID) KeyType이 자원관리인 경우만 처리
		If ls_crt_kind_h = ls_crt_kind_code[4]  Then   
			IF ls_n_validitem3_1 <> '' Then 
				Update validkeymst
					set status      = :ls_validkeymst_status[2]
					  , sale_flag   = '1'
					  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
					  , customerid  = :ls_customerid
					  , orderno     = :ldc_svcorderno
					  , contractseq = :ls_contractseq 
					  , updt_user   = :gs_user_id    ,  updtdt = sysdate,   pgm_id = :is_data[4] 
				  Where validkey      = :ls_n_validitem3_1
					 and validkey_type = :ls_validkey_type_h ;
										 
				  
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
					Return 
				End If
				
				Insert Into validkeymst_log
							 ( validkey, seq, status, actdt, customerid
							 , contractseq, partner, crt_user, crtdt, pgm_id )
					  values 
							 (:ls_n_validitem3_1, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
								 to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
								:ls_partner, :gs_user_id, sysdate, :is_data[4] );						  
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: h323id")				
					Return 
				End If
			End If
		End If

		ls_callforwardno_new = idw_data[1].object.new_callforwardno[1]
        ls_password_new =  idw_data[1].object.new_password[1]
        ls_callingnum_all = idw_data[1].object.callingnum[1]
		If IsNull(ls_callforwardno_new) Then ls_callforwardno_new = ""
		If IsNull(ls_password_new) Then ls_password_new = ""
		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""
		
	   //khpark add 2005-07-12 start(착신전환부가서비스)
		CHOOSE CASE ls_addition_code  
			CASE ls_callforward_code[1]   //착신전환일반유형일때 

				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
					
					//callforwarding_info_seq 가져 오기
					Select seq_callforwarding_info.nextval
					  Into :ll_callforward_seq_new
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
					Values ( :ll_callforward_seq_new, :ldc_svcorderno,:ls_contractseq,:ls_addition_itemcod,
							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
							 :gs_user_id,sysdate, :is_data[4]);
							 
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
						ii_rc = -1						
						RollBack;
						Return 
					End If									 

				End IF
					
			CASE ls_callforward_code[2]     //착신전환비밀번호인증일때

				If ls_callforwardno_new <> "" Then    //변경후 착신전환번호가 있을 경우

					//callforwarding_info_seq 가져 오기
					Select seq_callforwarding_info.nextval
					  Into :ll_callforward_seq_new
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
					Values ( :ll_callforward_seq_new, :ldc_svcorderno,:ls_contractseq,:ls_addition_itemcod,
							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
							 :gs_user_id,sysdate, :is_data[4] );

					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
						ii_rc = -1						
						RollBack;
						Return 
					End If									 

				End IF						
				
			CASE ls_callforward_code[3]     //착신전환발신번호인증일때
				
				ll_callingnum_cnt = fi_cut_string(ls_callingnum_all, ";" , ls_callingnum[])

				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
					//callforwarding_info_seq 가져 오기
					Select seq_callforwarding_info.nextval
					  Into :ll_callforward_seq_new
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
					Values ( :ll_callforward_seq_new, :ldc_svcorderno,:ls_contractseq,:ls_addition_itemcod,
							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
							 :gs_user_id,sysdate, :is_data[4] );

					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
						ii_rc = -1						
						RollBack;
						Return 
					End If									 
					
					//발신가능전화번호 insert

					For i = 1 To ll_callingnum_cnt	
						Insert Into callforwarding_auth
						( seq,callingnum,
						  crt_user,crtdt, pgm_id ) 
						Values ( :ll_callforward_seq_new,:ls_callingnum[i],
							 :gs_user_id,sysdate, :is_data[4] );

						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
							ii_rc = -1						
							RollBack;
							Return 
						End If									 
							 
					Next
				End IF						
				
		END CHOOSE
		//khpark add 2005-07-12 start							
			
    	f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey_1 + "]가  추가되었습니다.")
		
		commit;
		
	Case "b1w_validkey_update_popup_3_1_v20%ue_save"			//인증Key 관리모듈포함 version 2.0
		idw_data[1].accepttext()
		
		ls_validkey  = fs_snvl(idw_data[1].object.validkey[1]  , '')
      ls_h323id    = fs_snvl(idw_data[1].object.validitem3[1], '')
	   ls_priceplan = fs_snvl(idw_data[1].object.priceplan[1] , '')
		
		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
		If IsNull(ls_customerid) Then ls_customerid = ""		
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
		If IsNull(ls_partner) Then ls_partner = '0'		
		ls_orderno = String(idw_data[1].object.orderno[1])   
		If IsNull(ls_orderno) Then ls_orderno = '0'

		Update validkeymst
		   set status =:ls_validkeymst_status[3],  sale_flag = '0', activedt = null,
			   customerid = '',  orderno = null,   contractseq = null,
			   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[2] 
		 Where validkey = :ls_validkey
		   And contractseq = :ls_contractseq;
		  
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
			Return 
		End If
		
		Insert Into validkeymst_log
		   (validkey, seq, status, actdt, customerid, 
			contractseq, partner, crt_user, crtdt, pgm_id)
		 Select :ls_validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[3], to_date(:is_data[1],'yyyy-mm-dd'), :ls_customerid,
				  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[2] 
		  From validkeymst where validkey = :ls_validkey;
				  
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table")				
			Return 
		End If
		
		If ls_h323id <> '' Then
			Update validkeymst
				set status =:ls_validkeymst_status[3],  sale_flag = '0', activedt = null,
					customerid = '',  orderno = null,   contractseq = null,
					updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[2] 
			 Where validkey = :ls_h323id
				And contractseq = :ls_contractseq;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table :h323id")					
				Return 
			End If
			
			Insert Into validkeymst_log
				(validkey, seq, status, actdt, customerid, 
				contractseq, partner, crt_user, crtdt, pgm_id)
			 Select :ls_h323id, seq_validkeymstlog.nextval, :ls_validkeymst_status[3], to_date(:is_data[1],'yyyy-mm-dd'), :ls_customerid,
					  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[2] 
			  From validkeymst 
			 where validkey    = :ls_h323id
			   And contractseq = :ls_contractseq;
					  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table :h323id")				
				Return 
			End If
	
		End IF
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr_v20.uf_prc_db_02()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose
ii_rc = 0
////"b1w_validkey_update_popup_1_1_v20%ue_save"
//String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf, &
//       ls_crt_kind_code[], ls_validkey_type, ls_validkey_typenm, ls_crt_kind, ls_prefix, &
//		 ls_type, ls_used_level, ls_priceplan, ls_validitem_yn, ls_validkey_type_h, ls_crt_kind_h, &
//		 ls_prefix_h, ls_auth_method_h, ls_type_h, ls_used_level_h, ls_auto_validkey, ls_validkey_loc, &
//		 ls_n_auth_method, ls_auto_validitem, ls_n_validitem3, ls_n_validitem2, ls_n_validitem1, &
//		 ls_n_langtype, ls_validkey_1, ls_n_validitem3_1 
//Long   ll_cnt, li_return, ll_length_h, ll_length, li_random_length, ll_boss_check
////"b1w_validkey_update_popup_2_2%ue_save"
//String ls_gkid, ls_auth_method, ls_cusnm, ls_ip_address, ls_h323id, ls_ref_desc, ls_act_status
//String ls_customernm, ls_svccod, ls_sys_langtype, ls_langtype, ls_svctype
//decimal ldc_svcorderno
////공통 
//String ls_sysdt, ls_cid, ls_temp, ls_validkeyloc, ls_h323id_old, ls_validkey_type_old, ls_crt_kind_old
//
////Ver 2.0 추가
//String ls_customerid, ls_contractseq, ls_partner, ls_orderno, ls_validkeymst_status[], ls_validkey_msg
//String ls_activedt  //2005.04.18 juede [fromdt >= activedt ] 
//String ls_addition_code, ls_addition_itemcod,ls_callforward_code[],ls_password_old,ls_password_new
//String ls_callingnum_all, ls_callingnum[],ls_callforwardno_old,  ls_callforwardno_new, ls_call_todt
//Date  ld_addition_item_todt
//Long ll_callforward_seq_old, ll_callforward_seq_new,ll_callingnum_cnt
//Int i
//
////2009.05.27 UBS 2차 추가
//LONG		ll_new_orderno,	ll_return,			ll_validkey_chk
//STRING	ls_validkey_old,	ls_fromdt_old,		ls_errmsg,		ls_sysdate
//
//ii_rc = -1
////인증Key 관리모듈포함 version 2.0 khpark modify 2004.06.02.
////validkeymst 상태(is_caller 모두 사용함으로 상단에 코팅)
//ls_ref_desc = ""
//ls_temp = fs_get_control("B1", "P400", ls_ref_desc)   
//If ls_temp = "" Then Return 
//fi_cut_string(ls_temp, ";" , ls_validkeymst_status[])   //인증Key관리상태(생성;개통;해지)
//
////인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
//ls_ref_desc = ""
//ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , ls_crt_kind_code[])		
//
////부가서비스유형코드(착신전환부가서비스코드)
//ls_ref_desc = ""
//ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";", ls_callforward_code[])		
//
//Choose Case is_caller
//	Case "b1w_validkey_update_popup_1_1_v20%ue_save"          //인증Key 관리모듈포함 version 2.0
////		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_1_v20%ue_save"
////		lu_dbmgr.is_title = Title
////		lu_dbmgr.idw_data[1] = dw_detail
////		lu_dbmgr.is_data[1]  = is_fromdt
////		lu_dbmgr.is_data[2]  = is_validkey						//변경전..
////		lu_dbmgr.is_data[3]  = is_pgm_id
////		lu_dbmgr.is_data[4]  = is_inout_svctype
////		//khpark add 2005-07-11
////		lu_dbmgr.is_data[5]  = is_addition_code      	 //착신전환부가서비스코드
////		lu_dbmgr.is_data[6]  = is_addition_itemcod    	 //착신전환부가서비스품목
////		lu_dbmgr.il_data[1]  = il_callforward_seq        //착신전환정보 seq
////		lu_dbmgr.id_data[1]  = id_addition_item_todt  	 //착신전환부가서비스품목 todt		
//	
//		idw_data[1].accepttext()
//		
//		ls_addition_code       = is_data[5]
//		ls_addition_itemcod    = is_data[6]
//		ll_callforward_seq_old = il_data[1]
//		ld_addition_item_todt  = id_data[1]
//    	If IsNull(ls_addition_code)    Then ls_addition_code = ""
//		If IsNull(ls_addition_itemcod) Then ls_addition_itemcod = ""
//		
//		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
//		If ls_sys_langtype = "" Then Return
//		
//        If is_data[4] = 'Y' Then
//			 ls_validkey_msg = 'Route-No.'
//		Else
//			 ls_validkey_msg = '인증KEY'
//		End IF
//	
//      ls_validkey     = fs_snvl(idw_data[1].object.new_validkey[1], '') //NEW
//		ls_fromdt_1     = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
//		ls_fromdt       = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
//		ls_new_todt     = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
//		ls_new_todt_cf  = ls_new_todt
//		ls_vpassword    = fs_snvl(idw_data[1].object.new_vpassword[1]   , '')
//		ls_langtype     = idw_data[1].object.new_langtype[1]
//		ls_svctype      = idw_data[1].object.svctype[1]
//		ls_cid          = idw_data[1].object.cid[1]
//		ls_validkey_loc = fs_snvl(idw_data[1].object.new_validkey_loc[1], '')
//		
//		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
//		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
//		If IsNull(ls_activedt) Then ls_activedt = ""
//		//2005.04.18 juede  fromdt >= activedt 로 조건변경------end
//				
//		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
//		If IsNull(ls_fromdt)   Then ls_fromdt = ""
//		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
//			ls_new_todt = ""
//			ls_new_todt_cf = '99991231'
//		End if
//		If IsNull(ls_langtype) or ls_langtype = "" Then 
//			ls_langtype = ls_sys_langtype
//		End IF
//		If IsNull(ls_cid) Then ls_cid = ""
//	
//		//인증키 관리하지 않는 서비스는 validinfo에 데이터 넣기 위해서 검색함! 2009.07.09 CJH
//		SELECT COUNT(*) 
//		INTO :ll_validkey_chk
//		FROM   VALIDKEYMST
//		WHERE  VALIDKEY = :ls_validkey;
//		
//		ls_svccod      = fs_snvl(idw_data[1].object.svccod[1]         , '')
//		ls_ip_address  = fs_snvl(idw_data[1].object.ip_address[1]     , '')
//		ls_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')
//    	ls_h323id      = fs_snvl(idw_data[1].object.h323id[1]         , '')
//		ls_customerid  = fs_snvl(idw_data[1].object.customerid[1]     , '')              // ver2.0 khpark add
//		ls_contractseq = String(idw_data[1].object.contractseq[1])   
//		ls_partner     = fs_snvl(idw_data[1].object.reg_partner[1]    , '')
//		ls_orderno     = String(idw_data[1].object.orderno[1])   
//		//2009.05.27 ubs 2차 개발시 추가.
//      ls_validkey_old = fs_snvl(idw_data[1].object.validkey[1], '') //old
//		ls_fromdt_old   = string(idw_data[1].object.fromdt[1],'yyyymmdd')		
//
//		If IsNull(ls_contractseq) Then ls_contractseq = '0'
//		If IsNull(ls_orderno) Then ls_orderno = '0'
//		
//	   //변경전...  
//		ls_priceplan         = fs_snvl(idw_data[1].object.priceplan[1]    , '')
//		ls_h323id_old        = fs_snvl(idw_data[1].object.validitem3[1]   , '')
////		ls_validkey_type_old = fs_snvl(idw_data[1].object.validkey_type[1], '')
//		
////		SELECT CRT_KIND
////		  INTO :ls_crt_kind_old
////        FROM VALIDKEY_TYPE
////       WHERE VALIDKEY_TYPE = :ls_validkey_type_old;
////		
////		If sqlca.sqlcode < 0 Then
////			f_msg_sql_err(is_title, is_caller +"Select VALIDKEY_TYPE(변경전 : CRT_KIND)")				
////			Return 
////		End If
////
//		If ls_fromdt = "" Then
//			f_msg_usr_err(200, is_title, "적용시작일")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_fromdt")
//			Return
//		End If
//
//		// 날짜 체크   2005.04.18 juede comment 처리
//		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
//		//If ls_fromdt <= ls_sysdt Then
//		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜보다 커야합니다.")
//		//	idw_data[1].SetFocus()
//		//	idw_data[1].SetColumn("new_fromdt")
//		//	Return
//		//End If		
//		
//		
//		//2013.01.17 SUNZU KIM ADD
//		//적용시작일은 OPEN할때, defalut로 오늘+1일 후가 뜨고, 당일 개통이 있으므로,
//		//오늘 날짜나, 혹은 그 이후로, 입력한 대로, SVCORDER.REQUESTDT에 반영되도록 수정함.
//		//이에, 위의 날짜 체크를 막은 이유는 모르겠으나, 오늘 날짜 이전의 데이타가 들어가지 않도록
//		//로직 추가함. 
//		ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
//		If ls_fromdt < ls_sysdt Then
//			f_msg_usr_err(210, is_Title, "적용시작일은 과거일자로 입력할 수 없습니다.!!")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_fromdt")
//			Return
//		End If	
//			
//		
//		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---start
//		If ls_fromdt < ls_activedt Then
//			f_msg_usr_err(210, is_Title, "적용시작일은 개통일자 이상이여야 합니다.")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_fromdt")
//			Return
//		End If				
//		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---end		
//		
//	/* ----- */
//		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
//		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
//		
//		If li_return = -1 Then
//		    return
//		End IF
//
//     	ls_validkey_type = Trim(idw_data[1].object.new_validkey_type[1])
//		ls_priceplan     = Trim(idw_data[1].object.priceplan[1])
//		
//		//인증KEY의 validkey_type에 따른 처리
//		li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type,ls_validkey_typenm,ls_crt_kind,ls_prefix,ll_length,ls_auth_method,ls_type,ls_used_level) 
//		
//		If li_return = -1 Then
//			 return
//		End IF
//		
//		Choose Case ls_crt_kind		
//			Case ls_crt_kind_code[1]   //수동Manual
//				
//			Case ls_crt_kind_code[2]   //AutoRandom
//						
//				ls_auto_validkey = ""
//				
//				//validkey 생성에 따른 prefix 및 길이 Check
//				IF isnull(ls_prefix) or ls_prefix = "" Then
//					ls_prefix = ""
//					li_random_length = ll_length
//				Else
//					li_random_length = ll_length - LEN(ls_prefix)
//				END IF
//						
//				DO  //validkey random 생성
//					ls_auto_validkey = ls_prefix + fs_get_randomize_v20(li_random_length)
//	
//					select count(validkey)
//					  into :ll_cnt
//					  from validinfo
//					 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//							 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//							 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//						and validkey = :ls_auto_validkey
//						and svccod   = :ls_svccod;	
//						
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, " Select Error(validinfo check)")
//						RollBack;
//						ii_rc = -1				
//						Return 
//					End If		
//				
//				LOOP WHILE(ll_cnt>0)		
//				
//				idw_data[1].object.new_validkey[1] = ls_auto_validkey
//	
//			Case ls_crt_kind_code[3]   //AutoSeq
//				
//				ls_auto_validkey = ""
//				//Order Sequence
//				Select to_char(seq_auto_validkey.nextval)
//				  Into :ls_auto_validkey
//				  From dual;
//				
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_title, " Sequence Error(seq_auto_validkey)")
//					RollBack;
//					ii_rc = -1				
//					Return 
//				End If				
//
//				idw_data[1].object.new_validkey[1] = ls_auto_validkey
//				
//			Case ls_crt_kind_code[4]   //자원관리Resource
//				
//			Case ls_crt_kind_code[5]   //고객대체				
//				
//		End Choose                
//		
//		If ls_auto_validkey <> '' Then
//			ls_validkey_1 = ls_auto_validkey		//AUTO NEW
//		Else
//			ls_validkey_1 = ls_validkey  			//NEW
//		End If
//		
//		IF ll_validkey_chk <= 0 THEN				//2009.07.09 CJH	인증키 관리하지 않는 서비스 이면
//			//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
//			ll_cnt = 0
//			select count(validkey)
//			  into :ll_cnt
//			 from validinfo
//			where validkey = :ls_validkey
//			  and to_char(fromdt,'yyyymmdd') = :ls_fromdt 
//			  and svccod = :ls_svccod;
//			//and svctype = :ls_svctype;   ohj 05.05.03
//					  
//			If sqlca.sqlcode < 0 Then
//				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
//				Return 
//			End If
//		
//			If ll_cnt > 0 Then
//				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
//				return 
//			End if
//		END IF
//		
//		//인증KEY 중복 check  
//		//적용시작일과 적용종료일의 중복일자를 막는다. 
//		select count(validkey)
//		  into :ll_cnt
//		  from validinfo
//		 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//				 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//				 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//			and validkey = :ls_validkey_1
//			and svccod   = :ls_svccod;
//				  
//		If sqlca.sqlcode < 0 Then
//			f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
//			Return 
//		End If
//		
//		If ll_cnt > 0 Then
//			f_msg_usr_err(9000, is_title, ls_validkey_msg +"[" + ls_validkey_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_validkey")
//			ii_rc = -3					
//			return 
//		End if
//
//		ls_n_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')						 
//		ls_n_validitem3  = fs_snvl(idw_data[1].object.h323id[1]         , '')  //new
//		
//		IF ls_validitem_yn = 'Y' Then	
//			
//			Choose Case ls_crt_kind_h	
//				Case ls_crt_kind_code[1]   //수동Manual
//					
//				Case ls_crt_kind_code[2]   //AutoRandom
//
//					ls_auto_validitem = ""							
//					//validitem(H323id) 생성에 따른 prefix 및 길이 Check
//					IF isnull(ls_prefix_h) or ls_prefix_h = "" Then
//						ls_prefix_h= ""
//						li_random_length = ll_length_h
//					Else
//						li_random_length = ll_length_h - LEN(ls_prefix_h)
//					END IF
//							
//					DO  //validitem random 생성
//						ls_auto_validitem = ls_prefix_h + fs_get_randomize_v20(li_random_length)
//
//						ll_cnt = 0
//						IF mid(ls_n_auth_method,7,4) = "H323" Then
//		
//							select count(validkey)
//							  into :ll_cnt
//							  from validinfo
//							 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//									( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//									:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//								and validitem3 = :ls_auto_validitem
//								and svccod     = :ls_svccod;									 
//								
//							If sqlca.sqlcode < 0 Then
//								f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
//								Return 
//							End If
//						End IF  
//						 
//					LOOP WHILE(ll_cnt > 0)		
//					
//					idw_data[1].object.h323id[1] = ls_auto_validitem
//
//				Case ls_crt_kind_code[3]   //AutoSeq							
//					
//					ls_auto_validitem = ""							
//					//Order Sequence
//					 Select to_char(seq_auto_validitem.nextval)
//					  Into :ls_auto_validitem
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, " Sequence Error(seq_auto_validitem)")
//						RollBack;
//						ii_rc = -1				
//						Return 
//					End If				
//
//					idw_data[1].object.h323id[1] = ls_auto_validitem
//					
//				Case ls_crt_kind_code[4]   //자원관리Resource
//					
//				Case ls_crt_kind_code[5]   //고객대체
//				
//			End Choose
//		End IF	 
//		
//		ls_n_langtype    = idw_data[1].object.new_langtype[1]
//		ls_n_validitem2  = idw_data[1].object.ip_address[1]
////			ls_n_validitem3  = idw_data[1].object.h323id[1]
//		ls_n_validitem1  = idw_data[1].object.cid[1]
//		
//		If ls_auto_validitem <> '' Then
//			ls_n_validitem3_1 = ls_auto_validitem
//		Else
//			ls_n_validitem3_1 = ls_n_validitem3
//		End If
//		
//		//인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
//		ll_cnt = 0
//		IF mid(ls_n_auth_method,7,4) = "H323" Then
//
//			select count(validkey)
//			  into :ll_cnt
//			  from validinfo
//			  where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//					( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//					:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//					  and validitem3 = :ls_n_validitem3_1
//				and svccod = :ls_svccod;
//				
//			If sqlca.sqlcode < 0 Then
//				f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
//				Return 
//			End If
//				
//			If ll_cnt > 0 Then
//				f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("h323id")
//				ii_rc = -3					
//				return 
//			End if
//		End IF  
//	/* ----- */
//
//		//인증KEY 인증KeyType이 자원관리인 경우만 처리		
////		If ls_crt_kind_old = ls_crt_kind_code[4]  Then  		
//			
//			//VALIDKEYMST UPDATE  변경전 인증키 상태변경
////2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.
//			Update validkeymst
//				set status      = :ls_validkeymst_status[3]
//				  , sale_flag   = '0'
//				  , activedt    = null
//				  , customerid  = null
//				  , orderno     = null
//				  , contractseq = null
//				  , updt_user   = :gs_user_id
//				  , updtdt      = sysdate
//				  , pgm_id      = :is_data[3] 
//			 Where validkey    = :is_data[2]
//				and contractseq = :ls_contractseq ;
//			  
//			 If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table(old)")				
//				Return 
//			 End If
////2009.05.27------------------------------------------------------END			
//			 
//			//VALIDKEYMST_LOG INSERT   변경전 인증키 상태변경 로그남기기
////2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.			
//			 Insert Into validkeymst_log
//						  ( validkey
//						  , seq
//						  , status
//						  , actdt
//						  , customerid
//						  , contractseq
//						  , partner
//						  , crt_user, crtdt, pgm_id )
//					Select validkey
//						  , seq_validkeymstlog.nextval
//						  , :ls_validkeymst_status[3]
//						  , to_date(:ls_fromdt,'yyyy-mm-dd')
//						  , :ls_customerid
//						  , :ls_contractseq
//						  , :ls_partner
//						  , :gs_user_id, sysdate, :is_data[3] 
//					 From validkeymst
//					Where validkey    = :is_data[2]
//					  and contractseq = :ls_contractseq ;
//			 
//			 If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table(old)")				
//				Return 
//			 End If
////2009.05.27------------------------------------------------------END			
//		
//		//인증KEY 인증KeyType이 자원관리인 경우만 처리	
////2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.					
//		If ls_crt_kind = ls_crt_kind_code[4]  Then 
//			
//			//변경된 인증key 상태 '개통'으로 update
//			Update validkeymst
//				set status      = :ls_validkeymst_status[2]
//				  , sale_flag   = '1'
//				  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
//				  , customerid  = :ls_customerid
//				  , orderno     = :ls_orderno
//				  , contractseq = :ls_contractseq 
//				  , updt_user   = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
//			 Where validkey    = :ls_validkey_1 
//			   AND validkey_type = :ls_validkey_type  ;
//			  
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table(new)")					
//				Return 
//			End If
//			
//			//변경된 인증key 로그 남기기 '개통'
//			Insert Into validkeymst_log
//						 ( validkey
//						 , seq
//						 , status
//						 , actdt
//						 , customerid
//						 , contractseq
//						 , partner
//						 , crt_user, crtdt, pgm_id )
//				  Select validkey
//						 , seq_validkeymstlog.nextval
//						 , :ls_validkeymst_status[2]
//						 , to_date(:ls_fromdt,'yyyy-mm-dd')
//						 , :ls_customerid
//						 , :ls_contractseq
//						 , :ls_partner
//						 , :gs_user_id, sysdate, :is_data[3]
//					 From validkeymst 
//					Where validkey      = :ls_validkey_1
//					  AND validkey_type = :ls_validkey_type  ;
//					  
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table(new)")				
//				Return 
//			End If
//		End If
////2009.05.27------------------------------------------------------END			
//		
//		//h323id 관리
////2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.							
//		If ls_h323id <> ls_h323id_old Then
//			
//			//validitem3(H323ID) KeyType이 자원관리인 경우만 처리   
////					If ls_crt_kind_h = ls_crt_kind_code[4]  Then  
//				If ls_h323id_old <> '' Then
//					//변경전 h323id'해지'
//					Update validkeymst
//						set status      = :ls_validkeymst_status[3]
//						  , sale_flag   = '0'
//						  , activedt    = null
//						  , customerid  = null
//						  , orderno     = null
//						  , contractseq = null
//						  , updt_user   = :gs_user_id
//						  , updtdt      = sysdate
//						  , pgm_id      = :is_data[3] 	
//					 Where validkey    = :ls_h323id_old
//					  and contractseq  = :ls_contractseq  ;
//											 
//					  
//					If SQLCA.SQLCode <> 0 Then
//						RollBack;	
//						f_msg_sql_err(is_title, is_caller + " Update validkeymst Table (h323id: old")					
//						Return 
//					End If
//						
//					Insert Into validkeymst_log
//								 ( validkey, seq, status, actdt, customerid
//								 , contractseq, partner, crt_user, crtdt, pgm_id )
//						  select :ls_h323id_old, seq_validkeymstlog.nextval, :ls_validkeymst_status[3],
//									 to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
//									:ls_partner, :gs_user_id, sysdate, :is_data[4] 
//							  from validkeymst
//							 Where validkey     = :ls_h323id_old
//							 and contractseq  = :ls_contractseq  ;									  
//									
//					If SQLCA.SQLCode <> 0 Then
//						RollBack;	
//						f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: h323id old")				
//						Return 
//					End If
//				End If
//				
//			If ls_crt_kind_h = ls_crt_kind_code[4]  Then  										
//		
//				If ls_n_validitem3_1 <> '' Then
//					//변경후 h323id '개통'
//					Update validkeymst
//						set status      = :ls_validkeymst_status[2]
//						  , sale_flag   = '1'
//						  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
//						  , customerid  = :ls_customerid
//						  , orderno     = :ls_orderno
//						  , contractseq = :ls_contractseq 
//						  , updt_user   = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
//					 Where validkey    = :ls_n_validitem3_1   
//						and validkey_type = :ls_validkey_type_h;													 
//					  
//					If SQLCA.SQLCode <> 0 Then
//						RollBack;	
//						f_msg_sql_err(is_title, is_caller + " Update validkeymst Table (h323id: new")					
//						Return 
//					End If
//						
//					Insert Into validkeymst_log
//								 ( validkey, seq, status, actdt, customerid
//								 , contractseq, partner, crt_user, crtdt, pgm_id )
//						  values 
//								 (:ls_n_validitem3_1, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
//									 to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
//									:ls_partner, :gs_user_id, sysdate, :is_data[4] );			
//									
//					If SQLCA.SQLCode <> 0 Then
//						RollBack;	
//						f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: h323id new")				
//						Return 
//					End If
//				End If
//			End If
//		End If
////2009.05.27------------------------------------------------------END			
//
//		
////			End IF
//		//2010.05.19 추가함. 인증키 변경할 때 인증서비스에 해당하는놈들만 인증받도록...나머지는 그냥 처리하도록
//		IF ll_validkey_chk > 0 THEN
//			
//			SELECT COUNT(*) 
//			INTO :ll_boss_check
//			FROM   SYSCOD2T
//			WHERE  GRCODE = 'BOSS03'
//	      AND    CODE = :ls_svccod;
//			
//			IF ll_boss_check <= 0 THEN
//				ll_validkey_chk = 0
//			END IF
//		END IF
//		
////2009.05.27 UBS 2차 개발시 추가됨. SVCORDER 데이터 입력
//		IF ll_validkey_chk > 0 THEN				//인증키 관리하는 서비스만 인증하도록! 2009.07.09 CJH
//			//Get SVCORDER Sequence
//			SELECT SEQ_ORDERNO.NEXTVAL 
//			INTO :ll_new_orderno
//			FROM   DUAL;
//			
//			IF SQLCA.SQLCode <> 0 THEN
//				ROLLBACK;	
//				f_msg_sql_err(is_title, is_caller + " SVCORDER SEQUENCE ERROR")
//				RETURN 
//			END IF				
//			//Insert SVCORDER. STATUS=80 ( 번호변경신청 ) SYSCOD2T : B300 
//			INSERT INTO SVCORDER ( ORDERNO,				CUSTOMERID,			ORDERDT,			REQUESTDT,
//										  STATUS,				SVCCOD,				PRICEPLAN,		PRICEMODEL,
//										  PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
//										  MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
//										  CRT_USER,	CRTDT,	PGM_ID )
//			SELECT 	:ll_new_orderno,	CUSTOMERID,			TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),	SYSDATE,
//						'80',					SVCCOD,				PRICEPLAN,		PRICEMODEL,
//						PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
//						MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
//						:gs_user_id,		SYSDATE,				:is_data[3]
//			FROM		SVCORDER
//			WHERE    ORDERNO = TO_NUMBER(:ls_orderno);
//			
//			IF SQLCA.SQLCode <> 0 THEN
//				ROLLBACK;	
//				f_msg_sql_err(is_title, is_caller + " INSERT SVCORDER Table")
//				RETURN 
//			END IF
//			
//			//Insert VALIDINFO_CHANGE . 변경전 인증키
//			INSERT INTO VALIDINFO_CHANGE 
//			       ( VALIDKEY,		   FROMDT,			TODT,
//                  STATUS,			   USE_YN,			VPASSWORD,
//                  VALIDITEM,		   GKID,				CUSTOMERID,
//                  SVCCOD,			   SVCTYPE,			PRICEPLAN,
//                  ORDERNO,		      CONTRACTSEQ,	VALIDITEM1,
//                  VALIDITEM2,	      VALIDITEM3,		AUTH_METHOD,
//                  VALIDKEY_LOC,	   LANGTYPE,		CRT_USER,
//                  CRTDT,			   PGM_ID,			UPDT_USER,
//                  UPDTDT,			   CHANGE_TYPE,	TIMESTAMP )
//			SELECT	VALIDKEY,			FROMDT,			TO_DATE(:ls_fromdt, 'YYYYMMDD'),
//						'99',					'N',				VPASSWORD,
//						VALIDITEM,			GKID,				CUSTOMERID,
//						SVCCOD,				SVCTYPE,			PRICEPLAN,
//						:ll_new_orderno,	CONTRACTSEQ,	VALIDITEM1,
//						VALIDITEM2,			VALIDITEM3,		AUTH_METHOD,
//						VALIDKEY_LOC,		LANGTYPE,		:gs_user_id,
//						SYSDATE,				:is_data[3],	:gs_user_id,
//						SYSDATE,				'0',				''
//			FROM		VALIDINFO
//			WHERE    VALIDKEY = :is_data[2]
//			AND      TO_CHAR(FROMDT, 'YYYYMMDD') = :ls_fromdt_old
//			AND      SVCCOD = :ls_svccod;		
//			
//			IF SQLCA.SQLCode <> 0 THEN
//				ROLLBACK;
//				MessageBox("", SQLCA.SQLERRTEXT )
//				f_msg_sql_err(is_title, is_caller + " INSERT VALIDINFO_CHANGE(OLD) Table")
//				RETURN 
//			END IF		
//	
//			//Insert VALIDINFO_CHANGE . 변경후 인증키
//			INSERT INTO VALIDINFO_CHANGE ( VALIDKEY,		FROMDT,			TODT,
//													 STATUS,			USE_YN,			VPASSWORD,
//													 VALIDITEM,		GKID,				CUSTOMERID,
//													 SVCCOD,			SVCTYPE,			PRICEPLAN,
//													 ORDERNO,		CONTRACTSEQ,	VALIDITEM1,
//													 VALIDITEM2,	VALIDITEM3,		AUTH_METHOD,
//													 VALIDKEY_LOC,	LANGTYPE,		CRT_USER,
//													 CRTDT,			PGM_ID,			UPDT_USER,
//													 UPDTDT,			CHANGE_TYPE,	TIMESTAMP )
//			SELECT	:ls_validkey_1,	TO_DATE(:ls_fromdt, 'YYYYMMDD'),	TO_DATE(:ls_new_todt, 'YYYYMMDD'),
//						STATUS,				'Y',										:ls_vpassword,
//						VALIDITEM,			GKID,										CUSTOMERID,
//						SVCCOD,				SVCTYPE,									PRICEPLAN,
//						:ll_new_orderno,	CONTRACTSEQ,							:ls_cid,
//						:ls_ip_address,	:ls_n_validitem3_1,					:ls_auth_method,
//						:ls_validkey_loc,	:ls_langtype,							:gs_user_id,
//						SYSDATE,				:is_data[3],							:gs_user_id,
//						SYSDATE,				'N',										''
//			FROM     VALIDINFO
//			WHERE    VALIDKEY = :is_data[2]
//			AND  		TO_CHAR(FROMDT, 'YYYYMMDD') = :is_data[1]
//			AND 		SVCCOD = :ls_svccod;
//	
//			IF SQLCA.SQLCode <> 0 THEN
//				ROLLBACK;	
//				f_msg_sql_err(is_title, is_caller + " INSERT VALIDINFO_CHANGE(NEW) Table")
//				RETURN 
//			END IF	
//			
//			//2009.06.07 추가. SIID 오더번호 업데이트!!!
//			UPDATE SIID
//			SET    ORDERNO = :ll_new_orderno,
//					 UPDTDT = SYSDATE
//			WHERE  CONTRACTSEQ = :ls_contractseq;
//			
//			IF SQLCA.SQLCODE < 0 THEN		//For Programer
//				MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//				ROLLBACK;				
//				RETURN 
//			END IF		
//			
//			//프로비져닝 프로시저 실패해도 롤백시키지 않기 위해서!
//			commit;
//			
//			SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO :ls_sysdate
//			FROM   DUAL;
//			
//			IF ls_sysdate = ls_fromdt THEN			//적용시작일이 현재일 이어야만 연동처리
//				//프로비져닝 프로시저 호출
//				ls_errmsg = space(1000)
//				SQLCA.UBS_PROVISIONNING(ll_new_orderno,		'TEL322',		0,					&
//												ls_validkey_1,			gs_shopid,		is_data[3],		&
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
//			END IF
//		ELSE		//관리하지 않는놈은 그냥 오더만 생성! 완료로...
//			//Get SVCORDER Sequence
//			SELECT SEQ_ORDERNO.NEXTVAL INTO :ll_new_orderno
//			FROM   DUAL;
//			
//			IF SQLCA.SQLCode <> 0 THEN
//				ROLLBACK;	
//				f_msg_sql_err(is_title, is_caller + " SVCORDER SEQUENCE ERROR")
//				RETURN  
//			END IF				
//			//Insert SVCORDER. STATUS=85 ( 번호변경완료 ) SYSCOD2T : B300 
//			//2013.01.17 SUNZU KIM MODIFY
//			//수정내용: 화면에서 사용자가 입력한 적용일자로 저장되도록.
//			//        : REQUESTDT컬럼값에 sysdate--> TO_DATE(:ls_fromdt, 'YYYYMMDD')로 수정.      
//			INSERT INTO SVCORDER ( ORDERNO,				CUSTOMERID,			ORDERDT,			REQUESTDT,
//										  STATUS,				SVCCOD,				PRICEPLAN,		PRICEMODEL,
//										  PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
//										  MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
//										  CRT_USER,	CRTDT,	PGM_ID )
//			SELECT 	:ll_new_orderno,	CUSTOMERID,			TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),	
//			         /*SYSDATE, */     TO_DATE(:ls_fromdt, 'YYYYMMDD'),
//						'85',					SVCCOD,				PRICEPLAN,		PRICEMODEL,
//						PRMTYPE,				REG_PREFIXNO,		REG_PARTNER,	SALE_PARTNER,
//						MAINTAIN_PARTNER,	SETTLE_PARTNER,	PARTNER,			REF_CONTRACTSEQ,
//						:gs_user_id,		SYSDATE,				:is_data[3]
//			FROM		SVCORDER
//			WHERE    ORDERNO = TO_NUMBER(:ls_orderno);
//			
//			IF SQLCA.SQLCode <> 0 THEN
//				ROLLBACK;	
//				f_msg_sql_err(is_title, is_caller + " INSERT SVCORDER Table")
//				RETURN 
//			END IF
//			
//		END IF			
////2009.05.27------------------------------------------END
//
////2009.05.27 UBS 2차 개발시 제외됨. VALIDINFO_CHANGE 테이블 사용.								
//		IF ll_validkey_chk <= 0 THEN				//인증키 관리하지 않는 서비스만 VALIDINFO로 들어가도록 2009.07.09 CJH
//		  //변경전 인증키 미사용으로 update
//			Update validinfo
//				Set use_yn    = 'N'
//				  , status    = '99'  //20080825 hcjung
//				  , todt      = to_date(:ls_fromdt,'yyyy-mm-dd')
//				  , updt_user = :gs_user_id
//				  , updtdt    = sysdate
//				  , pgm_id    = :is_data[3]
//			 Where validkey  = :is_data[2]
//				And to_char(fromdt,'yyyymmdd') = :is_data[1] 
//				and svccod    = :ls_svccod;
//				//and svctype = :ls_svctype;
//			
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
//				Return 
//			End If
//
//			//Insert  변경후 인증키 insert
//			insert into validinfo
//						 ( validkey      , fromdt     , todt
//						 , status        , use_yn     , vpassword
//						 , validitem     , gkid       , customerid
//						 , svccod        , svctype    , priceplan
//						 , orderno       , contractseq, validitem1
//						 , validitem2    , validitem3 , auth_method
//						 , validkey_loc  , langtype 
//						 , crt_user      , crtdt  	   , pgm_id      
//						 , updt_user     , updtdt                             )
//				  select :ls_validkey_1, to_date(:ls_fromdt,'yyyy-mm-dd')
//						 , to_date(:ls_new_todt,'yyyy-mm-dd')
//						 , :ls_validkeymst_status[2], 'Y'   , :ls_vpassword
//						 , validitem     , gkid, customerid
//						 ,	svccod        , svctype
//						 , priceplan     , orderno
//						 , contractseq   , :ls_cid, :ls_ip_address
//						 , :ls_n_validitem3_1 , :ls_auth_method,	:ls_validkey_loc
//						 , :ls_langtype  
//						 , :gs_user_id   , sysdate, :is_data[3]
//						 , :gs_user_id   , sysdate
//					 from validinfo
//					where validkey  = :is_data[2]
//					  and to_char(fromdt,'yyyymmdd') = :is_data[1] 
//					  and svccod    = :ls_svccod;
//					//and svctype = :ls_svctype;
//
//			//저장 실패 
//			If SQLCA.SQLCode < 0 Then
//				RollBack;
//				f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
//				Return 
//			End If	
//		END IF
////2009.05.27------------------------------------------END
//
////2009.05.27 UBS 2차 개발시 제외됨. 나중을 위하여 주석처리					
////		ls_callforwardno_old = idw_data[1].object.callforwardno[1]
////		ls_callforwardno_new = idw_data[1].object.new_callforwardno[1]
////    ls_password_new =  idw_data[1].object.new_password[1]
////    ls_callingnum_all = idw_data[1].object.callingnum[1]
////		ls_call_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')	//변경후 적용시작일 -1 일 
////		If IsNull(ls_callforwardno_old) Then ls_callforwardno_old = ""
////		If IsNull(ls_callforwardno_new) Then ls_callforwardno_new = ""
////		If IsNull(ls_password_new) Then ls_password_new = ""
////		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""
////		
////	   //khpark add 2005-07-11 start(착신전환부가서비스)
////		CHOOSE CASE ls_addition_code  
////			CASE ls_callforward_code[1]   //착신전환일반유형일때 
////
////				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
////					
////					Update callforwarding_info
////					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
////						  updtdt = sysdate,
////						  pgm_id = :is_data[3]
////					where seq = :ll_callforward_seq_old;						
////				End If
////				
////				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
////					
////					//callforwarding_info_seq 가져 오기
////					Select seq_callforwarding_info.nextval
////					  Into :ll_callforward_seq_new
////					  From dual;
////					
////					If SQLCA.SQLCode < 0 Then
////						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
////						ii_rc = -1			
////						RollBack;
////						Return 
////					End If
////					
////					Insert Into callforwarding_info
////						( seq,orderno,contractseq,itemcod,
////						  addition_code,validkey,password,
////						  callforwardno,fromdt,todt,
////						  crt_user,crtdt, pgm_id ) 
////					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
////							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
////							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
////							 :gs_user_id,sysdate, :is_data[3]);
////							 
////					If SQLCA.SQLCode < 0 Then
////						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
////						ii_rc = -1						
////						RollBack;
////						Return 
////					End If									 
////
////				End IF
////					
////			CASE ls_callforward_code[2]     //착신전환비밀번호인증일때
////
////				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
////					
////					Update callforwarding_info
////					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
////						  updtdt = sysdate,
////						  pgm_id = :is_data[3]
////					where seq = :ll_callforward_seq_old;						
////				End If
////				
////				If ls_callforwardno_new <> "" Then    //변경후 착신전환번호가 있을 경우
////
////					//callforwarding_info_seq 가져 오기
////					Select seq_callforwarding_info.nextval
////					  Into :ll_callforward_seq_new
////					  From dual;
////					
////					If SQLCA.SQLCode < 0 Then
////						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
////						ii_rc = -1			
////						RollBack;
////						Return 
////					End If
////					
////					Insert Into callforwarding_info
////						( seq,orderno,contractseq,itemcod,
////						  addition_code,validkey,password,
////						  callforwardno,fromdt,todt,
////						  crt_user,crtdt, pgm_id ) 
////					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
////							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
////							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
////							 :gs_user_id,sysdate, :is_data[3] );
////
////					If SQLCA.SQLCode < 0 Then
////						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
////						ii_rc = -1						
////						RollBack;
////						Return 
////					End If									 
////
////				End IF						
////				
////			CASE ls_callforward_code[3]     //착신전환발신번호인증일때
////				
////				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
////					
////					Update callforwarding_info
////					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
////						  updtdt = sysdate,
////						  pgm_id = :is_data[3]
////					where seq = :ll_callforward_seq_old;						
////				End If					
////				
////				ll_callingnum_cnt = fi_cut_string(ls_callingnum_all, ";" , ls_callingnum[])
////
////				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
////					//callforwarding_info_seq 가져 오기
////					Select seq_callforwarding_info.nextval
////					  Into :ll_callforward_seq_new
////					  From dual;
////					
////					If SQLCA.SQLCode < 0 Then
////						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
////						ii_rc = -1			
////						RollBack;
////						Return 
////					End If
////					
////					Insert Into callforwarding_info
////						( seq,orderno,contractseq,itemcod,
////						  addition_code,validkey,password,
////						  callforwardno,fromdt,todt,
////						  crt_user,crtdt, pgm_id ) 
////					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
////							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
////							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
////							 :gs_user_id,sysdate, :is_data[3] );
////
////					If SQLCA.SQLCode < 0 Then
////						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
////						ii_rc = -1						
////						RollBack;
////						Return 
////					End If									 
////					
////					//발신가능전화번호 insert
////					For i = 1 To ll_callingnum_cnt	
////						Insert Into callforwarding_auth
////						( seq,callingnum,
////						  crt_user,crtdt, pgm_id ) 
////						Values ( :ll_callforward_seq_new,:ls_callingnum[i],
////							 :gs_user_id,sysdate, :is_data[3] );
////
////						If SQLCA.SQLCode < 0 Then
////							f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
////							ii_rc = -1						
////							RollBack;
////							Return 
////						End If									 
////							 
////					Next
////				End IF						
////				
////		END CHOOSE
////2009.05.27------------------------------------------------------END			
//
//		//khpark add 2005-07-11 start							
//		
//		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey_1 + "]로 변경되었습니다.")
//		commit;
//		
//	Case "b1w_validkey_update_popup_2_1_v20%ue_save"			//인증Key 관리모듈포함 version 2.0
////		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_1_v20%ue_save"
////		lu_dbmgr.is_title = Title
////		lu_dbmgr.idw_data[1] = dw_detail
////		lu_dbmgr.is_data[1]  = is_itemcod
////		lu_dbmgr.is_data[2]  = is_contractseq
////		lu_dbmgr.is_data[3]  = is_svctype
////		lu_dbmgr.is_data[4]  = is_pgm_id
////		lu_dbmgr.is_data[5]  = is_inout_svctype
////		lu_dbmgr.is_data[6]  = is_status
////		//lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt      //validkeytype count
////		//khpark add 2005-07-12
////		lu_dbmgr.is_data[7]  = is_addition_code      	 //착신전환부가서비스코드
////		lu_dbmgr.is_data[8]  = is_addition_itemcod    	 //착신전환부가서비스품목
////		lu_dbmgr.id_data[1]  = id_addition_item_todt  	 //착신전환부가서비스품목 todt		
//
//		idw_data[1].accepttext()
//		
//		ls_addition_code = is_data[7]
//		ls_addition_itemcod = is_data[8]
//		ld_addition_item_todt = id_data[1]	
//    	If IsNull(ls_addition_code) Then ls_addition_code = ""
//		If IsNull(ls_addition_itemcod) Then ls_addition_itemcod = ""
//		
//		ls_ref_desc = ""
//		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
//		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
//		If ls_sys_langtype = "" Then Return
//		
//		If is_data[5] = 'Y' Then
//			 ls_validkey_msg = 'Route-No.'
//		Else
//			 ls_validkey_msg = '인증KEY'
//		End IF
//		
//		//gkid default 값
//		ls_gkid = fs_get_control("00", "G100", ls_ref_desc)
//		
//		ls_validkey = idw_data[1].object.new_validkey[1]     //추가인증키
//		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
//		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
//		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
//		ls_new_todt_cf = ls_new_todt
//		ls_vpassword = idw_data[1].object.new_vpassword[1]
//		ls_langtype = idw_data[1].object.new_langtype[1]
//		ls_cid     = idw_data[1].object.cid[1]
//		ls_validkeyloc = idw_data[1].object.new_validkey_loc[1]
//		
//		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
//		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
//		If IsNull(ls_activedt) Then ls_activedt = ""
//		//2005.04.18 juede  fromdt >= activedt 로 조건변경------end
//		
//		If IsNull(ls_validkey) Then ls_validkey = ""
//		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
//		If IsNull(ls_fromdt) Then ls_fromdt = ""
//		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
//			ls_new_todt = ""
//			ls_new_todt_cf = '99991231'
//		End if
//		If IsNull(ls_vpassword) Then ls_vpassword = ""
//		ls_svccod = idw_data[1].object.svccod[1]
//		If IsNull(ls_svccod) Then ls_svccod = ""
//		If IsNull(ls_langtype) or ls_langtype = "" Then 
//			ls_langtype = ls_sys_langtype
//		End IF
//		If IsNull(ls_cid) Then ls_cid = ""
//		If IsNull(ls_validkeyloc) Then ls_validkeyloc = ""
//		
//		ls_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')
//	    ls_ip_address  = fs_snvl(idw_data[1].object.ip_address[1]     , '')
//		ls_h323id      = fs_snvl(idw_data[1].object.h323id[1]         , '')
//		ls_customerid  = fs_snvl(idw_data[1].object.customerid[1]     , '')           // ver2.0 khpark add
//		ls_contractseq = String(idw_data[1].object.contractseq[1])   
//		ls_partner     = idw_data[1].object.reg_partner[1] 
//		ls_priceplan   = Trim(idw_data[1].object.priceplan[1])
//		
//		If IsNull(ls_contractseq) Then ls_contractseq = '0'
//		If IsNull(ls_partner) Then ls_partner = ""	
//
////		If ls_validkey = "" Then
////			f_msg_usr_err(200, is_title, "인증KEY")
////			idw_data[1].SetFocus()
////			idw_data[1].SetColumn("new_validkey")
////			Return
////		End If
////		
////		If ls_vpassword = "" Then
////			f_msg_usr_err(200, is_title, "인증PassWord")
////			idw_data[1].SetFocus()
////			idw_data[1].SetColumn("new_vpassword")
////			Return
////		End If
//
//		If ls_fromdt = "" Then
//			f_msg_usr_err(200, is_title, "적용시작일")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_fromdt")
//			Return
//		End If
//
//		// 날짜 체크 2005.04.18 juede comment 처리
//		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
//		//If ls_fromdt < ls_sysdt Then
//		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜 이상이여야 합니다.")
//		//	idw_data[1].SetFocus()
//		//	idw_data[1].SetColumn("new_fromdt")
//		//	Return
//		//End If				
//		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---start
//		
//		If ls_fromdt < ls_activedt Then
//			f_msg_usr_err(210, is_Title, "적용시작일은 개통일자 이상이여야 합니다.")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_fromdt")
//			Return
//		End If		
//		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---end		
//
///* ----- */
//		//해당 가격정책에 VALIDTIEM(H323ID)에 따른 info 가져오기
//		li_return = b1fi_validitem_info_v20(is_title,ls_priceplan,ls_validitem_yn,ls_validkey_type_h,ls_crt_kind_h,ls_prefix_h,ll_length_h,ls_auth_method_h,ls_type_h,ls_used_level_h) 
//		
//		If li_return = -1 Then
//		    return
//		End IF
//
////			ls_temp = fs_get_control("B1","P400", ls_ref_desc)			
////			If ls_temp = "" Then Return 
////			fi_cut_string(ls_temp, ";" , ls_result_code[])
////			
////			//인증Key 관리상태(개통:20)
////			ls_validkeystatus = ls_result_code[2]			
//			
//		ls_validkey_type = Trim(idw_data[1].object.new_validkey_type[1])
//		
//		//인증KEY의 validkey_type에 따른 처리
//		li_return = b1fi_validkey_type_info_v20(is_title,ls_validkey_type,ls_validkey_typenm,ls_crt_kind,ls_prefix,ll_length,ls_auth_method,ls_type,ls_used_level) 
//		
//		If li_return = -1 Then
//			 return
//		End IF
//		
//		Choose Case ls_crt_kind		
//			Case ls_crt_kind_code[1]   //수동Manual
//				
//			Case ls_crt_kind_code[2]   //AutoRandom
//						
//				ls_auto_validkey = ""
//				  //validkey 생성에 따른 prefix 및 길이 Check
//				IF isnull(ls_prefix) or ls_prefix = "" Then
//							ls_prefix = ""
//					li_random_length = ll_length
//				Else
//					li_random_length = ll_length - LEN(ls_prefix)
//				END IF
//						
//				DO  //validkey random 생성
//					ls_auto_validkey = ls_prefix + fs_get_randomize_v20(li_random_length)
//	
//					select count(validkey)
//					  into :ll_cnt
//					  from validinfo
//					 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//							 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//							 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//						and validkey = :ls_auto_validkey
//						and svccod = :ls_svccod;	
//						
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, " Select Error(validinfo check)")
//						RollBack;
//						ii_rc = -1				
//						Return 
//					End If		
//				
//				LOOP WHILE(ll_cnt>0)		
//				
//				idw_data[1].object.new_validkey[1] = ls_auto_validkey
//	
//			Case ls_crt_kind_code[3]   //AutoSeq
//				
//				ls_auto_validkey = ""
//				//Order Sequence
//				Select to_char(seq_auto_validkey.nextval)
//				  Into :ls_auto_validkey
//				  From dual;
//				
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_title, " Sequence Error(seq_auto_validkey)")
//					RollBack;
//					ii_rc = -1				
//					Return 
//				End If				
//
//				idw_data[1].object.new_validkey[1] = ls_auto_validkey
//				
//			Case ls_crt_kind_code[4]   //자원관리Resource
//				
//			Case ls_crt_kind_code[5]   //고객대체				
//				
//		End Choose                
//		
//		If ls_auto_validkey <> '' Then
//			ls_validkey_1 = ls_auto_validkey
//		Else
//			ls_validkey_1 = ls_validkey
//		End If
////			If ls_validkey = "" Then
////				//f_msg_info(200, is_title, ls_validkey_msg)
////				idw_data[1].SetFocus()
////				idw_data[1].SetColumn("new_validkey")
////				ii_rc = -3
////				Return	
////			End If
//		
//		//인증KEY 중복 check  
//		//적용시작일과 적용종료일의 중복일자를 막는다. 
//		select count(validkey)
//		  into :ll_cnt
//		  from validinfo
//		 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//				 ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//				 :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//			and validkey = :ls_validkey_1
//			and svccod = :ls_svccod;
//				  
//		If sqlca.sqlcode < 0 Then
//			f_msg_sql_err(is_title, is_caller +"Select validinfo(count)")				
//			Return 
//		End If
//		
//		If ll_cnt > 0 Then
//			f_msg_usr_err(9000, is_title, ls_validkey_msg +"[" + ls_validkey_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_validkey")
//			ii_rc = -3					
//			return 
//		End if
//
//		ls_n_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')						 
//	    ls_n_validitem3  = fs_snvl(idw_data[1].object.h323id[1]         , '')
//		
//		IF ls_validitem_yn = 'Y' Then	
//			
//			Choose Case ls_crt_kind_h	
//				Case ls_crt_kind_code[1]   //수동Manual
//					
//				Case ls_crt_kind_code[2]   //AutoRandom
//
//					ls_auto_validitem = ""							
//					//validitem(H323id) 생성에 따른 prefix 및 길이 Check
//					IF isnull(ls_prefix_h) or ls_prefix_h = "" Then
//						ls_prefix_h= ""
//						li_random_length = ll_length_h
//					Else
//						li_random_length = ll_length_h - LEN(ls_prefix_h)
//					END IF
//							
//					DO  //validitem random 생성
//						ls_auto_validitem = ls_prefix_h + fs_get_randomize_v20(li_random_length)
//
//						ll_cnt = 0
//						IF mid(ls_n_auth_method,7,4) = "H323" Then
//		
//							select count(validkey)
//							  into :ll_cnt
//							  from validinfo
//							 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//									( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//									:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//								and validitem3 = :ls_auto_validitem
//								and svccod = :ls_svccod;									 
//								
//							If sqlca.sqlcode < 0 Then
//								f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)1")				
//								Return 
//							End If
//						End IF  
//						 
//					LOOP WHILE(ll_cnt > 0)		
//					
//					idw_data[1].object.h323id[1] = ls_auto_validitem
//
//				Case ls_crt_kind_code[3]   //AutoSeq							
//					
//					ls_auto_validitem = ""							
//					//Order Sequence
//					 Select to_char(seq_auto_validitem.nextval)
//					  Into :ls_auto_validitem
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, " Sequence Error(seq_auto_validitem)")
//						RollBack;
//						ii_rc = -1				
//						Return 
//					End If				
//
//					idw_data[1].object.h323id[1] = ls_auto_validitem
//					
//				Case ls_crt_kind_code[4]   //자원관리Resource
//					
//				Case ls_crt_kind_code[5]   //고객대체
//				
//			End Choose
//		End IF	 
//		
//		ls_n_langtype    = idw_data[1].object.new_langtype[1]
//		ls_n_validitem2  = idw_data[1].object.ip_address[1]
////		ls_n_validitem3  = idw_data[1].object.h323id[1]
//		ls_n_validitem1  = idw_data[1].object.cid[1]
//		
//		If ls_auto_validitem <> '' Then
//			ls_n_validitem3_1 = ls_auto_validitem
//		Else
//			ls_n_validitem3_1 = ls_n_validitem3
//		End If
//		
//		//인증방법이 _H323ID로 끝나는 것은 H323ID(validitem3)도 중복 CHECK.
//		ll_cnt = 0
//		IF mid(ls_n_auth_method,7,4) = "H323" Then
//
//			select count(validkey)
//			  into :ll_cnt
//			  from validinfo
//			  where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
//					( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//					:ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//					  and validitem3 = :ls_n_validitem3_1
//				and svccod = :ls_svccod;
//				
//			If sqlca.sqlcode < 0 Then
//				f_msg_sql_err(is_title, is_caller +"Select validinfo(validitem3 cnt)2")				
//				Return 
//			End If
//				
//			If ll_cnt > 0 Then
//				f_msg_usr_err(9000, is_title, "H323ID"+"[" + ls_n_validitem3_1+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("h323id")
//				ii_rc = -3					
//				return 
//			End if
//				
//		End IF  
//		
///*  ---- */		
////		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
//		select max(orderno) 
//		  into :ldc_svcorderno
//		  From svcorder 
//	     Where to_char(ref_contractseq) = :is_data[2]
//	       and status = :is_data[6];		
//							 
//		If sqlca.sqlcode < 0 Then
//			f_msg_sql_err(is_title, is_caller+"Select svcorder (orderno)")				
//			Return 
//		End If
//		
//		//Insert   
//		insert into validinfo
//			 ( validkey, fromdt, todt, 
//			  status, use_yn, vpassword,
//			  customerid, svccod, 
//			  svctype, priceplan,
//			  orderno, contractseq, gkid,
//			  validitem1, validitem2, validitem3, auth_method,
//			  validkey_loc, crt_user, crtdt,
//			  pgm_id, updt_user, updtdt, langtype)
//		  select :ls_validkey_1, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
//					 status, 'Y', :ls_vpassword,
//				customerid, svccod,
//				:is_data[3], priceplan,
//				:ldc_svcorderno, contractseq, :ls_gkid,
//				:ls_cid, :ls_ip_address, :ls_n_validitem3_1, :ls_auth_method,
//				:ls_validkeyloc, :gs_user_id, sysdate,
//				:is_data[4], :gs_user_id, sysdate, :ls_langtype
//			from contractmst
//		  where to_char(contractseq) = :is_data[2];
//
//		//저장 실패 
//		If SQLCA.SQLCode < 0 Then
//			RollBack;
//			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
//			Return 
//		End If	
//		
//		//인증KEY 인증KeyType이 자원관리인 경우만 처리
//		If ls_crt_kind = ls_crt_kind_code[4]  Then   
//			Update validkeymst
//				set status      = :ls_validkeymst_status[2]
//				  , sale_flag   = '1'
//				  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
//				  , customerid  = :ls_customerid
//				  , orderno     = :ldc_svcorderno
//				  , contractseq = :ls_contractseq 
//				  , updt_user   = :gs_user_id    ,  updtdt = sysdate,   pgm_id = :is_data[4] 
//			  Where validkey      = :ls_validkey_1
//				and validkey_type = :ls_validkey_type ;
//			  
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
//				Return 
//			End If
//				
//			Insert Into validkeymst_log
//					   ( validkey, seq, status, actdt, customerid
//						 , contractseq, partner, crt_user, crtdt, pgm_id )
//				 values 
//					   (:ls_validkey_1, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
//							to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
//						  :ls_partner, :gs_user_id, sysdate, :is_data[4] )	;					  
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: 인증key")				
//				Return 
//			End If
//		End If
//		
//		//validitem3(H323ID) KeyType이 자원관리인 경우만 처리
//		If ls_crt_kind_h = ls_crt_kind_code[4]  Then   
//			IF ls_n_validitem3_1 <> '' Then 
//				Update validkeymst
//					set status      = :ls_validkeymst_status[2]
//					  , sale_flag   = '1'
//					  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
//					  , customerid  = :ls_customerid
//					  , orderno     = :ldc_svcorderno
//					  , contractseq = :ls_contractseq 
//					  , updt_user   = :gs_user_id    ,  updtdt = sysdate,   pgm_id = :is_data[4] 
//				  Where validkey      = :ls_n_validitem3_1
//					 and validkey_type = :ls_validkey_type_h ;
//										 
//				  
//				If SQLCA.SQLCode <> 0 Then
//					RollBack;	
//					f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
//					Return 
//				End If
//				
//				Insert Into validkeymst_log
//							 ( validkey, seq, status, actdt, customerid
//							 , contractseq, partner, crt_user, crtdt, pgm_id )
//					  values 
//							 (:ls_n_validitem3_1, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
//								 to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
//								:ls_partner, :gs_user_id, sysdate, :is_data[4] );						  
//				If SQLCA.SQLCode <> 0 Then
//					RollBack;	
//					f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table: h323id")				
//					Return 
//				End If
//			End If
//		End If
//
//		ls_callforwardno_new = idw_data[1].object.new_callforwardno[1]
//        ls_password_new =  idw_data[1].object.new_password[1]
//        ls_callingnum_all = idw_data[1].object.callingnum[1]
//		If IsNull(ls_callforwardno_new) Then ls_callforwardno_new = ""
//		If IsNull(ls_password_new) Then ls_password_new = ""
//		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""
//		
//	   //khpark add 2005-07-12 start(착신전환부가서비스)
//		CHOOSE CASE ls_addition_code  
//			CASE ls_callforward_code[1]   //착신전환일반유형일때 
//
//				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
//					
//					//callforwarding_info_seq 가져 오기
//					Select seq_callforwarding_info.nextval
//					  Into :ll_callforward_seq_new
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
//						ii_rc = -1			
//						RollBack;
//						Return 
//					End If
//					
//					Insert Into callforwarding_info
//						( seq,orderno,contractseq,itemcod,
//						  addition_code,validkey,password,
//						  callforwardno,fromdt,todt,
//						  crt_user,crtdt, pgm_id ) 
//					Values ( :ll_callforward_seq_new, :ldc_svcorderno,:ls_contractseq,:ls_addition_itemcod,
//							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
//							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
//							 :gs_user_id,sysdate, :is_data[4]);
//							 
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
//						ii_rc = -1						
//						RollBack;
//						Return 
//					End If									 
//
//				End IF
//					
//			CASE ls_callforward_code[2]     //착신전환비밀번호인증일때
//
//				If ls_callforwardno_new <> "" Then    //변경후 착신전환번호가 있을 경우
//
//					//callforwarding_info_seq 가져 오기
//					Select seq_callforwarding_info.nextval
//					  Into :ll_callforward_seq_new
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
//						ii_rc = -1			
//						RollBack;
//						Return 
//					End If
//					
//					Insert Into callforwarding_info
//						( seq,orderno,contractseq,itemcod,
//						  addition_code,validkey,password,
//						  callforwardno,fromdt,todt,
//						  crt_user,crtdt, pgm_id ) 
//					Values ( :ll_callforward_seq_new, :ldc_svcorderno,:ls_contractseq,:ls_addition_itemcod,
//							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
//							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
//							 :gs_user_id,sysdate, :is_data[4] );
//
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
//						ii_rc = -1						
//						RollBack;
//						Return 
//					End If									 
//
//				End IF						
//				
//			CASE ls_callforward_code[3]     //착신전환발신번호인증일때
//				
//				ll_callingnum_cnt = fi_cut_string(ls_callingnum_all, ";" , ls_callingnum[])
//
//				If ls_callforwardno_new <> "" Then   //변경후 착신전환번호가 있을 경우
//					//callforwarding_info_seq 가져 오기
//					Select seq_callforwarding_info.nextval
//					  Into :ll_callforward_seq_new
//					  From dual;
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + "SELECT seq_callforwarding_info.nextval")			
//						ii_rc = -1			
//						RollBack;
//						Return 
//					End If
//					
//					Insert Into callforwarding_info
//						( seq,orderno,contractseq,itemcod,
//						  addition_code,validkey,password,
//						  callforwardno,fromdt,todt,
//						  crt_user,crtdt, pgm_id ) 
//					Values ( :ll_callforward_seq_new, :ldc_svcorderno,:ls_contractseq,:ls_addition_itemcod,
//							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
//							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
//							 :gs_user_id,sysdate, :is_data[4] );
//
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
//						ii_rc = -1						
//						RollBack;
//						Return 
//					End If									 
//					
//					//발신가능전화번호 insert
//					For i = 1 To ll_callingnum_cnt	
//						Insert Into callforwarding_auth
//						( seq,callingnum,
//						  crt_user,crtdt, pgm_id ) 
//						Values ( :ll_callforward_seq_new,:ls_callingnum[i],
//							 :gs_user_id,sysdate, :is_data[4] );
//
//						If SQLCA.SQLCode < 0 Then
//							f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
//							ii_rc = -1						
//							RollBack;
//							Return 
//						End If									 
//							 
//					Next
//				End IF						
//				
//		END CHOOSE
//		//khpark add 2005-07-12 start							
//			
//    	f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey_1 + "]가  추가되었습니다.")
//		
//		commit;
//		
//	Case "b1w_validkey_update_popup_3_1_v20%ue_save"			//인증Key 관리모듈포함 version 2.0
//		idw_data[1].accepttext()
//		
//		ls_validkey  = fs_snvl(idw_data[1].object.validkey[1]  , '')
//      ls_h323id    = fs_snvl(idw_data[1].object.validitem3[1], '')
//	   ls_priceplan = fs_snvl(idw_data[1].object.priceplan[1] , '')
//		
//		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
//		If IsNull(ls_customerid) Then ls_customerid = ""		
//		ls_contractseq = String(idw_data[1].object.contractseq[1])   
//		If IsNull(ls_contractseq) Then ls_contractseq = '0'
//		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
//		If IsNull(ls_partner) Then ls_partner = '0'		
//		ls_orderno = String(idw_data[1].object.orderno[1])   
//		If IsNull(ls_orderno) Then ls_orderno = '0'
//
//		Update validkeymst
//		   set status =:ls_validkeymst_status[3],  sale_flag = '0', activedt = null,
//			   customerid = '',  orderno = null,   contractseq = null,
//			   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[2] 
//		 Where validkey = :ls_validkey
//		   And contractseq = :ls_contractseq;
//		  
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
//			Return 
//		End If
//		
//		Insert Into validkeymst_log
//		   (validkey, seq, status, actdt, customerid, 
//			contractseq, partner, crt_user, crtdt, pgm_id)
//		 Select :ls_validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[3], to_date(:is_data[1],'yyyy-mm-dd'), :ls_customerid,
//				  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[2] 
//		  From validkeymst where validkey = :ls_validkey;
//				  
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table")				
//			Return 
//		End If
//		
//		If ls_h323id <> '' Then
//			Update validkeymst
//				set status =:ls_validkeymst_status[3],  sale_flag = '0', activedt = null,
//					customerid = '',  orderno = null,   contractseq = null,
//					updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[2] 
//			 Where validkey = :ls_h323id
//				And contractseq = :ls_contractseq;
//			  
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table :h323id")					
//				Return 
//			End If
//			
//			Insert Into validkeymst_log
//				(validkey, seq, status, actdt, customerid, 
//				contractseq, partner, crt_user, crtdt, pgm_id)
//			 Select :ls_h323id, seq_validkeymstlog.nextval, :ls_validkeymst_status[3], to_date(:is_data[1],'yyyy-mm-dd'), :ls_customerid,
//					  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[2] 
//			  From validkeymst 
//			 where validkey    = :ls_h323id
//			   And contractseq = :ls_contractseq;
//					  
//			If SQLCA.SQLCode <> 0 Then
//				RollBack;	
//				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table :h323id")				
//				Return 
//			End If
//	
//		End IF
//		
//	Case Else
//		f_msg_info_app(9000, "b1u_dbmgr_v20.uf_prc_db_02()", &
//							"Matching statement Not found(" + String(is_caller) + ")")
//		Return  
//End Choose
//ii_rc = 0
end subroutine

on b1u_dbmgr1_v20.create
call super::create
end on

on b1u_dbmgr1_v20.destroy
call super::destroy
end on

