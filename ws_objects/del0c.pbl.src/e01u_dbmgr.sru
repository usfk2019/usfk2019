$PBExportHeader$e01u_dbmgr.sru
$PBExportComments$[parkkh] db control
forward
global type e01u_dbmgr from u_cust_a_db
end type
end forward

global type e01u_dbmgr from u_cust_a_db
end type
global e01u_dbmgr e01u_dbmgr

type variables


end variables

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();Long ll_rowcnt, i, ll_seq, ll_cnt
String ls_contractseq, ls_pgm_id, ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_termtype, ls_remark
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_requestdt, ls_partner
Dec ldc_orderno
ii_rc = -1

Choose Case is_caller
	Case "e01w_reg_del_last_set%save"
//		iu_db01.is_caller = "e01w_reg_del_last_set%save"
//		iu_db01.is_title = This.Title
//		iu_db01.idw_data[1] = dw_term
//		iu_db01.is_data[1] = ls_work_dt     		//처리일자
//		iu_db01.is_data[2] = ls_new_status			//다음상태
//		iu_db01.is_data[3] = dw_detail.Object.payid[ll_row]   //납입자
//		iu_db01.is_data[4] = ls_termtype				//해지사유
//		iu_db01.is_data[5] = is_e_termstatus   	//연체자해지신청상태코드
//		iu_db01.is_data[6] = is_e_suspenstatus		//연체자일시정지상태코드
//		iu_db01.is_data[7] = is_termstatus[1]     //해지신청코드(SVCORDER)
//		iu_db01.is_data[8] = is_suspendstatus     //일시정시신청코드(SVCORDER)
//		iu_db01.is_data[9] = ls_status_cd         //현재상태

			
		ls_remark = is_data[9] + "상태에서 " + is_data[2]+ "상태로 조치사항등록"
		
		INSERT INTO dlydet ( payid, seq, work_date, status, amount, remark,
									crt_user, crtdt, pgm_id, updt_user, updtdt )
		SELECT :is_data[3], nvl(max(seq ), 0 ) + 1, :is_data[1], :is_data[2], 0, :ls_remark,
				 :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate
		FROM dlydet
		WHERE payid = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK;
			Return
		End If
		
		UPDATE dlymst
		SET status = :is_data[2] ,
			 modify_date = to_date(:is_data[1],'yyyymmdd'),
			 crt_user = :gs_user_id, 
			 crtdt = sysdate, 
			 pgm_id = :gs_pgm_id[gi_open_win_no], 
			 updt_user = :gs_user_id,
			 updtdt = sysdate  
		WHERE payid = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK ;
			Return
		End If
			
		Choose Case is_data[2]
			Case is_data[5]     //해지신청일 경우
				
					ll_rowcnt = idw_data[1].RowCount()
					If ll_rowcnt = 0 Then
						ii_rc = 0
						Return	   //저장 하지 않음
					End if

					For i =1 To ll_rowcnt
						
						ls_contractseq = string(idw_data[1].object.contractmst_contractseq[i])
					
						ll_cnt = 0
						//해지신청내역 존재 여부 check
						Select count(*)
						 Into :ll_cnt
						 From svcorder
						Where to_char(ref_contractseq) = :ls_contractseq
						  and status = :is_data[7];
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "SELECT svcorder")
							RollBack;
							Return
						End If	
						
						If ll_cnt > 0 Then
					//		li_chk =  f_msg_ques_yesno2(9000, Title, "계약Seq [" + ls_contractseq + "]로 이미 해지신청이 등록되어 있습니다. ~R" + &
					//		                                          "다음 계약Seq 해지신청을 계속 하시겠습니까?!", 1)
					//		
					//		If li_chk = 1 Then		//Yes
					//			 continue
					//		End If		 
							continue
						End If	
						
						ls_customerid = ""
						ls_svccod = ""
						ls_priceplan = ""
						ls_reg_partner = ""
						ls_sale_partner = ""
						ls_maintain_partner = ""
						ls_settle_partner = ""
						ls_partner = ""
						ls_prmtype = ""
						ls_customerid = Trim(idw_data[1].object.contractmst_customerid[i])
						ls_svccod = Trim(idw_data[1].object.contractmst_svccod[i])
						ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[i])
						ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[i])
						ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[i])
						ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[i])
						ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[i])
						ls_partner = Trim(idw_data[1].object.contractmst_partner[i])						
						ls_prmtype =	Trim(idw_data[1].object.contractmst_prmtype[i])
						If IsNull(ls_customerid) Then ls_customerid = ""				
						If IsNull(ls_svccod) Then ls_svccod = ""						
						If IsNull(ls_priceplan) Then ls_priceplan = ""						
						If IsNull(ls_prmtype) Then ls_prmtype = ""						
						If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
						If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
						If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
						If IsNull(ls_settle_partner) Then ls_settle_partner = ""	
						If IsNull(ls_partner) Then ls_partner = ""							
						
						//Insert
						insert into svcorder
							 (orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
								prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
								ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt )
						values ( seq_orderno.nextval, :ls_customerid, sysdate, to_date(:is_data[1],'yyyy-mm-dd'), :is_data[7], :ls_svccod, :ls_priceplan,
								:ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
								:ls_contractseq, :is_data[4], :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate);
					
						//저장 실패 
						If SQLCA.SQLCode < 0 Then
							RollBack;
							f_msg_info(3010, is_Title, "Svcorder Insert")
							Return
						End If	
					Next
					
			Case is_data[6]    //일시정지신청일 경우
				
					ll_rowcnt = idw_data[1].RowCount()
					If ll_rowcnt = 0 Then 
						 ii_rc = 0
						 Return	   //저장 하지 않음
					End if

					For i =1 To ll_rowcnt
				
						//중복 Check
						ls_contractseq = String(idw_data[1].object.contractmst_contractseq[i])
					
						Select count(*)
						 Into :ll_cnt
						 From svcorder
						Where ref_contractseq = :ls_contractseq 
						  and status = :is_data[8];
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
							ROLLBACK;
							Return  
						End If
						
						If ll_cnt <> 0 Then
	//						f_msg_usr_err(9000, is_title, "고객번호 : " + ls_customerid + &
	//										  "~r계약 Seq : " + ls_contractseq + "는 ~r이미 신청되었습니다.")
	//						ii_rc = -2
	//						Return
							continue
						End If
						
						ls_customerid = ""
						ls_svccod = ""
						ls_priceplan = ""
						ls_reg_partner = ""
						ls_sale_partner = ""
						ls_maintain_partner = ""
						ls_settle_partner = ""
						ls_partner = ""
						ls_prmtype = ""
						//svcorder Insert
						ls_customerid = Trim(idw_data[1].object.contractmst_customerid[i])						
						ls_svccod = Trim(idw_data[1].object.contractmst_svccod[i])
						ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[i])
						ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[i])
						ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[i])
						ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[i])
						ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[i])
						ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[i])
						ls_partner = Trim(idw_data[1].object.contractmst_partner[i])						
						If IsNull(ls_customerid) Then ls_customerid = ""				
						If IsNull(ls_svccod) Then ls_svccod = ""						
						If IsNull(ls_priceplan) Then ls_priceplan = ""						
						If IsNull(ls_prmtype) Then ls_prmtype = ""						
						If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
						If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
						If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
						If IsNull(ls_settle_partner) Then ls_settle_partner = ""			
						If IsNull(ls_partner) Then ls_partner = ""									
						
						Insert Into svcorder
								 (orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
									prmtype, reg_partner, sale_partner, maintain_partner, settle_partner,
									partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
						Values (seq_orderno.nextval, :ls_customerid, sysdate, to_date(:is_data[1], 'yyyy-mm-dd'),
									:is_data[8], :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, 
									:ls_sale_partner, :ls_maintain_partner, :ls_settle_partner,
									:ls_partner, :ls_contractseq, :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " 일시정시 신청(SVCORDER)")
							ROLLBACK;
							Return  
						End If
				NEXT
			
		End Choose

	Case "e01w_reg_del_last_set_1%save"
//		iu_db01.is_caller = "e01w_reg_del_last_set%save"
//		iu_db01.is_title = This.Title
//		iu_db01.idw_data[1] = dw_term
//		iu_db01.is_data[1] = ls_work_dt     		//처리일자
//		iu_db01.is_data[2] = ls_new_status			//다음상태
//		iu_db01.is_data[3] = dw_detail.Object.payid[ll_row]   //납입자
//		iu_db01.is_data[4] = ls_termtype				//해지사유
//		iu_db01.is_data[5] = is_e_termstatus   	//연체자해지신청상태코드
//		iu_db01.is_data[6] = is_e_suspenstatus		//연체자일시정지상태코드
//		iu_db01.is_data[7] = is_termstatus[1]     //해지신청코드(SVCORDER)
//		iu_db01.is_data[8] = is_suspendstatus     //일시정시신청코드(SVCORDER)
//		iu_db01.is_data[9] = ls_status_cd         //현재상태
//2005.08.30 juede add
// 	iu_db01.is_data[10] = is_e_suspenconfirm_status //연체자일시정치처리상태코드 200
//	   iu_db01.is_data[11] = ls_suspendtype  //일시정처리지사유
//    iu_db01.is_data[12] = is_suspendconfirm_status //
			
		ls_remark = is_data[9] + "상태에서 " + is_data[2]+ "상태로 조치사항등록"
		
		INSERT INTO dlydet ( payid, seq, work_date, status, amount, remark,
									crt_user, crtdt, pgm_id, updt_user, updtdt )
		SELECT :is_data[3], nvl(max(seq ), 0 ) + 1, :is_data[1], :is_data[2], 0, :ls_remark,
				 :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate
		FROM dlydet
		WHERE payid = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK;
			Return
		End If
		
		UPDATE dlymst
		SET status = :is_data[2] ,
			 modify_date = to_date(:is_data[1],'yyyymmdd'),
			 crt_user = :gs_user_id, 
			 crtdt = sysdate, 
			 pgm_id = :gs_pgm_id[gi_open_win_no], 
			 updt_user = :gs_user_id,
			 updtdt = sysdate  
		WHERE payid = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK ;
			Return
		End If
			
		Choose Case is_data[2]
			Case is_data[5]     //해지신청일 경우
				
					ll_rowcnt = idw_data[1].RowCount()
					If ll_rowcnt = 0 Then
						ii_rc = 0
						Return	   //저장 하지 않음
					End if

					For i =1 To ll_rowcnt
						
						ls_contractseq = string(idw_data[1].object.contractmst_contractseq[i])
					
						ll_cnt = 0
						//해지신청내역 존재 여부 check
						Select count(*)
						 Into :ll_cnt
						 From svcorder
						Where to_char(ref_contractseq) = :ls_contractseq
						  and status = :is_data[7];
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "SELECT svcorder")
							RollBack;
							Return
						End If	
						
						If ll_cnt > 0 Then
					//		li_chk =  f_msg_ques_yesno2(9000, Title, "계약Seq [" + ls_contractseq + "]로 이미 해지신청이 등록되어 있습니다. ~R" + &
					//		                                          "다음 계약Seq 해지신청을 계속 하시겠습니까?!", 1)
					//		
					//		If li_chk = 1 Then		//Yes
					//			 continue
					//		End If		 
							continue
						End If	
						
						ls_customerid = ""
						ls_svccod = ""
						ls_priceplan = ""
						ls_reg_partner = ""
						ls_sale_partner = ""
						ls_maintain_partner = ""
						ls_settle_partner = ""
						ls_partner = ""
						ls_prmtype = ""
						ls_customerid = Trim(idw_data[1].object.contractmst_customerid[i])
						ls_svccod = Trim(idw_data[1].object.contractmst_svccod[i])
						ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[i])
						ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[i])
						ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[i])
						ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[i])
						ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[i])
						ls_partner = Trim(idw_data[1].object.contractmst_partner[i])						
						ls_prmtype =	Trim(idw_data[1].object.contractmst_prmtype[i])
						If IsNull(ls_customerid) Then ls_customerid = ""				
						If IsNull(ls_svccod) Then ls_svccod = ""						
						If IsNull(ls_priceplan) Then ls_priceplan = ""						
						If IsNull(ls_prmtype) Then ls_prmtype = ""						
						If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
						If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
						If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
						If IsNull(ls_settle_partner) Then ls_settle_partner = ""	
						If IsNull(ls_partner) Then ls_partner = ""							
						
						//Insert
						insert into svcorder
							 (orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
								prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
								ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt )
						values ( seq_orderno.nextval, :ls_customerid, sysdate, to_date(:is_data[1],'yyyy-mm-dd'), :is_data[7], :ls_svccod, :ls_priceplan,
								:ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
								:ls_contractseq, :is_data[4], :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate);
					
						//저장 실패 
						If SQLCA.SQLCode < 0 Then
							RollBack;
							f_msg_info(3010, is_Title, "Svcorder Insert")
							Return
						End If	
					Next
					
			Case is_data[6]    //일시정지신청일 경우
				
					ll_rowcnt = idw_data[1].RowCount()
					If ll_rowcnt = 0 Then 
						 ii_rc = 0
						 Return	   //저장 하지 않음
					End if

					For i =1 To ll_rowcnt
				
						//중복 Check
						ls_contractseq = String(idw_data[1].object.contractmst_contractseq[i])
					
						Select count(*)
						 Into :ll_cnt
						 From svcorder
						Where ref_contractseq = :ls_contractseq 
						  and status = :is_data[8];
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
							ROLLBACK;
							Return  
						End If
						
						If ll_cnt <> 0 Then
	//						f_msg_usr_err(9000, is_title, "고객번호 : " + ls_customerid + &
	//										  "~r계약 Seq : " + ls_contractseq + "는 ~r이미 신청되었습니다.")
	//						ii_rc = -2
	//						Return
							continue
						End If
						
						ls_customerid = ""
						ls_svccod = ""
						ls_priceplan = ""
						ls_reg_partner = ""
						ls_sale_partner = ""
						ls_maintain_partner = ""
						ls_settle_partner = ""
						ls_partner = ""
						ls_prmtype = ""
						//svcorder Insert
						ls_customerid = Trim(idw_data[1].object.contractmst_customerid[i])						
						ls_svccod = Trim(idw_data[1].object.contractmst_svccod[i])
						ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[i])
						ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[i])
						ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[i])
						ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[i])
						ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[i])
						ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[i])
						ls_partner = Trim(idw_data[1].object.contractmst_partner[i])						
						If IsNull(ls_customerid) Then ls_customerid = ""				
						If IsNull(ls_svccod) Then ls_svccod = ""						
						If IsNull(ls_priceplan) Then ls_priceplan = ""						
						If IsNull(ls_prmtype) Then ls_prmtype = ""						
						If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
						If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
						If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
						If IsNull(ls_settle_partner) Then ls_settle_partner = ""			
						If IsNull(ls_partner) Then ls_partner = ""									
						
						Insert Into svcorder
								 (orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
									prmtype, reg_partner, sale_partner, maintain_partner, settle_partner,
									partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
						Values (seq_orderno.nextval, :ls_customerid, sysdate, to_date(:is_data[1], 'yyyy-mm-dd'),
									:is_data[8], :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, 
									:ls_sale_partner, :ls_maintain_partner, :ls_settle_partner,
									:ls_partner, :ls_contractseq, :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " 일시정시 신청(SVCORDER)")
							ROLLBACK;
							Return  
						End If
				NEXT
				
			//2005.08.30 juede add 일시정지 처리========================================================
			Case is_data[10]  
				
					ll_rowcnt = idw_data[1].RowCount()
					MESSAGEBOX("TEST", STRING(ll_rowcnt));
					If ll_rowcnt = 0 Then 
						 ii_rc = 0
						 Return	   //저장 하지 않음
					End if

					For i =1 To ll_rowcnt
				
						//중복 Check
						ls_contractseq = String(idw_data[1].object.contractmst_contractseq[i])
					
						Select count(*)
						 Into :ll_cnt
						 From svcorder
						Where ref_contractseq = :ls_contractseq 
						  and status = :is_data[8];
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
							ROLLBACK;
							Return  
						End If
						
						If ll_cnt <> 0 Then
	//						f_msg_usr_err(9000, is_title, "고객번호 : " + ls_customerid + &
	//										  "~r계약 Seq : " + ls_contractseq + "는 ~r이미 신청되었습니다.")
	//						ii_rc = -2
	//						Return
							continue
						End If
						
						ls_customerid = ""
						ls_svccod = ""
						ls_priceplan = ""
						ls_reg_partner = ""
						ls_sale_partner = ""
						ls_maintain_partner = ""
						ls_settle_partner = ""
						ls_partner = ""
						ls_prmtype = ""
						//svcorder Insert
						ls_customerid = Trim(idw_data[1].object.contractmst_customerid[i])						
						ls_svccod = Trim(idw_data[1].object.contractmst_svccod[i])
						ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[i])
						ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[i])
						ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[i])
						ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[i])
						ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[i])
						ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[i])
						ls_partner = Trim(idw_data[1].object.contractmst_partner[i])						
						If IsNull(ls_customerid) Then ls_customerid = ""				
						If IsNull(ls_svccod) Then ls_svccod = ""						
						If IsNull(ls_priceplan) Then ls_priceplan = ""						
						If IsNull(ls_prmtype) Then ls_prmtype = ""						
						If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
						If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
						If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
						If IsNull(ls_settle_partner) Then ls_settle_partner = ""			
						If IsNull(ls_partner) Then ls_partner = ""									
						
						Insert Into svcorder
								 (orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
									prmtype, reg_partner, sale_partner, maintain_partner, settle_partner,
									partner, ref_contractseq, suspend_type,crt_user, updt_user, crtdt, updtdt, pgm_id)
						Values (seq_orderno.nextval, :ls_customerid, sysdate, to_date(:is_data[1], 'yyyy-mm-dd'),
									:is_data[12], :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, 
									:ls_sale_partner, :ls_maintain_partner, :ls_settle_partner,
									:ls_partner, :ls_contractseq, :is_data[11],:gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " 일시정시처리(SVCORDER)")
							ROLLBACK;
							Return  
						End If
