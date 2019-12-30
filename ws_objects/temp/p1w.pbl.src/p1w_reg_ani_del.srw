$PBExportHeader$p1w_reg_ani_del.srw
$PBExportComments$[islim] Delete Ani
forward
global type p1w_reg_ani_del from w_a_reg_m
end type
end forward

global type p1w_reg_ani_del from w_a_reg_m
integer width = 2299
integer height = 1892
end type
global p1w_reg_ani_del p1w_reg_ani_del

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

on p1w_reg_ani_del.create
call super::create
end on

on p1w_reg_ani_del.destroy
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

/*
If ls_priceplan = "" Then
	f_msg_Info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
    Return 
End If
*/

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

event type integer ue_extra_save();String ls_fromdt, ls_todt, ls_priceplan
String ls_fromdt1, ls_todt1, ls_priceplan1
String ls_fromdt2, ls_todt2, ls_priceplan2
String ls_sort

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
	ls_todt = String (dw_detail.object.todt[i],'yyyymmdd')
	ls_priceplan = dw_detail.object.priceplan[i]
	lc_delamt = Dec(dw_detail.object.delamt[i])
	
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	If IsNull(ls_todt) Then ls_todt = ""
	
	
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
	
	//적용종료일 체크
	If IsNull(ls_todt) Or ls_todt = "" Then ls_todt = "99991231"
	
	If ls_fromdt > ls_todt Then
		f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
		dw_detail.setColumn("todt")
		dw_detail.setRow(i)
		dw_detail.scrollToRow(i)
		dw_detail.setFocus()
		Return -2
	End If
	
	If IsNull(lc_delamt)Then
		f_msg_usr_err(200, Title, "삭제대상금액")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("delamt")
		dw_detail.SetRedraw(True)
		Return -1
	End If
	
Next
dw_detail.SetRedraw(True)

//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows = 1 To dw_detail.RowCount()
	ls_priceplan1  = Trim(dw_detail.object.priceplan[ll_rows])
	ls_fromdt1   = String(dw_detail.object.fromdt[ll_rows], 'yyyymmdd')
	ls_todt1    = String(dw_detail.object.todt[ll_rows], 'yyyymmdd')
	
	If IsNull(ls_todt1) Or ls_todt1 = "" Then ls_todt1 = '99991231'
	
	For ll_rows1 = dw_detail.RowCount() To ll_rows - 1 Step -1
		If ll_rows = ll_rows1 Then
			Exit
		End If
		ls_priceplan2  = Trim(dw_detail.object.priceplan[ll_rows1])
		ls_fromdt2   = String(dw_detail.object.fromdt[ll_rows1], 'yyyymmdd')
		ls_todt2    = String(dw_detail.object.todt[ll_rows1], 'yyyymmdd')
		
		If IsNull(ls_todt2) Or ls_todt2 = "" Then ls_todt2 = '99991231'
		
		If (ls_priceplan1 = ls_priceplan2) Then
			If ls_todt1 >= ls_fromdt2 Then
				f_msg_info(9000, Title, "같은 가격정책[ " + ls_priceplan1 + " ]로 적용개시일이 중복됩니다.")
				Return -1
			End If
		End If
		
	Next
	
Next


Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within p1w_reg_ani_del
integer x = 41
integer y = 40
integer width = 1221
integer height = 208
string dataobject = "p1dw_cnd_reg_ani_del"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within p1w_reg_ani_del
integer x = 1390
integer y = 52
end type

type p_close from w_a_reg_m`p_close within p1w_reg_ani_del
integer x = 1691
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within p1w_reg_ani_del
integer x = 23
integer width = 1253
integer height = 264
end type

type p_delete from w_a_reg_m`p_delete within p1w_reg_ani_del
integer x = 315
integer y = 1652
end type

type p_insert from w_a_reg_m`p_insert within p1w_reg_ani_del
integer x = 23
integer y = 1652
end type

type p_save from w_a_reg_m`p_save within p1w_reg_ani_del
integer x = 613
integer y = 1652
end type

type dw_detail from w_a_reg_m`dw_detail within p1w_reg_ani_del
integer x = 23
integer y = 276
integer width = 2217
integer height = 1312
string dataobject = "p1dw_reg_ani_del"
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

type p_reset from w_a_reg_m`p_reset within p1w_reg_ani_del
integer x = 1134
integer y = 1652
end type

