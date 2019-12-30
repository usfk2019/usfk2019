$PBExportHeader$b2u_dbmgr.sru
$PBExportComments$[y.k.min] DB
forward
global type b2u_dbmgr from u_cust_a_db
end type
end forward

global type b2u_dbmgr from u_cust_a_db
event uf_prc_db_04 ( )
end type
global b2u_dbmgr b2u_dbmgr

type variables

end variables

forward prototypes
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_02 ();Dec  lc_tot_samt

ii_rc = -1

Choose Case is_caller
	Case "b2w_reg_partnerbond_recv%ue_save"		
	//		iu_db.is_caller = "b2w_reg_partnerbond_recv%ue_save"
	//		iu_db.is_title = Title
	//		iu_db.is_data[1] = ls_partner	    //대리점
	//		iu_db.is_data[2] = ls_work_type		//유형
	//		iu_db.is_data[3] = ls_remark	   	//비고
	//		iu_db.is_data[4] = gs_user_id
	//		iu_db.ic_data[1] = lc_work_amt		//금액
	//		iu_db.idw_data[1] = dw_detail
    //      iu_db.idw_data[2] = dw_cond	

			SELECT nvl(tot_samt,0)
			INTO  :lc_tot_samt
			FROM partnermst
			WHERE partner = :is_data[1];
			
			If lc_tot_samt < ic_data[1]  Then
				f_msg_usr_err(201, is_Title, "한도회복금액범위Check")
				idw_data[2].SetFocus()
				idw_data[2].SetColumn("work_amt")
				ii_rc = -2
				Return
			End If
			
			//작업 내용.
			INSERT INTO partnerrefill_limitlog (
							seqno,partner,worktype,
							workamt,remark,
							crt_user,crtdt, updt_user,
							updtdt,	pgm_id) 
				VALUES ( SEQ_REFILL_LIMIT.nextval,:is_data[1],:is_data[2],
							:ic_data[1],:is_data[3],
							:is_data[4],sysdate, :is_data[4],
							sysdate, :gs_pgm_id[gi_open_win_no]);
							
			If SQLCA.SQLCode < 0 Then	
				f_msg_sql_err(is_data[1],  " Insert Error(PARTNERBOND_recv)" )
				Return 
			End If
			
			UPDATE partnermst
			SET	tot_samt = tot_samt - :ic_data[1]
			WHERE	partner = :is_data[1];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_data[1], "Update Error(PARTNERMST)")
				Return
			End If		

End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_01 ();ii_rc = -1
		
//작업 내용.
	
INSERT INTO partnerrefill_limitlog (
				seqno,
				partner,
				worktype,
				workamt,
				remark,
				crt_user,
				crtdt,
				updt_user,
				updtdt,
				pgm_id) VALUES (
				SEQ_REFILL_LIMIT.nextval,
				:is_data[1],
				:is_data[2],
				:ic_data[1],
				:is_data[3],
				:is_data[4],
				sysdate,
				:is_data[4],
				sysdate,
				:gs_pgm_id[gi_open_win_no]);

				
If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " Insert Error(PARTNERREFILL_LIMITLOG)" )
	Return 
End If

UPDATE partnermst
SET	tot_credit = tot_credit + :ic_data[1]
WHERE	partner = :is_data[1];

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_data[1], "Update Error(PARTNERMST)")
	Return
End If		

ii_rc = 0
end subroutine

public subroutine uf_prc_db_03 ();
ii_rc = -1
String ls_regcomm, ls_settlecomm, ls_regcommarr[], ls_settlecommarr[], ls_desc, ls_presalecomm, ls_presalecommarr[]
String ls_paycomm, ls_paycommarr[]
String ls_reg, ls_settle, ls_pay, ls_todt, ls_premonth, ls_fromdt, ls_yn
Date ld_reg1month_pre, ld_reg2month_pre, ld_settle1month_pre, ld_settle2month_pre, ld_paymonth_pre
int li_regcnt, li_settlecnt, li_paycnt, li_presalecnt

String ls_maintaincomm, ls_maintaincommarr[]
int li_maintaincnt
		