//=================================================================================================						

						//contractmst update
						Update contractmst
						Set   status = :is_data[12],
								updt_user = :gs_user_id,
								updtdt = sysdate,
								pgm_id = :gs_pgm_id[gi_open_win_no]
						Where contractseq = :ls_contractseq;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
							Return  
						End If
			
						//suspendinfo insert
						Insert Into suspendinfo
								(seq, customerid, contractseq, fromdt,
								 crt_user, updt_user, crtdt, updtdt, pgm_id)
						Values (seq_suspendinfo.nextval, :ls_customerid, :ls_contractseq, to_date(:is_data[1], 'yyyy-mm-dd'),
								  :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);

						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(SUSPENDINFO)")
							Return  
						End If	
						
						//인증정보 UPDATE
			//			ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
			//			ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
						Update validinfo
						Set use_yn = 'N',
							status = :is_data[12],
							updt_user =  :gs_user_id,
							updtdt = sysdate,
							pgm_id =  :gs_pgm_id[gi_open_win_no]
						Where contractseq = :ls_contractseq
						  and use_yn = 'Y';
						//Where svccod = :ls_svccod and customerid = :ls_customerid;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
							Return  
						End If
									
						
				NEXT				
			
		End Choose
		
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db_01()", &
							"Matching statement Not found.(" + String(is_caller) + ")")
		Return
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db ();ii_rc = -1

