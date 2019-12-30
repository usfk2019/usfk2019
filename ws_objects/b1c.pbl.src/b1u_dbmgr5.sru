$PBExportHeader$b1u_dbmgr5.sru
$PBExportComments$[jsha]
forward
global type b1u_dbmgr5 from u_cust_a_db
end type
end forward

global type b1u_dbmgr5 from u_cust_a_db
end type
global b1u_dbmgr5 b1u_dbmgr5

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();//lu_dbmgr.ic_data[1] = lc_refill_amt			//충전금액
//lu_dbmgr.ic_data[2] = lc_sale_amt	   	//판매금액  
//lu_dbmgr.is_data[1] = ls_partner_prefix	//대리점
//lu_dbmgr.is_data[2] = ls_refill_type		//충전유형
//lu_dbmgr.is_data[3] = ls_refilldt			//충전일자
//lu_dbmgr.is_data[4] = ls_remark				//비고


Long ll_count, ll_srow
String ls_extdays, ls_contno, ls_ref_desc, ls_pid, ls_partner_prefix, ls_customerid, ls_contractseq
Int li_return
Long ll_contractseq


//2005.03.28 basic rate, fee, extdays 추가
Dec{2} lc_basic_fee, lc_basic_rate, lc_refill_amt, lc_basic
Dec{2} lc_real_refill_amt
Long ll_extdays

String  ls_priceplan, ls_refilldt, ls_enddt, ls_basic_rate, ls_partner
Date ld_enddt, ld_refilldt, ld_real_enddt
Dec{2} lc_balance, ldc_rate, ldc_basic_fee, ldc_basic_rate, lc_sale_amt, ldc_refill_amt
Boolean lb_flag = False

String ls_prefix, ls_level_code, ls_partner_main
Long   ll_len


ii_rc = -1
ll_srow = 0

