$PBExportHeader$b1u_dbmgr3.sru
$PBExportComments$[chooys] DB 스크립트처리 User Object
forward
global type b1u_dbmgr3 from u_cust_a_db
end type
end forward

global type b1u_dbmgr3 from u_cust_a_db
end type
global b1u_dbmgr3 b1u_dbmgr3

forward prototypes
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_02 ();ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_chg_contractdet%save"
//lu_dbmgr.is_caller = "b1w_reg_chg_priceplan%save"
//lu_dbmgr.is_title = Title
//lu_dbmgr.is_data[1] = is_contractseq
//lu_dbmgr.is_data[2] = is_orderno
//lu_dbmgr.is_data[3] = gs_user_group
//lu_dbmgr.is_data[4] = gs_user_id
//lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
//lu_dbmgr.idw_data[1] = dw_detail2
//lu_dbmgr.idw_data[2] = dw_detail

	String ls_contractseq
	String ls_orderno
	String ls_priceplan
	Long ll_rows
	Long ll_i
	String ls_check
	String ls_itemcod

	ls_contractseq = is_data[1]
	ls_orderno = is_data[2]
	

	//필수항목 체크
	ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])	
	IF IsNull(ls_priceplan) THEN ls_priceplan = ""

	IF ls_priceplan = "" THEN
		f_msg_usr_err(200, is_title, "가격정책")
		idw_data[1].SetFocus()
		idw_data[1].SetColumn("contractmst_priceplan")
		RETURN
	END IF
	
	//계약내역 저장
	IF idw_data[1].Update() < 0 THEN
		f_msg_sql_err(is_title, "dw_detail2(ContractMst) Update Error")
		RollBack;
		RETURN
	END IF
	
	
	//계약품목 저장
	DELETE contractdet
	WHERE contractseq = :ls_contractseq;
	
	IF SQLCA.sqlcode < 0 THEN
		f_msg_sql_err(is_title, "contractdet delete Error")
		RollBack;
		RETURN
	END IF
			
	ll_rows = idw_data[2].rowcount()
	
	FOR ll_i=1 TO ll_rows
		ls_check = idw_data[2].object.chk[ll_i]
		IF ls_check = "Y" THEN
			ls_itemcod = Trim(idw_data[2].object.itemcod[ll_i])
			INSERT INTO contractdet
			(orderno,itemcod,contractseq)
			VALUES
			(:ls_orderno,:ls_itemcod,:ls_contractseq);
			
			IF SQLCA.sqlcode < 0 THEN
				f_msg_sql_err(is_title, "contractdet insert Error")
				RollBack;
				RETURN
			END IF
			
		END IF
	NEXT

END Choose

ii_rc = 0
RETURN
end subroutine

public subroutine uf_prc_db_03 ();String ls_customerid, ls_ref_desc, ls_status, ls_remark, ls_levelcod, ls_reg_prefixno
String ls_daricod, ls_boncod, ls_bonsacod, ls_action, ls_cus_status
Long   ll_row, ll_cnt
Dec ldc_orderno, ldc_contractseq
ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_svc_actcancel%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actcancel%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = tab_1.idw_tabpage[1]
//		lu_dbmgr2.is_data[1] = ls_termdt   //철회일자

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음

      idw_data[1].AcceptText()
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]
		ldc_contractseq =  idw_data[1].object.contractmst_contractseq[1]
		ls_customerid = idw_data[1].object.contractmst_customerid[1]
		//계약철회상태코드			
		ls_ref_desc = ""
		ls_status = ""
		ls_status = fs_get_control("B0","P244", ls_ref_desc)
		ls_remark = Trim(idw_data[1].object.svcorder_remark[1])
		
		Update svcorder
		Set status = :ls_status,
			 remark = :ls_remark,
			 updt_user = :gs_user_id,
			 updtdt = sysdate,
			 pgm_id = :gs_pgm_id[gi_open_win_no]
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
			
		Update contractmst
		Set status = :ls_status,
			 remark = :ls_remark,
			 termdt = to_date(:is_data[1],'yyyy-mm-dd'),
			 bil_todt = to_date(:is_data[1],'yyyy-mm-dd'),
			 updt_user = :gs_user_id,
			 updtdt = sysdate,
			 pgm_id = :gs_pgm_id[gi_open_win_no]
		Where contractseq = :ldc_contractseq;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTSEQ Table")				
			Return 
		End If

		//개통상태코드			
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		
		//Insert
		insert into partner_ardtl
			 ( seq, partner, trdt, artrcod, tramt, org_partner,customerid,
				orderno, itemcod, remark, crt_user, crtdt, pgm_id )
		    ( select seq_partnerar.nextval,
						    ar.partner,
							 sysdate,
							 ar.artrcod,
							 ar.tramt * (-1),
							 ar.org_partner,
							 ar.customerid,
							 :ldc_orderno,
							 ar.itemcod,
							 '계약철회로 인한 미수금조정',
							 :gs_user_id,
							 sysdate,
							 :gs_pgm_id[gi_open_win_no]
					 from partner_ardtl ar, svcorder sv
					where ar.orderno = sv.orderno
					  and sv.status = :ls_status
					  and sv.ref_contractseq = :ldc_contractseq ) ;

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(partnerdtl)")
			Return 
		End If	
			
		//대리점의 여신관리여부가 Y일경우의 처리
		//총출고금액(tot_samt)에 ADMODEL의 이동기준금액(partner_amt)을 update 한다. 2003.10.31 김은미 수정. (sale_amt)로 변경.
		ls_ref_desc = ""
		ls_levelcod = fs_get_control("A1","C100", ls_ref_desc)
			
		Update partnermst
		Set tot_samt = nvl(tot_samt,0) - nvl((select nvl(a.sale_amt,0)
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
	
		//대리점재고 상태코드
		ls_daricod = fs_get_control("E1","A102", ls_ref_desc)
		//본사재고 상태코드
		ls_boncod = fs_get_control("E1","A100", ls_ref_desc)
		//본사대리점코드 
		ls_bonsacod = fs_get_control("A1","C102", ls_ref_desc)
		
		Update admst
		Set status = decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
			 saledt = null,
			 customerid = null,
			 sale_amt = null,
			 sale_flag = '0',
			 dlvstat = null,
			 updt_user = :gs_user_id,
			 updtdt = sysdate,
			 pgm_id = :gs_pgm_id[gi_open_win_no]
		Where contractseq = :ldc_contractseq;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update ADMST Table")				
			Return 
		End If
			
		//계약철회코드 
		ls_action = fs_get_control("E1","A307", ls_ref_desc)

		//Insert
		insert into admstlog
			 ( adseq, seq, action, status, actdt, customerid, fr_partner,
				crt_user, crtdt, pgm_id )
		   select adseq,
					 seq_admstlog.nextval,
					 :ls_action,
					 decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod), 
					 sysdate,
					 :ls_customerid,
					 mv_partner,
					 :gs_user_id,
					 sysdate, 
					 :gs_pgm_id[gi_open_win_no]					
		  from admst where contractseq = :ldc_contractseq;					

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(admstlog)")
			Return 
		End If	
			
		//개통상태코드			
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		
		ll_cnt = 0
		select count(*) 
		  into :ll_cnt
		  from contractmst
		 where customerid = :ls_customerid
			and status = :ls_status;

		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " select count contractmst")
			Return 
		End If	

		If ll_cnt = 0 then
			
			//고객상태(계약철회)
			ls_cus_status = fs_get_control("B0","P205", ls_ref_desc)
			
			Update customerm
			Set status = :ls_cus_status,
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :gs_pgm_id[gi_open_win_no]
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update customerm Table")				
				Return 
			End If
		End if
				
		Commit;

END Choose

ii_rc = 0
RETURN
end subroutine

