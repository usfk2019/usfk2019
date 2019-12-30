$PBExportHeader$b5w_inq_pay2dtl.srw
$PBExportComments$[kwon] 입금상세내역조회
forward
global type b5w_inq_pay2dtl from w_a_inq_m_m
end type
end forward

global type b5w_inq_pay2dtl from w_a_inq_m_m
integer width = 3515
integer height = 2160
end type
global b5w_inq_pay2dtl b5w_inq_pay2dtl

type variables
String is_format
end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
end prototypes

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Payer ID(wfi_get_payid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where  , ls_payid  , ls_paynm  , ls_paydtfrom, ls_paydtto
String	ls_trcodnm, ls_paytype, ls_transdtfr, ls_transdtto

ls_payid		 = Trim(dw_cond.Object.payid[1])
ls_paydtfrom = Trim(String(dw_cond.object.paydtfrom[1],'yyyymmdd'))
ls_paydtto	 = Trim(String(dw_cond.object.paydtto[1],'yyyymmdd'))
ls_transdtfr	 = Trim(String(dw_cond.object.transdtfr[1],'yyyymmdd'))
ls_transdtto	 = Trim(String(dw_cond.object.transdtto[1],'yyyymmdd'))

ls_paytype	 = Trim(dw_cond.Object.paytype[1])
ls_trcodnm	 = Trim(dw_cond.Object.trcodnm[1])

If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_paydtfrom) Then ls_paydtfrom = ""
If IsNull(ls_paydtto) Then ls_paydtfrom = ""
If IsNull(ls_transdtfr) Then ls_transdtfr = ""
If IsNull(ls_transdtto) Then ls_transdtto = ""
If IsNull(ls_paytype) Then ls_paytype = ""
If IsNull(ls_trcodnm) Then ls_trcodnm = ""

//Dynamic SQL
ls_where = ""

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where	+= "reqpay.payid = '"+ ls_payid +"' "
End If

If( ls_paydtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(paydt, 'YYYYMMDD') >= '"+ ls_paydtfrom +"' "
End If

If( ls_paydtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(paydt, 'YYYYMMDD') <= '"+ ls_paydtto +"' "
End If

If( ls_trcodnm <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "reqpay.trcod = '"+ ls_trcodnm +"' "
End If

If( ls_transdtfr <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(transdt, 'YYYYMMDD') >= '"+ ls_transdtfr +"' "
End If

If( ls_transdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(transdt, 'YYYYMMDD') <= '"+ ls_transdtto +"' "
End If

If( ls_paytype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "reqpay.paytype = '"+ ls_paytype +"' "
End If

dw_master.is_where	= ls_where

//Retrieve
ll_rows	= dw_master.Retrieve()

If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

If is_format = "1" Then
	dw_master.object.payamt.Format = "#,##0.0"
	dw_master.object.sum_payamt.Format = "#,##0.0"
	dw_detail.object.tramt.Format = "#,##0.0"	
ElseIf is_format = "2" Then
	dw_master.object.payamt.Format = "#,##0.00"
	dw_master.object.sum_payamt.Format = "#,##0.00"
	dw_detail.object.tramt.Format = "#,##0.00"	
Else
	dw_master.object.payamt.Format = "#,##0"
	dw_master.object.sum_payamt.Format = "#,##0"
	dw_detail.object.tramt.Format = "#,##0"	
End If
end event

on b5w_inq_pay2dtl.create
call super::create
end on

on b5w_inq_pay2dtl.destroy
call super::destroy
end on

event open;call super::open;String ls_ref_desc

is_format = fs_get_control("B5", "H200", ls_ref_desc)
end event

type dw_cond from w_a_inq_m_m`dw_cond within b5w_inq_pay2dtl
integer x = 64
integer y = 56
integer width = 2414
integer height = 308
string dataobject = "b5d_cnd_inq_pay2dtl"
boolean controlmenu = true
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();idwo_help_col[1] = Object.payid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.paynm[1] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If
//	Case "customerid"
//		If iu_cust_help.ib_data[1] Then
//			This.Object.customerid[1] = iu_cust_help.is_data2[1]
//			This.Object.customernm[1] = iu_cust_help.is_data2[2]			
//		End If	
End Choose

AcceptText()

Return 0 
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_payid
Int    li_rc

Choose Case Dwo.Name
	Case "payid"
		ls_payid = dw_cond.object.payid[1]
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid)

		If li_rc < 0 Then
			dw_cond.object.payid[1] = ""
			dw_cond.object.paynm[1] = ""			
			dw_cond.SetColumn("payid")
			return 2
		End IF		
End Choose
end event

type p_ok from w_a_inq_m_m`p_ok within b5w_inq_pay2dtl
integer x = 2565
end type

type p_close from w_a_inq_m_m`p_close within b5w_inq_pay2dtl
integer x = 2862
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b5w_inq_pay2dtl
integer width = 2482
integer height = 392
end type

type dw_master from w_a_inq_m_m`dw_master within b5w_inq_pay2dtl
integer x = 27
integer y = 420
integer width = 3410
integer height = 1004
string dataobject = "b5dw_inq_pay2dtl"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.payid_t
uf_init(ldwo_SORT)

end event

type dw_detail from w_a_inq_m_m`dw_detail within b5w_inq_pay2dtl
integer x = 32
integer y = 1472
integer width = 3410
integer height = 536
string dataobject = "b5dw_inq_detail_pay2dtl"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);String	ls_where
Long		ll_rows , ll_masterrow
String	ls_seqno

dw_master.AcceptText()		
ll_masterrow = dw_master.GetSelectedrow(0)

ls_seqno = Trim(String(dw_master.Object.seqno[ll_masterrow]))

//Retrieve
If ll_masterrow > 0 Then
	ls_where = " rseqno = '" + ls_seqno + "' "
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b5w_inq_pay2dtl
integer y = 1428
integer height = 36
end type

