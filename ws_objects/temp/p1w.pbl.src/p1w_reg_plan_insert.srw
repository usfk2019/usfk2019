$PBExportHeader$p1w_reg_plan_insert.srw
$PBExportComments$[uhmjj] Insert_Plan_Rate
forward
global type p1w_reg_plan_insert from w_a_reg_m
end type
end forward

global type p1w_reg_plan_insert from w_a_reg_m
integer width = 3200
integer height = 1892
end type
global p1w_reg_plan_insert p1w_reg_plan_insert

forward prototypes
public function integer wfi_minute (string as_start_time, string as_end_time)
public function boolean wfb_check_time (string as_time)
end prototypes

public function integer wfi_minute (string as_start_time, string as_end_time);/*------------------------------------------------------------------------
	Name	: wfb_minute()
	Desc. 	: 시작 시간과 종료시간의 분수를 구함
	Arg.	: 1.String 	-as_start_time
			  2.String  -as_end_time
	Return	: 1.Integer -분 수 
------------------------------------------------------------------------*/

Integer li_HH, li_MM
Integer li_OTV, li_ETV
Integer li_return

li_HH = Integer(MidA(as_start_time, 1, 2))
li_MM = Integer(MidA(as_start_time, 3, 2))
li_OTV = li_HH * 60 + li_MM

li_HH = Integer(MidA(as_end_time, 1, 2))
li_MM = Integer(MidA(as_end_time, 3, 2))
li_ETV = li_HH * 60 + li_MM

li_return = li_ETV - li_OTV
Return li_return
end function

public function boolean wfb_check_time (string as_time);/*------------------------------------------------------------------------
	Name	: wfb_check_time()
	Desc. 	: ##:## 형식의 시간을 요구하는데 맞는지 확인
	Arg.	: 1.String 	-as_time
	Return	: 1.Boolean
					- True : 성공
					- False: 실패
------------------------------------------------------------------------*/
Integer li_hh
//4자리 인지 확인
If LenA(as_time) <> 4 Then Return False
If Not IsNumber(as_time) Then Return False

//앞의 2자리 확
li_hh = Integer(MidA(as_time, 1, 2))
If Not (li_hh >= 0 And li_hh <= 24) Then Return False
//뒤의 2자리 확인
li_hh = Integer(MidA(as_time, 3, 2))
If Not (li_hh >= 0 And li_hh <= 59) Then Return False

Return True
end function

on p1w_reg_plan_insert.create
call super::create
end on

on p1w_reg_plan_insert.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
//	Name      :	p1w_reg_ani_del
//	Desc.     : Price Code별 ani 삭제 대상금액등록
//	Date      : 2004. 08. 18
//  Ver.      : 1.0
//  Programer : islim
-------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;//조건 조회
String ls_priceplan,ls_where, ls_fromdt
Long ll_row

ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_fromdt = String(dw_cond.object.fromdt[1],'yyyymmdd')

If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""


If ls_priceplan = "" Then
	f_msg_Info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
    Return 
End If

ls_where = ""

If ls_priceplan <>"" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "priceplan = '" + ls_priceplan  + "' "
End If
	

If ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(fromdt, 'YYYYMMDD')  = '"   + ls_fromdt + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row =0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title,"Retrieve()")
	Return 
End If



	
	
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert
dw_detail.Object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
dw_detail.object.priceplan[al_insert_row] = Trim(dw_cond.object.priceplan[1])
dw_detail.object.log_yn[al_insert_row] = 'Y'


dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("fromdt")
dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event type integer ue_extra_save();String ls_fromdt, ls_priceplan
String ls_fromdt1,ls_priceplan1
String ls_fromdt2,ls_priceplan2
String ls_sort

String ls_p_method, ls_log_yn, ls_refill_type, ls_remark
Long ll_unit
Dec lc_charge_amt, lc_charge_rate

Date ldt_fromdt
Dec  lc_delamt
Long ll_row , i, ll_row1, ll_rows, ll_rows1
Integer li_total

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 

