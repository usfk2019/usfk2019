$PBExportHeader$b1w_reg_validkey_type_v20.srw
$PBExportComments$[ohj] 인증key type 등록 v20
forward
global type b1w_reg_validkey_type_v20 from w_a_reg_m
end type
end forward

global type b1w_reg_validkey_type_v20 from w_a_reg_m
integer width = 3214
end type
global b1w_reg_validkey_type_v20 b1w_reg_validkey_type_v20

type variables
string is_crt_kind
end variables

on b1w_reg_validkey_type_v20.create
call super::create
end on

on b1w_reg_validkey_type_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_validkey_type
	Desc.	: 	인증Key Type 등록
	Ver.	:	1.0
	Date	: 	2005.04.13
	Programer : Oh Hye Jin
--------------------------------------------------------------------------*/

String ls_temp, ls_ref_desc, ls_result[]

//crt_kind(생성종류) -> 자동auto 가져오기 'A'
ls_temp = fs_get_control("B1","P503", ls_ref_desc)

If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

is_crt_kind = ls_result[2]
end event

event ue_ok();call super::ue_ok;String ls_validkey_type, ls_crt_kind, ls_auth_method, ls_type, ls_where, &
       ls_ref_desc, ls_temp, ls_result[], ls_where_1
Long   ll_row, li_i

ls_validkey_type = fs_snvl(dw_cond.object.validkey_type[1], '')
ls_crt_kind      = fs_snvl(dw_cond.object.crt_kind[1]     , '')
ls_auth_method   = fs_snvl(dw_cond.object.auth_method[1]  , '')
ls_type          = fs_snvl(dw_cond.object.type[1]         , '')

ls_where = ""
If ls_validkey_type <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " validkey_typenm LIKE '" + ls_validkey_type + "%' "
End If

If ls_crt_kind <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " crt_kind = '" + ls_crt_kind + "' "
End If

If ls_auth_method <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " auth_method = '" + ls_auth_method + "' "
End If

If ls_type <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " type = '" + ls_type + "' "
End If

dw_detail.ReSet()
dw_detail.SetRedraw(False)

dw_detail.is_where = ls_where

//Retrieve
ll_row = dw_detail.Retrieve()

dw_detail.SetRedraw(True)

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	p_reset.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
Else
	//dw_cond.Enabled = False
	
End If

Return
end event

event type integer ue_extra_save();call super::ue_extra_save;//Save
String ls_validkey_type, ls_validkey_typenm, ls_crt_kind, ls_validkey_type1, ls_validkey_type2, &
       ls_auth_method, ls_type, ls_prefix, ls_used_level
Long   ll_row, ll_cnt, ll_rows, ll_rows1, ll_rows2, ll_length

//Row 수가 없으면
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

dw_detail.AcceptText()

//If ib_new = False Then Return 0
For ll_row = 1 To ll_rows
	
	//필수 Check
	ls_validkey_type   = fs_snvl(Trim(dw_detail.object.validkey_type[ll_row]), '')
	ls_validkey_typenm = fs_snvl(Trim(dw_detail.object.validkey_typenm[ll_row]), '')
	ls_crt_kind        = fs_snvl(Trim(dw_detail.object.crt_kind[ll_row]), '')
	ls_prefix          = fs_snvl(Trim(dw_detail.object.prefix[ll_row]), '')
	ll_length          = dw_detail.object.length[ll_row]
	ls_auth_method     = fs_snvl(Trim(dw_detail.object.auth_method[ll_row]), '')
	ls_type            = fs_snvl(Trim(dw_detail.object.type[ll_row]), '')
	ls_used_level      = fs_snvl(Trim(dw_detail.object.used_level[ll_row]), '')
	
	//필수 항목 check 
	If ls_validkey_type = "" Then
		f_msg_usr_err(200, Title, "인증Key Type")
		dw_detail.SetColumn("validkey_type")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If
	
	If ls_validkey_typenm = "" Then
		f_msg_usr_err(200, Title, "인증Key Type명")
		dw_detail.SetColumn("validkey_typenm")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If

	If ls_crt_kind = "" Then
		f_msg_usr_err(200, Title, "생성종류")
		dw_detail.SetColumn("crt_kind")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If
	
	If ls_crt_kind = 'AR' Then
		If ll_length <= 0 Then
			f_msg_usr_err(200, Title, "0보다 큰 값을 입력하셔야 합니다!")
			dw_detail.SetColumn("length")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -1
		End If
		
		If LenA(ls_prefix) > ll_length Then
			f_msg_usr_err(200, Title, "길이보다 prefix 길이가 크면 안됩니다.")
			dw_detail.SetColumn("prefix")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -1
		End If
		
	Else
		If ll_length < 0 Then
			f_msg_usr_err(200, Title, "길이는 양수로 입력하셔야 합니다!")
			dw_detail.SetColumn("length")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -1
		End If
		
	End If
	
	If ls_auth_method = "" Then
		f_msg_usr_err(200, Title, "인증방법")
		dw_detail.SetColumn("auth_method")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If

	If ls_type = "" Then
		f_msg_usr_err(200, Title, "Type구분")
		dw_detail.SetColumn("type")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If
	
	If ls_crt_kind = 'R' Then
		If ls_used_level = "" Then
			f_msg_usr_err(200, Title, "사용권한")
			dw_detail.SetColumn("used_level")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -1	
		End If
	End If
Next

For ll_rows1 = 1 To dw_detail.RowCount()

	ls_validkey_type1    = fs_snvl(Trim(dw_detail.object.validkey_type[ll_rows1]), '')
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		
		ls_validkey_type2  = fs_snvl(Trim(dw_detail.object.validkey_type[ll_rows2]), '')
	
		If ls_validkey_type1 = ls_validkey_type2 Then
			f_msg_info(9000, Title, "인증Key Type [ " + ls_validkey_type2 + " ]이(가) 중복됩니다.")
			dw_detail.SetColumn("validkey_type")
			Return -2
		End If
		
	Next
	
	//Update Log
	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rows1] = gs_user_id
		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_rows1] = gs_pgm_id[1]
	End If
	
Next

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]

dw_detail.SetitemStatus(al_insert_row, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("validkey_type")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_validkey_type_v20
integer x = 101
integer y = 76
integer width = 2231
integer height = 176
string dataobject = "b1dw_cnd_reg_validkey_type_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_validkey_type_v20
integer x = 2514
end type

type p_close from w_a_reg_m`p_close within b1w_reg_validkey_type_v20
integer x = 2821
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_validkey_type_v20
integer width = 2377
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_validkey_type_v20
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_validkey_type_v20
end type

type p_save from w_a_reg_m`p_save within b1w_reg_validkey_type_v20
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_validkey_type_v20
integer width = 3122
string dataobject = "b1dw_reg_validkey_type_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::itemchanged;call super::itemchanged;////생성종류에 따라... 길이 색상 변경
//Long ll_null
//String ls_fromdt, ls_prebil_yn, ls_itemcode
//
//SetNull(ll_null)
//If dwo.name = "crt_kind" Then
//	//자동생성(auto)
//	If data = is_crt_kind  Then 
//		This.Object.length.Background.Color = RGB(108, 147, 137)
//		This.Object.length[row].Color = RGB(255, 255, 255)
//			
//	Else
//		This.Object.length[row].Background.Color = RGB(255, 255, 255)
//		This.Object.length[row].Color = RGB(0, 0, 0)	
//		
//	End If
//End If
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_validkey_type_v20
end type

