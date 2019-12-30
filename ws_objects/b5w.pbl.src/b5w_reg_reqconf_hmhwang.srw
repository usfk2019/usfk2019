$PBExportHeader$b5w_reg_reqconf_hmhwang.srw
$PBExportComments$*[kwon] 청구주기 Control
forward
global type b5w_reg_reqconf_hmhwang from w_a_reg_m
end type
end forward

global type b5w_reg_reqconf_hmhwang from w_a_reg_m
integer width = 3598
integer height = 1200
end type
global b5w_reg_reqconf_hmhwang b5w_reg_reqconf_hmhwang

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
	//Color property
	dw_detail.Object.reqdt.Color = "16777215"
	//Background Color property
	dw_detail.Object.reqdt.Background.Color = "8421376"
	//Alignment property
//	dw_detail.Object.reqdt.Alignment = "0~t0"
Else
	//Protect property
	dw_detail.Object.reqdt.Protect = "1"
	//Color property
	dw_detail.Object.reqdt.Color = "0"
	//Background Color property
	dw_detail.Object.reqdt.Background.Color = "15793151"
	//Alignment property
//	dw_detail.Object.reqdt.Alignment = "2~t2"
End If

Return 0

end function

on b5w_reg_reqconf_hmhwang.create
call super::create
end on

on b5w_reg_reqconf_hmhwang.destroy
call super::destroy
end on

event ue_extra_save;Long ll_rows
String ls_reqdt
String ls_inputclosedt
String ls_date

//1.필수입력사항 확인***********************************
//  [청구주기]익월시작일자
//  입력사항이 NotIsValid ==> Null
//  [작업로그]당월청구마감일자/당월청구마감자/당월TAX계산일자/당월연체계산일자/당월할인작업일자
//            History이관일자/전월입금마감일자/전월연체마감일자

//처리 대상 자료가 존재하는지 확인
ll_rows = dw_detail.RowCount()
If ll_rows <= 0 Then Return 0

ls_reqdt = String(dw_detail.Object.reqdt[1],"yyyy-mm-dd")
ls_inputclosedt = String(dw_detail.Object.inputclosedt[1],"yyyy-mm-dd")

If IsNull(ls_reqdt) Then ls_reqdt = ""
If IsNull(ls_inputclosedt) Then ls_inputclosedt = ""

ls_date = MidA(ls_reqdt, 1, 4) + "-" + MidA(ls_reqdt, 6, 2) + "-" + MidA(ls_reqdt, 9, 2)

If ls_reqdt = "" Then
	f_msg_usr_err(200, Title, "[청구주기]익월시작일자")
	dw_detail.SetColumn("reqdt")
	Return -2
Else
	If Not IsDate(ls_date) Then
		f_msg_usr_err(210, Title, "[청구주기]익월시작일자")
		dw_detail.SetColumn("reqdt")
		Return -2
	End If
End If

ls_date = MidA(ls_inputclosedt, 1, 4) + "-" + MidA(ls_inputclosedt, 6, 2) + "-" + MidA(ls_inputclosedt, 9, 2)
If ls_inputclosedt <> "" Then
	If Not IsDate(ls_date) Then
		f_msg_usr_err(210, Title, "전월입금마감일자")
		dw_detail.SetColumn("inputclosedt")
		Return -2
	End If
End If

Return 0

end event

event ue_ok;call super::ue_ok;Long ll_rows
String ls_where
String ls_chargedt

//입력 조건 처리 부분
//청구주기
ls_chargedt = Trim(dw_cond.Object.chargedt[1])

//Error 처리부분
If IsNull(ls_chargedt) Then ls_chargedt = ""

If ls_chargedt = "" Then
	f_msg_usr_err(200, Title, "Billing Cycle date")
	dw_cond.SetColumn("chargedt")
	Return
End If

//Dynamic SQL 처리부분
ls_where = ""
If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "chargedt = '" + ls_chargedt + "'"
End If

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
	p_insert.TriggerEvent("ue_disable")

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

dw_cond.SetFocus()

end event

event ue_extra_insert;String ls_chargedt

//청구주기
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
dw_detail.Object.chargedt[1] = ls_chargedt

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqconf_hmhwang
integer y = 52
integer width = 1403
integer height = 144
string dataobject = "b5d_cnd_reg_reqconf"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqconf_hmhwang
integer x = 1531
integer y = 32
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqconf_hmhwang
integer x = 1838
integer y = 32
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqconf_hmhwang
integer y = 8
integer width = 1463
integer height = 208
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqconf_hmhwang
integer x = 338
integer y = 864
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqconf_hmhwang
integer x = 101
integer y = 864
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqconf_hmhwang
integer x = 576
integer y = 864
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqconf_hmhwang
integer y = 224
integer width = 3525
integer height = 556
string dataobject = "b5d_reg_reqconf"
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

event dw_detail::itemchanged;call super::itemchanged;String ls_reqdt, ls_reqterm
String ls_date

Choose Case dwo.Name
	Case "reqdt"
		
		ls_reqdt =String(Object.reqdt[row],"yyyymmdd")
	   ls_date = String(Object.reqdt[row],"yyyy-mm-dd")
		If Not IsDate(ls_date) Then
			Object.dw_opendt_t.Text = ""
			Object.dw_enddt_t.Text = ""
			Object.iw_enddt_t.Text = ""
		Else
			ls_reqterm = b5fs_reqterm("", ls_reqdt)
			
			Object.dw_opendt_t.Text = String(MidA(ls_reqterm, 1, 8), "@@@@-@@-@@")
			Object.dw_enddt_t.Text = String(MidA(ls_reqterm, 9, 8), "@@@@-@@-@@")
			Object.iw_enddt_t.Text = String(MidA(ls_reqterm, 25, 8), "@@@@-@@-@@")
		End If
End Choose

end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqconf_hmhwang
integer x = 1202
integer y = 864
end type

