$PBExportHeader$b5w_reg_mtr_req_contract.srw
$PBExportComments$거래수동거래등록
forward
global type b5w_reg_mtr_req_contract from w_a_reg_m_sql
end type
end forward

global type b5w_reg_mtr_req_contract from w_a_reg_m_sql
integer width = 3205
integer height = 1992
end type
global b5w_reg_mtr_req_contract b5w_reg_mtr_req_contract

type variables
Date id_reqdt, id_reqdt_next
String is_chargedt, is_cus_gu, is_format
end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
public function integer wfi_get_reqnum (ref string as_reqnum)
public function integer wfi_set_trvalue (string as_payid)
public function integer wfi_get_customerid (string as_customerid)
public function integer wfi_save_sql ()
public function integer wfi_chk_data ()
end prototypes

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay Id(wfi_get_payid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0
end function

public function integer wfi_get_reqnum (ref string as_reqnum);//// get reqnum
//SELECT lpad(to_char(to_number(ref_content) + 1), 7, '0') INTO :as_reqnum
//FROM sysctl1t WHERE module = 'B5' AND ref_no = 'R101';
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(Title, "Invoice No(wfi_get_reqnum)")
//	Return -1
//ElseIf SQLCA.SQLCode = 100 Then
//	MessageBox(Title, "마지막 청구번호가 없습니다.(B5:R101)")
//	Return -1
//End If
//
Return 0 
//
end function

public function integer wfi_set_trvalue (string as_payid);String ls_billcycle, ls_trdt, ls_reqnum,ls_reqdt,ls_payid
Date ldate_trdt
Dec{2} lc0_pre_balance, lc0_cur_balance

ls_reqdt = string(id_reqdt,'yyyymmdd')

// 해당 청구년월의 미납액
//SELECT sum(tramt)
// 2019.04.11 VAT  Summary 추가 modified by Han
SELECT sum(tramt) + sum(nvl(taxamt,0))
 INTO :lc0_pre_balance
 FROM reqdtl 
WHERE to_char(trdt,'yyyymmdd') < :ls_reqdt
AND payid= :as_payid;

//WHERE trdt = :ls_reqdt
//AND  payid = :ls_payid 
//AND (mark is null or mark <> 'D')
//AND  trcod in (SELECT trcod FROM trcode WHERE extraflag = 'N') ;

If SQLCA.SQLCODE < 0 Then
	f_msg_sql_err(Title, "Previous Balance(wfi_set_trvalus)")
	Return -2
End If	

// 해당 청구년월의 미납액
//SELECT sum(tramt)
// 2019.04.11 VAT  Summary 추가 modified by Han
SELECT sum(tramt) + sum(nvl(taxamt,0))
 INTO :lc0_cur_balance
 FROM reqdtl 
WHERE to_char(trdt,'yyyymmdd') = :ls_reqdt
AND  payid = :as_payid ;
//AND (mark is null or mark <> 'D')
//AND  trcod in (SELECT trcod FROM trcode WHERE extraflag = 'N') ;
If SQLCA.SQLCODE < 0 Then
	f_msg_sql_err(Title, "Current Balance(wfi_set_trvalus)")
	Return -2
End If	

//dw_cond.Object.trdt[1] = ldate_trdt 
//dw_cond.Object.reqnum [1] = ls_reqnum  
dw_cond.Object.cur_balance[1] = lc0_cur_balance 
dw_cond.Object.pre_balance[1] = lc0_pre_balance 

Return 0
end function

public function integer wfi_get_customerid (string as_customerid);String ls_customerid, ls_customernm, ls_payid

ls_customerid = as_customerid
ls_payid = dw_cond.Object.payid[1]

If IsNull(ls_customerid) Then ls_customerid = " "
If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_customernm
  From Customerm
 Where customerid = :ls_customerid
   and payid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Customer ID(wfi_get_customerid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "해당납입번호에 속한 고객번호가 없습니다.")
	Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0
end function

public function integer wfi_save_sql ();Int 		li_rc
String 	ls_payid, 	ls_customerid, 	ls_trcod, 		ls_trdt, 	ls_reqnum
String 	ls_remark, 	ls_paydt, 			ls_transdt, 	ls_reqdt, 	ls_chargedt,	ls_svccod
String 	ls_dctype, 	ls_trdt_reqinfo
Dec{2} 	lc0_tramt, 	lc0_cur_balance, 	lc0_pre_balance
Long 		ll_seq, 		ll_cnt
// 2019.04.11 변수 추가(VAT)
Dec{2}   lc0_taxamt


//데이터 저장
ls_payid 		= dw_cond.Object.payid[1]
ls_customerid 	= dw_cond.Object.customerid[1]
ls_trcod 		= dw_cond.Object.trcod[1]
lc0_tramt 		= dw_cond.Object.tramt[1]
// 2019.04.11 VAT Column 추가에 따른 변수 저장 추가 Modified by Han
lc0_taxamt     = dw_cond.Object.taxamt[1]
ls_trdt 			= String(dw_cond.Object.trdt[1], "yyyymmdd") 

//ls_svccod = dw_cond.Object.svccod[1]

ls_transdt 		= String(dw_cond.Object.paydt[1], "yyyymmdd")
ls_remark 		= dw_cond.Object.remark[1]

SELECT to_char(trdt,'yyyymmdd')  INTO :ls_trdt_reqinfo  FROM reqinfo
WHERE chargedt = :is_chargedt
  AND payid 	= :ls_payid;

If SQLCA.SQLCODE < 0 Then
	f_msg_sql_err(Title, "청구월고객정보(wfi_save_sql)")
	Return -1
End If	

If ls_trdt_reqinfo <> ls_trdt Then
	MessageBox(Title, "청구기준일이 청구월고객정보(reqinfo)의 청구기준일과 달라" +&
	   "~r~n~r~n" + "당월 현 청구자료를 생성할수 없습니다.")
	Return -2
End If

// 해당 청구년월의 거래 건수
SELECT count(payid)  INTO :ll_seq  FROM reqdtl 
WHERE to_char(trdt, 'yyyymmdd') 	= :ls_trdt
  AND payid 							= :ls_payid ;

If SQLCA.SQLCODE < 0 Then
	f_msg_sql_err(Title, "Billing Cycle date(wfi_save_sql)")
	Return -1
End If	

If ll_seq = 0 Then
	
	//contractseq 가져 오기
	Select seq_reqnum.nextval	Into :ls_reqnum	From dual;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "SELECT seq_reqnum.nextval")			
		rollback;
		Return -1
	End If	
	
	ll_seq = 1
	
