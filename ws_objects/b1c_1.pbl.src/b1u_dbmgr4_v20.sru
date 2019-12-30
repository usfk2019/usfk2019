$PBExportHeader$b1u_dbmgr4_v20.sru
$PBExportComments$인증Key change/add/term -> moohannet
forward
global type b1u_dbmgr4_v20 from u_cust_a_db
end type
end forward

global type b1u_dbmgr4_v20 from u_cust_a_db
end type
global b1u_dbmgr4_v20 b1u_dbmgr4_v20

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_01 ();//"b1w_validkey_update_popup_1_1_v20%ue_save"
String ls_validkey, ls_fromdt_1, ls_fromdt, ls_new_todt, ls_vpassword, ls_todt, ls_new_todt_cf, &
       ls_crt_kind_code[], ls_validkey_type, ls_validkey_typenm, ls_crt_kind, ls_prefix, &
		 ls_type, ls_used_level, ls_priceplan, ls_validitem_yn, ls_validkey_type_h, ls_crt_kind_h, &
		 ls_prefix_h, ls_auth_method_h, ls_type_h, ls_used_level_h, ls_auto_validkey, ls_validkey_loc, &
		 ls_n_auth_method, ls_auto_validitem, ls_n_validitem3, ls_n_validitem2, ls_n_validitem1, &
		 ls_n_langtype, ls_validkey_1, ls_n_validitem3_1
Long   ll_cnt, li_return, ll_length_h, ll_length, li_random_length
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

//Moohannet kem modify 추가 2005.11.09
String ls_new_gkid, ls_new_validitem, ls_new_subseq    //서버IP1/2, Port#


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
	Case "b1w_validkey_update_popup_1_1_v20_moohan%ue_save"          //인증Key 관리모듈포함 version 2.0
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
		
		ls_addition_code = is_data[5]
		ls_addition_itemcod = is_data[6]
		ll_callforward_seq_old = il_data[1]
		ld_addition_item_todt = id_data[1]
    	If IsNull(ls_addition_code) Then ls_addition_code = ""
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
		ls_new_gkid     = fs_snvl(idw_data[1].Object.new_gkid[1], '')
		ls_new_validitem = fs_snvl(idw_data[1].Object.new_validitem[1], '')
		ls_new_subseq   = fs_snvl(idw_data[1].Object.new_subseq[1], '')
		
		
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
		
		
		ls_svccod      = fs_snvl(idw_data[1].object.svccod[1]         , '')
		ls_ip_address  = fs_snvl(idw_data[1].object.ip_address[1]     , '')
		ls_auth_method = fs_snvl(idw_data[1].object.new_auth_method[1], '')
    	ls_h323id      = fs_snvl(idw_data[1].object.h323id[1]         , '')
		ls_customerid  = fs_snvl(idw_data[1].object.customerid[1]     , '')              // ver2.0 khpark add
		ls_contractseq = String(idw_data[1].object.contractseq[1])   
		ls_partner     = fs_snvl(idw_data[1].object.reg_partner[1]    , '')
		ls_orderno     = String(idw_data[1].object.orderno[1])   

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
		

//		//해당 validkey와 fromdt로 data가 있는지 확인한다.(validinfo PK)
//		ll_cnt = 0
//		select count(validkey)
//		  into :ll_cnt
//		 from validinfo
//		where validkey = :ls_validkey
//		  and to_char(fromdt,'yyyymmdd') = :ls_fromdt 
//		  and svccod = :ls_svccod;
//		//and svctype = :ls_svctype;   ohj 05.05.03
//				  
//		If sqlca.sqlcode < 0 Then
//			f_msg_sql_err(is_title, is_caller+"Select validinfo (count)")				
//			Return 
//		End If
//	
//		If ll_cnt > 0 Then
//			f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey + "]에 적용시작일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
//			return 
//		End if		
		
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
			 
			//VALIDKEYMST_LOG INSERT   변경전 인증키 상태변경 로그남기기
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
		
		//인증KEY 인증KeyType이 자원관리인 경우만 처리		
		If ls_crt_kind = ls_crt_kind_code[4]  Then 
			
			//변경된 인증key 상태 '개통'으로 update
			Update validkeymst
				set status      = :ls_validkeymst_status[2]
				  , sale_flag   = '1'
				  , activedt    = to_date(:ls_fromdt,'yyyy-mm-dd')
				  , customerid  = :ls_customerid
				  , orderno     = :ls_orderno
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
		
		//h323id 관리
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
		
