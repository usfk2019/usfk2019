$PBExportHeader$b2w_reg_currency_exchange.srw
$PBExportComments$[kjm]일자별 currency별 환율 등록
forward
global type b2w_reg_currency_exchange from w_a_reg_m
end type
end forward

global type b2w_reg_currency_exchange from w_a_reg_m
end type
global b2w_reg_currency_exchange b2w_reg_currency_exchange

on b2w_reg_currency_exchange.create
call super::create
end on

on b2w_reg_currency_exchange.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b2w_reg_currency_exchange
	Desc.	: 일자별 currency별 환율 등록
	Ver 	: 1.0
	Date	: 2004.08.26
	Progrmaer: Kwon Jung Min(KJM)
------------------------------------------------------------------------*/


end event

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_currency,	ls_fromdt,	ls_todt
Integer li_cnt

ls_currency = Trim(dw_cond.object.currency[1])
ls_fromdt = String(dw_cond.object.fromdt[1],'YYYYMMDD')

If IsNull(ls_currency) Then ls_currency = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""

ls_where = ""
If ls_currency <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " currency = '"+ ls_currency+ "'"
End If

If ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(fromdt, 'yyyymmdd') <= '"+ls_fromdt+ &
	"' And (to_char(NVL(todt,'"+ls_fromdt+"'), 'yyyymmdd') >= '"+ls_fromdt+"')"
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If

p_insert.TriggerEvent('ue_enable')
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

dw_detail.SetColumn('currency')

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Integer li_row
Long ll_rowcnt
String ls_currency,	ls_fromdt,	ls_todt,	ls_sort
dec lc_exchange_value

//중복 check용 
Long ll_rowcnt1,	ll_rowcnt2
String ls_currency1,	ls_fromdt1,	ls_todt1,	ls_currency2,	ls_fromdt2,	ls_todt2


ll_rowcnt = dw_detail.RowCount()
IF ll_rowcnt < 0 THEN RETURN 0

FOR li_row = 1 TO ll_rowcnt
	ls_currency = dw_detail.object.currency[li_row]
	ls_fromdt = String(dw_detail.object.fromdt[li_row],'yyyymmdd')
	ls_todt = String(dw_detail.object.todt[li_row],'yyyymmdd')
	lc_exchange_value = dw_detail.object.exchange_value[li_row]
	
	IF IsNull(ls_currency) THEN ls_currency = ""
	IF IsNull(ls_fromdt) THEN ls_fromdt = ""	
//	IF IsNull(lc_exchange_value) THEN lc_exchange_value = 0

	IF ls_currency = "" THEN
		f_msg_usr_err(200, Title, "통화구분")
		dw_detail.SetColumn("currency")
		dw_detail.SetRow(li_row)
		dw_detail.ScrollToRow(li_row)
		dw_detail.SetRedraw(True)
		Return -2
	END IF
	
	IF ls_fromdt = "" THEN
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(li_row)
		dw_detail.ScrollToRow(li_row)
		dw_detail.SetRedraw(True)
		Return -2
	END IF
	
	IF ls_todt <> "" THEN
		IF ls_fromdt > ls_todt THEN
			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
			dw_detail.setColumn("fromdt")
			dw_detail.setRow(li_row)
			dw_detail.scrollToRow(li_row)
			dw_detail.SetRedraw(True)
			Return -2
		END IF
	END IF

	IF IsNull(lc_exchange_value) THEN
		f_msg_usr_err(200, Title, "교환가치")
		dw_detail.setColumn("exchange_value")
		dw_detail.setRow(li_row)
		dw_detail.scrollToRow(li_row)
		dw_detail.SetRedraw(True)
		Return -2		
	END IF
NEXT

ls_sort = "currency, string(fromdt,'yyyymmdd')"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

FOR ll_rowcnt1 = 1 TO dw_detail.RowCount()
	ls_currency1 = Trim(dw_detail.object.currency[ll_rowcnt1])
	ls_fromdt1 = String(dw_detail.object.fromdt[ll_rowcnt1], 'yyyymmdd')
	ls_todt1 = String(dw_detail.object.todt[ll_rowcnt1], 'yyyymmdd')

	IF IsNull(ls_todt1) Or ls_todt1 = "" Then ls_todt1 = '99991231'

	FOR ll_rowcnt2 = dw_detail.RowCount() TO ll_rowcnt1 - 1 Step -1
		IF ll_rowcnt1 = ll_rowcnt2 Then
			Exit
		End If
		
		ls_currency2 = Trim(dw_detail.object.currency[ll_rowcnt2])
		ls_fromdt2 = String(dw_detail.object.fromdt[ll_rowcnt2], 'yyyymmdd')
		ls_todt2 = String(dw_detail.object.todt[ll_rowcnt2], 'yyyymmdd')

		If IsNull(ls_todt2) Or ls_todt2 = "" Then ls_todt2 = '99991231'

		IF ls_currency1 = ls_currency2 THEN
			If ls_todt1 >= ls_fromdt2 Then
				f_msg_info(9000, Title, "같은 통화구분[ " + ls_currency1 + " ]으로 적용기간이 중복됩니다.")
				dw_detail.ScrollToRow(ll_rowcnt1)
				dw_detail.SetColumn('currency')				
				Return -2
			End If
		End If
//		
	Next
	//Update Log
	If dw_detail.GetItemStatus(ll_rowcnt1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rowcnt1] = gs_user_id
		dw_detail.object.updtdt[ll_rowcnt1] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_rowcnt1] = gs_pgm_id[1]
	End If
Next

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b2w_reg_currency_exchange
integer y = 64
integer width = 1554
integer height = 128
string dataobject = "b2dw_cnd_reg_currency_exchange"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b2w_reg_currency_exchange
integer x = 2235
end type

type p_close from w_a_reg_m`p_close within b2w_reg_currency_exchange
integer x = 2542
end type

type gb_cond from w_a_reg_m`gb_cond within b2w_reg_currency_exchange
integer width = 1618
integer height = 236
end type

type p_delete from w_a_reg_m`p_delete within b2w_reg_currency_exchange
end type

type p_insert from w_a_reg_m`p_insert within b2w_reg_currency_exchange
end type

type p_save from w_a_reg_m`p_save within b2w_reg_currency_exchange
end type

type dw_detail from w_a_reg_m`dw_detail within b2w_reg_currency_exchange
integer y = 252
string dataobject = "b2dw_reg_currency_exchange"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b2w_reg_currency_exchange
end type