ElseIF ll_seq > 0 Then
	// 청구번호와 SEQ 가져오기
	ll_seq = 0
	SELECT reqnum, max(seq)+1
	 INTO :ls_reqnum, :ll_seq 
	 FROM reqdtl 
	WHERE to_char(trdt,'yyyymmdd') = :ls_trdt
	  AND payid = :ls_payid 
	GROUP BY reqnum
	ORDER BY reqnum;
	
	If SQLCA.SQLCODE < 0 Then
		f_msg_sql_err(Title, "Invoice No/SEQ(wfi_save_sql)")
		Return -1
	End If
End If

SELECT dctype INTO :ls_dctype FROM trcode
WHERE trcod = :ls_trcod;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Transaction dctype(wfi_save_sql)")
	Return -1
End If

If ls_dctype = "C" Then lc0_tramt = lc0_tramt * -1

// 자료 등록
// 2019.04.11 taxamt Insert 추가 Modified by Han
INSERT INTO reqdtl
( reqnum, 		seq, 			payid, 		customerid, 		trdt, 		paydt,
  transdt, 		trcod, 		tramt, 		remark,
  crt_user,		crtdt, 		pgm_id, 		updt_user, 			updtdt,     taxamt)
VALUES
( :ls_reqnum, :ll_seq, 		:ls_payid, 	:ls_customerid, 	to_date(:ls_trdt,'yyyymmdd'), to_date(:ls_transdt,'yyyymmdd'),
  to_date(:ls_transdt,'yyyymmdd'), :ls_trcod, :lc0_tramt, :ls_remark, 
  :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate, :lc0_taxamt);

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "reqdtl insert-청구거래자료추가(wfi_save_sql)")
	Return -1
End If

/*****************************************/
/* ITEMSALE UPDATE, INSERT  - start      */
/*****************************************/
string ls_itemcod, ls_salefromdt,ls_saletodt 
long ll_contractseq
integer li_item_cnt

ls_itemcod = dw_cond.object.itemcod[1]
ll_contractseq = long(dw_cond.object.contractseq[1])

// 해당 청구년월의 거래 건수
SELECT COUNT(*) INTO :li_item_cnt
FROM ITEMSALE
WHERE to_char(invoice_month,'yyyymmdd') = :ls_trdt
  AND customerid  = :ls_customerid
  AND itemcod 	   = :ls_itemcod
  AND contractseq = :ll_contractseq;
			 