public subroutine uf_prc_db_01 ();ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_customer_batch_cv%ok"
//lu_dbmgr3.is_caller = "b1w_reg_customer_batch_cv%ok"
//lu_dbmgr3.is_title = Title
//lu_dbmgr3.idw_data[1] = dw_detail
//lu_dbmgr3.is_data[1] = ls_activate_yn
//lu_dbmgr3.is_data[2] = ls_svccod
//lu_dbmgr3.is_data[3] = ls_priceplan
//lu_dbmgr3.is_data[4] = ls_remark
//lu_dbmgr3.is_data[5] = ls_bil_fromdt
//lu_dbmgr3.uf_prc_db_01()
//li_rc = lu_dbmgr3.ii_rc

		DataWindow dw_detail
		dw_detail = idw_data[1]
		
		Int i
		String ls_desc
		String ls_ctype1_code[]
		String ls_ctype2_code[]
		String ls_bilcycle_code[]
		String ls_inv_method_code[]
		String ls_pay_method_code[]
		String ls_taxtype_code[]
		Long ll_cnt
		Boolean lb_new

		//입력받은 데이터
		String ls_activate_yn
		String ls_svccod
		String ls_priceplan
		String ls_remark
		String ls_bil_fromdt
		
		ls_activate_yn = is_data[1]
		ls_svccod = is_data[2]
		ls_priceplan = is_data[3]
		ls_remark = is_data[4]
		//ls_bil_fromdt = is_data[5]
		
		//입력할 데이터
		//1.고객정보
		String ls_customerid
		String ls_customernm
		String ls_join
		String ls_stitle
		String ls_birthdt
		String ls_ctype1
		String ls_ctype2
		String ls_ssno
		String ls_cregno
		String ls_corpno
		String ls_corpnm
		String ls_representative
		String ls_zipcod
		String ls_addr1
		String ls_addr2
		String ls_phone1
		String ls_phone2
		String ls_enterdt
		String ls_location
		String ls_buildingno
		String ls_roomno
		String ls_passportno
		
		String ls_aptname
		String ls_customer_status
		
		//2.청구정보
		String ls_bilcycle
		String ls_inv_method
		String ls_inv_yn
		String ls_currency_type
		String ls_pay_method
		String ls_taxtype
		String ls_overdue_yn
		String ls_bil_zipcod
		String ls_bil_addr1
		String ls_bil_addr2
		String ls_bil_email
		
		Int li_cnt
		Long ll_rows
		ll_rows = dw_detail.rowcount()
		
		
		//가입상태
		ls_join = fs_get_control("B0","P200",ls_desc)
		
		
		//고객타입
		ll_cnt = fi_cut_string(fs_get_control("CV","CV10",ls_desc),";",ls_ctype1_code)
		ls_ctype1 = ls_ctype1_code[1]
		
		//개인고객
		String ls_ctype2_p
		ls_ctype2_p = fs_get_control("B0","P111",ls_desc)
		
		//법인고객
		String ls_ctype2_c
		ll_cnt = fi_cut_string(fs_get_control("B0","P110",ls_desc),";",ls_ctype2_code)
		ls_ctype2_c = ls_ctype2_code[1]
		
		//청구주기
		ll_cnt = fi_cut_string(fs_get_control("B0","P141",ls_desc),";",ls_bilcycle_code)
		ls_bilcycle = ls_bilcycle_code[2]
		
		//
		ls_inv_method = ls_bilcycle_code[3]
		
		//통화타입
		ls_currency_type = fs_get_control("B0","P105",ls_desc)
		
		//결제방법
		ls_pay_method = ls_bilcycle_code[1]
		
		//세금타입
		ll_cnt = fi_cut_string(fs_get_control("CV","CV10",ls_desc),";",ls_taxtype_code)
		ls_taxtype = ls_taxtype_code[2]
		
		
		String ls_status
		String ls_act_status
		String ls_term_status
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_desc)

		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_desc)		

		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_desc)
		
		
		
		//valid check
		FOR i=1 TO ll_rows
			//1.주민번호 및 여권번호 체크
			ls_ssno = Trim(dw_detail.object.ssno[i])
			//주민번호 "-" 없이..
			IF LenA(ls_ssno) = 14 THEN ls_ssno = MidA(ls_ssno,1,6) + MidA(ls_ssno,8,7)
			
			//여권번호
			ls_passportno = Trim(dw_detail.object.passportno[i])
			
