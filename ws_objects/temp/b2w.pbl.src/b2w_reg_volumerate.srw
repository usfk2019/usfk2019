$PBExportHeader$b2w_reg_volumerate.srw
$PBExportComments$[y.k.min]볼륨rate 등록
forward
global type b2w_reg_volumerate from w_a_reg_m
end type
end forward

global type b2w_reg_volumerate from w_a_reg_m
integer height = 1912
end type
global b2w_reg_volumerate b2w_reg_volumerate

on b2w_reg_volumerate.create
call super::create
end on

on b2w_reg_volumerate.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b2w_reg_volumerate
	Desc.	: volumn 요율 등록
	Ver 	: 1.0
	Date	: 2003.01.09
	Progrmaer: Min Yoon Ki (y.k.min)
-------------------------------------------------------------------------*/
//p_insert.TriggerEvent("ue_enable")
dw_detail.SetRowFocusIndicator(Off!)

end event

event ue_ok;call super::ue_ok;Long ll_row
String ls_where
Long ll_volumefr
String ls_fromdt

//조회 
ll_volumefr = dw_cond.Object.volumefr[1]
ls_fromdt = Trim(String(dw_cond.Object.fromdt[1],"YYYYMMDD"))

If IsNull(ll_volumefr) Then ll_volumefr = 0
If IsNull(ls_fromdt) Then ls_fromdt = ""

ls_where = ""
If ll_volumefr <> 0 Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " volumefr >= " + String(ll_volumefr) + " "	
ElseIf ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(fromdt, 'yyyymmdd') = '" + ls_fromdt + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i, ll_j
String ls_volumefr, ls_fromdt, ls_com_amt, ls_itemcod, ls_volumefr1, ls_fromdt1, ls_itemcod1

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_volumefr = Trim(String(dw_detail.Object.volumefr[ll_i]))
	ls_fromdt = Trim(String(dw_detail.Object.fromdt[ll_i]))	
	ls_com_amt = Trim(String(dw_detail.Object.com_amt[ll_i]))
	ls_itemcod = Trim(dw_detail.Object.itemcod[ll_i])
		
	If IsNull(ls_volumefr) Then ls_volumefr = ""
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	If IsNull(ls_com_amt) Then ls_com_amt = ""
	If IsNull(ls_itemcod) Then ls_itemcod = ""
	
	If ls_volumefr = "" Then 
		f_msg_usr_err(200, Title, "Volumefr")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("volumefr")
		Return -1
	End If
	If ls_fromdt = "" Then 
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("fromdt")
		Return -1
	End If
	If ls_com_amt = "" Then 
		f_msg_usr_err(200, Title, "커미션")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("com_amt")
		Return -1
	End If
	If ls_itemcod = "" Then
		f_msg_usr_err(200, Title, "품목")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("itemcod")
		Return -1
	End If
	
	//중복체크 20040109 추가 - kem
	For ll_j = 1 To ll_row
		If ll_i = ll_j Then Continue
		
		ls_volumefr1 = Trim(String(dw_detail.Object.volumefr[ll_j]))
	 	ls_fromdt1 = Trim(String(dw_detail.Object.fromdt[ll_j]))	
		ls_itemcod1 = Trim(dw_detail.Object.itemcod[ll_j])
		
		If IsNull(ls_volumefr1) Then ls_volumefr1 = ""
		If IsNull(ls_fromdt1) Then ls_fromdt1 = ""
		If IsNull(ls_itemcod1) Then ls_itemcod1 = ""
	
		If ls_volumefr = ls_volumefr1 And ls_fromdt = ls_fromdt1 And ls_itemcod = ls_itemcod1 Then
			f_msg_usr_err(9000, Title, "적용개시일, Volume 수량, 품목이 중복됩니다.")
			dw_detail.SetRow(ll_j)
			dw_detail.ScrollToRow(ll_j)
			dw_detail.SetColumn("fromdt")
			Return -1
		Else
			If ls_itemcod = "ALL" Or ls_itemcod1 = "ALL" Then
				f_msg_usr_err(9000, Title, "품목을 ALL과 중복해서 사용할 수 없습니다.")
				dw_detail.SetRow(ll_j)
				dw_detail.ScrollToRow(ll_j)
				dw_detail.SetColumn("itemcod")
				Return -1
			End If
		End If
			
	Next
	
	//Update 한 Log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
   End If
Next



Return 0
	
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("fromdt")



dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b2w_reg_volumerate
integer x = 59
integer y = 56
integer width = 1687
integer height = 132
string dataobject = "b2dw_cnd_reg_volumerate"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b2w_reg_volumerate
integer x = 1943
end type

type p_close from w_a_reg_m`p_close within b2w_reg_volumerate
integer x = 2263
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b2w_reg_volumerate
integer width = 1769
integer height = 224
end type

type p_delete from w_a_reg_m`p_delete within b2w_reg_volumerate
integer x = 320
integer y = 1656
end type

type p_insert from w_a_reg_m`p_insert within b2w_reg_volumerate
integer x = 23
integer y = 1656
end type

type p_save from w_a_reg_m`p_save within b2w_reg_volumerate
integer y = 1656
end type

type dw_detail from w_a_reg_m`dw_detail within b2w_reg_volumerate
integer x = 27
integer y = 240
integer height = 1368
string dataobject = "b2dw_reg_volumerate"
end type

event dw_detail::retrieveend;call super::retrieveend;If dw_detail.RowCount() = 0 Then
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
   p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
End If

Return 0 
end event

type p_reset from w_a_reg_m`p_reset within b2w_reg_volumerate
integer x = 1125
integer y = 1656
end type

