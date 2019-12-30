$PBExportHeader$p1c_dbmgr2_v20.sru
$PBExportComments$[ohj]
forward
global type p1c_dbmgr2_v20 from u_cust_a_db
end type
end forward

global type p1c_dbmgr2_v20 from u_cust_a_db
end type
global p1c_dbmgr2_v20 p1c_dbmgr2_v20

type variables

end variables

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
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

public subroutine uf_prc_db_02 ();//선불카드 수동충전 p1w_reg_card_refill_individual_v20  ue_save_sql

String ls_ref_desc, ls_temp, ls_cnt_type, ls_amt_type, ls_extdays, ls_priceplan, ls_contno, &
       ls_pid, ls_refilldt, ls_enddt, ls_partner_prefix, ls_cnt_flag, ls_amt_flag, ls_gubun, &
		 ls_type,ls_partner_main, ls_partner_prefix_main, ls_partner, ls_model, ls_refill_place[]
String ls_limit_cnt[], ls_limit_amt[], ls_limit_type[], ls_process = 'N', ls_level_code

Long   ll_srow, ll_extdays, ll_len

Dec{2} lc_basic_fee, lc_basic_rate, lc_balance, lc_refill_amt, lc_basic = 0, lc_real_refill_amt = 0, &
       lc_limitbal_qty = 0, lc_qty = 0
		 
Date   ld_enddt, ld_refilldt

String ls_basic_rate  // basic rate 0 확인

ii_rc = -1
ll_srow = 0

Choose Case is_caller
	Case "p1w_reg_card_refill_individual_v20%save"
		//한도관리 건당 (총판;소속) y0, y1
		ls_ref_desc = ""
		ls_temp = fs_get_control("A1", "C724", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_limit_cnt[])		
		
		//한도관리 금액당 (총판;소속) y0, y0a, y1, y1a
		ls_ref_desc = ""
		ls_temp = fs_get_control("A1", "C725", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_limit_amt[])	
		
		//대리점사용한도증감유형 a1, c721   5번째 'mtt' 선불카드충전사용
		ls_ref_desc = ""
		ls_temp = fs_get_control("A1", "C721", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_limit_type[])	
		
		//관리 유형건관리 C
		ls_ref_desc = ""
		ls_cnt_type = fs_get_control("A1", "C722", ls_ref_desc)
		//관리유형 금액관리A
		ls_ref_desc = ""
		ls_amt_type = fs_get_control("A1", "C723", ls_ref_desc)
		
		//관리대상 레벨 코드 A1 C100
		ls_ref_desc = ""
		ls_level_code = fs_get_control("A1", "C100", ls_ref_desc)
		
		//충전장소 가져오기... p0, p116  3번쨰 
		ls_ref_desc = ""
		ls_temp = fs_get_control('P0', 'P116', ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_refill_place[])
		
		SELECT LENGTH(MAX(PREFIXNO))  
		  INTO :ll_len
		  FROM PARTNERMST  
		 WHERE LEVELCOD = :ls_level_code  ;
		 
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title,  " Select Error(partnermst) prefixno max length select error" )
			Return
		End If
		
		lc_basic_fee  = ic_data[4]
		lc_basic_rate = ic_data[3]
		ll_extdays    = il_data[1]
		
		//2005.07.31 juede add --start
		ls_basic_rate = String(ic_data[3])					
		If IsNull(ls_basic_rate) Then 
			lc_basic_rate=0 
		End if						
		//2005.07.31 juede add --end		
				
		Do While(True)
			
			ll_srow = idw_data[1].getSelectedRow(ll_srow)
		
			If ll_srow = 0 Then Exit
	
			ls_pid        = idw_data[1].Object.pid[ll_srow]
			ls_priceplan  = idw_data[1].Object.priceplan[ll_srow]
			ls_contno     = idw_data[1].Object.contno[ll_srow]
			lc_balance    = idw_data[1].Object.balance[ll_srow]
			lc_refill_amt = ic_data[1]
			
			If IsNull(ls_pid)        Then ls_pid        = ""	
			If IsNull(ls_contno)     Then ls_contno     = ""
			IF ISNULL(lc_basic_fee)  Then lc_basic_fee  = 0
			IF ISNULL(lc_balance)    Then lc_balance    = 0
			IF ISNULL(lc_refill_amt) Then lc_refill_amt = 0	
			IF ISNULL(ll_extdays)    Then ll_extdays = 0	
			
			lc_basic = lc_refill_amt * (lc_basic_rate/100)
			lc_basic = lc_basic + lc_basic_fee
			lc_real_refill_amt = (lc_refill_amt - lc_basic)				
			
			If lc_refill_amt < 0 Then			
				If lc_balance + lc_real_refill_amt < 0 Then 
					MessageBox(is_title, "마이너스 충전금액이 카드잔액을 초과하였습니다.")
					Return 
				End If
			End If	
			
			ls_refilldt = MidA(is_data[3], 1,4) + "-" + MidA(is_data[3], 5,2) + "-" + MidA(is_data[3], 7,2)
			ld_refilldt = Date(ls_refilldt)
			ld_enddt = fd_date_next(ld_refilldt, ll_extdays)
			ls_enddt = String(ld_enddt, 'yyyymmdd')
			
			//충전대리점 prefixno select
			Select prefixno
			  Into :ls_partner_prefix
			  From partnermst
			 Where partner = :is_data[1];
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title,  " Select Error(partnermst)" )
				Return
			End If
			
			//대리점별 가격정책관리등록 확인..  건/금액당 확인 및 소속대리점관리/총판관리 확인.. no data found 이면 한도 관리 안하는대리점 이므로 걍~ 처리
			SELECT NVL(CNT_LIMIT_FLAG, '')
			     , NVL(AMT_LIMIT_FLAG, '')
			  INTO :ls_cnt_flag
			     , :ls_amt_flag
			  FROM PARTNER_PRICEPLAN
			 WHERE PARTNER   = :is_data[1]
			   AND PRICEPLAN = :ls_priceplan  ;
				
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title,  " Select Error(PARTNER_PRICEPLAN)" )
				Return
			ElseIf SQLCA.SQLCode = 100 Then	