Choose Case is_caller
	Case "b2w_prc_cancel_commdet_maintain%ue_process"
		//작업 내용.
		Delete From  commdet
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMDET)")
			Return 
		End If
		
		Delete From commdet2
				WHERE to_char(commdt,'yyyymm') = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMDET2)")
			Return 
		End If
		
		Delete From  commReqnum
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMReqnum)")
			Return 
		End If
		
		Delete From  commTramt
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMTramt)")
			Return 
		End If
		
		ls_regcomm = fs_get_control('A1', 'C310', ls_desc)			// 유치수수료 최종 대상일From;대상일To;발생년월
		ls_settlecomm = fs_get_control('A1', 'C311', ls_desc)		// 매출수수료 최종 대상일From;대상일To;발생년월
		ls_presalecomm = fs_get_control('A1', 'C312', ls_desc) 	// 선불매출수수료 최종 대상일From;대상일To;발생년월

		//2005.01.27 관리수수료 
		ls_maintaincomm = fs_get_control('A1', 'C313', ls_desc) 	// 관리수수료 최종 대상일From;대상일To;발생년월
		
		li_regcnt = fi_cut_string(ls_regcomm, ';', ls_regcommarr)
		li_settlecnt = fi_cut_string(ls_settlecomm, ';', ls_settlecommarr)		
		li_presalecnt = fi_cut_string(ls_presalecomm, ';', ls_presalecommarr)

		//2005.01.27 관리수수료 
		li_maintaincnt = fi_cut_string(ls_maintaincomm, ';', ls_maintaincommarr)
		
		
		If is_data[1] = ls_regcommarr[3] Then
			// 유치수수료 최종 대상년월;발생년월 -1월
			//ld_reg1month_pre = fd_pre_month(Date(Mid(ls_regcommarr[1],1,4) + "-" + Mid(ls_regcommarr[1],5,2) + "-01"),1)
			//ld_reg2month_pre = fd_pre_month(Date(Mid(ls_regcommarr[3],1,4) + "-" + Mid(ls_regcommarr[3],5,2) + "-01"),1)
			//ls_reg = String(ld_reg1month_pre, 'yyyymm')+";"+String(ld_reg2month_pre, 'yyyymm')
			
			Select to_char(to_date(:ls_regcommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_regcommarr[3],'yyyymm'),-1),'yyyymm'),
					 to_char(add_months(to_date(:ls_regcommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_regcommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C310';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T - A1, C310)")
				Return 
			End If
		End If
		
		If is_data[1] = ls_settlecommarr[3] Then
			// 매출수수료 최종 대상년월;발생년월 -1월
			//ld_settle1month_pre = fd_pre_month(Date(Mid(ls_settlecommarr[1],1,4) + "-" + Mid(ls_settlecommarr[1],5,2) + "-01"),1)
			//ld_settle2month_pre = fd_pre_month(Date(Mid(ls_settlecommarr[2],1,4) + "-" + Mid(ls_settlecommarr[2],5,2) + "-01"),1)
			//ls_settle = String(ld_settle1month_pre, 'yyyymm')+";"+String(ld_settle2month_pre, 'yyyymm')

			Select to_char(to_date(:ls_settlecommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_settlecommarr[3],'yyyymm'),-1),'yyyymm'),
				    to_char(add_months(to_date(:ls_settlecommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_settlecommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월		
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C311';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C311)")
				Return 
			End If
		End If
		
		If is_data[1] = ls_presalecommarr[3] Then

			Select to_char(to_date(:ls_presalecommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_presalecommarr[3],'yyyymm'),-1),'yyyymm'),
				    to_char(add_months(to_date(:ls_presalecommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_presalecommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월		
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C312';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C312)")
				Return 
			End If
		End If
		
		
		//2005.01.27 관리수수료 
		If is_data[1] = ls_maintaincommarr[3] Then

			Select to_char(to_date(:ls_maintaincommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_maintaincommarr[3],'yyyymm'),-1),'yyyymm'),
				    to_char(add_months(to_date(:ls_maintaincommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_maintaincommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월		
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C313';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C313)")
				Return 
			End If
		End If		
	
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db ();
ii_rc = -1
String ls_regcomm, ls_settlecomm, ls_regcommarr[], ls_settlecommarr[], ls_desc, ls_presalecomm, ls_presalecommarr[]
String ls_paycomm, ls_paycommarr[]
String ls_reg, ls_settle, ls_pay, ls_todt, ls_premonth, ls_fromdt, ls_yn
Date ld_reg1month_pre, ld_reg2month_pre, ld_settle1month_pre, ld_settle2month_pre, ld_paymonth_pre
int li_regcnt, li_settlecnt, li_paycnt, li_presalecnt
		
Choose Case is_caller
	Case "b2w_prc_cancel_commdet%ue_process"
		//작업 내용.
		Delete From  commdet
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMDET)")
			Return 
		End If
		
		Delete From commdet2
				WHERE to_char(commdt,'yyyymm') = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMDET2)")
			Return 
		End If
		
		Delete From  commReqnum
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMReqnum)")
			Return 
		End If
		
		Delete From  commTramt
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(COMMTramt)")
			Return 
		End If
		
		ls_regcomm = fs_get_control('A1', 'C310', ls_desc)			// 유치수수료 최종 대상일From;대상일To;발생년월
		ls_settlecomm = fs_get_control('A1', 'C311', ls_desc)		// 매출수수료 최종 대상일From;대상일To;발생년월
		ls_presalecomm = fs_get_control('A1', 'C312', ls_desc) 	// 선불매출수수료 최종 대상일From;대상일To;발생년월
		
		li_regcnt = fi_cut_string(ls_regcomm, ';', ls_regcommarr)
		li_settlecnt = fi_cut_string(ls_settlecomm, ';', ls_settlecommarr)		
		li_presalecnt = fi_cut_string(ls_presalecomm, ';', ls_presalecommarr)
		
		If is_data[1] = ls_regcommarr[3] Then
			// 유치수수료 최종 대상년월;발생년월 -1월
			//ld_reg1month_pre = fd_pre_month(Date(Mid(ls_regcommarr[1],1,4) + "-" + Mid(ls_regcommarr[1],5,2) + "-01"),1)
			//ld_reg2month_pre = fd_pre_month(Date(Mid(ls_regcommarr[3],1,4) + "-" + Mid(ls_regcommarr[3],5,2) + "-01"),1)
			//ls_reg = String(ld_reg1month_pre, 'yyyymm')+";"+String(ld_reg2month_pre, 'yyyymm')
			
			Select to_char(to_date(:ls_regcommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_regcommarr[3],'yyyymm'),-1),'yyyymm'),
					 to_char(add_months(to_date(:ls_regcommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_regcommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C310';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T - A1, C310)")
				Return 
			End If
		End If
		
		If is_data[1] = ls_settlecommarr[3] Then
			// 매출수수료 최종 대상년월;발생년월 -1월
			//ld_settle1month_pre = fd_pre_month(Date(Mid(ls_settlecommarr[1],1,4) + "-" + Mid(ls_settlecommarr[1],5,2) + "-01"),1)
			//ld_settle2month_pre = fd_pre_month(Date(Mid(ls_settlecommarr[2],1,4) + "-" + Mid(ls_settlecommarr[2],5,2) + "-01"),1)
			//ls_settle = String(ld_settle1month_pre, 'yyyymm')+";"+String(ld_settle2month_pre, 'yyyymm')

			Select to_char(to_date(:ls_settlecommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_settlecommarr[3],'yyyymm'),-1),'yyyymm'),
				    to_char(add_months(to_date(:ls_settlecommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_settlecommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월		
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C311';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C311)")
				Return 
			End If
		End If
		
		If is_data[1] = ls_presalecommarr[3] Then

			Select to_char(to_date(:ls_presalecommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_presalecommarr[3],'yyyymm'),-1),'yyyymm'),
				    to_char(add_months(to_date(:ls_presalecommarr[1],'yyyymmdd'),-1),'yyyymmdd'),
					 :ls_presalecommarr[4]
			Into   :ls_todt, :ls_premonth, :ls_fromdt, :ls_yn
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월		
			Update sysctl1t
			Set 	 ref_content = :ls_fromdt || ';' || :ls_todt || ';' || :ls_premonth || ';' || :ls_yn
			Where	 module = 'A1' and ref_no = 'C312';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C312)")
				Return 
			End If
		End If
	
	Case "b2w_prc_cancel_partner_reqdtl%ue_process"
		//작업 내용.
		Delete From partner_reqdtl
		Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(PARTNER_REQDTL)")
			Return
		End If
		
		ls_paycomm = fs_get_control('A1', 'C320', ls_desc)			// 대리점지급수수료정산 최종작업년월(yyyymm)
		li_paycnt = fi_cut_string(ls_paycomm, ';', ls_paycommarr)
		
		// 대리점지급수수료정산 최종작업년월(yyyymm) -1월
		ld_paymonth_pre = fd_pre_month(Date(MidA(ls_paycommarr[1],1,4) + "-" + MidA(ls_paycommarr[1],5,2) + "-01"),1)
		ls_pay = String(ld_paymonth_pre, 'yyyymm')
		
		Update sysctl1t
			Set 	 ref_content = :ls_pay
			Where	 module = 'A1' and ref_no = 'C320';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C320)")
				Return 
			End If
	
Case "b2w_prc_cancel_settle_commdet%ue_process"
		//작업 내용.
		Delete From  settle_commdet
		       Where to_char(commdt,'yyyymm') = :is_data[1];
	   
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Delete Error(SETTLE_COMMDET)")
			Return 
		End If
		
		ls_regcomm = fs_get_control('A1', 'C350', ls_desc)			// 유치수수료 최종 대상일From;대상일To;발생년월
		ls_settlecomm = fs_get_control('A1', 'C351', ls_desc)		// 매출수수료 최종 대상일From;대상일To;발생년월
		
		li_regcnt = fi_cut_string(ls_regcomm, ';', ls_regcommarr)
		li_settlecnt = fi_cut_string(ls_settlecomm, ';', ls_settlecommarr)		
		
		If is_data[1] = ls_regcommarr[3] Then
			// 유치수수료 최종 대상년월;발생년월 -1월		
			Select to_char(to_date(:ls_regcommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_regcommarr[3],'yyyymm'),-1),'yyyymm')
			Into   :ls_todt, :ls_premonth
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월
			Update sysctl1t
			Set 	 ref_content = '00000000;' || :ls_todt || ';' || :ls_premonth
			Where	 module = 'A1' and ref_no = 'C350';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T - A1, C350)")
				Return 
			End If
		End If
		
		If is_data[1] = ls_settlecommarr[3] Then
			// 매출수수료 최종 대상년월;발생년월 -1월
			Select to_char(to_date(:ls_settlecommarr[1],'yyyymmdd')-1,'yyyymmdd'),
			       to_char(add_months(to_date(:ls_settlecommarr[3],'yyyymm'),-1),'yyyymm')
			Into   :ls_todt, :ls_premonth
			From   dual;
			
			// ref_content = 대상일From(00000000);대상일To;발생년월		
			Update sysctl1t
			Set 	 ref_content = '00000000;' || :ls_todt || ';' || :ls_premonth
			Where	 module = 'A1' and ref_no = 'C351';
	   
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(SYSCTL1T  - A1, C351)")
				Return 
			End If
		End If
	
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_04 ();Long ll_cnt=0 , ll_used_qty = 0, ll_move_qty = 0
String ls_partprefix

ii_rc = -1

select prefixno
into :ls_partprefix
from partnermst
where partner =:is_data[1];

		
//작업 내용.
select count(partner)
  into :ll_cnt
  from partnerused_limit
  where partner  = :is_data[1]
    and priceplan =:is_data[2];

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " select Error(PARTNERUSED_LIMIT)" )
	Return
End if
	
If ll_cnt = 0 Then	

	
INSERT INTO partnerused_limit (
			   partner,
				priceplan,
				partner_prefixno,
				limitbal_qty,
				quota_qty,
				used_qty,
				move_qty,
				limit_flag,
				crt_user,
				crtdt) 
                         VALUES (
				:is_data[1],
				:is_data[2],
				:ls_partprefix,
				:ic_data[1],
				:ic_data[1],
				:ll_used_qty,
				:ll_move_qty,
				:is_data[7],
				:is_data[5],
				sysdate);
				
If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " Insert Error(PARTNERUSED_LIMIT)" )
	Return
End if
	
				

elseif ll_cnt >= 1 Then	
	UPDATE partnerused_limit
	SET	quota_qty = quota_qty + :ic_data[1],
		limitbal_qty = limitbal_qty + :ic_data[1],
		   updt_user = :is_data[5],
			updtdt = sysdate
	WHERE	partner = :is_data[1]
	And     priceplan = :is_data[2];
If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " update Error(PARTNERUSED_LIMIT)" )
	Return
End if
	
		
End iF

INSERT INTO partnerused_limitlog (
				seqno,
				partner,
				partner_prefixno,
				priceplan,
				worktype,
				workqty,
				remark,
				from_partner,
				to_partner,
				limit_flag,
				crt_user,
				crtdt,
				pgm_id) VALUES (
				SEQ_PARTNERUSED_LIMITLOG.nextval,
				:is_data[1],
				:ls_partprefix,
				:is_data[2],
				:is_data[3],
				:ic_data[1],
				:is_data[4],
				:is_data[6],
				:is_data[1],
				:is_data[7],
				:is_data[5],
				sysdate,
				:gs_pgm_id[gi_open_win_no]);

				
	If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(is_data[1],  " Insert Error(PARTNERUSED_LIMITLOG)" )
	Return 
	End If
	
ii_rc = 0

end subroutine

on b2u_dbmgr.create
call super::create
end on

on b2u_dbmgr.destroy
call super::destroy
end on

