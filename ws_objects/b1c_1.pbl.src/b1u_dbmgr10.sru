$PBExportHeader$b1u_dbmgr10.sru
$PBExportComments$[islim] 인증Key 요청처리DB
forward
global type b1u_dbmgr10 from u_cust_a_db
end type
end forward

global type b1u_dbmgr10 from u_cust_a_db
end type
global b1u_dbmgr10 b1u_dbmgr10

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
end prototypes

public subroutine uf_prc_db ();//Save Check
String ls_reqtype, ls_req_status, ls_req_validkey, ls_req_customerid, ls_req_svccod
String ls_req_contractseq, ls_vpassword, ls_req_auth_method
String ls_req_validitem2, ls_req_validitem1, ls_req_validitem3
String ls_req_remark, ls_req_langtype, ls_bef_validkey
String ls_tmp, ls_ref_desc, ls_name[], ls_xener
String ls_vreqno, ls_remark, ls_reqdt, ls_today
String ls_auth_method_stcip, ls_auth_method_both
Dec ldc_vreqno, ldc_svcorderno
Long ll_rows , i, ll_result, ll_rc
Integer li_cnt_result, li_result

String ls_con_priceplan, ls_svctype
String ls_con_status, ls_default_lang, ls_default_gkid, ls_validkey_loc
String ls_key_status[], ls_req_partner, ls_complete
Integer li_key_cnt, li_cnt