String ls_remark

Choose Case is_caller
	Case "e01w_reg_del_status_change%status_cd"
		
		select ref_content 
		into :is_data[1]
		from sysctl1t 
		where module = 'E2' 
		and ref_no = 'F101' ;
		
		If sqlca.sqlcode <> 0 then
			rollback ;
			messageBox( "알림", "연체상태코드가 존재하지 않습니다." )
			return
		end If
		
	Case "e01w_reg_del_status_change%lastseq"
						
		SELECT max(nvl(seq,0))
		INTO   :il_data[1] 
		FROM dlydet
		WHERE payid = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			rollback ;
			Return
		End If		

	Case "e01w_reg_del_batch%save"
//		iu_db01.is_caller = "e01w_reg_del_batch%save"
//		iu_db01.is_title = This.Title
//		iu_db01.is_data[1] = ls_work_dt			//처리일자
//		iu_db01.is_data[2] = ls_status_cd2		//다음상태
//		iu_db01.is_data[3] = dw_detail.Object.payid[ ll_row ]  //payid
//		iu_db01.is_data[4] = ls_status_cd      //현재상태
//		iu_db01.is_data[5] = ls_remark         //Remark ADD-2006-12-14
//		iu_db01.il_data[1] = Long(dw_detail.Object.amount[ ll_row ])

