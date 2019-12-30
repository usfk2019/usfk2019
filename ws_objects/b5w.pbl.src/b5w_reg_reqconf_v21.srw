$PBExportHeader$b5w_reg_reqconf_v21.srw
$PBExportComments$[parkkh] 청구주기v21-사용일자fr/to(후불,선불)추가
forward
global type b5w_reg_reqconf_v21 from w_a_reg_m
end type
end forward

global type b5w_reg_reqconf_v21 from w_a_reg_m
integer width = 3707
integer height = 1832
end type
global b5w_reg_reqconf_v21 b5w_reg_reqconf_v21

forward prototypes
public function integer wfi_screen_mode (boolean ab_edit)
end prototypes

public function integer wfi_screen_mode (boolean ab_edit);//******************************************************
// // [청구주기 Control]
// 화면의 Mode를 재설정한다.(조회만/수정도)
//******************************************************

If ab_edit Then
	//Protect property
	dw_detail.Object.chargedt.Protect = "0"
	dw_detail.Object.reqdt.Protect = "0"
	dw_detail.Object.unitcycle.Protect = "0"
	dw_detail.Object.reqcycle.Protect = "0"
	dw_detail.Object.useddt_fr.Protect = "0"
	dw_detail.Object.useddt_to.Protect = "0"
	dw_detail.Object.pre_useddt_fr.Protect = "0"
	dw_detail.Object.pre_useddt_to.Protect = "0"		
//	//Color property
	dw_detail.Object.chargedt.Color = "16777215"
	dw_detail.Object.reqdt.Color = "16777215"
	dw_detail.Object.unitcycle.Color = "16777215"
	dw_detail.Object.reqcycle.Color = "16777215"
	dw_detail.Object.useddt_fr.Color = "16777215"
	dw_detail.Object.useddt_to.Color = "16777215"
	dw_detail.Object.pre_useddt_fr.Color = "16777215"
	dw_detail.Object.pre_useddt_to.Color = "16777215"			
//	//Background Color property
	dw_detail.Object.chargedt.Background.Color =  rgb(108,147,137) 
	dw_detail.Object.reqdt.Background.Color =  rgb(108,147,137) 
	dw_detail.Object.unitcycle.Background.Color =  rgb(108,147,137) 
	dw_detail.Object.reqcycle.Background.Color = rgb(108,147,137) 
	dw_detail.Object.useddt_fr.Background.Color = rgb(108,147,137)
	dw_detail.Object.useddt_to.Background.Color = rgb(108,147,137)
	dw_detail.Object.pre_useddt_fr.Background.Color = rgb(108,147,137)
	dw_detail.Object.pre_useddt_to.Background.Color = rgb(108,147,137)			
//	//Alignment property
////	dw_detail.Object.reqdt.Alignment = "0~t0"
Else
	//Protect property
	dw_detail.Object.chargedt.Protect = "1"	
	dw_detail.Object.reqdt.Protect = "1"
	dw_detail.Object.unitcycle.Protect = "1"
	dw_detail.Object.reqcycle.Protect = "1"
	dw_detail.Object.useddt_fr.Protect = "1"
	dw_detail.Object.useddt_to.Protect = "1"
	dw_detail.Object.pre_useddt_fr.Protect = "1"
	dw_detail.Object.pre_useddt_to.Protect = "1"			
//	//Color property
	dw_detail.Object.chargedt.Color = "0"
	dw_detail.Object.reqdt.Color = "0"
	dw_detail.Object.unitcycle.Color = "0"
	dw_detail.Object.reqcycle.Color = "0"
	dw_detail.Object.useddt_fr.Color = "0"
	dw_detail.Object.useddt_to.Color = "0"
	dw_detail.Object.pre_useddt_fr.Color = "0"
	dw_detail.Object.pre_useddt_to.Color = "0"			
//	//Background Color property
	dw_detail.Object.chargedt.Background.Color = "15793151"
	dw_detail.Object.reqdt.Background.Color = "15793151"
	dw_detail.Object.unitcycle.Background.Color = "15793151"
	dw_detail.Object.reqcycle.Background.Color = "15793151"
	dw_detail.Object.useddt_fr.Background.Color = "15793151"
	dw_detail.Object.useddt_to.Background.Color = "15793151"
	dw_detail.Object.pre_useddt_fr.Background.Color = "15793151"
	dw_detail.Object.pre_useddt_to.Background.Color = "15793151"	
//	//Alignment property
////	dw_detail.Object.reqdt.Alignment = "2~t2"
End If

Return 0

end function

on b5w_reg_reqconf_v21.create
call super::create
end on

on b5w_reg_reqconf_v21.destroy
call super::destroy
end on

