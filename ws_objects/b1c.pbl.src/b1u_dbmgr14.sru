$PBExportHeader$b1u_dbmgr14.sru
$PBExportComments$[kem] 서비스개통신청(SSW)
forward
global type b1u_dbmgr14 from u_cust_a_db
end type
end forward

global type b1u_dbmgr14 from u_cust_a_db
end type
global b1u_dbmgr14 b1u_dbmgr14

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();String ls_ref_desc, ls_status, ls_customerid, ls_cus_status, ls_activedt, ls_svccod, ls_priceplan
String ls_prmtype, ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_partner, ls_orderdt
String ls_requestdt, ls_bil_fromdt, ls_settle_partner, ls_contractno, ls_reg_prefixno, ls_remark
String ls_pgm_id, ls_term_status, ls_enter_status, ls_dlvstat, ls_validkey, ls_todt_tmp, ls_svctype
String ls_levelcod, ls_temp
Datetime ldt_crtdt
Long   ll_row, ll_cnt
Dec{0} ldc_contractseq, ldc_orderno
String ls_hotbillflag, ls_payid


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actprc_ssw%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_ssw%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//2004.12.08. khpark modify start
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
		   f_msg_usr_err(201, is_Title, "Customer that is in Hotbill porcess.")
		   ii_rc = -1
		   return
		End If
		//2004.12.08. khpark modify end		
		
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
		ls_status           = fs_get_control("B0","P223", ls_ref_desc)
		ls_customerid       = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status       = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt         = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod           = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan        = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype          = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner      = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner     = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner   = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner          = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt          = String(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt        = String(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt       = String(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno       = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno     = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark           = Trim(idw_data[1].object.remark[1])
		
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
		Set    contractseq = :ldc_contractseq,
			    updt_user   = :gs_user_id,
			    updtdt      = :ldt_crtdt
		Where  orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If
		
		//장비금액을 할부로 안하고 일시불로 처리했을 경우 oncepayment Update
		Update oncepayment
		Set    contractseq = :ldc_contractseq,
			    updt_user   = :gs_user_id,
			    updtdt      = :ldt_crtdt
		Where  orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update ONCEPAYMENT Table")				
			Return 
		End If
		
		//배송대기(개통완료)
		ls_dlvstat = fs_get_control("E1", "A410", ls_ref_desc)
		
		Update admst
		Set    contractseq = :ldc_contractseq,
		       dlvstat     = :ls_dlvstat
		Where  orderno = :ldc_orderno;
		
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
				f_msg_usr_err(9000, is_title, "Starting date and Ending date is overlapped for authentication key[" + ls_validkey+ "]~r~n~r~nTry again!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check;
		
		Update validinfo
		Set    fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			    use_yn = 'Y',												//사용여부
			    status = :ls_status,
			    contractseq = :ldc_contractseq,
			    svccod = :ls_svccod,
       	    priceplan = :ls_priceplan,
			    updt_user = :gs_user_id,
			    updtdt = :ldt_crtdt,
			    pgm_id = :ls_pgm_id
		Where  orderno = :ldc_orderno;
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
			 
		f_msg_info(9000, is_title, "It is registered " + String(ldc_contractseq) + "in contract seq")
		
		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_03 ();
//"b1w_validkey_update_popup_1_cl_ssw%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_todt, ls_new_todt_cf
String ls_d_ent_name, ls_d_domain_id, ls_d_comp_id, ls_d_ip_auth_type, ls_d_capa_idx
String ls_d_ent_type, ls_ora_ip_addr, ls_d_ip_port, ls_d_diallimit
String ls_d_subsbarr, ls_d_linecat, ls_d_linepri, ls_d_relcond, ls_d_cgchacat, ls_d_cdchacat
String ls_d_netcodeidx, ls_ex_local_id, ls_sys_langtype, ls_ref_desc, ls_svctype
String ls_sysdt
Long ll_cnt, ll_d_opt_bit_map

//"b1w_validkey_update_popup_2_cl%ue_save"
String ls_act_status
//String ls_customernm, ls_svccod, ls_sys_langtype, ls_langtype, ls_svctype
decimal ldc_svcorderno
//공통 
//String ls_sysdt, ls_cid, ls_validkeyloc

ii_rc = -1

Choose Case is_caller
	Case "b1w_validkey_update_popup_1_cl_ssw%ue_save"		//SSW
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_cl_ssw%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey
//		lu_dbmgr.is_data[3]  = is_pgm_id
//		lu_dbmgr.is_data[4]  = is_xener_svc         //제너서비스여부

		idw_data[1].accepttext()
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
		
		
		ls_d_ent_name     = idw_data[1].Object.new_d_ent_name[1]
		ls_d_domain_id    = idw_data[1].Object.new_d_domain_id[1]
		ls_d_comp_id      = idw_data[1].Object.new_d_comp_id[1]
		ls_d_ip_auth_type = idw_data[1].Object.new_d_ip_auth_type[1]
		ls_d_capa_idx     = idw_data[1].Object.new_d_capa_idx[1]
		ll_d_opt_bit_map  = idw_data[1].Object.new_d_opt_bit_map[1]
		ls_d_ent_type     = idw_data[1].Object.new_d_ent_type[1]
		ls_ora_ip_addr    = idw_data[1].Object.new_ora_ip_addr[1]
		ls_d_ip_port      = idw_data[1].Object.new_d_ip_port[1]
		ls_d_diallimit    = idw_data[1].Object.new_d_diallimit[1]
		ls_d_subsbarr     = idw_data[1].Object.new_d_subsbarr[1]
		ls_d_linecat      = idw_data[1].Object.new_d_linecat[1]
		ls_d_linepri      = idw_data[1].Object.new_d_linepri[1]
		ls_d_relcond      = idw_data[1].Object.new_d_relcond[1]
		ls_d_cgchacat     = idw_data[1].Object.new_d_cgchacat[1]
		ls_d_cdchacat     = idw_data[1].Object.new_d_cdchacat[1]
		ls_d_netcodeidx   = idw_data[1].Object.new_d_netcodeidx[1]
		ls_ex_local_id    = idw_data[1].Object.new_ex_local_id[1]
		
		
		ls_validkey       = idw_data[1].object.new_validkey[1]
		ls_fromdt_1       = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt         = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt       = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf    = ls_new_todt
		ls_svctype        = idw_data[1].Object.svctype[1]
		
		
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
			ls_new_todt = ""
			ls_new_todt_cf = '99991231'
		End if
		If IsNull(ls_svctype) Then ls_svctype = ""
		
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "Authorization code")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		
		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "Effective-From")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		If ls_fromdt <= ls_sysdt Then
			f_msg_usr_err(210, is_Title, "Effective-From date should be later than today.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If		
		
		//xener IPPhone 서비스코드는 인증방법기타 check 
		If is_data[4] = 'Y' Then

//			If ls_gkid = "" Then
//				f_msg_usr_err(200, is_Title, "GKID")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("new_gkid")
//				Return 
//			End If
		
//			If ls_auth_method = "" Then
//				f_msg_usr_err(200, is_Title, "Method of authentication")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("new_authmethod")
//				Return
//			End If		
//			
//			If left(ls_auth_method,1) = 'S' Then
//				If ls_ip_address = "" Then
//					f_msg_usr_err(200, is_Title, "IP ADDRESS")
//					idw_data[1].SetFocus()
//					idw_data[1].SetColumn("ip_address")
//					Return
//				End If		
//			End if
			
//			If mid(ls_auth_method,7,1) <> 'E' Then
//				If ls_h323id = "" Then
//					f_msg_usr_err(200, is_Title, "H323ID")
//					idw_data[1].SetFocus()
//					idw_data[1].SetColumn("h323id")
//					Return 
//				End If		
//			End If
		End IF
		
		
		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		  from validinfo
		 where validkey = :ls_validkey
		   and to_char(fromdt,'yyyymmdd') = :ls_fromdt 
			and svctype = :ls_svctype;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
	
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "Starting date is overlapped for authentication key[" + ls_validkey + "]~r~n~r~nTry again!!")
			return 
		End if
		
		//변경전 Key = 변경후 Key 날짜 중복check 루틴 뺀다.(update적용종료일되므로)
		If is_data[2] <> ls_validkey Then
			
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			  from validinfo
			 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
						 to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
					   (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and validkey = :ls_validkey 
				and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "Starting date and Ending date is overlapped for authentication key[" + ls_validkey + "]~r~n~r~nTry again!!")
				return 
			End if
		End IF
	
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
		
		Update validinfo
		   Set use_yn    = 'N',
		       todt      = to_date(:ls_fromdt,'yyyy-mm-dd'),
			    updt_user = :gs_user_id,
		       updtdt    = sysdate,
			    pgm_id    = :is_data[3]
		 Where validkey   = :is_data[2]
		   And to_char(fromdt,'yyyymmdd') = :is_data[1] 
		   And svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
			Return 
		End If

		//Insert
		insert into validinfo
		    	( validkey, fromdt, todt, status,
				  use_yn, vpassword, validitem, gkid, 
				  customerid, svccod, svctype, priceplan, 
				  orderno, contractseq, validitem1, validitem2, 
				  validitem3, auth_method, validkey_loc, crt_user, 
				  crtdt, pgm_id, updt_user, updtdt, langtype,
				  protocol_type, d_ent_name, d_domain_id, d_comp_id,
				  d_ip_auth_type, d_capa_idx, d_opt_bit_map, d_ent_type,
				  d_id_type, d_h323id, d_full_e164_auth, d_chk_subs_busy,
				  d_lwrrq_supp, d_ttl, d_ttl_to_cnt, d_soirr_supp,
				  d_irr_freq, d_irr_to_cnt, d_relcall_in_rrq, ora_ip_addr,
				  d_ip_port, d_e164, d_diallimit, d_subsbarr, 
				  d_linecat, d_linepri, d_relcond, d_cgchacat,
				  d_cdchacat, d_netcodeidx, d_numporttype, ex_local_id )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), status, 
		         'Y', vpassword, validitem, gkid, 
					customerid,	svccod, svctype, priceplan,
				   orderno, contractseq, validitem1, validitem2, 
					validitem3, auth_method, validkey_loc, :gs_user_id, 
					sysdate, :is_data[3], :gs_user_id, sysdate, langtype,
					protocol_type, :ls_d_ent_name, :ls_d_domain_id, :ls_d_comp_id,
					:ls_d_ip_auth_type, :ls_d_ent_name, :ll_d_opt_bit_map, :ls_d_ent_type,
					d_id_type, d_h323id, d_full_e164_auth, d_chk_subs_busy,
					d_lwrrq_supp, d_ttl, d_ttl_to_cnt, d_soirr_supp,
					d_irr_freq, d_irr_to_cnt, d_relcall_in_rrq, :ls_ora_ip_addr,
					:ls_d_ip_port, :ls_validkey, :ls_d_diallimit, :ls_d_subsbarr,
					:ls_d_linecat, :ls_d_linepri, :ls_d_relcond, :ls_d_cgchacat,
					:ls_d_cdchacat, :ls_d_netcodeidx, d_numporttype, :ls_ex_local_id 
		    from validinfo
		   where validkey = :is_data[2]
		     and to_char(fromdt,'yyyymmdd') = :is_data[1] 
			  and svctype = :ls_svctype;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "Authorization Code["+ ls_validkey + "]Change")
		
		commit;
		
	Case "b1w_validkey_update_popup_2_cl%ue_save"			//Com-N-Life
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_cl%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_itemcod
//		lu_dbmgr.is_data[2]  = is_contractseq
//	    lu_dbmgr.is_data[3]  = is_svctype
//		lu_dbmgr.is_data[4]  = is_pgm_id
//		lu_dbmgr.is_data[5]  = is_xener_svc     //제너서비스여부('Y'/'N')
//      lu_dbmgr.is_data[6]  = is_status         //개통상태 코드

		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
	
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
			ls_new_todt = ""
			ls_new_todt_cf = '99991231'
		End if
		

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "Authorization Code")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "Effective-From")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		If ls_fromdt < ls_sysdt Then
			f_msg_usr_err(210, is_Title, "Effective-From date should be later than today.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If		
		
		//xener service IPPhone 일때는 인증방법  Check ...
		If is_data[5] = 'Y' Then
			
//			If ls_gkid = "" Then
//				f_msg_usr_err(200, is_Title, "GKID")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("new_gkid")
//				Return 
//			End If
			
			
			
		End IF
		
		
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(*)
		  into :ll_cnt
		  from validinfo
		 where ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
					 to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
				  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and validkey = :ls_validkey and svctype = :is_data[3];
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "Starting date and Ending date is overlapped for authentication key[" + ls_validkey + "]~r~n~r~nTry again!!")
			Return 
		End if
	
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
			  pgm_id, updt_user, updtdt, langtype )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', vpassword,
				customerid, svccod,
				:is_data[3], priceplan,
				:ldc_svcorderno, contractseq, gkid,
				validitem1, validitem2, validitem3, auth_method,
				validkeyloc, :gs_user_id, sysdate, :is_data[4], :gs_user_id, sysdate, langtype
		   from contractmst
		  where to_char(contractseq) = :is_data[2];

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "Add Authorization Code["+ ls_validkey + "]")
		
		commit;
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose
//
ii_rc = 0
end subroutine

