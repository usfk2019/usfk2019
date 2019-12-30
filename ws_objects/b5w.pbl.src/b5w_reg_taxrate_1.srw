$PBExportHeader$b5w_reg_taxrate_1.srw
$PBExportComments$[kwon-backgu] TAX 요율관리
forward
global type b5w_reg_taxrate_1 from w_a_reg_m
end type
end forward

global type b5w_reg_taxrate_1 from w_a_reg_m
integer width = 3246
integer height = 1584
end type
global b5w_reg_taxrate_1 b5w_reg_taxrate_1

type variables
String is_format
end variables

on b5w_reg_taxrate_1.create
call super::create
end on

on b5w_reg_taxrate_1.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_taxcod, ls_trcodnm, ls_dctype

//입력 조건 처리 부분
ls_taxcod = Trim(dw_cond.Object.taxcod[1])
//ls_trcodnm = Trim(dw_cond.Object.trcodnm[1])
//ls_dctype = Trim(dw_cond.Object.dctype[1])

//Error 처리부분
If IsNull(ls_taxcod) Then ls_taxcod = ""
//If IsNull(ls_trcodnm) Then ls_trcodnm = ""
//If IsNull(ls_dctype) Then ls_dctype = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_taxcod <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "taxrate.taxcod =  '" + ls_taxcod + "'"
End If

//If ls_dctype <> "" Then
//	If ls_where <> "" Then ls_where += " and "
//	ls_where += "dctype = '" + ls_dctype + "'"
//End If
//
//If ls_trcod <> "" Then
//	If ls_where <> "" Then ls_where += " and "
//	ls_where += "trcod like '" + ls_trcod + "%'"
//End If
//
dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

event ue_extra_save;Long   ll_row, ll_row1,  ll_rowcount
String ls_taxcod, ls_taxcod1, ls_fromdt, ls_fromdt1
String ls_sort
Double ld_taxrate, ld_taxamt, ld_taxtot
Double ld_fromamt, ld_fromamt1, ld_toamt, ld_toamt1

//금액 Error Check 를 위한 Sort: jjuhm 추가
ls_sort = "taxcod, fromdt, fromamt"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

/*****************************************************************
  2019.04.04 적용시작금액(fromamt)
             적용종료금액(toamt)
				 정액(taxamt) 칼럼 삭제에 따른 관련 Check 주석처리
  Modified by Han
*****************************************************************/

//필수항목 Check
//기타 항목 Check
ll_rowcount = dw_detail.RowCount()
For ll_row = 1 To ll_rowcount
	ls_taxcod  = Trim(dw_detail.Object.taxcod  [ll_row])
	ls_fromdt  = String(dw_detail.Object.fromdt[ll_row],'yyyymmdd')

	ld_taxrate = dw_detail.object.taxrate[ll_row]
//	ld_taxamt  = dw_detail.object.taxamt [ll_row]

//	ld_fromamt = dw_detail.object.fromamt[ll_row]
//	ld_toamt   = dw_detail.object.toamt  [ll_row]
	
	If IsNull(ls_taxcod)  Then ls_taxcod  = ""
	If IsNull(ls_fromdt)  Then ls_fromdt  = ""
	If IsNull(ld_taxrate) Then ld_taxrate = 0
//	If IsNull(ld_taxamt) Then ld_taxamt = 0

	If IsNull(ld_fromamt) Then ld_fromamt = 0
//	If IsNull(ld_toamt) Then ld_toamt = 0
	
//	If ld_toamt = 0 Then	ld_toamt = 9999999
	
	If ls_taxcod = "" Then
		f_msg_usr_err(200, Title, "Tax")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("taxcod")
		Return -2
	End If
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "Effective-From")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("fromdt")
		Return -2
	End If
	
	If ld_toamt <> 0 Then
		If ld_fromamt >= ld_toamt Then
			f_msg_usr_err(9000, "입력오류", "적용종료금액이 적용시작금액보다 커야됩니다..")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetColumn("toamt")
			Return -2
		End If
	End If

