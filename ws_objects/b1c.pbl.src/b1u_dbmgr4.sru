$PBExportHeader$b1u_dbmgr4.sru
$PBExportComments$[parkkh] DB Manager/인증정보 - 2005.04.18 인증키 추가/변경에 날짜 체크 변경 [fromdt >= activedt] juede
forward
global type b1u_dbmgr4 from u_cust_a_db
end type
end forward

global type b1u_dbmgr4 from u_cust_a_db
end type
global b1u_dbmgr4 b1u_dbmgr4

type variables

end variables

forward prototypes
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_05 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_02 ();//"b1w_reg_validinfoserver_mod%ue_save"
String ls_worktype, ls_svctype, ls_status, ls_customerid, ls_prcdt, ls_auth_method, ls_validkey,  ls_vpassword
String ls_ip_address, ls_h323id, ls_block_type, ls_coid, ls_gkid, ls_check_yn
String ls_ref_desc, ls_code
Dec ldc_seqno
Int li_cnt

ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_validinfoserver_mod%ue_save"
		//lu_dbmgr = Create b1u_dbmgr4
		//lu_dbmgr.is_caller = "b1w_reg_validinfoserver_mod%ue_save"
		//lu_dbmgr.is_title = Title
		//lu_dbmgr.idw_data[1] = dw_detail
		//lu_dbmgr.is_data[1] = gs_user_id
//		lu_dbmgr.is_data[2] = is_result[3]      //
//		lu_dbmgr.is_data[3] = is_result[4]


		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		//재처리 Flag 코드
 		ls_code = fs_get_control("B1", "P310", ls_ref_desc)
				
		For li_cnt = 1 to  idw_data[1].RowCount()
			
			ls_check_yn = ""
			ls_check_yn = idw_data[1].object.check_yn[li_cnt]
			If ls_check_yn = "1" Then
				ldc_seqno = idw_data[1].object.seqno[li_cnt]				
				ls_worktype = idw_data[1].object.worktype[li_cnt]
				ls_svctype = idw_data[1].object.svctype[li_cnt]
				ls_status = idw_data[1].object.status[li_cnt]
				ls_validkey = idw_data[1].object.validkey[li_cnt]
				ls_vpassword = idw_data[1].object.vpassword[li_cnt]
				ls_customerid = idw_data[1].object.customerid[li_cnt]
				ls_prcdt = string(idw_data[1].object.prcdt[li_cnt],'yyyymmdd')
				ls_auth_method = idw_data[1].object.auth_method[li_cnt]
				ls_ip_address = idw_data[1].object.ip_address[li_cnt]		
				ls_h323id = idw_data[1].object.h323id[li_cnt]		
				ls_block_type = idw_data[1].object.block_type[li_cnt]
				ls_coid  = idw_data[1].object.coid[li_cnt]
				ls_gkid = idw_data[1].object.gkid[li_cnt]
				
				If IsNull(ls_worktype) Then ls_worktype = ""
				If IsNull(ls_svctype) Then ls_svctype = ""
				If IsNull(ls_status) Then ls_status = ""
				If IsNull(ls_validkey) Then ls_validkey = ""
				If IsNull(ls_vpassword) Then ls_vpassword = ""		
				If IsNull(ls_customerid) Then ls_customerid = ""
				If IsNull(ls_prcdt) Then ls_prcdt = ""
				If IsNull(ls_auth_method) Then ls_auth_method = ""
				If IsNull(ls_ip_address) Then ls_ip_address = ""
				If IsNull(ls_h323id) Then ls_h323id = ""
				If IsNull(ls_block_type) Then ls_block_type = ""
				If IsNull(ls_coid) Then ls_coid = ""
				If IsNull(ls_gkid) Then ls_gkid = ""
		
				//Insert
				Insert Into validinfoserver
				   ( seqno, worktype, svctype, status, validkey, vpassword,
					 customerid, cworkdt, prcdt,
					 crt_user, gkid, auth_method,
					 customerm, ip_address, h323id, chg_number, block_type, coid, flag)
				values ( seq_validinfoserver.nextval, :ls_worktype, :ls_svctype, :ls_status, :ls_validkey, :ls_vpassword,
						:ls_customerid, sysdate, to_date(:ls_prcdt,'yyyy-mm-dd'),
						:is_data[1], :ls_gkid, :ls_auth_method, 
						:ls_customerid, :ls_ip_address, :ls_h323id, :ls_validkey, :ls_block_type, :ls_coid, :ls_code); 
											 
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					f_msg_sql_err(is_title, is_caller + " Insert Error(validinfoserver)")
					Return 
				End If	
				
				Update validinfoserverh
				   set result = :is_data[3]
				 where seqno = :ldc_seqno;
				 
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					f_msg_sql_err(is_title, is_caller + " Update Error(validinfoserverh)")
					Return 
				End If					 
				
			End If

		Next
		
	Case "b1w_reg_validinfoserver_mod_1%ue_save"
		//lu_dbmgr = Create b1u_dbmgr4
		//lu_dbmgr.is_caller = "b1w_reg_validinfoserver_mod_1%ue_save"
		//lu_dbmgr.is_title = Title
		//lu_dbmgr.idw_data[1] = dw_detail
		//lu_dbmgr.is_data[1] = gs_user_id
//		lu_dbmgr.is_data[2] = is_result[3]      //
//		lu_dbmgr.is_data[3] = is_result[4]
//      lu_dbmgr.is_data[4] = is_result[1]

		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		//재처리 Flag 코드
 		ls_code = fs_get_control("B1", "P310", ls_ref_desc)
				
		For li_cnt = 1 to  idw_data[1].RowCount()
			
			ls_check_yn = ""
			ls_check_yn = idw_data[1].object.check_yn[li_cnt]
			If ls_check_yn = "1" Then
				
				ldc_seqno = idw_data[1].object.seqno[li_cnt]				
				ls_auth_method = idw_data[1].object.auth_method[li_cnt]
				ls_ip_address = idw_data[1].object.ip_address[li_cnt]		
				ls_h323id = idw_data[1].object.h323id[li_cnt]		
				If IsNull(ls_auth_method) Then ls_auth_method = ""
				If IsNull(ls_ip_address) Then ls_ip_address = ""
				If IsNull(ls_h323id) Then ls_h323id = ""

				//Insert
				Insert Into validinfoserver
				   ( seqno, worktype, svctype, status, validkey, vpassword,
					 customerid, cworkdt, prcdt, result,
					 crt_user, customerm, ip_address, h323id, 
					 auth_method, gkid, chg_number, block_type, ogn, coid, flag, cid, svccod )
			     select seq_validinfoserver.nextval, worktype, svctype, status, validkey, vpassword,
					    customerid, sysdate, prcdt, :is_data[4],
					    :is_data[1], customerm, :ls_ip_address, :ls_h323id,
					    :ls_auth_method, gkid, chg_number, block_type, ogn, coid, :ls_code, cid, svccod
				    from validinfoserverh
 				   where seqno = :ldc_seqno; 
											 
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					f_msg_sql_err(is_title, is_caller + " Insert Error(validinfoserver)")
					Return 
				End If	
				
				Update validinfoserverh
				   set result = :is_data[3]
				 where seqno = :ldc_seqno;
				 
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					f_msg_sql_err(is_title, is_caller + " Update Error(validinfoserverh)")
					Return 
				End If					 
				
			End If

		Next
		

	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose
//
ii_rc = 0
end subroutine