If SQLCA.SQLCODE < 0 Then
	f_msg_sql_err(Title, "SELECT ITEMSALE - (wfi_save_sql)")
	Return -1
End If	

//IF li_item_cnt = 1 then  //한건이면 update
//			
//		UPDATE itemsale SET
//				sale_amt = sale_amt - :lc0_tramt
//		WHERE to_char(invoice_month,'yyyymmdd') = :ls_trdt
//		    AND customerid = :ls_customerid
//			 AND itemcod = :ls_itemcod
//			 AND contractseq = :ll_contractseq;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(Title, "itemsale update-청구판매 품목추가(wfi_save_sql)")
//			Return -1
//		End If
//	
//			 
//ELSE   // 0 이거나 한건이상이면 INSERT
	
	select to_char(useddt_fr,'yyyymmdd') ,  to_char(useddt_to,'yyyymmdd') into :ls_salefromdt, :ls_saletodt
	from reqconf
	where chargedt  = :is_chargedt
  		and to_char( reqdt,'yyyymmdd')  = :ls_trdt;
	
	If SQLCA.SQLCODE < 0 Then
		f_msg_sql_err(Title, "SALE_MONTH 검색실패(wfi_save_sql)")
		Return -1
	End If	

// 2019.04.11 taxamt Insert 추가 Modified by Han
	   INSERT INTO ITEMSALE
		(	SEQ, SALE_MONTH, CUSTOMERID, 
			PAYID, CONTRACTSEQ, ITEMCOD, 
			SALEAMT, SALECNT, DCAMT, 
			DCRATE, USAGEPERIOD, TRCOD, 
			SVCCOD, PRICEPLAN, SALE_PARTNER, 
			MAINTAIN_PARTNER, PARTNER, REQNUM, 
			INVOICE_MONTH, CRT_USER, CRTDT, 
			LOCATION, SVCTYPE, 
			SALEFROMDT, SALETODT, BILL_FLAG, TAXAMT	)
		(select  seq_itemsale.nextval, to_date(:ls_salefromdt,'yyyymmdd'), a.customerid,
					a.customerid, a.contractseq, :ls_itemcod,
					:lc0_tramt, 1, 0, 
					0, 0, :ls_trcod,
					a.svccod, a.priceplan, a.sale_partner,
					a.maintain_partner, a.partner, :ls_reqnum,
					to_date(:ls_trdt,'yyyymmdd'), :gs_user_id, sysdate,
					null, (select svctype from svcmst where svccod = a. svccod), 
					:ls_salefromdt, :ls_saletodt, null, :lc0_taxamt
		 from contractmst a
		 where a.contractseq = :ll_contractseq);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "itemsale insert-청구판매 품목추가(wfi_save_sql)")
			Return -1
		End If
	
//END IF
/*****************************************/
/* ITEMSALE UPDATE, INSERT  -  end       */
/*****************************************/

Return 0 
end function

public function integer wfi_chk_data ();String 	ls_payid, 		ls_customerid, ls_trcod, 	ls_itemcod
String 	ls_useryn, 		ls_trdt, 		ls_paydt, 	ls_transdt,	ls_svccod,	ls_userynre
Date 		ld_transdt, 	ld_paydt, 		ld_trdt,		ld_mintrdt,	ld_maxtrdt
Dec{2} 	lc0_tramt
Int 		li_count, li_cnt
long 		ll_contractseq


ls_payid 		= dw_cond.Object.payid[1]
If IsNull(ls_payid) 		Then ls_payid 	= "" 

ls_trcod 		= dw_cond.Object.trcod[1]
If IsNull(ls_trcod) 		Then ls_trcod 	= "" 

//ls_svccod = dw_cond.Object.svccod[1]
//If IsNull(ls_svccod) Then ls_svccod = "" 

lc0_tramt 		= dw_cond.Object.tramt[1]
If IsNull(lc0_tramt) 	Then lc0_tramt = 0 

If ls_payid = "" Then 
	f_msg_usr_err(200, Title, "Payer ID")
	dw_cond.SetColumn("payid")
	Return -2
End If

If ls_trcod = "" Then 
	f_msg_usr_err(200, Title, "Transaction")
	dw_cond.SetColumn("trcod")
	Return -2
End If

