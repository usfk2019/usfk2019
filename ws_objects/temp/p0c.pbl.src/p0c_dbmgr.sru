$PBExportHeader$p0c_dbmgr.sru
$PBExportComments$[y.k.min]
forward
global type p0c_dbmgr from u_cust_a_db
end type
end forward

global type p0c_dbmgr from u_cust_a_db
end type
global p0c_dbmgr p0c_dbmgr

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();String ls_model, ls_contno_fr, ls_contno_to, ls_lotno, ls_status_1, ls_status_2
String ls_opendt, ls_remark, ls_priceplan, ls_enddt, ls_contno_first, ls_contno_last, ls_refill_type
String ls_ref_desc, ls_tmp, ls_result[], ls_result2[], ls_sql, ls_where, ls_pid
String ls_partner_prefix, ls_partner, ls_contno, ls_eday, ls_mainoffice, ls_sale_flag
Dec{2} lc_amt, lc_sale_amt, lc_tot_amt, lc_tot_sale_amt
Dec lc_cnt, lc_outseq, lc_real_price
Integer li_return

ii_rc = -1
Choose Case is_caller
	Case "p0w_prc_out_1%saleout"
   	lc_amt 			= ic_data[1]
		lc_sale_amt 	= ic_data[2]
		ls_model 		= is_data[1]
		ls_contno_fr 	= is_data[2]
		ls_contno_to 	= is_data[3]
		ls_partner 		= is_data[4]		// 대리점 코드 
		ls_priceplan	= is_data[5]
		ls_lotno 		= is_data[6]
		ls_enddt 		= is_data[7]
		ls_opendt 		= is_data[8]
		ls_remark 		= is_data[9]
		ls_eday			= is_data[10]
		lc_cnt = 0
		
		//발행 상태 가져오기
	   ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result[])
		If li_return <= 0 Then Return
		ls_status_1 = ls_result[1]			//발행
		ls_status_2 = ls_result[2]			//판매
		
		//개통(신규판매)
		ls_refill_type = fs_get_control('P0', 'P106', ls_ref_desc) 	
		
		//본사prefixno
		ls_mainoffice = fs_get_control('A1', 'C101', ls_ref_desc)
		
		// 대리점 prefixno 가져
		Select prefixno
		Into :ls_partner_prefix
		From   partnermst
		Where partner = :ls_partner;
		
		//salepricemodel
		If IsNull(ls_model) Then ls_model = ""
		If ls_model <> "" Then
			ls_where += " And pricemodel= '" + ls_model + "' "
		End If
		
		//관리번호from
		If IsNull(ls_contno_fr) Then ls_contno_fr = ""
		If ls_contno_fr <> "" Then
			ls_where += " And contno >= '" + ls_contno_fr + "' "
		End If
		
		//관리번호to
		If IsNull(ls_contno_to) Then ls_contno_to = ""
		If ls_contno_to <> "" Then
			ls_where += " And contno <= '" + ls_contno_to + "' "
		End If
		
		//Lot #
		If IsNull(ls_lotno) Then ls_lotno  = ""
		If ls_lotno <> "" Then
			ls_where += " And lotno = '" + ls_lotno + "' "
		End If
		
		//출고 Seq
		Select seq_outseq.nextval
		Into :lc_outseq
		From dual;
		
		//판매상태
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P112', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result2[])
		If li_return <= 0 Then Return
		ls_sale_flag = ls_result2[1]			//판매상태
		
		
		//실제 Balance 값 구하기 - 2005. 1. 26 y.k.min
		SELECT real_price
		INTO	:lc_real_price
		FROM SALEPRICEMODEL
		WHERE pricemodel = :ls_model;
		
		
		//해당 조건에 해당하는 pin 찾기
		DECLARE out_pin DYNAMIC CURSOR FOR SQLSA;

		ls_sql += 	"Select pid, contno From p_cardmst where sale_flag <> '0' And " + &
		         	"status = '" + ls_status_1 + "' And partner_prefix = '" + ls_mainoffice + "' "
		If ls_where <> "" Then ls_sql += ls_where
		ls_sql += "Order by contno, pid"


  		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC out_pin;
		
		Do While(True)
			FETCH out_pin
			INTO :ls_pid, :ls_contno;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : out_pin")
				CLOSE out_pin;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			//p_cardmst Update
			Update p_cardmst set
				status = :ls_status_2, 		
				outseq = :lc_outseq, 
				usedsum_amt = 0,
				priceplan = :ls_priceplan, 
				partner_prefix = :ls_partner_prefix,
				first_refill_amt = :lc_amt, 
				sale_flag =:ls_sale_flag, 
				remark = :ls_remark, 
				opendt = to_date(:ls_opendt, 'yyyy-mm-dd'),
				enddt = to_date(:ls_enddt, 'yyyy-mm-dd'),
				refillsum_amt = :lc_amt,
				salesum_amt = :lc_sale_amt,
				balance = :lc_real_price,  //REAL_PRICE 추가 - 2005. 1. 25 y.k.min
				last_refill_amt = :lc_amt, 
				last_refilldt = to_date(:ls_opendt, 'yyyy-mm-dd'),
				first_sale_amt = :lc_sale_amt,
				updtdt = sysdate,
				updt_user = :gs_user_id,
				pgm_id = :gs_pgm_id[1]    
			Where pid = :ls_pid;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(P_CARDMST)")
				Return
			End If
			
			//p_rflog Insert 충전이력
			Insert Into p_refilllog
			( refillseq, pid, contno, refilldt, refill_type, refill_amt, 
			  sale_amt, remark, eday, partner_prefix, crtdt, crt_user, pricemodel, priceplan)
			Values 
			( SEQ_REFILLLOG.Nextval, :ls_pid, :ls_contno, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_refill_type, :lc_amt,
			  :lc_sale_amt, :ls_remark, to_number(:ls_eday) , :ls_partner_prefix, sysdate, :gs_user_id,
			  :ls_model, :ls_priceplan);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Insert Error(P_REFILLLOG)")
				Return
			End If
			
			lc_cnt += 1  //count
			
			//초기관리번호
			If lc_cnt = 1 Then
				ls_contno_first = ls_contno
				ls_contno_last = ls_contno
			Else
				ls_contno_last = ls_contno
			End If
			
			w_msg_wait.wf_progress_step()
			
		Loop			 
		CLOSE out_pin;
		
		//판매금액의 합계
		lc_tot_sale_amt = lc_cnt * lc_sale_amt
		//카드금액의 합계
		lc_tot_amt = lc_cnt * lc_amt
		
		//출고이력
		If lc_cnt> 0 Then
			Insert Into p_outlog
				(outseq, outdt, pricemodel, partner_prefix, out_qty, sdamt,
				 sale_amt, contno_fr, contno_to, remark, totamt, crtdt, crt_user)
			Values
				(:lc_outseq, to_date(:ls_opendt, 'yyyymmdd'), :ls_model, :ls_partner_prefix, :lc_cnt, :lc_sale_amt,
				 :lc_tot_sale_amt, :ls_contno_first, :ls_contno_last, :ls_remark, :lc_tot_amt, sysdate,  :gs_user_id);
				 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(P_OUTLOG)")
				Return
			End If 
		End If
		
		ic_data[1] = lc_cnt
		ic_data[2] = lc_tot_sale_amt
		is_data[1] = ls_contno_first
		is_data[2] = ls_contno_last