public subroutine uf_prc_db_02 ();/*-------------------------------------------------------------------------
	name	: uf_prc_db_02()
	desc.	: Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2005.03.25
	programer : Kim Eun Mi (kem)
--------------------------------------------------------------------------*/	

//"b1w_reg_validkey_update%ue_change"
String ls_svctype, ls_status, ls_fromdt, ls_use_yn, ls_svccod

//"b1w_reg_validkey_update%ue_add"
Long ll_cnt

ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_validkey_update%ue_change"		//통합빌링 & xener
//		iu_check.is_caller = "b1w_reg_validkey_update%ue_change"
//		iu_check.is_title = This.Title
//		iu_check.is_data[1] = ls_validkey     		//인증KEY
		//iu_check.is_data[2] = ls_svctype    //해당 인증KEY의 svctype
		//iu_check.is_data[3] = ls_status     //해당 인증KEY의 status
		//iu_check.is_data[4] = ls_fromdt     //해당 인증KEY의 Fromdt
		//iu_check.is_data[5] = ls_user_yn    //해당 인증KEY의 사용여부
		//iu_check.is_data[6] = ls_svccod     //해당 인증KEY의 svccod
//		iu_check.is_data[7] = ls_contractseq  
      
	    
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
			f_msg_info(9000, is_title, "No Authorization Code")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("validkey")			
			ii_rc = -1
			Return 	
		End If
	
	Case "b1w_reg_validkey_update%ue_add"		
