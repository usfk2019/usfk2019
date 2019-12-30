$PBExportHeader$b1u_dbmgr12_v20.sru
$PBExportComments$[kem] 서비스개통신청(선불) - 선납품목 추가
forward
global type b1u_dbmgr12_v20 from u_cust_a_db
end type
end forward

global type b1u_dbmgr12_v20 from u_cust_a_db
end type
global b1u_dbmgr12_v20 b1u_dbmgr12_v20

forward prototypes
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db_03 ();
//b1w_reg_svc_actorder_6%save
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

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_6%save"    //장비임대 포함 수정, 입중계출중계서비스추가
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

public subroutine uf_prc_db_02 ();//"b1w_reg_svc_actprc_pre_2%save"
String ls_ref_desc, ls_temp, ls_status, ls_customerid, ls_priceplan, ls_prmtype
String ls_refilltype[], ls_pricemodel, ls_cus_status, ls_activedt, ls_svccod
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_partner, ls_orderdt, ls_requestdt, ls_contractno, ls_reg_prefixno
String ls_remark, ls_bil_fromdt, ls_pgm_id, ls_term_status, ls_enter_status
String ls_reqactive, ls_validkey, ls_todt_tmp, ls_svctype, ls_enddt, ls_direct_paytype
Decimal{2} ldc_first_refill_amt, ldc_first_sale_amt
Dec{0} ldc_contractseq, ldc_orderno, ldc_price, ldc_rate_first, ldc_basic_fee_first, ldc_basic_rate_first
String ls_hotbillflag
DateTime ldt_crtdt
Long ll_row, ll_cnt//, ll_endday
Boolean lb_flag = False


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actprc_pre_2%save"
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
//		ll_endday = idw_data[1].object.svcorder_endday[1]
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


		//1. 해당 Partner, 해당 Priceplan
		Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
		  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
		  From refillpolicy
		 where partner = :ls_reg_partner  
			and priceplan = :ls_priceplan 
			and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
															  from refillpolicy 
															 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																and partner   = :ls_reg_partner  
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
			 where partner = :ls_reg_partner  
				and priceplan = 'ALL' 
				and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																  from refillpolicy 
																 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																	and partner   = :ls_reg_partner  
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
				enddt, direct_paytype)//endday
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno,
			   :ls_pricemodel, :ldc_price, :ldc_first_sale_amt, :ldc_first_refill_amt,
			   :ldc_price, :ldc_first_sale_amt, :ldc_price, to_date(:ls_activedt,'yyyy-mm-dd'),
				to_date(:ls_enddt,'yyyy-mm-dd'), :ls_direct_paytype);//ll_endday

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
Return 
end subroutine

public subroutine uf_prc_db ();//b1w_reg_svc_actorder_pre_2%save
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
	
String ls_prebil_yn, ls_oneoffcharge_yn, ls_itemcod1, ls_validloc_gu, ls_day, ls_direct_paytype, &
       ls_method_code[], ls_M_method, ls_D_method, ls_paytype_method[]
Long   ll_validity_term, ll_i
Decimal ldc_unitcharge, ldc_payamt, ldc_price, ldc_rate_first, ldc_basic_fee_first, ldc_basic_rate_first
Date   ld_salemonth, ld_inputclosedt
Boolean lb_flag = False

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_pre_3%save"    //선불제(선납포함) - 장비모듈 추가, 인증KeyLocation 필수 체크 포함.
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
		
		//과금방식코드
		ls_temp = fs_get_control("B0", "P106" , ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_method_code[])
		ls_M_method  = ls_method_code[1]    //월정액
		ls_D_method  = ls_method_code[8]    //Daily정액
		
		//청구서발송방식;직접입금방식 100 200
		ls_temp = fs_get_control("B1", "P600" , ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_paytype_method[])
		
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
				
				If IsNull(ls_n_auth_method[i]) Then ls_n_auth_method[i] = ""
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
				f_msg_sql_err(is_title, is_caller + "SELECT Error(salepricemodel)")
				RollBack;
				Return
			End If	
	
	
			//1. 해당 Partner, 해당 Priceplan
			Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
			  From refillpolicy
			 where partner = :ls_reg_partner  
				and priceplan = :ls_priceplan 
				and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																  from refillpolicy 
																 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																	and partner   = :ls_reg_partner  
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
			
			//2. 해당 Partner, 'ALL' Priceplan
			If lb_flag = False Then
				
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
			     Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_reg_partner  
					and priceplan = 'ALL' 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_reg_partner  
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
				   refill_type, refill_amt, sale_amt, baiscamt, 
				   remark, partner_prefix, crtdt, crt_user)
			values ( seq_refilllogseq.nextval, :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), 
				   :ls_refilltype[1], :ldc_price, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt,
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