//			End IF
	
      //변경전 인증키 미사용으로 update
		Update validinfo
		   Set use_yn    = 'N'
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
					 , validkey_loc  , langtype   , subseq
					 , crt_user      , crtdt  	   , pgm_id      
					 , updt_user     , updtdt                        )
	        select :ls_validkey_1, to_date(:ls_fromdt,'yyyy-mm-dd')
			       , to_date(:ls_new_todt,'yyyy-mm-dd')
					 , status, 'Y'   , :ls_vpassword
					 , :ls_new_validitem , :ls_new_gkid , customerid
					 ,	svccod        , svctype
					 , priceplan     , orderno
					 , contractseq   , :ls_cid,   :ls_ip_address
					 , :ls_n_validitem3_1 , :ls_auth_method,	:ls_validkey_loc
					 , :ls_langtype  , :ls_new_subseq
					 , :gs_user_id   , sysdate,   :is_data[3]
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
		
		ls_callforwardno_old = idw_data[1].object.callforwardno[1]
		ls_callforwardno_new = idw_data[1].object.new_callforwardno[1]
      ls_password_new =  idw_data[1].object.new_password[1]
      ls_callingnum_all = idw_data[1].object.callingnum[1]
		ls_call_todt = string(RelativeDate(date(ls_fromdt_1), -1),'yyyymmdd')	//변경후 적용시작일 -1 일 
		
		If IsNull(ls_callforwardno_old) Then ls_callforwardno_old = ""
		If IsNull(ls_callforwardno_new) Then ls_callforwardno_new = ""
		If IsNull(ls_password_new) Then ls_password_new = ""
		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""
		
	   //khpark add 2005-07-11 start(착신전환부가서비스)
		CHOOSE CASE ls_addition_code  
			CASE ls_callforward_code[1]   //착신전환일반유형일때 

				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
					
					Update callforwarding_info
					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
						  updtdt = sysdate,
						  pgm_id = :is_data[3]
					where seq = :ll_callforward_seq_old;						
				End If
				
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
					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
							 :gs_user_id,sysdate, :is_data[3]);
							 
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
						ii_rc = -1						
						RollBack;
						Return 
					End If									 

				End IF
					
			CASE ls_callforward_code[2]     //착신전환비밀번호인증일때

				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
					
					Update callforwarding_info
					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
						  updtdt = sysdate,
						  pgm_id = :is_data[3]
					where seq = :ll_callforward_seq_old;
					
				End If
				
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
					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
							 :gs_user_id,sysdate, :is_data[3] );

					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_info)")
						ii_rc = -1						
						RollBack;
						Return 
					End If									 

				End IF						
				
			CASE ls_callforward_code[3]     //착신전환발신번호인증일때
				
				If ls_callforwardno_old <> "" Then    //변경전 착신전환번호가 있을 경우
					
					Update callforwarding_info
					  set todt = to_date(:ls_call_todt,'yyyy-mm-dd'),
						  updtdt = sysdate,
						  pgm_id = :is_data[3]
					where seq = :ll_callforward_seq_old;						
				End If					
				
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
					Values ( :ll_callforward_seq_new, :ls_orderno,:ls_contractseq,:ls_addition_itemcod,
							 :ls_addition_code,:ls_validkey_1,:ls_password_new,
							 :ls_callforwardno_new,to_date(:ls_fromdt,'yyyy-mm-dd'),:ld_addition_item_todt,
							 :gs_user_id,sysdate, :is_data[3] );

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
							 :gs_user_id,sysdate, :is_data[3] );

						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(callforwarding_auth)")
							ii_rc = -1						
							RollBack;
							Return 
						End If									 
							 
					Next
				End IF						
				
		END CHOOSE
		//khpark add 2005-07-11 start							
		
		f_msg_info(9000, is_title, "인증KEY[" +is_data[2] +"]에서 인증KEY["+ ls_validkey_1 + "]로 변경되었습니다.")
		commit;
		
	Case "b1w_validkey_update_popup_2_1_v20_moohan%ue_save"			//인증Key 관리모듈포함 version 2.0
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
		//ls_gkid = fs_get_control("00", "G100", ls_ref_desc)
		
		ls_validkey    = idw_data[1].object.new_validkey[1]     //추가인증키
		ls_fromdt_1    = string(idw_data[1].object.new_fromdt[1],'yyyy-mm-dd')
		ls_fromdt      = string(idw_data[1].object.new_fromdt[1],'yyyymmdd')
		ls_new_todt    = string(idw_data[1].object.new_todt[1],'yyyymmdd')		
		ls_new_todt_cf = ls_new_todt
		ls_vpassword   = idw_data[1].object.new_vpassword[1]
		ls_langtype    = idw_data[1].object.new_langtype[1]
		ls_cid         = idw_data[1].object.cid[1]
		ls_validkeyloc = fs_snvl(idw_data[1].object.new_validkey_loc[1], '')
		ls_new_gkid     = fs_snvl(idw_data[1].Object.new_gkid[1], '')
		ls_new_validitem = fs_snvl(idw_data[1].Object.new_validitem[1], '')
		ls_new_subseq   = fs_snvl(idw_data[1].Object.new_subseq[1], '')
		
		
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
				  svctype, priceplan, orderno, 
				  contractseq, gkid, validitem,
				  validitem1, validitem2, validitem3, auth_method,
				  validkey_loc, crt_user, crtdt, pgm_id,
				  updt_user, updtdt, langtype, subseq)
		  select :ls_validkey_1, to_date(:ls_fromdt,'yyyy-mm-dd'), to_date(:ls_new_todt,'yyyy-mm-dd'), 
					status, 'Y', :ls_vpassword,
					customerid, svccod,
					:is_data[3], priceplan,	:ldc_svcorderno, 
					contractseq, :ls_new_gkid, :ls_new_validitem,
					:ls_cid, :ls_ip_address, :ls_n_validitem3_1, :ls_auth_method,
					:ls_validkeyloc, :gs_user_id, sysdate,	:is_data[4], 
					:gs_user_id, sysdate, :ls_langtype, :ls_new_subseq
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
		
	Case "b1w_validkey_update_popup_3_1_v20_moohan%ue_save"			//인증Key 관리모듈포함 version 2.0
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
end subroutine