public subroutine uf_prc_db_03 ();String ls_validinfo , ls_name[], ls_ref_des, ls_temp, ls_status, ls_svc_status[], ls_term
String ls_ref_desc, ls_fromdt, ls_contractseq, ls_svctype
Integer li_valid_cnt, li_cnt, i
ii_rc = -1
Choose Case  is_caller
		Case "b1w_reg_validkey_term"
			//iu_check.idw_data[1] = dw_cond
            //iu_check.is_data[1] = ls_validkey     //인증KEY
			li_valid_cnt = 0 
			ls_validinfo = is_data[1]
			ls_contractseq = is_data[3]
			
			ls_status = fs_get_control("B0", "P221", ls_ref_desc)
			fi_cut_string(ls_status, ";", ls_svc_status[])		
			ls_term	 = ls_svc_status[2]
			
				SELECT count(*), to_char(fromdt, 'yyyymmdd'), svctype 
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

      /**************************************************/
      /* 2005.04.12 juede 애니유저넷 인증키분리  (trem) */
      /**************************************************/		
		Case "b1w_reg_validkey_term_aun"
			//iu_check.idw_data[1] = dw_cond
            //iu_check.is_data[1] = ls_validkey     //인증KEY
			li_valid_cnt = 0 
			ls_validinfo = is_data[1]
			ls_contractseq = is_data[3]
			
			ls_status = fs_get_control("B0", "P221", ls_ref_desc)
			fi_cut_string(ls_status, ";", ls_svc_status[])		
			ls_term	 = ls_svc_status[2]
			
				SELECT count(*), to_char(fromdt, 'yyyymmdd'), svctype 
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
Return 
	
end subroutine

public subroutine uf_prc_db_06 ();/* *************************************************************
*  2005.04.09 juede AnyUserNet 인증키 분리
*  인증키 변경/삭제/추가
****************************************************************/

//"b1w_validkey_update_popup_1_1%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf
Long ll_cnt

//"b1w_validkey_update_popup_2_2%ue_save"
String ls_gkid, ls_auth_method, ls_cusnm, ls_ip_address, ls_h323id, ls_ref_desc, ls_act_status
String ls_customernm, ls_svccod, ls_sys_langtype, ls_langtype, ls_svctype
decimal ldc_svcorderno

//공통 
String ls_sysdt, ls_cid, ls_validkeyloc, ls_temp

//Ver 2.0 추가
String ls_customerid, ls_contractseq, ls_partner, ls_orderno, ls_validkeymst_status[]

//2005.04.06 juede Anyusernet  ----start
Long ll_validkey_cnt
String ls_validkey1, ls_validkey2, ls_validkey3, ls_validkey4, ls_activedt
Date ld_fromdt
Datetime ldt_activedt
//2005.04.06 juede Anyusernet  ----end

ii_rc = -1

//인증Key 관리모듈포함 version 2.0 khpark modify 2004.06.02.

//validkeymst 상태(is_caller 모두 사용함으로 상단에 코팅)
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P400", ls_ref_desc)   
If ls_temp = "" Then Return 
fi_cut_string(ls_temp, ";" , ls_validkeymst_status[])   //인증Key관리상태(생성;개통;해지)

Choose Case is_caller
	/*********************************
	*  Validkey  Change
	*********************************/		
	Case "b1w_validkey_update_popup_1_1_aun%ue_save"          //인증Key 관리모듈포함 version 2.0
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey
//		lu_dbmgr.is_data[3]  = is_pgm_id
//		lu_dbmgr.is_data[4]  = is_xener_svc               //제너서비스여부
//      lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt        //validkeytype count

		idw_data[1].accepttext()
		
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return

		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt   = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		//2005.04.15 juede add -- start
		ls_activedt   = string(idw_data[1].object.activedt[1],'yyyymmdd')
		//2005.04.15 juede add -- end		
		
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_svctype = idw_data[1].object.svctype[1]
		ls_cid     = idw_data[1].object.cid[1]
		ls_validkeyloc = idw_data[1].object.new_validkey_loc[1]
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
			ls_new_todt = ""
			ls_new_todt_cf = '99991231'
		End if
		If IsNull(ls_vpassword) Then ls_vpassword = ""
        If IsNull(ls_langtype) or ls_langtype = "" Then 
			ls_langtype = ls_sys_langtype
		End IF
		If IsNull(ls_cid) Then ls_cid = ""
		If IsNull(ls_validkeyloc) Then ls_validkeyloc = ""

		ls_svccod = idw_data[1].object.svccod[1]
		If IsNull(ls_svccod) Then ls_svccod = ""
//		ls_gkid = idw_data[1].object.new_gkid[1]		
		ls_auth_method = idw_data[1].object.new_auth_method[1]
