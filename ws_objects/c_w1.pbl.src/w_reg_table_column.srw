$PBExportHeader$w_reg_table_column.srw
$PBExportComments$[parkkh] 품목 소분류등록
forward
global type w_reg_table_column from w_a_reg_m
end type
end forward

global type w_reg_table_column from w_a_reg_m
integer width = 3328
integer height = 2004
end type
global w_reg_table_column w_reg_table_column

on w_reg_table_column.create
call super::create
end on

on w_reg_table_column.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_table_name, ls_comments, ls_sort

//조회시 상단에 입력한 내용으로 조회
ls_table_name = Trim(dw_cond.Object.table_name[1])
ls_comments = Trim(dw_cond.Object.comments[1])
ls_sort = Trim(dw_cond.Object.sort[1])


If IsNull(ls_table_name) Then ls_table_name = ""
If IsNull(ls_comments) Then ls_comments = ""
If IsNull(ls_sort) Then ls_sort = ""

ls_where = ""

If ls_table_name <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " table_name like '" + ls_table_name + "%' "	
End If

If ls_comments <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " comments like '" + ls_comments + "%' "	
End If


//If ls_sort <> "" Then
//	If ls_where <> "" Then 
//		ls_where += "order by "+ ls_sort 
//   Else 
//		ls_where += "order by "+ ls_sort 
//	End If
////	ls_where += ls_sort
//End if

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


dw_detail.SetRedraw(false)

If ls_sort ='T' Then	
  dw_detail.SetSort("#1 A, #2 A")
ElseIf ls_sort='C' Then
	dw_detail.SetSort("#2 A, #1 A")
ElseIf ls_sort='M' Then
	dw_detail.SetSort("#3 A")
End If

dw_detail.Sort()

dw_detail.SetRedraw(true)
//p_reset.TriggerEvent("ue_enable")


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_table_name, ls_comments
Long ll_row

//insert시 상단에 중분류가 존재하면 뿌려줌!
ls_table_name = Trim(dw_cond.Object.table_name[1])
If IsNull(ls_table_name) Then ls_table_name = ""


If ls_table_name <> "" Then 
	dw_detail.Object.table_name[al_insert_row] = ls_table_name
End If

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("table_name")

////Log 정보
//dw_detail.object.categorya_crt_user[al_insert_row] = gs_user_id
//dw_detail.object.categorya_crtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.categorya_updt_user[al_insert_row] = gs_user_id
//dw_detail.object.categorya_updtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.categorya_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

dw_detail.SetItemStatus(al_insert_row, 0, primary!, NotModified!)

Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_table_name, ls_column_name

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장시 필수입력항목 check
For ll_i = 1 To ll_row
	ls_table_name = Trim(dw_detail.Object.table_name[ll_i])
	ls_column_name = Trim(dw_detail.Object.column_name[ll_i])	
	
	If IsNull(ls_table_name) Then ls_table_name = ""
	If IsNull(ls_column_name) Then ls_column_name = ""

	
	If ls_table_name = "" Then 
		f_msg_usr_err(200, Title, "테이블명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("table_name")
		Return -1
	End If
	If ls_column_name = "" Then 
		f_msg_usr_err(200, Title, "컬럼명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("column_name")
		Return -1
	End If

	
	//Update 한 Log 정보
//	If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
//		dw_detail.object.categorya_updt_user[ll_i] = gs_user_id
//		dw_detail.object.categorya_updtdt[ll_i] = fdt_get_dbserver_now()
//	End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b0w_reg_categoryA
	Desc.	: 품목 소분류 등록
	Ver 	: 1.0
	Date	: 2002.09.24
	Progrmaer: Park Kyung Hae(parkkh)
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
dw_cond.SetColumn("table_name")

p_insert.TriggerEvent("ue_enable")


Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_table_column
integer x = 41
integer y = 64
integer width = 2377
integer height = 272
string dataobject = "d_cnd_table_column"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_table_column
integer x = 2583
integer y = 44
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within w_reg_table_column
integer x = 2889
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_table_column
integer y = 4
integer width = 2409
integer height = 356
end type

type p_delete from w_a_reg_m`p_delete within w_reg_table_column
integer x = 334
integer y = 1736
end type

type p_insert from w_a_reg_m`p_insert within w_reg_table_column
integer y = 1736
end type

type p_save from w_a_reg_m`p_save within w_reg_table_column
integer x = 635
integer y = 1736
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_table_column
integer y = 384
integer width = 3227
integer height = 1296
string dataobject = "d_reg_table_column"
end type

event dw_detail::itemchanged;call super::itemchanged;String ls_category_c 

//품목중분류 선택시 품목대분류 자동 뿌려줌!!
Choose Case dwo.Name
	Case "categorya_categoryb"
		SELECT categoryc INTO :ls_category_c
		FROM categoryb
		WHERE categoryb = :data;		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT categoryc ")
			Return
		End If		
		
		This.Object.categoryb_categoryc[row] = ls_category_c
		
End Choose

end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within w_reg_table_column
integer x = 1193
integer y = 1736
end type

