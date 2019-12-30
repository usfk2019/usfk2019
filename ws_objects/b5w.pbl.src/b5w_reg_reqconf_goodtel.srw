$PBExportHeader$b5w_reg_reqconf_goodtel.srw
$PBExportComments$[parkkh] 청구주기 Control-goodtel용(workdays추가)
forward
global type b5w_reg_reqconf_goodtel from w_a_reg_m
end type
end forward

global type b5w_reg_reqconf_goodtel from w_a_reg_m
integer width = 3314
integer height = 1216
end type
global b5w_reg_reqconf_goodtel b5w_reg_reqconf_goodtel

forward prototypes
public function integer wfi_screen_mode (boolean ab_edit)
end prototypes

public function integer wfi_screen_mode (boolean ab_edit);//******************************************************
// // [청구주기 Control]
// 화면의 Mode를 재설정한다.(조회만/수정도)
//******************************************************

If ab_edit Then
	//Protect property
	dw_detail.Object.reqdt.Protect = "0"
//	//Color property
//	dw_detail.Object.reqdt.Color = "16777215"
//	//Background Color property
//	dw_detail.Object.reqdt.Background.Color = "8421376"
//	//Alignment property
////	dw_detail.Object.reqdt.Alignment = "0~t0"
Else
	//Protect property
	dw_detail.Object.reqdt.Protect = "1"
//	//Color property
//	dw_detail.Object.reqdt.Color = "0"
//	//Background Color property
//	dw_detail.Object.reqdt.Background.Color = "15793151"
//	//Alignment property
////	dw_detail.Object.reqdt.Alignment = "2~t2"
End If

Return 0

end function

on b5w_reg_reqconf_goodtel.create
call super::create
end on

on b5w_reg_reqconf_goodtel.destroy
call super::destroy
end on

event type integer ue_extra_save();Long ll_rows
String ls_chargedt, ls_desc, ls_reqdt, ls_inputclosedt, ls_date
Int li_cnt

//1.필수입력사항 확인***********************************
//  [청구주기]익월시작일자
//  입력사항이 NotIsValid ==> Null
//  [작업로그]당월청구마감일자/당월청구마감자/당월TAX계산일자/당월연체계산일자/당월할인작업일자
//            History이관일자/전월입금마감일자/전월연체마감일자

//처리 대상 자료가 존재하는지 확인
ll_rows = dw_detail.RowCount()
If ll_rows <= 0 Then Return 0

For li_cnt = 1 to ll_rows
	ls_chargedt = dw_detail.object.chargedt[li_cnt]
	ls_desc     = dw_detail.object.description[li_cnt]
	ls_reqdt = String(dw_detail.Object.reqdt[li_cnt], "yyyy-mm-dd")
	ls_inputclosedt = String(dw_detail.Object.inputclosedt[li_cnt], "yyyy-mm-dd")
	
	If IsNull(ls_chargedt) Then ls_chargedt = ""
	If IsNull(ls_desc) Then ls_desc = ""
	If IsNull(ls_reqdt) Then ls_reqdt = ""
	If IsNull(ls_inputclosedt) Then ls_inputclosedt = ""
	
	ls_date = MidA(ls_reqdt, 1, 4) + "-" + MidA(ls_reqdt, 6, 2) + "-" + MidA(ls_reqdt, 9, 2)
	
	If ls_chargedt = "" Then
		f_msg_usr_err(200, Title, "[Billing Cycle]Due Date")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("chargedt")
		dw_detail.SetFocus()
		Return - 2
	End If
	
	If ls_desc = "" Then
		f_msg_usr_err(200, Title, "[Billing Cycle]Due Date")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("description")
		Return -2
	End If
	
	If ls_reqdt = "" Then
		f_msg_usr_err(200, Title, "[Billing Cycle]Starting Date Of Next Invoice")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("reqdt")
		Return -2
	Else
		If Not IsDate(ls_date) Then
			f_msg_usr_err(210, Title, "[Billing Cycle]Starting Date Of Next Invoice")
			dw_detail.SetRow(li_cnt)
			dw_detail.SetColumn("reqdt")
			Return -2
		End If
	End If
	
	ls_date = MidA(ls_inputclosedt, 1, 4) + "-" + MidA(ls_inputclosedt, 6, 2) + "-" + MidA(ls_inputclosedt, 9, 2)
	
	If ls_inputclosedt = "" Then
		f_msg_usr_err(200, Title, "[Billing Cycle]Prev. Due Date")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("inputclosedt")
		Return -2
	Else
		If Not IsDate(ls_date) Then
			f_msg_usr_err(210, Title, "Prev. Due Date")
			dw_detail.SetRow(li_cnt)
			dw_detail.SetColumn("inputclosedt")
			Return -2
		End If
	End If
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(li_cnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[li_cnt]	= gs_user_id
		dw_detail.Object.updtdt[li_cnt]		= fdt_get_dbserver_now()
		dw_detail.Object.pgm_id[li_cnt]		= gs_pgm_id[gi_open_win_no]
	END IF
Next

Return 0

end event

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_chargedt

//입력 조건 처리 부분
//청구주기
//ls_chargedt = Trim(dw_cond.Object.chargedt[1])

//Error 처리부분
//If IsNull(ls_chargedt) Then ls_chargedt = ""

//If ls_chargedt = "" Then
//	f_msg_usr_err(200, Title, "청구주기")
//	dw_cond.SetColumn("chargedt")
//	Return
//End If
//
//Dynamic SQL 처리부분

//If ls_chargedt <> "" Then
//	If ls_where <> "" Then ls_where += " and "
//	ls_where += "chargedt = '" + ls_chargedt + "'"
//End If

ls_where = ""
dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
dw_detail.SetRedraw(False)

ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	
	f_msg_info(1000, Title, "")
	p_insert.TriggerEvent("ue_enable")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
Else
	
	dwObject ldwo_reqdt
	String ls_reqdt

	ldwo_reqdt = dw_detail.Object.reqdt
	ls_reqdt = string(dw_detail.Object.reqdt[1],'yyyymmdd')
	dw_detail.Trigger Event Itemchanged(1, ldwo_reqdt, ls_reqdt)
	p_insert.TriggerEvent("ue_enable")

End If

dw_detail.SetRedraw(True)
end event

event open;call super::open;String ls_module, ls_ref_no, ls_ref_desc
String ls_edit

dw_detail.SetRowfocusIndicator(Off!)

//SYSCTL1T의 청구주기 Control Read
ls_module = "B5"
ls_ref_no = "C101"
ls_ref_desc = ""
ls_edit = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)

