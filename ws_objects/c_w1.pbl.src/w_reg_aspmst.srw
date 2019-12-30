$PBExportHeader$w_reg_aspmst.srw
$PBExportComments$[chooys] 제조사 등록 Window
forward
global type w_reg_aspmst from w_a_reg_m_m
end type
end forward

global type w_reg_aspmst from w_a_reg_m_m
integer width = 2587
integer height = 2016
event ue_modeinsert ( )
event ue_modemodify ( )
end type
global w_reg_aspmst w_reg_aspmst

type variables
//신규등록여
Boolean	ib_new
end variables

event ue_modeinsert();p_delete.TriggerEvent("ue_diable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

p_insert.TriggerEvent("ue_enable")
end event

event ue_modemodify();//p_insert.TriggerEvent("ue_disable")

p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")


end event

on w_reg_aspmst.create
call super::create
end on

on w_reg_aspmst.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_item, ls_value

//Condition
ls_item	= Trim(dw_cond.Object.item[1])
ls_value	= Trim(dw_cond.Object.value[1])

IF IsNull(ls_item) THEN ls_item = ""
IF IsNull(ls_value) THEN ls_value = ""


//Dynamic SQL
ls_where = ""

IF ls_item = "asp_id" AND ls_value <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "asp_id = '" + ls_value + "'"
END IF

IF ls_item = "asp_name" AND ls_value <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "asp_name LIKE '%" + ls_value + "%'"
END IF

//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
END IF

end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_asp_id, ls_asp_name, ls_db_userid

//필수항목 Check
ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	ls_asp_id	= Trim(dw_detail.Object.asp_id[ll_rowcnt])
	IF IsNull(ls_asp_id) THEN ls_asp_id = ""
	
	ls_asp_name	= Trim(dw_detail.Object.asp_name[ll_rowcnt])
	IF IsNull(ls_asp_name) THEN ls_asp_name = ""

	ls_db_userid = Trim(dw_detail.Object.db_userid[ll_rowcnt])
	IF IsNull(ls_db_userid) THEN ls_db_userid = ""
	
	//사업자코드 체크
	IF ls_asp_id = "" THEN
		f_msg_usr_err(200, Title, "사업자코드")
		dw_detail.setColumn("ls_asp_id")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//사업자명 체크
	IF ls_asp_name = "" THEN
		f_msg_usr_err(200, Title, "사업자명")
		dw_detail.setColumn("asp_name")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//DB USER 체크
	IF ls_db_userid = "" THEN
		f_msg_usr_err(200, Title, "DB UserID")
		dw_detail.setColumn("db_userid")
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

event type integer ue_reset();call super::ue_reset;dw_cond.Object.item[1] = ""
dw_cond.Object.value[1] = ""

TriggerEvent("ue_modeinsert")

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;TriggerEvent("ue_reset")
dw_detail.insertRow(0)
dw_detail.setColumn("asp_id")
dw_detail.setRow(1)
dw_detail.scrollToRow(1)
dw_detail.setFocus()



//Log 정보
dw_detail.Object.crt_user[1] 	= gs_user_id
dw_detail.Object.crtdt[1] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[1] = gs_user_id
dw_detail.Object.updtdt[1]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[1]		= gs_pgm_id[gi_open_win_no]

TriggerEvent("ue_modemodify")

RETURN 0

end event

event type integer ue_delete();String 	ls_asp_id
Int		li_cnt

ls_asp_id = Trim(dw_detail.Object.asp_id[1])

IF(ls_asp_id = "") THEN
	f_msg_info(3010,This.title,"Delete")
	RETURN -2
END IF

//삭제할 사업자로 등록되어 있는 사용자가 있을 경우 삭제 불가
SELECT count(*)
  INTO :li_cnt
  FROM sysusr1t
 WHERE asp_id = :ls_asp_id;

IF li_cnt > 0 THEN
	MessageBox("삭제불가","해당 사업자의 사용자가 이미 등록되어 있는 사업자이므로 삭제불가합니다.")
	f_msg_info(3010,This.title,"Delete")
	RETURN -2
END IF


DELETE aspmst
WHERE asp_id = :ls_asp_id;


IF SQLCA.SqlCode < 0 THEN
	f_msg_info(3010,This.title,"Delete")
	RollBack;
ELSE
	f_msg_info(3000,This.title,"Delete")
	Commit;
	
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
	TriggerEvent("ue_ok")
END IF

return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
	
	TriggerEvent("ue_ok")
	
End if

//ii_error_chk = 0
RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within w_reg_aspmst
integer x = 55
integer y = 40
integer width = 1833
integer height = 116
string dataobject = "d_cnd_reg_aspmst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within w_reg_aspmst
integer x = 1943
end type

type p_close from w_a_reg_m_m`p_close within w_reg_aspmst
integer x = 2245
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_reg_aspmst
integer width = 1874
integer height = 204
end type

type dw_master from w_a_reg_m_m`dw_master within w_reg_aspmst
integer y = 232
integer width = 2432
integer height = 604
string dataobject = "d_inq_reg_aspmst"
end type

event dw_master::clicked;call super::clicked;Parent.TriggerEvent("ue_modemodify")

String ls_type

ls_type = dwo.Type

Choose Case UPPER(ls_type)
	Case "COLUMN"
		   return 1
	Case "ROW"
			return 1		
End Choose

end event

event dw_master::retrieveend;call super::retrieveend;Parent.TriggerEvent("ue_modemodify")
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.asp_id_t
uf_init( ldwo_sort )

end event

type dw_detail from w_a_reg_m_m`dw_detail within w_reg_aspmst
integer x = 37
integer y = 876
integer width = 2432
integer height = 868
string dataobject = "d_reg_aspmst"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_asp_id


//Set PackageCod
ls_asp_id = Trim(dw_master.Object.asp_id[al_select_row])

//Retrieve
If al_select_row > 0 Then
	ls_where = "asp_id = '" + ls_asp_id + "' "
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

type p_insert from w_a_reg_m_m`p_insert within w_reg_aspmst
integer x = 37
integer y = 1776
end type

type p_delete from w_a_reg_m_m`p_delete within w_reg_aspmst
integer x = 329
integer y = 1776
end type

type p_save from w_a_reg_m_m`p_save within w_reg_aspmst
integer x = 626
integer y = 1776
end type

type p_reset from w_a_reg_m_m`p_reset within w_reg_aspmst
integer x = 1353
integer y = 1776
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_reg_aspmst
integer x = 0
integer y = 844
end type