public subroutine uf_prc_db_01 ();//"b1w_inq_svcorder_b%cancel"
String ls_ref_desc, ls_result_code[], ls_temp, ls_customerid, ls_validkeystatus, ls_priceplan, ls_svccod
String ls_order_status, ls_tmp, ls_serialno, ls_mv_partner, ls_status, ls_pre_status, ls_ubs_17, ls_ubs_18
String ls_cause, ls_cancel, ls_admst_status
Long   ll_hwseq,	ll_contractseq, ll_pre_orderno, ll_svccod_cnt, ll_priceplan_cnt, ll_admst_cnt
Long	 ll_mobile_cnt, ll_not_cnt, ll_quota_cnt
Integer li_cnt, is_cnt

ii_rc = -2
CHOOSE CASE is_caller
	CASE "b1w_inq_svcorder_c_v20%cancel"
//    참고 사항
//		lu_dbmgr.is_caller = "b1w_inq_svcorder_c%cancel"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data  Order Number
//		lu_dbmgr.is_data[2] = is_partner
//		lu_dbmgr.is_data[3] = is_status_1
//		lu_dbmgr.is_data[4] = is_status_2
//		lu_dbmgr.is_data[6] = gs_user_id
//		lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.ii_data[1]  = ii_cnt 

		ls_customerid 		= Trim(idw_data[1].object.svcorder_customerid[idw_data[1].getrow()])
		ls_order_status 	= Trim(idw_data[1].object.svcorder_status[idw_data[1].getrow()])
		ll_contractseq		= idw_data[1].object.svcorder_ref_contractseq[idw_data[1].getrow()]
		ls_priceplan		= Trim(idw_data[1].Object.svcorder_priceplan[idw_data[1].getrow()])
		ls_svccod	   	= Trim(idw_data[1].Object.svcorder_svccod[idw_data[1].getrow()])
		ls_cause				= Trim(idw_data[1].Object.svcorder_direct_paytype[idw_data[1].getrow()])
		
		//ADMSTLOG_NEW 테이블에 ACTION 값 ( 취소 )
		SELECT ref_content INTO :ls_cancel FROM sysctl1t 
		WHERE module = 'U2' AND ref_no = 'A104';
		
		ls_admst_status = fs_get_control("E1", "A104", ls_ref_desc)
		
      // 후행 서비스 취소없이 선행을 먼저 취소하는지 체크 -- add hcjung 20071203
		SELECT count(*) INTO :is_cnt FROM svc_relation WHERE pre_priceplan = :is_data[8];
		
		IF is_cnt > 0 THEN
			SELECT count(*) INTO :is_cnt FROM svcorder WHERE related_orderno = :is_data[1];
			IF is_cnt > 0 THEN
				f_msg_sql_err(is_title, is_caller + " Check Service Relation")
				RollBack;
				RETURN 
		   END IF
		END IF
		
		//서비스신청 테이블 이관. SVCORDER_CAN 으로...
		INSERT INTO SVCORDER_CAN
			(  ORDERNO, CUSTOMERID, ORDERDT, REQUESTDT, STATUS, SVCCOD, PRICEPLAN,
				PRICEMODEL, PRMTYPE, REG_PREFIXNO, REG_PARTNER, SALE_PARTNER, MAINTAIN_PARTNER, SETTLE_PARTNER,
				PARTNER, REF_CONTRACTSEQ, TERMTYPE, SUSPEND_TYPE, REMARK, FIRST_REFILL_AMT, FIRST_SALE_AMT,
				ORDER_PRIORITY, HOPENUM, ACTTYPE, CHGOPT, VPRICECOD, BIL_FROMDT, DIRECT_PAYTYPE, 
				ENDDT, CRT_USER, UPDT_USER, CRTDT, UPDTDT, PGM_ID, ORDER_TYPE,
				RELATED_ORDERNO, SELFEQUIP_YN )
		SELECT 	ORDERNO, CUSTOMERID, ORDERDT, REQUESTDT, STATUS, SVCCOD, PRICEPLAN,
					PRICEMODEL, PRMTYPE, REG_PREFIXNO, REG_PARTNER, SALE_PARTNER, MAINTAIN_PARTNER, SETTLE_PARTNER,
					PARTNER, REF_CONTRACTSEQ, TERMTYPE, SUSPEND_TYPE, REMARK, FIRST_REFILL_AMT, FIRST_SALE_AMT,
					ORDER_PRIORITY, HOPENUM, ACTTYPE, CHGOPT, VPRICECOD, BIL_FROMDT, :ls_cause, 
					ENDDT, CRT_USER, UPDT_USER, CRTDT, UPDTDT, PGM_ID, ORDER_TYPE,
					RELATED_ORDERNO, SELFEQUIP_YN
		FROM     SVCORDER
		WHERE    ORDERNO = TO_NUMBER(:is_data[1]);

		IF SQLCA.SQLCode < 0 THEN
			ROLLBACK;			
			f_msg_sql_err(is_title, is_caller + " INSERT Error(SVCORDER_CAN)")
			RETURN 
		END IF				

		//1.서비스신청(svcorder) 테이블 Delete
		//DELETE FROM svcorder WHERE to_char(orderno) = :is_data[1];
		DELETE FROM svcorder WHERE orderno = TO_NUMBER(:is_data[1]);		

		STRING ls_reqactive, ls_reqactive1 //개통 신청 상태, 개통신청(단말기미등록) 상태 코드
		ls_reqactive 		= fs_get_control("B0", "P220", ls_ref_desc)
		ls_reqactive1 		= fs_get_control("B0", "P241", ls_ref_desc)
		
		//2.개통신청인 경우 validinfo 삭제...
		IF ls_reqactive = ls_order_status or ls_reqactive1 = ls_order_status THEN
			//Validinfo 삭제
			//DELETE FROM validinfo WHERE to_char(orderno) = :is_data[1];
			DELETE FROM validinfo WHERE orderno = TO_NUMBER(:is_data[1]);
		
			IF SQLCA.SQLCode < 0 THEN
				ROLLBACK;				
				f_msg_sql_err(is_title, is_caller + " DETELE Error(VALIDINFO)")
				RETURN 
			END IF
		END IF
		
		//3.계약품목디테일(contractdet) 테이블 Delete
		//DELETE FROM contractdet WHERE to_char(orderno) = :is_data[1];
		DELETE FROM contractdet WHERE orderno = TO_NUMBER(:is_data[1]);
		
		//DELETE FROM callforwarding_auth 
		//WHERE seq = (SELECT seq 
		//              FROM callforwarding_info 
		//				  WHERE to_char(orderno) = :is_data[1]);
						  
		DELETE FROM callforwarding_auth 
		WHERE seq = (SELECT seq 
		              FROM  callforwarding_info 
						  WHERE orderno = TO_NUMBER(:is_data[1]));						  
		
		//DELETE FROM callforwarding_info WHERE to_char(orderno) = :is_data[1];
		DELETE FROM callforwarding_info WHERE orderno = TO_NUMBER(:is_data[1]);
		
		//4.할부정보(quota_info) 테이블 Delete
		//DELETE FROM quota_info WHERE to_char(orderno) = :is_data[1];
		DELETE FROM quota_info WHERE orderno = TO_NUMBER(:is_data[1]);
		
		//5.해당 Order 번호에 해당하는 하드웨어 정보가 있는지 확인
		//SELECT count(*)
		//INTO   :li_cnt
		//FROM   customer_hw
		//WHERE  to_char(orderno) = :is_data[1];
		SELECT count(*)
		INTO   :li_cnt
		FROM   customer_hw
		WHERE  customerid = :ls_customerid
		AND    orderno    = TO_NUMBER(:is_data[1]);		
		
		IF li_cnt > 0 THEN
			SETNULL(ls_tmp)		//NULL SETting			
			DECLARE serialno CURSOR FOR
				SELECT serialno
				FROM   customer_hw
				WHERE  customerid = :ls_customerid
				AND    orderno = TO_NUMBER(:is_data[1]);
				//SELECT serialno
				//FROM customer_hw
				//WHERE to_char(orderno) = :is_data[1];				
			
			OPEN serialno;
		 	Do While(TRUE)										//looping
				FETCH serialno	INTO :ls_serialno;
				//error
				IF SQLCA.SQLCODE < 0 THEN
					f_msg_sql_err(is_title, is_caller + " SELECT Error(CUSTOMER_HW)")
					CLOSE serialno;
					RETURN 	 
				ELSEIF SQLCA.SQLCODE = 100 THEN
					EXIT;
				END IF
						 
				//장비 마스터에 UPDATE
				SELECT mv_partner, adseq
				INTO   :ls_mv_partner, :ll_hwseq
				FROM   admst
				WHERE  serialno = :ls_serialno;
						
				IF SQLCA.SQLCode < 0 THEN
					f_msg_sql_err(is_title, is_caller + " SELECT Error(ADMST)")
					ROLLBACK;
					RETURN 
				END IF
						
				IF ls_mv_partner = is_data[2] THEN  // 본사이면
			   	ls_status = is_data[3]
				ELSE
					ls_status = is_data[4]				//대리점
				END IF
			
				UPDATE admst
					SET status 		= :ls_status,
					    saledt 		= :ls_tmp,
					    customerid = :ls_tmp,
					    sale_amt 	= :ls_tmp,
					    sale_flag 	= '0',
					    updt_user 	= :is_data[6],
					    pgm_id 		= :is_data[7]
				 WHERE serialno = :ls_serialno;
						
				IF SQLCA.SQLCode < 0 THEN
					f_msg_sql_err(is_title, is_caller + " UPDATE Error(ADMST)")
					ROLLBACK;
					RETURN 
				END IF
			
				//admstlog insert	장비 이력
				INSERT INTO admstlog ( adseq, seq, action, status, actdt, customerid, fr_partner,
											  crt_user, crtdt, pgm_id)
								VALUES( :ll_hwseq, seq_admstlog.nextval, :is_data[5], :ls_status,
											sysdate, :ls_customerid, :ls_mv_partner, :is_data[6], sysdate,:is_data[7]);
					
				IF SQLCA.SQLCode < 0 THEN
					f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG)")
					ROLLBACK;
					RETURN 
				END IF									
			LOOP
			CLOSE serialno;
			
			//4.고객HW정보(customer_hw) 테이블 Delete
			//DELETE FROM customer_hw
			//WHERE orderno = :is_data[1];
			
			DELETE FROM customer_hw
			WHERE orderno = TO_NUMBER(:is_data[1]);
			
			IF SQLCA.SQLCode < 0 THEN
				f_msg_sql_err(is_title, is_caller + " Delete Error(customer_hw)")
				ROLLBACK;
				RETURN 
			END IF
		END IF		
		
		//ADMST 에 데이터가 있는경우. 모바일 장비 같은 경우...바꾸고 ADMSTLOG_NEW 에로그 남기기...
		SELECT COUNT(*) INTO :ll_admst_cnt
		FROM   ADMST
		WHERE  CUSTOMERID = :ls_customerid
		AND    ORDERNO =  TO_NUMBER(:is_data[1]);
		
		IF ll_admst_cnt > 0 THEN
			//장비이력(admstlog_new) Table에 정보저장
			INSERT INTO ADMSTLOG_NEW		
				( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
				  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
				  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
				  PGM_ID, IDATE )
			SELECT ADSEQ, seq_admstlog.nextval, :ls_cancel, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, DECODE(MV_PARTNER, :is_data[2], :is_data[3], :is_data[4]),
					 NULL, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, NULL, NULL,
					 NULL, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
					 :is_data[7], IDATE
			FROM   ADMST
		   WHERE  CUSTOMERID = :ls_customerid
			AND    ORDERNO    = TO_NUMBER(:is_data[1]);
				
			If SQLCA.SQLCode < 0 Then
				RollBack;				
				f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG_NEW)")
				Return 
			End If			
			
			//a. ADMST Update
			Update ADMST
				Set saledt 		= null,
					 Status 		= DECODE(MV_PARTNER, :is_data[2], :is_data[3], :is_data[4]),
					 sale_flag	= '0',
					 customerid = null,					 
				    sale_amt 	= null,
					 orderno    = null,
 					 updt_user 	= :gs_user_id,
					 updtdt 		= sysdate,
					 pgm_id 		= :is_data[7]
		    WHERE CUSTOMERID = :ls_customerid
				AND ORDERNO    = TO_NUMBER(:is_data[1]);
					
			If SQLCA.SQLCode < 0 Then
				RollBack;				
				f_msg_sql_err(is_title, is_caller + " UPDATE Error(ADMST)")
				Return 
			End If
		END IF
		
		//AD_MOBILE_RENTAL 에 데이터가 있는 경우... 바꾸고 LEASELOG_NEW 에 로그 남기기
		SELECT COUNT(*) INTO :ll_mobile_cnt
		FROM   AD_MOBILE_RENTAL
		WHERE  CUSTOMERID = :ls_customerid
		AND    CONTRACTSEQ = :ll_contractseq;
		
		IF ll_mobile_cnt > 0 THEN
			//장비이력(LEASELOG_NEW) Table에 정보저장 - 반품
			INSERT INTO LEASELOG_NEW		
				( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
				  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
				  RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
				  PGM_ID, IDATE )
			SELECT SEQ, seq_admstlog.nextval, :ls_cancel, SYSDATE, FR_SHOP, MV_SHOP, CONTNO, :ls_admst_status,
					 NULL, SHOPID, 1, 0, 0, PHONE_MODEL, NULL, NULL,
					 NULL, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
					 :is_data[7], ISEQ
			FROM   AD_MOBILE_RENTAL
			WHERE  CUSTOMERID = :ls_customerid
			AND    CONTRACTSEQ = :ll_contractseq;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;				
				f_msg_sql_err(is_title, is_caller + " UPDATE Error(LEASELOG_NEW)")				
				RETURN
			End If		
			
			UPDATE AD_MOBILE_RENTAL
			SET    CUSTOMERID  = NULL,
					 CONTRACTSEQ = NULL,
					 VALIDKEY	 = NULL,
					 CARD_CONTNO = NULL,
					 STATUS	    = :ls_admst_status,
					 updt_user   = :gs_user_id,
					 updtdt 	    = sysdate,
					 pgm_id 	    = :is_data[7]
			WHERE  CUSTOMERID = :ls_customerid
			AND    CONTRACTSEQ = :ll_contractseq;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;				
				f_msg_sql_err(is_title, is_caller + " UPDATE Error(AD_MOBILE_RENTAL)")				
				RETURN
			End IF
		END IF		
		
		//EQUIPMST 에 데이터가 있는 경우...바꾸고 EQUIPLOG 에 로그남기기...						
		//인증장비는 여기 나올 수 없다...
		
		/*** 단말할부 취소처리 START************************************************/
		//CONT_QUOTASALEMST 에 데이터가 있는 경우... 취소처리
		SELECT COUNT(*) INTO :ll_quota_cnt FROM CONT_QUOTASALEMST
		WHERE ORDERNO = TO_NUMBER(:is_data[1])
        AND CANCEL_YN = 'N';
		  
		IF ll_quota_cnt > 0 THEN
			  //CONT_QUOTASALEMST
			  UPDATE CONT_QUOTASALEMST SET
					  CANCEL_YN 	= 'Y',
					  CANCELDT 		= SYSDATE,
					  CANCEL_USER 	= :gs_user_id,
					  UPDT_USER 	= :gs_user_id,
					  UPDT        	= SYSDATE,
					  pgm_id       = :is_data[7]
			  WHERE ORDERNO = TO_NUMBER(:is_data[1])
					  AND CANCEL_YN = 'N';
						
			If SQLCA.SQLCode <> 0 Then
				RollBack;				
				f_msg_sql_err(is_title, is_caller + " UPDATE Error(CONT_QUOTASALEMST)")				
				RETURN
			End IF
		END IF	
		/*** 단말할부 취소처리 END  ************************************************/
		
		
		
		//5.위약금내역(penaltydet)테이블 Delete  
		//DELETE FROM penaltydet  
		//WHERE to_char(orderno) = :is_data[1];
		DELETE FROM penaltydet  
		WHERE  orderno = TO_NUMBER(:is_data[1]);	
		
		IF SQLCA.SQLCode < 0 THEN
			ROLLBACK;			
			f_msg_sql_err(is_title, is_caller + " Delete Error(penaltydet)")
			RETURN 
		END IF		
		
		//6.일시불정보내역(oncepayment)테이블 Delete
		//DELETE FROM oncepayment
		//WHERE  TO_CHAR(orderno) = :is_data[1];
		DELETE FROM oncepayment
		WHERE  orderno = TO_NUMBER(:is_data[1]);
		
		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(is_title, is_caller + " Delete Error(oncepayment)")
			ROLLBACK;
			RETURN 
		END IF		
				
		//7.가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
		//IF ii_data[1] > 0 THEN  --> 제외 o.h.j.
			
		//인증Key 관리상태
		ls_temp = fs_get_control("B1","P400", ls_ref_desc)
		IF ls_temp = "" THEN RETURN 
		fi_cut_string(ls_temp, ";" , ls_result_code[])
			
		//인증Key 관리상태(개통:00)
		ls_validkeystatus = ls_result_code[1]
							
		//인증Key 마스터 UPDATE
		UPDATE validkeymst
		SET    status      = :ls_validkeystatus,
				 sale_flag   = '0',
				 activedt    = NULL,
				 customerid  = NULL,
				 orderno     = 0,
				 contractseq = 0,
				 updt_user   = :gs_user_id,
				 updtdt      = sysdate
		WHERE  orderno     = TO_NUMBER(:is_data[1]);