If lc0_tramt = 0 Then 
	f_msg_usr_err(200, Title, "거래금액을 다시 입력 하세요.")
	dw_cond.SetColumn("tramt")
	Return -2
End If	

//거래일자 체크
ld_paydt = dw_cond.Object.paydt[1]
// 2005.11.21. khpark modify 다음달 청구주기보다 클 때는 입력가능하게 수정한다.(조건하나생략)
//If (id_reqdt > ld_paydt) OR (ld_paydt > id_reqdt_next) OR string(ld_paydt,'yyyymmdd') = "" Then
If (id_reqdt > ld_paydt) OR string(ld_paydt,'yyyymmdd') = "" Then
	f_msg_usr_err(200, Title, "거래일자가 잘못 되었습니다. 다시 입력 하세요")
	dw_cond.SetColumn("paydt")
	Return -2
End If	

If is_cus_gu = "Y" Then
	
	SELECT useryn
	 INTO :ls_useryn
	 FROM trcode 
	WHERE trcod = :ls_trcod;
	
	If ls_useryn = 'N' Then
		dw_cond.Object.customerid[1]=""
		dw_cond.Object.customernm[1]=""
	ElseIf ls_useryn = 'Y' Then
		ls_customerid = dw_cond.Object.customerid[1]
		If IsNull(ls_customerid) Then ls_customerid = "" 
		If ls_customerid = "" Then 
			f_msg_usr_err(200, Title, "Customer ID")
			dw_cond.SetColumn("customerid")
			Return -2
		End If	
	End If
End If

/* contractseq */
ll_contractseq	= long(dw_cond.Object.contractseq[1])
If IsNull(ll_contractseq) 		Then ll_contractseq 	= 0

If ll_contractseq = 0 Then 
	f_msg_usr_err(200, Title, "Contractseq를 확인하세요")
	dw_cond.SetColumn("Contractseq")
	Return -2
else
		ls_trdt = string(dw_cond.object.trdt[1],'yyyymmdd')
		
		  select count(*) into :li_cnt  
        from itemsale
        where invoice_month = to_date(:ls_trdt,'yyyymmdd')
            and customerid = :ls_payid
            and contractseq = :ll_contractseq;
		
		if SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "select contractseq-청구계약 조회(dw_cond)")
			Return -2
		End If
		
		if li_cnt = 0 then
			MessageBox(Title, "당월청구정보가 생성되지 않은  계약번호입니다.")
			dw_cond.SetColumn("Contractseq")
			Return -2
		end if
		
End If

/* itemcod */
ls_itemcod 		= dw_cond.Object.itemcod[1]
If IsNull(ls_itemcod) 		Then ls_itemcod 	= "" 

If ls_itemcod = "" Then 
	f_msg_usr_err(200, Title, "거래품목을 선택하세요")
	dw_cond.SetColumn("itemcod")
	Return -2
End If

//ld_paydt = dw_cond.Object.paydt[1]
//ls_paydt = String(ld_paydt, "yyyymm")
//If IsNull(ld_paydt) Then ls_paydt = "" 
//ld_transdt = dw_cond.Object.transdt[1]
//ls_transdt = String(ld_transdt, "yyyymm")
//If IsNull(ld_transdt) Then ls_transdt = "" 

//If ls_svccod = "" Then 
//	f_msg_usr_err(200, Title, "Service")
//	dw_cond.SetColumn("svccod")
//	Return -2
//End If	

Return 0 
end function

on b5w_reg_mtr_req_contract.create
call super::create
end on

on b5w_reg_mtr_req_contract.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Integer li_return
Int li_rc
Long ll_rows
String ls_where
String ls_payid, ls_trdt,ls_paynm, ls_reqnum, ls_reqdt_yyyymm
Date ld_date
Dec{0} lc0_null

ls_payid = Trim(dw_cond.Object.payid[1])
If IsNull(ls_payid) Then ls_payid = ""
If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Payer ID")
	dw_cond.SetColumn("payid")
	Return
End If

ls_trdt = string(dw_cond.object.trdt[1],'yyyymmdd')
If isnull(ls_trdt) Then ls_trdt= ""
If ls_trdt = "" Then
	f_msg_usr_err(200, Title, "Billing Cycle Date")
	dw_cond.SetColumn("payid")
	Return
End If

//자료 읽기 및 관련 처리부분
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve(ls_payid, ls_trdt)
If ll_rows = 0 Then
//	f_msg_info(1000, Title, "청구자료없음")
	dw_cond.Object.pre_balance[1] = 0
	dw_cond.Object.cur_balance[1] = 0	
	p_save.TriggerEvent("ue_enable")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "detail : Retrieve()")
	Return
