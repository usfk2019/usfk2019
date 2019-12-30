$PBExportHeader$b1w_reg_linkpartner.srw
$PBExportComments$[ssong] 사업자등록 - Window
forward
global type b1w_reg_linkpartner from w_a_reg_m
end type
end forward

global type b1w_reg_linkpartner from w_a_reg_m
integer width = 2194
integer height = 1920
end type
global b1w_reg_linkpartner b1w_reg_linkpartner

on b1w_reg_linkpartner.create
call super::create
end on

on b1w_reg_linkpartner.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_partner

ls_partner	= Trim( dw_cond.Object.partner[1] )

IF( IsNull(ls_partner) ) THEN ls_partner = ""

If ls_partner = "" Then
	f_msg_info(200, Title, "연동사업자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

//Dynamic SQL
IF ls_partner <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "partner = '" + ls_partner + "' "
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event ue_extra_save;call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_pbxno, ls_inid_prefix

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_pbxno	= Trim(dw_detail.Object.pbxno[ll_rowcnt])
	IF IsNull(ls_pbxno) THEN ls_pbxno = ""
	
	ls_inid_prefix	= Trim(dw_detail.Object.inid_prefix[ll_rowcnt])
	IF IsNull(ls_inid_prefix) THEN ls_inid_prefix = ""
	
	
	//PBXNO check
	IF ls_pbxno = "" THEN
		f_msg_usr_err(200, Title, "PBXNO")
		dw_detail.setColumn("pbxno")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_inid_prefix = "" THEN
		f_msg_usr_err(200, Title, "INID Prefix")
		dw_detail.setColumn("inid_prefix")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	
NEXT

//No Error
RETURN 0
end event

event ue_reset;call super::ue_reset;dw_cond.Object.partner[1] = ""

dw_cond.SetColumn("partner")

p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event ue_extra_insert;call super::ue_extra_insert;// Insertion Log
dw_detail.Object.partner[al_insert_row]	= dw_cond.Object.partner[1]


RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_linkpartner
integer x = 37
integer width = 1349
integer height = 140
string dataobject = "b1dw_reg_cnd_linkpartner"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_linkpartner
integer x = 1509
integer y = 32
end type

type p_close from w_a_reg_m`p_close within b1w_reg_linkpartner
integer x = 1801
integer y = 32
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_linkpartner
integer x = 23
integer width = 1408
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_linkpartner
integer x = 315
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_linkpartner
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b1w_reg_linkpartner
integer x = 608
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_linkpartner
integer x = 23
integer y = 212
integer width = 2103
integer height = 1412
string dataobject = "b1dw_reg_det_linkpartner"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_linkpartner
integer y = 1664
end type

