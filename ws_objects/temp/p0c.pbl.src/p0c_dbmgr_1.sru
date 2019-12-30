$PBExportHeader$p0c_dbmgr_1.sru
$PBExportComments$[juede] 판매출고처리 anyuser  (refillpolicy -> basic & extdays)
forward
global type p0c_dbmgr_1 from u_cust_a_db
end type
end forward

global type p0c_dbmgr_1 from u_cust_a_db
end type
global p0c_dbmgr_1 p0c_dbmgr_1

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_model, ls_contno_fr, ls_contno_to, ls_lotno, ls_status_1, ls_status_2
String ls_opendt, ls_remark, ls_priceplan, ls_enddt, ls_contno_first, ls_contno_last, ls_refill_type
String ls_ref_desc, ls_tmp, ls_result[], ls_result2[], ls_sql, ls_where, ls_pid
String ls_partner_prefix, ls_partner, ls_contno, ls_eday, ls_mainoffice, ls_sale_flag, ls_refill_place[]
Dec{2} lc_amt, lc_sale_amt, lc_tot_amt, lc_tot_sale_amt, lc_b_rate, lc_basic
Dec lc_cnt, lc_outseq, lc_real_price
Integer li_return

ii_rc = -1

//2005.03.29 add =====START
Long ll_eday   
Dec{2} lc_basic_fee, lc_basic_rate, lc_basic_minus_balance = 0
//2005.03.29 add =====END

Choose Case is_caller
	Case "p0w_prc_out%saleout"  
		/*********************************************************************
		|| refillpolicy 에서 basic fee & basic rate & extdays 적용 2005.03.29*/
		//====================================================================
		//iu_db.ic_data[1] = ic_amt				//카드금액
		//iu_db.ic_data[2] = ic_sale_amt	      //판매금액
		//iu_db.ic_data[3] = ic_basic_fee      //기본료   2005.03.29 add
      //iu_db.ic_data[4] = ic_basic_rate     //기본료율 2005.03.29 add		
		//iu_db.is_data[1] = is_model			   //모델명
		//iu_db.is_data[2] = is_contno_fr
		//iu_db.is_data[3] = is_contno_to
		//iu_db.is_data[4] = is_partner			//대리점코드
		//iu_db.is_data[5] = is_priceplan		//가격정책
		//iu_db.is_data[6] = is_lotno			   //LOT NO
		//iu_db.is_data[7] = is_use_period		//유효기간
		//iu_db.is_data[8] = is_opendt			//개통일자
		//iu_db.is_data[9] = is_remark	
		//iu_db.il_data[1] = il_extdays        //연장일수 2005.03.29 add
		//=================================================================
   	lc_amt 			= ic_data[1]
		lc_sale_amt 	= ic_data[2]
		lc_basic_fee   = ic_data[3]   //basic fee 2005.03.29 add
		lc_basic_rate  = ic_data[4]   //basic rate 2005.03.29 add		
		ls_model 		= is_data[1]
		ls_contno_fr 	= is_data[2]
		ls_contno_to 	= is_data[3]
		ls_partner 		= is_data[4]   // 대리점 코드 
		ls_priceplan	= is_data[5]
		ls_lotno 		= is_data[6]
		ls_enddt 		= is_data[7]
		ls_opendt 		= is_data[8]
		ls_remark 		= is_data[9]
		ll_eday			= il_data[1]   //2005.03.29 modify
		lc_cnt = 0
		
		If IsNull(lc_amt )       Then lc_amt = 0
		If IsNull(lc_basic_fee ) Then lc_basic_fee = 0
		If IsNull(lc_basic_rate) Then lc_basic_rate = 0
		
		
		If IsNull(ls_contno_fr) Then ls_contno_fr = ''
		If IsNull(ls_contno_to) Then ls_contno_to = ''
		
		If ls_contno_fr = '' Or ls_contno_to = '' Then
			f_msg_info_app(9000, is_caller, "관리번호를 입력하세요.")
		End If
		
		//발행 상태 가져오기
	   ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result[])
		If li_return <= 0 Then Return
		ls_status_1 = ls_result[1]			//발행 1
		ls_status_2 = ls_result[2]			//판매 2
		
		//개통(신규판매)
		ls_refill_type = fs_get_control('P0', 'P106', ls_ref_desc) 	
		
		//본사prefixno
		ls_mainoffice = fs_get_control('A1', 'C101', ls_ref_desc)
		
		//충전장소 가져오기... p0, p116  3번쨰 
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P116', ls_ref_desc)
		If ls_tmp = "" Then Return
		fi_cut_string(ls_tmp, ";", ls_refill_place[])		
		
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
			
		
		//해당 조건에 해당하는 pin 찾기
		DECLARE out_pin DYNAMIC CURSOR FOR SQLSA;

		ls_sql += 	"Select pid, contno From p_cardmst where sale_flag <> '0' And " + &
		         	"status = '" + ls_status_1 + "' "//And partner_prefix = '" + ls_mainoffice + "' "
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
			
			//basic fee calc 2005.03.29 ===================================START
			lc_basic_minus_balance = lc_amt - (lc_amt * lc_basic_rate/100)
			lc_basic_minus_balance = lc_basic_minus_balance - lc_basic_fee
   		//basic fee calc 2005.03.29 ===================================END
         lc_b_rate = lc_amt * lc_basic_rate/100
			lc_basic  = lc_b_rate + lc_basic_fee
			
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
				balance = :lc_basic_minus_balance,  //basic fee 적용 2005.03.29
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
			( refillseq, pid, contno, refilldt, refill_type, refill_amt, refill_place 
			, sale_amt , remark, eday,pricemodel, priceplan, partner_prefix, crtdt, crt_user, basicamt)
			Values 
			( SEQ_REFILLLOG.Nextval, :ls_pid, :ls_contno, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_refill_type, :lc_amt, :ls_refill_place[3]
			, :lc_sale_amt, :ls_remark, :ll_eday ,:ls_model, :ls_priceplan, :ls_partner_prefix, sysdate, :gs_user_id, :lc_basic);
			
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
			
			lc_basic_minus_balance = 0 //2005.03.29 초기화
			
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

on p0c_dbmgr_1.create
call super::create
end on

on p0c_dbmgr_1.destroy
call super::destroy
end on