//			If ls_ssno = "" AND ls_passportno = "" Then
//					f_msg_usr_err(200, is_title, "주민등록번호 또는 여권번호")
//					dw_detail.SetFocus()
//					dw_detail.SetRow(i)
//					dw_detail.SetColumn("ssno")
//					Return 
//			End If
			
			//개인
			IF ls_ssno <> "" THEN
				
				//주민번호 Check
				If fi_check_juminnum(ls_ssno) = -1 Then
					f_msg_usr_err(201, is_title, "주민등록번호")
					dw_detail.SetFocus()
					dw_detail.SetRow(i)
					dw_detail.SetColumn("ssno")
					Return
				End If
				
				IF MidA(ls_ssno,7,1) = "1" OR MidA(ls_ssno,7,1) = "2" THEN
					ls_birthdt = "19"+ MidA(ls_ssno,1,6)
				ELSE
					ls_birthdt = "20"+ MidA(ls_ssno,1,6)
				END IF
				
				IF not IsDate(MidA(ls_birthdt,1,4) +"-"+ MidA(ls_birthdt,5,2) +"-"+ MidA(ls_birthdt,7,2)) THEN
					f_msg_usr_err(201, is_title, "주민등록번호")
					dw_detail.SetFocus()
					dw_detail.SetRow(i)
					dw_detail.SetColumn("ssno")
					Return
				END IF
					

				//주민번호 중복체크
				SELECT COUNT(*)
				INTO :li_cnt
				FROM customerm
				WHERE ssno = :ls_ssno
				AND status = :ls_join;
				
				IF li_cnt <> 0 THEN
					f_msg_usr_err(9000, is_title, "등록된 주민번호로 가입상태인 고객이 있습니다.")
					dw_detail.SetFocus()
					dw_detail.SetRow(i)
					dw_detail.SetColumn("ssno")
					Return
				END IF
			
			//외국인
			ELSEIF ls_passportno <> "" THEN
				//여권번호 중복체크
				SELECT COUNT(*)
				INTO :li_cnt
				FROM customerm
				WHERE passportno = :ls_passportno
				AND status = :ls_join;
				
				IF li_cnt <> 0 THEN
					f_msg_usr_err(9000, is_title, "등록된 여권번호로 가입상태인 고객이 있습니다.")
					dw_detail.SetFocus()
					dw_detail.SetRow(i)
					dw_detail.SetColumn("passportno")
					Return
				END IF
			End If
			
			
			
			//2.아파트 동호 중복체크
			
			ls_location = Trim(dw_detail.object.location[i])
			ls_buildingno = UPPER(Trim(dw_detail.object.buildingno[i]))
			ls_roomno = UPPER(Trim(dw_detail.object.roomno[i]))
			
			SELECT count(*)
			INTO :ll_cnt
			FROM customerm
			WHERE location = :ls_location
			AND buildingno = :ls_buildingno
			AND roomno = :ls_roomno
			AND status = :ls_join;
			
			IF ll_cnt > 0 THEN
				f_msg_usr_err(201, is_title, "아파트 중복")
				dw_detail.SetFocus()
				dw_detail.SetRow(i)
				dw_detail.SetColumn("location")
				Return
			END IF
			
			
			
			//3.서비스 중복 신청 Check
			//해지 상태가 아닌 같은 서비스 & 가격정책이 있으면 신청 중복 error
			Select count(*)
			Into :ll_cnt
			From contractmst
			Where customerid = :ls_customerid and svccod = :ls_svccod 
			 and priceplan = :ls_priceplan and status <> :ls_term_status;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Select Error(SVCORDER)")
				Return 
			End If		
			
			If ll_cnt <> 0 Then
				f_msg_usr_err(201, is_title, "중복신청")
				dw_detail.SetFocus()
				dw_detail.SetRow(i)
				dw_detail.SetColumn("ssno")
				Return
			End If
			
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
				f_msg_usr_err(201, is_title, "중복신청")
				dw_detail.SetFocus()
				dw_detail.SetRow(i)
				dw_detail.SetColumn("ssno")
				Return
			End If
		NEXT
		
		
		
		//insert
		FOR i=1 TO ll_rows
			
			ls_ssno = Trim(dw_detail.object.ssno[i])
			//주민번호 "-" 없이..
			IF LenA(ls_ssno) = 14 THEN ls_ssno = MidA(ls_ssno,1,6) + MidA(ls_ssno,8,7)
			ls_customernm = Trim(dw_detail.object.customernm[i])
			
			ls_location = Trim(dw_detail.object.location[i])
			ls_buildingno = UPPER(Trim(dw_detail.object.buildingno[i]))
			ls_roomno = UPPER(Trim(dw_detail.object.roomno[i]))
			ls_passportno = Trim(dw_detail.object.passportno[i])
			
			ls_corpnm = Trim(dw_detail.object.corpnm[i])
			IF IsNull(ls_corpnm) THEN ls_corpnm = ""
					
			//개인
			IF ls_corpnm = "" THEN
				ls_ctype2 = ls_ctype2_p
				ls_cregno = ""
				ls_corpno = ""
				ls_representative = ""
			//법인
			ELSE
				ls_corpnm = Trim(dw_detail.object.corpnm[i])
				IF IsNull(ls_corpnm) THEN ls_corpnm = ""
					
				ls_ctype2 = ls_ctype2_c
				ls_cregno = Trim(dw_detail.object.cregno[i])
				IF IsNull(ls_cregno) THEN ls_cregno = ""
						
				ls_corpno = Trim(dw_detail.object.corpno[i])
				IF IsNull(ls_corpno) THEN ls_corpno = ""
						
				ls_representative = Trim(dw_detail.object.representative[i])
				IF IsNull(ls_representative) THEN ls_representative = ""
			END IF
			
			
					ls_location = Trim(dw_detail.object.location[i])
					IF IsNull(ls_location) THEN ls_location = ""
					
					//아파트 정보에서 주소를 읽어옴..
					SELECT name, addr_1, addr_2, zipcode
					INTO :ls_aptname, :ls_addr1, :ls_addr2, :ls_zipcod
					FROM apartments
					WHERE aptid = :ls_location;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " SELECT Error(APARTMENTS)")
						RollBack;
						Return 
					End If
					
					IF IsNull(ls_addr1) THEN ls_addr1 = ""
					
					IF IsNull(ls_addr2) THEN ls_addr2 = ""
					
					IF LenA(ls_zipcod) = 7 THEN ls_zipcod = MidA(ls_zipcod,1,3) + MidA(ls_zipcod,5,3)
					IF IsNull(ls_zipcod) THEN ls_zipcod = ""
					
					ls_phone1 = Trim(dw_detail.object.phone1[i])
					IF IsNull(ls_phone1) THEN ls_phone1 = ""
					
					ls_phone2 = Trim(dw_detail.object.phone2[i])
					IF IsNull(ls_phone2) THEN ls_phone2 = ""
					
					ls_enterdt = String(dw_detail.object.enterdt[i],"YYYYMMDD")
					IF IsNull(ls_enterdt) THEN ls_enterdt = ""
				
				
				
					
			//1.개인(내국인)
			IF ls_ssno <> "" AND ls_ctype2 = ls_ctype2_p THEN
			
				SELECT count(*)
				INTO :li_cnt
				FROM customerm
				WHERE ssno = :ls_ssno;
			
			
				//이미 등록된 주민번호라면.. 고객번호를 가져온다.
				IF li_cnt > 0 THEN
					
					lb_new = false
					
					SELECT customerid, status
					INTO :ls_customerid, :ls_customer_status
					FROM customerm
					WHERE ssno = :ls_ssno
					AND rownum = 1;
					
					//정보 Update
					UPDATE customerm
					SET location = :ls_location,
					buildingno = :ls_buildingno,
					roomno = :ls_roomno,
					status = :ls_join
					WHERE customerid = :ls_customerid;
					
				ELSE
				//새로 등록될 주민번호라면.. 신규고객을 등록한다.
					
					lb_new = true
					
					//ls_join = ls_join
					IF MidA(ls_ssno,7,1) = "1" OR MidA(ls_ssno,7,1) = "3" THEN
						ls_stitle = "M"
					ELSE
						ls_stitle = "F"
					END IF
					
					IF MidA(ls_ssno,7,1) = "1" OR MidA(ls_ssno,7,1) = "2" THEN
						ls_birthdt = "19"+ MidA(ls_ssno,1,6)
					ELSE
						ls_birthdt = "20"+ MidA(ls_ssno,1,6)
					END IF
					

				END IF
				
			//외국인(개인)인 경우
			ELSEIF ls_passportno <> "" AND ls_ctype2 = ls_ctype2_p THEN
				
				SELECT count(*)
				INTO :li_cnt
				FROM customerm
				WHERE passportno = :ls_passportno;
			
			
				//이미 등록된 여권번호라면.. 고객번호를 가져온다.
				IF li_cnt > 0 THEN
					
					lb_new = false
					
					SELECT customerid, status
					INTO :ls_customerid, :ls_customer_status
					FROM customerm
					WHERE passportno = :ls_passportno
					AND rowcount = 1;
					
					//정보 Update
					UPDATE customerm
					SET location = :ls_location,
					buildingno = :ls_buildingno,
					roomno = :ls_roomno,
					status = :ls_join
					WHERE customerid = :ls_customerid;
					
				ELSE
				//새로 등록될 여권번호라면.. 신규고객을 등록한다.
					
					lb_new = true
					
					ls_stitle = ""
					ls_birthdt = ""
					
				END IF
			
			//법인인경우
			ELSE 
				
				lb_new = true
				
				ls_stitle = ""
				ls_birthdt = ""
				
			END IF
				

			IF lb_new THEN
				
				SELECT seq_customerid.nextval
				INTO :ls_customerid
				FROM dual;

					//주민번호가 있는경우.
					IF ls_ssno <> "" THEN
				
						INSERT INTO customerm
						(
							customerid, payid, customernm, status, stitle, 
							birthdt, ctype1, ctype2, ssno, passportno,
							cregno, corpno, corpnm, representative, zipcod, addr1, addr2, 
							buildingno, roomno, phone1, phone2, enterdt, location,
							crt_user, updt_user, crtdt, updtdt, pgm_id
						)
						VALUES
						(
							:ls_customerid,:ls_customerid,:ls_customernm,:ls_join,:ls_stitle,
							to_date(:ls_birthdt,'yyyy-mm-dd'),:ls_ctype1,:ls_ctype2,:ls_ssno,:ls_passportno,
							:ls_cregno,:ls_corpno,:ls_corpnm,:ls_representative,:ls_zipcod,:ls_addr1,:ls_addr2,
							:ls_buildingno,:ls_roomno,:ls_phone1,:ls_phone2,to_date(:ls_enterdt,'yyyy-mm-dd'),:ls_location,
							:gs_user_id,:gs_user_id,sysdate,sysdate,:gs_pgm_id[gi_open_win_no]
						);
					
					//주민번호가 없는경우.
					ELSE
						
						INSERT INTO customerm
						(
							customerid, payid, customernm, status, 
							ctype1, ctype2, ssno, passportno,
							cregno, corpno, corpnm, representative, zipcod, addr1, addr2, 
							buildingno, roomno, phone1, phone2, enterdt, location,
							crt_user, updt_user, crtdt, updtdt, pgm_id
						)
						VALUES
						(
							:ls_customerid,:ls_customerid,:ls_customernm,:ls_join,
							:ls_ctype1,:ls_ctype2,:ls_ssno,:ls_passportno,
							:ls_cregno,:ls_corpno,:ls_corpnm,:ls_representative,:ls_zipcod,:ls_addr1,:ls_addr2,
							:ls_buildingno,:ls_roomno,:ls_phone1,:ls_phone2,to_date(:ls_enterdt,'yyyy-mm-dd'),:ls_location,
							:gs_user_id,:gs_user_id,sysdate,sysdate,:gs_pgm_id[gi_open_win_no]
						);
						
					END IF
					
				
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " INSERT Error(CUSTOMERM): "+ls_customernm)
						RollBack;
						Return 
					End If
			
				
				END IF
			
		
		//2.청구정보 Insert
		//	ls_bilcycle = ls_bilcycle
		//	ls_inv_method = ls_inv_method
			ls_inv_yn = "Y"
		//	ls_currency_type = ls_currency_type
		//	ls_pay_method = ls_pay_method
		//	ls_taxtype = ls_taxtype
			ls_overdue_yn = "Y"
			ls_bil_zipcod = ls_zipcod
			ls_bil_addr1 = Trim(dw_detail.object.bil_addr1[i])
			IF IsNull(ls_bil_addr1) THEN ls_bil_addr1 = ""
			IF ls_bil_addr1 = "" THEN ls_bil_addr1 = ls_addr1
			ls_bil_addr2 = Trim(dw_detail.object.bil_addr2[i])
			IF IsNull(ls_bil_addr2) THEN ls_bil_addr2 = ""
			IF ls_bil_addr2 = "" THEN ls_bil_addr2 = ls_addr2 + " " + ls_buildingno + "동 " + ls_roomno + "호"
			ls_bil_email = Trim(dw_detail.object.bil_email[i])
			IF IsNull(ls_bil_email) THEN ls_bil_email = ""
			
			IF lb_new THEN

				INSERT INTO billinginfo
				(
					customerid, bilcycle, inv_method, currency_type, pay_method,
					bil_zipcod, bil_addr1, bil_addr2, bil_email, 
					inv_yn, taxtype, overdue_yn, 
					crt_user, updt_user, crtdt, updtdt, pgm_id
				)
				VALUES
				(
					:ls_customerid, :ls_bilcycle, :ls_inv_method, :ls_currency_type, :ls_pay_method,
					:ls_bil_zipcod, :ls_bil_addr1, :ls_bil_addr2, :ls_bil_email, 
					:ls_inv_yn, :ls_taxtype, :ls_overdue_yn,
					:gs_user_id,:gs_user_id,sysdate,sysdate,:gs_pgm_id[gi_open_win_no]
				);
			ELSE
				
				UPDATE billinginfo
				SET bil_zipcod = :ls_bil_zipcod,
				bil_addr1 = :ls_bil_addr1,
				bil_addr2 = :ls_bil_addr2,
				bil_email = :ls_bil_email,
				crt_user = :gs_user_id, 
				updt_user = :gs_user_id, 
				crtdt = sysdate, 
				updtdt = sysdate, 
				pgm_id = :gs_pgm_id[gi_open_win_no]
				WHERE customerid = :ls_customerid;
				
			END IF
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(BILLINGINFO)")
				RollBack;
				Return 
			End If
			
		//3.서비스신청
		String ls_orderdt
		String ls_requestdt
		String ls_partner
		String ls_reg_partner
		String ls_sale_partner
		String ls_reg_prefix
		String ls_prmtype
		String ls_contractno
		String ls_use_yn
		
		
		ls_orderdt = ls_enterdt
		ls_requestdt = ls_enterdt
		ls_partner = fs_get_control("A1","C102",ls_desc)
		ls_reg_partner = ls_partner
		ls_sale_partner = ls_partner
		
		ls_prmtype = ""
		ls_contractno = ""
		
		
		If ls_reg_partner <> "" Then
			//대리점 Prefix
			Select prefixno
			Into :ls_reg_prefix
			From partnermst
			Where partner = :ls_reg_partner;
		End If
		
		Long ll_orderno
		Long ll_contractseq
			
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
		IF ls_activate_yn = "Y" THEN
			
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
		
		//svccod insert
		Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt,
					status, svccod, priceplan, prmtype, reg_partner, sale_partner,
					partner, ref_contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
		 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
				 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, 
				 :ls_partner, :ll_contractseq, :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
							
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(SVCORDER)")
			ii_rc = -1				
			RollBack;
			Return 
		End If

		IF ls_activate_yn = "Y" THEN
			
			ls_bil_fromdt = String(dw_detail.object.bil_fromdt[i],"YYYYMMDD")
			IF IsNull(ls_bil_fromdt) THEN ls_bil_fromdt = ""
			IF ls_bil_fromdt = "" THEN ls_bil_fromdt = ls_requestdt
			
			//Insert contractmst
			insert into contractmst
				( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
				   prmtype, reg_partner, sale_partner,partner,
				   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
			values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, :ls_svccod, :ls_priceplan,
				   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_partner,
				   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				   :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate, :ls_reg_prefix);
				   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
				Return 
			End If
				   
		End If
		
		//서비스에 해당하는 기본품목
		String ls_itemcod
		
