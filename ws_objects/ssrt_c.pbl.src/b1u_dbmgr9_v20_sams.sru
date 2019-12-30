$PBExportHeader$b1u_dbmgr9_v20_sams.sru
$PBExportComments$[kem] DB Manager/서비스신청(장비임대포함)
forward
global type b1u_dbmgr9_v20_sams from u_cust_a_db
end type
end forward

global type b1u_dbmgr9_v20_sams from u_cust_a_db
end type
global b1u_dbmgr9_v20_sams b1u_dbmgr9_v20_sams

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();//b1w_reg_quotainfo_pop_2%insert
String ls_bilcycle, ls_unitcycle
DateTime ldt_date[]
Date   ld_reqdt, ld_date[]
Time   lt_time
Dec    ldc_mod, ldc_qty, ldc_div[]
Long   li_cnt, i

//b1w_reg_quotainfo_pop_2%hw_save
String ls_modelno, ls_serialno, ls_status, ls_ref_desc, ls_sale_flag, ls_sale_flag_hw
String ls_gubun, ls_modelnm, ls_adtype, ls_itemcod1, ls_artrcod, ls_levelcod
String ls_reg_prefixno, ls_act_status
Dec{6} lc_baseamt
Dec{2} ldc_beforeamt, ldc_deposit, ldc_saleamt
Long   ll_orderno, ll_rows, ll_hwseq, ll_quotacnt, ll_contractseq

//b1w_reg_quotainfo_pop_2%inq
String ls_sunsu, ls_deposit
Dec{6} lc_tramt, lc_beforeamt, lc_deposit


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_quotainfo_pop_2_v20%getdata"
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
		
	Case "b1w_reg_quotainfo_pop_2_v20%insert"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.ii_data[1] = li_cnt
//		//lu_dbmgr.id_data[1] = ld_startdate
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		//lu_dbmgr.is_data[6] = ls_startdate
//		lu_dbmgr.is_data[6] = is_contractseq
//		lu_dbmgr.ic_data[1] = ldc_saleamt   //총판매금액
//		lu_dbmgr.idw_data[1] = dw_detail

		
		//같은 order no로 두번 Insert 될 수 없다.
	   Select count(*)
		  Into :li_cnt
		  From quota_info
		 Where to_char(orderno) = :is_data[3] and customerid = :is_data[1] and itemcod = :is_data[2] 
		   And rownum = 1;
		
				
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
		
		//2005-11-14 kem Modify
		//청구주기가 Daily(D)인 경우 할부는 막고 일시불처리만 가능하도록 수정...
		SELECT unitcycle
		  INTO :ls_unitcycle
		  FROM reqconf
		 WHERE chargedt = :ls_bilcycle;
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(REQCONF)")
			Return
		End If
		
		If ls_unitcycle = 'D' Then
			If ii_data[1] > 0 Then
				f_msg_info(9000, is_title, "일단위 청구주기일 경우 할부는 불가능 합니다. 일시불만 처리 가능합니다.")
				Return
			End If
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
			idw_data[1].object.amt[i]         = ldc_div[i]
			idw_data[1].object.sale_amt[i]    = ldc_div[i]
			idw_data[1].object.customerid[i]  = is_data[1]
			idw_data[1].object.orderno[i]     = Long(is_data[3])
			idw_data[1].object.contractseq[i] = Long(is_data[6])
			idw_data[1].object.sale_month[i]  = DateTime(ld_date[i], lt_time)
			
			
			//Log
			idw_data[1].object.crt_user[i]   = is_data[4]
			idw_data[1].object.crtdt[i]      = fdt_get_dbserver_now()
			idw_data[1].object.pgm_id[i]     = is_data[5]
			idw_data[1].object.updt_user[i]  = is_data[4]
			idw_data[1].object.updtdt[i]     = fdt_get_dbserver_now()
			
		Next
		
	Case "b1w_reg_quotainfo_pop_2_v20%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status 판매(출고)
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.is_data[8] = is_reg_partner
//    lu_dbmgr.is_data[9] = is_svccod
//		lu_dbmgr.is_data[10] = is_contractseq
//		lu_dbmgr.idw_data[1] = idw_data[3]
//    lu_dbmgr.idw_data[2] = dw_detail2

		ls_modelno = Trim(idw_data[2].object.modelno[1])
		ls_serialno = Trim(idw_data[2].object.serialno[1])
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		 
		//개통상태코드
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)
		
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
			ll_contractseq = Long(is_data[4])
			
			//svcorder에 status update
			Update svcorder
			Set    status = decode(nvl(:ll_contractseq,0), 0, :ls_status, :ls_act_status)
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
				Set sale_flag   = :ls_sale_flag, 
					 status      = :is_data[6],
					 saledt      = sysdate,
					 customerid  = :is_data[1],
					 orderno     = :ll_orderno,
					 contractseq = :ll_contractseq,
					 sale_amt    = :lc_baseamt,
					 updt_user   = :is_data[4],
					 updtdt      = sysdate,
					 pgm_id      = :is_data[5]
				Where adseq     = :ll_hwseq;
			
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
				
				Insert Into oncepayment ( onceseq, customerid, orderno, contractseq, paydt, 
													payamt, crt_user, updt_user, crtdt, updtdt, pgm_id)
										values( seq_oncepayment.nextval, :is_data[1], :ll_orderno, sysdate, :ll_contractseq,
													:ldc_saleamt, :is_data[4], :is_data[4], sysdate, sysdate, :is_data[5] );
			
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
		
	Case "b1w_reg_quotainfo_pop_2_v20%inq"
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