//		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""
		ls_ip_address = idw_data[1].object.ip_address[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
     	ls_h323id = idw_data[1].object.h323id[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							

		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
		If IsNull(ls_customerid) Then ls_customerid = ""		
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
		If IsNull(ls_partner) Then ls_partner = ""	
		ls_orderno = String(idw_data[1].object.orderno[1])   
		If IsNull(ls_orderno) Then ls_orderno = '0'

		//2005.04.06 juede anyusernet validkey 분리---------start
		ls_validkey1 = trim(idw_data[1].object.new_validkey1[1])
     	ls_validkey2 = trim(idw_data[1].object.new_validkey2[1])
		ls_validkey3 = trim(idw_data[1].object.new_validkey3[1])
		ls_validkey4 = trim(idw_data[1].object.new_validkey4[1])
		

		If IsNull(ls_validkey1) Then ls_validkey1 = ""				
		If IsNull(ls_validkey2) Then ls_validkey2 = ""				
		If IsNull(ls_validkey3) Then ls_validkey3 = ""				
		If IsNull(ls_validkey4) Then ls_validkey4 = ""												
		//2005.04.06 juede anyusernet validkey 분리---------end	
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		//2005.04.06 juede anyusernet validkey 분리---------start
		If ls_validkey1 = "" Then
			f_msg_info(200, is_title, " 국가번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey1")
			Return	
		End If
		
		If ls_validkey2 = "" Then
			f_msg_info(200, is_title,"지역")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey2")
			Return	
		End If
		
		If ls_validkey3 = "" Then
			f_msg_info(200, is_title, "국번")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey3")
			Return	
		End If	
		
		If ls_validkey4= "" Then
			f_msg_info(200, is_title, "번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey4")
			Return	
		End If										
		//2005.04.06 juede anyusernet validkey 분리---------end
		
		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//2005.04.15 juede modify comment
		//If ls_fromdt <= ls_sysdt Then
		If ls_fromdt <= ls_activedt Then		 //2005.04.15 juede activedt로 변경
			f_msg_usr_err(210, is_Title, "적용시작일은 개통일보다 커야합니다.")
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
		
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ip_address")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("h323id")
					Return 
				End If		
			End If
		End IF
		
		
		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		 from validinfo
		where validkey = :ls_validkey
		  and to_char(fromdt,'yyyymmdd') = :ls_fromdt and svctype = :ls_svctype;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
	
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			return 
		End if
		
		//변경전 Key = 변경후 Key 날짜 중복check 루틴 뺀다.(update적용종료일되므로)
		If is_data[2] <> ls_validkey Then
			
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
							to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
					  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				return 
			End if

			IF ii_data[1] > 0 Then
				
				//VALIDKEYMST UPDATE
				Update validkeymst
				   set status = :ls_validkeymst_status[3], sale_flag = '0', activedt = null,
					   customerid = null,  orderno = null, contractseq = null,
					   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
				  Where validkey = :is_data[2]
				    and contractseq = :ls_contractseq ;
				  
				 If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Update validkeymst Table 1(old)")				
					Return 

				 End If
				 
				//VALIDKEYMST_LOG INSERT
				 Insert Into validkeymst_log
				   (validkey, seq, status, actdt, customerid, 
					contractseq, partner, crt_user, crtdt, pgm_id)
				 Select validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[3], to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid,
						  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[3] 
				    From validkeymst
   				   Where validkey = :is_data[2];
				 
				 If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table 1(old)")				
					Return 
				 End If

				 Update validkeymst
				   set status = :ls_validkeymst_status[2],   sale_flag = '1',   activedt = to_date(:ls_fromdt,'yyyy-mm-dd'),
					   customerid = :ls_customerid,  orderno = :ls_orderno,   contractseq = :ls_contractseq ,
					   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
				  Where validkey = :ls_validkey;
				  
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Update validkeymst Table 2(new)")					
					Return 
				End If
			
			    Insert Into validkeymst_log
				   (validkey, seq, status, actdt, customerid, 
					contractseq, partner, crt_user, crtdt, pgm_id)
				 Select  validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[2], to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid,
						  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[3]
				   From validkeymst 
				  Where validkey = :ls_validkey;
						  
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table 2(new)")				
					Return 
				End If
				
			End IF
			
		End IF
	
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')

		Update validinfo
		Set use_yn = 'N',
		    todt = to_date(:ls_fromdt,'yyyy-mm-dd'),
			updt_user = :gs_user_id,
		    updtdt = sysdate,
			pgm_id = :is_data[3]
		Where validkey = :is_data[2]
		 And to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
			Return 
		End If

		//Insert
		insert into validinfo
		    ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  validitem, gkid, customerid,
			  svccod, svctype, priceplan, 
			  orderno, contractseq, validitem1,
			  validitem2, validitem3, auth_method,
			  validkey_loc, crt_user, crtdt,
			  pgm_id, updt_user, updtdt, langtype )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				validitem, gkid, customerid,
				svccod, svctype, priceplan,
				orderno, contractseq, :ls_cid,
				:ls_ip_address, :ls_h323id, :ls_auth_method,
				:ls_validkeyloc, :gs_user_id, sysdate,
				:is_data[3], :gs_user_id, sysdate, :ls_langtype
		   from validinfo
		  where validkey = :is_data[2]
		    and to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------start
		Update validinfo_sub
		Set  todt = to_date(:ls_fromdt,'yyyy-mm-dd'),
			updt_user = :gs_user_id,
		    updtdt = sysdate,
			pgm_id = :is_data[3]
		Where validkey = :is_data[2]
		 And to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
			Return 
		End If		
		
		Insert Into validinfo_sub
				(validkey, fromdt,todt,svctype,
				 validkey1, validkey2, validkey3,validkey4,
				 crt_user, updt_user, crtdt, updtdt, pgm_id)
		select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'),  svctype,
				:ls_validkey1, :ls_validkey2, :ls_validkey3, :ls_validkey4,
				:gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[3]
   		from validinfo_sub
		  where validkey = :is_data[2]
		    and to_char(fromdt,'yyyymmdd') = :is_data[1] 
			 and svctype = :ls_svctype;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo_sub)")
			ii_rc = -1						
			RollBack;
			Return 
		End If												
		//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------end				
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey + "]로 변경되었습니다.")
		
		commit;
		
	/*********************************
	*  Validkey Add
	*********************************/
	Case "b1w_validkey_update_popup_2_1_aun%ue_save"			//인증Key 관리모듈포함 version 2.0
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_itemcod
//		lu_dbmgr.is_data[2]  = is_contractseq
//	    lu_dbmgr.is_data[3]  = is_svctype
//		lu_dbmgr.is_data[4]  = is_pgm_id
//		lu_dbmgr.is_data[5]  = is_xener_svc     //제너서비스여부('Y'/'N')
//      lu_dbmgr.is_data[6]  = is_status         //개통상태 코드
//      lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt        //validkeytype count

		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
		//gkid default 값
		ls_gkid = fs_get_control("00", "G100", ls_ref_desc)
		
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		//2005.04.15 juede add -- start
		ls_activedt   = String(idw_data[1].object.activedt[1],'yyyymmdd')
		//2005.04.15 juede add -- end				
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_cid     = idw_data[1].object.new_cid[1]
		ls_validkeyloc = idw_data[1].object.new_validkey_loc[1]
		
		//2005.04.06 juede anyusernet validkey 분리---------start
		ls_validkey1 = trim(idw_data[1].object.new_validkey1[1])
     	ls_validkey2 = trim(idw_data[1].object.new_validkey2[1])
		ls_validkey3 = trim(idw_data[1].object.new_validkey3[1])
		ls_validkey4 = trim(idw_data[1].object.new_validkey4[1])
		

		If IsNull(ls_validkey1) Then ls_validkey1 = ""				
		If IsNull(ls_validkey2) Then ls_validkey2 = ""				
		If IsNull(ls_validkey3) Then ls_validkey3 = ""				
		If IsNull(ls_validkey4) Then ls_validkey4 = ""												
		//2005.04.06 juede anyusernet validkey 분리---------end	
		
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
		
//		ls_gkid = idw_data[1].object.new_gkid[1]
		ls_auth_method = idw_data[1].object.new_authmethod[1]
//		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""		
	    ls_ip_address = idw_data[1].object.new_ipaddress[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
		ls_h323id = idw_data[1].object.new_h323id[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							

		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
		If IsNull(ls_customerid) Then ls_customerid = ""		
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
		If IsNull(ls_partner) Then ls_partner = ""	

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If
		//2005.04.06 juede anyusernet validkey 분리---------start
		If ls_validkey1 = "" Then
			f_msg_info(200, is_title, " 국가번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey1")
			Return	
		End If
		
		If ls_validkey2 = "" Then
			f_msg_info(200, is_title,"지역")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey2")
			Return	
		End If
		
		If ls_validkey3 = "" Then
			f_msg_info(200, is_title, "국번")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey3")
			Return	
		End If	
		
		If ls_validkey4= "" Then
			f_msg_info(200, is_title, "번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey4")
			Return	
		End If										
		//2005.04.06 juede anyusernet validkey 분리---------end
		
		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//2005.04.15 juede modify comment
		//If ls_fromdt <= ls_sysdt Then
		If ls_fromdt <= ls_activedt Then		 //2005.04.15 juede activedt로 변경			
			f_msg_usr_err(210, is_Title, "적용시작일은 개통일날짜 이상이여야 합니다.") //오늘 -> 개통일
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
			
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_ipaddress")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_h323id")
					Return 
				End If		
			End If
			
		End IF
		
		
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(*)
		  into :ll_cnt
		 from validinfo
		where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
						to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
				  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and	validkey = :ls_validkey and svctype = :is_data[3];
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
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
                status, 'Y', :ls_vpassword,
				customerid, svccod,
				:is_data[3], priceplan,
				:ldc_svcorderno, contractseq, :ls_gkid,
				:ls_cid, :ls_ip_address, :ls_h323id, :ls_auth_method,
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
		
		//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------start
		Insert Into validinfo_sub
				(validkey, fromdt,todt,svctype,
				 validkey1, validkey2, validkey3,validkey4,
				 crt_user, updt_user, crtdt, updtdt, pgm_id)
		 Values(:ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'),  :is_data[3],
				:ls_validkey1, :ls_validkey2, :ls_validkey3, :ls_validkey4,
				:gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[4]);	

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo_sub)")
			ii_rc = -1						
			RollBack;
			Return 
		End If												
		//2005.04.06 juede anyusernet voip 인증키 번호 항목 분리-------------------end			
		
		IF ii_data[1] > 0 Then

			Update validkeymst
			   set status = :ls_validkeymst_status[2],   sale_flag = '1',  
				   activedt = to_date(:ls_fromdt,'yyyy-mm-dd'),
				   customerid = :ls_customerid,  orderno = :ldc_svcorderno,  
				   contractseq = :ls_contractseq ,
				   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[4] 
			  Where validkey = :ls_validkey;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
				Return 
			End If
				
			Insert Into validkeymst_log
			   (validkey, seq, status, 
			    actdt, customerid, contractseq, 
				partner, crt_user, crtdt, pgm_id)
			 Select :ls_validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
		              to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
					  :ls_partner, :gs_user_id, sysdate, :is_data[4] 
			   From validkeymst
			 Where validkey = :ls_validkey;
					  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table")				
				Return 
			End If
			
		End IF
		
		f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey + "]가  추가되었습니다.")
		
		commit;
	
	/*********************************
	*  Validkey Terms
	*********************************/
	Case "b1w_validkey_update_popup_3_1_aun%ue_save"			//인증Key 관리모듈포함 version 2.0