//				f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리 미등록상태입니다. 확인하세요. line no : " + string(ll_srow))
//				Return
				ls_process = 'N'
			Else
				ls_process = 'Y'	
			End If
			
			IF IsNull(ls_cnt_flag) THEN ls_cnt_flag = ''
			IF IsNull(ls_amt_flag) THEN ls_amt_flag = ''
			
			If ls_cnt_flag  = '' And ls_amt_flag = '' Then
				ls_process = 'N'
			End If
			
			If ls_process  = 'Y' Then
				If ls_cnt_flag <> '' And ls_amt_flag <> '' Then
					f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록이 잘못되었습니다.확인하세요. line no : " + string(ll_srow))
					Return
				ElseIf ls_cnt_flag <> '' Then
					If ls_cnt_flag     = ls_limit_cnt[1] Then
						ls_gubun  = '1'
					ElseIf ls_cnt_flag = ls_limit_cnt[2] Then
						ls_gubun  = '2'
					Else
						f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록된 코드와 sysctl1t에 코드값과 다릅니다.확인하세요. line no : " + string(ll_srow))
						Return
					End If				
					ls_type = ls_cnt_type
					
				ElseIf ls_amt_flag <> '' Then
					If ls_amt_flag = ls_limit_amt[1] Or ls_amt_flag = ls_limit_amt[2]  Then
						ls_gubun  = '1'
					ElseIf ls_amt_flag = ls_limit_amt[3] Or ls_amt_flag = ls_limit_amt[4] Then
						ls_gubun  = '2'
					Else
						f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록된 코드와 sysctl1t에 코드값과 다릅니다.확인하세요. line no : " + string(ll_srow))
						Return
					End If		
					ls_type = ls_amt_type
					
				Else
					f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록이 잘못되었습니다.확인하세요. line no : " + string(ll_srow))
					Return
				End If				
				
				//총판레벨  한도관리 일때
				If ls_gubun = '1' Then
					//총판파트너 정보 select
					Select partner
						  , prefixno
					  Into :ls_partner_main
						  , :ls_partner_prefix_main
					  From partnermst
					 Where prefixno = substr(:ls_partner_prefix, 1, :ll_len);

					If SQLCA.SQLCode < 0 Then	
						f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
						Return 
					End If
					
					//총판레벨의 사용한도잘량 select
					SELECT NVL(LIMITBAL_QTY, 0)
					  INTO :lc_limitbal_qty
					  FROM PARTNERUSED_LIMIT
					 WHERE PARTNER   = :ls_partner_main
						AND PRICEPLAN = :ls_priceplan ;
						
					If SQLCA.SQLCode < 0 Then	
						f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						
						SELECT NVL(LIMITBAL_QTY, 0)
						  INTO :lc_limitbal_qty
						  FROM PARTNERUSED_LIMIT
						 WHERE PARTNER   = :ls_partner_main
							AND PRICEPLAN = 'ALL' ;
							
						If SQLCA.SQLCode < 0 Then	
							f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
							Return
						ElseIf SQLCA.SQLCode = 100 Then								
							f_msg_usr_err(9000, is_title, "총판["+ls_partner_main+"],가격정책 [" + ls_priceplan + "] 의 사용한도 등록을 확인하세요. line no : " + string(ll_srow))
							Return
						End If
						ls_priceplan = 'ALL'
						
					End If	
					
					If ls_type = ls_cnt_type Then
						If lc_limitbal_qty < 1 Then
							f_msg_usr_err(9000, is_title, "총판["+ls_partner_main+"],가격정책 [" + ls_priceplan + "] 사용한도잔량이 부족합니다. 확인하십시오. line no : " + string(ll_srow))
							Return 
						End If
						lc_qty = 1
					Else	
						If lc_limitbal_qty < ic_data[2] Then
							f_msg_usr_err(9000, is_title, "총판["+ls_partner_main+"],가격정책 [" + ls_priceplan + "] 사용한도잔량이 부족합니다. 확인하십시오. line no : " + string(ll_srow))
							Return 
						End If
						lc_qty = ic_data[2]
					End If
					
					ls_partner        = ls_partner_main
					ls_partner_prefix = ls_partner_prefix_main
			
				ElseIf ls_gubun = '2' Then
					//소속레벨의 사용한도잘량 select
					SELECT NVL(LIMITBAL_QTY, 0)
					  INTO :lc_limitbal_qty
					  FROM PARTNERUSED_LIMIT
					 WHERE PARTNER   = :is_data[1]  //선택한 partner
						AND PRICEPLAN = :ls_priceplan ;		
						
					If SQLCA.SQLCode < 0 Then	
						f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						
						SELECT NVL(LIMITBAL_QTY, 0)
						  INTO :lc_limitbal_qty
						  FROM PARTNERUSED_LIMIT
						 WHERE PARTNER   = :is_data[1]  //선택한 partner
							AND PRICEPLAN = 'ALL';
							
						If SQLCA.SQLCode < 0 Then	
							f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
							Return	
						ElseIf SQLCA.SQLCode = 100 Then	
							f_msg_usr_err(9000, is_title, "선택대리점["+is_data[1]+"],가격정책 [" + ls_priceplan + "] 의 사용한도 등록을 확인하세요. line no -" + string(ll_srow))
							Return
						End If
						ls_priceplan = 'ALL'
					End If	
					
					If ls_type = ls_cnt_type Then //건별 한도관리
						If lc_limitbal_qty < 1 Then
							f_msg_usr_err(9000, is_title, "선택대리점["+is_data[1]+"],가격정책 [" + ls_priceplan + "] 사용한도수량이 부족합니다. 확인하십시오. line no -" + string(ll_srow))
							Return 
						End If	
						lc_qty = 1 
					Else
						If lc_limitbal_qty < ic_data[2] Then
							f_msg_usr_err(9000, is_title, "선택대리점["+is_data[1]+"],가격정책 [" + ls_priceplan + "] 사용한도금액이 부족합니다. 확인하십시오. line no -" + string(ll_srow))
							Return 
						End If	
						lc_qty = ic_data[2] 
					End If
					ls_partner = is_data[1]
					
				End If
				
				UPDATE PARTNERUSED_LIMIT 
					SET LIMITBAL_QTY = LIMITBAL_QTY - :lc_qty