//		iu_check.is_caller = "b1w_reg_validkey_update%ue_add" 	//통합빌링 & xener
//		iu_check.is_title = This.Title
//		iu_check.idw_data[1] = dw_cond
//		iu_check.is_data[1] = ls_contractseq  //계약번호
        //iu_check.is_data[2] = itemcod       //해당 계약번호에 itemcod
		//iu_check.is_data[3] = ls_svctype    //해당 계약번호에 svctype
		//iu_check.is_data[4] = ls_status     //해당 계약번호에 status
		//iu_check.is_data[5] = priceplan     //해당 계약번호에 priceplan
		//iu_check.is_data[6] = ls_svccod     //해당 계약번호에 svccod		
		
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
			f_msg_info(9000, is_title, "Contract SEQ[" +is_data[1] +"]is not exist  number Contractmaster")	
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
			f_msg_info(9000, is_title, "Contract SEQ[" +is_data[1] +"]is not exist  Price Plan")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("contractseq")			
			ii_rc = -1
			Return 	
		End If

		
End Choose		

ii_rc = 0 
end subroutine

public subroutine uf_prc_db ();//b1w_reg_svc_actorder_5%save
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_orderdt, ls_requestdt
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_partner
String ls_status, ls_ref_desc, ls_userid, ls_pgm_id, ls_cid[]
String ls_itemcod[], ls_check[], ls_name[], ls_reg_prefix
String ls_contractno, ls_enter_status, ls_act_status, ls_term_status, ls_customerm, ls_valid_item            
string ls_validkey[], ls_vpasswd[], ls_use_yn, ls_gkid, ls_auth_method, ls_h323id, ls_ip_address, ls_result  
string ls_validkey_loc[], ls_coid, ls_temp, ls_result_code[], ls_quota_yn, ls_langtype[]
Long ll_orderno, ll_cnt, ll_contractseq, ll_validseq
Long i, j, k, ll_row, ll_long, ll_result_sec, ll_priority
Time lt_now_time, lt_after_time
String ls_n_auth_method[], ls_n_validitem3[], ls_n_validitem2[], ls_n_langtype[], ls_chk_yn, ls_n_validitem1[]
String ls_vpricecod, ls_acttype, ls_hopenum, ls_remark, ls_quota_status, ls_validkeystatus
String ls_validkey_msg //인증Key MSG

