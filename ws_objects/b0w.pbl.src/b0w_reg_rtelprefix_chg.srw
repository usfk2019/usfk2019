$PBExportHeader$b0w_reg_rtelprefix_chg.srw
$PBExportComments$[kjm] 착신지 번호 보정 등록
forward
global type b0w_reg_rtelprefix_chg from w_a_reg_m
end type
end forward

global type b0w_reg_rtelprefix_chg from w_a_reg_m
integer width = 2281
end type
global b0w_reg_rtelprefix_chg b0w_reg_rtelprefix_chg

on b0w_reg_rtelprefix_chg.create
call super::create
end on

on b0w_reg_rtelprefix_chg.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b0w_reg_rtelprefix_chg
	Desc. : 착신지번호보정등록
	Date : 2004.08.12
	Auth : Kwon Jung Min
------------------------------------------------------------------------*/

p_insert.TriggerEvent("ue_enable")
end event

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_rtelprefix

ls_rtelprefix	= Trim( dw_cond.Object.rtelprefix[1] )

IF( IsNull(ls_rtelprefix) ) THEN ls_rtelprefix = ""

//Dynamic SQL
IF ls_rtelprefix <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "RTELPREFIX LIKE '%" + ls_rtelprefix + "%'"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, This.Title, "")
END IF

p_reset.TriggerEvent("ue_enable")
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0
end event

event type integer ue_save();String ls_priceplan
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End If

//cb_load.Enabled = False
Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_tot_row
String ls_rtelprefix,	ls_fromdt,	ls_todt,		ls_chgvalue

// 착신지Prefix별 적용시작일, 적용종료일 check variable
Long ll_chk_row1, ll_chk_row2  
String ls_rtelprefix1,	ls_rtelprefix2,	ls_fromdt1,	ls_fromdt2,	ls_todt1,	ls_todt2

ll_tot_row = dw_detail.RowCount()

// 필수 입력 사항 check -> 착신지Prefix, 적용시작일, 변경Prefix
FOR ll_row = 1 TO ll_tot_row
	ls_rtelprefix = dw_detail.Object.rtelprefix[ll_row]
	ls_fromdt = String(dw_detail.Object.fromdt[ll_row],'yyyymmdd')
	ls_todt = String(dw_detail.Object.todt[ll_row],'yyyymmdd')
	ls_chgvalue = dw_detail.Object.chgvalue[ll_row]
	IF IsNull(ls_rtelprefix) THEN ls_rtelprefix = ""
	IF IsNull(ls_fromdt) THEN ls_fromdt = ""	
	IF IsNull(ls_todt) THEN ls_todt = ""	
	IF IsNull(ls_chgvalue) THEN ls_chgvalue = ""		
	
	If ls_rtelprefix = "" Then
		f_msg_usr_err(200, Title, "착신지Prefix")
		dw_detail.SetColumn("rtelprefix")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If

	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If

	If ls_chgvalue = "" Then
		f_msg_usr_err(200, Title, "변경Prefix")
		dw_detail.SetColumn("chgvalue")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If
	
//적용종료일 체크
	If ls_todt <> "" Then
		If ls_fromdt > ls_todt Then
			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
			dw_detail.setColumn("todt")
			dw_detail.setRow(ll_row)
			dw_detail.scrollToRow(ll_row)
			dw_detail.SetRedraw(True)
			Return -2
		End If
	End If		
NEXT

// 착신지Prefix별 적용시작일 적용종료일 겹치지 않도록 check
FOR ll_chk_row1 = 1 TO dw_detail.RowCount()
	ls_rtelprefix1= dw_detail.Object.rtelprefix[ll_chk_row1]
	ls_fromdt1 = String(dw_detail.Object.fromdt[ll_chk_row1],'yyyymmdd')
	ls_todt1 = String(dw_detail.Object.todt[ll_chk_row1],'yyyymmdd')
	
	IF IsNull(ls_todt1) THEN ls_todt1 = ""
	
	FOR ll_chk_row2 = dw_detail.RowCount() TO ll_chk_row1 -1 Step -1
		IF ll_chk_row1 = ll_chk_row2 THEN Exit
		
		ls_rtelprefix2 = dw_detail.Object.rtelprefix[ll_chk_row2]
		ls_fromdt2 = String(dw_detail.Object.fromdt[ll_chk_row2],'yyyymmdd')
		ls_todt2 = String(dw_detail.Object.todt[ll_chk_row2],'yyyymmdd')
		
		IF IsNull(ls_todt2) THEN ls_todt2 = ""		
		
		IF ls_rtelprefix1 = ls_rtelprefix2 THEN
			
			If (ls_todt1 >= ls_fromdt2 AND ls_todt1 <> "") OR (ls_todt2 >= ls_fromdt2 AND ls_todt2 <> "")Then
				f_msg_info(9000, Title, "같은 착신지Prefix[ " + ls_rtelprefix1 + " ]로 적용기간이 중복됩니다.")				
				Return -2	
			END IF
		END IF
		
		
	NEXT
	//Update Log
	If dw_detail.GetItemStatus(ll_chk_row1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_chk_row1] = gs_user_id
		dw_detail.object.updtdt[ll_chk_row1] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_chk_row1] = gs_pgm_id[1]
	End If
NEXT

Return 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_rtelprefix_chg
integer x = 87
integer y = 88
integer width = 1248
integer height = 112
integer taborder = 10
string dataobject = "b0dw_cnd_rtelprefix_chg"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_rtelprefix_chg
integer x = 1431
integer y = 72
end type

type p_close from w_a_reg_m`p_close within b0w_reg_rtelprefix_chg
integer x = 1737
integer y = 72
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_rtelprefix_chg
integer width = 1344
integer height = 220
integer taborder = 30
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_rtelprefix_chg
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_rtelprefix_chg
end type

type p_save from w_a_reg_m`p_save within b0w_reg_rtelprefix_chg
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_rtelprefix_chg
integer y = 240
integer width = 2194
integer height = 1336
integer taborder = 20
string dataobject = "b0dw_reg_rtelprefix_chg"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_rtelprefix_chg
end type

