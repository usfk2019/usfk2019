$PBExportHeader$p0c_dbmgr4.sru
$PBExportComments$[chooys]
forward
global type p0c_dbmgr4 from u_cust_a_db
end type
end forward

global type p0c_dbmgr4 from u_cust_a_db
end type
global p0c_dbmgr4 p0c_dbmgr4

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_01 ();Dec ldc_issueseq
String ls_issuestat
String ls_card_maker
String ls_orderdt
String ls_indt
String ls_sale_flag
String ls_remark

//iu_db.ic_data[1] = ldc_issueseq		//발행Seq.
//iu_db.is_data[1] = ls_issuestat		//발행상태
//iu_db.is_data[2] = ls_card_maker		//카드제조사
//iu_db.is_data[3] = ls_orderdt			//주문일자
//iu_db.is_data[4] = ls_indt				//입고일자
//iu_db.is_data[5] = ls_sale_flag		//재고상태
//iu_db.is_data[6] = ls_remark			//비고

ldc_issueseq = ic_data[1]
ls_issuestat = is_data[1]
ls_card_maker = is_data[2]
ls_orderdt = is_data[3]
ls_indt = is_data[4]
ls_sale_flag = is_data[5]
ls_remark = is_data[6]


//P_CARDMST Update
UPDATE p_cardmst
SET sale_flag = :ls_sale_flag,
card_marker = :ls_card_maker,
orderdt = to_date(:ls_orderdt,'YYYYMMDD'),
indt = to_date(:ls_indt,'YYYYMMDD')
WHERE issueseq = :ldc_issueseq;

IF SQLCA.sqlcode < 0 THEN
	RollBack;
	MessageBox("Error","UPDATE p_cardmst")
	ii_rc = -1
	RETURN
END IF



//P_IOHISTORY Insert
INSERT INTO p_iohistory
(ioseq,issueseq,issuestat,workdt,card_marker,orderdt,indt,sale_flag,remark,crt_user)
VALUES(seq_ioseq.nextval,
:ldc_issueseq,
:ls_issuestat,
sysdate,
:ls_card_maker,
to_date(:ls_orderdt,'YYYY-MM-DD'),
to_date(:ls_indt,'YYYY-MM-DD'),
:ls_sale_flag,
:ls_remark,
:gs_user_id
);

IF SQLCA.sqlcode < 0 THEN
	RollBack;
	MessageBox("Error","INSERT p_iohistory")
	ii_rc = -1
	RETURN
END IF
 
Commit; 

ii_rc = 0
end subroutine

public subroutine uf_prc_db ();String ls_model, ls_contno_fr, ls_contno_to, ls_lotno, ls_status_1, ls_status_2
String ls_opendt, ls_remark, ls_priceplan, ls_enddt, ls_contno_first, ls_contno_last, ls_refill_type
String ls_ref_desc, ls_tmp, ls_result[], ls_sql, ls_where, ls_pid
String ls_partner_prefix, ls_partner, ls_contno, ls_eday, ls_mainoffice
String ls_wantedno, ls_issuedt, ls_confirm, ls_stock
Dec{2} lc_price, lc_quantity, lc_sale_amt, lc_tot_amt, lc_tot_sale_amt
Dec lc_cnt, lc_outseq
Dec lc_tot_sale, lc_tot_price
Integer li_return
Integer i
Integer li_tmp
Dec lc_issueseq
String ls_desc
String ls_tmparr[]
String ls_issuestat[], ls_issuestat1
String ls_sale_flag[], ls_sale_flag1
String ls_indt, ls_orderdt, ls_wkflag2

String ls_contno_prefix
Dec lc_last_contno
Dec lc_now_contno
Int li_cardno_cipher

ii_rc = -1


