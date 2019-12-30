$PBExportHeader$b5w_reg_taxsheet_cancel.srw
$PBExportComments$[jwlee] 세금계산서 발행 취소
forward
global type b5w_reg_taxsheet_cancel from w_a_reg_m_sql
end type
type cb_check from commandbutton within b5w_reg_taxsheet_cancel
end type
type cb_cancel from commandbutton within b5w_reg_taxsheet_cancel
end type
end forward

global type b5w_reg_taxsheet_cancel from w_a_reg_m_sql
integer width = 3328
integer height = 1832
cb_check cb_check
cb_cancel cb_cancel
end type
global b5w_reg_taxsheet_cancel b5w_reg_taxsheet_cancel

type variables
Date id_reqdt, id_reqdt_next
String is_chargedt, is_cus_gu, is_format
String is_type[]
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

public function integer wfi_save_sql ();Int li_rc
Long ll_row, ll_rows, ll_count, ll_taxsheetseq, ll_taxissueseq, ll_seqnx, ll_supplyamt, ll_surtax,  &
     ll_supplyamt_sum, ll_surtax_sum
String ls_chktbl, ls_reqnum
Date   ld_taxissuedt

ll_count = 0
ll_rows = dw_detail.RowCount()

For ll_row = 1 To ll_rows
	
	ls_chktbl = dw_detail.Object.chktbl[ll_row]
	
	If ls_chktbl = "Y" Then 
		ll_taxsheetseq = dw_detail.Object.taxsheetseq[ll_row] //세금계산서번호
		ll_taxissueseq = dw_detail.Object.taxissueseq[ll_row] //발행번호
		ll_supplyamt   = dw_detail.Object.supplyamt[ll_row]   //공급가액
		ll_surtax      = dw_detail.Object.surtax[ll_row]      //부가세
		ld_taxissuedt  = date(dw_detail.Object.taxissuedt[ll_row])  //발행일자
		
	//prepayment 발행번호,세금계산서번호 초기화
		UPDATE PREPAYMENT
		   SET taxissueseq = null, 
		       taxsheetseq = null, 
				 updt_user   = :gs_user_id,
				 updtdt      = sysdate
		 WHERE taxsheetseq = :ll_taxsheetseq ;
		  
		If sqlca.sqlcode < 0 Then 
			f_msg_sql_err(Title, "세금계산서번호(PREPAYMENT)초기화(taxsheetseq=" + String(ll_taxsheetseq))
			Return -1
		End If
		
	//TAXSHEET_INFO 해당 발행번호를 삭제한다.
		DELETE FROM TAXSHEET_INFO
		 WHERE taxsheetseq = :ll_taxsheetseq ;
		  
		If sqlca.sqlcode < 0 Then 
			f_msg_sql_err(Title, "세금계산서번호(TAXSHEET_INFO)삭제(taxsheetseq=" + String(ll_taxsheetseq))
			Return -1
		End If
		
		ll_supplyamt_sum += ll_supplyamt
		ll_surtax_sum    += ll_surtax
		ll_count ++
	End If	
		
Next		
	//TAXSHEET_LOG에 계산서 발행 취소 이력을 남긴다.
	UPDATE TAXSHEET_LOG
	   SET  taxissuedt    = :ld_taxissuedt,
		     supplyamt_sum = supplyamt_sum - :ll_supplyamt_sum,
		     surtax_sum    = surtax_sum    - :ll_surtax_sum,
		     issue_qty     = issue_qty     - :ll_count
	 WHERE taxissueseq    = :ll_taxissueseq;
			  
	If sqlca.sqlcode < 0 Then 
		f_msg_sql_err(Title, "세금계산서 취소 로그 Update(taxissueseq = " + string(ll_taxissueseq))
		Return -1
	End If	

Return 0 
	
end function

on b5w_reg_taxsheet_cancel.create
int iCurrent
call super::create
this.cb_check=create cb_check
this.cb_cancel=create cb_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_check
this.Control[iCurrent+2]=this.cb_cancel
end on

on b5w_reg_taxsheet_cancel.destroy
call super::destroy
destroy(this.cb_check)
destroy(this.cb_cancel)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b5w_reg_taxsheet_cancel
	Desc	: 세금계산서 발행 취소
    Ver.	: 1.0
	Date	: 2006.02.08	
	Programer : JIN-WON,LEE(jwlee)
--------------------------------------------------------------------------*/
String ls_date, ls_temp, ls_ref_desc