//	lu_dbmgr.is_caller = "b1w_validkey_update_popup_3_1%ue_save"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.idw_data[1] = dw_detail
//	lu_dbmgr.is_data[1]  = ls_todt
//	lu_dbmgr.is_data[2]  = is_pgm_id

		idw_data[1].accepttext()
		
		ls_validkey = idw_data[1].object.validkey[1]
		If IsNull(ls_validkey) Then ls_validkey = ""

		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
		If IsNull(ls_customerid) Then ls_customerid = ""		
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
		If IsNull(ls_partner) Then ls_partner = '0'		
		ls_orderno = String(idw_data[1].object.orderno[1])   
		If IsNull(ls_orderno) Then ls_orderno = '0'

		//validinfo_sub update  2005.04.06 juede anyusernet ---------------------------start			  
		SELECT count(*)
		INTO :ll_validkey_cnt
		FROM validinfo
		WHERE to_char(contractseq) = :ls_contractseq;
		
		If ll_validkey_cnt >0  Then
		
			DECLARE validinfo_key CURSOR FOR
				Select validkey, fromdt, svctype
				From   validinfo
				Where  to_char(contractseq) = :ls_contractseq;
			
			OPEN validinfo_key;
			
			Do While(True)
				FETCH validinfo_key INTO :ls_validkey, :ld_fromdt, :ls_svctype;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Select Error(VALIDINFO_VALIDKEY)")
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If		
				
				Update validinfo_sub
					Set todt = nvl(todt,to_date(:is_data[1], 'yyyy-mm-dd')), //해지일
						 updt_user = :gs_user_id, 
						 updtdt = sysdate, 
						 pgm_id = :is_data[2] 
				 Where validkey = :ls_validkey
				  AND  fromdt = :ld_fromdt
				  AND  svctype = :ls_svctype;
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If			  
							
				
			Loop					
			CLOSE validinfo_key;			
			
		Else
				SELECT validkey, fromdt, svctype
				INTO   :ls_validkey, :ld_fromdt, :ls_svctype
				FROM   validinfo
				WHERE  to_char(contractseq) = :ls_contractseq;
								
			
				Update validinfo_sub
					Set todt = nvl(todt,to_date(:is_data[1], 'yyyy-mm-dd')), //해지일
						 updt_user = :is_data[6],
						 updtdt = sysdate,
						 pgm_id = :is_data[7]
				 Where validkey = :ls_validkey
				  AND  fromdt = :ld_fromdt
				  AND  svctype = :ls_svctype;
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If			  
			  
		End If
		//validinfo_sub update  2005.04.06 juede anyusernet -------------------------------end			
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
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose
//
ii_rc = 0
end subroutine

public subroutine uf_prc_db ();
//"b1w_validkey_update_popup_1%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf
String ls_svctype
Long ll_cnt

//"b1w_validkey_update_popup_2%ue_save"
String ls_gkid, ls_auth_method, ls_cusnm, ls_ip_address, ls_h323id, ls_ref_desc, ls_act_status
String ls_customernm, ls_validkey_loc, ls_svccod, ls_langtype, ls_sys_langtype
decimal ldc_svcorderno
//공통 
String ls_sysdt

//2005.04.18 juede [fromdt >= activedt ] ----start
String ls_activedt 
Date ld_activedt
//2005.04.18 juede [fromdt >= activedt ] ----end

ii_rc = -1