public subroutine uf_prc_db_02 ();//b1w_reg_rental_pop%hw_save
String ls_modelno, ls_serialno, ls_sale_flag, ls_adtype, ls_modelnm, ls_levelcod, ls_reg_prefixno, ls_gubun
String ls_sale_flag_hw, ls_itemcod1, ls_status, ls_ref_desc, ls_adstatus, ls_act_status, ls_paydt, ls_action
String ls_pwd
Long   ll_hwseq, li_cnt, li_cnt1, ll_rows, i, ll_orderno, ll_contractseq

dec{2}  ldc_saleamt
String ls_contno
ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_admst_pop_new%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.is_data[8] = is_reg_partner
//    lu_dbmgr.is_data[9] = is_svccod
//		lu_dbmgr.is_data[10] = is_contractseq
//		lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_detail

		ls_modelno = Trim(idw_data[2].object.modelno[1])
		ls_serialno = Trim(idw_data[2].object.serialno[1])
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		 
		//개통상태코드
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)
		
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
			ll_contractseq = Long(is_data[10])
			
			
			//svcorder에 status update
			Update svcorder
			Set    status = decode(nvl(:ll_contractseq,0), 0, :ls_status, :ls_act_status)
			Where  orderno = :ll_orderno ;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
				RollBack;
				Return 
			End If
			
			//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
			SELECT ref_content INTO :ls_action FROM sysctl1t 
			WHERE module = 'U2' AND ref_no = 'A103';
			
			//장비가 여러건일 경우의 처리 때문에 로직 수정. 2003.11.05 김은미
			For ll_rows = 1 To idw_data[2].RowCount()
				ls_modelno    = Trim(idw_data[2].object.modelno[ll_rows])
				ls_serialno   = Trim(idw_data[2].object.serialno[ll_rows])
				ls_modelnm    = Trim(idw_data[2].object.modelnm[ll_rows])		//모델 명
				ldc_saleamt   = idw_data[2].object.sale_amt[ll_rows]		//판매가
				ls_contno     = Trim(idw_data[2].object.contno[ll_rows]) // Control No
				ls_adtype     = Trim(idw_data[2].object.adtype[ll_rows])
				ll_hwseq      = idw_data[2].object.adseq[ll_rows]
				ls_itemcod1   = idw_data[2].object.itemcod[ll_rows]
				ls_pwd		  = idw_data[2].object.spec_item1[ll_rows]
			
				//customer_hw insert
