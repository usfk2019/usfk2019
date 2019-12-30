$PBExportHeader$b1w_reg_priceplan_validkeytype.srw
$PBExportComments$[ssong]가격정책별 인증 key type
forward
global type b1w_reg_priceplan_validkeytype from w_a_reg_m
end type
end forward

global type b1w_reg_priceplan_validkeytype from w_a_reg_m
end type
global b1w_reg_priceplan_validkeytype b1w_reg_priceplan_validkeytype

on b1w_reg_priceplan_validkeytype.create
call super::create
end on

on b1w_reg_priceplan_validkeytype.destroy
call super::destroy
end on

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.svccod[1] = ""

dw_cond.SetColumn("svccod")

p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_svccod, ls_priceplan, ls_validkey_type

ls_svccod	= Trim( dw_cond.Object.svccod[1] )
ls_priceplan = Trim( dw_cond.object.priceplan[1] )
ls_validkey_type = Trim (dw_cond.object.validkey_type[1] )

IF( IsNull(ls_svccod) ) THEN ls_svccod = ""
IF( IsNull(ls_priceplan) ) THEN ls_priceplan = ""
IF( IsNull(ls_validkey_type) ) THEN ls_validkey_type = ""

//Dynamic SQL
IF ls_svccod <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(b.svccod) LIKE UPPER('%" + ls_svccod + "%')"
END IF

IF ls_priceplan <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(a.priceplan) LIKE UPPER('%" + ls_priceplan + "%')"
END IF

IF ls_validkey_type <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(a.validkey_type) LIKE UPPER('%" + ls_validkey_type + "%')"
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
String	ls_priceplan, ls_validkey_type

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_priceplan	= Trim(dw_detail.Object.priceplan_validkey_type_priceplan[ll_rowcnt])
	IF IsNull(ls_priceplan) THEN ls_priceplan = ""
	
	ls_validkey_type	= Trim(dw_detail.Object.priceplan_validkey_type_validkey_type[ll_rowcnt])
	IF IsNull(ls_validkey_type) THEN ls_validkey_type = ""
	
	//가격정책체크
	IF ls_priceplan = "" THEN
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.setColumn("priceplan")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_validkey_type = "" THEN
		f_msg_usr_err(200, Title, "인증 key type")
		dw_detail.setColumn("validkey_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)   
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.priceplan_validkey_type_updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.priceplan_validkey_type_updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	END IF

NEXT

//No Error
RETURN 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert log

dw_detail.Object.priceplan_validkey_type_crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.priceplan_validkey_type_crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.priceplan_validkey_type_updt_user[al_insert_row]	= gs_user_id
dw_detail.Object.priceplan_validkey_type_updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.priceplan_validkey_type_pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_priceplan_validkeytype
string dataobject = "b1dw_cnd_reg_priceplan_validkeytype"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_priceplan_validkeytype
end type

type p_close from w_a_reg_m`p_close within b1w_reg_priceplan_validkeytype
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_priceplan_validkeytype
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_priceplan_validkeytype
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_priceplan_validkeytype
end type

type p_save from w_a_reg_m`p_save within b1w_reg_priceplan_validkeytype
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_priceplan_validkeytype
string dataobject = "b1dw_master_reg_priceplan_validkeytype"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_svccod 

//품목중분류 선택시 품목대분류 자동 뿌려줌!!
Choose Case dwo.Name
	Case "priceplan_validkey_type_priceplan"
		SELECT svccod INTO :ls_svccod
		FROM priceplanmst
		WHERE priceplan = :data;		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT svccod ")
			Return
		End If		
		
		This.Object.priceplanmst_svccod[row] = ls_svccod
		
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_priceplan_validkeytype
end type

