$PBExportHeader$p2w_reg_refillpolicy.srw
$PBExportComments$[ceusee] 판매금액 Rate 등록
forward
global type p2w_reg_refillpolicy from w_a_reg_m
end type
end forward

global type p2w_reg_refillpolicy from w_a_reg_m
end type
global p2w_reg_refillpolicy p2w_reg_refillpolicy

on p2w_reg_refillpolicy.create
call super::create
end on

on p2w_reg_refillpolicy.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	:	p2w_reg_refillpolicy
	Desc	:	대리점과 가격정책에 따른 카드 금액의 판매가격 Rate
	Date	: 	2003.05.15
	Auth.	:	C.BORA(ceusee)
-------------------------------------------------------------------------*/
end event

event ue_ok();call super::ue_ok;String ls_where, ls_partner, ls_priceplan
Long ll_row

ls_partner = Trim(dw_cond.object.partner[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner = '" + ls_partner + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "priceplan = '" + ls_priceplan + "' "
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

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, i
String ls_sort, ls_partner, ls_priceplan, ls_fromdt
String ls_partner_old, ls_priceplan_old, ls_fromdt_old
Dec{2}  lc_from_amt, lc_to_amt, lc_from_amt_old, lc_to_amt_old


ll_row = dw_detail.RowCount()
//정리하기 위해서 Sort
dw_detail.SetRedraw(False)
ls_sort = "partner, priceplan, Stirng(fromdt, 'yyyymmdd'), fromamt"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
ls_partner_old = ""
ls_priceplan_old = ""
ls_fromdt_old = ""
	


For i = 1 To ll_row
	ls_partner = Trim(dw_detail.object.partner[i])
	ls_priceplan = Trim(dw_detail.object.priceplan[i])
	ls_fromdt = String(dw_detail.object.fromdt[i], 'yyyymmdd')
	lc_from_amt = dw_detail.object.fromamt[i]
	lc_to_amt = dw_detail.object.toamt[i]
	If IsNull(lc_to_amt)  Then lc_to_amt = 999999999
	If IsNull(ls_partner) Then ls_partner = ""
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	
	If ls_partner = "" Then
		f_msg_usr_err(200, Title, "대리점")
		dw_detail.SetColumn("partner")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	End If
   
	If ls_priceplan = "" Then
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.SetColumn("priceplan")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	End If
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	End If
	
//   	 ohj 2005.1.21 추가  0 도 입력가능하게
//	If lc_from_amt = 0 Or IsNull(lc_from_amt) Then
	If lc_from_amt < 0 Or IsNull(lc_from_amt) Then
		f_msg_usr_err(200, Title, "기준금액 From(>=)")
		dw_detail.SetColumn("fromamt")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	
   ElseIf lc_from_amt >= lc_to_amt Then
		If lc_from_amt <> 0 Then		
			f_msg_usr_err(201, Title, "기준금액 From < 기준금액 To")
			dw_detail.SetColumn("toamt")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			Return -2
		End If
	End If
	
	
	
	//날짜가 같으면 금액 범위 비교
	If ls_partner = ls_partner_old and ls_priceplan = ls_priceplan_old and ls_fromdt = ls_fromdt_old Then
		If lc_from_amt >= lc_from_amt_old and lc_from_amt < lc_to_amt_old  Then
			f_msg_usr_err(9000, title,"기준금액을 이미 등록하셨습니다.")
			dw_detail.SetColumn("fromamt")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			Return -2
		
   	End If
	End If
	
 lc_from_amt_old = lc_from_amt
 lc_to_amt_old = lc_to_amt
 ls_partner_old = ls_partner 
 ls_priceplan_old = ls_priceplan  
 ls_fromdt_old = ls_fromdt
Next

dw_detail.SetRedraw(True)
Return 0 
end event

event type integer ue_save();call super::ue_save;dw_detail.SetRedraw(True)
Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within p2w_reg_refillpolicy
integer width = 1467
string dataobject = "p2dw_cnd_refillpolicy"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within p2w_reg_refillpolicy
integer x = 1833
end type

type p_close from w_a_reg_m`p_close within p2w_reg_refillpolicy
integer x = 2139
end type

type gb_cond from w_a_reg_m`gb_cond within p2w_reg_refillpolicy
integer width = 1513
end type

type p_delete from w_a_reg_m`p_delete within p2w_reg_refillpolicy
end type

type p_insert from w_a_reg_m`p_insert within p2w_reg_refillpolicy
end type

type p_save from w_a_reg_m`p_save within p2w_reg_refillpolicy
end type

type dw_detail from w_a_reg_m`dw_detail within p2w_reg_refillpolicy
string dataobject = "p2dw_reg_refillpolicy"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

type p_reset from w_a_reg_m`p_reset within p2w_reg_refillpolicy
end type