//		ls_remark = is_data[4] + "상태에서 " + is_data[2]+ "상태로 일괄등록"
		ls_remark = is_data[5] 
		
		INSERT INTO dlydet
              (  payid    , seq                    , work_date, 
                 status   , amount                 , remark,
                 crt_user , crtdt                  , pgm_id, 
                 updt_user, updtdt                 , bef_status )
		SELECT   :is_data[3], nvl(max( seq ), 0 ) + 1, to_date(:is_data[1],'yyyy-mm-dd'), 
					:is_data[2], '0'                    , :ls_remark,
				 	:gs_user_id, sysdate                , :gs_pgm_id[gi_open_win_no], 
					:gs_user_id, sysdate                , :is_data[4]
		FROM dlydet
		WHERE payid = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK ;
			Return
		End If
				
		UPDATE dlymst
		SET status      = :is_data[2] ,
			 modify_date = to_date(:is_data[1],'yyyymmdd'),
			 crt_user    = :gs_user_id, 
			 crtdt       = sysdate, 
			 pgm_id      = :gs_pgm_id[gi_open_win_no], 
			 updt_user   = :gs_user_id,
			 updtdt = sysdate  
		WHERE payid = :is_data[3];
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK ;
			Return
		End If		
	Case "e01w_reg_del_batch_new%save"
