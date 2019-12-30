$PBExportHeader$p0c_dbmgr5.sru
$PBExportComments$[uhmjj] 선불카드 판매출고 취소
forward
global type p0c_dbmgr5 from u_cust_a_db
end type
end forward

global type p0c_dbmgr5 from u_cust_a_db
end type
global p0c_dbmgr5 p0c_dbmgr5

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String  ls_where, ls_sql
String  ls_ref_desc, ls_temp, ls_result[] 
Integer li_return
String  ls_pid, ls_contno, ls_partner_prefix, ls_priceplan, ls_model
String  ls_status1, ls_status2, ls_flag, ls_refill_type
Dec{2}  lc_amt, lc_refill_amt, lc_refillsum_amt, lc_tot_amt
String  ls_contno_first, ls_contno_last
Long    ll_outseq, ll_eday, ll_cnt
String  ls_mainoffice
Date    ld_sysday
String  ls_sysdate

//system 날짜
Select sysdate Into :ld_sysday From Dual;
ls_sysdate = String(ld_sysday,'yyyymmdd')

//선불카드마스터 사용내역 체크
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P101", ls_ref_desc)
If ls_temp = "" Then Return

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return

//판매상태
ls_status1 = ls_result[1]

//발행상태
ls_status2 = ls_result[2]

//선불카드마스터 재고구분 체크
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P112", ls_ref_desc)
If ls_temp = "" Then Return

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return

//미입고상태
ls_flag = ls_result[3]

//선불카드마스터 재고구분 체크
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P107", ls_ref_desc)
If ls_temp = "" Then Return

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return

//본사
ls_mainoffice = fs_get_control('A1', 'C101', ls_ref_desc)

//판매출고취소
ls_refill_type = ls_result[6]

Choose Case is_caller
	Case "p0w_reg_out_cancel"

		ll_outseq = ic_data[1]
	
		//관리번호to
		If IsNull(ls_status2) Then ls_status2 = ""
		If ls_status2 <> "" Then
			ls_where += " And status = '" + ls_status2 + "' "
		End If
	
		//해당 조건에 해당하는 pin 찾기
		DECLARE out_pin DYNAMIC CURSOR FOR SQLSA;
		ls_sql += 	"Select pid, contno, priceplan, pricemodel, first_refill_amt, first_sale_amt, partner_prefix, (enddt - opendt) eday From p_cardmst Where outseq = '" + String(ll_outseq) + "' "
		If ls_where <> "" Then ls_sql += ls_where
		ls_sql +=" order by contno "
	
		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC out_pin;
	
		Do While(True)
			FETCH out_pin
			INTO :ls_pid, :ls_contno, :ls_priceplan, :ls_model, :lc_refill_amt, :lc_amt, :ls_partner_prefix,:ll_eday;
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : out_pin")
				CLOSE out_pin;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If

//			//유효기간 계산
//			SELECT extdays
//			INTO :ll_eday
//			FROM salepricemodel
//			WHERE pricemodel = :ls_model;
			
			//ll_eday = fl_refill_extdays_anyuser(ls_partner, ls_priceplan, ls_opendt, lc_amt)
						
			//p_cardmst Update
			Update p_cardmst set
				status = :ls_status1,
				refillsum_amt = 0,
				salesum_amt = 0,
				balance = 0,
				first_sale_amt = 0,
				last_refill_amt = 0,
				sale_flag = :ls_flag,
				partner_prefix = :ls_mainoffice,
				updtdt = sysdate,
				updt_user = :gs_user_id,
				pgm_id = :gs_pgm_id[1]
			Where pid = :ls_pid;
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(P_CARDMST)")
				ROLLBACK;
				Return
			End If
	
			// - sdamt
			lc_amt *= -1
			// - refill
			lc_refill_amt *= -1
			
			//p_refilllog Insert
			Insert Into p_refilllog
			( refillseq, pid, contno, refilldt, refill_type, refill_amt, sale_amt,
			  remark, eday, partner_prefix, crtdt, crt_user, pricemodel, priceplan)
			Values
			( SEQ_REFILLLOG.Nextval, :ls_pid, :ls_contno, to_date(:ls_sysdate,'yyyy-mm-dd'), :ls_refill_type, :lc_refill_amt, :lc_amt,
			  '판매출고취소', :ll_eday, :ls_partner_prefix, sysdate, :gs_user_id, :ls_model, :ls_priceplan);
	
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Insert Error(P_REFILLLOG)")
				ROLLBACK;
				Return
			End If
			
			//count
			ll_cnt += 1 
			
			//초기관리번호
			If ll_cnt = 1 Then
				ls_contno_first = ls_contno
				ls_contno_last = ls_contno
			Else
				ls_contno_last = ls_contno
			End If
	
		Loop			 
CLOSE out_pin;

//카드금액의 합계
lc_tot_amt = ll_cnt * lc_amt
lc_refillsum_amt = ll_cnt * lc_refill_amt

	
	//출고이력
	If ll_cnt > 0 Then
		//수량 마이너스 처리
		Insert Into p_outlog
			(outseq, outdt, pricemodel, partner_prefix, out_qty, sdamt, sale_amt, 
			 contno_fr, contno_to, remark, totamt, crtdt, crt_user)
		Values
			(SEQ_OUTSEQ.Nextval, to_date(:ls_sysdate,'yyyy-mm-dd'), :ls_model, :ls_partner_prefix, :ll_cnt * (-1), :lc_amt, :lc_tot_amt,
			 :ls_contno_first, :ls_contno_last, '판매출고취소', :lc_refillsum_amt, sysdate, :gs_user_id);
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "Insert Error(P_OUTLOG)")
				ROLLBACK;
				Return
			End If 
	End If

	COMMIT;	 
	
End Choose

//ii_rc = 0

end subroutine

on p0c_dbmgr5.create
call super::create
end on

on p0c_dbmgr5.destroy
call super::destroy
end on