//					  , QUOTA_QTY    = QUOTA_QTY    + :lc_qty
                 , USED_QTY     = NVL(USED_QTY, 0) + :lc_qty
					  , UPDTDT       = sysdate
					  , UPDT_USER    = :gs_user_id
				 WHERE PARTNER      = :ls_partner
					AND PRICEPLAN    = :ls_priceplan ;
				
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title,  " UPDATE Error(PARTNERUSED_LIMIT)" )
					Return 
				End If
				
				INSERT INTO PARTNERUSED_LIMITLOG
							 ( SEQNO
							 , PARTNER
							 , PARTNER_PREFIXNO
							 , PRICEPLAN
							 , WORKQTY
							 , WORKTYPE
	//						 , FROM_PARTNER
	//						 , TO_PARTNER
							 , LIMIT_FLAG
							 , CRT_USER
							 , CRTDT
							 , PGM_ID   )
					VALUES ( seq_partnerused_limitlog.nextval
							 , :ls_partner
							 , :ls_partner_prefix
							 , :ls_priceplan
							 , :lc_qty * -1
							 , :ls_limit_type[5]
							 , :ls_type
							 , :gs_user_id
							 , sysdate
							 , :is_data[6] );
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title,  " Insert Error(PARTNERUSED_LIMITLOG)" )
					Return 
				End If	
			End If
				
			//카드 정보 Update
			Update p_cardmst 
				Set enddt           = to_date(:ls_enddt, 'yyyymmdd')
				  , refillsum_amt   = NVL(refillsum_amt, 0) + :lc_refill_amt
				  , balance         = NVL(balance      , 0) + :lc_real_refill_amt
				  , salesum_amt     = NVL(salesum_amt  , 0) + :ic_data[2]  			//sale amt
				  , last_refill_amt = :lc_refill_amt
				  , last_refilldt   = to_date(:is_data[3], 'yyyy-mm-dd')
				  , remark          = :is_data[4]
				  , status          = :is_data[5]
			 Where pid             = :ls_pid;
			
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title, " Update Error(P_CARDMST)" )
				Return
			End If
			
			Select pricemodel
			  Into :ls_model
			  From p_cardmst
			 Where pid = :ls_pid;
			 
			//충전 이력 Insert
			Insert Into P_REFILLLOG
				( REFILLSEQ, pid, refilldt, contno, refill_type, 
				  refill_amt, sale_amt, remark, eday, partner_prefix, crtdt, crt_user,
				  pricemodel, priceplan, basicamt, refill_place)
			Values 
				( SEQ_REFILLLOG.nextval, :ls_pid, to_date(:is_data[3],'yyyy-mm-dd'), :ls_contno, :is_data[2],
				:lc_refill_amt, :ic_data[2], :is_data[4], :ll_extdays, :ls_partner_prefix, sysdate, :gs_user_id,
				:ls_model, :ls_priceplan, :lc_basic, :ls_refill_place[3]);
				
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title,  " Insert Error(P_RFILLLOG)" )
				Return 
			End If							
		
			lc_real_refill_amt = 0	
			lc_basic = 0
			
		Loop	

