$PBExportHeader$b0w_reg_connection_zone_v20.srw
$PBExportComments$[ssong] 접속료 발생 대역등록
forward
global type b0w_reg_connection_zone_v20 from w_a_reg_m
end type
end forward

global type b0w_reg_connection_zone_v20 from w_a_reg_m
integer width = 2281
integer height = 1920
end type
global b0w_reg_connection_zone_v20 b0w_reg_connection_zone_v20

type variables
String is_customer_type, is_carrier_type
end variables

on b0w_reg_connection_zone_v20.create
call super::create
end on

on b0w_reg_connection_zone_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_svccod

ls_svccod	= Trim( dw_cond.Object.svccod[1] )

IF( IsNull(ls_svccod) ) THEN ls_svccod = ""

If ls_svccod = "" Then
		f_msg_Info(200, Title, "서비스")
		dw_cond.SetFocus()
		dw_cond.SetColumn("svccod")
   	 Return 
	End If	


//Dynamic SQL
IF ls_svccod <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "svccod = '" + ls_svccod + "' AND customer_type = '" + is_customer_type + "' "
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event ue_extra_save;call super::ue_extra_save;
String	ls_callingkey, ls_sacnum_kind, ls_zoncod
Long		ll_rows, ll_rowcnt
Long     ll_cnt, ll_cnt_1


ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_callingkey	= Trim(dw_detail.Object.callingkey[ll_rowcnt])
	IF IsNull(ls_callingkey) THEN ls_callingkey = ""
	
	ls_sacnum_kind	= Trim(dw_detail.Object.sacnum_kind[ll_rowcnt])
	IF IsNull(ls_sacnum_kind) THEN ls_sacnum_kind = ""
	
	ls_zoncod	= Trim(dw_detail.Object.zoncod[ll_rowcnt])
	IF IsNull(ls_zoncod) THEN ls_zoncod = ""
	
	//서비스코드체크
	IF ls_callingkey = "" THEN
		f_msg_usr_err(200, Title, "발신번호 prefix")
		dw_detail.setColumn("callingkey")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_sacnum_kind = "" THEN
		f_msg_usr_err(200, Title, "접속료 유형")
		dw_detail.setColumn("sacnum_kind")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_zoncod = "" THEN
		f_msg_usr_err(200, Title, "대 역")
		dw_detail.setColumn("zoncod")
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

event ue_reset;call super::ue_reset;dw_cond.Object.svccod[1] = ""

dw_cond.SetColumn("svccod")


RETURN 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insertion Log

dw_detail.Object.svccod[al_insert_row] = Trim(dw_cond.Object.svccod[1])
dw_detail.object.customer_type[al_insert_row] = '100'

dw_detail.object.crt_user[al_insert_row]  = gs_user_id
dw_detail.object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row]  = gs_user_id
dw_detail.object.updtdt[al_insert_row]     = fdt_get_dbserver_now()

RETURN 0
end event

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b0w_reg_connection_zone_v20
	Desc.	:	접속료 발생 대역등록
	Ver	: 	1.0
	Date	: 	2005.07.20
	Prgromer : Song Eun Mi
---------------------------------------------------------------------------*/

String ls_ref_desc, ls_temp, ls_name[]


ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("00", "Z940", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_customer_type = ls_name[1]
is_carrier_type = ls_name[2]
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_connection_zone_v20
integer x = 37
integer y = 44
integer width = 1349
integer height = 140
string dataobject = "b0dw_reg_cnd_connection_zone_v20"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_connection_zone_v20
integer x = 1509
integer y = 32
end type

type p_close from w_a_reg_m`p_close within b0w_reg_connection_zone_v20
integer x = 1801
integer y = 32
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_connection_zone_v20
integer x = 23
integer width = 1376
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_connection_zone_v20
integer x = 315
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_connection_zone_v20
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b0w_reg_connection_zone_v20
integer x = 608
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_connection_zone_v20
integer x = 23
integer y = 212
integer width = 2194
integer height = 1412
string dataobject = "b0dw_reg_det_connection_zone_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

event dw_detail::editchanged;call super::editchanged;//Update log
dw_detail.object.updt_user[row] = gs_user_id
dw_detail.object.updtdt[row]    = fdt_get_dbserver_now()
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_connection_zone_v20
integer y = 1664
end type