//		SELECT itemcod
//		INTO :ls_itemcod
//		FROM itemmst
//		WHERE svccod = :ls_svccod
//		AND mainitem_yn = 'Y';

		DECLARE cur_itemcod CURSOR FOR
	  		SELECT i.itemcod
     		 FROM itemmst i , priceplandet p
     		WHERE i.svccod = :ls_svccod
		      AND p.priceplan = :ls_priceplan
       		  AND i.itemcod = p.itemcod
     		  AND i.mainitem_yn = 'Y';

		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			CLOSE cur_itemcod;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " CURSOR cur_itemcod")				
			Return 
		End If

		OPEN cur_itemcod;
		Do While(True)
			FETCH cur_itemcod
			Into :ls_itemcod;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
			    CLOSE cur_itemcod;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_itemcod")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				CLOSE cur_itemcod;
				Exit
			End If
			
		    //contractdet insert
			Insert Into contractdet(orderno, itemcod, contractseq)
			Values(:ll_orderno, :ls_itemcod, :ll_contractseq);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACDET)")
				ii_rc = -1					
			    CLOSE cur_itemcod;				
				RollBack;
				Return 
			End If
			
		Loop
		CLOSE cur_itemcod;		

	NEXT
		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db ();Integer li_cnt
String ls_mv_partner, ls_serialno, ls_tmp, ls_status, ls_customerid
String ls_ref_desc, ls_order_status
Long ll_hwseq

ii_rc = -1
Choose Case is_caller
	Case "b1w_inq_svcorder%cancel"
//		lu_dbmgr.is_caller = "b1w_inq_svcorder%cancel"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data  Order Number
//		lu_dbmgr3.is_data[2] = is_partner
//		lu_dbmgr3.is_data[3] = is_status_1
//		lu_dbmgr3.is_data[4] = is_status_2
//		lu_dbmgr3.is_data[6] = gs_user_id
//		lu_dbmgr3.is_data[7] = gs_pgm_id[gi_open_win_no]

		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[idw_data[1].getrow()])
		ls_order_status = Trim(idw_data[1].object.svcorder_status[idw_data[1].getrow()])

		//1.서비스신청(svcorder) 테이블 Delete
		DELETE FROM svcorder 
		WHERE to_char(orderno) = :is_data[1];

		String ls_reqactive //개통 신청 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		//개통신청인 경우 validinfo 삭제...
		IF ls_reqactive = ls_order_status Then
			
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
		
		
		
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_04 ();String ls_activate_yn, ls_svccod, ls_priceplan, ls_remark, ls_partner, ls_reg_partner
String ls_sale_partner, ls_maintain_partner, ls_desc, ls_join
String ls_ctype1, ls_ctype2, ls_bilcycle_code[], ls_bilcycle, ls_inv_method
String ls_currency_type, ls_pay_method, ls_taxtype_code[], ls_taxtype, ls_inv_type
String ls_status, ls_act_status, ls_term_status, ls_validkey, ls_enterdt
String ls_inv_yn, ls_overdue_yn, ls_orderdt, ls_requestdt, ls_prmtype, ls_contractno
String ls_reg_prefix, ls_use_yn, ls_bil_fromdt, ls_itemcod, ls_passwd, ls_pricemodel
String ls_ref_desc, ls_temp, ls_refilltype[], ls_gkid, ls_enddt, ls_langtype, ls_auth_method
String ls_customerid, ls_ipaddress, ls_serialno, ls_svctype, ls_adtype, ls_saleflag
String ls_validkey_org, ls_validkey_type, ls_validkey_status[], ls_level_code, ls_partner_main, ls_sale_prefix
Long   ll_rows, ll_cnt, i, ll_orderno, ll_contractseq, ll_extdays, ll_hwseq, ll_valid_cnt, ll_cnt1, ll_count, ll_len
Dec    ldc_first_refill_amt, ldc_first_sale_amt, ldc_price, ldc_rate, ldc_rate_first
Dec    ldc_basic_fee_first, ldc_basic_rate_first
DateTime ldt_bilfromdt, ldt_enddt
Boolean lb_flag
String ls_validkey1, ls_validkey2, ls_validkey3, ls_validkey4

		
ii_rc = -1
lb_flag = False

Choose Case is_caller
	Case "b1w_reg_actorder_pre_batch%ok"