If Upper(Trim(ls_edit)) = "Y" Then
	wfi_screen_mode(True)
Else
	wfi_screen_mode(False)
End If

//dw_cond.SetFocus()

This.TriggerEvent("ue_ok")

end event

event type integer ue_save();Constant Int LI_ERROR = -1

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

This.TriggerEvent("ue_ok")

Return 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.RowCount()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row] = gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

RETURN 0
end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_close.Y   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_close.Y   = newheight - iu_cust_w_resize.ii_button_space
	
End If

/*
If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If
*/

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqconf_goodtel
boolean visible = false
integer y = -32768
integer width = 1230
integer height = 144
string dataobject = "b5d_cnd_reg_reqconf"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqconf_goodtel
boolean visible = false
integer x = 1280
integer y = 32
boolean enabled = false
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqconf_goodtel
integer x = 1207
integer y = 916
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqconf_goodtel
boolean visible = false
integer x = 503
integer y = 1036
integer height = 152
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqconf_goodtel
integer x = 384
integer y = 916
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqconf_goodtel
integer x = 64
integer y = 916
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqconf_goodtel
integer x = 704
integer y = 916
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqconf_goodtel
integer x = 50
integer y = 52
integer width = 3163
integer height = 820
string dataobject = "b5d_reg_reqconf_goodtel"
boolean vscrollbar = false
end type

event dw_detail::retrieveend;//Override
p_ok.TriggerEvent("ue_disable")

//p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

dw_cond.Enabled = False

end event

event dw_detail::itemchanged;call super::itemchanged;String ls_reqdt, ls_reqterm, ls_date
Long   ll_row
Int    li_cnt

ll_row = dw_detail.RowCount()

Choose Case dwo.Name
	Case "reqdt"
		For li_cnt = 1 to ll_row
			ls_reqdt =String(Object.reqdt[li_cnt],"yyyymmdd")
			ls_date = String(Object.reqdt[li_cnt],"yyyy-mm-dd")

			If Not IsDate(ls_date) Then
				setrow(li_cnt)
				Object.opendt[li_cnt] = ""
				Object.enddt[li_cnt] = ""
				Object.salesdt[li_cnt] = ""
			Else
				ls_reqterm = b5fs_reqterm("", ls_reqdt)
				setrow(li_cnt)
				Object.opendt[li_cnt] = String(MidA(ls_reqterm, 1, 8), "@@@@-@@-@@")
				Object.enddt[li_cnt] = String(MidA(ls_reqterm, 9, 8), "@@@@-@@-@@")
				Object.salesdt[li_cnt] = String(MidA(ls_reqterm, 1, 8), "@@@@-@@-@@")
			  	This.SetitemStatus(li_cnt, "opendt", Primary!, NotModified!)   //수정 안되었다고 인식.
			  	This.SetitemStatus(li_cnt, "enddt", Primary!, NotModified!)   //수정 안되었다고 인식.
			  	This.SetitemStatus(li_cnt, "salesdt", Primary!, NotModified!)   //수정 안되었다고 인식.				  
			End If
		Next
End Choose

end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqconf_goodtel
boolean visible = false
integer y = 876
end type

