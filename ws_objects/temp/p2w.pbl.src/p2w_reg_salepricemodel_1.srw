$PBExportHeader$p2w_reg_salepricemodel_1.srw
$PBExportComments$[chooys] 카드모델관리 Window
forward
global type p2w_reg_salepricemodel_1 from w_a_reg_s
end type
end forward

global type p2w_reg_salepricemodel_1 from w_a_reg_s
integer width = 2958
end type
global p2w_reg_salepricemodel_1 p2w_reg_salepricemodel_1

on p2w_reg_salepricemodel_1.create
call super::create
end on

on p2w_reg_salepricemodel_1.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_modelnm

ls_modelnm	= Trim( dw_cond.Object.modelnm[1] )

IF( IsNull(ls_modelnm) ) THEN ls_modelnm = ""

//Dynamic SQL
IF ls_modelnm <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(pricemodelnm) LIKE UPPER('%" + ls_modelnm + "%')"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.modelnm[1] = ""

dw_cond.SetColumn("modelnm")

p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_pricemodel, ls_pricemodelnm, ls_price, ls_svctype, ls_extdays
String   ls_sale_item, ls_recharge_item

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_pricemodel	= Trim(dw_detail.Object.pricemodel[ll_rowcnt])
	IF IsNull(ls_pricemodel) THEN ls_pricemodel = ""
	
	ls_pricemodelnm	= Trim(dw_detail.Object.pricemodelnm[ll_rowcnt])
	IF IsNull(ls_pricemodelnm) THEN ls_pricemodelnm = ""
	
	ls_price	= String(dw_detail.Object.price[ll_rowcnt])
	IF IsNull(ls_price) THEN ls_price = ""
	
	ls_svctype	= Trim(dw_detail.Object.svctype[ll_rowcnt])
	IF IsNull(ls_svctype) THEN ls_svctype = ""
	
	ls_extdays	= String(dw_detail.Object.extdays[ll_rowcnt])
	IF IsNull(ls_extdays) THEN ls_extdays = ""
	
	ls_sale_item	= String(dw_detail.Object.sale_item[ll_rowcnt])
	IF IsNull(ls_sale_item) THEN ls_sale_item = ""
	
	ls_recharge_item	= String(dw_detail.Object.recharge_item[ll_rowcnt])
	IF IsNull(ls_recharge_item) THEN ls_recharge_item = ""
	
	IF ls_pricemodel = "" THEN
		f_msg_usr_err(200, Title, "모델")
		dw_detail.setColumn("pricemodel")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_pricemodelnm = "" THEN
		f_msg_usr_err(200, Title, "모델 명")
		dw_detail.setColumn("pricemodelnm")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_price = "" THEN
		f_msg_usr_err(200, Title, "카드 금액")
		dw_detail.setColumn("price")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_svctype = "" THEN
		f_msg_usr_err(200, Title, "서비스유형")
		dw_detail.setColumn("svctype")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_extdays = "" THEN
		f_msg_usr_err(200, Title, "연장일수")
		dw_detail.setColumn("extdays")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_sale_item = "" THEN
		f_msg_usr_err(200, Title, "판매품목")
		dw_detail.setColumn("sale_item")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_recharge_item = "" THEN
		f_msg_usr_err(200, Title, "충전품목")
		dw_detail.setColumn("recharge_item")
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

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insertion Log
dw_detail.Object.crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row]	= gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

RETURN 0
end event

type dw_cond from w_a_reg_s`dw_cond within p2w_reg_salepricemodel_1
integer width = 1083
integer height = 112
string dataobject = "p2dw_cnd_reg_salepricemodel_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_s`p_ok within p2w_reg_salepricemodel_1
integer x = 1239
integer y = 60
end type

type p_close from w_a_reg_s`p_close within p2w_reg_salepricemodel_1
integer x = 1541
integer y = 60
end type

type gb_cond from w_a_reg_s`gb_cond within p2w_reg_salepricemodel_1
integer x = 23
integer width = 1129
integer height = 188
end type

type dw_detail from w_a_reg_s`dw_detail within p2w_reg_salepricemodel_1
integer x = 27
integer y = 216
integer width = 2862
integer height = 1380
string dataobject = "p2dw_reg_salepricemodel_1"
end type

type p_delete from w_a_reg_s`p_delete within p2w_reg_salepricemodel_1
end type

type p_insert from w_a_reg_s`p_insert within p2w_reg_salepricemodel_1
end type

type p_save from w_a_reg_s`p_save within p2w_reg_salepricemodel_1
end type

type p_reset from w_a_reg_s`p_reset within p2w_reg_salepricemodel_1
end type

