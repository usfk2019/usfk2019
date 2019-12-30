$PBExportHeader$p0w_reg_cardctl.srw
$PBExportComments$[y.k.min] 대리점별선불카드control
forward
global type p0w_reg_cardctl from w_a_reg_s
end type
end forward

global type p0w_reg_cardctl from w_a_reg_s
end type
global p0w_reg_cardctl p0w_reg_cardctl

on p0w_reg_cardctl.create
call super::create
end on

on p0w_reg_cardctl.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_partner

ls_partner	= Trim( dw_cond.Object.partner[1] )

IF( IsNull(ls_partner) ) THEN ls_partner = ""

//Dynamic SQL
IF ls_partner <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "partner = '" + ls_partner + "'"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.partner[1] = ""

dw_cond.SetColumn("partner")
p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_partner, ls_pidprefix, ls_contnoprefix

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_partner	= Trim(dw_detail.Object.partner[ll_rowcnt])
	IF IsNull(ls_partner) THEN ls_partner = ""
	
	ls_pidprefix	= Trim(dw_detail.Object.pidprefix[ll_rowcnt])
	IF IsNull(ls_pidprefix) THEN ls_pidprefix = ""
	
	ls_contnoprefix	= Trim(dw_detail.Object.contnoprefix[ll_rowcnt])
	IF IsNull(ls_contnoprefix) THEN ls_contnoprefix = ""
	
	//ls_eday	= String(dw_detail.Object.eday[ll_rowcnt])
	//IF IsNull(ls_eday) THEN ls_eday = ""
	
	
	IF ls_partner = "" THEN
		f_msg_usr_err(200, Title, "대리점")
		dw_detail.setColumn("partner")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_pidprefix = "" or LenA(ls_pidprefix) > 2 THEN
		f_msg_usr_err(200, Title, "Pin # Prefix")
		dw_detail.setColumn("pidprefix")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF LenA(ls_contnoprefix) > 2 THEN
		f_msg_usr_err(200, Title, "관리번호 Prefix")
		dw_detail.setColumn("contnoprefix")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
//	IF ls_contnoprefix = "" or Len(ls_contnoprefix) > 2 THEN
//		f_msg_usr_err(200, Title, "관리번호 Prefix")
//		dw_detail.setColumn("contnoprefix")
//		dw_detail.setRow(ll_rowcnt)
//		dw_detail.scrollToRow(ll_rowcnt)
//		dw_detail.setFocus()
//		RETURN -2
//	END IF
	
//	IF ls_eday = "" THEN
//		f_msg_usr_err(200, Title, "연장일수")
//		dw_detail.setColumn("eday")
//		dw_detail.setRow(ll_rowcnt)
//		dw_detail.scrollToRow(ll_rowcnt)
//		dw_detail.setFocus()
//		RETURN -2
//	END IF

	
	//업데이트 처리
//	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
//		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
//		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
//	END IF
//
NEXT

//No Error
RETURN 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: p0w_reg_cardctl
	Desc.	: 대리점별선불카드Control
	Ver 	: 1.0
	Date	: 2003.06.26
	Progrmaer: Min Yoon Ki
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

type dw_cond from w_a_reg_s`dw_cond within p0w_reg_cardctl
integer x = 64
integer width = 1065
integer height = 188
string dataobject = "p0dw_cnd_reg_cardctl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_s`p_ok within p0w_reg_cardctl
integer x = 1431
integer y = 68
end type

type p_close from w_a_reg_s`p_close within p0w_reg_cardctl
integer x = 1733
integer y = 68
end type

type gb_cond from w_a_reg_s`gb_cond within p0w_reg_cardctl
integer y = 4
integer width = 1289
integer height = 252
end type

type dw_detail from w_a_reg_s`dw_detail within p0w_reg_cardctl
integer y = 308
integer height = 1284
string dataobject = "p0dw_reg_cardctl"
end type

type p_delete from w_a_reg_s`p_delete within p0w_reg_cardctl
end type

type p_insert from w_a_reg_s`p_insert within p0w_reg_cardctl
end type

type p_save from w_a_reg_s`p_save within p0w_reg_cardctl
end type

type p_reset from w_a_reg_s`p_reset within p0w_reg_cardctl
end type