//	ld_taxtot = ld_taxrate + ld_taxamt
	
//	If ld_taxtot = 0 Then
//		f_msg_usr_err(9000, "입력오류", "세율(%) 또는 정액 둘중 하나는 반드시 입력 하여야 합니다.")
	If ld_taxrate = 0 Then
		f_msg_usr_err(9000, "입력오류", "세율(%)은 반드시 입력 하여야 합니다.")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("taxrate")
		Return -2
	End If
	
	If dw_detail.GetItemStatus(ll_row, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_row] = gs_user_id
		dw_detail.object.updtdt   [ll_row] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id   [ll_row] = gs_pgm_id[gi_open_win_no]		
	End If

//금액 Error Check: jjuhm 추가
	For ll_row1 = dw_detail.RowCount() To ll_row - 1 Step -1
		If ll_row1 = ll_row Then
			Exit
		End If
		ls_taxcod1  = Trim(dw_detail.Object.taxcod[ll_row1])
		ld_fromamt1 = dw_detail.Object.fromamt[ll_row1]
		ls_fromdt1  = String(dw_detail.Object.fromdt[ll_row1],'yyyymmdd')

		If ls_taxcod = ls_taxcod1 And ls_fromdt = ls_fromdt1 Then
//			If ld_toamt > ld_fromamt1 Then
//				f_msg_usr_err(9000, "입력오류", "적용시작금액과 적용종료금액 범위가 중복됩니다.")
//				dw_detail.SetRow(ll_row1)
//				dw_detail.ScrollToRow(ll_row1)
//				dw_detail.SetColumn("fromamt")
//				Return -2
//			End If
		End If 
	Next
Next

Return 0
end event

event ue_extra_insert;//Log 정보
dw_detail.object.crt_user [al_insert_row] = gs_user_id
dw_detail.object.crtdt    [al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt   [al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id   [al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event open;call super::open;String ls_ref_desc

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_enable")

//금액 format 맞춘다.
is_format = fs_get_control("B5", "H200", ls_ref_desc)

// 금액 입력 Column삭제에 따른 전체 주석 처리 2019.04.04 Modified by Han
//If is_format = "1" Then
//	dw_detail.object.taxamt.Format = "#,##0.0"
//	dw_detail.object.fromamt.Format = "#,##0.0"
//	dw_detail.object.toamt.Format = "#,##0.0"
//ElseIf is_format = "2" Then
//	dw_detail.object.taxamt.Format = "#,##0.00"
//	dw_detail.object.fromamt.Format = "#,##0.00"
//	dw_detail.object.toamt.Format = "#,##0.00"
//Else
//	dw_detail.object.taxamt.Format = "#,##0"
//	dw_detail.object.fromamt.Format = "#,##0"
//	dw_detail.object.toamt.Format = "#,##0"
//End If
//
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_taxrate_1
integer y = 52
integer width = 1061
integer height = 116
string dataobject = "b5dw_cnd_reg_taxrate"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_taxrate_1
integer x = 2400
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b5w_reg_taxrate_1
integer x = 2711
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_taxrate_1
integer x = 23
integer y = 4
integer width = 1298
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_taxrate_1
integer y = 1348
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_taxrate_1
integer x = 23
integer y = 1348
end type

type p_save from w_a_reg_m`p_save within b5w_reg_taxrate_1
integer x = 626
integer y = 1348
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_taxrate_1
integer x = 23
integer y = 224
integer width = 3127
integer height = 1084
string dataobject = "b5dw_reg_taxrate_1"
end type

event dw_detail::itemchanged;call super::itemchanged;
Choose Case dwo.name
	Case "taxrate"
		If IsNull(data) or data = "" Then This.Object.taxrate[row] = 0
		   Return 2 
		   
	Case "taxamt"
		If IsNull(data) or data = "" Then This.Object.taxamt[row] = 0
		   Return 2
End Choose

Return 0 
end event

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_taxrate_1
integer x = 1184
integer y = 1348
end type