Choose Case is_caller
	Case "b1w_validkey_update_popup_1%ue_save"        //통합빌링..
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey
//		lu_dbmgr.is_data[3]  = is_pgm_id
//    lu_dbmgr.is_data[4]  = ls_contractseq

      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----start
		select to_char(activedt,'yyyymmdd')
		  into :ls_activedt
		 from contractmst
		where contractseq=:is_data[4];
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select activedt ")				
			Return 
		End If
      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----end
		
		idw_data[1].accepttext()
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
	    ls_langtype = idw_data[1].object.new_langtype[1]
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_svctype = idw_data[1].object.svctype[1]                   //Svctype 을 가져옴
		
		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
		//ls_activedt = string(ld_activedt,'yyyymmdd')
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
		If IsNull(ls_langtype) Then ls_langtype = ls_sys_langtype

		ls_svccod = idw_data[1].object.svccod[1]
		If IsNull(ls_svccod) Then ls_svccod = ""


		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//If ls_fromdt <= ls_sysdt Then
		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜보다 커야합니다.")
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
				
		
//		If ls_gkid = "" Then
//			f_msg_usr_err(200, is_Title, "GKID")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_gkid")
//			Return 
//		End If		
		
		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		 from validinfo
		where validkey = :ls_validkey
		  and to_char(fromdt,'yyyymmdd') = :ls_fromdt and svctype = :ls_svctype;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
	
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			return 
		End if
		
		//변경전 Key = 변경후 Key 날짜 중복check 루틴 뺀다.(update적용종료일되므로)
		If is_data[2] <> ls_validkey Then
			
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
							to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
					  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				return 
			End if
		End IF
	
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
		
		Update validinfo
		Set use_yn = 'N',
		    todt = to_date(:ls_fromdt,'yyyy-mm-dd'),
			updt_user = :gs_user_id,
		    updtdt = sysdate,
			pgm_id = :is_data[3]
		Where validkey = :is_data[2]
		 And to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update Error(ValindInfo)")				
			Return 
		End If

		//Insert 인증 방법, validitem1 에 고객이름 Insert 되지 않는다. 
		insert into validinfo
		    ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  validitem, gkid, customerid,
			  svccod, svctype, priceplan, 
			  orderno, contractseq, langtype,
			  crt_user, crtdt, pgm_id, updt_user, updtdt )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				validitem, :ls_gkid, customerid,
				svccod, svctype, priceplan,
				orderno, contractseq, :ls_langtype,
				:gs_user_id, sysdate, :is_data[3], :gs_user_id, sysdate
		   from validinfo
		  where validkey = :is_data[2]
		    and to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey + "]로 변경되었습니다.")
		
		commit;
		
	Case "b1w_validkey_update_popup_1_x1%ue_save"		//xener
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_x1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey
//		lu_dbmgr.is_data[3]  = is_pgm_id
//		lu_dbmgr.is_data[4]  = is_xener_svc         //제너서비스여부
//		lu_dbmgr.is_data[5]  = ls_contractseq

		idw_data[1].accepttext()
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return

      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----start
		select to_char(activedt,'yyyymmdd')
		  into :ls_activedt
		 from contractmst
		where contractseq=:is_data[5];
		
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select activedt ")				
			Return 
		End If		
      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----end
		
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
	   ls_svctype = idw_data[1].object.svctype[1]                   //Svctype 을 가져옴
		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
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
		If IsNull(ls_langtype) Then ls_langtype = ls_sys_langtype

		ls_svccod = idw_data[1].object.svccod[1]
		If IsNull(ls_svccod) Then ls_svccod = ""

		ls_gkid = idw_data[1].object.new_gkid[1]		
		ls_validkey_loc = idw_data[1].object.new_validkey_loc[1]		
		ls_auth_method = idw_data[1].object.new_auth_method[1]
		If IsNull(ls_validkey_loc) Then ls_validkey_loc = ""
		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""		

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//If ls_fromdt <= ls_sysdt Then
		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜보다 커야합니다.")
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
		
		If ls_gkid = "" Then
			f_msg_usr_err(200, is_Title, "GKID")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_gkid")
			Return 
		End If		
		
		If ls_validkey_loc = "" Then
			f_msg_usr_err(200, is_title, "인증KEY Location")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey_loc")
			Return
		End If

		//xener IPPhone 서비스코드는 인증방법기타 check 
		If is_data[4] = 'Y' Then

			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				ls_ip_address = idw_data[1].object.ip_address[1]
				If IsNull(ls_ip_address) Then ls_ip_address = ""				
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ip_address")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				ls_h323id = idw_data[1].object.h323id[1]
				If IsNull(ls_h323id) Then ls_h323id = ""							
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("h323id")
					Return 
				End If		
			End If
		End IF

		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		 from validinfo
		where validkey = :ls_validkey
		  and to_char(fromdt,'yyyymmdd') = :ls_fromdt and svctype = :ls_svctype;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
	
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			return 
		End if
		
		//변경전 Key = 변경후 Key 날짜 중복check 루틴 뺀다.(update적용종료일되므로)
		If is_data[2] <> ls_validkey Then
			
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
							to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
					  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				return 
			End if
		End IF
	
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
		
		Update validinfo
		Set use_yn = 'N',
		    todt = to_date(:ls_fromdt,'yyyy-mm-dd'),
			updt_user = :gs_user_id,
		    updtdt = sysdate,
			pgm_id = :is_data[3]
		Where validkey = :is_data[2]
		 And to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
			Return 
		End If

		//Insert
		insert into validinfo
		    ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  validitem, gkid, customerid,
			  svccod, svctype, priceplan,
			  orderno, contractseq, validkey_loc,
			  validitem1, validitem2, validitem3, auth_method,
			  crt_user, crtdt, pgm_id, updt_user, updtdt, langtype )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				validitem, :ls_gkid, customerid,
				svccod, svctype, priceplan,
				orderno, contractseq, :ls_validkey_loc,
				validitem1, :ls_ip_address, :ls_h323id, :ls_auth_method,
				:gs_user_id, sysdate, :is_data[3], :gs_user_id, sysdate, :ls_langtype
		   from validinfo
		  where validkey = :is_data[2]
		    and to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey + "]로 변경되었습니다.")
		
		commit;
		
	Case "b1w_validkey_update_popup_2%ue_save"		//통합빌링
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_itemcod
//		lu_dbmgr.is_data[2]  = is_contractseq
//	   lu_dbmgr.is_data[3]  = is_svctype
//		lu_dbmgr.is_data[4]  = is_pgm_id
//    lu_dbmgr.is_data[5]  = is_status         //개통상태 코드
 

		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)     //개통상태
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return				
		
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_customernm = idw_data[1].object.customerm_customernm[1]
		ls_langtype = idw_data[1].object.new_langtype[1]   //멘트 언어
		
      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----start
		select to_char(activedt,'yyyymmdd')
		  into :ls_activedt
		 from contractmst
		where contractseq=:is_data[2];
		
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select activedt ")				
			Return 
		End If		
		
		If IsNull(ls_activedt) Then ls_activedt = ""
      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----end
		
		If IsNull(ls_langtype) Then ls_langtype = ls_sys_langtype  //Default 언어
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

		ls_gkid = idw_data[1].object.new_gkid[1]
		If IsNull(ls_gkid) Then ls_gkid = ""

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
		//ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
		//If ls_fromdt < ls_sysdt Then
		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜 이상이여야합니다.")
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
		
		
//		If ls_gkid = "" Then
//			f_msg_usr_err(200, is_Title, "GKID")
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("new_gkid")
//			Return 
//		End If		

		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(*)
		  into :ll_cnt
		 from validinfo
		where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
						to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
				  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			and  svctype = :is_data[3]
		   and	validkey = :ls_validkey;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			Return 
		End if
	
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
		select max(orderno) 
		  into :ldc_svcorderno
		  From svcorder 
	     Where to_char(ref_contractseq) = :is_data[2]
	       and status = :is_data[5];		
							 
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select svcorder (orderno)")				
			Return 
		End If
		
		//Insert
		insert into validinfo
		    ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  gkid, customerid,
			  svccod, svctype, priceplan, 
			  orderno, contractseq, langtype,
			  crt_user, crtdt, pgm_id, updt_user, updtdt )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				:ls_gkid, customerid, 
				svccod, :is_data[3], priceplan,
				:ldc_svcorderno, contractseq, :ls_langtype,
				:gs_user_id, sysdate, :is_data[4], :gs_user_id, sysdate
		   from contractmst
		  where to_char(contractseq) = :is_data[2];

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey + "]가  추가되었습니다.")
		
		commit;

	Case "b1w_validkey_update_popup_2_x1%ue_save"			//xener
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_x1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_itemcod
//		lu_dbmgr.is_data[2]  = is_contractseq
//	    lu_dbmgr.is_data[3]  = is_svctype
//		lu_dbmgr.is_data[4]  = is_pgm_id
//		lu_dbmgr.is_data[5]  = is_xener_svc        //제너서비스여부('Y'/'N')
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
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_customernm = idw_data[1].object.customerm_customernm[1]
		ls_langtype = idw_data[1].object.new_langtype[1]

		//2005.04.18 juede  fromdt >= activedt 로 조건변경------start
		select to_char(activedt,'yyyymmdd')
		  into :ls_activedt
		 from contractmst
		where contractseq=:is_data[2];
		
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select activedt")				
			Return 
		End If
		
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
		If IsNull(ls_langtype) Then ls_langtype =ls_sys_langtype

		ls_validkey_loc = idw_data[1].object.new_validkey_loc[1]		
		ls_gkid = idw_data[1].object.new_gkid[1]
		ls_auth_method = idw_data[1].object.new_authmethod[1]
		If IsNull(ls_validkey_loc) Then ls_validkey_loc = ""
		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""		

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
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
		
		If ls_gkid = "" Then
			f_msg_usr_err(200, is_Title, "GKID")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_gkid")
			Return 
		End If		
		
		If ls_validkey_loc = "" Then
			f_msg_usr_err(200, is_title, "인증KEY Location")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey_loc")
			Return
		End If

		//xener service IPPhone 일때는 인증방법  Check ...
		If is_data[5] = 'Y' Then
			
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				ls_ip_address = idw_data[1].object.new_ipaddress[1]
				If IsNull(ls_ip_address) Then ls_ip_address = ""				
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_ipaddress")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				ls_h323id = idw_data[1].object.new_h323id[1]
				If IsNull(ls_h323id) Then ls_h323id = ""							
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_h323id")
					Return 
				End If		
			End If
			
		End IF

		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(*)
		  into :ll_cnt
		 from validinfo
		where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
						to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
				  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and	validkey = :ls_validkey and svctype = :is_data[3];
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
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
			  gkid, customerid, validkey_loc,
			  svccod, svctype, priceplan, 
			  orderno, contractseq, langtype,
			  validitem1, validitem2, validitem3, auth_method,
			  crt_user, crtdt, pgm_id, updt_user, updtdt )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				:ls_gkid, customerid, :ls_validkey_loc,
				svccod, :is_data[3], priceplan,
				:ldc_svcorderno, contractseq, :ls_langtype,
				:ls_customernm, :ls_ip_address, :ls_h323id, :ls_auth_method,
				:gs_user_id, sysdate, :is_data[4], :gs_user_id, sysdate
		   from contractmst
		  where to_char(contractseq) = :is_data[2];

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey + "]가  추가되었습니다.")
		
		commit;
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_05 ();//"b1w_validkey_update_popup_1_1%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf
Long ll_cnt

