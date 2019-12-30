$PBExportHeader$b5w_reg_cardprefix_v20.srw
$PBExportComments$[ssong] 신용카드 prefix별 카드사 등록
forward
global type b5w_reg_cardprefix_v20 from w_a_reg_m
end type
end forward

global type b5w_reg_cardprefix_v20 from w_a_reg_m
integer width = 2281
integer height = 1920
end type
global b5w_reg_cardprefix_v20 b5w_reg_cardprefix_v20

on b5w_reg_cardprefix_v20.create
call super::create
end on

on b5w_reg_cardprefix_v20.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_cardprefix, ls_card_type

ls_cardprefix	= Trim(dw_cond.Object.cardprefix[1] )
ls_card_type = Trim(dw_cond.Object.card_type[1])

IF( IsNull(ls_cardprefix) ) THEN ls_cardprefix = ""
IF( IsNull(ls_card_type))THEN ls_card_type = ""

//Dynamic SQL
IF ls_cardprefix <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(cardprefix) LIKE UPPER('" + ls_cardprefix + "%')"
END IF

IF ls_card_type <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "card_type = '" + ls_card_type + "' "
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
String	ls_cardprefix, ls_card_type

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_cardprefix	= Trim(dw_detail.Object.cardprefix[ll_rowcnt])
	IF IsNull(ls_cardprefix) THEN ls_cardprefix = ""
	
	ls_card_type	= Trim(dw_detail.Object.card_type[ll_rowcnt])
	IF IsNull(ls_card_type) THEN ls_card_type = ""
	
		
	//cardprefix코드체크
	IF ls_cardprefix = "" THEN
		f_msg_usr_err(200, Title, "cardprefix")
		dw_detail.setColumn("cardprefix")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_card_type = "" THEN
		f_msg_usr_err(200, Title, "카드사")
		dw_detail.setColumn("card_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	
	
//	//업데이트 처리
//	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
//		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
//		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
//	END IF
//
NEXT

//No Error
RETURN 0
end event

event ue_reset;call super::ue_reset;dw_cond.Object.cardprefix[1] = ""

dw_cond.SetColumn("cardprefix")

p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b5w_reg_cardprefix_v20
	Desc	: 	신용카드 prefix별 카드사구분
	Ver.	: 	1.0
	Date	:	2005.07.19
	Programer : Song Eun Mi
-------------------------------------------------------------------------*/

end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_cardprefix_v20
integer x = 37
integer y = 40
integer width = 1349
integer height = 188
string dataobject = "b5dw_reg_cnd_cardprefix_v20"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_cardprefix_v20
integer x = 1509
integer y = 80
end type

type p_close from w_a_reg_m`p_close within b5w_reg_cardprefix_v20
integer x = 1801
integer y = 80
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_cardprefix_v20
integer x = 23
integer width = 1376
integer height = 260
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_cardprefix_v20
integer x = 315
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_cardprefix_v20
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b5w_reg_cardprefix_v20
integer x = 608
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_cardprefix_v20
integer x = 23
integer y = 276
integer width = 2194
integer height = 1356
string dataobject = "b5dw_reg_det_cardprefix_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_cardprefix_v20
integer y = 1664
end type

