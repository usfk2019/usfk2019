$PBExportHeader$b0w_reg_packageitem.srw
$PBExportComments$[chooys] Package Item 구성 - Window
forward
global type b0w_reg_packageitem from w_a_reg_m_m
end type
end forward

global type b0w_reg_packageitem from w_a_reg_m_m
integer width = 3090
integer height = 1932
end type
global b0w_reg_packageitem b0w_reg_packageitem

type variables
String is_packagecod	= ""
end variables

on b0w_reg_packageitem.create
call super::create
end on

on b0w_reg_packageitem.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_svccod
String	ls_itemnm

//Condition
ls_svccod	= Trim(dw_cond.Object.svccod[1])
ls_itemnm	= Trim(dw_cond.Object.itemnm[1])

IF IsNull(ls_svccod) THEN ls_svccod = ""
IF IsNull(ls_itemnm) THEN ls_itemnm	= ""


//Dynamic SQL
ls_where = ""

IF ls_svccod <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "svccod = '" + ls_svccod + "'"
END IF

IF ls_itemnm <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "itemnm LIKE '%" + ls_itemnm + "%'"
END IF

//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	f_msg_info(1000, Title, "")
END IF

end event

event ue_reset;call super::ue_reset;dw_cond.Object.svccod[1] = ""
dw_cond.Object.itemnm[1] = ""

RETURN 0
end event

event ue_extra_insert;call super::ue_extra_insert;//Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row] = gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

//PackageCod
dw_detail.Object.packagecod[al_insert_row] = is_packagecod

RETURN 0
end event

event ue_extra_save;call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_itemcod

//필수항목 Check
ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	ls_itemcod	= Trim(dw_detail.Object.package_item_itemcod[ll_rowcnt])
	IF IsNull(ls_itemcod) THEN ls_itemcod = ""

	//품목ID체크
	IF ls_itemcod = "" THEN
		f_msg_usr_err(200, Title, "품목ID")
		dw_detail.setColumn("package_item_itemcod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	END IF
NEXT

//No Error
RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b0w_reg_packageitem
integer x = 59
integer width = 2345
integer height = 148
string dataobject = "b0dw_cnd_packageitem"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within b0w_reg_packageitem
integer x = 2450
integer y = 40
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b0w_reg_packageitem
integer x = 2743
integer y = 40
end type

type gb_cond from w_a_reg_m_m`gb_cond within b0w_reg_packageitem
integer width = 2400
integer height = 220
end type

type dw_master from w_a_reg_m_m`dw_master within b0w_reg_packageitem
integer y = 228
integer width = 2999
integer height = 772
string dataobject = "b0dw_inq_packageitem"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.itemmst_itemcod_t
uf_init( ldwo_sort )

end event

event dw_master::retrieveend;call super::retrieveend;If rowcount >= 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If
end event

event dw_master::clicked;call super::clicked;String ls_type

ls_type = dwo.Type

Choose Case UPPER(ls_type)
	Case "COLUMN"
		   return 1
	Case "ROW"
			return 1		
End Choose

end event

type dw_detail from w_a_reg_m_m`dw_detail within b0w_reg_packageitem
integer x = 32
integer y = 1040
integer width = 2999
integer height = 612
string dataobject = "b0dw_reg_packageitem"
end type

event dw_detail::ue_retrieve;call super::ue_retrieve;String	ls_where
Long		ll_rows


//Set PackageCod
is_packagecod = Trim(dw_master.Object.itemcod[al_select_row])

//Retrieve
If al_select_row > 0 Then
	ls_where = "package_item.packagecod = '" + is_packagecod + "' "
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "package_item_itemcod"
		If iu_cust_help.ib_data[1] Then
			Object.package_item_itemcod[row] = iu_cust_help.is_data2[1]
			Object.itemnm[row] = iu_cust_help.is_data2[2]
		End If
End Choose
end event

event dw_detail::ue_init;call super::ue_init;idwo_help_col[1] = Object.package_item_itemcod
is_help_win[1] = "b0w_hlp_packageitem"
is_data[1] = "CloseWithReturn"

end event

type p_insert from w_a_reg_m_m`p_insert within b0w_reg_packageitem
integer y = 1692
end type

type p_delete from w_a_reg_m_m`p_delete within b0w_reg_packageitem
integer y = 1692
end type

type p_save from w_a_reg_m_m`p_save within b0w_reg_packageitem
integer y = 1692
end type

type p_reset from w_a_reg_m_m`p_reset within b0w_reg_packageitem
integer x = 1106
integer y = 1692
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b0w_reg_packageitem
integer x = 23
integer y = 1000
integer width = 690
integer height = 36
end type