Choose Case is_caller
	Case "b1w_reg_refill%save"
			
			Do While(True)
				
				ll_srow = idw_data[1].getSelectedRow(ll_srow)
				If ll_srow = 0 Then Exit
				
				ls_contractseq = Trim(String(idw_data[1].Object.contractmst_contractseq[ll_srow]))
				
				ls_customerid = idw_data[1].Object.contractmst_customerid[ll_srow]
				If IsNull(ls_customerid) Then ls_customerid = ""
				
				//ContractMst Update
				Update contractmst
				SET  refillsum_amt = refillsum_amt + :ic_data[1], 
					  salesum_amt = salesum_amt + :ic_data[2], 
					 balance = balance + :ic_data[1],
					 last_refill_amt = :ic_data[1], 
					 last_refilldt = sysdate
				WHERE to_char(contractseq) = :ls_contractseq;
				
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title, " Update Error(P_CARDMST)" )
					rollback;
					Return
				End If
				
				Select prefixno
				Into :ls_partner_prefix
				From partnermst
				Where partner = :is_data[1];
				
				//충전 이력 Insert
				Insert Into REFILLLOG
					( REFILLSEQ, contractseq, customerid, refilldt, refill_type, 
					  refill_amt, sale_amt, remark, partner_prefix, crtdt, crt_user)
				Values 
					( SEQ_REFILLLOGSEQ.nextval, 
					  to_number(:ls_contractseq), 
					  :ls_customerid,
					  to_date(:is_data[3],'yyyy-mm-dd'), :is_data[2],
					  :ic_data[1], :ic_data[2], :is_data[4],
					  :ls_partner_prefix, sysdate, :gs_user_id);
					  
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title,  " Insert Error(P_RFILLLOG)" )
					rollback;
					Return 
				End If
				
			Loop	
			
   //2005.7.31 juede add start ======================================================
	//2005.08.08 kem Modify
	Case "b1w_reg_refill_new%save"

			//ls_eday = fs_get_control('P0', 'P110', ls_ref_desc)
			//If ls_eday = "" Then Return
			
			//iu_db.ic_data[1] = lc_refill_amt		 //충전금액
			//iu_db.ic_data[2] = lc_sale_amt	   	 //판매금액  
			//iu_db.is_data[1] = ls_partner_prefix	 //대리점
			//iu_db.is_data[2] = ls_refill_type		 //충전유형
			//iu_db.is_data[3] = ls_refilldt			 //충전일자
			//iu_db.is_data[4] = ls_remark			 //비고
			//iu_db.ic_data[3] = ic_basic_rate      //기본료율
			//iu_db.ic_data[4] = ic_basic_fee       //기본료금액
			//iu_db.il_data[1] = il_extdays         //연장일수
			//iu_db.idw_data[1] = dw_detail
			lc_real_refill_amt = 0	
			lc_basic = 0				
			
			//lc_basic_fee  = ic_data[4]
			//lc_basic_rate = ic_data[3]
			//ll_extdays    = il_data[1]
			//ls_basic_rate = String(ic_data[3])							
			
			
			Do While(True)
				
				ll_srow = idw_data[1].getSelectedRow(ll_srow)
			
				If ll_srow = 0 Then Exit
				
				lc_refill_amt = ic_data[1]
			   If IsNull(ls_basic_rate) Then 
					lc_basic_rate = 0 
				End if
				
				//2005-08-08 Modify kem  Start
				ls_partner    = is_data[1]
				ls_priceplan  = Trim(idw_data[1].Object.contractmst_priceplan[ll_srow])
				
				If ls_partner <> "" Then
					//dw_cond의 선택한 대리점 Prefix
					Select prefixno
					  Into :ls_prefix
					  From partnermst
					 Where partner = :ls_partner;
				End If
				
				//선불제 충전정책 판매금액 및 기본료 계산 후 적용
				//1. 해당 Partner, 해당 Priceplan
				Select nvl(rate,0), nvl(basic_fee,0), nvl(basic_rate,0), extdays
				  Into :ldc_rate, :ldc_basic_fee, :ldc_basic_rate, :ll_extdays
				  From refillpolicy
				 where partner = :ls_partner  
					and priceplan = :ls_priceplan 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :is_data[3]
																		and partner   = :ls_partner  
																		and priceplan = :ls_priceplan )
					and fromamt <= ABS(:lc_refill_amt)
					and nvl(toamt, ABS(:lc_refill_amt)) >= ABS(:lc_refill_amt) ;
	
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
					RollBack;
					Return
					
				ElseIf SQLCA.SQLCode  = 100 Then
					lb_flag = False
					
				Else
					lb_flag = True
					
				End If
				If lb_flag = False Then
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
					 Where prefixno = substr(:ls_prefix, 1, :ll_len);
					 
					If sqlca.sqlcode < 0 then
						f_msg_sql_err(is_title, is_caller + "Select Error(PARTNERmst)-관리대상대리점" )
						RollBack;
						Return
					End If
					
					Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0), extdays
					  Into :ldc_rate, :ldc_basic_fee, :ldc_basic_rate, :ll_extdays
					  From refillpolicy
					 where partner = :ls_partner_main  
						and priceplan = :ls_priceplan 
						and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																		  from refillpolicy 
																		 where to_char(fromdt, 'yyyymmdd') <= :is_data[3]
																			and partner   = :ls_partner_main  
																			and priceplan = :ls_priceplan )
						and fromamt <= ABS(:lc_refill_amt)
						and nvl(toamt, ABS(:lc_refill_amt)) >= ABS(:lc_refill_amt) ;
		
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
					
					Select nvl(rate,0), nvl(basic_fee,0), nvl(basic_rate,0), extdays
					  Into :ldc_rate, :ldc_basic_fee, :ldc_basic_rate, :ll_extdays
					  From refillpolicy
					 where partner = :ls_partner_main  
						and priceplan = 'ALL' 
						and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																		  from refillpolicy 
																		 where to_char(fromdt, 'yyyymmdd') <= :is_data[3]
																			and partner   = :ls_partner_main  
																			and priceplan = 'ALL' )
						and fromamt <= ABS(:lc_refill_amt)
						and nvl(toamt, ABS(:lc_refill_amt)) >= ABS(:lc_refill_amt) ;
		
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
					
					Select nvl(rate,0), nvl(basic_fee,0), nvl(basic_rate,0), extdays
					  Into :ldc_rate, :ldc_basic_fee, :ldc_basic_rate, :ll_extdays
					  From refillpolicy
					 where partner = 'ALL'  
						and priceplan = 'ALL' 
						and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																		  from refillpolicy 
																		 where to_char(fromdt, 'yyyymmdd') <= :is_data[3]
																			and partner   = 'ALL'  
																			and priceplan = 'ALL' )
						and fromamt <= ABS(:lc_refill_amt)
						and nvl(toamt, ABS(:lc_refill_amt)) >= ABS(:lc_refill_amt) ;
		
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + "SELECT refillpolicy")
						RollBack;
						Return
						
					ElseIf SQLCA.SQLCode  = 100 Then