//공통코드 시작
		 lc_price = ic_data[1]			//카드금액
		 lc_sale_amt = ic_data[2]	   //판매금액  
		 lc_quantity = ic_data[3]		//판매수량
		 ls_model = is_data[1]			//모델명
		 ls_contno_prefix = is_data[2]			//관리번호Prefix
		 ls_wantedno = is_data[3]		//희망번호
		 ls_partner = is_data[4]			//대리점
		 ls_priceplan = is_data[5]		//가격정책
		 ls_lotno = is_data[6]			//LOT NO
		 ls_enddt = is_data[7]		   //유효기간
		 ls_opendt = is_data[8]			//개통일자
		 ls_issuedt = is_data[9]			//발행일자
		 ls_remark = is_data[10]			//비고
		 ls_confirm = is_data[11]		//판매출고확정여부
		 ls_stock = is_data[12]			//재고확정여부

		 ls_wkflag2 = is_data[14]       //멘트언어

		
		IF ls_partner = "" OR IsNull(ls_partner) THEN
			//본사(A1:C102)
			ls_partner = fs_get_control("A1","C102",ls_desc)
		END IF

		// 대리점 prefixno
		Select prefixno
		Into :ls_partner_prefix
		From   partnermst
		Where partner = :ls_partner;
		
		//발행 상태 가져오기
	   ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result[])
		If li_return <= 0 Then Return
		ls_status_1 = ls_result[1]			//발행
		ls_status_2 = ls_result[2]			//판매
		
		//재고상태
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P112', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_sale_flag[])
		If li_return <= 0 Then Return
		//ls_sale_flag[1]			//판매
		//ls_sale_flag[2]			//재고
		//ls_sale_flag[3]			//미입고
		//ls_sale_flag[4]			//반품
		
		//선불카드발행Log
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P113', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_issuestat[])
		If li_return <= 0 Then Return
		//ls_issuestat[1]			//미입고
		//ls_issuestat[2]			//재고확정
		
		//카드번호 자리수
		ls_tmp = fs_get_control('P0', 'P102', ls_ref_desc)
		If ls_tmp = "" Then Return
		li_cardno_cipher = Integer(ls_tmp)
		
		IF LenA(ls_wantedno) = 2 THEN
			li_cardno_cipher = li_cardno_cipher -2
		ELSEIF LenA(ls_wantedno) = 1 THEN
			li_cardno_cipher = li_cardno_cipher -1
		ELSE
			ls_wantedno = ""
		END IF
		
		//마지막 관리번호
		ls_tmp = fs_get_control('P0', 'P103', ls_ref_desc)
		If ls_tmp = "" Then Return
		lc_last_contno = Dec(ls_tmp)
	
		IF lc_last_contno + lc_quantity > 99999999 THEN
			f_msg_info_app(9000, is_caller, "관리번호를 더 이상 생성 할 수 없습니다." +&
				 "~r~n" + "관리번호 한도 초과 입니다.(8자리)" +&
			 "~r~n" + "관리자에게 문의 하세요.")
			 RETURN
		END IF
		
		//관리번호
		Integer ll_contno_len
		ll_contno_len = 10 - LenA(ls_contno_prefix)

		lc_now_contno = lc_last_contno
		ls_contno_first = ls_contno_prefix + fs_fill_zeroes(String(lc_last_contno+1),-(ll_contno_len)) //첫 관리번호

		//Issueseq 구하기
		SELECT seq_issuelog.nextval
		INTO :lc_issueseq
		FROM dual;
//공통코드 끝