//"b1w_validkey_update_popup_2_2%ue_save"
String ls_gkid, ls_auth_method, ls_cusnm, ls_ip_address, ls_h323id, ls_ref_desc, ls_act_status
String ls_customernm, ls_svccod, ls_sys_langtype, ls_langtype, ls_svctype
decimal ldc_svcorderno

//공통 
String ls_sysdt, ls_cid, ls_validkeyloc, ls_temp

//Ver 2.0 추가
String ls_customerid, ls_contractseq, ls_partner, ls_orderno, ls_validkeymst_status[]


String ls_activedt  //2005.04.18 juede [fromdt >= activedt ] 

ii_rc = -1

//인증Key 관리모듈포함 version 2.0 khpark modify 2004.06.02.

//validkeymst 상태(is_caller 모두 사용함으로 상단에 코팅)
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P400", ls_ref_desc)   
If ls_temp = "" Then Return 
fi_cut_string(ls_temp, ";" , ls_validkeymst_status[])   //인증Key관리상태(생성;개통;해지)

Choose Case is_caller
	Case "b1w_validkey_update_popup_1_1%ue_save"          //인증Key 관리모듈포함 version 2.0
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey
//		lu_dbmgr.is_data[3]  = is_pgm_id
//		lu_dbmgr.is_data[4]  = is_xener_svc               //제너서비스여부
//      lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt        //validkeytype count

		idw_data[1].accepttext()
		
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return

		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt   = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_svctype = idw_data[1].object.svctype[1]
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
        If IsNull(ls_langtype) or ls_langtype = "" Then 
			ls_langtype = ls_sys_langtype
		End IF
		If IsNull(ls_cid) Then ls_cid = ""
		If IsNull(ls_validkeyloc) Then ls_validkeyloc = ""

		ls_svccod = idw_data[1].object.svccod[1]
		If IsNull(ls_svccod) Then ls_svccod = ""
//		ls_gkid = idw_data[1].object.new_gkid[1]		
		ls_auth_method = idw_data[1].object.new_auth_method[1]