Else
	li_rc = wfi_set_trvalue(ls_payid)
End If

//dw_cond.AcceptText()
//p_ok.TriggerEvent("ue_disable")
//dw_cond.Object.payid.protect = 1
end event

event open;call super::open;String ls_ref_desc, ls_temp

//고객정보관리 여부 
ls_ref_desc = ""
is_cus_gu = fs_get_control("B5", "R102", ls_ref_desc)

If is_cus_gu = "" Then Return 
If is_cus_gu = 'Y' Then
	dw_cond.Object.l_4.Visible = 1
	dw_cond.Object.userid_t.Visible = 1
	dw_cond.Object.customerid.Visible = 1
	dw_cond.Object.customernm.Visible = 1
ElseIf is_cus_gu = 'N' Then
	dw_cond.Object.customerid[1] = ""			
	dw_cond.Object.customernm[1] = ""						
	dw_cond.Object.l_4.Visible = 0
	dw_cond.Object.userid_t.Visible = 0
	dw_cond.Object.customerid.Visible = 0
	dw_cond.Object.customernm.Visible = 0
End IF

dw_cond.Object.paydt[1] = date(fdt_get_dbserver_now())
p_save.Enabled = FALSE

//금액 format 맞춘다.
is_format = fs_get_control("B5", "H200", ls_ref_desc)
If is_format = "1" Then
	dw_cond.object.tramt.Format 			= "#,##0.0"
	dw_cond.object.pre_balance.Format 	= "#,##0.0"
	dw_cond.object.cur_balance.Format 	= "#,##0.0"	
	dw_detail.object.tramt.Format 		= "#,##0.0"	
ElseIf is_format = "2" Then
	dw_cond.object.tramt.Format 			= "#,##0.00"
	dw_cond.object.pre_balance.Format 	= "#,##0.00"
	dw_cond.object.cur_balance.Format 	= "#,##0.00"	
	dw_detail.object.tramt.Format 		= "#,##0.00"	
Else
	dw_cond.object.tramt.Format 			= "#,##0"
	dw_cond.object.pre_balance.Format 	= "#,##0"
	dw_cond.object.cur_balance.Format 	= "#,##0"	
	dw_detail.object.tramt.Format 		= "#,##0"	
End If
end event

event type integer ue_save_sql();Int li_rc
String ls_payid

dw_cond.AcceptText()

// 필수입력항목 체크
li_rc = wfi_chk_data()
If li_rc < 0 Then Return li_rc

ls_payid = dw_cond.Object.payid[1]

li_rc = wfi_set_trvalue(ls_payid)
If li_rc < 0 Then Return -2

li_rc = MessageBox(Title, "청구거래를 추가 하시겠습니까?", Question!, YesNo!)

If li_rc = 1 Then
	 li_rc = wfi_save_sql()	
Else
	 Return -2
End If

Post Event ue_ok()

Return li_rc
end event

event ue_save;Date ld_date
Integer li_return

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If

li_return = This.Trigger Event ue_save_sql()
Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "Save")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "Save")
		// 청구년월,청구번호,청구금액,미납액 Setting
		SetNull(ld_date)
		dw_cond.Object.trcod[1] = ""
		dw_cond.Object.tramt[1] = 0
		dw_cond.Object.taxamt[1] = 0
		dw_cond.Object.totamt[1] = 0
		dw_cond.Object.paydt[1] = date(fdt_get_dbserver_now())
		dw_cond.Object.remark[1] = ""
		dw_cond.Object.customerid[1] = ""
		dw_cond.Object.customernm[1] = ""	
		dw_cond.Object.contractseq[1] = ""
		dw_cond.Object.itemcod[1] = ""
		dw_cond.Object.pre_balance[1] = 0
		dw_cond.Object.cur_balance[1] = 0
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
End Choose

//dw_cond.Object.payid.protect = 0
//p_ok.TriggerEvent("ue_enable")
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b5w_reg_mtr_req_contract
integer y = 72
integer width = 2770
integer height = 636
string dataobject = "b5d_cnd_reg_mtr_req_contract"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst"
This.is_data[1] = "CloseWithReturn"

This.idwo_help_col[2] = This.Object.customerid
This.is_help_win[2] = "b5w_hlp_paymst_2"
This.is_data[2] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;Int li_i
String ls_type, ls_name
Date ld_date
Window lw_help