Choose Case is_caller
	//1.판매출고확정 = 'N' - 카드발행만
	Case "p0w_prc_cardmst%sale_no"

			
		FOR i=1 To lc_quantity
			lc_now_contno = lc_now_contno +1 //마지막관리번호
			ls_contno = ls_contno_prefix + fs_fill_zeroes(String(lc_now_contno),-(ll_contno_len)) //새 관리번호
			
			//PID 생성
			DO
				ls_pid = ls_wantedno + fdc_get_random(li_cardno_cipher)

				SELECT COUNT(*) 
				INTO :li_tmp
				FROM p_cardmst
				WHERE pid = :ls_pid;
				
			LOOP WHILE(li_tmp>0)
			
			//p_cardmst에 Insert(선불카드마스터)
			IF ls_stock = "N" THEN //재고확정 안됨.
				ls_sale_flag1 = ls_sale_flag[3]
				ls_issuestat1 = ls_issuestat[1]
				SetNull(ls_indt)
				SetNull(ls_orderdt)
			ELSE
				ls_sale_flag1 = ls_sale_flag[2]
				ls_issuestat1 = ls_issuestat[2]
				ls_indt = ls_issuedt
				ls_orderdt = ls_issuedt
			END IF
			
				INSERT INTO p_cardmst
				(pid,contno,status,issueseq,issuedt,issue_user,priceplan,pricemodel,lotno,
				 refillsum_amt,usedsum_amt,salesum_amt,balance,partner_prefix,
				 first_refill_amt,first_sale_amt,last_refill_amt,sale_flag,remark,
				 indt,orderdt, wkflag2,
				 crtdt,crt_user,updtdt,updt_user,pgm_id)
				VALUES
				(:ls_pid,:ls_contno,:ls_status_1,:lc_issueseq,to_date(:ls_issuedt, 'yyyy-mm-dd'),:gs_user_id,:ls_priceplan,:ls_model,:ls_lotno,
				 0,0,0,0,:ls_partner_prefix,
				 :lc_price,0,0,:ls_sale_flag1,:ls_remark,
				to_date(:ls_indt, 'yyyy-mm-dd'),to_date(:ls_orderdt, 'yyyy-mm-dd'),:ls_wkflag2,
				 sysdate,:gs_user_id,sysdate,:gs_user_id,:gs_pgm_id[gi_open_win_no]);
			
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(P_CARDMST)")
				Return
			End If
			
		Next
		
		ls_contno_last = ls_contno  //마지막 관리번호
		
		//p_issuelog Insert(발행이력)			
			Insert Into p_issuelog
			( issueseq, issuestat, issuedt, pricemodel, lotno,
			issue_qty, card_amt, contno_fr, contno_to, remark,
			indt, orderdt,
			crtdt, crt_user, updtdt, updt_user,pgm_id)
			Values 
			( :lc_issueseq, :ls_issuestat1, to_date(:ls_issuedt, 'yyyy-mm-dd'),:ls_model, :ls_lotno,
			:lc_quantity, :lc_price, :ls_contno_first , :ls_contno_last, :ls_remark, 
			to_date(:ls_indt, 'yyyy-mm-dd'),to_date(:ls_orderdt, 'yyyy-mm-dd'),
			sysdate, :gs_user_id, sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no]);

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(p_issuelog)")
			Return
		End If 
		
		//마지막관리번호 업데이트
		fi_set_control('P0', 'P103', String(lc_now_contno))

		
		ic_data[1] = lc_quantity
		ic_data[2] = lc_sale_amt*lc_quantity
		is_data[1] = ls_contno_first
		is_data[2] = ls_contno_last
		
		
	//2.판매출고확정 = 'Y' - 카드발행&충전
	Case "p0w_prc_cardmst%sale_yes"

		//개통(신규판매)
		ls_refill_type = fs_get_control('P0', 'P106', ls_ref_desc) 	
		
		//연장일수
		ls_eday = is_data[13]
		
		//본사prefixno
		ls_mainoffice = fs_get_control('A1', 'C101', ls_ref_desc)
		
		// 대리점 prefixno
		Select prefixno
		Into :ls_partner_prefix
		From   partnermst
		Where partner = :ls_partner;
		
		
		//Outseq 구하기
		SELECT seq_outseq.nextval
		INTO :lc_outseq
		FROM dual;
	
		FOR i=1 To lc_quantity
			lc_now_contno = lc_now_contno +1 //마지막관리번호
			ls_contno = ls_contno_prefix + fs_fill_zeroes(String(lc_now_contno),-(ll_contno_len)) //새 관리번호
			
			//PID 생성
			DO
				ls_pid = ls_wantedno + fdc_get_random(li_cardno_cipher)

				SELECT COUNT(*) 
				INTO :li_tmp
				FROM p_cardmst
				WHERE pid = :ls_pid;
				
			LOOP WHILE(li_tmp>0)
			
			//p_cardmst에 Insert(선불카드마스터)
			INSERT INTO p_cardmst
			(pid,contno,status,issueseq,issuedt,issue_user,priceplan,pricemodel,lotno,
			 outseq,refillsum_amt,usedsum_amt,salesum_amt,balance,partner_prefix,
			 first_refill_amt,first_sale_amt,last_refill_amt,sale_flag,remark,
			 opendt, enddt,last_refilldt,
			 indt,orderdt,wkflag2,
			 crtdt,crt_user,updtdt,updt_user,pgm_id)
			VALUES
			(:ls_pid,:ls_contno,:ls_status_2,:lc_issueseq,to_date(:ls_issuedt, 'yyyy-mm-dd'),:gs_user_id,:ls_priceplan,:ls_model,:ls_lotno,
			 :lc_outseq,:lc_price,0,:lc_sale_amt,:lc_price,:ls_partner_prefix,
			 :lc_price,:lc_sale_amt,:lc_price,:ls_sale_flag[1],:ls_remark,
			 to_date(:ls_opendt, 'yyyy-mm-dd'),to_date(:ls_enddt, 'yyyy-mm-dd'),to_date(:ls_opendt, 'yyyy-mm-dd'),
			 to_date(:ls_issuedt, 'yyyy-mm-dd'),to_date(:ls_issuedt, 'yyyy-mm-dd'),:ls_wkflag2,
			 sysdate,:gs_user_id,sysdate,:gs_user_id,:gs_pgm_id[gi_open_win_no]);
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(P_CARDMST)")
				Return
			End If
			
			//p_rflog Insert 충전이력
			Insert Into p_refilllog
			( refillseq, pid, contno, refilldt, refill_type, refill_amt, 
			  sale_amt, remark, eday, partner_prefix, crtdt, crt_user, pricemodel, priceplan)
			Values 
			( seq_REFILLLOG.Nextval, :ls_pid, :ls_contno, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_refill_type, :lc_price,
			  :lc_sale_amt, :ls_remark, to_number(:ls_eday) , :ls_partner_prefix, sysdate, :gs_user_id,
			  :ls_model, :ls_priceplan);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Insert Error(P_Refilllog)")
				Return
			End If
			
		Next
		
		ls_contno_last = ls_contno  //마지막 관리번호
		
				
		//p_issuelog Insert(발행이력)
		Insert Into p_issuelog
		( issueseq, issuestat, issuedt, enddt, pricemodel, lotno,
		issue_qty, card_amt, contno_fr, contno_to, remark,
		indt,orderdt,
		crtdt, crt_user, updtdt, updt_user, pgm_id)
		Values 
		(:lc_issueseq, :ls_issuestat[2],to_date(:ls_issuedt, 'yyyy-mm-dd'), to_date(:ls_enddt, 'yyyy-mm-dd'),:ls_model, :ls_lotno,
		:lc_quantity, :lc_price, :ls_contno_first , :ls_contno_last, :ls_remark, 
		to_date(:ls_issuedt, 'yyyy-mm-dd'),to_date(:ls_issuedt, 'yyyy-mm-dd'),
		sysdate, :gs_user_id, sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no]);
		

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(P_ISSUELOG)")
			Return
		End If 
		
		lc_tot_sale_amt = lc_sale_amt * lc_quantity //판매금액 합계
		lc_tot_amt = lc_price * lc_quantity	//카드금액 합계
		
		//출고이력
		Insert Into p_outlog
		(outseq, outdt, pricemodel, partner_prefix, out_qty, sdamt,
		sale_amt, contno_fr, contno_to, remark, totamt, crtdt, crt_user)
		Values
		(:lc_outseq, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_model, :ls_partner_prefix, :lc_quantity, :lc_sale_amt,
		:lc_tot_sale_amt, :ls_contno_first, :ls_contno_last, :ls_remark, :lc_tot_amt, sysdate,  :gs_user_id);
			 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(P_OUTLOG)")
			Return
		End If
		
		//마지막관리번호 업데이트
		fi_set_control('P0', 'P103', String(lc_now_contno))
		
		ic_data[1] = lc_quantity
		ic_data[2] = lc_sale_amt*lc_quantity
		is_data[1] = ls_contno_first
		is_data[2] = ls_contno_last		
		
		
