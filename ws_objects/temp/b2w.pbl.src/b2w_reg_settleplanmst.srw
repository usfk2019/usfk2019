$PBExportHeader$b2w_reg_settleplanmst.srw
$PBExportComments$[jsmnoh]사업자정산유형등록 W
forward
global type b2w_reg_settleplanmst from w_a_reg_m
end type
end forward

global type b2w_reg_settleplanmst from w_a_reg_m
integer width = 2752
integer height = 1964
end type
global b2w_reg_settleplanmst b2w_reg_settleplanmst

on b2w_reg_settleplanmst.create
call super::create
end on

on b2w_reg_settleplanmst.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_svcdesc, ls_partner

ls_svcdesc	= Trim( dw_cond.Object.svcdesc[1] )
ls_partner	= Trim( dw_cond.Object.partner[1] )

IF( IsNull(ls_svcdesc) ) THEN ls_svcdesc = ""
IF( IsNull(ls_partner) ) THEN ls_partner = ""

//Dynamic SQL
IF ls_svcdesc <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(settleplan_desc) LIKE UPPER('%" + ls_svcdesc + "%')"
END IF

IF ls_partner <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "settle_partner = '" + ls_partner + "'"
END IF


dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(9000, Title, "자료가 없습니다.")
END IF
end event

event ue_extra_save;call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_settleplan, ls_settleplan_desc, ls_settle_partner

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_settleplan	= Trim(dw_detail.Object.settleplan[ll_rowcnt])
	IF IsNull(ls_settleplan) THEN ls_settleplan = ""
	
	ls_settleplan_desc	= Trim(dw_detail.Object.settleplan_desc[ll_rowcnt])
	IF IsNull(ls_settleplan_desc) THEN ls_settleplan_desc = ""
	
	ls_settle_partner = Trim(dw_detail.Object.settle_partner[ll_rowcnt])
	IF IsNull(ls_settle_partner) THEN ls_settle_partner = ""
	
	IF ls_settleplan = "" THEN
		f_msg_usr_err(200, Title, "정산유형코드")
		dw_detail.setColumn("settleplan")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_settleplan_desc = "" THEN
		f_msg_usr_err(200, Title, "정산유형명")
		dw_detail.setColumn("settleplan_desc")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	

	IF ls_settle_partner = "" THEN
		f_msg_usr_err(200, Title, "사업자")
		dw_detail.setColumn("settle_partner")
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

event type integer ue_reset();call super::ue_reset;dw_cond.Object.svcdesc[1] = ""

dw_cond.SetColumn("svcdesc")

p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event ue_extra_insert;call super::ue_extra_insert;String	ls_where
// Insertion Log
dw_detail.Object.crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row]	= gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b2w_reg_settleplanmst
integer x = 37
integer y = 52
integer width = 1943
integer height = 160
string dataobject = "b2dw_cnd_reg_settleplanmst"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b2w_reg_settleplanmst
integer x = 2057
integer y = 48
end type

type p_close from w_a_reg_m`p_close within b2w_reg_settleplanmst
integer x = 2354
integer y = 48
end type

type gb_cond from w_a_reg_m`gb_cond within b2w_reg_settleplanmst
integer width = 1975
integer height = 224
end type

type p_delete from w_a_reg_m`p_delete within b2w_reg_settleplanmst
integer x = 311
integer y = 1676
end type

type p_insert from w_a_reg_m`p_insert within b2w_reg_settleplanmst
integer x = 18
integer y = 1676
end type

type p_save from w_a_reg_m`p_save within b2w_reg_settleplanmst
integer x = 608
integer y = 1676
end type

type dw_detail from w_a_reg_m`dw_detail within b2w_reg_settleplanmst
integer x = 27
integer y = 260
integer width = 2606
integer height = 1368
string dataobject = "b2dw_reg_settleplanmst"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b2w_reg_settleplanmst
integer x = 1125
integer y = 1676
end type

