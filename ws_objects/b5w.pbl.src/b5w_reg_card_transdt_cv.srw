$PBExportHeader$b5w_reg_card_transdt_cv.srw
$PBExportComments$[chooys] 카드이체일 변경
forward
global type b5w_reg_card_transdt_cv from w_a_reg_m
end type
end forward

global type b5w_reg_card_transdt_cv from w_a_reg_m
integer width = 1760
end type
global b5w_reg_card_transdt_cv b5w_reg_card_transdt_cv

on b5w_reg_card_transdt_cv.create
call super::create
end on

on b5w_reg_card_transdt_cv.destroy
call super::destroy
end on

event type integer ue_save();Int li_rowCount
Int i
Int li_cnt
String ls_payTrcod
String ls_paydt
String ls_transdt
String ls_maxPaydt
Date ld_maxPaydt
String ls_firstDayNextMonth
String ls_payTrcode[]
String ls_desc
String ls_next


If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return -1
End If

//모래시계표시
SetPointer (HourGlass! )

//li_cnt = fi_cut_string(fs_get_control("B5","I102",ls_desc),";",ls_payTrcode)

//ls_payTrcod = ls_payTrcode[4]

ls_payTrcod = Trim(dw_cond.object.pay_method[1])

ls_next = Trim(dw_cond.object.next[1])

ls_maxPaydt = "00000000"
ld_maxPaydt = Date("1900-01-01")

li_rowCount = dw_detail.rowcount()

For i = 1 to li_rowCount
	ls_paydt = String(dw_detail.object.paydt[i],'yyyymmdd')
	ls_transdt = String(dw_detail.object.transdt[i],'yyyymmdd')
	
	IF ls_maxPaydt < ls_paydt THEN
		ls_maxPaydt = ls_paydt
		ld_maxPaydt = dw_detail.object.paydt[i]
	END IF
	
	UPDATE reqpay SET transdt = to_date(:ls_transdt,'yyyymmdd')
	WHERE trcod = :ls_payTrcod and to_char(paydt,'yyyymmdd') = :ls_paydt;
	
	IF SQLCA.sqlcode < 0 THEN
		MessageBox("reqpay","Update Error")
		RollBack;
	END If
	
	UPDATE reqdtl SET transdt = to_date(:ls_transdt,'yyyymmdd')
	WHERE trcod = :ls_payTrcod and to_char(paydt,'yyyymmdd') = :ls_paydt;
	
	IF SQLCA.sqlcode < 0 THEN
		MessageBox("reqdtl","Update Error")
		RollBack;
	END If
	
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next


ls_firstDayNextMonth = String(fd_next_month(ld_maxPaydt,0),'yyyymmdd')

//가장큰 입금일 이후부터 그 달의 마지막 날까지의 카드이체일을 다음달 1일로 변경한다.
IF ls_next = "Y" THEN
	
	UPDATE reqpay SET transdt = to_date(:ls_firstDayNextMonth,'yyyymmdd')
	WHERE trcod = :ls_payTrcod 
	AND to_char(paydt,'yyyymmdd') > :ls_maxPaydt
	AND to_char(paydt,'yyyymmdd') < :ls_firstDayNextMonth;
		
	IF SQLCA.sqlcode < 0 THEN
		MessageBox("reqpay","Update Error")
		RollBack;
	END If
		
	UPDATE reqdtl SET transdt = to_date(:ls_firstDayNextMonth,'yyyymmdd')
	WHERE trcod = :ls_payTrcod 
	AND to_char(paydt,'yyyymmdd') > :ls_maxPaydt
	AND to_char(paydt,'yyyymmdd') < :ls_firstDayNextMonth;
	
		
	IF SQLCA.sqlcode < 0 THEN
		MessageBox("reqdtl","Update Error")
		RollBack;
	END If

END IF

//모래시계표시 해제
SetPointer (Arrow! )

Commit;

f_msg_info(3000,This.Title,"Save")

Return 0
end event