End Choose
ii_rc = 0
end subroutine

public subroutine uf_prc_db_02 ();String ls_model, ls_contno_fr, ls_contno_to, ls_lotno, ls_status_1, ls_status_2
String ls_opendt, ls_remark, ls_priceplan, ls_enddt, ls_contno_first, ls_contno_last, ls_refill_type
String ls_ref_desc, ls_tmp, ls_result[], ls_sql, ls_where, ls_pid
String ls_partner_prefix, ls_partner, ls_contno, ls_eday, ls_mainoffice
String ls_wantedno, ls_issuedt, ls_confirm, ls_stock
Dec{2} lc_price, lc_quantity, lc_sale_amt, lc_tot_amt, lc_tot_sale_amt
Dec lc_cnt, lc_outseq
Dec lc_tot_sale, lc_tot_price
Integer li_return
Integer i
Integer li_tmp
Dec lc_issueseq
String ls_desc
String ls_tmparr[]
String ls_issuestat[], ls_issuestat1
String ls_sale_flag[], ls_sale_flag1
String ls_indt, ls_orderdt, ls_wkflag2,	ls_pid_len

String ls_contno_prefix
Dec lc_last_contno
Dec lc_now_contno
Int li_cardno_cipher

ii_rc = -1


//공통코드 시작
		 lc_price = ic_data[1]			//카드금액
		 lc_sale_amt = ic_data[2]	   //판매금액  
		 lc_quantity = ic_data[3]		//판매수량
		 ls_model = is_data[1]			//모델명
		 ls_contno_prefix = is_data[2]			//관리번호Prefix
		 ls_wantedno = is_data[3]		//희망번호
		 ls_partner = is_data[4]			//대리점
		 ls_priceplan = is_data[5]		//가격정책
		 ls_lotno = is_data[6]			//LOT NO
		 ls_enddt = is_data[7]		   //유효기간
		 ls_opendt = is_data[8]			//개통일자
		 ls_issuedt = is_data[9]			//발행일자
		 ls_remark = is_data[10]			//비고
		 ls_confirm = is_data[11]		//판매출고확정여부
		 ls_stock = is_data[12]			//재고확정여부

		 ls_wkflag2 = is_data[14]       //멘트언어
		 ls_pid_len = is_data[15]       //길이
		
		IF ls_partner = "" OR IsNull(ls_partner) THEN
			//본사(A1:C102)
			ls_partner = fs_get_control("A1","C102",ls_desc)
		END IF

		// 대리점 prefixno
		Select prefixno
		Into :ls_partner_prefix
		From   partnermst
		Where partner = :ls_partner;
		
		//발행 상태 가져오기
	   ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result[])
		If li_return <= 0 Then Return
		ls_status_1 = ls_result[1]			//발행
		ls_status_2 = ls_result[2]			//판매
		
		//재고상태
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P112', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_sale_flag[])
		If li_return <= 0 Then Return
		//ls_sale_flag[1]			//판매
		//ls_sale_flag[2]			//재고
		//ls_sale_flag[3]			//미입고
		//ls_sale_flag[4]			//반품
		
		//선불카드발행Log
		ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P113', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_issuestat[])
		If li_return <= 0 Then Return
		//ls_issuestat[1]			//미입고
		//ls_issuestat[2]			//재고확정
		
		//카드번호 자리수