setnull(ld_date)
//p_save.TriggerEvent("ue_disable")

Choose Case dwo.Name
	Case "customerid"
		this.is_data[3] = This.object.payid[1]
		this.is_data[4] = This.object.paynm[1]
End Choose

iu_cust_help.il_data[1] = row  // clicked row  , value using at w_a_hlp.il_clicked_row

//kenn : 1999-05-25 Modify *******************
//DW내의 button일 경우를 고려(Column만 Help)
ls_name = dwo.Name
If LeftA(Upper(ls_name), 2) = "B_" Then Return
ls_type = dwo.Type
If ls_type <> "column" Then Return
//*********************************************

For li_i = 1 To ii_help_col_no
	If idwo_help_col[li_i].Name = ls_name Then
		iu_cust_help.idw_data[1] = this

		If UpperBound( is_data ) = 0 Then
			iu_cust_help.is_data[1]='' 
		Else			
			iu_cust_help.is_data[] = is_data[]
		End If
	
		iu_cust_help.is_temp[] = is_temp[]	
		
		OpenwithParm(lw_help, iu_cust_help, is_help_win[li_i]  )

		Exit
	End If
Next

Choose Case dwo.Name
	Case "payid"
		If this.iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.paynm[1] = iu_cust_help.is_data2[2]
			
			SELECT reqdt,
					 add_months(reqdt,1),
					 chargedt
			 INTO :id_reqdt,
					:id_reqdt_next,
					:is_chargedt
			 FROM reqconf
			WHERE chargedt = ( select chargedt
										from reqinfo 
									 where payid = :iu_cust_help.is_data2[1] );
									 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(parent.title, "DOUBLECLICKED-SELECT reqconf")
				dw_cond.Object.trdt[1] = ld_date
				Return -1
			ElseIF SQLCA.SQLCode = 100 Then
			  	f_msg_usr_err(9000, parent.Title, "청구월고객정보(reqinfo)에 존재하지 않는 고객입니다.")			
				dw_cond.object.payid[1] = ""
				dw_cond.object.paynm[1] = ""
				dw_cond.Object.trdt[1] = ld_date
				dw_cond.SetColumn("payid")
				Return -1
			End If	

			dw_cond.Object.trdt[1] = id_reqdt
			
		End If
		
	Case "customerid"
		String ls_payid, ls_paynm
		Long ll_row
	
		If this.iu_cust_help.ib_data[1] Then
			This.Object.customerid[1] = iu_cust_help.is_data2[1]
			This.Object.customernm[1] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If
End Choose

AcceptText()

Return 0
end event

event dw_cond::constructor;call super::constructor;//DataWindowChild ldwc_trcod
//Integer li_rc
//String  ls_filter
//Long ll_rows
//
//li_rc = dw_cond.GetChild("trcod", ldwc_trcod)
//IF li_rc = -1 THEN 
//	MessageBox(Parent.Title, "Not a DataWindowChild(dw_cond)")
//	Return 1
//End If

// Set the filtering condition
//ls_filter = " in_yn = 'Y' "
//// Set the transaction object for the child
//ldwc_trcod.SetTransObject(SQLCA)
//ldwc_trcod.SetFilter(ls_filter)
//ldwc_trcod.Filter()

Return 0
end event

event dw_cond::itemchanged;//Item Change Event
DataWindowChild ldwc_trcod, ldwc_contract
String  ls_billcycle , ls_useryn, ls_payid, ls_trcod, ls_trcod1,	ls_sql,	ls_trdt
String  ls_customerid, ls_itemcod, ls_sql1
Integer li_rc, li_cnt, li_rc1
Long    ll_row, ll_row1
date    ldate_trdt 

// 2019.04.11 변수 추가
Dec  ld_taxamt, ld_tax_rate, ld_netamt

setnull(ldate_trdt)
Choose Case dwo.name
// 2019.05.13 거래금액 입력시 VAT 자동 계산 Modified by Han
	Case "totamt"
		ls_payid   = dw_cond.Object.payid[1]
		ls_trcod   = dw_cond.Object.trcod[1]
		ldate_trdt = dw_cond.Object.trdt [1]

		SELECT FNC_GET_TAXRATE(:ls_payid, 'T', :ls_trcod, :ldate_trdt)
		  INTO :ld_tax_rate
		  FROM DUAL;