ls_temp = fs_get_control("B5", "T210", ls_ref_desc) 

If ls_temp = "" Then Return 0
fi_cut_string(ls_temp, ";" , is_type[])

If is_type[2] = "" Then
	f_msg_usr_err(9000, Title, "세금계산서 발행Type 정보가 없습니다.(SYSCTL1T:B5:T210)")
	Close(This)
End If

dw_cond.SetColumn('taxissueseq')
dw_cond.SetFocus()
end event

event ue_ok;call super::ue_ok;//조회 
String ls_trdt, ls_where, ls_null, ls_reqdt
Long ll_row, ll_taxsheetseq, ll_taxissueseq

dw_cond.Accepttext()

//입력 조건 처리 부분
ll_taxissueseq = dw_cond.object.taxissueseq[1]
ll_taxsheetseq = dw_cond.Object.taxsheetseq[1]

If IsNull(ll_taxissueseq) Then ll_taxissueseq = 0
If IsNull(ll_taxsheetseq) Then ll_taxsheetseq = 0

If ll_taxissueseq = 0 Then
	f_msg_Info(200, Title, "발행번호")
	dw_cond.SetColumn("taxissueseq")
	Return
End If

ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += "a.taxissueseq = '" + String(ll_taxissueseq) + "' "

If ll_taxsheetseq <> 0 Then
	If ls_where <> "" Then ls_where += " And "
    ls_where += "a.taxsheetseq = '" + String(ll_taxsheetseq) + "' "
End If

cb_check.Enabled  = False
cb_cancel.Enabled = False
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
	cb_check.Enabled  = False
	cb_cancel.Enabled = False
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	cb_check.Enabled  = False
	cb_cancel.Enabled = False
	Return 
Else
	cb_check.Enabled  = True
	cb_cancel.Enabled = True
End If
end event

event ue_save_sql;call super::ue_save_sql;Int li_rc
Long ll_row, ll_rows, ll_count
String ls_chktbl

li_rc = 0
ll_count = 0
ll_rows = dw_detail.RowCount()
For ll_row = 1 To ll_rows
	ls_chktbl = dw_detail.Object.chktbl[ll_row]
	If ls_chktbl = "Y" Then ll_count++
Next		
	
li_rc = MessageBox(Title, "선택한 세금계산서를 취소 하시겠습니까?" +&
					  "~r~n" + "(Del : " + String(ll_count) + "Hit(s))" , Question!, YesNo!)
If li_rc = 1 Then
	li_rc = wfi_save_sql()
Else
	Return -2
End If

Return li_rc
end event

event ue_save;call super::ue_save;THIS.TriggerEvent("ue_ok")
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b5w_reg_taxsheet_cancel
integer x = 41
integer y = 44
integer width = 910
integer height = 236
string dataobject = "b5d_cnd_taxsheet_cancel"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within b5w_reg_taxsheet_cancel
integer x = 2373
integer y = 60
end type

type p_close from w_a_reg_m_sql`p_close within b5w_reg_taxsheet_cancel
integer x = 2967
integer y = 60
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b5w_reg_taxsheet_cancel
integer width = 1015
integer height = 296
end type

type p_save from w_a_reg_m_sql`p_save within b5w_reg_taxsheet_cancel
integer x = 2670
integer y = 60
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b5w_reg_taxsheet_cancel
integer y = 316
integer width = 3246
integer height = 1388
string dataobject = "b5d_reg_taxsheet_cancel"
boolean ib_sort_use = false
end type

event dw_detail::rowfocuschanged;call super::rowfocuschanged;
If currentrow = 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
End If
end event

type cb_check from commandbutton within b5w_reg_taxsheet_cancel
integer x = 2373
integer y = 180
integer width = 283
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean enabled = false
string text = "전체선택"
end type

event clicked;Long ll_rows, ll_row

ll_rows = dw_detail.RowCount()

For ll_row = 1 To ll_rows
	dw_detail.Object.chktbl[ll_row] = 'Y'
Next		
end event

type cb_cancel from commandbutton within b5w_reg_taxsheet_cancel
integer x = 2670
integer y = 180
integer width = 283
integer height = 96
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean enabled = false
string text = "전체취소"
end type

event clicked;Long ll_rows, ll_row

ll_rows = dw_detail.RowCount()

For ll_row = 1 To ll_rows
	dw_detail.Object.chktbl[ll_row] = 'N'
Next		
end event

