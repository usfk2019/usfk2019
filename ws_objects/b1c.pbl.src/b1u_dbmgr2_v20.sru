$PBExportHeader$b1u_dbmgr2_v20.sru
$PBExportComments$[ohj] DBmanager
forward
global type b1u_dbmgr2_v20 from u_cust_a_db
end type
end forward

global type b1u_dbmgr2_v20 from u_cust_a_db
end type
global b1u_dbmgr2_v20 b1u_dbmgr2_v20

forward prototypes
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
end prototypes

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
String ls_reg_prefixno, ls_method[]
Dec{6} lc_baseamt
Dec{2} ldc_beforeamt, ldc_deposit, ldc_saleamt
Long   ll_orderno, ll_rows, ll_hwseq, ll_quotacnt

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
		
		//같은 order no로 두번 Insert 될 수 없다.
	   For i = 1 To UpperBound(is_data2[])
			Select count(*)
			  Into :li_cnt
			  From quota_info
			 Where to_char(orderno) = :is_data[3] 
				and customerid = :is_data[1] 
				and itemcod = :is_data2[i] 
				and rownum = 1;
			 
			If li_cnt <> 0 Then
				f_msg_usr_err(3400, is_title, "itemcod" + is_data2[i] + "분납정보 중복 error")
				Return
			End If
			
//			SELECT METHOD
//				  , ADDUNIT			
//			  INTO :ls_method[i]
//			     , :ll_addunit[i]
//			  FROM PRICEPLAN_RATE2
//			 WHERE PRICEPLAN = :is_data[6]
//				AND ITEMCOD   = :is_data2[i];
			
			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(is_title, is_caller + " Select PRICEPLAN_RATE2 Table(method)")				
				Return 
			End If	
			messagebox('', ls_method[i])
		Next
		
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
			//SELECT ADD_MONTHS(REQDT, 1)
			SELECT REQDT			
			  INTO :ld_reqdt
			  FROM REQCONF
			 WHERE CHARGEDT = :ls_bilcycle;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(REQCONF)")
				Return
			End If	
		End If
		
      //금액을 나눈다.
		ldc_mod = Mod(ic_data[1], ii_data[1])
		ldc_qty = (ic_data[1] - ldc_mod) / ii_data[1]
		
		For i = 1 To ii_data[1] 
			ldc_div[i] = ldc_qty
		Next
		ldc_div[ii_data[1]] = ldc_div[ii_data[1]] + ldc_mod //마지막 달에 많이 부과
		

		//다음달 구하기
//		ld_date[1] = ld_reqdt
//		For i = 2 To ii_data[1] 
//			ld_date[i] = fd_next_month(ld_date[i - 1], 0)
//		Next

		//ld_date[1] = ld_reqdt   //청구마감일     
//		For i = 1 To ii_data[1]
//			ls_bilfromdt  = string(ld_reqdt, 'YYYYMMDD') 
//			
//			If ls_method[i] = 'M' Then
//				SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit[i]) -1
//				  INTO :ldt_date_next
//				  FROM DUAL;
//				
//				
//				ld_date[i] = fd_next_month(ld_date[i], 0)
//		Next
//
//		lt_time = Time("00:00:00")
//		For i =1 To ii_data[1]
//			ldt_date[i] = DateTime(ld_date[i], lt_time)
//		Next
		
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

public subroutine uf_prc_db_01 ();	// "b1w_reg_svc_termprc_b_v20%save"  해지처리 v20
String ls_act_yn, ls_customerid, ls_payid, ls_enddt, ls_termdt, ls_ref_desc
String ls_orderno, ls_contractseq, ls_svccod, ls_termtype, ls_customerid_1, ls_act_status
String ls_sysdt, ls_activedt, ls_remark, ls_validkeystatus, ls_validkey, ls_pgm_id
String ls_svctype, ls_svctype_pre, ls_svctype_post, ls_svctype_post1, ls_temp, ls_result_code[]
String ls_reg_partner, ls_validkeystatus1
Long ll_cnt, ll_cnt1, ll_svccnt
//2005-12-23 khpark add
string ls_priceplan, ls_date_allow_yn

//"b1w_inq_svcorder_b%cancel"
String ls_order_status, ls_tmp, ls_serialno, ls_mv_partner, ls_status
Long   ll_hwseq
Integer li_cnt


