$PBExportHeader$ssrt2_reg_related_svcmst.srw
$PBExportComments$[hcjung] 서비스 관계 등록
forward
global type ssrt2_reg_related_svcmst from w_a_reg_m
end type
end forward

global type ssrt2_reg_related_svcmst from w_a_reg_m
integer width = 2281
integer height = 1920
end type
global ssrt2_reg_related_svcmst ssrt2_reg_related_svcmst

on ssrt2_reg_related_svcmst.create
call super::create
end on

on ssrt2_reg_related_svcmst.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_relationdesc

ls_relationdesc	= Trim( dw_cond.Object.relationdesc[1] )

IF( IsNull(ls_relationdesc) ) THEN ls_relationdesc = ""

//Dynamic SQL
IF ls_relationdesc <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(relationdesc) LIKE UPPER('%" + ls_relationdesc + "%')"
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
String	ls_priceplan, ls_pre_priceplan, ls_relationdesc

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_priceplan	= Trim(dw_detail.Object.priceplan[ll_rowcnt])
	IF IsNull(ls_priceplan) THEN ls_priceplan = ""
	
	ls_pre_priceplan	= Trim(dw_detail.Object.pre_priceplan[ll_rowcnt])
	IF IsNull(ls_pre_priceplan) THEN ls_pre_priceplan = ""
	
	ls_relationdesc	= Trim(dw_detail.Object.relationdesc[ll_rowcnt])
	IF IsNull(ls_relationdesc) THEN ls_relationdesc = ""
	
	//서비스코드체크
	IF ls_priceplan = "" THEN
		f_msg_usr_err(200, Title, "서비스코드")
		dw_detail.setColumn("priceplan")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//선행 서비스명 체크
	IF ls_pre_priceplan = "" THEN
		f_msg_usr_err(200, Title, "선행 서비스명")
		dw_detail.setColumn("pre_priceplan")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_relationdesc = "" THEN
		f_msg_usr_err(200, Title, "서비스 관계")
		dw_detail.setColumn("relationdesc")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//선후 서비스가 같은지 체크
	IF ls_pre_priceplan = ls_priceplan THEN
		f_msg_usr_err(2100, Title, "선후 Priceplan은 같은 Priceplan로 세팅할 수 없습니다.")
		dw_detail.setColumn("pre_priceplan")
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

event type integer ue_reset();call super::ue_reset;dw_cond.Object.relationdesc[1] = ""

dw_cond.SetColumn("relationdesc")

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

type dw_cond from w_a_reg_m`dw_cond within ssrt2_reg_related_svcmst
integer x = 46
integer y = 40
integer width = 1550
integer height = 140
string dataobject = "ssrt2_cnd_relationdesc"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within ssrt2_reg_related_svcmst
integer x = 1627
integer y = 32
end type

type p_close from w_a_reg_m`p_close within ssrt2_reg_related_svcmst
integer x = 1920
integer y = 32
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt2_reg_related_svcmst
integer x = 23
integer width = 1582
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within ssrt2_reg_related_svcmst
integer x = 315
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within ssrt2_reg_related_svcmst
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within ssrt2_reg_related_svcmst
integer x = 608
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt2_reg_related_svcmst
integer x = 23
integer y = 212
integer width = 2194
integer height = 1412
string dataobject = "ssrt2_reg_related_svcmst"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within ssrt2_reg_related_svcmst
integer y = 1664
end type