//		ls_tmp = fs_get_control('P0', 'P102', ls_ref_desc)
//		If ls_tmp = "" Then Return
		li_cardno_cipher = Integer(ls_pid_len)
		
		IF LenA(ls_wantedno) = 2 THEN
			li_cardno_cipher = li_cardno_cipher -2
		ELSEIF LenA(ls_wantedno) = 1 THEN
			li_cardno_cipher = li_cardno_cipher -1
		ELSE
			ls_wantedno = ""
		END IF
		
		//마지막 관리번호
		ls_tmp = fs_get_control('P0', 'P103', ls_ref_desc)
		If ls_tmp = "" Then Return
		lc_last_contno = Dec(ls_tmp)
	
		IF lc_last_contno + lc_quantity > 99999999 THEN
			f_msg_info_app(9000, is_caller, "관리번호를 더 이상 생성 할 수 없습니다." +&
				 "~r~n" + "관리번호 한도 초과 입니다.(8자리)" +&
			 "~r~n" + "관리자에게 문의 하세요.")
			 RETURN
		END IF
		
		//관리번호
		Integer ll_contno_len
		ll_contno_len = 10 - LenA(ls_contno_prefix)

		lc_now_contno = lc_last_contno
		ls_contno_first = ls_contno_prefix + fs_fill_zeroes(String(lc_last_contno+1),-(ll_contno_len)) //첫 관리번호

		//Issueseq 구하기
		SELECT seq_issuelog.nextval
		INTO :lc_issueseq
		FROM dual;
//공통코드 끝


