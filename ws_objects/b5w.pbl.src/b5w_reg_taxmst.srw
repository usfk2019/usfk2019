$PBExportHeader$b5w_reg_taxmst.srw
$PBExportComments$[chooys] TaxMst 등록 Window
forward
global type b5w_reg_taxmst from w_a_reg_m
end type
end forward

global type b5w_reg_taxmst from w_a_reg_m
integer width = 2258
integer height = 1816
end type
global b5w_reg_taxmst b5w_reg_taxmst

on b5w_reg_taxmst.create
call super::create
end on

on b5w_reg_taxmst.destroy
call super::destroy
end on

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insertion Log
dw_detail.Object.crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row]	= gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]


RETURN 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_taxcod, ls_taxname, ls_trcod

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_taxcod	= Trim(dw_detail.Object.taxcod[ll_rowcnt])
	IF IsNull(ls_taxcod) THEN ls_taxcod = ""
	
	ls_taxname	= Trim(dw_detail.Object.taxname[ll_rowcnt])
	IF IsNull(ls_taxname) THEN ls_taxname = ""
	
	ls_trcod	= Trim(dw_detail.Object.trcod[ll_rowcnt])
	IF IsNull(ls_trcod) THEN ls_trcod = ""
	
	//TAX코드체크
	IF ls_taxcod = "" THEN
		f_msg_usr_err(200, Title, "Tax Code")
		dw_detail.setColumn("taxcod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//TAX이름 체크
	IF ls_taxname = "" THEN
		f_msg_usr_err(200, Title, "Tax")
		dw_detail.setColumn("taxname")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//TR코드 체크
	IF ls_trcod = "" THEN
		f_msg_usr_err(200, Title, "Transaction")
		dw_detail.setColumn("trcod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
		dw_detail.Object.pgm_id[ll_rowcnt]		= gs_pgm_id[gi_open_win_no]		
	END IF

NEXT

//No Error
RETURN 0
end event

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_taxcod, ls_taxname, ls_trcod

//ls_taxcod	= Trim(dw_cond.Object.taxcod[1])
ls_taxname	= Trim(dw_cond.Object.taxname[1])
ls_trcod		= Trim(dw_cond.Object.trcod[1])

//IF(IsNull(ls_taxcod)) THEN ls_taxcod = ""
IF (IsNull(ls_taxname)) THEN ls_taxname = ""
IF (IsNull(ls_trcod)) THEN ls_trcod = ""

//Dynamic SQL
/*
IF ls_taxcod <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "taxcod = '" + ls_taxcod + "'"
END IF
*/

IF ls_taxname <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(taxname) LIKE UPPER('%" + ls_taxname + "%')"
END IF

IF ls_trcod <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "trcod = '" + ls_trcod + "'"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event type integer ue_reset();call super::ue_reset;//dw_cond.Object.taxcod[1] = ""
dw_cond.Object.taxname[1] = ""
dw_cond.Object.trcod[1] = ""

//dw_cond.SetColumn("taxname")

p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_taxmst
integer x = 41
integer y = 40
integer width = 1394
string dataobject = "b5dw_cnd_regtaxmst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_taxmst
integer x = 1591
end type

type p_close from w_a_reg_m`p_close within b5w_reg_taxmst
integer x = 1893
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_taxmst
integer width = 1440
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_taxmst
integer x = 343
integer y = 1580
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_taxmst
integer y = 1580
end type

type p_save from w_a_reg_m`p_save within b5w_reg_taxmst
integer x = 654
integer y = 1580
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_taxmst
integer x = 23
integer y = 312
integer width = 2144
string dataobject = "b5dw_reg_taxmst"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_taxmst
integer x = 1207
integer y = 1580
end type

