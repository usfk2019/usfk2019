$PBExportHeader$b5w_reg_mtr_del.srw
$PBExportComments$[parkkh] 거래건별삭제
forward
global type b5w_reg_mtr_del from w_a_reg_m_sql
end type
end forward

global type b5w_reg_mtr_del from w_a_reg_m_sql
integer width = 3328
integer height = 1832
end type
global b5w_reg_mtr_del b5w_reg_mtr_del

type variables
Date id_reqdt, id_reqdt_next
String is_chargedt, is_cus_gu, is_format
end variables

forward prototypes
public function integer wfi_get_trdt (string as_payid)
public function integer wfi_get_payid (string as_payid)
public function integer wfi_get_customerid (string as_customerid)
public function integer wfi_save_sql ()
end prototypes

public function integer wfi_get_trdt (string as_payid);/*------------------------------------------------------------------------
	Name	: wfi_get_trdt()
	Descc	: 납입자별 reqnum, trdt구하기
	Arg.	: string as_payid : 납입자 ID
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_reqnum, ls_trdt, ls_basecod, ls_shopid, ls_name
Date ld_trdt
Dec lc_total, lc_curamt

//Base, Shop 구하기
Select basecod, shopid , (firstname || ' ' || midname || ' ' || lastname) name
Into :ls_basecod, :ls_shopid, :ls_name
From customerm
Where customerid = :as_payid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "Payer ID")
   dw_cond.SetFocus()
   dw_cond.SetColumn("payid")
   Return -1
End If

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Base Or Shop")
	Return -1
End If

//청구 년월 구하기
Select add_months(reqdt, -1) 
Into :ld_trdt 
From reqconf Where chargedt  = (Select rtrim(billcycle) from
                                customerm where customerid = :as_payid);
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Invoice Month")
	Return -1
End If

ls_trdt = String(ld_trdt, 'yyyymm')



//Total Amount
Select sum(nvl(tramt,0))
Into :lc_total
From reqdtl
Where payid = :as_payid and (mark is null or mark <> 'D');
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Total Amt. Due")
	Return -1
End If

//당월 청구의 Total
Select sum(nvl(tramt,0))
Into :lc_curamt
From reqdtl
Where to_char(trdt, 'yyyymm') = :ls_trdt and payid = :as_payid
and (mark is null or mark <> 'D');
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Current Balance")
	Return -1
End If


dw_cond.object.name[1] = ls_name
dw_cond.object.basecod[1] = ls_basecod
dw_cond.object.shopid[1] = ls_shopid
dw_cond.object.trdt[1] = ld_trdt
If IsNull(String(lc_total)) Then lc_total = 0
If IsNull(String(lc_curamt)) Then lc_curamt = 0 
dw_cond.object.pre_overdue[1] = lc_total
dw_cond.object.cur_overdue[1] = lc_curamt

Return 0 
end function

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay ID(wfi_get_payid)")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

public function integer wfi_get_customerid (string as_customerid);String ls_customerid, ls_customernm, ls_payid

ls_customerid = as_customerid
//ls_payid = dw_cond.Object.payid[1]

If IsNull(ls_customerid) Then ls_customerid = " "
//If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_customernm
  From Customerm
 Where customerid = :ls_customerid;
//   and payid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay ID(wfi_get_customerid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "고객번호가 없습니다.")
	Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0
end function

public function integer wfi_save_sql ();Int		li_rc
Long		ll_row,			ll_rows,			ll_count,			ll_seq,			ll_seqnx
String	ls_cwork,		ls_reqnum
Dec		ldc_payidamt

ll_count = 0
ll_rows = dw_detail.RowCount()
For ll_row = 1 To ll_rows
	ls_cwork = dw_detail.Object.cwork[ll_row]
	ldc_payidamt = dw_detail.Object.payidamt[ll_row]
	If ls_cwork = "Y" Then 
		ll_seq = dw_detail.Object.seq[ll_row]
		ls_reqnum = dw_detail.Object.reqnum[ll_row]
		
		If ldc_payidamt <> 0 Then
			MessageBox(Title, "이미 수납이 이뤄진 항목입니다.삭제처리 할 수 없습니다.")
			Return -1
		End If
		
		UPDATE  reqdtl 
		  SET mark = 'D', 
		      pgm_id = :gs_pgm_id[gi_open_win_no], 
				updt_user = :gs_user_id,
				updtdt = sysdate,
				complete_yn = 'Y',
				payidamt = tramt
		  WHERE reqnum = :ls_reqnum AND seq = :ll_seq;
		  
		If sqlca.sqlcode < 0 Then 
			f_msg_sql_err(Title, "청구자료삭제1(reqnum=" + ls_reqnum + ",seq=" + String(ll_seq))
			Return -1
		End If
		
		SELECT max(seq) + 1 INTO :ll_seqnx FROM reqdtl WHERE reqnum  = :ls_reqnum;

		INSERT INTO reqdtl
		( reqnum, seq, payid, customerid, trdt, paydt, transdt, trcod, tramt, trcnt, mark, remark,
   	  crt_user,crtdt, pgm_id, updt_user, updtdt,complete_yn,payidamt, TAXAMT)
		SELECT reqnum, :ll_seqnx, payid, customerid, trdt, paydt, transdt, trcod, tramt * -1, trcnt, mark, 'SEQ='||:ll_seq||' 이관 자료',
		       :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no], :gs_user_id, sysdate, 'Y', tramt * -1, NVL(TAXAMT,0) * -1
		 FROM reqdtl
		WHERE reqnum = :ls_reqnum AND seq = :ll_seq;
		If sqlca.sqlcode < 0 Then 
			f_msg_sql_err(Title, "청구자료삭제2(reqnum=" + ls_reqnum + ",seq=" + String(ll_seq))
			Return -1
		End If	
	End If	
Next		

Return 0 
	
end function

on b5w_reg_mtr_del.create
call super::create
end on

on b5w_reg_mtr_del.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b5w_reg_mtr_del
	Desc	: 청구 거래건별 삭제
    Ver.	: 1.0
	Date	: 2003.01.03
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/
String ls_ref_desc

//금액 format 맞춘다.
is_format = fs_get_control("B5", "H200", ls_ref_desc)
If is_format = "1" Then
	dw_detail.object.tramt.Format = "#,##0.0"	
ElseIf is_format = "2" Then
	dw_detail.object.tramt.Format = "#,##0.00"	
Else
	dw_detail.object.tramt.Format = "#,##0"	
End If
end event

event ue_ok();call super::ue_ok;//조회 
String ls_customerid, ls_payid, ls_trcod, ls_paydt
String ls_trdt, ls_where, ls_null, ls_reqdt
Long ll_row

//입력 조건 처리 부분
ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_trcod = Trim(dw_cond.object.trcod[1])
//ls_paydt = String(dw_cond.object.paydt[1], 'YYYYMMDD')

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_trcod) Then ls_trcod = ""
//If IsNull(ls_paydt) Then ls_paydt = ""

If ls_payid = "" Then
	f_msg_Info(200, Title, "Pay ID")
	dw_cond.SetColumn("payid")
	Return
End If

////발란스/청구 년월 등 구하기 
//ll_row = wfi_get_trdt(ls_payid)
//
//If ll_row < 0 Then
//	p_save.TriggerEvent("ue_disable")
//	Return
//ElseIf ll_row = 0 Then
//	//Save 활성화
//	p_save.TriggerEvent("ue_enable")
//	ls_trdt = String(dw_cond.object.trdt[1], 'YYYYMM')    //Invoice Month
//End If

ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += "payid = '" + ls_payid + "' "

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
    ls_where += "customerid = '" + ls_customerid + "' "
End If

If ls_trcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
    ls_where += "trcod = '" + ls_trcod + "' "
End If

ls_reqdt = String(id_reqdt,'yyyymmdd')
If isnull(ls_reqdt) Then ls_reqdt = ""
If ls_reqdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
    ls_where += "to_char(trdt,'yyyymmdd') = '" + ls_reqdt + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 
End If
end event

event type integer ue_save_sql();call super::ue_save_sql;Int li_rc
Long ll_row, ll_rows, ll_count
String ls_cwork

li_rc = 0
ll_count = 0
ll_rows = dw_detail.RowCount()
For ll_row = 1 To ll_rows
	ls_cwork = dw_detail.Object.cwork[ll_row]
	If ls_cwork = "Y" Then ll_count++
Next		
	
li_rc = MessageBox(Title, "선택한 청구거래를 삭제 하시겠습니까?" +&
					  "~r~n" + "(Del : " + String(ll_count) + "Hit(s))" , Question!, YesNo!)
If li_rc = 1 Then
	li_rc = wfi_save_sql()
Else
	Return -2
End If

Return li_rc
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b5w_reg_mtr_del
integer x = 41
integer y = 44
integer width = 1787
integer height = 364
string dataobject = "b5d_cnd_reg_mtr_del"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;date ldate_trdt, ld_use_fr, ld_use_to
setnull(ldate_trdt)

Choose Case dwo.name
	Case "payid"
		If This.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.payid[row] = iu_cust_help.is_data2[1]
			 dw_cond.object.paynm[row] = iu_cust_help.is_data2[2]
		End If
		
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
			f_msg_sql_err(parent.title, "doubleclicked-SELECT reqconf")
			dw_cond.Object.trdt[1] = ldate_trdt
			Return 2
		ElseIF SQLCA.SQLCode = 100 Then
		  	f_msg_usr_err(9000, parent.Title, "청구월고객정보(reqinfo)에 존재하지 않는 고객입니다.")			
			dw_cond.object.payid[1] = ""
			dw_cond.object.paynm[1] = ""
			dw_cond.Object.trdt[1] = ldate_trdt
			dw_cond.SetColumn("payid")
			Return -1
		End If	

		dw_cond.Object.trdt[1] = id_reqdt
		
		//사용기간 시작일
		ld_use_fr = fd_pre_month(id_reqdt, 1)
		//사용기간 종료일
		ld_use_to = fd_date_pre(id_reqdt, 1)
		
		This.object.usedt[1] = String(ld_use_fr, 'yyyy-mm-dd') + " ~~ " + String(ld_use_to, 'yyyy-mm-dd')
		
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] =dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[row] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst"
This.is_data[1] = "CloseWithReturn"

This.idwo_help_col[2] = This.Object.customerid
This.is_help_win[2] = "b5w_hlp_customerm"
This.is_data[2] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String  ls_billcycle , ls_useryn, ls_payid, ls_trcod, ls_trcod1
String  ls_customerid
Integer li_rc
Long    ll_row
date    ldate_trdt , ld_use_to, ld_use_fr

setnull(ldate_trdt)
Choose Case dwo.name
 	Case "payid"
		
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
		
		//사용기간 시작일
		ld_use_fr = fd_pre_month(id_reqdt, 1)
		//사용기간 종료일
		ld_use_to = fd_date_pre(id_reqdt, 1)
		
		This.object.usedt[1] = String(ld_use_fr, 'yyyy-mm-dd') + " ~~ " + String(ld_use_to, 'yyyy-mm-dd')

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
end event

type p_ok from w_a_reg_m_sql`p_ok within b5w_reg_mtr_del
integer x = 1920
integer y = 48
end type

type p_close from w_a_reg_m_sql`p_close within b5w_reg_mtr_del
integer x = 2514
integer y = 48
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b5w_reg_mtr_del
integer width = 1842
integer height = 448
end type

type p_save from w_a_reg_m_sql`p_save within b5w_reg_mtr_del
integer x = 2217
integer y = 48
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b5w_reg_mtr_del
integer y = 488
integer width = 3232
integer height = 1216
string dataobject = "b5d_reg_mtr_del"
boolean ib_sort_use = false
end type