public subroutine uf_prc_db ();//b1w_reg_validkey_update_1_v20_mh
/*-------------------------------------------------------------------------
	name	: uf_prc_db()
	desc.	: Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2005.05.02
	programer : oh hye jin 
	            modify Moohannet kem 2005.11.09 
--------------------------------------------------------------------------*/	

//"b1w_reg_validkey_update_moohan%ue_change"
String ls_svctype, ls_status, ls_fromdt, ls_use_yn, ls_svccod, ls_validinfo, ls_contractseq
String ls_ref_desc, ls_svc_status[], ls_term, ls_temp
String ls_callforward_code[]

//"b1w_reg_validkey_update_moohan%ue_add"
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
	Case "b1w_reg_validkey_update_1_v20_moohan%ue_change"		//통합빌링 & xener
	    
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
		
	Case "b1w_reg_validkey_update_1_v20_moohan%ue_add"		
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
		 
		is_data[9] = 'Y'		
		//khpark modify add 2005-07-12 end

		Case "b1w_reg_validkey_update_1_v20_moohan%ue_term"
	
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
				   AND status <> :ls_term 
					AND to_char(contractseq) = :ls_contractseq
				 GROUP BY fromdt, svctype;
				
				
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

public subroutine uf_prc_db_02 ();//"b1w_reg_validinfoserver_mod%ue_save"
String ls_worktype, ls_svctype, ls_status, ls_customerid, ls_prcdt, ls_auth_method, ls_validkey,  ls_vpassword
String ls_ip_address, ls_h323id, ls_block_type, ls_coid, ls_gkid, ls_check_yn
String ls_ref_desc, ls_code, ls_mac
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
		
	Case "b1w_reg_validinfoserver_mod_1_v20%ue_save"
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
				ls_mac    = idw_data[1].Object.mac[li_cnt]
				If IsNull(ls_auth_method) Then ls_auth_method = ""
				If IsNull(ls_ip_address) Then ls_ip_address = ""
				If IsNull(ls_h323id) Then ls_h323id = ""
				If IsNull(ls_mac) Then ls_mac = ""

				//Insert
				Insert Into validinfoserver
				   ( seqno, worktype, svctype, status, validkey, vpassword,
					 customerid, cworkdt, prcdt, result,
					 crt_user, customerm, ip_address, h323id, 
					 auth_method, gkid, chg_number, block_type, ogn, coid, flag, cid, svccod, mac )
			     select seq_validinfoserver.nextval, worktype, svctype, status, validkey, vpassword,
					    customerid, sysdate, prcdt, :is_data[4],
					    :is_data[1], customerm, :ls_ip_address, :ls_h323id,
					    :ls_auth_method, gkid, chg_number, block_type, ogn, coid, :ls_code, cid, svccod, :ls_mac
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

on b1u_dbmgr4_v20.create
call super::create
end on

on b1u_dbmgr4_v20.destroy
call super::destroy
end on