//SSW 
String ls_pro_type, ls_d_ent_name, ls_d_domain_id, ls_d_comp_id, ls_d_ip_auth_type
String ls_d_ent_type, ls_ora_ip_addr, ls_d_ip_port, ls_d_capa_idx

LONG   LL_SEQ, LL_D_OPT_BIT_MAP, LL_EX_CODE_A[], LL_D_TTL_TO_CNT, LL_D_IRR_FREQ, LL_D_IRR_TO_CNT, LL_EX_CODE, ll_ex_act_a[]	
STRING LS_D_ID_TYPE[], LS_ORA_STATIC_IP_ADDR[], LS_D_STATIC_IP_PORT[], LS_D_H323ID[], LS_D_FULL_E164_AUTH[], LS_D_CHK_SUBS_BUSY[]	
STRING LS_D_LWRRQ_SUPP, LS_D_TTL, LS_D_SOIRR_SUPP, LS_D_RELCALL_IN_RRQ	
STRING LS_D_E164[], LS_D_DIALLIMIT[], LS_D_SUBSBARR[], LS_D_LINECAT[], LS_D_LINEPRI[], LS_D_RELCOND[]
STRING LS_D_CGCHACAT[], LS_D_CDCHACAT[], LS_D_NETCODEIDX[], LS_D_NUMPORTTYPE[], LS_EX_LOCAL_ID[], LS_SVC[], LS_EX_ODN[], LS_EX_TDN[]	
STRING LS_EX_KEY[], LS_EX_MODE[], LS_EX_TIME[], LS_LS_EX_VSN[], LS_D_DN, LS_D_CDN, LS_D_START_DATE, LS_D_EXPIRY_DATE, LS_SVC_NAME
STRING LS_ADDSVC[], ls_protocol_mgcp, ls_protocol_sip