Choose Case is_caller
	//1.판매출고확정 = 'N' - 카드발행만
	Case "p0w_prc_cardmst_cpass%sale_no"

			
		FOR i=1 To lc_quantity
			lc_now_contno = lc_now_contno +1 //마지막관리번호
			ls_contno = ls_contno_prefix + fs_fill_zeroes(String(lc_now_contno),-(ll_contno_len)) //새 관리번호
			
			//PID 생성
			DO
				ls_pid = ls_wantedno + fdc_get_random(li_cardno_cipher)

				SELECT COUNT(*) 
				INTO :li_tmp
				FROM p_cardmst
				WHERE pid = :ls_pid;
				
			LOOP WHILE(li_tmp>0)
			
			//p_cardmst에 Insert(선불카드마스터)
			IF ls_stock = "N" THEN //재고확정 안됨.
				ls_sale_flag1 = ls_sale_flag[3]
				ls_issuestat1 = ls_issuestat[1]
				SetNull(ls_indt)
				SetNull(ls_orderdt)
			ELSE
				ls_sale_flag1 = ls_sale_flag[2]
				ls_issuestat1 = ls_issuestat[2]
				ls_indt = ls_issuedt
				ls_orderdt = ls_issuedt
			END IF
			
				INSERT INTO p_cardmst
				(pid,contno,status,issueseq,issuedt,issue_user,priceplan,pricemodel,lotno,
				 refillsum_amt,usedsum_amt,salesum_amt,balance,partner_prefix,
				 first_refill_amt,first_sale_amt,last_refill_amt,sale_flag,remark,
				 indt,orderdt, wkflag2,
				 crtdt,crt_user,updtdt,updt_user,pgm_id)
				VALUES
				(:ls_pid,:ls_contno,:ls_status_1,:lc_issueseq,to_date(:ls_issuedt, 'yyyy-mm-dd'),:gs_user_id,:ls_priceplan,:ls_model,:ls_lotno,
				 0,0,0,0,:ls_partner_prefix,
				 :lc_price,0,0,:ls_sale_flag1,:ls_remark,
				to_date(:ls_indt, 'yyyy-mm-dd'),to_date(:ls_orderdt, 'yyyy-mm-dd'),:ls_wkflag2,
				 sysdate,:gs_user_id,sysdate,:gs_user_id,:gs_pgm_id[gi_open_win_no]);
			
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(P_CARDMST)")
				Return
			End If
			
		Next
		
		ls_contno_last = ls_contno  //마지막 관리번호
		
		//p_issuelog Insert(발행이력)			
			Insert Into p_issuelog
			( issueseq, issuestat, issuedt, pricemodel, lotno,
			issue_qty, card_amt, contno_fr, contno_to, remark,
			indt, orderdt,
			crtdt, crt_user, updtdt, updt_user,pgm_id)
			Values 
			( :lc_issueseq, :ls_issuestat1, to_date(:ls_issuedt, 'yyyy-mm-dd'),:ls_model, :ls_lotno,
			:lc_quantity, :lc_price, :ls_contno_first , :ls_contno_last, :ls_remark, 
			to_date(:ls_indt, 'yyyy-mm-dd'),to_date(:ls_orderdt, 'yyyy-mm-dd'),
			sysdate, :gs_user_id, sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no]);

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(p_issuelog)")
			Return
		End If 
		
		//마지막관리번호 업데이트
		fi_set_control('P0', 'P103', String(lc_now_contno))

		
		ic_data[1] = lc_quantity
		ic_data[2] = lc_sale_amt*lc_quantity
		is_data[1] = ls_contno_first
		is_data[2] = ls_contno_last
		
		
	//2.판매출고확정 = 'Y' - 카드발행&충전
	Case "p0w_prc_cardmst_cpass%sale_yes"

		//개통(신규판매)
		ls_refill_type = fs_get_control('P0', 'P106', ls_ref_desc) 	
		
		//연장일수
		ls_eday = is_data[13]
		
		//본사prefixno
		ls_mainoffice = fs_get_control('A1', 'C101', ls_ref_desc)
		
		// 대리점 prefixno
		Select prefixno
		Into :ls_partner_prefix
		From   partnermst
		Where partner = :ls_partner;
		
		
		//Outseq 구하기
		SELECT seq_outseq.nextval
		INTO :lc_outseq
		FROM dual;

		FOR i=1 To lc_quantity
			lc_now_contno = lc_now_contno +1 //마지막관리번호
			ls_contno = ls_contno_prefix + fs_fill_zeroes(String(lc_now_contno),-(ll_contno_len)) //새 관리번호
			
			//PID 생성
			DO
				ls_pid = ls_wantedno + fdc_get_random(li_cardno_cipher)

				SELECT COUNT(*) 
				INTO :li_tmp
				FROM p_cardmst
				WHERE pid = :ls_pid;
				
			LOOP WHILE(li_tmp>0)
			
			//p_cardmst에 Insert(선불카드마스터)
			INSERT INTO p_cardmst
			(pid,contno,status,issueseq,issuedt,issue_user,priceplan,pricemodel,lotno,
			 outseq,refillsum_amt,usedsum_amt,salesum_amt,balance,partner_prefix,
			 first_refill_amt,first_sale_amt,last_refill_amt,sale_flag,remark,
			 opendt, enddt,last_refilldt,
			 indt,orderdt,wkflag2,
			 crtdt,crt_user,updtdt,updt_user,pgm_id)
			VALUES
			(:ls_pid,:ls_contno,:ls_status_2,:lc_issueseq,to_date(:ls_issuedt, 'yyyy-mm-dd'),:gs_user_id,:ls_priceplan,:ls_model,:ls_lotno,
			 :lc_outseq,:lc_price,0,:lc_sale_amt,:lc_price,:ls_partner_prefix,
			 :lc_price,:lc_sale_amt,:lc_price,:ls_sale_flag[1],:ls_remark,
			 to_date(:ls_opendt, 'yyyy-mm-dd'),to_date(:ls_enddt, 'yyyy-mm-dd'),to_date(:ls_opendt, 'yyyy-mm-dd'),
			 to_date(:ls_issuedt, 'yyyy-mm-dd'),to_date(:ls_issuedt, 'yyyy-mm-dd'),:ls_wkflag2,
			 sysdate,:gs_user_id,sysdate,:gs_user_id,:gs_pgm_id[gi_open_win_no]);
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " INSERT Error(P_CARDMST)")
				Return
			End If
			
			//p_rflog Insert 충전이력
			Insert Into p_refilllog
			( refillseq, pid, contno, refilldt, refill_type, refill_amt, 
			  sale_amt, remark, eday, partner_prefix, crtdt, crt_user, pricemodel, priceplan)
			Values 
			( seq_REFILLLOG.Nextval, :ls_pid, :ls_contno, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_refill_type, :lc_price,
			  :lc_sale_amt, :ls_remark, to_number(:ls_eday) , :ls_partner_prefix, sysdate, :gs_user_id,
			  :ls_model, :ls_priceplan);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Insert Error(P_Refilllog)")
				Return
			End If
			
		Next
		
		ls_contno_last = ls_contno  //마지막 관리번호
		
				
		//p_issuelog Insert(발행이력)
		Insert Into p_issuelog
		( issueseq, issuestat, issuedt, enddt, pricemodel, lotno,
		issue_qty, card_amt, contno_fr, contno_to, remark,
		indt,orderdt,
		crtdt, crt_user, updtdt, updt_user, pgm_id)
		Values 
		(:lc_issueseq, :ls_issuestat[2],to_date(:ls_issuedt, 'yyyy-mm-dd'), to_date(:ls_enddt, 'yyyy-mm-dd'),:ls_model, :ls_lotno,
		:lc_quantity, :lc_price, :ls_contno_first , :ls_contno_last, :ls_remark, 
		to_date(:ls_issuedt, 'yyyy-mm-dd'),to_date(:ls_issuedt, 'yyyy-mm-dd'),
		sysdate, :gs_user_id, sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no]);
		

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(P_ISSUELOG)")
			Return
		End If 
		
		lc_tot_sale = lc_sale_amt * lc_quantity //판매금액 합계
		lc_tot_price = lc_price * lc_quantity	//카드금액 합계
		
		//출고이력
		Insert Into p_outlog
		(outseq, outdt, pricemodel, partner_prefix, out_qty, sdamt,
		sale_amt, contno_fr, contno_to, remark, totamt, crtdt, crt_user)
		Values
		(:lc_outseq, to_date(:ls_opendt, 'yyyy-mm-dd'), :ls_model, :ls_partner_prefix, :lc_quantity, :lc_sale_amt,
		:lc_tot_sale, :ls_contno_first, :ls_contno_last, :ls_remark, :lc_tot_sale, sysdate,  :gs_user_id);
			 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(P_OUTLOG)")
			Return
		End If
		
		//마지막관리번호 업데이트
		fi_set_control('P0', 'P103', String(lc_now_contno))
		
		ic_data[1] = lc_quantity
		ic_data[2] = lc_sale_amt*lc_quantity
		is_data[1] = ls_contno_first
		is_data[2] = ls_contno_last		
		
		
End Choose
ii_rc = 0
end subroutine

on p0c_dbmgr4.create
call super::create
end on

on p0c_dbmgr4.destroy
call super::destroy
end on