//		iu_db01.is_caller = "e01w_reg_del_batch%save"
//		iu_db01.is_title = This.Title
//		iu_db01.is_data[1] = ls_work_dt			//처리일자
//		iu_db01.is_data[2] = ls_status_cd2		//다음상태
//		iu_db01.is_data[3] = dw_detail.Object.payid[ ll_row ]  //payid
//		iu_db01.is_data[4] = ls_status_cd      //현재상태
//		iu_db01.is_data[5] = ls_remark         //Remark ADD-2006-12-14
//		iu_db01.il_data[1] = Long(dw_detail.Object.amount[ ll_row ])

//		ls_remark = is_data[4] + "상태에서 " + is_data[2]+ "상태로 일괄등록"
		ls_remark = is_data[5] 
		
		UPDATE DLYMST_BYSVC
		SET	 STATUS      = :is_data[2],
			 	 MODIFY_DATE = to_date(:is_data[1],'yyyymmdd'),
				 REMARK      = :ls_remark,
				 PGM_ID      = :gs_pgm_id[gi_open_win_no], 
			 	 UPDT_USER   = :gs_user_id,
			 	 UPDTDT      = sysdate  
		WHERE  PAYID = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			ROLLBACK ;
			Return
		End If				
	
	Case "e01w_reg_del_status_change%ue_save_after"