//lu_dbmgr3.is_caller = "b1w_reg_actorder_pre_batch%ok"
//lu_dbmgr3.is_title = Title
//lu_dbmgr3.idw_data[1] = dw_detail
//lu_dbmgr3.is_data[1] = ls_activate_yn
//lu_dbmgr3.is_data[2] = ls_svccod
//lu_dbmgr3.is_data[3] = ls_priceplan
//lu_dbmgr3.is_data[4] = ls_remark
//lu_dbmgr3.is_data[5] = ls_parnter
//lu_dbmgr3.is_data[6] = ls_reg_parnter
//lu_dbmgr3.is_data[7] = ls_sale_parnter
//lu_dbmgr3.is_data[8] = ls_maintain_parnter
//lu_dbmgr3.uf_prc_db_01()
//li_rc = lu_dbmgr3.ii_rc

		
		
		ls_activate_yn      = is_data[1]
		ls_svccod           = is_data[2]
		ls_priceplan        = is_data[3]
		ls_remark           = is_data[4]
		ls_partner          = is_data[5]
		ls_reg_partner      = is_data[6]
		ls_sale_partner     = is_data[7]
		ls_maintain_partner = is_data[8]
		
		
		ll_rows = idw_data[1].rowcount()
		
		
		//가입상태
		ls_join = fs_get_control("B0","P200",ls_desc)
		
		
		//고객타입
		ls_ctype1 = fs_get_control("B0","P121",ls_desc)
		
		//개인고객
		ls_ctype2 = fs_get_control("B0","P111",ls_desc)
		
		
		//청구주기
		ll_cnt = fi_cut_string(fs_get_control("B0","P141",ls_desc),";",ls_bilcycle_code)
		ls_bilcycle = ls_bilcycle_code[2]
		
		//청구서발송방법
		ls_inv_method = ls_bilcycle_code[3]
		
		//결제방법
		ls_pay_method = ls_bilcycle_code[1]
		
		//청구서유형
		ls_inv_type = ls_bilcycle_code[4]
		
		//통화타입
		ls_currency_type = fs_get_control("B0","P105",ls_desc)
				
		
		//세금타입
		ls_taxtype = fs_get_control("B0","P142",ls_desc)
		
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_desc)

		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_desc)		

		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_desc)
		
		//서비스유형
		ls_svctype = fs_get_control("B0","P101", ls_desc)
		
		//장비판매구분
		ls_saleflag = fs_get_control("E1","A720", ls_desc)
		
		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])
		
			
		//valid check
		FOR i=1 TO ll_rows
			
			ls_validkey   = Trim(idw_data[1].Object.validkey[i])
			ls_validkey1  = Trim(idw_data[1].Object.validkey1[i])
			ls_validkey2  = Trim(idw_data[1].Object.validkey2[i])
			ls_validkey3  = Trim(idw_data[1].Object.validkey3[i])
			ls_validkey4  = Trim(idw_data[1].Object.validkey4[i])
			ls_passwd     = Trim(idw_data[1].Object.passwd[i])
			ls_enterdt    = Trim(idw_data[1].Object.enterdt[i])
			ls_bil_fromdt = Trim(idw_data[1].Object.bil_fromdt[i])
			ls_pricemodel = Trim(idw_data[1].Object.pricemodel[i])
			ls_enddt      = Trim(idw_data[1].Object.extdays[i])
			ls_gkid       = Trim(idw_data[1].Object.gkid[i])
			ls_ipaddress  = Trim(idw_data[1].Object.ip_address[i])
			ls_serialno   = Trim(idw_data[1].Object.serialno[i])
			ls_adtype     = Trim(idw_data[1].Object.adtype[i])
			
			SELECT seq_customerid.nextval
			INTO   :ls_customerid
			FROM   dual;
			
					
			INSERT INTO customerm
			(
				customerid, payid, customernm, status, 
				ctype1, ctype2, ssno, zipcod,
				addr1, addr2, phone1, enterdt, 
				crt_user, updt_user, crtdt, updtdt, pgm_id
			)
			VALUES
			(
				:ls_customerid,:ls_customerid,:ls_validkey,:ls_join,
				:ls_ctype1,:ls_ctype2,:ls_validkey,'111111',
				'1','1', '1',to_date(:ls_enterdt,'yyyy-mm-dd'),
				:gs_user_id,:gs_user_id,sysdate,sysdate,:gs_pgm_id[gi_open_win_no]
			);
						
				
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(CUSTOMERM): "+ls_validkey)
				RollBack;
				Return 
			End If
			

			ls_inv_yn = "Y"
			ls_overdue_yn = "Y"

				INSERT INTO billinginfo
				(
					customerid, bilcycle, inv_method, currency_type, 
					pay_method, bil_zipcod, bil_addr1, bil_addr2,
					inv_yn, taxtype, overdue_yn, inv_type,
					crt_user, updt_user, crtdt, updtdt, pgm_id
				)
				VALUES
				(
					:ls_customerid, :ls_bilcycle, :ls_inv_method, :ls_currency_type, 
					:ls_pay_method, '111111', '1', '1', 
					:ls_inv_yn, :ls_taxtype, :ls_overdue_yn, :ls_inv_type,
					:gs_user_id,:gs_user_id,sysdate,sysdate,:gs_pgm_id[gi_open_win_no]
				);
				
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(BILLINGINFO)")
				RollBack;
				Return 
			End If
			

			ls_orderdt   = ls_enterdt
			ls_requestdt = ls_enterdt
			ls_prmtype = ""
			ls_contractno = ""
		
		
			If ls_reg_partner <> "" Then
				//대리점 Prefix
				Select prefixno
				Into :ls_reg_prefix
				From partnermst
				Where partner = :ls_reg_partner;
			End If
			
			If ls_sale_partner <> "" Then
				//매출대리점 Prefix
				Select prefixno
				  Into :ls_sale_prefix
				  From partnermst
				 Where partner = :ls_sale_partner;
			End If
			
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
	
		
			IF ls_activate_yn = "Y" THEN
				//1. 해당 Partner, 해당 Priceplan
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
				  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_sale_partner  
					and priceplan = :ls_priceplan 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_sale_partner  
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
				 Where prefixno = substr(:ls_sale_prefix, 1, :ll_len);
				 
				If sqlca.sqlcode < 0 then
					f_msg_sql_err(is_title, is_caller + "Select Error(PARTNERmst)-관리대상대리점" )
					RollBack;
					Return
				End If
				
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
				  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_partner_main  
					and priceplan = :ls_priceplan 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_partner_main  
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
					 where partner = :ls_partner_main  
						and priceplan = 'ALL' 
						and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																		  from refillpolicy 
																		 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																			and partner   = :ls_partner_main  
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
						f_msg_usr_err(9000, is_title, is_caller + "There is no appropricate Recharge policy.")
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
			End If

			//Order Sequence
			SELECT seq_orderno.nextval
			  INTO :ll_orderno
			  FROM dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, " Validkey : " + ls_validkey + " Sequence Error")
				RollBack;
				ii_rc = -1				
				Return 
			End If		

			setnull(ll_contractseq)
		
		
		
      	//개통처리까지 check일 경우 : 개통처리까지 하는지 여부에 따라 status/사용여부가 바뀐다.
			IF ls_activate_yn = "Y" THEN
				
				//contractseq 가져 오기
				SELECT seq_contractseq.nextval
				  INTO :ll_contractseq
				  FROM dual;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + "SELECT seq_contractseq.nextval")			
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
			
			//svccod insert
			Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt, 
										status, svccod, priceplan, prmtype, reg_partner, enddt,
										sale_partner, partner, maintain_partner, ref_contractseq, 
										pricemodel, first_refill_amt, first_sale_amt, crt_user, 
										updt_user, crtdt, updtdt, pgm_id)
			 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
					 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, to_date(:ls_enddt,'yyyy-mm-dd'),
					 :ls_sale_partner, :ls_partner, :ls_maintain_partner, :ll_contractseq, 
					 :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :gs_user_id, 
					 :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
								
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(SVCORDER)")
				ii_rc = -1				
				RollBack;
				Return 
			End If
	
			IF ls_activate_yn = "Y" THEN
			
				ls_bil_fromdt = idw_data[1].object.bil_fromdt[i]
				IF IsNull(ls_bil_fromdt) THEN ls_bil_fromdt = ""
				IF ls_bil_fromdt = "" THEN ls_bil_fromdt = ls_requestdt
				
				//Insert contractmst
				Insert into contractmst
					( contractseq, customerid, activedt, status, termdt,
						svccod, priceplan, prmtype, reg_partner, sale_partner, enddt,
						partner, maintain_partner, orderdt, requestdt, 
						bil_fromdt, bil_todt, change_flag, termtype, contractno,
						crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
						balance, refillsum_amt, salesum_amt, first_refill_amt, 
						first_sale_amt, last_refill_amt, last_refilldt, pricemodel)
				Values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, 
						:ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, to_date(:ls_enddt,'yyyy-mm-dd'),
						:ls_partner, :ls_maintain_partner, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), 
						to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
						:gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate, :ls_reg_prefix,
						:ldc_first_refill_amt, :ldc_price, :ldc_first_sale_amt, :ldc_price, 
						:ldc_first_sale_amt,	:ldc_price, sysdate, :ls_pricemodel);
						
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(CONTRACTMST)")
					Return 
				End If
			
				//Insert contractmst
				insert into refilllog
					(  refillseq, contractseq, customerid, refilldt, 
						refill_type, refill_amt, sale_amt, basicamt, 
						remark, partner_prefix, crtdt, crt_user)
				values ( seq_refilllogseq.nextval, :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), 
						:ls_refilltype[1], :ldc_price, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt, 
						'최초충전', :ls_sale_prefix, sysdate, :gs_user_id);
				   
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(refilllog)")
					Return 
				End If	
				   
			End If

		
			//서비스에 해당하는 기본품목
			DECLARE cur_itemcod CURSOR FOR
				SELECT i.itemcod
				  FROM itemmst i , priceplandet p
				 WHERE i.svccod      = :ls_svccod
					AND p.priceplan   = :ls_priceplan
					AND i.itemcod     = p.itemcod;
	
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				CLOSE cur_itemcod;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " CURSOR cur_itemcod")				
				Return 
			End If
			
		
			OPEN cur_itemcod;
			Do While(True)
				FETCH cur_itemcod
				Into :ls_itemcod;
	
				If SQLCA.sqlcode < 0 Then
					RollBack;		
					 CLOSE cur_itemcod;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " CURSOR cur_itemcod")				
					Return
					
				ElseIf SQLCA.SQLCode = 100 Then
					CLOSE cur_itemcod;
					Exit
					
				End If
				
				//contractdet insert
				Insert Into contractdet(orderno, itemcod, contractseq)
				Values(:ll_orderno, :ls_itemcod, :ll_contractseq);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(CONTRACDET)")
					ii_rc = -1					
					CLOSE cur_itemcod;				
					RollBack;
					Return 
				End If
				
			Loop
			CLOSE cur_itemcod;
			
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			  from validinfo
			 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
					 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
					 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and validkey = :ls_validkey;
						  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Validkey : " + ls_validkey + "Select validinfo (count)")				
				Return 
			End If
				
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "ValidKey" + "[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				idw_data[1].SetFocus()
				idw_data[1].SetRow(i)
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("validkey")
				RollBack;				
				return 
			End if
			
			Insert Into validinfo
				 (validkey, fromdt, status, 
				 use_yn, vpassword, svctype, gkid, 
				 customerid, svccod, priceplan, orderno, 
				 contractseq, langtype, auth_method, validitem2,
				 crt_user, updt_user, crtdt, updtdt, pgm_id)
			 Values(:ls_validkey, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
					 :ls_use_yn, :ls_passwd, :ls_svctype, :ls_gkid, 
					 :ls_customerid, :ls_svccod, :ls_priceplan, :ll_orderno, 
					 :ll_contractseq, :ls_langtype, :ls_auth_method, :ls_ipaddress,
					 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(Validinfo)")
				ii_rc = -1						
				RollBack;
				Return 
			End If
			
			//2005-09-07 kem Modify
			Insert Into validinfo_sub
					(validkey, fromdt, svctype, todt, 
					 validkey1, validkey2, validkey3, validkey4, 
					 crtdt, crt_user, updtdt, updt_user, pgm_id)
				Values(:ls_validkey, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_svctype, null,
						 :ls_validkey1, :ls_validkey2, :ls_validkey3, :ls_validkey4, 
						 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(Validinfo_sub)")
				ii_rc = -1						
				RollBack;
				Return 
			End If
			
			//2005-05-31 kem Modify
			//해당 인증Key의 적용시작일, 종료일 체크한 후 serial 중복 체크...
			//ls_validkey = Trim(idw_data[1].Object.remark[i])
			If ls_serialno <> '' Then
				
				SELECT COUNT(*), NVL(REMARK, 'NULL')
				INTO   :ll_cnt1, :ls_validkey_org
				FROM   CUSTOMER_HW
				WHERE  SERIALNO = :ls_serialno
				GROUP BY REMARK;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "SELECT ERROR (CUSTOMER_HW)")
					idw_data[1].SetFocus()
					idw_data[1].SetRow(i)
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("serialno")
					RollBack;				
					return 
				End If
				
				If ll_cnt1 > 0 Then
					
					If ls_validkey_org <> 'NULL' Then
						
						SELECT COUNT(*)
						INTO   :ll_valid_cnt
						FROM   VALIDINFO
						WHERE  ( (TO_CHAR(FROMDT,'YYYYMMDD') > TO_CHAR(SYSDATE,'YYYYMMDD') )
						OR	    ( TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
						AND     TO_CHAR(SYSDATE,'YYYYMMDD') < NVL(TO_CHAR(TODT,'YYYYMMDD'),'99991231')) )
						AND     VALIDKEY = :ls_validkey_org;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_caller, "SELECT ERROR (VALIDINFO)")
							idw_data[1].SetFocus()
							idw_data[1].SetRow(i)
							idw_data[1].ScrollToRow(i)
							idw_data[1].SetColumn("serialno")
							RollBack;				
							return 
						End If
						
						If ll_valid_cnt > 0 Then
							f_msg_usr_err(9000, is_title, '인증Key : ' + ls_validkey_org + '로 Serial No 가 중복됩니다.')
							idw_data[1].SetFocus()
							idw_data[1].SetRow(i)
							idw_data[1].ScrollToRow(i)
							idw_data[1].SetColumn("validkey")
							RollBack;				
							return 
						End If
						
					End If
				End If
			End If
			
			
			//CUSTOMER_HW 정보 Insert
			Select seq_adseq.nextval
			Into :ll_hwseq
			From dual;
			
			Insert Into customer_hw
					(hwseq, rectype, customerid, sale_flag,
					 adtype, serialno, remark, orderno, 
					 crt_user, updt_user, crtdt, updtdt, pgm_id)
			Values (:ll_hwseq, 'C', :ls_customerid, :ls_saleflag,
                 :ls_adtype, :ls_serialno, :ls_validkey, :ll_orderno, 
					  :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
			
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "ValidKey" + "[" + ls_validkey + "] Insert Error(Customer_hw)")
				idw_data[1].SetFocus()
				idw_data[1].SetRow(i)
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("validkey")
				RollBack;				
				return 
			End if
			
			Commit;
			
		NEXT
		
		
	Case "b1w_reg_actorder_pre_batch_1%ok"