End choose

ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db ();//선불카드 수동충전 p1w_reg_card_refill_basic_v20  ue_save_sql

String ls_ref_desc, ls_temp, ls_cnt_type, ls_amt_type, ls_extdays, ls_priceplan, ls_contno, &
       ls_pid, ls_refilldt, ls_enddt, ls_partner_prefix, ls_cnt_flag, ls_amt_flag, ls_gubun, &
		 ls_type,ls_partner_main, ls_partner_prefix_main, ls_partner, ls_model, ls_refill_place[]
String ls_limit_cnt[], ls_limit_amt[], ls_limit_type[], ls_process = 'N', ls_level_code

Long   ll_srow, ll_extdays, ll_len

Dec{2} lc_basic_fee, lc_basic_rate, lc_balance, lc_refill_amt, lc_basic, lc_real_refill_amt, &
       lc_limitbal_qty = 0, lc_qty = 0
		 
Date   ld_enddt, ld_refilldt

String ls_basic_rate  // basic rate 0 확인

ii_rc = -1
ll_srow = 0

Choose Case is_caller
	Case "p1w_reg_card_refill_basic_v20%save"
		//한도관리 건당 (총판;소속) y0, y1
		ls_ref_desc = ""
		ls_temp = fs_get_control("A1", "C724", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_limit_cnt[])		
		
		//한도관리 금액당 (총판;소속) y0, y0a, y1, y1a
		ls_ref_desc = ""
		ls_temp = fs_get_control("A1", "C725", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_limit_amt[])	
		
		//대리점사용한도증감유형 a1, c721   5번째 'mtt' 선불카드충전사용
		ls_ref_desc = ""
		ls_temp = fs_get_control("A1", "C721", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_limit_type[])	
		
		//관리 유형건관리 C
		ls_ref_desc = ""
		ls_cnt_type = fs_get_control("A1", "C722", ls_ref_desc)
		//관리유형 금액관리A
		ls_ref_desc = ""
		ls_amt_type = fs_get_control("A1", "C723", ls_ref_desc)
		
		//관리대상 레벨 코드 A1 C100
		ls_ref_desc = ""
		ls_level_code = fs_get_control("A1", "C100", ls_ref_desc)
		
		//충전장소 가져오기... p0, p116  3번쨰 
		ls_ref_desc = ""
		ls_temp = fs_get_control('P0', 'P116', ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_refill_place[])
		
		SELECT LENGTH(MAX(PREFIXNO))  
		  INTO :ll_len
		  FROM PARTNERMST  
		 WHERE LEVELCOD = :ls_level_code  ;
		 
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title,  " Select Error(partnermst) prefixno max length select error" )
			Return
		End If
		
		lc_basic_fee  = ic_data[4]
		lc_basic_rate = ic_data[3]
		ll_extdays    = il_data[1]
		//2005.07.31 juede add --start
		ls_basic_rate = String(ic_data[3])					
		If IsNull(ls_basic_rate) Then 
			lc_basic_rate=0 
		End if						
		//2005.07.31 juede add --end		
				
		Do While(True)
			
			ll_srow = idw_data[1].getSelectedRow(ll_srow)
		
			If ll_srow = 0 Then Exit
	
			ls_pid       = idw_data[1].Object.pid[ll_srow]
			ls_priceplan = idw_data[1].Object.priceplan[ll_srow]
			ls_contno    = idw_data[1].Object.contno[ll_srow]
			
			If IsNull(ls_pid)       Then ls_pid = ""	
			If IsNull(ls_contno)    Then ls_contno = ""
			IF ISNULL(lc_basic_fee) Then lc_basic_fee = 0
			IF ISNULL(lc_basic)     Then lc_basic = 0
			lc_refill_amt = ic_data[1]		
			 
			lc_balance = idw_data[1].Object.balance[ll_srow]
			lc_basic = lc_refill_amt * (lc_basic_rate/100)
			lc_basic = lc_basic + lc_basic_fee
			lc_real_refill_amt = (lc_refill_amt - lc_basic)			
			
			If lc_refill_amt < 0 Then			
				If lc_balance + lc_real_refill_amt < 0 Then 
					MessageBox(is_title, "마이너스 충전금액이 카드잔액을 초과하였습니다.")
					Return 
				End If
			End If	
			
			ls_refilldt = MidA(is_data[3], 1,4) + "-" + MidA(is_data[3], 5,2) + "-" + MidA(is_data[3], 7,2)
			ld_refilldt = Date(ls_refilldt)
			ld_enddt = fd_date_next(ld_refilldt, ll_extdays)
			ls_enddt = String(ld_enddt, 'yyyymmdd')
			
			//충전대리점 prefixno select
			Select prefixno
			  Into :ls_partner_prefix
			  From partnermst
			 Where partner = :is_data[1];
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title,  " Select Error(partnermst)" )
				Return
			End If
			
			//대리점별 가격정책관리등록 확인..  건/금액당 확인 및 소속대리점관리/총판관리 확인.. no data found 이면 한도 관리 안하는대리점 이므로 걍~ 처리
			SELECT NVL(CNT_LIMIT_FLAG, '')
			     , NVL(AMT_LIMIT_FLAG, '')
			  INTO :ls_cnt_flag
			     , :ls_amt_flag
			  FROM PARTNER_PRICEPLAN
			 WHERE PARTNER   = :is_data[1]
			   AND PRICEPLAN = :ls_priceplan  ;
				
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title,  " Select Error(PARTNER_PRICEPLAN)" )
				Return
			ElseIf SQLCA.SQLCode = 100 Then	
