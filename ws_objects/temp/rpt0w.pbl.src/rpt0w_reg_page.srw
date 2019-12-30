$PBExportHeader$rpt0w_reg_page.srw
$PBExportComments$[parkkh] Page File Window
forward
global type rpt0w_reg_page from w_a_reg_m
end type
end forward

global type rpt0w_reg_page from w_a_reg_m
integer width = 2345
integer height = 1928
end type
global rpt0w_reg_page rpt0w_reg_page

type variables

end variables

on rpt0w_reg_page.create
call super::create
end on

on rpt0w_reg_page.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_pageno_fr, ls_pageno_to, ls_pageno, ls_description, ls_reccod, ls_selection
String ls_where
Long ll_row

ls_pageno_fr = Trim(dw_cond.Object.pageno_fr[1])
ls_pageno_to = Trim(dw_cond.Object.pageno_to[1])
ls_description = Trim(dw_cond.Object.description[1])
ls_selection = Trim(dw_cond.Object.selection[1])

If IsNull(ls_pageno_fr) Then ls_pageno_fr = ""
If IsNull(ls_pageno_to) Then ls_pageno_to = ""
If IsNull(ls_description) Then ls_description = ""
If IsNull(ls_selection) Then ls_selection = ""

//Record NO Valid Check
If ls_pageno_fr <> "" And ls_pageno_to <> "" Then
	If Long(ls_pageno_fr) > Long(ls_pageno_to) Then
		f_msg_usr_err(202,Title,"Page No From")
		dw_cond.SetFocus()
		dw_cond.SetColumn("pageno_fr")
		Return
	End If
End If

//SQL Where절 생성
ls_where = ""
If ls_pageno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " page.pageno >= '" + ls_pageno_fr + "' "
End If

If ls_pageno_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " page.pageno <= '" + ls_pageno_to + "' "
End If

If ls_description <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " page.description like '%" + ls_description + "%' "
End If


//selection...
If ls_selection <> "" Then
	
	Choose Case ls_selection
		Case "A"   //All
			//.....
		Case "U"   //Use
			If ls_where <> "" Then ls_where += " And "
			ls_where += "( page.mark is null or page.mark <> 'D')"
		Case "D"   //Delete
			If ls_where <> "" Then ls_where += " And "
			ls_where += " page.mark = 'D' "
	End Choose
End If
	
//Retrieve
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100,Title,"Retrieve : dw_detail")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100,Title,"")
End If
end event

event ue_delete;//Not extend ancestor script
//Delete시 row를 실제로 삭제하지는 않고 Mark에 삭제표시('D')만 한다.
Long ll_row

ll_row = dw_detail.GetRow()
dw_detail.Object.mark[ll_row] = "D"

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_pageno, ls_description, ls_mark, ls_pagetype
Long ll_i, ll_rowcount

ll_rowcount = dw_detail.RowCount()

//필수항목 입력 체크
For ll_i = 1 To ll_rowcount
	
	ls_pageno = Trim(dw_detail.Object.pageno[ll_i])
	If IsNull(ls_pageno) Then ls_pageno = ""	
	
	If ls_pageno = "" Then
		f_msg_usr_err(200,Title,"PageNo")
		dw_detail.SetFocus()
		dw_detail.SetColumn("pageno")
		dw_detail.ScrollToRow(ll_i)
		Return -1
	End If
	
	ls_description = Trim(dw_detail.Object.description[ll_i])
	If IsNull(ls_description) Then ls_description = ""	
	
	If ls_description = "" Then
		f_msg_usr_err(200,Title,"Description")
		dw_detail.SetFocus()
		dw_detail.SetColumn("description")
		dw_detail.ScrollToRow(ll_i)
		Return -1
	End If
	
	ls_pagetype = Trim(dw_detail.Object.pagetype[ll_i])
	If IsNull(ls_pagetype) Then ls_pagetype = ""	
	If ls_pagetype = "" Then
		f_msg_usr_err(200,Title,"PageType")
		dw_detail.SetFocus()
		dw_detail.SetColumn("pagetype")
		dw_detail.ScrollToRow(ll_i)
		Return -1
	End If
	
Next

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within rpt0w_reg_page
integer x = 59
integer y = 64
integer width = 1399
integer height = 404
string dataobject = "rpt0dw_cnd_reg_page"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within rpt0w_reg_page
integer x = 1650
integer y = 64
end type

type p_close from w_a_reg_m`p_close within rpt0w_reg_page
integer x = 1957
integer y = 64
end type

type gb_cond from w_a_reg_m`gb_cond within rpt0w_reg_page
integer y = 12
integer width = 1472
integer height = 472
end type

type p_delete from w_a_reg_m`p_delete within rpt0w_reg_page
integer x = 329
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within rpt0w_reg_page
integer x = 37
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within rpt0w_reg_page
integer x = 626
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within rpt0w_reg_page
integer y = 512
integer width = 2249
integer height = 1124
string dataobject = "rpt0dw_reg_detail_page"
end type

event dw_detail::itemerror;call super::itemerror;Return 1
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within rpt0w_reg_page
integer x = 1143
integer y = 1664
end type

