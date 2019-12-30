$PBExportHeader$b0w_reg_tmcod2.srw
$PBExportComments$[kem] 시간대 구성 등록2(ALL포함)
forward
global type b0w_reg_tmcod2 from w_a_reg_m
end type
end forward

global type b0w_reg_tmcod2 from w_a_reg_m
integer width = 2693
integer height = 1892
end type
global b0w_reg_tmcod2 b0w_reg_tmcod2

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

on b0w_reg_tmcod2.create
call super::create
end on

on b0w_reg_tmcod2.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
//	Name      :	b0w_reg_tmcod2
//	Desc.     : Price Code별 시간대 등록
//	Date      : 2003.10.06
//  Ver.      : 1.0
//  Programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
dw_cond.object.parttype[1] = "0"

dw_cond.object.priceplan[1] = "ALL"
dw_cond.object.priceplan_t.visible = 0
dw_cond.object.priceplan.visible = 0
end event

event ue_ok();call super::ue_ok;//조건 조회
String ls_parttype, ls_priceplan,ls_where, ls_opendt
Long ll_row

ls_parttype  = Trim(dw_cond.object.parttype[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_opendt    = String(dw_cond.object.opendt[1],'yyyymmdd')

If IsNull(ls_parttype) Then ls_parttype = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_opendt) Then ls_opendt = ""

If ls_parttype = "0" Then
	ls_priceplan = "ALL"
Else
	If ls_priceplan = "" Then
		f_msg_Info(200, Title, "가격정책")
		dw_cond.SetFocus()
		dw_cond.SetColumn("priceplan")
   	 Return 
	End If
End If


ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += "priceplan = '" + ls_priceplan  + "' "

If ls_opendt <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(opendt, 'YYYYMMDD')  = '"   + ls_opendt + "' "
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
dw_detail.Object.opendt[al_insert_row] = Date(fdt_get_dbserver_now())
dw_detail.object.priceplan[al_insert_row] = Trim(dw_cond.object.priceplan[1])
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("opendt")
dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event ue_extra_save;//Save Check
/*------------------------------------------------------
// 1.시간대코드(SYSCOD2T) : XYZ
//   X : H(휴일)/S(토요일)/W(평일) fix
//   Y : 1(국제)/2(시외) fix
//   Z : Sequence
-------------------------------------------------------*/
String ls_opendt, ls_opentm, ls_endtm, ls_tmcod
String ls_sort, ls_old_opentm, ls_old_endtm, ls_old_tmcod, ls_old_opendt
DateTime ldt_opendt
Long ll_row , i
Integer li_total

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 
ls_old_opentm = ""
ls_old_endtm = ""
ls_old_tmcod = ""
ls_old_opendt = ""

//시간대의 연속성 Check : 개시일자/시간대코드(XY)/시작시간
//  - DW를 Sort해야만 한다.
dw_detail.SetRedraw(False)
ls_sort = "opendt, mid(tmcod, 2, 1), mid(tmcod, 1, 1), opentm"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()  

//Check
For i =1 To ll_row
	ls_opendt = String(dw_detail.object.opendt[i], 'yyyymmdd')
	ls_tmcod = Trim(dw_detail.object.tmcod[i])
	ls_opentm = Trim(dw_detail.object.opentm[i])
	ls_endtm = Trim(dw_detail.object.endtm[i])

	
	If IsNull(ls_opendt) Then ls_opendt = ""
	If IsNull(ls_tmcod) Then ls_tmcod = ""
	If IsNull(ls_opentm) Then ls_opentm = ""
	If IsNull(ls_endtm) Then ls_endtm = ""
	
	If ls_opendt = "" Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("opendt")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	If ls_tmcod = "" Then
		f_msg_usr_err(200, Title, "시간대 코드")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("tmcod")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	If ls_opentm = "" Then
		f_msg_usr_err(200, Title, "시작시간")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("opentm")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	If ls_endtm = "" Then
		f_msg_usr_err(200, Title, "종료시간")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("endtm")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	//시간 형직 맞는지 비교
	If Not wfb_check_time(ls_opentm) Then
		f_msg_usr_err(201, Title, "시작시간")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("opentm")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	If Not wfb_check_time(ls_endtm) Then
		f_msg_usr_err(201, Title, "종료시간")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("endtm")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	//시간의 대소확인
	If ls_opentm > ls_endtm Then
		f_msg_usr_err(221, Title, "시작시간 > 종료시간")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("opentm")
		dw_detail.ScrollToRow(i)
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
	//같은 시간대 코드일 경우
	If ls_old_opendt = ls_opendt And MidA(ls_old_tmcod, 1, 2) = MidA(ls_tmcod, 1, 2) Then
		If ls_opentm < ls_old_endtm Then
			f_msg_usr_err(221, Title, "시간이 중복 되었습니다.")
			dw_detail.SetColumn("opentm")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetRedraw(True)
			Return -1
		End If
		//시간의 차이를 분으로 환산해서 누적
		li_total += wfi_minute(ls_opentm, ls_endtm)
		
		//이전자료 저장
		ls_old_opendt = ls_opendt
		ls_old_endtm = ls_endtm
		//ls_old_tmcod = ls_tmcod
		
		//마지막인 경우
		If i = ll_row Then
			//누적되어있던 분의 총계가 1440(24*60)이 되는지 확인
			If li_total <> 1440 Then
				f_msg_usr_err(9000, Title, "각 시간대 별로는 24시간이 되어야 합니다.")
				dw_detail.SetRow(i)
				dw_detail.SetColumn("opentm")
				dw_detail.ScrollToRow(i)
				dw_detail.SetFocus()
				dw_detail.SetRedraw(True)
				Return -1
			End If
		End If
	Else
		
		If i > 1 Then
			//누적되어있던 분의 총계가 1440(24*60)이 되는지 확인
			If li_total <> 1440 Then
				f_msg_usr_err(9000, Title, "각 시간대 별로는 24시간이 되어야 합니다.")
				dw_detail.SetColumn("opentm")
				dw_detail.SetRow(i - 1)
				dw_detail.ScrollToRow(i - 1)
				dw_detail.SetFocus()
				dw_detail.SetRedraw(True)
				Return -1
			End If
		End If

		//시간의 차이를 분으로 환산해서 저장
		li_total = wfi_minute(ls_opentm, ls_endtm)

		//이전자료 저장
		ls_old_opendt = ls_opendt
		ls_old_tmcod = ls_tmcod
		ls_old_endtm = ls_endtm
	End If
Next
dw_detail.SetRedraw(True)
//다른 opend dt에서서 처음 하나만 입력할때 24시간이 되지 않아도 넘어가는것 방지 
If li_total <> 1440 Then
	f_msg_usr_err(9000, Title, "각 시간대 별로는 24시간이 되어야 합니다.")
	dw_detail.SetRow(i)
	dw_detail.SetColumn("opentm")
	dw_detail.ScrollToRow(i)
	dw_detail.SetFocus()
	Return -1
End If
Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.object.parttype[1] = "0"

dw_cond.object.priceplan[1] = "ALL"
dw_cond.object.priceplan_t.visible = 0
dw_cond.object.priceplan.visible = 0

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_tmcod2
integer x = 41
integer y = 40
integer width = 1888
integer height = 224
string dataobject = "b0dw_cnd_reg_tmcod2"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;If dwo.name  = "parttype" Then
	If data = "0" Then
		This.object.priceplan[1] = "ALL"
		This.object.priceplan_t.visible = 0
		This.object.priceplan.visible = 0
	Else
		This.object.priceplan[1] = ""
		This.object.priceplan_t.visible = 1
		This.object.priceplan.visible = 1
	End If
End If
end event

type p_ok from w_a_reg_m`p_ok within b0w_reg_tmcod2
integer x = 2048
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b0w_reg_tmcod2
integer x = 2350
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_tmcod2
integer x = 23
integer width = 1920
integer height = 280
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_tmcod2
integer x = 315
integer y = 1652
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_tmcod2
integer x = 23
integer y = 1652
end type

type p_save from w_a_reg_m`p_save within b0w_reg_tmcod2
integer x = 613
integer y = 1652
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_tmcod2
integer x = 23
integer y = 292
integer width = 2615
integer height = 1296
string dataobject = "b0dw_reg_tmcod2"
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

event dw_detail::editchanged;call super::editchanged;//Update log
dw_detail.object.updt_user[row] = gs_user_id
dw_detail.object.updtdt[row] = fdt_get_dbserver_now()
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_tmcod2
integer x = 1134
integer y = 1652
end type

