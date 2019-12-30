$PBExportHeader$b1w_reg_trouble_categorya.srw
$PBExportComments$[chooys] 민원유형 소분류등록
forward
global type b1w_reg_trouble_categorya from w_a_reg_m
end type
end forward

global type b1w_reg_trouble_categorya from w_a_reg_m
integer width = 3328
integer height = 2004
end type
global b1w_reg_trouble_categorya b1w_reg_trouble_categorya

on b1w_reg_trouble_categorya.create
call super::create
end on

on b1w_reg_trouble_categorya.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_category_b, ls_category_c

//조회시 상단에 입력한 내용으로 조회
ls_category_b = Trim(dw_cond.Object.categoryb[1])
ls_category_c = Trim(dw_cond.Object.categoryc[1])

If IsNull(ls_category_b) Then ls_category_b = ""
If IsNull(ls_category_c) Then ls_category_c = ""

ls_where = ""

If ls_category_b <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " troubletypea.troubletypeb = '" + ls_category_b + "' "	
End If

If ls_category_c <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " troubletypeb.troubletypec = '" + ls_category_c + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_category_b, ls_category_c
Long ll_row

//insert시 상단에 중분류가 존재하면 뿌려줌!
ls_category_b = Trim(dw_cond.Object.categoryb[1])
If IsNull(ls_category_b) Then ls_category_b = ""

ls_category_c = Trim(dw_cond.Object.categoryc[1])
If IsNull(ls_category_c) Then ls_category_c = ""

If ls_category_b <> "" Then 
	dw_detail.Object.troubletypea_troubletypeb[al_insert_row] = ls_category_b

	SELECT troubletypec 
	INTO :ls_category_c
	FROM troubletypeb
	WHERE troubletypeb = :ls_category_b;
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, " SELECT troubletypeb")
		Return -1
	End If
		
	dw_detail.Object.troubletypeb_troubletypec[al_insert_row] = ls_category_c
End If

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("troubletypea_troubletypea")

//Log 정보
dw_detail.object.troubletypea_crt_user[al_insert_row] = gs_user_id
dw_detail.object.troubletypea_crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.troubletypea_updt_user[al_insert_row] = gs_user_id
dw_detail.object.troubletypea_updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.troubletypea_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

dw_detail.SetItemStatus(al_insert_row, 0, primary!, NotModified!)

Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_category_a, ls_category_anm, ls_category_b

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장시 필수입력항목 check
For ll_i = 1 To ll_row
	ls_category_a = Trim(dw_detail.Object.troubletypea_troubletypea[ll_i])
	ls_category_anm = Trim(dw_detail.Object.troubletypea_troubletypeanm[ll_i])	
	ls_category_b = Trim(dw_detail.Object.troubletypea_troubletypeb[ll_i])
	
	If IsNull(ls_category_a) Then ls_category_a = ""
	If IsNull(ls_category_anm) Then ls_category_anm = ""
	If IsNull(ls_category_b) Then ls_category_b = ""
	
	If ls_category_a = "" Then 
		f_msg_usr_err(200, Title, "민원유형 소분류코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypea_troubletypea")
		Return -1
	End If
	If ls_category_anm = "" Then 
		f_msg_usr_err(200, Title, "민원유형 소분류명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypea_troubletypeanm")
		Return -1
	End If
	If ls_category_b = "" Then 
		f_msg_usr_err(200, Title, "민원유형 중분류코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypea_troubletypeb")
		Return -1
	End If
	
	//Update 한 Log 정보
	If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.troubletypea_updt_user[ll_i] = gs_user_id
		dw_detail.object.troubletypea_updtdt[ll_i] = fdt_get_dbserver_now()
	End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b1w_reg_categoryC
	Desc.	: 민원유형 소분류 등록
	Ver 	: 1.0
	Date	: 2003.08.12
	Progrmaer: Choo YoonShik(chooys)
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("categoryb")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_trouble_categorya
integer x = 41
integer y = 64
integer width = 2377
integer height = 144
string dataobject = "b1dw_cnd_reg_trouble_categorya"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_trouble_categorya
integer x = 2583
integer y = 44
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_trouble_categorya
integer x = 2889
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_trouble_categorya
integer y = 4
integer width = 2409
integer height = 240
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_trouble_categorya
integer x = 334
integer y = 1736
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_trouble_categorya
integer y = 1736
end type

type p_save from w_a_reg_m`p_save within b1w_reg_trouble_categorya
integer x = 635
integer y = 1736
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_trouble_categorya
integer y = 272
integer width = 3227
integer height = 1408
string dataobject = "b1dw_reg_trouble_categorya"
end type

event dw_detail::itemchanged;call super::itemchanged;String ls_category_c 

//품목중분류 선택시 품목대분류 자동 뿌려줌!!
Choose Case dwo.Name
	Case "troubletypea_troubletypeb"
		SELECT troubletypec INTO :ls_category_c
		FROM troubletypeb
		WHERE troubletypeb = :data;		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT categoryc ")
			Return
		End If		
		
		This.Object.troubletypeb_troubletypec[row] = ls_category_c
		
End Choose

end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_trouble_categorya
integer x = 1193
integer y = 1736
end type