//				f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리 미등록상태입니다. 확인하세요. line no : " + string(ll_srow))
//				Return
				ls_process = 'N'
			Else
				ls_process = 'Y'	
			End If
			IF IsNull(ls_cnt_flag) THEN ls_cnt_flag = ''
			IF IsNull(ls_amt_flag) THEN ls_amt_flag = ''
			
			If ls_cnt_flag  = '' And ls_amt_flag = '' Then
				ls_process = 'N'
			End If
			
			If ls_process  = 'Y' Then
				If ls_cnt_flag <> '' And ls_amt_flag <> '' Then
					f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록이 잘못되었습니다.확인하세요. line no : " + string(ll_srow))
					Return
				ElseIf ls_cnt_flag <> '' Then
					If ls_cnt_flag     = ls_limit_cnt[1] Then
						ls_gubun  = '1'
					ElseIf ls_cnt_flag = ls_limit_cnt[2] Then
						ls_gubun  = '2'
					Else
						f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록된 코드와 sysctl1t에 코드값과 다릅니다.확인하세요. line no : " + string(ll_srow))
						Return
					End If				
					ls_type = ls_cnt_type
					
				ElseIf ls_amt_flag <> '' Then
					If ls_amt_flag = ls_limit_amt[1] Or ls_amt_flag = ls_limit_amt[2]  Then
						ls_gubun  = '1'
					ElseIf ls_amt_flag = ls_limit_amt[3] Or ls_amt_flag = ls_limit_amt[4] Then
						ls_gubun  = '2'
					Else
						f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록된 코드와 sysctl1t에 코드값과 다릅니다.확인하세요. line no : " + string(ll_srow))
						Return
					End If		
					ls_type = ls_amt_type
					
				Else
					f_msg_usr_err(9000, is_title, "가격정책 [" + ls_priceplan + "]- 대리점별 가격정책관리등록이 잘못되었습니다.확인하세요. line no : " + string(ll_srow))
					Return
				End If				
				
				//총판레벨  한도관리 일때
				If ls_gubun = '1' Then
					//총판파트너 정보 select
					Select partner
						  , prefixno
					  Into :ls_partner_main
						  , :ls_partner_prefix_main
					  From partnermst
					 Where prefixno = substr(:ls_partner_prefix, 1, :ll_len);

					If SQLCA.SQLCode < 0 Then	
						f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
						Return 
					End If
					
					//총판레벨의 사용한도잘량 select
					SELECT NVL(LIMITBAL_QTY, 0)
					  INTO :lc_limitbal_qty
					  FROM PARTNERUSED_LIMIT
					 WHERE PARTNER   = :ls_partner_main
						AND PRICEPLAN = :ls_priceplan ;
						
					If SQLCA.SQLCode < 0 Then	
						f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						
						SELECT NVL(LIMITBAL_QTY, 0)
						  INTO :lc_limitbal_qty
						  FROM PARTNERUSED_LIMIT
						 WHERE PARTNER   = :ls_partner_main
							AND PRICEPLAN = 'ALL' ;
							
						If SQLCA.SQLCode < 0 Then	
							f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
							Return
						ElseIf SQLCA.SQLCode = 100 Then								
							f_msg_usr_err(9000, is_title, "총판["+ls_partner_main+"],가격정책 [" + ls_priceplan + "] 의 사용한도 등록을 확인하세요. line no : " + string(ll_srow))
							Return
						End If
						ls_priceplan = 'ALL'
						
					End If	
					
					If ls_type = ls_cnt_type Then
						If lc_limitbal_qty < 1 Then
							f_msg_usr_err(9000, is_title, "총판["+ls_partner_main+"],가격정책 [" + ls_priceplan + "] 사용한도잔량이 부족합니다. 확인하십시오. line no : " + string(ll_srow))
							Return 
						End If
						lc_qty = 1
					Else	
						If lc_limitbal_qty < ic_data[2] Then
							f_msg_usr_err(9000, is_title, "총판["+ls_partner_main+"],가격정책 [" + ls_priceplan + "] 사용한도잔량이 부족합니다. 확인하십시오. line no : " + string(ll_srow))
							Return 
						End If
						lc_qty = ic_data[2]
					End If
					
					ls_partner        = ls_partner_main
					ls_partner_prefix = ls_partner_prefix_main
			
				ElseIf ls_gubun = '2' Then
					//소속레벨의 사용한도잘량 select
					SELECT NVL(LIMITBAL_QTY, 0)
					  INTO :lc_limitbal_qty
					  FROM PARTNERUSED_LIMIT
					 WHERE PARTNER   = :is_data[1]  //선택한 partner
						AND PRICEPLAN = :ls_priceplan ;		
						
					If SQLCA.SQLCode < 0 Then	
						f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						
						SELECT NVL(LIMITBAL_QTY, 0)
						  INTO :lc_limitbal_qty
						  FROM PARTNERUSED_LIMIT
						 WHERE PARTNER   = :is_data[1]  //선택한 partner
							AND PRICEPLAN = 'ALL';
							
						If SQLCA.SQLCode < 0 Then	
							f_msg_sql_err(is_title,  " Select Error(PARTNERUSED_LIMIT)" )
							Return	
						ElseIf SQLCA.SQLCode = 100 Then	
							f_msg_usr_err(9000, is_title, "선택대리점["+is_data[1]+"],가격정책 [" + ls_priceplan + "] 의 사용한도 등록을 확인하세요. line no -" + string(ll_srow))
							Return
						End If
						ls_priceplan = 'ALL'
					End If	
					
					If ls_type = ls_cnt_type Then //건별 한도관리
						If lc_limitbal_qty < 1 Then
							f_msg_usr_err(9000, is_title, "선택대리점["+is_data[1]+"],가격정책 [" + ls_priceplan + "] 사용한도수량이 부족합니다. 확인하십시오. line no -" + string(ll_srow))
							Return 
						End If	
						lc_qty = 1 
					Else
						If lc_limitbal_qty < ic_data[2] Then
							f_msg_usr_err(9000, is_title, "선택대리점["+is_data[1]+"],가격정책 [" + ls_priceplan + "] 사용한도금액이 부족합니다. 확인하십시오. line no -" + string(ll_srow))
							Return 
						End If	
						lc_qty = ic_data[2] 
					End If
					ls_partner = is_data[1]
					
				End If
				
				UPDATE PARTNERUSED_LIMIT 
					SET LIMITBAL_QTY = LIMITBAL_QTY - :lc_qty