event type integer ue_extra_save();Long ll_rows, ll_reqcycle
String ls_chargedt, ls_desc, ls_reqdt, ls_inputclosedt, ls_date
String ls_unitcycle, ls_useddt_fr, ls_useddt_to,ls_pre_useddt_fr, ls_pre_useddt_to
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
	ls_unitcycle = dw_detail.object.unitcycle[li_cnt]
	ll_reqcycle = dw_detail.object.reqcycle[li_cnt]
	ls_useddt_fr = String(dw_detail.Object.useddt_fr[li_cnt], "yyyy-mm-dd")
	ls_useddt_to = String(dw_detail.Object.useddt_to[li_cnt], "yyyy-mm-dd")
	ls_pre_useddt_fr = String(dw_detail.Object.pre_useddt_fr[li_cnt], "yyyy-mm-dd")
	ls_pre_useddt_to = String(dw_detail.Object.pre_useddt_to[li_cnt], "yyyy-mm-dd")
	
	If IsNull(ls_chargedt) Then ls_chargedt = ""
	If IsNull(ls_desc) Then ls_desc = ""
	If IsNull(ls_reqdt) Then ls_reqdt = ""
	If IsNull(ls_inputclosedt) Then ls_inputclosedt = ""
	If IsNull(ls_unitcycle) Then ls_unitcycle = ""
	If IsNull(ll_reqcycle) Then ll_reqcycle = 0
	If IsNull(ls_useddt_fr) Then ls_useddt_fr = ""	
	If IsNull(ls_useddt_to) Then ls_useddt_to = ""	
	If IsNull(ls_pre_useddt_fr) Then ls_pre_useddt_fr = ""	
	If IsNull(ls_pre_useddt_to) Then ls_pre_useddt_to = ""		
		
	ls_date = MidA(ls_reqdt, 1, 4) + "-" + MidA(ls_reqdt, 6, 2) + "-" + MidA(ls_reqdt, 9, 2)
	
	If ls_chargedt = "" Then
		f_msg_usr_err(200, Title, "Billing Cycle (Due Date)")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("chargedt")
		dw_detail.SetFocus()
		Return - 2
	End If
	
	If ls_desc = "" Then
		f_msg_usr_err(200, Title, "Billing Cycle (Due Date)")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("description")
		Return -2
	End If
	
	ls_date = MidA(ls_inputclosedt, 1, 4) + "-" + MidA(ls_inputclosedt, 6, 2) + "-" + MidA(ls_inputclosedt, 9, 2)
	
	If ls_inputclosedt = "" Then
		f_msg_usr_err(200, Title, "전월입금마감일자")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("inputclosedt")
		Return -2
	Else
		If Not IsDate(ls_date) Then
			f_msg_usr_err(210, Title, "전월입금마감일자")
			dw_detail.SetRow(li_cnt)
			dw_detail.SetColumn("inputclosedt")
			Return -2
		End If
	End If
	
	If ls_reqdt = "" Then
		f_msg_usr_err(200, Title, "청구기준일")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("reqdt")
		Return -2
	Else
		If Not IsDate(ls_date) Then
			f_msg_usr_err(210, Title, "청구기준일")
			dw_detail.SetRow(li_cnt)
			dw_detail.SetColumn("reqdt")
			Return -2
		End If
	End If
	
	If ls_unitcycle = "" Then
		f_msg_usr_err(200, Title, "청구주기단위")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("unitcycle")
		Return -2
	End If
	
	If ll_reqcycle <= 0 Then
		f_msg_usr_err(200, Title, "청구주기수")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("reqcycle")
		Return -2
	End If

	If ls_useddt_fr = "" Then
		f_msg_usr_err(200, Title, "후불사용기간(From)")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("useddt_fr")
		Return -2
	End If

	If ls_useddt_to = "" Then
		f_msg_usr_err(200, Title, "후불사용기간(To)")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("useddt_to")
		Return -2
	End If
	
	If ls_pre_useddt_fr = "" Then
		f_msg_usr_err(200, Title, "선불사용기간(From)")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("pre_useddt_fr")
		Return -2
	End If

	If ls_pre_useddt_to = "" Then
		f_msg_usr_err(200, Title, "선불사용기간(To)")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("pre_useddt_to")
		Return -2
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
String ls_chargedt, ls_bill_group

//입력 조건 처리 부분
//청구주기
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
ls_bill_group = Trim(dw_cond.Object.bill_group[1])

//Error 처리부분
If IsNull(ls_chargedt) Then ls_chargedt = ""
If IsNull(ls_bill_group) Then ls_bill_group = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "chargedt = '" + ls_chargedt + "'"
End If

If ls_bill_group <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "bill_group = '" + ls_bill_group + "'"
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