//				Insert Into customer_hw (hwseq, rectype, customerid, sale_flag, adtype,
//												 serialno, modelnm, orderno, crt_user, updt_user,
//												 crtdt, updtdt, pgm_id, itemcod)
//								Values ( seq_customerhwno.nextval, 'A', :is_data[1], :ls_sale_flag_hw, :ls_adtype,
//											:ls_serialno, :ls_modelnm, :ll_orderno, :is_data[4], :is_data[4],
//											sysdate, sysdate, :is_data[5], :ls_itemcod1);
//			
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_title, is_caller + " Insert Error(CUSTOMER_HW)")
//					RollBack;
//					Return 
//				End If

				//admst update	
				// sams   추가
				//ls_ad_status
				String ls_ad_status
				date	 ldt_shop_closedt

		 		ls_ad_status = fs_get_control("E1", "A103", ls_ref_desc)  // RENTAL GOODS 에서 SALING GOODS 로
				select closedt INTO :ldt_shop_closedt from shopclosemst
				 where shopid = :GS_SHOPID ;
				IF IsNull(ldt_shop_closedt) OR sqlca.sqlcode < 0 then
					ldt_shop_closedt =  date(fdt_get_dbserver_now())
				END IF

				Update	admst 
				Set 		sale_flag   = '1', 
					 		status      = :ls_ad_status,
							saledt      = :ldt_shop_closedt,
							customerid  = :is_data[1],
							orderno     = :ll_orderno,
							contractseq = :ll_contractseq,
							spec_item1  = :ls_pwd,
							updt_user   = :is_data[4],
							updtdt      = sysdate,
							sale_amt    = :ldc_saleamt,
							pgm_id      = :is_data[5]
				Where    adseq       = :ll_hwseq ;
		
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
				End If
			
				//ad_salelog insert	
				Insert Into ad_salelog ( saleseq, 
												saledt, 
												SHOPID,
												saleqty,
												sale_amt,
												sale_sum,
												modelno,
												contno,
												crt_user, crtdt, pgm_id)
								Values( seq_ad_salelog.nextval, 
											:ldt_shop_closedt,
											:GS_SHOPID,
											1, 
											:ldc_saleamt , 
											:ldc_saleamt, 
											:ls_modelno, 
											:ls_contno,
											:gs_user_id,
 											sysdate,
											:is_data[5]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(AD_SALELOG)")
					RollBack;
					Return 
				End If
				
				//장비이력(ADMSTLOG_NEW) Table에 정보저장
				INSERT INTO ADMSTLOG_NEW		
					( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
					  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
					  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
					  PGM_ID, IDATE )
				SELECT ADSEQ, seq_admstlog.nextval, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
						 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
						 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
						 :is_data[5], IDATE
				FROM   ADMST
				WHERE  ADSEQ = :ll_hwseq;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG_NEW)")
					RollBack;
					Return 
				End If						

				ls_modelno  = ""
				ls_serialno = ""
				ls_modelnm  = ""
				ls_adtype   = ""
				ll_hwseq    = 0
				ls_itemcod1  = ""
				ls_paydt    = "00000000"
			Next
		
		End IF		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db ();//b1w_reg_rental_pop%hw_save
String ls_modelno, ls_serialno, ls_sale_flag, ls_adtype, ls_modelnm, ls_levelcod, ls_reg_prefixno, ls_gubun
String ls_sale_flag_hw, ls_itemcod1, ls_status, ls_ref_desc, ls_adstatus, ls_act_status, ls_paydt, ls_action
Long   ll_hwseq, li_cnt, li_cnt1, ll_rows, i, ll_orderno, ll_contractseq

dec{2}  ldc_saleamt
String ls_contno
ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_rental_pop_v20_sams%getdata"
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
		
	Case "b1w_reg_rental_pop_v20_sams%hw_save"
//		lu_dbmgr.is_data[1] = is_customerid
//		lu_dbmgr.is_data[2] = is_main_itemcod
//		lu_dbmgr.is_data[3] = is_orderno
//		lu_dbmgr.is_data[4] = gs_user_id
//		lu_dbmgr.is_data[5] = is_pgmid
//		lu_dbmgr.is_data[6] = is_status
//		lu_dbmgr.is_data[7] = is_action
//		lu_dbmgr.is_data[8] = is_reg_partner
//    lu_dbmgr.is_data[9] = is_svccod
//		lu_dbmgr.is_data[10] = is_contractseq
//		lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_detail

		ls_modelno = Trim(idw_data[2].object.modelno[1])
		ls_serialno = Trim(idw_data[2].object.serialno[1])
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		 
		//개통상태코드
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)
		
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
			ll_contractseq = Long(is_data[10])
			
			
			//svcorder에 status update
			Update svcorder
			Set    status = decode(nvl(:ll_contractseq,0), 0, :ls_status, :ls_act_status)
			Where  orderno = :ll_orderno ;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SVCORDER)")
				RollBack;
				Return 
			End If
			
			//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
			SELECT ref_content INTO :ls_action FROM sysctl1t 
			WHERE module = 'U2' AND ref_no = 'A103';
			
			//장비가 여러건일 경우의 처리 때문에 로직 수정. 2003.11.05 김은미
			For ll_rows = 1 To idw_data[2].RowCount()
				ls_modelno    = Trim(idw_data[2].object.modelno[ll_rows])
				ls_serialno   = Trim(idw_data[2].object.serialno[ll_rows])
				ls_modelnm    = Trim(idw_data[2].object.modelnm[ll_rows])		//모델 명
				ldc_saleamt   = idw_data[2].object.sale_amt[ll_rows]		//판매가
				ls_contno     = Trim(idw_data[2].object.contno[ll_rows]) // Control No
				ls_adtype     = Trim(idw_data[2].object.adtype[ll_rows])
				ll_hwseq      = idw_data[2].object.adseq[ll_rows]
				ls_itemcod1   = idw_data[2].object.itemcod[ll_rows]
			
				//customer_hw insert