//lu_dbmgr3.is_caller = "b1w_reg_actorder_pre_batch%ok"
//lu_dbmgr3.is_title = Title
//lu_dbmgr3.idw_data[1] = dw_detail
//lu_dbmgr3.is_data[1] = ls_activate_yn
//lu_dbmgr3.is_data[2] = ls_svccod
//lu_dbmgr3.is_data[3] = ls_priceplan
//lu_dbmgr3.is_data[4] = ls_remark
//lu_dbmgr3.is_data[5] = ls_parnter
//lu_dbmgr3.is_data[6] = ls_reg_parnter
//lu_dbmgr3.is_data[7] = ls_sale_parnter
//lu_dbmgr3.is_data[8] = ls_maintain_parnter
//lu_dbmgr3.uf_prc_db_01()
//li_rc = lu_dbmgr3.ii_rc

		
		
		ls_activate_yn      = is_data[1]
		ls_svccod           = is_data[2]
		ls_priceplan        = is_data[3]
		ls_remark           = is_data[4]
		ls_partner          = is_data[5]
		ls_reg_partner      = is_data[6]
		ls_sale_partner     = is_data[7]
		ls_maintain_partner = is_data[8]
		
		
		ll_rows = idw_data[1].rowcount()
		
		
		//가입상태
		ls_join = fs_get_control("B0","P200",ls_desc)
		
		
		//고객타입
		ls_ctype1 = fs_get_control("B0","P121",ls_desc)
		
		//개인고객
		ls_ctype2 = fs_get_control("B0","P111",ls_desc)
		
		
		//청구주기
		ll_cnt = fi_cut_string(fs_get_control("B0","P141",ls_desc),";",ls_bilcycle_code)
		ls_bilcycle = ls_bilcycle_code[2]
		
		//청구서발송방법
		ls_inv_method = ls_bilcycle_code[3]
		
		//결제방법
		ls_pay_method = ls_bilcycle_code[1]
		
		//청구서유형
		ls_inv_type = ls_bilcycle_code[4]
		
		//통화타입
		ls_currency_type = fs_get_control("B0","P105",ls_desc)
				
		
		//세금타입
		ls_taxtype = fs_get_control("B0","P142",ls_desc)
		
		
		//개통신청상태코드
 		ls_status = fs_get_control("B0", "P220", ls_desc)

		//개통상태코드
 		ls_act_status = fs_get_control("B0", "P223", ls_desc)		

		//해지상태코드
		ls_term_status = fs_get_control("B0", "P201", ls_desc)
		
		//서비스유형
		ls_svctype = fs_get_control("B0","P101", ls_desc)
		

		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])
		
		//인증Key 관리상태(00:생성, 20:개통, 99:해지)
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","P400", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_validkey_status[])
		
		
		//valid check
		FOR i=1 TO ll_rows
			
			ls_validkey   = Trim(idw_data[1].Object.validkey[i])
			ls_passwd     = Trim(idw_data[1].Object.passwd[i])
			ls_enterdt    = Trim(idw_data[1].Object.enterdt[i])
			ls_bil_fromdt = Trim(idw_data[1].Object.bil_fromdt[i])
			ls_pricemodel = Trim(idw_data[1].Object.pricemodel[i])
			ls_enddt      = Trim(idw_data[1].Object.extdays[i])
			ls_gkid       = Trim(idw_data[1].Object.gkid[i])
			ls_ipaddress  = Trim(idw_data[1].Object.ip_address[i])
			ls_serialno   = Trim(idw_data[1].Object.serialno[i])

			
			SELECT seq_customerid.nextval
			INTO   :ls_customerid
			FROM   dual;
			
					
			INSERT INTO customerm
			(
				customerid, payid, customernm, status, 
				ctype1, ctype2, ssno, zipcod,
				addr1, addr2, phone1, enterdt,
				logid, password, crt_user, updt_user, 
				crtdt, updtdt, pgm_id
			)
			VALUES
			(
				:ls_customerid, :ls_customerid, :ls_validkey, :ls_join,
				:ls_ctype1, :ls_ctype2, :ls_validkey, '111111',
				'1', '1', '1', to_date(:ls_enterdt,'yyyy-mm-dd'),
				:ls_validkey, :ls_passwd, :gs_user_id, :gs_user_id,
				sysdate, sysdate, :gs_pgm_id[gi_open_win_no]
			);
						
				
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(CUSTOMERM): "+ls_validkey)
				RollBack;
				Return 
			End If
			

			ls_inv_yn = "Y"
			ls_overdue_yn = "Y"

				INSERT INTO billinginfo
				(
					customerid, bilcycle, inv_method, currency_type, 
					pay_method, bil_zipcod, bil_addr1, bil_addr2,
					inv_yn, taxtype, overdue_yn, inv_type,
					crt_user, updt_user, crtdt, updtdt, pgm_id
				)
				VALUES
				(
					:ls_customerid, :ls_bilcycle, :ls_inv_method, :ls_currency_type, 
					:ls_pay_method, '111111', '1', '1', 
					:ls_inv_yn, :ls_taxtype, :ls_overdue_yn, :ls_inv_type,
					:gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]
				);
				
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(BILLINGINFO)")
				RollBack;
				Return 
			End If
			

			ls_orderdt   = ls_enterdt
			ls_requestdt = ls_enterdt
			ls_prmtype = ""
			ls_contractno = ""
		
		
			If ls_reg_partner <> "" Then
				//대리점 Prefix
				Select prefixno
				Into :ls_reg_prefix
				From partnermst
				Where partner = :ls_sale_partner;
			End If
			
			If ls_sale_partner <> "" Then
				//매출대리점 Prefix
				Select prefixno
				  Into :ls_sale_prefix
				  From partnermst
				 Where partner = :ls_sale_partner;
			End If
			
			
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
	
			
			IF ls_activate_yn = "Y" THEN
				
				//1. 해당 Partner, 해당 Priceplan
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
					  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_sale_partner  
					and priceplan = :ls_priceplan 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_sale_partner  
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
				 Where prefixno = substr(:ls_sale_prefix, 1, :ll_len);
				 
				If sqlca.sqlcode < 0 then
					f_msg_sql_err(is_title, is_caller + "Select Error(PARTNERmst)-관리대상대리점" )
					RollBack;
					Return
				End If
				
				Select nvl(rate_first,0), nvl(basic_fee_first,0), nvl(basic_rate_first,0)
				  Into :ldc_rate_first, :ldc_basic_fee_first, :ldc_basic_rate_first
				  From refillpolicy
				 where partner = :ls_partner_main  
					and priceplan = :ls_priceplan 
					and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																	  from refillpolicy 
																	 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																		and partner   = :ls_partner_main  
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
					 where partner = :ls_partner_main  
						and priceplan = 'ALL' 
						and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
																		  from refillpolicy 
																		 where to_char(fromdt, 'yyyymmdd') <= :ls_requestdt
																			and partner   = :ls_partner_main  
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
						ldc_first_refill_amt = ldc_price
						ldc_first_sale_amt   = ldc_price
							
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
			End If


			//Order Sequence
			SELECT seq_orderno.nextval
			  INTO :ll_orderno
			  FROM dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, " Validkey : " + ls_validkey + " Sequence Error")
				RollBack;
				ii_rc = -1				
				Return 
			End If		

			setnull(ll_contractseq)
		
		
		
      	//개통처리까지 check일 경우 : 개통처리까지 하는지 여부에 따라 status/사용여부가 바뀐다.
			IF ls_activate_yn = "Y" THEN
				
				//contractseq 가져 오기
				SELECT seq_contractseq.nextval
				  INTO :ll_contractseq
				  FROM dual;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + "SELECT seq_contractseq.nextval")			
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
			
			//svccod insert
			Insert Into svcorder (orderno, reg_prefixno, customerid, orderdt, requestdt, 
										status, svccod, priceplan, prmtype, reg_partner, enddt,
										sale_partner, partner, maintain_partner, ref_contractseq, 
										pricemodel, first_refill_amt, first_sale_amt, crt_user, 
										updt_user, crtdt, updtdt, pgm_id)
			 Values (:ll_orderno, :ls_reg_prefix, :ls_customerid, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'),
					 :ls_act_status, :ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, to_date(:ls_enddt,'yyyy-mm-dd'),
					 :ls_sale_partner, :ls_partner, :ls_maintain_partner, :ll_contractseq, 
					 :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :gs_user_id, 
					 :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
								
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(SVCORDER)")
				ii_rc = -1				
				RollBack;
				Return 
			End If
	
			IF ls_activate_yn = "Y" THEN
			
				ls_bil_fromdt = idw_data[1].object.bil_fromdt[i]
				IF IsNull(ls_bil_fromdt) THEN ls_bil_fromdt = ""
				IF ls_bil_fromdt = "" THEN ls_bil_fromdt = ls_requestdt
				
				//Insert contractmst
				Insert into contractmst
					( contractseq, customerid, activedt, status, termdt,
						svccod, priceplan, prmtype, reg_partner, sale_partner, enddt,
						partner, maintain_partner, orderdt, requestdt, 
						bil_fromdt, bil_todt, change_flag, termtype, contractno,
						crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
						balance, refillsum_amt, salesum_amt, first_refill_amt, 
						first_sale_amt, last_refill_amt, last_refilldt, pricemodel)
				Values ( :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status, null, 
						:ls_svccod, :ls_priceplan, :ls_prmtype, :ls_reg_partner, :ls_sale_partner, to_date(:ls_enddt,'yyyy-mm-dd'),
						:ls_partner, :ls_maintain_partner, to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), 
						to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
						:gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate, :ls_reg_prefix,
						:ldc_first_refill_amt, :ldc_price, :ldc_first_sale_amt, :ldc_price, 
						:ldc_first_sale_amt,	:ldc_price, sysdate, :ls_pricemodel);
						
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(CONTRACTMST)")
					Return 
				End If
			
				//Insert Refilllog
				insert into refilllog
					(  refillseq, contractseq, customerid, refilldt, 
						refill_type, refill_amt, sale_amt, basicamt, 
						remark, partner_prefix, crtdt, crt_user)
				values ( seq_refilllogseq.nextval, :ll_contractseq, :ls_customerid, to_date(:ls_requestdt,'yyyy-mm-dd'), 
						:ls_refilltype[1], :ldc_price, :ldc_first_sale_amt, :ldc_price - :ldc_first_refill_amt, 
						'최초충전', :ls_sale_prefix, sysdate, :gs_user_id);
				   
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(refilllog)")
					Return 
				End If	
				   
			End If

		
			//서비스에 해당하는 기본품목
			DECLARE cur_itemcod1 CURSOR FOR
				SELECT i.itemcod
				  FROM itemmst i , priceplandet p
				 WHERE i.svccod      = :ls_svccod
					AND p.priceplan   = :ls_priceplan
					AND i.itemcod     = p.itemcod;
	
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				CLOSE cur_itemcod;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " CURSOR cur_itemcod")				
				Return 
			End If
			
		
			OPEN cur_itemcod1;
			Do While(True)
				FETCH cur_itemcod1
				Into :ls_itemcod;
	
				If SQLCA.sqlcode < 0 Then
					RollBack;		
					 CLOSE cur_itemcod1;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " CURSOR cur_itemcod")				
					Return
					
				ElseIf SQLCA.SQLCode = 100 Then
					CLOSE cur_itemcod1;
					Exit
					
				End If
				
				 //contractdet insert
				Insert Into contractdet(orderno, itemcod, contractseq)
				Values(:ll_orderno, :ls_itemcod, :ll_contractseq);
						 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(CONTRACDET)")
					ii_rc = -1					
					CLOSE cur_itemcod1;				
					RollBack;
					Return 
				End If
				
			Loop
			CLOSE cur_itemcod1;
			
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			  from validinfo
			 where ( (to_char(fromdt,'yyyymmdd') > :ls_requestdt ) Or
					 ( to_char(fromdt,'yyyymmdd') <= :ls_requestdt and
					 :ls_requestdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and validkey = :ls_validkey;
						  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Validkey : " + ls_validkey + "Select validinfo (count)")	
				RollBack;
				Return 
			End If
				
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "ValidKey" + "[" + ls_validkey + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				idw_data[1].SetFocus()
				idw_data[1].SetRow(i)
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("validkey")
				RollBack;				
				return 
			End if
			
			Insert Into validinfo
				 (validkey, fromdt, status, 
				 use_yn, vpassword, svctype, gkid, 
				 customerid, svccod, priceplan, orderno, 
				 contractseq, langtype, auth_method, validitem2,
				 crt_user, updt_user, crtdt, updtdt, pgm_id)
			 Values(:ls_validkey, to_date(:ls_requestdt,'yyyy-mm-dd'), :ls_act_status,
					 :ls_use_yn, :ls_passwd, :ls_svctype, :ls_gkid, 
					 :ls_customerid, :ls_svccod, :ls_priceplan, :ll_orderno, 
					 :ll_contractseq, :ls_langtype, :ls_auth_method, :ls_ipaddress,
					 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Validkey : " + ls_validkey + " Insert Error(Validinfo)")
				ii_rc = -1						
				RollBack;
				Return 
			End If
			
			
//			//2005-05-31 kem Modify
//			//해당 인증Key의 적용시작일, 종료일 체크한 후 serial 중복 체크...
//			//ls_validkey = Trim(idw_data[1].Object.remark[i])
//			If ls_serialno <> '' Then
//				
//				SELECT COUNT(*), NVL(REMARK, 'NULL')
//				INTO   :ll_cnt1, :ls_validkey_org
//				FROM   CUSTOMER_HW
//				WHERE  SERIALNO = :ls_serialno
//				GROUP BY REMARK;
//				
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_caller, "SELECT ERROR (CUSTOMER_HW)")
//					idw_data[1].SetFocus()
//					idw_data[1].SetRow(i)
//					idw_data[1].ScrollToRow(i)
//					idw_data[1].SetColumn("serialno")
//					RollBack;				
//					return 
//				End If
//				
//				If ll_cnt1 > 0 Then
//					
//					If ls_validkey_org <> 'NULL' Then
//						
//						SELECT COUNT(*)
//						INTO   :ll_valid_cnt
//						FROM   VALIDINFO
//						WHERE  ( (TO_CHAR(FROMDT,'YYYYMMDD') > TO_CHAR(SYSDATE,'YYYYMMDD') )
//						OR	    ( TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
//						AND     TO_CHAR(SYSDATE,'YYYYMMDD') < NVL(TO_CHAR(TODT,'YYYYMMDD'),'99991231')) )
//						AND     VALIDKEY = :ls_validkey_org;
//						
//						If SQLCA.SQLCode < 0 Then
//							f_msg_sql_err(is_caller, "SELECT ERROR (VALIDINFO)")
//							idw_data[1].SetFocus()
//							idw_data[1].SetRow(i)
//							idw_data[1].ScrollToRow(i)
//							idw_data[1].SetColumn("serialno")
//							RollBack;				
//							return 
//						End If
//						
//						If ll_valid_cnt > 0 Then
//							f_msg_usr_err(9000, is_title, '인증Key : ' + ls_validkey_org + '로 Serial No 가 중복됩니다.')
//							idw_data[1].SetFocus()
//							idw_data[1].SetRow(i)
//							idw_data[1].ScrollToRow(i)
//							idw_data[1].SetColumn("validkey")
//							RollBack;				
//							return 
//						End If
//						
//					End If
//				End If
//			End If
			
			
//			//CUSTOMER_HW 정보 Insert
//			Select seq_adseq.nextval
//			Into :ll_hwseq
//			From dual;
//			
//			Insert Into customer_hw
//					(hwseq, rectype, customerid, sale_flag,
//					 adtype, serialno, remark, orderno, 
//					 crt_user, updt_user, crtdt, updtdt, pgm_id)
//			Values (:ll_hwseq, 'C', :ls_customerid, :ls_saleflag,
//                 :ls_adtype, :ls_serialno, :ls_validkey, :ll_orderno, 
//					  :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no]);
//			
//			
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(is_title, is_caller + "ValidKey" + "[" + ls_validkey + "] Insert Error(Customer_hw)")
//				idw_data[1].SetFocus()
//				idw_data[1].SetRow(i)
//				idw_data[1].ScrollToRow(i)
//				idw_data[1].SetColumn("validkey")
//				RollBack;				
//				return 
//			End if

			//가격정책별 인증Key Type Select
			Select validkey_type
			Into   :ls_validkey_type
			From   priceplan_validkey_type
			Where  priceplan = :ls_priceplan;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ERROR (PRICEPLAN_VALIDKEY_TYPE)")
				idw_data[1].SetFocus()
				idw_data[1].SetRow(i)
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("Validkey")
				RollBack;				
				return 
			End If
			
			//해당 인증key Type으로 인증키가 생성인지 여부 확인
			Select count(*)
			Into   :ll_count
			From   validkeymst
			Where  validkey      = :ls_validkey
			And    validkey_type = :ls_validkey_type
			And    status        = :ls_validkey_status[1];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ERROR (VALIDKEYMST)")
				idw_data[1].SetFocus()
				idw_data[1].SetRow(i)
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("Validkey")
				RollBack;				
				return 
			End If
			
			If ll_count > 0 Then
				Update validkeymst
				Set    status      = :ls_validkey_status[2],
				       sale_flag   = '1',
				       activedt    = to_date(:ls_requestdt,'yyyy-mm-dd'),
						 customerid  = :ls_customerid,
						 orderno     = :ll_orderno,
						 contractseq = :ll_contractseq,
						 updt_user   = :gs_user_id,
						 updtdt      = sysdate
				Where  validkey    = :ls_validkey
				And    validkey_type = :ls_validkey_type
				And    status      = :ls_validkey_status[1];
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "UPDATE ERROR (VALIDKEYMST)")
					idw_data[1].SetFocus()
					idw_data[1].SetRow(i)
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("Validkey")
					RollBack;				
					return 
				End If
				
				Insert Into validkeymst_log ( validkey, seq, status, actdt,
													   customerid, contractseq, partner, crt_user,
													   crtdt, pgm_id )
											Values ( :ls_validkey, seq_validkeymstlog.nextval, :ls_validkey_status[2], to_date(:ls_requestdt,'yyyy-mm-dd'),
													   :ls_customerid, :ll_contractseq, :ls_reg_partner, :gs_user_id,
													   sysdate, :gs_pgm_id[gi_open_win_no] );
			
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "INSERT ERROR (VALIDKEYMST_LOG)")
					idw_data[1].SetFocus()
					idw_data[1].SetRow(i)
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("Validkey")
					RollBack;				
					return 
				End If
				
			Else
				
				f_msg_usr_err(9000, is_title, '인증Key : ' + ls_validkey + '는 인증Key 관리 모듈에 Validkey가 존재하지 않습니다.')
				idw_data[1].SetFocus()
				idw_data[1].SetRow(i)
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("Validkey")
				RollBack;				
				return 
				
			End If
			
			Commit;
			
		NEXT
		
End Choose
ii_rc = 0
Return 
end subroutine

on b1u_dbmgr3.create
call super::create
end on

on b1u_dbmgr3.destroy
call super::destroy
end on

