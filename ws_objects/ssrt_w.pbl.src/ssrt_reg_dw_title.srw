$PBExportHeader$ssrt_reg_dw_title.srw
$PBExportComments$[1hera] DW Object 의 타이틀명 관리
forward
global type ssrt_reg_dw_title from w_a_reg_m
end type
end forward

global type ssrt_reg_dw_title from w_a_reg_m
integer width = 3950
integer height = 2016
end type
global ssrt_reg_dw_title ssrt_reg_dw_title

on ssrt_reg_dw_title.create
call super::create
end on

on ssrt_reg_dw_title.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_category_b, ls_dwonm

String 	ls_Name, 	ls_Title, 	ls_dwobj, 	ls_column, 	ls_modify, ls_header
Long 		ll_Count, 	ll_i, 		ll_rowcnt
Integer 	li_rtn
DataStore lds_dw


//조회 시 상단 대분류명 like 조회
ls_dwonm 	= Trim(dw_cond.Object.dwonm[1])
ls_header 	= Trim(dw_cond.Object.col_header[1])
ls_column 	= Trim(dw_cond.Object.tbl_column[1])
ls_title 	= Trim(dw_cond.Object.header_title[1])

If IsNull(ls_dwonm) Then ls_dwonm = ""

ls_where = ""
If ls_dwonm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(dwobject) Like '%" + Upper(ls_dwonm) + "%' "	
End If
If ls_header <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(col_header) Like '%" + Upper(ls_header) + "%' "	
End If
If ls_column <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(tbl_column) Like '%" + Upper(ls_column) + "%' "	
End If
If ls_title <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(header_title) Like '%" + Upper(ls_title) + "%' "	
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	IF ls_dwonm <> "" THEN
		lds_dw 				= CREATE DataStore
		lds_dw.dataobject = ls_dwonm
		li_rtn = lds_dw.SetTransObject(SQLCA)
		lds_dw.Retrieve()
		IF li_rtn = -1 then 
			f_msg_info(1000, Title, "")
			return
		END IF
		
		ll_Count = Long(lds_dw.Object.DataWindow.Column.Count) //칼럼의 총 갯수
		ls_dwobj = lds_dw.dataobject

		For ll_i = 1 to ll_Count
			ls_Name = lds_dw.Describe("#" + String(ll_i) + ".Name")  //해당 id를 가지는 칼럼의 이름
			// 해당 칼럼의 Header부( = 칼럼명 + '_t')의 Text를 알아낸다
			ls_Title = ls_Name + '_t'
			ll_rowcnt = dw_detail.InsertRow(0)
			dw_detail.Object.dwobject[ll_rowcnt] 	=  ls_dwonm
			dw_detail.Object.col_header[ll_rowcnt] =  ls_title
			dw_detail.Object.tbl_column[ll_rowcnt] =  ls_name
		Next	
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
	ELSE
		f_msg_info(1000, Title, "")
	END IF

ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_dwo, ls_colhd

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_dwo = Trim(dw_detail.Object.dwobject[ll_i])
	ls_colhd = Trim(dw_detail.Object.col_header[ll_i])	
	
	If IsNull(ls_dwo) Then ls_dwo = ""
	If IsNull(ls_colhd) Then ls_colhd = ""
	
	If ls_dwo = "" Then 
		f_msg_usr_err(200, Title, "DW Object")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("dwobject")
		Return -1
	End If
	If ls_colhd = "" Then 
		f_msg_usr_err(200, Title, "Column Header")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("col_header")
		Return -1
	End If
	
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
//		dw_detail.object.updt_user[ll_i] = gs_user_id
//		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
	//	dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
   End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------

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
//f_modify_dw_title(dw_detail)

dw_cond.SetColumn("dwonm")



p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)

dw_detail.SetColumn("dwobject")

//Log 정보
//dw_detail.object.crt_user[al_insert_row] = gs_user_id
//dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.updt_user[al_insert_row] = gs_user_id
//dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//
Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_dw_title
integer x = 41
integer y = 52
integer width = 2341
integer height = 180
string dataobject = "ssrt_cnd_dw_title"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within ssrt_reg_dw_title
integer x = 2441
integer y = 40
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_dw_title
integer x = 2743
integer y = 40
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_dw_title
integer x = 18
integer width = 2382
integer height = 244
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_dw_title
integer x = 315
integer y = 1768
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_dw_title
integer x = 23
integer y = 1768
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_dw_title
integer x = 608
integer y = 1768
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_dw_title
integer x = 23
integer y = 252
integer width = 3849
integer height = 1476
string dataobject = "ssrt_dw_reg_dwtitle"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)




end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_dw_title
integer x = 1179
integer y = 1768
end type

