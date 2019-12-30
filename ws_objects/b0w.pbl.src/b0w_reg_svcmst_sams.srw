$PBExportHeader$b0w_reg_svcmst_sams.srw
$PBExportComments$[chooys] 서비스마스터 등록 - Window
forward
global type b0w_reg_svcmst_sams from w_a_reg_m
end type
end forward

global type b0w_reg_svcmst_sams from w_a_reg_m
integer width = 2281
integer height = 1920
end type
global b0w_reg_svcmst_sams b0w_reg_svcmst_sams

on b0w_reg_svcmst_sams.create
call super::create
end on

on b0w_reg_svcmst_sams.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_svcdesc

ls_svcdesc	= Trim( dw_cond.Object.svcdesc[1] )

IF( IsNull(ls_svcdesc) ) THEN ls_svcdesc = ""

//Dynamic SQL
IF ls_svcdesc <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(svcdesc) LIKE UPPER('%" + ls_svcdesc + "%')"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_svccod, ls_svcdesc, ls_svctype

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_svccod	= Trim(dw_detail.Object.svccod[ll_rowcnt])
	IF IsNull(ls_svccod) THEN ls_svccod = ""
	
	ls_svcdesc	= Trim(dw_detail.Object.svcdesc[ll_rowcnt])
	IF IsNull(ls_svcdesc) THEN ls_svcdesc = ""
	
	ls_svctype	= Trim(dw_detail.Object.svctype[ll_rowcnt])
	IF IsNull(ls_svctype) THEN ls_svctype = ""
	
	//서비스코드체크
	IF ls_svccod = "" THEN
		f_msg_usr_err(200, Title, "서비스코드")
		dw_detail.setColumn("svccod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_svcdesc = "" THEN
		f_msg_usr_err(200, Title, "서비스명")
		dw_detail.setColumn("svcdesc")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_svctype = "" THEN
		f_msg_usr_err(200, Title, "서비스유형")
		dw_detail.setColumn("svctype")
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

event ue_extra_insert;call super::ue_extra_insert;// Insertion Log
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

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_svcmst_sams
integer x = 37
integer y = 40
integer width = 1550
integer height = 140
string dataobject = "b0dw_cnd_svcdesc_sams"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_svcmst_sams
integer x = 1627
integer y = 32
end type

type p_close from w_a_reg_m`p_close within b0w_reg_svcmst_sams
integer x = 1920
integer y = 32
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_svcmst_sams
integer x = 23
integer width = 1582
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_svcmst_sams
integer x = 315
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_svcmst_sams
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b0w_reg_svcmst_sams
integer x = 608
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_svcmst_sams
integer x = 23
integer y = 212
integer width = 2194
integer height = 1412
string dataobject = "b0dw_reg_svcmst_sams"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_svcmst_sams
integer y = 1664
end type