End Choose
ii_rc = 0
end subroutine

public subroutine uf_prc_db ();String ls_model, ls_contno_fr, ls_contno_to, ls_lotno, ls_status_1, ls_status_2
String ls_opendt, ls_remark, ls_priceplan, ls_enddt, ls_contno_first, ls_contno_last, ls_refill_type
String ls_ref_desc, ls_tmp, ls_result[], ls_result2[], ls_sql, ls_where, ls_pid
String ls_partner_prefix, ls_partner, ls_contno, ls_eday, ls_mainoffice, ls_sale_flag
Dec{2} lc_amt, lc_sale_amt, lc_tot_amt, lc_tot_sale_amt
Dec lc_cnt, lc_outseq
Integer li_return

ii_rc = -1
Choose Case is_caller
	Case "p0w_prc_out%saleout"
   	lc_amt 			= ic_data[1]
		lc_sale_amt 	= ic_data[2]
		ls_model 		= is_data[1]
		ls_contno_fr 	= is_data[2]
		ls_contno_to 	= is_data[3]
		ls_partner 		= is_data[4]		// 대리점 코드 
		ls_priceplan	= is_data[5]
		ls_lotno 		= is_data[6]
		ls_enddt 		= is_data[7]
		ls_opendt 		= is_data[8]
		ls_remark 		= is_data[9]
		ls_eday			= is_data[10]
		lc_cnt = 0
		
		//발행 상태 가져오기
	   ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result[])
		If li_return <= 0 Then Return
		ls_status_1 = ls_result[1]			//발행
		ls_status_2 = ls_result[2]			//판매
		
		//개통(신규판매)
		ls_refill_type = fs_get_control('P0', 'P106', ls_ref_desc) 	
		
		//본사prefixno
		ls_mainoffice = fs_get_control('A1', 'C101', ls_ref_desc)
		
		// 대리점 prefixno 가져
		Select prefixno
		Into :ls_partner_prefix
		From   partnermst
		Where partner = :ls_partner;
		
		//salepricemodel
		If IsNull(ls_model) Then ls_model = ""
		If ls_model <> "" Then
			ls_where += " And pricemodel= '" + ls_model + "' "
		End If
		
		//관리번호from
		If IsNull(ls_contno_fr) Then ls_contno_fr = ""
		If ls_contno_fr <> "" Then
			ls_where += " And contno >= '" + ls_contno_fr + "' "
		End If
		
		//관리번호to
		If IsNull(ls_contno_to) Then ls_contno_to = ""
		If ls_contno_to <> "" Then
			ls_where += " And contno <= '" + ls_contno_to + "' "
		End If
		
		//Lot #
		If IsNull(ls_lotno) Then ls_lotno  = ""
		If ls_lotno <> "" Then
			ls_where += " And lotno = '" + ls_lotno + "' "
		End If
		
		//출고 Seq
		Select seq_outseq.nextval
		Into :lc_outseq
		From dual;
		
		//판매상태
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P112', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result2[])
		If li_return <= 0 Then Return
		ls_sale_flag = ls_result2[1]			//판매상태
		
		
		/*//실제 Balance 값 구하기 - 2005. 1. 26 y.k.min=> 재수정 2005.05.28 juede
		SELECT price
		INTO	:lc_real_price
		FROM SALEPRICEMODEL
		WHERE pricemodel = :ls_model; */
		
		
		//해당 조건에 해당하는 pin 찾기
		DECLARE out_pin DYNAMIC CURSOR FOR SQLSA;

		ls_sql += 	"Select pid, contno From p_cardmst where sale_flag <> '0' And " + &
		         	"status = '" + ls_status_1 + "' And partner_prefix = '" + ls_mainoffice + "' "
		If ls_where <> "" Then ls_sql += ls_where
		ls_sql += "Order by contno, pid"


  		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC out_pin;
		
		Do While(True)
			FETCH out_pin
			INTO :ls_pid, :ls_contno;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : out_pin")
				CLOSE out_pin;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			//p_cardmst Update
			Update p_cardmst set
				status = :ls_status_2, 		
				outseq = :lc_outseq, 
				usedsum_amt = 0,
				priceplan = :ls_priceplan, 
				partner_prefix = :ls_partner_prefix,
				first_refill_amt = :lc_amt, 
				sale_flag =:ls_sale_flag, 
				remark = :ls_remark, 
				opendt = to_date(:ls_opendt, 'yyyy-mm-dd'),
				enddt = to_date(:ls_enddt, 'yyyy-mm-dd'),
				refillsum_amt = :lc_amt,
				salesum_amt = :lc_sale_amt,
				balance = :lc_amt,    //REAL_PRICE 추가 - 2005. 1. 25 y.k.min => 2005.05.30 khpark 재수정(원복)
				last_refill_amt = :lc_amt, 
				last_refilldt = to_date(:ls_opendt, 'yyyy-mm-dd'),
				first_sale_amt = :lc_sale_amt,
				updtdt = sysdate,
				updt_user = :gs_user_id,
				pgm_id = :gs_pgm_id[1]    
			Where pid = :ls_pid;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(P_CARDMST)")
				Return
			End If
			
			//p_rflog Insert 충전이력
			Insert Into p_refilllog
			( refillseq, pid, contno, refilldt, refill_type, refill_amt, 
			  sale_amt, remark, eday, partner_prefix, crtdt, crt_user, pricemodel, priceplan)
			Values 
			( SEQ_REFILLLOG.Nextval, :ls_pid, :ls_contno, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_refill_type, :lc_amt,
			  :lc_sale_amt, :ls_remark, to_number(:ls_eday) , :ls_partner_prefix, sysdate, :gs_user_id,
			  :ls_model, :ls_priceplan);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Insert Error(P_REFILLLOG)")
				Return
			End If
			
			lc_cnt += 1  //count
			
			//초기관리번호
			If lc_cnt = 1 Then
				ls_contno_first = ls_contno
				ls_contno_last = ls_contno
			Else
				ls_contno_last = ls_contno
			End If
			
			w_msg_wait.wf_progress_step()
			
		Loop			 
		CLOSE out_pin;
		
		//판매금액의 합계
		lc_tot_sale_amt = lc_cnt * lc_sale_amt
		//카드금액의 합계
		lc_tot_amt = lc_cnt * lc_amt
		
		//출고이력
		If lc_cnt> 0 Then
			Insert Into p_outlog
				(outseq, outdt, pricemodel, partner_prefix, out_qty, sdamt,
				 sale_amt, contno_fr, contno_to, remark, totamt, crtdt, crt_user)
			Values
				(:lc_outseq, to_date(:ls_opendt, 'yyyymmdd'), :ls_model, :ls_partner_prefix, :lc_cnt, :lc_sale_amt,
				 :lc_tot_sale_amt, :ls_contno_first, :ls_contno_last, :ls_remark, :lc_tot_amt, sysdate,  :gs_user_id);
				 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(P_OUTLOG)")
				Return
			End If 
		End If
		
		ic_data[1] = lc_cnt
		ic_data[2] = lc_tot_sale_amt
		is_data[1] = ls_contno_first
		is_data[2] = ls_contno_last
End Choose
ii_rc = 0
end subroutine

on p0c_dbmgr.create
call super::create
end on

on p0c_dbmgr.destroy
call super::destroy
end on