//			iu_db01.is_title = This.Title
//			iu_db01.is_data[1] = is_payid
		
		//금액 , 금액일자 먼저 
 		Update dlymst d
		set ( d.amt_date, d.amount, d.crt_user, d.crtdt, d.pgm_id, d.updt_user, d.updtdt )
		= ( select  c.work_date, c.amount, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate
			 from dlydet c
			where  payid = d.payid
			and seq = ( 
							select max( seq ) 
							from dlydet 
							where payid = c.payid
							and status = ( select ref_content /* 연체추출만 */
								 from sysctl1t 
								 where module = 'E2' and ref_no = 'F101' 			
								)
							) 
		)
		where payid = :is_data[1] ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Rollback ;
			Return
		End If
		
		
		// 상태, 상태일자 
 		Update dlymst d
		set ( d.modify_date , d.status, d.crt_user, d.crtdt, d.pgm_id, d.updt_user, d.updtdt )
		= ( select c.work_date, c.status, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate
			   from dlydet c
			  where c.payid = d.payid
			    and c.seq = ( select max( seq ) 
							        from dlydet 
							       where payid = d.payid
						        ) 
		  )
		where payid = :is_data[1] ;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			rollback ;
			Return
		End If

	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db_01()", &
							"Matching statement Not found.(" + String(is_caller) + ")")
		Return
End Choose

ii_rc = 0
end subroutine

on e01u_dbmgr.create
call super::create
end on

on e01u_dbmgr.destroy
call super::destroy
end on