//		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""
		ls_ip_address = idw_data[1].object.ip_address[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
    	ls_h323id = idw_data[1].object.h323id[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							

		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
		If IsNull(ls_customerid) Then ls_customerid = ""		
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
		If IsNull(ls_partner) Then ls_partner = ""	
		ls_orderno = String(idw_data[1].object.orderno[1])   
		If IsNull(ls_orderno) Then ls_orderno = '0'
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

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

		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---start
		If ls_fromdt < ls_activedt Then
			f_msg_usr_err(210, is_Title, "적용시작일은 개통일자 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If				
		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---end		
		
		
		//xener IPPhone 서비스코드는 인증방법기타 check 
		If is_data[4] = 'Y' Then

//			If ls_gkid = "" Then
//				f_msg_usr_err(200, is_Title, "GKID")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("new_gkid")
//				Return 
//			End If
		
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ip_address")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("h323id")
					Return 
				End If		
			End If
		End IF
		
		
		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		 from validinfo
		where validkey = :ls_validkey
		  and to_char(fromdt,'yyyymmdd') = :ls_fromdt and svctype = :ls_svctype;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
	
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			return 
		End if
		
		//변경전 Key = 변경후 Key 날짜 중복check 루틴 뺀다.(update적용종료일되므로)
		If is_data[2] <> ls_validkey Then
			
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
							to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
					  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				return 
			End if

			IF ii_data[1] > 0 Then
				
				//VALIDKEYMST UPDATE
				Update validkeymst
				   set status = :ls_validkeymst_status[3], sale_flag = '0', activedt = null,
					   customerid = null,  orderno = null, contractseq = null,
					   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
				  Where validkey = :is_data[2]
				    and contractseq = :ls_contractseq ;
				  
				 If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Update validkeymst Table 1(old)")				
					Return 

				 End If
				 
				//VALIDKEYMST_LOG INSERT
				 Insert Into validkeymst_log
				   (validkey, seq, status, actdt, customerid, 
					contractseq, partner, crt_user, crtdt, pgm_id)
				 Select validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[3], to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid,
						  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[3] 
				    From validkeymst
   				   Where validkey = :is_data[2];
				 
				 If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table 1(old)")				
					Return 
				 End If

				 Update validkeymst
				   set status = :ls_validkeymst_status[2],   sale_flag = '1',   activedt = to_date(:ls_fromdt,'yyyy-mm-dd'),
					   customerid = :ls_customerid,  orderno = :ls_orderno,   contractseq = :ls_contractseq ,
					   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[3] 
				  Where validkey = :ls_validkey;
				  
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Update validkeymst Table 2(new)")					
					Return 
				End If
			
			    Insert Into validkeymst_log
				   (validkey, seq, status, actdt, customerid, 
					contractseq, partner, crt_user, crtdt, pgm_id)
				 Select  validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[2], to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid,
						  :ls_contractseq, :ls_partner, :gs_user_id, sysdate, :is_data[3]
				   From validkeymst 
				  Where validkey = :ls_validkey;
						  
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table 2(new)")				
					Return 
				End If
				
			End IF
			
		End IF
	
//		ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')

		Update validinfo
		Set use_yn = 'N',
		    todt = to_date(:ls_fromdt,'yyyy-mm-dd'),
			updt_user = :gs_user_id,
		    updtdt = sysdate,
			pgm_id = :is_data[3]
		Where validkey = :is_data[2]
		 And to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
			Return 
		End If

		//Insert
		insert into validinfo
		    ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  validitem, gkid, customerid,
			  svccod, svctype, priceplan, 
			  orderno, contractseq, validitem1,
			  validitem2, validitem3, auth_method,
			  validkey_loc, crt_user, crtdt,
			  pgm_id, updt_user, updtdt, langtype )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				validitem, gkid, customerid,
				svccod, svctype, priceplan,
				orderno, contractseq, :ls_cid,
				:ls_ip_address, :ls_h323id, :ls_auth_method,
				:ls_validkeyloc, :gs_user_id, sysdate,
				:is_data[3], :gs_user_id, sysdate, :ls_langtype
		   from validinfo
		  where validkey = :is_data[2]
		    and to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey + "]로 변경되었습니다.")
		
		commit;
		
	Case "b1w_validkey_update_popup_2_1%ue_save"			//인증Key 관리모듈포함 version 2.0
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_itemcod
//		lu_dbmgr.is_data[2]  = is_contractseq
//	    lu_dbmgr.is_data[3]  = is_svctype
//		lu_dbmgr.is_data[4]  = is_pgm_id
//		lu_dbmgr.is_data[5]  = is_xener_svc     //제너서비스여부('Y'/'N')
//      lu_dbmgr.is_data[6]  = is_status         //개통상태 코드
//      lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt        //validkeytype count

		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
		//gkid default 값
		ls_gkid = fs_get_control("00", "G100", ls_ref_desc)
		
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_cid     = idw_data[1].object.new_cid[1]
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
		
//		ls_gkid = idw_data[1].object.new_gkid[1]
		ls_auth_method = idw_data[1].object.new_authmethod[1]
//		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""		
	    ls_ip_address = idw_data[1].object.new_ipaddress[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
		ls_h323id = idw_data[1].object.new_h323id[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							

		ls_customerid = idw_data[1].object.customerid[1]              // ver2.0 khpark add
		If IsNull(ls_customerid) Then ls_customerid = ""		
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		If IsNull(ls_contractseq) Then ls_contractseq = '0'
		ls_partner = idw_data[1].object.contractmst_reg_partner[1] 
		If IsNull(ls_partner) Then ls_partner = ""	

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

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
		
		
		//xener service IPPhone 일때는 인증방법  Check ...
		If is_data[5] = 'Y' Then
			
//			If ls_gkid = "" Then
//				f_msg_usr_err(200, is_Title, "GKID")
//				idw_data[1].SetFocus()
//				idw_data[1].SetColumn("new_gkid")
//				Return 
//			End If
			
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_ipaddress")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_h323id")
					Return 
				End If		
			End If
			
		End IF
		
		
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(*)
		  into :ll_cnt
		 from validinfo
		where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
						to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
				  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and	validkey = :ls_validkey and svctype = :is_data[3];
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
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
                status, 'Y', :ls_vpassword,
				customerid, svccod,
				:is_data[3], priceplan,
				:ldc_svcorderno, contractseq, :ls_gkid,
				:ls_cid, :ls_ip_address, :ls_h323id, :ls_auth_method,
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

		
		IF ii_data[1] > 0 Then

			Update validkeymst
			   set status = :ls_validkeymst_status[2],   sale_flag = '1',  
				   activedt = to_date(:ls_fromdt,'yyyy-mm-dd'),
				   customerid = :ls_customerid,  orderno = :ldc_svcorderno,  
				   contractseq = :ls_contractseq ,
				   updt_user = :gs_user_id,  updtdt = sysdate,   pgm_id = :is_data[4] 
			  Where validkey = :ls_validkey;
			  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Update validkeymst Table")					
				Return 
			End If
				
			Insert Into validkeymst_log
			   (validkey, seq, status, 
			    actdt, customerid, contractseq, 
				partner, crt_user, crtdt, pgm_id)
			 Select :ls_validkey, seq_validkeymstlog.nextval, :ls_validkeymst_status[2],
		              to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_customerid, :ls_contractseq,
					  :ls_partner, :gs_user_id, sysdate, :is_data[4] 
			   From validkeymst
			 Where validkey = :ls_validkey;
					  
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				f_msg_sql_err(is_title, is_caller + " Insert validkeymst_log Table")				
				Return 
			End If
			
		End IF
		
		f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey + "]가  추가되었습니다.")
		
		commit;
		
	Case "b1w_validkey_update_popup_3_1%ue_save"			//인증Key 관리모듈포함 version 2.0
//	lu_dbmgr.is_caller = "b1w_validkey_update_popup_3_1%ue_save"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.idw_data[1] = dw_detail
//	lu_dbmgr.is_data[1]  = ls_todt
//	lu_dbmgr.is_data[2]  = is_pgm_id

		idw_data[1].accepttext()
		
		ls_validkey = idw_data[1].object.validkey[1]
		If IsNull(ls_validkey) Then ls_validkey = ""

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
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose
//
ii_rc = 0
end subroutine

public subroutine uf_prc_db_01 ();/*-------------------------------------------------------------------------
	name	: uf_prc_db_01()
	desc.	: Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2003.02.05
	programer : Park Kyung Hae (parkkh)
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
			f_msg_info(9000, is_title, "인증KEY[" +is_data[1] +"]는 없는 인증KEY입니다.")	
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

//	    다른번호로 같은 날짜에 두개를 사용가능하므로...이 루틴삭제하고... 계약번호로 값을 가지고 온다...
//		SELECT validkey, svctype, to_char(fromdt,'yyyymmdd'), use_yn
//	     INTO :is_data[2], :is_data[3], :is_data[5], :is_data[6]
//		 FROM validinfo
//		WHERE to_char(contractseq) = :is_data[1]
//		  AND fromdt = ( select max(fromdt)
//		  				   from validinfo
//						  where to_char(contractseq) = :is_data[1] );
//
//		IF sqlca.sqlcode < 0 Then
//			f_msg_sql_err(is_title, is_caller + "SELECT validkey, svctype, status from validinfo")			
//			ii_rc = -1			
//			Return 		
//		ELSEIF sqlca.sqlcode = 100 Then
//			f_msg_sql_err(is_title, is_caller + "SELECT validkey, svctype, status from validinfo")			
//			ii_rc = -1			
//			Return 
//		End If

		//itemcod
//		String ls_ref_desc
//		
//		SELECT itm.itemcod
//		Into :is_data[2]
//		FROM itemmst itm,  priceplandet det
//		WHERE (itm.itemcod = det.itemcod) and  
//				itm.pricetable = (select ref_content from sysctl1t 
//										where module = 'B0' and ref_no = 'P100')
//				and priceplan = :is_data[5];
//										
//		If SQLCA.SQLCode < 0 Then
//			RollBack;		
//			ii_rc = -1			
//			f_msg_sql_err(is_title, is_caller + " Select ITEMMST Table")				
//			Return 
//		ElseIf SQLCA.SQLCode = 0 Then
//			is_data[2] = '0000'
//	   End If		

End Choose

ii_rc = 0 
end subroutine

public subroutine uf_prc_db_04 ();
//"b1w_validkey_update_popup_1_cl%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf
Long ll_cnt

//"b1w_validkey_update_popup_2_cl%ue_save"
String ls_gkid, ls_auth_method, ls_cusnm, ls_ip_address, ls_h323id, ls_ref_desc, ls_act_status
String ls_customernm, ls_svccod, ls_sys_langtype, ls_langtype, ls_svctype
decimal ldc_svcorderno
//공통 
String ls_sysdt, ls_cid, ls_validkeyloc

//2005.04.18 juede 날짜확인 변경  --- start
String ls_activedt, ls_contractseq
Date ld_activedt 
//2005.04.18 juede 날짜확인 변경  --- end

ii_rc = -1

Choose Case is_caller
	Case "b1w_validkey_update_popup_1_cl%ue_save"		//Com-N-Life
//		lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_x1%ue_save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1]  = is_fromdt
//		lu_dbmgr.is_data[2]  = is_validkey
//		lu_dbmgr.is_data[3]  = is_pgm_id
//		lu_dbmgr.is_data[4]  = is_xener_svc         //제너서비스여부
//    lu_dbmgr.is_data[5]  = ls_contractseq       //2005.04.18 juede add

		idw_data[1].accepttext()
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return

		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt   = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_svctype = idw_data[1].object.svctype[1]
		ls_cid     = idw_data[1].object.cid[1]
		ls_validkeyloc = idw_data[1].object.new_validkey_loc[1]
		
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_fromdt_1) Then ls_fromdt_1 = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If IsNull(ls_new_todt) or ls_new_todt = "" Then 
			ls_new_todt = ""
			ls_new_todt_cf = '99991231'
		End if
		If IsNull(ls_vpassword) Then ls_vpassword = ""
        If IsNull(ls_langtype) Then ls_langtype = ls_sys_langtype
		If IsNull(ls_cid) Then ls_cid = ""
		If IsNull(ls_validkeyloc) Then ls_validkeyloc = ""

		ls_svccod = idw_data[1].object.svccod[1]
		If IsNull(ls_svccod) Then ls_svccod = ""
		//ls_gkid = idw_data[1].object.new_gkid[1]		
		ls_auth_method = idw_data[1].object.new_auth_method[1]
		//If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""
		ls_ip_address = idw_data[1].object.ip_address[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
    	ls_h323id = idw_data[1].object.h323id[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

      //2005.04.18 juede 날짜확인 fromdt >= activedt 로 수정 -----start
		select to_char(activedt,'yyyymmdd')
		  into :ls_activedt
		 from contractmst
		where contractseq=:is_data[5];
		
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select activedt ")				
			Return 
		End If		
		
		If IsNull(ls_activedt) Then ls_activedt = ""
		
		If ls_fromdt < ls_activedt Then
			f_msg_usr_err(210, is_Title, "")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If				
		//2005.04.18 juede 날짜체크 변경 [fromdt >= activedt]---end		
		
		//// 날짜 체크
		//ls_sysdt = string(fdt_get_dbserver_now(),'yyyymmdd')
		//If ls_fromdt <= ls_sysdt Then
		//	f_msg_usr_err(210, is_Title, "적용시작일은 오늘날짜보다 커야합니다.")
		//	idw_data[1].SetFocus()
		//	idw_data[1].SetColumn("new_fromdt")
		//	Return
		//End If		
	
		//xener IPPhone 서비스코드는 인증방법기타 check 
		If is_data[4] = 'Y' Then

		//If ls_gkid = "" Then
		//	f_msg_usr_err(200, is_Title, "GKID")
		//	idw_data[1].SetFocus()
		//	idw_data[1].SetColumn("new_gkid")
		//	Return 
		//End If
		
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ip_address")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("h323id")
					Return 
				End If		
			End If
		End IF
		
		
		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		 from validinfo
		where validkey = :ls_validkey
		  and to_char(fromdt,'yyyymmdd') = :ls_fromdt and svctype = :ls_svctype;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
	
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			return 
		End if
		
		//변경전 Key = 변경후 Key 날짜 중복check 루틴 뺀다.(update적용종료일되므로)
		If is_data[2] <> ls_validkey Then
			
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
							to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
					  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
				Return 
			End If
		
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				return 
			End if
		End IF
	
		//ls_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')
		
		Update validinfo
		Set use_yn = 'N',
		    todt = to_date(:ls_fromdt,'yyyy-mm-dd'),
			updt_user = :gs_user_id,
		    updtdt = sysdate,
			pgm_id = :is_data[3]
		Where validkey = :is_data[2]
		 And to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table(todt,use_yn)")				
			Return 
		End If

		//Insert
		insert into validinfo
		    ( validkey, fromdt, todt, 
			  status, use_yn, vpassword,
			  validitem, gkid, customerid,
			  svccod, svctype, priceplan, 
			  orderno, contractseq, validitem1,
			  validitem2, validitem3, auth_method,
			  validkey_loc, crt_user, crtdt,
			  pgm_id, updt_user, updtdt, langtype )
	     select :ls_validkey, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
                status, 'Y', :ls_vpassword,
				validitem, gkid, customerid,
				svccod, svctype, priceplan,
				orderno, contractseq, :ls_cid,
				:ls_ip_address, :ls_h323id, :ls_auth_method,
				:ls_validkeyloc, :gs_user_id, sysdate,
				:is_data[3], :gs_user_id, sysdate, :ls_langtype
		   from validinfo
		  where validkey = :is_data[2]
		    and to_char(fromdt,'yyyymmdd') = :is_data[1] and svctype = :ls_svctype;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey + "]로 변경되었습니다.")
		
		commit;
		
	Case "b1w_validkey_update_popup_2_cl%ue_save"			//Com-N-Life
		//lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_cl%ue_save"
		//lu_dbmgr.is_title = Title
		//lu_dbmgr.idw_data[1] = dw_detail
		//lu_dbmgr.is_data[1]  = is_itemcod
		//lu_dbmgr.is_data[2]  = is_contractseq
		//lu_dbmgr.is_data[3]  = is_svctype
		//lu_dbmgr.is_data[4]  = is_pgm_id
		//lu_dbmgr.is_data[5]  = is_xener_svc     //제너서비스여부('Y'/'N')
		//lu_dbmgr.is_data[6]  = is_status         //개통상태 코드

		idw_data[1].accepttext()
		
		ls_ref_desc = ""
		ls_act_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
		ls_sys_langtype= fs_get_control("B1", "P204", ls_ref_desc)    //Default 언어 멘트
		If ls_sys_langtype = "" Then Return
		
		//gkid default 값
		ls_gkid = fs_get_control("00", "G100", ls_ref_desc)
		
		ls_validkey = idw_data[1].object.new_validkey[1]
		ls_fromdt_1 = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword = idw_data[1].object.new_vpassword[1]
		ls_langtype = idw_data[1].object.new_langtype[1]
		ls_cid     = idw_data[1].object.new_cid[1]
		ls_validkeyloc = idw_data[1].object.new_validkey_loc[1]
		
		ls_activedt = String(idw_data[1].object.activedt[1],'yyyymmdd') //2005.04.18 juede 인증키 날짜확인 변경
		If IsNull(ls_activedt) Then ls_activedt = ""                    //2005.04.18 juede 인증키 날짜확인 변경
		
		
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
		If IsNull(ls_langtype) Then ls_langtype = ls_sys_langtype
		If IsNull(ls_cid) Then ls_cid = ""
		If IsNull(ls_validkeyloc) Then ls_validkeyloc = ""
		
//		ls_gkid = idw_data[1].object.new_gkid[1]
		ls_auth_method = idw_data[1].object.new_authmethod[1]
//		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""		
	    ls_ip_address = idw_data[1].object.new_ipaddress[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
		ls_h323id = idw_data[1].object.new_h323id[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							

		If ls_validkey = "" Then
			f_msg_usr_err(200, is_title, "인증KEY")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_validkey")
			Return
		End If
		
		If ls_vpassword = "" Then
			f_msg_usr_err(200, is_title, "인증PassWord")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_vpassword")
			Return
		End If

		If ls_fromdt = "" Then
			f_msg_usr_err(200, is_title, "적용시작일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("new_fromdt")
			Return
		End If

		// 날짜 체크
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
		
		//xener service IPPhone 일때는 인증방법  Check ...
		If is_data[5] = 'Y' Then
			
		//If ls_gkid = "" Then
		//	f_msg_usr_err(200, is_Title, "GKID")
		//	idw_data[1].SetFocus()
		//	idw_data[1].SetColumn("new_gkid")
		//	Return 
		//End If
			
			If ls_auth_method = "" Then
				f_msg_usr_err(200, is_Title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("new_authmethod")
				Return
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, is_Title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_ipaddress")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, is_Title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("new_h323id")
					Return 
				End If		
			End If
			
		End IF
		
		
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		select count(*)
		  into :ll_cnt
		 from validinfo
		where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
						to_char(fromdt,'yyyymmdd') <= :ls_new_todt_cf)  or
				  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
				   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and	validkey = :ls_validkey and svctype = :is_data[3];
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
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
                status, 'Y', :ls_vpassword,
				customerid, svccod,
				:is_data[3], priceplan,
				:ldc_svcorderno, contractseq, :ls_gkid,
				:ls_cid, :ls_ip_address, :ls_h323id, :ls_auth_method,
				:ls_validkeyloc, :gs_user_id, sysdate, :is_data[4], :gs_user_id, sysdate, :ls_langtype
		   from contractmst
		  where to_char(contractseq) = :is_data[2];

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Error(validinfo)")
			Return 
		End If	
		
		f_msg_info(9000, is_title, "계약 SEQ[" + is_data[2] +"]에 인증KEY["+ ls_validkey + "]가  추가되었습니다.")
		
		commit;
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose
//
ii_rc = 0
end subroutine

on b1u_dbmgr4.create
call super::create
end on

on b1u_dbmgr4.destroy
call super::destroy
end on