//		ld_taxamt = truncate((dec(data) * ld_tax_rate / 100),2) //        - round(dec(data) / (ld_tax_rate / 100), 2)
		
//		ld_taxamt = truncate(dec(data) * ld_tax_rate / 100,li_len)
		SELECT TRUNC(TO_NUMBER(:data) * :ld_tax_rate / 100 , (SELECT TO_NUMBER(ref_content) FROM SYSCTL1T WHERE REF_NO = 'H200' AND MODULE = 'B5')
		            )
		  INTO :ld_taxamt
		  FROM DUAL;
		  
		dw_cond.Object.taxamt[1] = ld_taxamt
		dw_cond.Object.tramt [1] = dec(data) - ld_taxamt
// 2019.04.11 거래금액 입력시 VAT 자동 계산 Modified by Han
	Case "tramt"
		ls_payid   = dw_cond.Object.payid[1]
		ls_trcod   = dw_cond.Object.trcod[1]
		ldate_trdt = dw_cond.Object.trdt [1]

		SELECT FNC_GET_TAXRATE(:ls_payid, 'T', :ls_trcod, :ldate_trdt)
		  INTO :ld_tax_rate
		  FROM DUAL;

//		ld_taxamt = truncate((dec(data) * ld_tax_rate / 100),2) //        - round(dec(data) / (ld_tax_rate / 100), 2)
		
//		ld_taxamt = truncate(dec(data) * ld_tax_rate / 100,li_len)
		SELECT TRUNC(TO_NUMBER(:data) * :ld_tax_rate / 100 , (SELECT TO_NUMBER(ref_content) FROM SYSCTL1T WHERE REF_NO = 'H200' AND MODULE = 'B5')
		            )
		  INTO :ld_taxamt
		  FROM DUAL;
		  
		dw_cond.Object.taxamt[1] = ld_taxamt
 	Case "payid"
		//청구기준일 표시 
//		ls_payid = Trim(dw_cond.Object.payid[1])
		
		If IsNull(data) Then data = " "
		li_rc = wfi_get_payid(data)

		If li_rc = -1 Then
			dw_cond.object.payid[1] = ""
			dw_cond.object.paynm[1] = ""
			dw_cond.object.trdt[1] = ldate_trdt
			dw_cond.SetColumn("payid")
			return 2
		End IF

		SELECT reqdt,
			   add_months(reqdt,1),
			   chargedt 
		 INTO :id_reqdt,
		 	  :id_reqdt_next,
			  :is_chargedt
		 FROM reqconf
		WHERE chargedt = ( select chargedt
							from reqinfo 
							where payid = :data );
								 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "ITEMCHANGED-SELECT reqconf")
			dw_cond.Object.trdt[1] = ldate_trdt
			Return 2
		ElseIF SQLCA.SQLCode = 100 Then
		  	f_msg_usr_err(9000, parent.Title, "청구월고객정보(reqinfo)에 존재하지 않는 고객입니다.")			
			dw_cond.object.payid[1] = ""
			dw_cond.object.paynm[1] = ""
			dw_cond.Object.trdt[1] = ldate_trdt
			dw_cond.SetColumn("payid")
			Return 2
		End If	

		dw_cond.Object.trdt[1] = id_reqdt
		
		ls_trdt	= STRING(id_reqdt, 'YYYYMMDD')
		
		//거래유형
		li_rc = dw_cond.GetChild("trcod", ldwc_trcod)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " SELECT B.TRCOD,   B.TRCODNM, B.DCTYPE, B.CREDIT, B.SALADDYN,    " + &
					" 			B.CALL_YN, B.IN_YN,   B.USERYN									" + &
					" FROM   ITEMMST A, TRCODE B													" + &
					" WHERE  A.TRCOD = B.TRCOD														" + &
					" AND    B.IN_YN = 'N'															" + &
					" AND    A.SVCCOD IN ( SELECT X.SVCCOD										" + &
					"							  FROM   CONTRACTMST X, CUSTOMERM Y				" + &
					"							  WHERE  Y.PAYID = '" + data + "'				" + &
					"							  AND    Y.CUSTOMERID = X.CUSTOMERID )			" + &
					" ORDER BY B.TRCODNM ASC "