//					  , QUOTA_QTY    = QUOTA_QTY    + :lc_qty
                 , USED_QTY     = NVL(USED_QTY, 0) + :lc_qty
					  , UPDTDT       = sysdate
					  , UPDT_USER    = :gs_user_id
				 WHERE PARTNER      = :ls_partner
					AND PRICEPLAN    = :ls_priceplan ;
				
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title,  " UPDATE Error(PARTNERUSED_LIMIT)" )
					Return 
				End If
				
				INSERT INTO PARTNERUSED_LIMITLOG
							 ( SEQNO
							 , PARTNER
							 , PARTNER_PREFIXNO
							 , PRICEPLAN
							 , WORKQTY
							 , WORKTYPE
	//						 , FROM_PARTNER
	//						 , TO_PARTNER
							 , LIMIT_FLAG
							 , CRT_USER
							 , CRTDT
							 , PGM_ID   )
					VALUES ( seq_partnerused_limitlog.nextval
							 , :ls_partner
							 , :ls_partner_prefix
							 , :ls_priceplan
							 , :lc_qty * -1
							 , :ls_limit_type[5]
							 , :ls_type
							 , :gs_user_id
							 , sysdate
							 , :is_data[6] );
				If SQLCA.SQLCode < 0 Then	
					f_msg_sql_err(is_title,  " Insert Error(PARTNERUSED_LIMITLOG)" )
					Return 
				End If	
			End If
				
			//카드 정보 Update
			Update p_cardmst 
				Set enddt           = to_date(:ls_enddt, 'yyyymmdd')
				  , refillsum_amt   = NVL(refillsum_amt, 0) + :lc_refill_amt
				  , balance         = NVL(balance      , 0) + :lc_real_refill_amt
				  , salesum_amt     = NVL(salesum_amt  , 0) + :ic_data[2]  			//sale amt
				  , last_refill_amt = :lc_refill_amt
				  , last_refilldt   = to_date(:is_data[3], 'yyyy-mm-dd')
				  , remark          = :is_data[4]
				  , status          = :is_data[5]
			 Where pid             = :ls_pid;
			
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title, " Update Error(P_CARDMST)" )
				Return
			End If
			
			Select pricemodel
			  Into :ls_model
			  From p_cardmst
			 Where pid = :ls_pid;
			 
			//충전 이력 Insert
			Insert Into P_REFILLLOG
				( REFILLSEQ, pid, refilldt, contno, refill_type, 
				  refill_amt, sale_amt, remark, eday, partner_prefix, crtdt, crt_user,
				  pricemodel, priceplan, basicamt, refill_place)
			Values 
				( SEQ_REFILLLOG.nextval, :ls_pid, to_date(:is_data[3],'yyyy-mm-dd'), :ls_contno, :is_data[2],
				:lc_refill_amt, :ic_data[2], :is_data[4], :ll_extdays, :ls_partner_prefix, sysdate, :gs_user_id,
				:ls_model, :ls_priceplan, :lc_basic, :ls_refill_place[3]);
				
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_title,  " Insert Error(P_RFILLLOG)" )
				Return 
			End If							
		
			lc_real_refill_amt = 0	
			lc_basic = 0
			
		Loop	

End choose

ii_rc = 0
Return 
end subroutine

on p1c_dbmgr2_v20.create
call super::create
end on

on p1c_dbmgr2_v20.destroy
call super::destroy
end on