dw_cond.SetFocus()

//This.TriggerEvent("ue_ok")

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

event resize;call super::resize;////2000-06-28 by kEnn
////Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
////
//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
//	dw_detail.Height = 0
//   p_close.Y   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//	
//Else
//	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
//   p_close.Y   = newheight - iu_cust_w_resize.ii_button_space
//	
//End If
//
///*
//If newwidth < dw_detail.X  Then
//	dw_detail.Width = 0
//Else
//	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
//End If
//*/
//
//SetRedraw(True)
//
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqconf_v21
integer x = 59
integer y = 96
integer width = 2423
integer height = 144
string dataobject = "b5d_cnd_reg_reqconf_v21"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqconf_v21
integer x = 2894
integer y = 84
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqconf_v21
integer x = 3205
integer y = 84
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqconf_v21
integer y = 40
integer width = 2569
integer height = 228
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqconf_v21
integer x = 384
integer y = 1540
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqconf_v21
integer x = 64
integer y = 1540
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqconf_v21
integer x = 704
integer y = 1540
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqconf_v21
integer x = 37
integer y = 296
integer width = 3589
integer height = 1208
string dataobject = "b5dw_reg_reqconf_v21"
end type

event dw_detail::retrieveend;//Override
p_ok.TriggerEvent("ue_disable")

//p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

dw_cond.Enabled = False

end event

event dw_detail::itemchanged;call super::itemchanged;//String ls_reqdt, ls_reqterm, ls_date
//Long   ll_row, ll_reqcycle
//Int    li_cnt
//String ls_unitcycle
//Date     ld_reqdt,ld_use_fr,ld_use_to
//
//ll_row = dw_detail.RowCount()
//
//Choose Case dwo.Name
//	Case "reqdt"
//		ld_reqdt = Date(object.reqdt[row])
//		ls_reqdt =String(Object.reqdt[row],"yyyymmdd")
//		ls_date = String(Object.reqdt[row],"yyyy-mm-dd")
//
//		If Not IsDate(ls_date) Then
//			setrow(row)
//			Object.useddt_fr[row] = ""
//			Object.useddt_to[row] = ""
//		Else
//			ls_unitcycle = object.unitcycle[row]
//			ll_reqcycle = object.reqcycle[row]
//			IF ls_unitcycle = 'M' Then
//				//사용기간 시작일
//				ld_use_fr = fd_month_pre(ld_reqdt,ll_reqcycle)
//			ElseIF ls_unitcycle = 'D' Then
//				//사용기간 시작일
//				ld_use_fr = relativedate(ld_reqdt, -ll_reqcycle)
//			End IF
//			//사용기간 종료일
//			ld_use_to = relativedate(ld_reqdt, -1)	
//			
//			setrow(row)
//			Object.useddt_fr[row] = datetime(ld_use_fr)
//			Object.useddt_to[row] = datetime(ld_use_to)
//		End If
//		
//	Case "unitcycle"	
//		ld_reqdt = Date(object.reqdt[row])
//		ls_unitcycle = object.unitcycle[row]
//		ll_reqcycle = object.reqcycle[row]
//		IF ls_unitcycle = 'M' Then
//			//사용기간 시작일
//			ld_use_fr = fd_month_pre(ld_reqdt,ll_reqcycle)
//		ElseIF ls_unitcycle = 'D' Then
//			//사용기간 시작일
//			ld_use_fr = relativedate(ld_reqdt, -ll_reqcycle)
//		End IF
//		//사용기간 종료일
//		ld_use_to = relativedate(ld_reqdt, -1)	
//		
//		setrow(row)
//		Object.useddt_fr[row] = datetime(ld_use_fr)
//		Object.useddt_to[row] = datetime(ld_use_to)
//
//	Case "reqcycle"	
//		ld_reqdt = Date(object.reqdt[row])
//		ls_unitcycle = object.unitcycle[row]
//		ll_reqcycle = object.reqcycle[row]
//		IF ls_unitcycle = 'M' Then
//			//사용기간 시작일
//			ld_use_fr = fd_month_pre(ld_reqdt,ll_reqcycle)
//		ElseIF ls_unitcycle = 'D' Then
//			//사용기간 시작일
//			ld_use_fr = relativedate(ld_reqdt, -ll_reqcycle)
//		End IF
//		//사용기간 종료일
//		ld_use_to = relativedate(ld_reqdt, -1)	
//		
//		setrow(row)
//		Object.useddt_fr[row] = datetime(ld_use_fr)
//		Object.useddt_to[row] = datetime(ld_use_to)
//
//End Choose
//
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqconf_v21
integer x = 2130
integer y = 1540
end type