//2009.07.17 박자연씨 요청이 있을 줄 알았는데...나중에 다시 이야기한다고함. CJH					
//					" AND    A.BILITEM_YN = 'Y'													" + &		

		ldwc_trcod.SetSqlselect(ls_sql)
		ldwc_trcod.SetTransObject(SQLCA)
		ll_row = ldwc_trcod.Retrieve()
		
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "TRCODE Retrieve()")
			RETURN -2
		END IF			
		
		
		
		//계약번호
		li_rc1 = dw_cond.GetChild("contractseq", ldwc_contract)
		
		IF li_rc1 = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql1 = "select a.contractseq, b.priceplan_desc, a.bil_fromdt	 " + &
					 "	 from contractmst a, priceplanmst b							 " + &
					 "	where  a.priceplan = b.priceplan								 " + &
					 "   and a.customerid = '" + data + "'							 " + &
					 " order by a.contractseq "
		
		ldwc_contract.SetSqlselect(ls_sql1)
		ldwc_contract.SetTransObject(SQLCA)
		ll_row1 = ldwc_contract.Retrieve()
		
		IF ll_row1 < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "Contractseq Retrieve()")
			RETURN -2
		END IF				
	Case "itemcod"
// 2019.04.11 항목이 바뀌면 거래금액과 VAT를 Clear 한다.
		This.Object.tramt [1] = 0
		This.Object.taxamt[1] = 0
		This.Object.totamt[1] = 0

 	Case "trcod"		
// 2019.04.11 항목이 바뀌면 거래금액과 VAT를 Clear 한다.
		This.Object.tramt [1] = 0
		This.Object.taxamt[1] = 0
		This.Object.totamt[1] = 0

		select itemcod into :ls_itemcod from itemmst
		where trcod = trim(:data);
		
		if SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "select itemcod-청구판매 품목조회(dw_cond)")
			Return -2
		End If
		
		this.object.itemcod[1] = ls_itemcod
		
		If is_cus_gu = "N" Then return 0
		
		//거래유형에따라 고객표시여부 
		SELECT useryn
		 INTO :ls_useryn
 		 FROM trcode 
		WHERE trcod = :data;

		If ls_useryn = 'N' Then
			This.Object.customerid[1] = ""			
			This.Object.customernm[1] = ""						
			this.Object.customerid.visible=0
			this.Object.customernm.visible=0
			this.Object.userid_t.visible=0
			this.Object.l_4.visible=0
			This.Object.customerid[1] = ""
		ElseIf ls_useryn = 'Y' Then
			this.Object.customerid.visible=1
			this.Object.customernm.visible=1
			this.Object.userid_t.visible=1
			this.Object.l_4.visible=1
		End If
		
		
	
	Case "customerid"
		
		If IsNull(data) Then data = " "
		li_rc = wfi_get_customerid(data)

		If li_rc < 0 Then
			dw_cond.object.customerid[1] = ""
			dw_cond.object.customernm[1] = ""
			dw_cond.SetColumn("customerid")			
			return 2
		End IF
		


End Choose

Return 0 

//p_save.TriggerEvent("ue_disable")	
end event

type p_ok from w_a_reg_m_sql`p_ok within b5w_reg_mtr_req_contract
integer x = 2862
integer y = 76
end type

type p_close from w_a_reg_m_sql`p_close within b5w_reg_mtr_req_contract
integer x = 2862
integer y = 300
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b5w_reg_mtr_req_contract
integer x = 23
integer width = 2811
integer height = 772
end type

type p_save from w_a_reg_m_sql`p_save within b5w_reg_mtr_req_contract
integer x = 2862
integer y = 188
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b5w_reg_mtr_req_contract
integer x = 23
integer y = 788
integer width = 2802
integer height = 1040
string dataobject = "b5d_reg_mtr_req1"
end type

event dw_detail::ue_init;call super::ue_init;ib_sort_use = False
end event

event dw_detail::doubleclicked;//// Row Click시 b5w_inq_reqbyuserid를 연다.
//// 인자는 청구년월, 고객번호
//String ls_trdt, ls_payid
//Long ll_row
//b5s_str_response  lstr_response
//
//If row > 0 Then 
////	ll_row = GetSelectedRow(0)
//   ls_trdt = Object.reqdtl_trdt[row]
//	ls_payid = dw_cond.Object.payid[1] 
//	
//	messagebox(ls_trdt,"1")
//	
//	This.SelectRow(0,False)
//	This.SelectRow(row, TRUE)
//	
//	lstr_response.s_trdt = ls_trdt
//	lstr_response.s_payid = ls_payid
//	
//	
//	OpenWithParm(b5w_inq_reqbyuserid, lstr_response)
//	
//End If
//
//Return 0 
end event