//						lc_real_refill_amt = lc_refill_amt
//						lc_sale_amt        = lc_refill_amt
//						ll_extdays         = 0
						f_msg_usr_err(9000, is_title, is_caller + "There is no appropricate Recharge policy.")
						RollBack;
						Return
						
					Else
						lb_flag = True
						
					End If
				
				End If
				
				
				If lb_flag = True Then
					lc_real_refill_amt = lc_refill_amt
					lc_sale_amt        = lc_refill_amt
					
					//판매가 적용
					If ldc_rate = 0 Then
						lc_sale_amt = lc_refill_amt
					Else
						lc_sale_amt = lc_refill_amt * ldc_rate/100
					End If
					
					//Balance 적용가
					If ldc_basic_rate = 0 Then
						ldc_refill_amt = lc_refill_amt
					Else
						ldc_refill_amt = lc_refill_amt * (100 - ldc_basic_rate)/100
					End If
					
					If ldc_basic_fee = 0 Then
						ldc_refill_amt = ldc_refill_amt
					Else
						ldc_refill_amt = ldc_refill_amt - ldc_basic_fee
					End If
					
				End If
								
				
				lc_balance = idw_data[1].Object.contractmst_balance[ll_srow]
				lc_basic = lc_refill_amt - ldc_refill_amt
				lc_real_refill_amt = ldc_refill_amt
				
				If lc_refill_amt < 0 Then
				
					If lc_balance + lc_real_refill_amt < 0 Then 
						MessageBox(is_title, "The negative recharge amount has exceeded the remaining balance.")
						Return
					End If
				End If
				
				ls_refilldt = MidA(is_data[3], 1,4) + "-" + MidA(is_data[3], 5,2) + "-" + MidA(is_data[3], 7,2)
				ld_refilldt = Date(ls_refilldt)
				
				//2005.08.08 Modify kem
				//충전금액이 0이상일 경우만 유효기간 update
				//계산한 유효기간이 현재 유효기간 보다 클 경우만 update
				ld_real_enddt = Date(idw_data[1].Object.enddt[ll_srow])
				
				If lc_refill_amt > 0 Then
					ld_enddt = fd_date_next(ld_refilldt, ll_extdays)
					
					If ld_enddt > ld_real_enddt Then
						ls_enddt = String(ld_enddt, 'yyyymmdd')
					Else
						ls_enddt = String(ld_real_enddt,'yyyymmdd')
					End If
				Else
					ls_enddt = String(ld_real_enddt,'yyyymmdd')
				End If
								
				
				ls_contractseq = Trim(String(idw_data[1].Object.contractmst_contractseq[ll_srow]))
				
				ls_customerid = idw_data[1].Object.contractmst_customerid[ll_srow]
				If IsNull(ls_customerid) Then ls_customerid = ""
				
				//ContractMst Update
				Update contractmst
				SET   enddt           = to_date(:ls_enddt, 'yyyymmdd'),
						refillsum_amt   = refillsum_amt + :lc_refill_amt,
						balance         = balance + :lc_real_refill_amt,
						salesum_amt     = salesum_amt + :lc_sale_amt,  
						last_refill_amt = :lc_refill_amt,
						last_refilldt   = to_date(:is_data[3], 'yyyy-mm-dd'),
						remark          = :is_data[4]
				WHERE to_char(contractseq) = :ls_contractseq;	
				
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title, " Update Error(P_CARDMST)" )
					rollback;
					Return
				End If
				
				Select prefixno
				Into :ls_partner_prefix
				From partnermst
				Where partner = :is_data[1];
				
				//충전 이력 Insert
				Insert Into REFILLLOG
					( REFILLSEQ, contractseq, customerid, refilldt, refill_type, 
					  refill_amt, sale_amt, remark, partner_prefix,
					  crtdt, crt_user, basicamt)
				Values 
					( SEQ_REFILLLOGSEQ.nextval, 
					  to_number(:ls_contractseq), 
					  :ls_customerid,
					  to_date(:is_data[3],'yyyy-mm-dd'), :is_data[2],
					  :lc_refill_amt, :lc_sale_amt, :is_data[4], :ls_prefix, 
					  sysdate, :gs_user_id, :lc_basic);
					  
					  
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title,  " Insert Error(P_RFILLLOG)" )
					rollback;
					Return 
				End If
				//2005-08-08 Modify kem End

				
			Loop	
  //2005.7.31 juede add end ======================================================			
End Choose
ii_rc = 0

Return 
end subroutine

on b1u_dbmgr5.create
call super::create
end on

on b1u_dbmgr5.destroy
call super::destroy
end on

