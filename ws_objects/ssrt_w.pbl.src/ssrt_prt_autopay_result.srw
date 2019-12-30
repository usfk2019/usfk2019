$PBExportHeader$ssrt_prt_autopay_result.srw
$PBExportComments$[1hera] Autopayment Result List
forward
global type ssrt_prt_autopay_result from w_a_print
end type
end forward

global type ssrt_prt_autopay_result from w_a_print
end type
global ssrt_prt_autopay_result ssrt_prt_autopay_result

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_reqdt

ls_reqdt 	= String(dw_cond.Object.reqdt[1], "yyyymmdd")
If IsNull(ls_reqdt) 		Then ls_reqdt 		= ""

If ls_reqdt = '' Then
	f_msg_usr_err(200, Title, "Request Date")
	dw_cond.Setfocus()
	dw_cond.Setcolumn("reqdt")
	return
end If

ls_temp 		= "Request Date : " + string(dw_cond.Object.reqdt[1], 'mm-dd-yyyy')
ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

//ls_where = ""
//
//If ls_reqdt <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " A.REQUESTDT = '" + ls_reqdt + "' "
//End If
//
//dw_list.is_where = ls_where
ll_row = dw_list.Retrieve(ls_reqdt)

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If


end event

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_list
end event

on ssrt_prt_autopay_result.create
call super::create
end on

on ssrt_prt_autopay_result.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list,'ssrt_prt_autopay_result')

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_autopay_result
integer x = 50
integer y = 48
integer width = 1001
integer height = 132
string dataobject = "ssrt_cnd_prt_autopay_result"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within ssrt_prt_autopay_result
integer x = 1879
integer y = 36
end type

type p_close from w_a_print`p_close within ssrt_prt_autopay_result
integer x = 2190
integer y = 36
end type

type dw_list from w_a_print`dw_list within ssrt_prt_autopay_result
integer x = 23
integer y = 236
integer height = 1432
string dataobject = "ssrt_prt_autopay_result"
end type

event dw_list::retrieveend;call super::retrieveend;//Long 		kk,	ll_cnt
//String 	ls_base, 	ls_shop,	ls_trdt, ls_reqdt
//DEC{2}	ldc_amt
//IF rowcount <= 0 then return
//
//ls_reqdt =  STring(dw_cond.Object.reqdt[1], 'yyyymmdd')
//FOR kk =  1 to rowcount
//	ls_base = trim(this.Object.groupid[kk])
//	ls_shop = trim(this.Object.partner[kk])
//	ls_trdt = String(this.Object.trdt[kk], 'yyyymmdd')
//	//1. Processed Count
//	SELECT Count(*), SUM(NVL(A.APPRVAMT, 0)) INTO :ll_cnt, :ldc_amt 
//	  FROM KCPBATCH A, CUSTOMERM B
//	 WHERE A.payid =  b.customerid
//	 	AND A.requestdt 	= :ls_reqdt
//      AND A.RESULT 		= 'Y' 
//		AND A.groupid =  :ls_base
//		AND B.partner =  :ls_shop ;
//	
//	IF ISNULL(ll_cnt) OR SQLCA.SQLCODE < 0 	then ll_cnt = 0
//	IF IsNull(ldc_amt) OR SQLCA.SQLCODE < 0  	then ldc_amt = 0
//	THIS.Object.proc_cnt[kk] = ll_cnt
//	THIS.Object.proc_amt[kk] = ldc_amt
//	
//	//2. Failed Count
//	SELECT Count(*), SUM(NVL(A.REQAMT, 0)) INTO :ll_cnt, :ldc_amt 
//	  FROM KCPBATCH A, CUSTOMERM B
//	 WHERE A.payid =  b.customerid
//	 	AND A.requestdt 	= :ls_reqdt
//      AND A.RESULT 		= 'N' 
//		AND A.groupid =  :ls_base
//		AND B.partner =  :ls_shop ;
//	
//	IF ISNULL(ll_cnt) OR SQLCA.SQLCODE < 0 	then ll_cnt = 0
//	IF IsNull(ldc_amt) OR SQLCA.SQLCODE < 0  	then ldc_amt = 0
//	THIS.Object.fail_cnt[kk] = ll_cnt
//	THIS.Object.fail_amt[kk] = ldc_amt
//Next
//
end event

type p_1 from w_a_print`p_1 within ssrt_prt_autopay_result
end type

type p_2 from w_a_print`p_2 within ssrt_prt_autopay_result
end type

type p_3 from w_a_print`p_3 within ssrt_prt_autopay_result
end type

type p_5 from w_a_print`p_5 within ssrt_prt_autopay_result
end type

type p_6 from w_a_print`p_6 within ssrt_prt_autopay_result
end type

type p_7 from w_a_print`p_7 within ssrt_prt_autopay_result
end type

type p_8 from w_a_print`p_8 within ssrt_prt_autopay_result
end type

type p_9 from w_a_print`p_9 within ssrt_prt_autopay_result
end type

type p_4 from w_a_print`p_4 within ssrt_prt_autopay_result
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_autopay_result
end type

type p_port from w_a_print`p_port within ssrt_prt_autopay_result
end type

type p_land from w_a_print`p_land within ssrt_prt_autopay_result
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_autopay_result
integer width = 1033
integer height = 208
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_autopay_result
end type