//		WHERE  orderno     = :is_data[1];

		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(is_title, is_caller + " Update Error(validkeymst)")
			ROLLBACK;
			RETURN 
		END IF		
			
		//End IF
		
		//8.선납판매정보에 따른 처리 추가 (2004.12.10 kem)
		//DELETE FROM PREPAYMENT WHERE TO_CHAR(ORDERNO) = :is_data[1];
		DELETE FROM PREPAYMENT WHERE ORDERNO = TO_NUMBER(:is_data[1]);
		
		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(is_title, is_caller + " Delete Error(PREPAYMENT)")
			ROLLBACK;
			RETURN 
		END IF				
		
		//9.선수금등록에 따른 처리 추가 (2004.12.20 kem)
		//DELETE FROM REQPAY WHERE TO_CHAR(ORDERNO) = :is_data[1];
		DELETE FROM REQPAY WHERE ORDERNO = TO_NUMBER(:is_data[1]);
		
		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(is_title, is_caller + " Delete Error(REQPAY)")
			ROLLBACK;
			RETURN 
		END IF				
		
		//10. SSRT --------------- Add k.b.Cho
		//DELETE FROM SCHEDULE_DETAIL
		//WHERE TO_CHAR(ORDERNO) = :is_data[1] ;
		DELETE FROM SCHEDULE_DETAIL
		WHERE  ORDERNO = TO_NUMBER(:is_data[1]);

		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(is_title, is_caller + " Delete Error(SCHEDULE_DETAIL)")
			ROLLBACK;
			RETURN 
		END IF						
		
		// 서비스 연관 관계 풀기 -- add hcjung 20071203
		//UPDATE SVCORDER SET related_orderno = NULL
		//WHERE to_char(related_orderno) = :is_data[1];
		UPDATE SVCORDER SET related_orderno = NULL
		WHERE  related_orderno = TO_NUMBER(:is_data[1]);
		
		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
			ROLLBACK;
			RETURN 
		END IF	
		
		SELECT COUNT(*) INTO :ll_svccod_cnt
		FROM   SYSCOD2T
		WHERE  GRCODE = 'BOSS03'
		AND    CODE = :ls_svccod;
		
		SELECT COUNT(*) INTO :ll_priceplan_cnt
		FROM   SYSCOD2T
		WHERE  GRCODE = 'BOSS04'
		AND    CODE = :ls_priceplan;	
		
		SELECT COUNT(*) INTO :ll_not_cnt
		FROM   SYSCOD2T
		WHERE  GRCODE = 'BOSS05'
		AND    CODE = :ls_svccod;			
		
		IF (ll_svccod_cnt > 0 AND ll_priceplan_cnt <= 0) THEN
		
			//SIID 테이블의 ORDERNO 와 상태값, EQUIPMST 의 VALID_STATUS 값을 변경하기 위한 노력. 2010.05.28
			SELECT ORDERNO, STATUS INTO :ll_pre_orderno, :ls_pre_status
			FROM ( SELECT ORDERNO, STATUS 
					 FROM   SVCORDER
					 WHERE  CUSTOMERID = :ls_customerid
					 AND    ORDERNO <> TO_NUMBER(:is_data[1])
					 AND    REF_CONTRACTSEQ = :ll_contractseq
					 ORDER BY REQUESTDT DESC )
			WHERE  ROWNUM = 1;
			
			//이전 오더 상태값으로 siid 상태값, equipmst 의 valid_status 값 가져오기
			SELECT TO_CHAR(SUM(TO_NUMBER(UBS_17))) AS UBS_17, TO_CHAR(SUM(TO_NUMBER(UBS_18))) AS UBS_18
			INTO   :ls_ubs_17, :ls_ubs_18
			FROM ( SELECT CODE, CODENM AS UBS_17, '0' AS UBS_18 FROM SYSCOD2T WHERE GRCODE = 'UBS17'
					 UNION ALL
					 SELECT CODE, '0', CODENM FROM SYSCOD2T WHERE GRCODE = 'UBS18' )
			WHERE  CODE = :ls_pre_status;
			
			UPDATE SIID
			SET    ORDERNO = :ll_pre_orderno,
					 STATUS  = :ls_ubs_17,
					 UPDTDT  = SYSDATE
			WHERE  CONTRACTSEQ = :ll_contractseq;
			
			IF SQLCA.SQLCode < 0 THEN
				f_msg_sql_err(is_title, is_caller + " Update Error(SIID)")
				ROLLBACK;
				RETURN 
			END IF									
			
			UPDATE EQUIPMST
			SET    VALID_STATUS = :ls_ubs_18
			WHERE  CONTRACTSEQ = :ll_contractseq;		
	
			IF SQLCA.SQLCode < 0 THEN
				f_msg_sql_err(is_title, is_caller + " Update Error(EQUIPMST)")
				ROLLBACK;
				RETURN 
			END IF	

		END IF
		
		IF ll_not_cnt > 0 THEN
		
			//SIID 테이블의 ORDERNO 와 상태값, EQUIPMST 의 VALID_STATUS 값을 변경하기 위한 노력. 2010.05.28
			SELECT ORDERNO, STATUS INTO :ll_pre_orderno, :ls_pre_status
			FROM ( SELECT ORDERNO, STATUS 
					 FROM   SVCORDER
					 WHERE  CUSTOMERID = :ls_customerid
					 AND    ORDERNO <> TO_NUMBER(:is_data[1])
					 AND    REF_CONTRACTSEQ = :ll_contractseq
					 ORDER BY REQUESTDT DESC )
			WHERE  ROWNUM = 1;
			
			//이전 오더 상태값으로 siid 상태값, equipmst 의 valid_status 값 가져오기
			SELECT TO_CHAR(SUM(TO_NUMBER(UBS_17))) AS UBS_17, TO_CHAR(SUM(TO_NUMBER(UBS_18))) AS UBS_18
			INTO   :ls_ubs_17, :ls_ubs_18
			FROM ( SELECT CODE, CODENM AS UBS_17, '0' AS UBS_18 FROM SYSCOD2T WHERE GRCODE = 'UBS17'
					 UNION ALL
					 SELECT CODE, '0', CODENM FROM SYSCOD2T WHERE GRCODE = 'UBS18' )
			WHERE  CODE = :ls_pre_status;
			
			UPDATE EQUIPMST
			SET    STATUS = '300',
					 VALID_STATUS = :ls_ubs_18
			WHERE  CONTRACTSEQ = :ll_contractseq;		
		
			IF SQLCA.SQLCode < 0 THEN
				f_msg_sql_err(is_title, is_caller + " Update Error(EQUIPMST)")
				ROLLBACK;
				RETURN 
			END IF	
		END IF		
	
END CHOOSE	
ii_rc = 0
end subroutine

on b1u_dbmgr12_v20.create
call super::create
end on

on b1u_dbmgr12_v20.destroy
call super::destroy
end on