ii_rc = -2
Choose Case is_caller
	Case "b1w_reg_svc_termprc_b_v20%save"
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
			
			If fb_reqdt_check(is_Title,ls_customerid,ls_termdt, "해지일자") Then
			Else
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("termdt")
				Return 
			End If
		
		End If

      //2005-12-23 khpark add start
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])	
      ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])		
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		
		//개통일 check 여부 
		IF b1fi_date_allow_chk_yn_v20(is_title,ls_svccod,ls_priceplan,ls_date_allow_yn) < 0 Then
			 return 
		End IF	
      //2005-12-23 khpark add end

	   If is_data[8] = "Y" Then //날짜 Check
		   IF ls_date_allow_yn = 'N' Then     //2005-12-23 khpark add (해당서비스,가격정책에 날짜 check를 허용안할 경우)
				If ls_termdt <= ls_sysdt Then 
					f_msg_usr_err(200, is_Title, "해지일자는 오늘날짜 이상이여야 합니다.")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("termdt")
					Return
				End If		
			End if
	  	End If
	
		If ls_termdt <= ls_activedt Then
			f_msg_usr_err(200, is_Title, "해지일자은 개통일보다 커야 합니다.")
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
			f_msg_usr_err(200, is_title, "과금종료일은 해지일자보다 작아야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("enddt")
			Return
		End If
		
		//개통상태코드
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

		ls_contractseq = String(idw_data[1].object.contractmst_contractseq[1])
		
		//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
		Select count(validkey)
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
	  Select count(contractseq) 
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
		
		UPDATE CONTRACTDET
			SET BIL_TODT = DECODE(NVL(BIL_TODT, ''), '', to_date(:ls_enddt, 'yyyy-mm-dd')
			  , (DECODE(sign(BIL_TODT - to_date(:ls_enddt, 'yyyy-mm-dd'))
			  , -1, BIL_TODT
			  ,  1, to_date(:ls_enddt, 'yyyy-mm-dd')
			  ,  0, BIL_TODT                                            )))
		 WHERE to_char(contractseq) = :ls_contractseq;
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTDET)")
			Rollback;
			ii_rc = -1
			Return  
		End If			 			  			 
			 
	
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
		
		//가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
		//If ii_data[1] > 0 Then   ->제외 ohj 2005.04.25
				
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
			Set    status      = :ls_validkeystatus1,
					 sale_flag   = '0',
					 activedt    = null,
					 customerid  = null,
					 orderno     = 0,
					 contractseq = 0,
					 updt_user   = :gs_user_id,
					 updtdt      = sysdate
			Where  to_char(contractseq) = :ls_contractseq;
			
		//End If
	  
	   //서비스 개통 상태 갯수 확인	 
	  Select count(contractseq) 
	  Into :ll_cnt
	  From contractmst 
	  Where customerid = :ls_customerid and status <> :is_data[2];
	  
	  If SQLCA.SQLCode < 0 Then
		  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
		  ii_rc = -1
		  Return  
	  End If
	  
	  //현 신청 상태 확인
	  Select count(orderno)
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

public subroutine uf_prc_db ();// "b1w_reg_svc_termorder_2_v20%save"  해지신청 v20

String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_pgm_id, ls_requestactive, ls_termstatus, ls_ref_desc
String ls_act_gu , ls_status, ls_enddt, ls_act_yn, ls_payid, ls_customerid_1
Datetime ldt_crtdt
Long ll_cnt, ll_row, ll_cnt1, ll_cur
Dec ldc_orderno
String ls_contractseq, ls_result_code[]
String ls_check_yn, ls_remark, ls_temp, ls_validkeystatus, ls_validkey, ls_validkeystatus1
String ls_acttype

ii_rc = -2

Choose Case is_caller
	Case "b1w_reg_svc_termorder_2_v20%save"
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
		Select count(orderno)
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
		ls_acttype = Trim(idw_data[1].object.acttype[1])
		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""		
		If IsNull(ls_remark) Then ls_remark = ""
		If IsNull(ls_acttype) Then ls_acttype = ""
		
		//Insert
		insert into svcorder
		    ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   ref_contractseq, termtype, acttype,	crt_user, crtdt, pgm_id, updt_user, updtdt, remark, order_type )
	   values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, :idt_data[1], :ls_status, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_data[4],
			   :is_data[1], :is_data[5], :ls_acttype, :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_remark, :ls_status);

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
			Select count(contractseq) 
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
			   Set status = :ls_status,
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
			
			UPDATE CONTRACTDET
			   SET BIL_TODT = DECODE(NVL(BIL_TODT, ''), '', to_date(:ls_enddt, 'yyyy-mm-dd')
				  , (DECODE(sign(BIL_TODT - to_date(:ls_enddt, 'yyyy-mm-dd'))
				  , -1, BIL_TODT
				  ,  1, to_date(:ls_enddt, 'yyyy-mm-dd')
				  ,  0, BIL_TODT                                            )))
			 WHERE to_char(contractseq) = :is_data[1];
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTDET)")
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
			  
			//가격정책별 인증Key Type에 따른 처리 추가 (2004.06.03 kem)
			//If ii_data[1] > 0 Then ->제외 ohj 2005.04.25
			
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
			Set    status      = :ls_validkeystatus1,
					 sale_flag   = '0',
					 activedt    = null,
					 customerid  = null,
					 orderno     = 0,
					 contractseq = 0,
					 updt_user   = :gs_user_id,
					 updtdt      = sysdate
			Where  to_char(contractseq) = :is_data[1];
			
			//End If	   
			  
			//서비스 개통 상태 갯수 확인	 
			Select count(contractseq) 
			Into :ll_cnt
			From contractmst 
			Where customerid = :ls_customerid and status <> :ls_status;
			
			If SQLCA.SQLCode < 0 Then
			  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
			  ii_rc = -1
			  Return  
			End If
			
			//현 신청 상태 확인
			Select count(orderno)
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

on b1u_dbmgr2_v20.create
call super::create
end on

on b1u_dbmgr2_v20.destroy
call super::destroy
end on