Choose Case is_caller
	Case "b1w_reg_validkey_req_add%save"
			//lu_dbmgr.is_title  = Title
			//lu_dbmgr.idw_data[1] = dw_detail
			//lu_dbmgr.idw_data[2] = dw_master
			//lu_dbmgr.is_data[1] = ls_vreqno
			//lu_dbmgr.is_data[2] = ls_reqtype
			//lu_dbmgr.is_data[3] = ls_req_status
			//lu_dbmgr.is_data[4] = ls_req_validkey 
			//lu_dbmgr.is_data[5] = ls_reqdt
			//lu_dbmgr.is_data[6] = ls_req_customerid
			//lu_dbmgr.is_data[7] = ls_req_svccod
			//lu_dbmgr.is_data[8] = ls_req_contractseq 
			//lu_dbmgr.is_data[9] = ls_vpassword
			//lu_dbmgr.is_data[10] = ls_req_auth_method 
			//lu_dbmgr.is_data[11] = ls_req_validitem1
			//lu_dbmgr.is_data[12] = ls_req_validitem2
			//lu_dbmgr.is_data[13] = ls_req_validitem3
			//lu_dbmgr.is_data[14] = ls_req_langtype
			//lu_dbmgr.is_data[15] = ls_bef_validkey
			//lu_dbmgr.is_data[16] = ls_remark

			ls_vreqno			=	is_data[1]
			ls_reqtype			=	is_data[2]
			ls_req_status		=	is_data[3]
			ls_req_validkey	=	is_data[4]
			ls_reqdt				=	is_data[5]
			ls_req_customerid	=	is_data[6]
			ls_req_svccod		=	is_data[7]
			ls_req_contractseq =	is_data[8]
			ls_vpassword		=	is_data[9]
			ls_req_auth_method =	is_data[10]
			ls_req_validitem1	=	is_data[11]  //발신번호표시
			ls_req_validitem2	=	is_data[12]  //IPADDRESS
			ls_req_validitem3	=	is_data[13]  //H323ID
			ls_req_langtype	=	is_data[14]
			ls_bef_validkey	=	is_data[15]
			ls_remark			=	is_data[16]
			
			ls_tmp= fs_get_control("B0", "P223", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_con_status    = ls_name[1]   //개통상태
			
			ls_tmp= fs_get_control("B1", "P204", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_lang    = ls_name[1]   //Default 언어멘트
			
			ls_tmp= fs_get_control("00", "G100", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_gkid    = ls_name[1]   //default GKID		
			
			ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_complete    =  ls_name[2]   //처리완료
	
			
			ls_tmp= fs_get_control("B1", "P400", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_key_status[1]   = ls_name[1]   //인증키관리상태(생성;개통;해지;인증키요청)	
			ls_key_status[2]   = ls_name[2]
			ls_key_status[3]   = ls_name[3]
			ls_key_status[4]   = ls_name[4]
			
						
			//validkey_loc
			ls_validkey_loc = idw_data[1].object.validkeyreq_validkey_loc[1]
			ls_con_priceplan = idw_data[1].object.contractmst_priceplan[1]
			ls_req_partner = idw_data[1].object.validkeyreq_req_partner[1]  //등록대리점
			ls_svctype    = idw_data[1].object.svcmst_svctype[1] //서비스타입


			//인증Key개수 확인			
			ll_result=b1fi_validkey_count(is_title,ls_reqdt, ls_req_contractseq, li_key_cnt) 
			
			
			If ll_result <> 1 Then
				f_msg_usr_err(200, is_Title, "해당 계약Seq에 인증KEY 등록은 "+String(li_key_cnt)+" 개까지 등록 가능합니다.~n"+&
								  "더 이상 인증KEY 등록을 할 수 없습니다." )
				Return
			End If
			


			//계약상태가 개통상태인지 check
			If ls_con_status <> (idw_data[1].object.contractmst_status[1]) Then
				f_msg_usr_err(200, is_Title, "개통상태가 아닙니다." )
				Return
			End If
			
				
			ll_result=b1fi_validkey_du_check(is_title,ls_req_validkey,ls_reqdt, ls_svctype, li_key_cnt) 				
			
			If li_key_cnt >0 then
				f_msg_usr_err(200, is_Title, "인증KEY의 적용시작일과 적용종료일이 중복됩니다." )
				return
			End If
			
			
			
			
			SELECT Max(orderno)
			INTO :ldc_svcorderno
			FROM svcorder
			WHERE to_char(ref_contractseq) = :ls_req_contractseq 
			  AND status = :ls_con_status;
			  
			
			
			INSERT INTO validinfo
			(validkey, fromdt, status, use_yn, vpassword, customerid, svccod, svctype,
			 priceplan, orderno, contractseq, gkid, validitem1, validitem2, validitem3,
			 auth_method, validkey_loc, langtype, crt_user, crtdt, pgm_id)
			SELECT :ls_req_validkey, to_date(:ls_reqdt,'yyyymmdd'), status, 'Y', :ls_vpassword, customerid,
			       svccod, :ls_svctype, priceplan, :ldc_svcorderno, contractseq, :ls_default_gkid, 
					 :ls_req_validitem1,:ls_req_validitem2, :ls_req_validitem3, :ls_req_auth_method,
					 :ls_validkey_loc, :ls_req_langtype, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
			FROM contractmst
			WHERE	to_char(contractseq) = :ls_req_contractseq;
			
			
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Insert Error(validinfo)")
				RollBack;
				Return
			End If
		
			
			li_result = b1fi_validkeytype_check(is_title, ls_con_priceplan, li_cnt)
			
			If li_cnt > 0 then
				
				UPDATE validkeymst
				SET status = :ls_key_status[2], 
				    orderno = :ldc_svcorderno,
					 sale_flag = '1',
					 activedt = to_date(:ls_reqdt,'yyyymmdd'),
					 updt_user =:gs_user_id, updtdt = sysdate,
					 pgm_id = :gs_pgm_id[gi_open_win_no]
				WHERE validkey = :ls_req_validkey AND contractseq = :ls_req_contractseq;
				
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_Title, "Update Error(validkeymst)")
					RollBack;
					Return
				End If
				
				INSERT INTO validkeymst_log 
				(validkey, seq, status, actdt, customerid, contractseq, partner, crt_user, crtdt, pgm_id)
				SELECT :ls_req_validkey, seq_validkeymstlog.nextval, :ls_key_status[2], 
				       to_date(:ls_reqdt,'yyyymmdd'), :ls_req_customerid, :ls_req_contractseq, :ls_req_partner,
					  :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
				FROM validkeymst 
				WHERE validkey=:ls_req_validkey and contractseq=:ls_req_contractseq;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_Title, "Insert Error(validkeymst)")
					RollBack;
					Return
				End If
			
			End If
		
		
		 UPDATE validkeyreq
		 SET status = :ls_complete, reqdt =to_date(:ls_reqdt,'yyyymmdd'), 
				 vpassword = :ls_vpassword, validitem1 = :ls_req_validitem1,
				validitem2 = :ls_req_validitem2, validitem3 = :ls_req_validitem3,
				auth_method = :ls_req_auth_method, langtype = :ls_req_langtype,
				remark = :ls_remark, updt_user = :gs_user_id, updtdt= sysdate,
				pgm_id = :gs_pgm_id[gi_open_win_no]
		 WHERE vreqno = :ls_vreqno ;

			
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Update Error(validkeyreq)")
			RollBack;
			Return
		End If	
			
End Choose
end subroutine

public subroutine uf_prc_db_02 ();//Save Check
String ls_reqtype, ls_req_status, ls_req_validkey, ls_req_customerid, ls_req_svccod
String ls_req_contractseq, ls_vpassword, ls_req_auth_method
String ls_req_validitem2, ls_req_validitem1, ls_req_validitem3
String ls_req_remark, ls_req_langtype, ls_bef_validkey
String ls_tmp, ls_ref_desc, ls_name[], ls_xener
String ls_vreqno, ls_remark, ls_reqdt, ls_today
String ls_auth_method_stcip, ls_auth_method_both
Dec ldc_vreqno, ldc_svcorderno
Long ll_rows , i, ll_result, ll_rc, li_del_result
Integer li_cnt_result, li_result

String ls_con_priceplan, ls_svctype
String ls_con_status, ls_default_lang, ls_default_gkid, ls_validkey_loc
String ls_key_status[], ls_req_partner, ls_complete
Integer li_key_cnt, li_cnt
String  ls_bef_fromdt ,ls_val_status, ls_use_yn, ls_todt, ls_fromdt
String ls_status_cancel //해지
Date ld_fromdt



Choose Case is_caller
	Case "b1w_reg_validkey_req_cancel%save"
			//lu_dbmgr.is_title  = Title
			//lu_dbmgr.idw_data[1] = dw_detail
			//lu_dbmgr.idw_data[2] = dw_master

			
			ls_tmp= fs_get_control("B0", "P223", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_con_status    = ls_name[1]   //개통상태
			
			ls_tmp= fs_get_control("B0", "P221", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_status_cancel    = ls_name[2]   //해지상태
			
			
			ls_tmp= fs_get_control("B1", "P204", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_lang    = ls_name[1]   //Default 언어멘트
			
			ls_tmp= fs_get_control("00", "G100", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_gkid    = ls_name[1]   //default GKID		
			
			ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_complete    =  ls_name[2]   //처리완료
	
			
			ls_tmp= fs_get_control("B1", "P400", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_key_status[1]   = ls_name[1]   //인증키관리상태(생성;개통;해지;인증키요청)	
			ls_key_status[2]   = ls_name[2]
			ls_key_status[3]   = ls_name[3]
			ls_key_status[4]   = ls_name[4]
			
			ls_con_priceplan = idw_data[1].object.contractmst_priceplan[1]			
			ls_req_partner   = idw_data[1].object.validkeyreq_req_partner[1]  //등록대리점
			ls_vreqno		  = String(idw_data[1].object.validkeyreq_vreqno[1])
			ls_bef_validkey  = idw_data[1].object.validkeyreq_bef_validkey[1]
			ls_bef_fromdt    = String(idw_data[1].object.validkeyreq_bef_fromdt[1],'yyyymmdd')			
			ls_svctype       = idw_data[1].object.svcmst_svctype[1] //서비스타입
			ls_req_customerid = idw_data[1].object.validkeyreq_customerid[1]
			ls_req_contractseq = String(idw_data[1].object.validkeyreq_contractseq[1])
			ls_req_validkey  = idw_data[1].object.validkeyreq_validkey[1]
			ls_reqdt			  = String(idw_data[1].object.validkeyreq_reqdt[1],'yyyymmdd') //적용요청일자
			ls_remark		  = Trim(idw_data[1].object.validkeyreq_remark[1])  //비고


//			//계약상태가 개통상태인지 check
//			If ls_status_cancel = (idw_data[1].object.contractmst_status[1]) Then
//				f_msg_usr_err(200, is_Title, "개통상태가 아닙니다." )
//				Return
//			End If
//			
			
			//인증Key 상태 및 Check
			SELECT status, fromdt
			INTO :ls_val_status, :ld_fromdt
			FROM validinfo
			WHERE validkey = :ls_req_validkey
			  AND to_char(fromdt,'yyyymmdd') = :ls_bef_fromdt
			  AND svctype = :ls_svctype;
				
			If SQLCA.SQLCode < 0 Then
				 f_msg_sql_err(is_title, " Select Error(validinfo_before_validkey_status)")
				Return 
			End If		
			
			ls_fromdt = String(ld_fromdt,'yyyymmdd')
			
			If ls_val_status = ls_status_cancel Then
				f_msg_usr_err(200, is_Title, "이미 인증KEY 가 해지되어 변경할 수 없습니다." )
				return
			End If				

			If ls_fromdt > ls_reqdt Then
				f_msg_usr_err(200, is_Title, "적용요청일자는 적용시작일 보다 커야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("validkeyreq_reqdt")
				Return 
			End If		
				
				
			//validinfo update
			UPDATE validinfo
			   SET use_yn='N',
					 todt = to_date(:ls_reqdt,'yyyymmdd'), status = :ls_status_cancel,
					 updt_user=:gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :gs_pgm_id[gi_open_win_no]
          WHERE validkey = :ls_req_validkey 
			   AND to_char(fromdt,'yyyymmdd') = :ls_bef_fromdt
				AND svctype = :ls_svctype;
				
				
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Update Error(validinfo_bef_validkey)")
				RollBack;
				Return
			End if						

			//validkeyreq update
			 UPDATE validkeyreq
				 SET status = :ls_complete, reqdt =to_date(:ls_reqdt,'yyyymmdd'), 
						remark = :ls_remark, updt_user = :gs_user_id, updtdt= sysdate,
						pgm_id = :gs_pgm_id[gi_open_win_no]
				 WHERE vreqno = :ls_vreqno ;
		
					
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Update Error(validkeyreq)")
				RollBack;
				Return
			End If	

			
			li_result = b1fi_validkeytype_check(is_title, ls_con_priceplan, li_cnt)
				
			If li_cnt > 0 then
				//기존인증키 해지
				UPDATE validkeymst
				SET status = :ls_key_status[3], 
					 orderno = null,
					 sale_flag = '0',
					 activedt = null, customerid = null, contractseq = null,
					 updt_user =:gs_user_id, updtdt = sysdate,
					 pgm_id = :gs_pgm_id[gi_open_win_no]
				WHERE validkey = :ls_req_validkey AND contractseq = :ls_req_contractseq;
				
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_Title, "Update Error(validkeymst)")
					RollBack;
					Return
				End If
				
				INSERT INTO validkeymst_log 
				(validkey, seq, status, actdt, customerid, contractseq, partner, crt_user, crtdt, pgm_id)
				SELECT validkey, seq_validkeymstlog.nextval, :ls_key_status[3], 
						 to_date(:ls_reqdt,'yyyymmdd'), :ls_req_customerid, :ls_req_contractseq, :ls_req_partner,
					  :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
				FROM validkeymst 
				WHERE validkey=:ls_req_validkey and contractseq=:ls_req_contractseq;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_Title, "Insert Error(validkeymst)")
					RollBack;
					Return
				End If				
			
			End If
			
				
						
End Choose

end subroutine

public subroutine uf_prc_db_01 ();//Save Check
String ls_reqtype, ls_req_status, ls_req_validkey, ls_req_customerid, ls_req_svccod
String ls_req_contractseq, ls_vpassword, ls_req_auth_method
String ls_req_validitem2, ls_req_validitem1, ls_req_validitem3
String ls_req_remark, ls_req_langtype, ls_bef_validkey
String ls_tmp, ls_ref_desc, ls_name[], ls_xener
String ls_vreqno, ls_remark, ls_reqdt, ls_today
String ls_auth_method_stcip, ls_auth_method_both
Dec ldc_vreqno, ldc_svcorderno
Long ll_rows , i, ll_result, ll_rc
Integer li_cnt_result, li_result

String ls_con_priceplan, ls_svctype
String ls_con_status, ls_default_lang, ls_default_gkid, ls_validkey_loc
String ls_key_status[], ls_req_partner, ls_complete
Integer li_key_cnt, li_cnt
String  ls_bef_fromdt ,ls_val_status, ls_use_yn, ls_todt
String ls_status_cancel //해지




Choose Case is_caller
	Case "b1w_reg_validkey_req_modify%save"
			//lu_dbmgr.is_title  = Title
			//lu_dbmgr.idw_data[1] = dw_detail
			//lu_dbmgr.idw_data[2] = dw_master
			//lu_dbmgr.is_data[1] = ls_vreqno
			//lu_dbmgr.is_data[2] = ls_reqtype
			//lu_dbmgr.is_data[3] = ls_req_status
			//lu_dbmgr.is_data[4] = ls_req_validkey 
			//lu_dbmgr.is_data[5] = ls_reqdt
			//lu_dbmgr.is_data[6] = ls_req_customerid
			//lu_dbmgr.is_data[7] = ls_req_svccod
			//lu_dbmgr.is_data[8] = ls_req_contractseq 
			//lu_dbmgr.is_data[9] = ls_vpassword
			//lu_dbmgr.is_data[10] = ls_req_auth_method 
			//lu_dbmgr.is_data[11] = ls_req_validitem1
			//lu_dbmgr.is_data[12] = ls_req_validitem2
			//lu_dbmgr.is_data[13] = ls_req_validitem3
			//lu_dbmgr.is_data[14] = ls_req_langtype
			//lu_dbmgr.is_data[15] = ls_bef_validkey
			//lu_dbmgr.is_data[16] = ls_remark

			ls_vreqno			=	is_data[1]
			ls_reqtype			=	is_data[2]
			ls_req_status		=	is_data[3]
			ls_req_validkey	=	is_data[4]
			ls_reqdt				=	is_data[5]
			ls_req_customerid	=	is_data[6]
			ls_req_svccod		=	is_data[7]
			ls_req_contractseq =	is_data[8]
			ls_vpassword		=	is_data[9]
			ls_req_auth_method =	is_data[10]
			ls_req_validitem1	=	is_data[11]  //발신번호표시
			ls_req_validitem2	=	is_data[12]  //IPADDRESS
			ls_req_validitem3	=	is_data[13]  //H323ID
			ls_req_langtype	=	is_data[14]
			ls_bef_validkey	=	is_data[15]
			ls_remark			=	is_data[16]
			
			ls_tmp= fs_get_control("B0", "P223", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_con_status    = ls_name[1]   //개통상태
			
			ls_tmp= fs_get_control("B0", "P221", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_status_cancel    = ls_name[2]   //해지상태
			
			
			ls_tmp= fs_get_control("B1", "P204", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_lang    = ls_name[1]   //Default 언어멘트
			
			ls_tmp= fs_get_control("00", "G100", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_gkid    = ls_name[1]   //default GKID		
			
			ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_complete    =  ls_name[2]   //처리완료
	
			
			ls_tmp= fs_get_control("B1", "P400", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_key_status[1]   = ls_name[1]   //인증키관리상태(생성;개통;해지;인증키요청)	
			ls_key_status[2]   = ls_name[2]
			ls_key_status[3]   = ls_name[3]
			ls_key_status[4]   = ls_name[4]
			
						
			//validkey_loc
			ls_validkey_loc = idw_data[1].object.validkeyreq_validkey_loc[1]
			ls_con_priceplan = idw_data[1].object.contractmst_priceplan[1]
			ls_req_partner = idw_data[1].object.validkeyreq_req_partner[1]  //등록대리점
			ls_svctype    = idw_data[1].object.svcmst_svctype[1] //서비스타입
			ls_bef_validkey = idw_data[1].object.validkeyreq_bef_validkey[1]
			ls_bef_fromdt   = String(idw_data[1].object.validkeyreq_bef_fromdt[1],'yyyymmdd')


			//계약상태가 개통상태인지 check
			If ls_con_status <> (idw_data[1].object.contractmst_status[1]) Then
				f_msg_usr_err(200, is_Title, "개통상태가 아닙니다." )
				Return
			End If
			
			
			//변경전 인증Key 상태 및 Check
			SELECT status, use_yn, to_char(todt,'yyyymmdd')
			INTO :ls_val_status, :ls_use_yn, :ls_todt
			FROM validinfo
			WHERE validkey = :ls_bef_validkey
			  AND to_char(fromdt,'yyyymmdd') = :ls_bef_fromdt
			  AND svctype = :ls_svctype;
				
			If SQLCA.SQLCode < 0 Then
				 f_msg_sql_err(is_title, " Select Error(validinfo_before_validkey_status)")
				Return 
			End If		
			
			
			If ls_val_status = ls_status_cancel Then
				f_msg_usr_err(200, is_Title, "변경전 인증KEY가 이미 해지되어 변경할 수 없습니다." )
				return
			End If				
			
			If ls_use_yn = 'Y' Then
				f_msg_usr_err(200, is_Title, "변경전 인증KEY가 사용중이지 않습니다." )
				return
			End If				
				
				
				
			//인증Key 적용시작일과 적용종료일의 중복 check
			SELECT count(*) 
			INTO  :li_cnt
			FROM validinfo
			WHERE validkey = :ls_req_validkey
			  AND to_char(fromdt, 'yyyymmdd') = :ls_reqdt and svctype = :ls_svctype;
			  
			If SQLCA.SQLCode < 0 Then
				 f_msg_sql_err(is_title, " Select Error(validinfo_validkey_date_du_check)")
				Return 
			End If					  
			
			If li_cnt>0 Then
				f_msg_usr_err(200, is_Title, "인증KEY의 적용시작일과 적용종료일이 중복됩니다." )
				return
			End If
				
			
			//요청인증Key 와 변경전인증Key가 다른 경우 check
			If Trim(ls_req_validkey) <> Trim(ls_bef_validkey) Then
				ll_result=b1fi_validkey_du_check(is_title,ls_req_validkey,ls_reqdt, ls_svctype, li_key_cnt) 				
				
				If li_key_cnt >0 then
					f_msg_usr_err(200, is_Title, "인증KEY의 적용시작일과 적용종료일이 중복됩니다." )
					return
				End If

			
				li_result = b1fi_validkeytype_check(is_title, ls_con_priceplan, li_cnt)
				
				If li_cnt > 0 then
					//기존인증키 해지
					UPDATE validkeymst
					SET status = :ls_key_status[3], 
						 orderno = null,
						 sale_flag = '0',
						 activedt = null, customerid = null, contractseq = null,
						 updt_user =:gs_user_id, updtdt = sysdate,
						 pgm_id = :gs_pgm_id[gi_open_win_no]
					WHERE validkey = :ls_bef_validkey AND contractseq = :ls_req_contractseq;
					
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_Title, "Update Error(validkeymst)")
						RollBack;
						Return
					End If
					
					INSERT INTO validkeymst_log 
					(validkey, seq, status, actdt, customerid, contractseq, partner, crt_user, crtdt, pgm_id)
					SELECT validkey, seq_validkeymstlog.nextval, :ls_key_status[3], 
							 to_date(:ls_reqdt,'yyyymmdd'), :ls_req_customerid, :ls_req_contractseq, :ls_req_partner,
						  :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
					FROM validkeymst 
					WHERE validkey=:ls_bef_validkey and contractseq=:ls_req_contractseq;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_Title, "Insert Error(validkeymst)")
						RollBack;
						Return
					End If
					
					//새로운 인증키 개통
					UPDATE validkeymst
					SET status = :ls_key_status[2], 
						 orderno = :ldc_svcorderno,
						 sale_flag = '1',
						 activedt = to_date(:ls_reqdt,'yyyymmdd'),
						 updt_user =:gs_user_id, updtdt = sysdate,
						 pgm_id = :gs_pgm_id[gi_open_win_no]
					WHERE validkey = :ls_req_validkey AND contractseq = :ls_req_contractseq;
					
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_Title, "Update Error(validkeymst)")
						RollBack;
						Return
					End If
					
					INSERT INTO validkeymst_log 
					(validkey, seq, status, actdt, customerid, contractseq, partner, crt_user, crtdt, pgm_id)
					SELECT :ls_req_validkey, seq_validkeymstlog.nextval, :ls_key_status[2], 
							 to_date(:ls_reqdt,'yyyymmdd'), :ls_req_customerid, :ls_req_contractseq, :ls_req_partner,
						  :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
					FROM validkeymst 
					WHERE validkey=:ls_req_validkey and contractseq=:ls_req_contractseq;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_Title, "Insert Error(validkeymst)")
						RollBack;
						Return
					End If
				
				End If
				
			End If
			
			
			
			//validinfo update
			UPDATE validinfo
			   SET use_yn='N',
					 todt = to_date(:ls_reqdt,'yyyymmdd'),
					 updt_user=:gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :gs_pgm_id[gi_open_win_no]
          WHERE validkey = :ls_bef_validkey 
			   AND to_char(fromdt,'yyyymmdd') = :ls_bef_fromdt
				AND svctype = :ls_svctype;
				
				
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Update Error(validinfo_bef_validkey)")
				RollBack;
				Return
			End if				
				
					 
			//validinfo insert
			INSERT INTO validinfo
			(validkey, fromdt, status, use_yn, vpassword, customerid, svccod, svctype,
			 priceplan, orderno, contractseq, gkid, validitem1, validitem2, validitem3,
			 auth_method, validkey_loc, langtype, crt_user, crtdt, pgm_id)
			SELECT :ls_req_validkey, to_date(:ls_reqdt,'yyyymmdd'), status, 'Y', :ls_vpassword, customerid,
			       svccod, :ls_svctype, priceplan, :ldc_svcorderno, contractseq, :ls_default_gkid, 
					 :ls_req_validitem1,:ls_req_validitem2, :ls_req_validitem3, :ls_req_auth_method,
					 :ls_validkey_loc, :ls_req_langtype, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
			FROM validinfo
			WHERE validkey = :ls_bef_validkey 
			  AND to_char(fromdt,'yyyymmdd') = :ls_bef_fromdt
			  AND svctype = :ls_svctype;			  			
			
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Insert Error(validinfo_new_validkey)")
				RollBack;
				Return
			End If
					
		
		 UPDATE validkeyreq
		 SET status = :ls_complete, reqdt =to_date(:ls_reqdt,'yyyymmdd'), 
				 vpassword = :ls_vpassword, validitem1 = :ls_req_validitem1,
				validitem2 = :ls_req_validitem2, validitem3 = :ls_req_validitem3,
				auth_method = :ls_req_auth_method, langtype = :ls_req_langtype,
				remark = :ls_remark, updt_user = :gs_user_id, updtdt= sysdate,
				pgm_id = :gs_pgm_id[gi_open_win_no]
		 WHERE vreqno = :ls_vreqno ;

			
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Update Error(validkeyreq)")
			RollBack;
			Return
		End If	
		
		
		f_msg_info(3000,is_Title,ls_bef_validkey+" 에서 "+ls_req_validkey+" 로 변경되었습니다.")
		
			
End Choose

end subroutine

public subroutine uf_prc_db_03 ();//Save Check
String ls_reqtype, ls_req_status, ls_req_validkey, ls_req_customerid, ls_req_svccod
String ls_req_contractseq, ls_vpassword, ls_req_auth_method
String ls_req_validitem2, ls_req_validitem1, ls_req_validitem3
String ls_req_remark, ls_req_langtype, ls_bef_validkey
String ls_tmp, ls_ref_desc, ls_name[], ls_xener
String ls_vreqno, ls_remark, ls_reqdt, ls_today
String ls_auth_method_stcip, ls_auth_method_both
Dec ldc_vreqno, ldc_svcorderno
Long ll_rows , i, ll_result, ll_rc, li_del_result
Integer li_cnt_result, li_result

String ls_con_priceplan, ls_svctype
String ls_con_status, ls_default_lang, ls_default_gkid, ls_validkey_loc
String ls_key_status[], ls_req_partner, ls_complete
Integer li_key_cnt, li_cnt
String  ls_bef_fromdt ,ls_val_status, ls_use_yn, ls_todt, ls_fromdt
String ls_status_cancel //해지
Date ld_fromdt



Choose Case is_caller
	Case "b1w_reg_validkey_req%delete"
			//lu_dbmgr.is_title  = Title
			//lu_dbmgr.idw_data[1] = dw_detail
			//lu_dbmgr.idw_data[2] = dw_master

			
			ls_tmp= fs_get_control("B0", "P223", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_con_status    = ls_name[1]   //개통상태
			
			ls_tmp= fs_get_control("B0", "P221", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_status_cancel    = ls_name[2]   //해지상태
			
			
			ls_tmp= fs_get_control("B1", "P204", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_lang    = ls_name[1]   //Default 언어멘트
			
			ls_tmp= fs_get_control("00", "G100", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_default_gkid    = ls_name[1]   //default GKID		
			
			ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_complete    =  ls_name[2]   //처리완료
	
			
			ls_tmp= fs_get_control("B1", "P400", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_key_status[1]   = ls_name[1]   //인증키관리상태(생성;개통;해지;인증키요청)	
			ls_key_status[2]   = ls_name[2]
			ls_key_status[3]   = ls_name[3]
			ls_key_status[4]   = ls_name[4]
			
			ls_con_priceplan = idw_data[1].object.contractmst_priceplan[1]			
			ls_req_partner   = idw_data[1].object.validkeyreq_req_partner[1]  //등록대리점
			ls_vreqno		  = String(idw_data[1].object.validkeyreq_vreqno[1])
			ls_bef_validkey  = idw_data[1].object.validkeyreq_bef_validkey[1]
			ls_bef_fromdt    = String(idw_data[1].object.validkeyreq_bef_fromdt[1],'yyyymmdd')			
			ls_svctype       = idw_data[1].object.svcmst_svctype[1] //서비스타입
			ls_req_customerid = idw_data[1].object.validkeyreq_customerid[1]
			ls_req_contractseq = String(idw_data[1].object.validkeyreq_contractseq[1])
			ls_req_validkey  = idw_data[1].object.validkeyreq_validkey[1]
			ls_reqdt			  = String(idw_data[1].object.validkeyreq_reqdt[1],'yyyymmdd') //적용요청일자
			ls_remark		  = Trim(idw_data[1].object.validkeyreq_remark[1])  //비고



			//가격정책별인증KEY TYPE 존재여부확인
			SELECT count(*) 
			  INTO  :li_cnt
			  FROM  priceplan_validkey_type
			 WHERE  priceplan = :ls_con_priceplan;

			 If SQLCA.SQLCode < 0 Then
				 f_msg_sql_err(is_title, " Select Error(priceplan_validkey_type)")
				Return 
			End If		
	
			

			If li_cnt > 0 then
				//변경할 인증KEY 와 변경전 인증KEY 가 다른 경우
				If ls_bef_validkey <> ls_req_validkey Then
					
						//기존인증키 해지
						UPDATE validkeymst
						SET status = :ls_key_status[1], 
							 orderno = null,
							 sale_flag = '0',
							 activedt = null, customerid = null, contractseq = null,
							 updt_user =:gs_user_id, updtdt = sysdate,
							 pgm_id = :gs_pgm_id[gi_open_win_no]
						WHERE validkey = :ls_req_validkey AND contractseq = :ls_req_contractseq;
						
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "Update Error(validkeymst)")
							RollBack;
							Return
						End If
						
						INSERT INTO validkeymst_log 
						(validkey, seq, status, actdt, customerid, contractseq, partner, crt_user, crtdt, pgm_id)
						SELECT validkey, seq_validkeymstlog.nextval, :ls_key_status[1], 
								 to_date(:ls_reqdt,'yyyymmdd'), :ls_req_customerid, :ls_req_contractseq, :ls_req_partner,
							  :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]
						FROM validkeymst 
						WHERE validkey=:ls_req_validkey and contractseq=:ls_req_contractseq;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "Insert Error(validkeymst)")
							RollBack;
							Return
						End If				
					
				End If
		   End If
				
						
End Choose

end subroutine

on b1u_dbmgr10.create
call super::create
end on

on b1u_dbmgr10.destroy
call super::destroy
end on

