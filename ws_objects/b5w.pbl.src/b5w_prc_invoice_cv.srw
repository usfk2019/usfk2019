$PBExportHeader$b5w_prc_invoice_cv.srw
$PBExportComments$[cuesee] 청구서 대행 발송
forward
global type b5w_prc_invoice_cv from w_a_prc
end type
end forward

global type b5w_prc_invoice_cv from w_a_prc
integer height = 1252
end type
global b5w_prc_invoice_cv b5w_prc_invoice_cv

type variables
String is_chargedt, is_trdt, is_cms_yn, is_giro_yn, is_giro_file, is_cms_file
end variables

on b5w_prc_invoice_cv.create
call super::create
end on

on b5w_prc_invoice_cv.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b5_prc_invoice_cv
	Desc.: 청구내역을 청구서 발행 업체에 TXT 파일로 전해줌
	Date : 2003.09.30
	Auth.: Choi Bo Ra(ceusee)
-------------------------------------------------------------------------*/
String ls_ref_desc
is_giro_file = fs_get_control("B5", "P100", ls_ref_desc)
is_cms_file = fs_get_control("B5", "P101", ls_ref_desc)
end event

event type integer ue_input();call super::ue_input;//해당 조건을 가져옴 
String ls_chargedt, ls_trdt, ls_cms_yn, ls_card_yn

is_chargedt = Trim(dw_input.object.chargedt[1])
is_trdt = String(dw_input.object.trdt[1], 'yyyymmdd')
is_cms_yn = Trim(dw_input.object.cms[1])
is_giro_yn = Trim(dw_input.object.giro[1])

If IsNull(is_chargedt) Then is_chargedt = ""
If IsNull(is_trdt) Then is_trdt = ""

If is_chargedt = "" Then
	f_msg_usr_err(200, Title, "Billing Cycle Date")
	dw_input.SetFocus()
	dw_input.SetColumn("chargedt")
	Return -1
End If


If is_trdt = "" Then
	f_msg_usr_err(200, Title, "Billing Cycle Date")
	dw_input.SetFocus()
	dw_input.SetColumn("trdt")
	Return -1
End If

If is_cms_yn = 'N' and is_giro_yn = 'N' Then
	f_msg_usr_err(9000, Title, "생성할 자료의 정보를 입력하세요.")
	dw_input.SetFocus()
	dw_input.SetColumn("giro")
	Return -1
End If

is_cms_file += is_trdt + ".txt"
is_giro_file += is_trdt + + ".txt"
Return 0 
end event

event type integer ue_process();call super::ue_process;b5u_dbmgr6 lu_dbmgr
Integer li_rc
lu_dbmgr = Create b5u_dbmgr6

//File 생성하러 감
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "Create Invoice"
lu_dbmgr.is_data[1] = is_chargedt
lu_dbmgr.is_data[2] = is_trdt
lu_dbmgr.is_data[3] = is_giro_yn
lu_dbmgr.is_data[4] = is_cms_yn
lu_dbmgr.is_data[5] = is_giro_file
lu_dbmgr.is_data[6] = is_cms_file
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -2 Then
	is_msg_process = "청구자료가 없습니다."
	Destroy lu_dbmgr
	Return 0

ElseIf li_rc = -1 Then
	is_msg_process = "Falid Create File"
   Destroy lu_dbmgr
	Return -1
ElseIf li_rc = 0 Then
	is_msg_process = "Sucess Create File ~r" + String(lu_dbmgr.il_data[1], "#,##0") + " Hit(s)"
	
End If

Destroy lu_dbmgr
Return 0 
end event

type p_ok from w_a_prc`p_ok within b5w_prc_invoice_cv
integer x = 1417
integer y = 72
boolean originalsize = false
end type

type dw_input from w_a_prc`dw_input within b5w_prc_invoice_cv
integer y = 44
integer width = 1262
integer height = 292
string dataobject = "b5dw_cnd_prc_invoice_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::itemchanged;call super::itemchanged;DateTime ld_trdt
If dwo.name = "chargedt" Then
	Select reqdt
	into :ld_trdt
	From reqconf
	where chargedt = :data;
   
	This.object.trdt[row] = Date(ld_trdt)
End If

Return 0
end event

type dw_msg_time from w_a_prc`dw_msg_time within b5w_prc_invoice_cv
integer y = 848
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_prc_invoice_cv
integer y = 384
end type

type ln_up from w_a_prc`ln_up within b5w_prc_invoice_cv
integer beginy = 364
integer endy = 364
end type

type ln_down from w_a_prc`ln_down within b5w_prc_invoice_cv
integer beginy = 1136
integer endy = 1136
end type

type p_close from w_a_prc`p_close within b5w_prc_invoice_cv
integer x = 1417
integer y = 180
end type

type gb_cond from w_a_prc`gb_cond within b5w_prc_invoice_cv
integer width = 1312
integer height = 344
end type