String ls_action_type_a, ls_addsvc_code_a[], ls_protocol_type_a, ls_itemcod_a[]
String LS_D_E164_A[], LS_SVC_A[], LS_EX_ODN_A[], LS_EX_TDN_A[]
String LS_EX_KEY_A[], LS_EX_MODE_A[], LS_EX_TIME_A[], LS_EX_VSN_A[] 

String ls_protocol_result[], ls_action_result[], ls_d_call_type

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_svc_actorder_ssw%save"    //장비임대 포함 수정, 입중계출중계서비스추가, SSW용
//		lu_dbmgr.is_title    = Title
//		lu_dbmgr.idw_data[1] = dw_cond
//		lu_dbmgr.idw_data[2] = dw_detail2                //품목
//		lu_dbmgr.idw_data[3] = dw_detail			     //인증KEY
//		lu_dbmgr.is_data[1]  = gs_user_id
//		lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
//		lu_dbmgr.is_data[3]  = is_act_gu                 //개통처리 check
//		lu_dbmgr.is_data[4]  = is_cus_status             //고객상태
//		lu_dbmgr.is_data[5]  = is_svctype                //svctype
//		lu_dbmgr.is_data[6]  = string(il_validkey_cnt)   //인증KEY갯수
//		lu_dbmgr.is_data[7]  = is_type         			 //MVNO svc type?
//		lu_dbmgr.is_data[8]  = is_xener_svc    			 //xener 서비스여부  khpark modify 2004.04.09
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
		
		//MGCP, SIP  MSS TYPE
		//MGCP --> ls_protocol_result[1]
		//SIP --> ls_protocol_result[2]
		ls_ref_desc = ""
		ls_temp = fs_get_control("X1","A100", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";" , ls_protocol_result[])
		ls_protocol_mgcp = ls_protocol_result[1]
		ls_protocol_sip  = ls_protocol_result[2]

      If is_data[9] = 'Y' Then
			 ls_validkey_msg = 'Route-No.'
		Else
			 ls_validkey_msg = 'Authorization KEY'
		End IF
		
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
		//ls_langtype 	 = Trim(idw_data[1].object.langtype[1])
		ls_userid       = is_data[1]
		ls_pgm_id       = is_data[2]
		
		//protocol type 
		ls_pro_type     = Trim(idw_data[1].object.protocol_type[1])
		
		ls_d_ent_name     = Trim(idw_data[1].object.d_ent_name[1]) 
		ls_d_domain_id    = Trim(idw_data[1].object.d_domain_id[1])
		ls_d_comp_id      = Trim(idw_data[1].object.d_comp_id[1])
		ls_d_ip_auth_type = Trim(idw_data[1].object.d_ip_auth_type[1])
		ls_d_ent_type     = Trim(idw_data[1].object.d_ent_type[1])
		ls_ora_ip_addr    = Trim(idw_data[1].object.ora_ip_addr[1])
		ls_d_ip_port      = Trim(idw_data[1].object.d_ip_port[1])
		ls_d_capa_idx     = Trim(idw_data[1].object.d_capa_idx[1])
		ll_d_opt_bit_map  = idw_data[1].object.d_opt_bit_map[1]
		ls_d_call_type    = Trim(idw_data[1].Object.call_type[1])
		
		If IsNull(ls_pro_type) Then ls_pro_type = ""
		If IsNull(ls_d_ent_name) Then ls_d_ent_name = ""
		If IsNull(ls_d_comp_id) Then ls_d_comp_id = ""
		If IsNull(ls_d_ip_auth_type) Then ls_d_ip_auth_type = ""
		If IsNull(ls_d_domain_id) Then ls_d_domain_id = ""
		If IsNull(ls_d_capa_idx) Then ls_d_capa_idx = ""
		If IsNull(ls_d_ent_type) Then ls_d_ent_type = ""
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""
		If IsNull(ls_d_call_type) Then ls_d_call_type = ""
		
		
		If is_data[8] = 'Y' Then
			//entity 필수사항 체크
			If ls_pro_type = "" Then
				f_msg_info(200, is_title, "PROTOCOL TYPE")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("PROTOCOL_TYPE")
				ii_rc = -3
				Return
			End If
			
			If ls_d_ent_name = "" Then
				f_msg_info(200, is_title, "ENTITY NAME")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("d_ent_name")
				ii_rc = -3
				Return	
			End If
			
			If ls_d_comp_id = "" Then
				f_msg_info(200, is_title, "CALL SERVER ID")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("d_comp_id")
				ii_rc = -3
				Return	
			End If
			
			If ls_d_ip_auth_type = "" Then
				f_msg_info(200, is_title, "IP Authentication")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("d_ip_auth_type")
				ii_rc = -3
				Return
			Else
				//STATIC IP ADDR, PORT 체크
			End If
		End If
		
		
		IF ls_pro_type = ls_protocol_result[1] THEN

			If ls_d_domain_id = "" Then
				f_msg_info(200, is_title, "DOMAIN ID")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("d_domain_id")
				ii_rc = -3
				Return	
			End If

			If ls_d_capa_idx = "" Then
				f_msg_info(200, is_title, "CAPABILITY SET")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("d_capa_idx")
				ii_rc = -3
				Return	
			End If

			//MGCP 이면서 CREATE --> ACTION TYPE
			//LS_ACT_TYPE = ls_action_result[1]
			
			//MGCP 일 때 SIP 설정값들 초기화
			ls_d_ent_type = ""
			
		ELSEIF ls_pro_type = ls_protocol_result[2] THEN
			
			If ls_d_ent_type = "" Then
				f_msg_info(200, is_title, "ENTITY TYPE")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("d_ent_type")
				ii_rc = -3
				Return	
			End If

			//SIP 이면서 CREATE --> ACTION TYPE
			//LS_ACT_TYPE = ls_action_result[2]

			//SIP 일 때 MGCP 설정값들 초기화
			ls_d_domain_id = ""
			ls_d_capa_idx = "" 
			ll_d_opt_bit_map = 0
			
		ElseIf ls_pro_type <> "" Then
			If ls_d_call_type = "" Then
				f_msg_info(200, is_title, "Call Limit")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("call_type")
				ii_rc = -3
				Return	
			End If
			
		END IF

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
			  	ls_validkey[i]      = Trim(idw_data[3].object.validkey[i])
			  	ls_vpasswd[i]       = Trim(idw_data[3].object.vpassword[i])
				ls_d_e164[i]        = Trim(idw_data[3].object.validkey[i])
				
				If is_data[8] = 'Y' Then
					
					ls_d_diallimit[i]   = Trim(idw_data[3].object.d_diallimit[i])
					ls_d_subsbarr[i]    = Trim(idw_data[3].object.d_subsbarr[i])
					ls_d_linecat[i]     = Trim(idw_data[3].object.d_linecat[i])
					ls_d_linepri[i]     = Trim(idw_data[3].object.d_linepri[i])
					ls_d_relcond[i]     = Trim(idw_data[3].object.d_relcond[i])
					ls_d_cgchacat[i]    = Trim(idw_data[3].object.d_cgchacat[i])
					ls_d_cdchacat[i]    = Trim(idw_data[3].object.d_cdchacat[i])
					ls_d_netcodeidx[i]  = Trim(idw_data[3].object.d_netcodeidx[i])
					ls_d_numporttype[i] = Trim(idw_data[3].object.d_numporttype[i])
					ls_langtype[i]      = Trim(idw_data[3].Object.langtype[i])
					
					
					//ex_local_id 는 MGCP 일때만 입력사항
					IF ls_pro_type = ls_protocol_result[1] Then
						ls_ex_local_id[i] = Trim(idw_data[3].object.ex_local_id[i])
					Else
						ls_ex_local_id[i] = ''
					End If
				End If
				
   	      If IsNull(ls_validkey[i]) Then ls_validkey[i] = ""
				If IsNull(ls_vpasswd[i]) Then ls_vpasswd[i] = ""
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
//					f_msg_info(200, is_title, "Authorization Passwrod")
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
						IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validkey = '" + ls_d_e164[i] + "'", i + 1, ll_row)
					CASE ll_row // Row가 맨 마지막
						IF  ll_row > 1 THEN	ll_long = idw_data[3].Find(" validkey = '" + ls_d_e164[i] + "'", 1, i -1)
					CASE ELSE	  
						IF  ll_row > 1 THEN
							ll_long = idw_data[3].Find(" validkey = '" + ls_d_e164[i] + "'", 1, i -1)
							IF  ll_long > 0 THEN
							else
								ll_long = idw_data[3].Find(" validkey = '" + ls_d_e164[i] + "'", i + 1, ll_row)
							END IF
						END IF
				END CHOOSE
				
				If ll_long > 0 Then
					// messagebox(인증KEY중복)	
					f_msg_usr_err(9000, is_title, ls_validkey_msg+"Duplicated")
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetColumn("DN")
					ii_rc = -3
					return
				End if
				
				//인증KEY 중복 check  
				//적용시작일과 적용종료일의 중복일자를 막는다. 
				SELECT count(*)
				  INTO :ll_cnt
				  FROM validinfo
				 WHERE ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
						 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
						 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
				   AND validkey = :ls_d_e164[i]
				   AND svctype = :is_data[5];
						  
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
					Return 
				End If
				
				If ll_cnt > 0 Then
					f_msg_usr_err(9000, is_title, ls_validkey_msg +"[" + ls_d_e164[i]+ "] Starting date and Ending date is overlapped .~r~n~r~nPlease again!!")
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
					f_msg_info(200, is_title, "Message language")		
					idw_data[3].SetRow(i)
					idw_data[3].ScrollToRow(i)
					idw_data[3].SetFocus()
					idw_data[3].SetColumn("langtype")
					ii_rc = -3					
					Return 
				End If
				
				//제너서비스여부 is_data[8] = 'Y'/'N'
				If is_data[8] = 'Y' Then
					
					If ls_d_ip_auth_type = "" Then
						f_msg_info(200, is_title, "Method of authentication")
						idw_data[3].SetFocus()
						idw_data[3].SetRow(i)
						idw_data[3].ScrollToRow(i)
						idw_data[3].SetColumn("d_ip_auth_type")
     					ii_rc = -3						
						Return 
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
	
			//SIP
			//validinfo Sequence
			Select seq_validinfo.nextval
			  Into :ll_validseq
			  From dual; 
			
			//validinfo insert
			For i =1 To UpperBound(ls_d_e164[])
			//ENTITY, 가입자생성 추가
				Insert Into validinfo
				    (seqno, validkey, fromdt, status, 
					 use_yn, vpassword, svctype, gkid,
					 customerid, svccod, priceplan, orderno,
					 contractseq, langtype, auth_method, validitem1,
					 validitem2, validitem3, protocol_type, d_ent_name,
					 d_domain_id, d_comp_id, d_ip_auth_type, d_ent_type,
					 ora_ip_addr, d_ip_port, d_capa_idx, d_opt_bit_map,
					 d_e164, d_diallimit, d_subsbarr, d_linecat,
					 d_linepri, d_relcond, d_cgchacat, d_cdchacat,
					 d_netcodeidx, d_numporttype, ex_local_id,
					 crt_user, updt_user, crtdt, updtdt, pgm_id, d_call_type)
			    Values(:ll_validseq, :ls_d_e164[i], to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
				       :ls_use_yn, :ls_vpasswd[i], :is_data[5], :ls_gkid, 
						 :ls_customerid, :ls_svccod, :ls_priceplan, :ll_orderno,
						 :ll_contractseq, :ls_langtype[i], :ls_auth_method, :ls_customerm,
						 :ls_ip_address, :ls_h323id, :ls_pro_type, :ls_d_ent_name,
						 :ls_d_domain_id, :ls_d_comp_id, :ls_d_ip_auth_type, :ls_d_ent_type,
						 :ls_ora_ip_addr, :ls_d_ip_port, :ls_d_capa_idx, :ll_d_opt_bit_map,
					    :ls_d_e164[i], :ls_d_diallimit[i], :ls_d_subsbarr[i], :ls_d_linecat[i],
						 :ls_d_linepri[i], :ls_d_relcond[i], :ls_d_cgchacat[i], :ls_d_cdchacat[i],
						 :ls_d_netcodeidx[i], :ls_d_numporttype[i], :ls_ex_local_id[i],
					    :gs_user_id, :gs_user_id, sysdate, sysdate, :ls_pgm_id, :ls_d_call_type);

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo entity)")
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
			
			
			//신청 품목  check
			ll_row = idw_data[2].RowCount()
			
			ls_protocol_type_a = Trim(idw_data[1].object.protocol_type[1])
			
			For i = 1 To ll_row
				ls_check[i] = Trim(idw_data[2].object.chk[i])
				
				If ls_check[i] = "Y" Then
					ls_itemcod_a[i] = Trim(idw_data[2].object.itemcod[i])
					ls_d_e164_a[i]  = Trim(idw_data[3].object.validkey[1])  //
					ls_svc_a[i]     = Trim(idw_data[2].object.svc[i])
					ls_ex_odn_a[i]  = Trim(idw_data[2].object.ex_odn[i])
					ls_ex_tdn_a[i]  = Trim(idw_data[2].object.ex_tdn[i])
					
					ll_ex_code_a[i] = Long(idw_data[2].object.ex_code[i])
					ls_ex_key_a[i]  = Trim(idw_data[2].object.ex_key[i])
					ls_ex_mode_a[i] = Trim(idw_data[2].object.ex_mode[i])
					ls_ex_time_a[i] = Trim(idw_data[2].object.ex_time[i])
					ls_ex_vsn_a[i]  = Trim(idw_data[2].object.ex_vsn[i])
					
					
					If IsNull(ls_svc_a[i]) Then ls_svc_a[i] = ""
					If IsNull(ls_ex_odn_a[i]) Then ls_ex_odn_a[i] = ""
					If IsNull(ls_ex_tdn_a[i]) Then ls_ex_tdn_a[i] = ""
					If IsNull(ls_ex_key_a[i]) Then ls_ex_key_a[i] = ""
					If IsNull(ls_ex_mode_a[i]) Then ls_ex_mode_a[i] = ""
					If IsNull(ls_ex_time_a[i]) Then ls_ex_time_a[i] = ""
					If IsNull(ls_ex_vsn_a[i]) Then ls_ex_vsn_a[i] = ""
										
							
					//부가서비스 신청
					If ls_svc_a[i] <> "" Then
						// 프로토콜 타입별로 지원 서비스 여부 쳌
						If ls_protocol_type_a = ls_protocol_sip Then
							Choose Case ls_svc_a[i]
								Case 'CRU','RCF','CFU','DND','CDND','ABS','CID','CIDB','ACR','WKP','ABD','CFB/CFNA','SCR'
								Case Else
									f_msg_info(9000, is_title, "선택하신 Protocol에서 지원하지 않는 부가서비스 입니다.")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("chk")
									ii_rc = -1						
									Return 
								
							End Choose
						Else
						End If
						
						Choose Case ls_svc_a[i]
							Case 'ABS', 'CABS', 'DND', 'CDND'
								If ls_ex_time_a[i] = "" Then
									f_msg_info(200, is_title, "Time")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_time")
									ii_rc = -1						
									Return 
								End If	
								
							Case 'SCR'
								If ls_ex_odn_a[i] = "" Then
									f_msg_info(200, is_title, "Origination DN")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_odn")
									ii_rc = -1						
									Return 
								End If
								
								If IsNull(ll_ex_code_a[i]) Then
									f_msg_info(200, is_title, "Speed Dial#")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_code")
									ii_rc = -1						
									Return 
								End If
								
							Case 'ABD'
								If ls_ex_tdn_a[i] = "" Then
									f_msg_info(200, is_title, "DN called")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_tdn")
									ii_rc = -1						
									Return 
								End If
								
								If IsNull(ll_ex_code_a[i]) Then
									f_msg_info(200, is_title, "Speed Dial#")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_code")
									ii_rc = -1						
									Return 
								End If
								
							Case 'RCF'
								If ls_ex_vsn_a[i] = "" Then
									f_msg_info(200, is_title, "DN")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_vsn")
									ii_rc = -1						
									Return 
								End If
								
							Case 'WML', 'HTL', 'CFB/CFNA', 'CFU'
								If ls_ex_tdn_a[i] = "" Then
									f_msg_info(200, is_title, "DN called")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_tdn")
									ii_rc = -1						
									Return 
								End If
								
							Case 'CIDB', 'ACR'
								ll_ex_act_a[i] = 1
								
							Case 'WKP'
								If ls_ex_mode_a[i] = "" Then
									f_msg_info(200, is_title, "Mode")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_mode")
									ii_rc = -1						
									Return 
								End If
								
								If ls_ex_time_a[i] = "" Then
									f_msg_info(200, is_title, "Time")
									idw_data[2].SetFocus()
									idw_data[2].SetRow(i)
									idw_data[2].ScrollToRow(i)
									idw_data[2].SetColumn("ex_time")
									ii_rc = -1						
									Return 
								End If
								
							Case Else
								
						End Choose
						
						
						Insert Into ssw_addsvc
								(d_e164, itemcod, svc, protocol_type,
								 ex_odn, ex_tdn, ex_code, ex_key,
								 ex_mode, ex_time, ex_vsn, ex_act,
								 use_yn, change_yn, crt_user, updt_user,
								 crtdt, updtdt, pgm_id)
						Values(:ls_d_e164_a[i], :ls_itemcod_a[i], :ls_svc_a[i], :ls_protocol_type_a, 
								 :ls_ex_odn_a[i], :ls_ex_tdn_a[i], :ll_ex_code_a[i], :ls_ex_key_a[i],
								 :ls_ex_mode_a[i], :ls_ex_time_a[i], :ls_ex_vsn_a[i], :ll_ex_act_a[i],
								 'Y', 'N', :gs_user_id, :gs_user_id,
								 sysdate, sysdate, :ls_pgm_id);
		
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(SWW_ADDSVC)")
							ii_rc = -1						
							RollBack;
							Return 
						End If
						
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
									  From validinfo_ssw
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
									  From validinfo_ssw Where coid = :ls_coid									  
									 Union
									Select validkey, to_char(cworkdt,'yyyymmdd') cworkdt, result
									  From validinfo_sswh
									 Where to_char(cworkdt,'yyyymmdd') = :ls_requestdt 
									   and coid = :ls_coid ) vs
									Where vs.validkey = :ls_validkey[i]
									  and vs.cworkdt = :ls_requestdt;
								  
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Select result(Validinfoserver)2")
							ii_rc = -1
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

on b1u_dbmgr14.create
call super::create
end on

on b1u_dbmgr14.destroy
call super::destroy
end on