//				Insert Into customer_hw (hwseq, rectype, customerid, sale_flag, adtype,
//												 serialno, modelnm, orderno, crt_user, updt_user,
//												 crtdt, updtdt, pgm_id, itemcod)
//								Values ( seq_customerhwno.nextval, 'A', :is_data[1], :ls_sale_flag_hw, :ls_adtype,
//											:ls_serialno, :ls_modelnm, :ll_orderno, :is_data[4], :is_data[4],
//											sysdate, sysdate, :is_data[5], :ls_itemcod1);
//			
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_title, is_caller + " Insert Error(CUSTOMER_HW)")
//					RollBack;
//					Return 
//				End If

				//admst update	
				// sams   추가
				//ls_ad_status
				String ls_ad_status
				date	 ldt_shop_closedt
//		 		ls_ad_status = fs_get_control("E1", "A101", ls_ref_desc)
		 		ls_ad_status = fs_get_control("E1", "A103", ls_ref_desc)  // RENTAL GOODS 에서 SALING GOODS 로
				select closedt INTO :ldt_shop_closedt from shopclosemst
				 where shopid = :GS_SHOPID ;
				IF IsNull(ldt_shop_closedt) OR sqlca.sqlcode < 0 then
					ldt_shop_closedt =  date(fdt_get_dbserver_now())
				END IF

				Update	admst 
				Set 		sale_flag   = '1', 
					 		status      = :ls_ad_status,
							saledt      = :ldt_shop_closedt,
							customerid  = :is_data[1],
							orderno     = :ll_orderno,
							contractseq = :ll_contractseq,
							updt_user   = :is_data[4],
							updtdt      = sysdate,
							sale_amt    = :ldc_saleamt,
							pgm_id      = :is_data[5]
				Where    adseq       = :ll_hwseq ;
		
			
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

				//ad_salelog insert	
				Insert Into ad_salelog ( saleseq, 
												saledt, 
												SHOPID,
												saleqty,
												sale_amt,
												sale_sum,
												modelno,
												contno,
												crt_user, crtdt, pgm_id)
								Values( seq_ad_salelog.nextval, 
											:ldt_shop_closedt,
											:GS_SHOPID,
											1, 
											:ldc_saleamt , 
											:ldc_saleamt, 
											:ls_modelno, 
											:ls_contno,
											:gs_user_id,
 											sysdate,
											:is_data[5]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(AD_SALELOG)")
					RollBack;
					Return 
				End If
				
				//장비이력(ADMSTLOG_NEW) Table에 정보저장
				INSERT INTO ADMSTLOG_NEW		
					( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
					  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
					  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
					  PGM_ID, IDATE )
				SELECT ADSEQ, seq_admstlog.nextval, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
						 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
						 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
						 :is_data[5], IDATE
				FROM   ADMST
				WHERE  ADSEQ = :ll_hwseq;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG_NEW)")
					RollBack;
					Return 
				End If						
				
				
//				//DAILYPAYMENT 에 REMARK 에 CONT.NO 기록.2010-05-31
//				SELECT NVL(MAX(TO_CHAR(PAYDT, 'YYYYMMDD')), '00000000') INTO :ls_paydt
//				FROM   DAILYPAYMENT
//				WHERE  CUSTOMERID = :is_data[1]
//				AND    ITEMCOD = :ls_itemcod1;
//				
//				IF ls_paydt <> "00000000" THEN
//					
//					UPDATE DAILYPAYMENT 
//					SET    REMARK = :ls_contno,
//							 UPDT_USER = :gs_user_id,
//							 UPDTDT = SYSDATE
//					WHERE  CUSTOMERID = :is_data[1]
//					AND    ITEMCOD = :ls_itemcod1
//					AND    PAYDT = TO_DATE(:ls_paydt, 'yyyymmdd')
//					AND	 PAYSEQ IN ( SELECT MAX(PAYSEQ)
//											 FROM   DAILYPAYMENT
//											 WHERE  CUSTOMERID = :is_data[1]
//											 AND    ITEMCOD = :ls_itemcod1
//											 AND    PAYDT = TO_DATE(:ls_paydt, 'YYYYMMDD'));
//					
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, is_caller + " Update Error(DAILYPAYMENT)")
//						RollBack;
//						Return 
//					End If
//				END IF								
			
				ls_modelno  = ""
				ls_serialno = ""
				ls_modelnm  = ""
				ls_adtype   = ""
				ll_hwseq    = 0
				ls_itemcod1  = ""
				ls_paydt    = "00000000"
			Next
		
		End IF
		
	Case "b1w_reg_rental_pop_v20%inq"
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

on b1u_dbmgr9_v20_sams.create
call super::create
end on

on b1u_dbmgr9_v20_sams.destroy
call super::destroy
end on