event ue_ok();call super::ue_ok;Int i
Date ld_firstPaydt
Date ld_lastPaydt
Date ld_curPaydt
String ls_paymethod
String ls_firstPaydt
String ls_lastPaydt

dw_detail.reset()

ls_paymethod = dw_cond.object.pay_method[1]
ld_firstPaydt = dw_cond.object.paydt_from[1]
ld_lastPaydt = dw_cond.object.paydt_to[1]
ls_firstPaydt = String(ld_firstPaydt,'yyyymmdd')
ls_lastPaydt = String(ld_lastPaydt,'yyyymmdd')

IF IsNull(ls_paymethod) THEN ls_paymethod = ""
IF IsNull(ls_firstPaydt) THEN ls_firstPaydt = ""
IF IsNull(ls_lastPaydt) THEN ls_lastPaydt = ""


If ls_paymethod = "" Then
	f_msg_usr_err(200, Title, "결제구분")
	dw_cond.SetColumn("pay_method")
	dw_cond.SetFocus()
	Return
End If

If ls_firstPaydt = "" Then
	f_msg_usr_err(200, Title, "Payment Date")
	dw_cond.SetColumn("paydt_from")
	dw_cond.SetFocus()
	Return
End If

If ls_lastPaydt = "" Then
	f_msg_usr_err(200, Title, "Payment Date")
	dw_cond.SetColumn("paydt_to")
	dw_cond.SetFocus()
	Return
End If

If ls_firstPaydt > ls_lastPaydt Then
	f_msg_usr_err(200, Title, "입금일 오류")
	dw_cond.SetColumn("paydt_from")
	dw_cond.SetFocus()
	Return
End If


//입금일별로 Row를 Insert 한다.

ld_curPaydt = ld_firstPaydt

FOR i=1 to 40
	
	dw_detail.insertRow(i)
	dw_detail.object.paydt[i] = ld_curPaydt
	dw_detail.object.transdt[i] = ld_curPaydt
	
	IF ld_curPaydt = ld_lastPaydt THEN
		EXIT
	END IF
	
	ld_curPaydt = RelativeDate(ld_curPaydt,1)
	
NEXT

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return
end event

event type integer ue_extra_save();call super::ue_extra_save;Int li_rowCount
Int i
String ls_cardTrcod
String ls_paydt
String ls_transdt
String ls_maxPaydt
String ls_firstDayNextMonth

ls_maxPaydt = "00000000"

li_rowCount = dw_detail.rowcount()

For i = 1 to li_rowCount
	ls_paydt = String(dw_detail.object.paydt[i],'yyyymmdd')
	ls_transdt = String(dw_detail.object.transdt[i],'yyyymmdd')
	
	IF IsNull(ls_paydt) THEN ls_paydt = ""
		
	IF ls_paydt = "" THEN
		f_msg_usr_err(200, Title, "Payment Date")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("paydt")
		dw_detail.SetFocus()
		RETURN -1
	END IF
	
	
	IF IsNull(ls_transdt) THEN ls_transdt = ""
		
	IF ls_transdt = "" THEN
		f_msg_usr_err(200, Title, "Fund Transfer Date")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("transdt")
		dw_detail.SetFocus()
		RETURN -1
	END IF
	
Next

return 0
end event

event type integer ue_reset();call super::ue_reset;p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_card_transdt_cv
integer width = 983
integer height = 336
string dataobject = "b5dw_cnd_reg_card_transdt_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_card_transdt_cv
integer x = 1097
end type

type p_close from w_a_reg_m`p_close within b5w_reg_card_transdt_cv
integer x = 1403
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_card_transdt_cv
integer y = 4
integer width = 1033
integer height = 388
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_card_transdt_cv
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_card_transdt_cv
end type

type p_save from w_a_reg_m`p_save within b5w_reg_card_transdt_cv
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_card_transdt_cv
integer x = 37
integer y = 424
integer width = 1632
integer height = 1140
string dataobject = "b5dw_reg_card_transdt_cv"
end type

type p_reset from w_a_reg_m`p_reset within b5w_reg_card_transdt_cv
end type