////시간대의 연속성 Check 
////  - DW를 Sort해야만 한다.
//dw_detail.SetRedraw(False)
//ls_sort = "fromdt, todt"
//dw_detail.SetSort(ls_sort)
//dw_detail.Sort()  
//
//Check

For i =1 To ll_row
	ls_fromdt = String(dw_detail.object.fromdt[i], 'yyyymmdd')
	ls_priceplan = dw_detail.object.priceplan[i]
	ls_p_method = dw_detail.object.p_method[i]
	ll_unit = Long(dw_detail.object.unit[i])
	lc_charge_amt = Dec(dw_detail.object.charge_amt[i])
	lc_charge_rate = Dec(dw_detail.object.charge_rate[i])
	ls_log_yn = dw_detail.object.log_yn[i]
	ls_refill_type = dw_detail.object.refill_type[i]
	ls_remark = dw_detail.object.remark[i]
	
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	
	If ls_priceplan = "" Then
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("priceplan")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRedraw(True)
		Return -1
	End If

	If ls_p_method = "" Then
		f_msg_usr_err(200, Title, "과금방식")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("p_method")
		dw_detail.SetRedraw(True)
		Return -1
	End If

	If IsNull(ll_unit)Then
		f_msg_usr_err(200, Title, "과금단위")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("unit")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	If IsNull(lc_charge_amt)Then
		f_msg_usr_err(200, Title, "정액")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("charge_amt")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	If IsNull(lc_charge_rate)Then
		f_msg_usr_err(200, Title, "정율")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("charge_rate")
		dw_detail.SetRedraw(True)
		Return -1
	End If

	If ls_log_yn = "" Then
		f_msg_usr_err(200, Title, "Log여부")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("log_yn")
		dw_detail.SetRedraw(True)
		Return -1
	End If

	IF ls_log_yn = 'Y' THEN
		If ls_refill_type = "" Then
			f_msg_usr_err(200, Title, "충전유형")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("refill_type")
			dw_detail.SetRedraw(True)
			Return -1
		End If
	END IF
Next
dw_detail.SetRedraw(True)



Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within p1w_reg_plan_insert
integer x = 41
integer y = 40
integer width = 1221
integer height = 208
string dataobject = "p1dw_cnd_reg_ani_del"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within p1w_reg_plan_insert
integer x = 1390
integer y = 52
end type

type p_close from w_a_reg_m`p_close within p1w_reg_plan_insert
integer x = 1691
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within p1w_reg_plan_insert
integer x = 23
integer width = 1253
integer height = 264
end type

type p_delete from w_a_reg_m`p_delete within p1w_reg_plan_insert
integer x = 315
integer y = 1652
end type

type p_insert from w_a_reg_m`p_insert within p1w_reg_plan_insert
integer x = 23
integer y = 1652
end type

type p_save from w_a_reg_m`p_save within p1w_reg_plan_insert
integer x = 613
integer y = 1652
end type

type dw_detail from w_a_reg_m`dw_detail within p1w_reg_plan_insert
integer x = 27
integer y = 276
integer width = 3090
integer height = 1312
string dataobject = "p1dw_reg_plan_insert"
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

event dw_detail::itemchanged;call super::itemchanged;////
//String ls_log_yn
//
//dw_detail.AcceptText()
//ls_log_yn = Trim(dw_detail.object.log_yn[Row])
//
//If ls_log_yn = 'N' Then
//	This.Object.refill_type.protect = 1
//	This.Object.log_yn.Background.Color = RGB(255, 251, 240)
//	This.Object.log_yn.Color = RGB(0, 0, 0)
//	This.Object.refill_type.Background.Color = RGB(255, 251, 240)
//	This.Object.refill_type.Color = RGB(0, 0, 0)
//Else
//	This.Object.refill_type.protect = 0
//	This.Object.log_yn.Background.Color = RGB(108, 147, 137)
//	This.Object.log_yn.Color = RGB(255, 255, 255)
//	This.Object.refill_type.Background.Color = RGB(108, 147, 137)
//	This.Object.refill_type.Color = RGB(255, 255, 255)
//End If
end event

type p_reset from w_a_reg_m`p_reset within p1w_reg_plan_insert
integer x = 1134
integer y = 1652
end type

