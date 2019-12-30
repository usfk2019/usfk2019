$PBExportHeader$b5w_prc_invoice_vtel_1.srw
$PBExportComments$[islim] 청구서 대행 발송- 브이텔레콤
forward
global type b5w_prc_invoice_vtel_1 from w_a_prc
end type
end forward

global type b5w_prc_invoice_vtel_1 from w_a_prc
integer height = 1252
end type
global b5w_prc_invoice_vtel_1 b5w_prc_invoice_vtel_1

type variables
String is_chargedt, is_trdt, is_cms_yn, is_giro_yn, is_giro_file, is_cms_file
String is_qnacenterp, is_qnacenterf , is_giro_no, is_pre_desc

//청구서 종류 2005.08.23
String is_inv_class
String is_manager_tel, is_file, is_issue_dt

String is_giro_file_delay, is_giro_delay_yn  //미납액 청구파일

end variables

on b5w_prc_invoice_vtel_1.create
call super::create
end on

on b5w_prc_invoice_vtel_1.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b5_prc_invoice_vtel_1
	Desc.: 청구내역을 청구서 발행 업체에 TXT 파일로 전해줌
	Date : 2005.08.23
	Auth.: juede  (브이텔레콤 전용)
-------------------------------------------------------------------------*/
String ls_ref_desc

//is_giro_file = fs_get_control("B5", "P100", ls_ref_desc)
//미납액청구파일
//is_giro_file_delay = is_giro_file +"delay_"

//KT합산청구서 & 지로청구서
is_file = fs_get_control("B5", "P100", ls_ref_desc) 

//관리점 전화번호
is_manager_tel = fs_get_control("B0","A104", ls_ref_desc) 

/*
is_qnacenterp = "1566-1544"
is_qnacenterf = "032-422-7852"
is_giro_no="6125235"
is_pre_desc="전월미납입금액"
*/
end event

event type integer ue_input();call super::ue_input;//해당 조건을 가져옴 
String ls_chargedt, ls_trdt, ls_cms_yn, ls_card_yn

is_chargedt = Trim(dw_input.object.chargedt[1])
is_trdt = String(dw_input.object.trdt[1], 'yyyymmdd')
is_inv_class = Trim(dw_input.object.inv_class[1])  //청구서 종류
is_issue_dt = String(dw_input.object.issue_date[1],'yyyy-mm-dd') //발행일자

//is_cms_yn = Trim(dw_input.object.cms[1])
//is_giro_yn = Trim(dw_input.object.giro[1])
//is_giro_delay_yn = Trim(dw_input.object.giro_delay[1])
//
If IsNull(is_chargedt) Then is_chargedt = ""
If IsNull(is_trdt) Then is_trdt = ""
If IsNull(is_inv_class) Then is_inv_class =""
If IsNull(is_issue_dt) Then is_issue_dt =""


If is_chargedt = "" Then
	f_msg_usr_err(200, Title, "Billing Cycle date")
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

If is_inv_class = "" Then
	f_msg_usr_err(200, Title, "생성할 자료의 정보를 입력하세요.")
	dw_input.SetFocus()
	dw_input.SetColumn("inv_class")
	Return -1
End If

If is_issue_dt = "" Then
	f_msg_usr_err(200, Title, "생성할 자료의 발행일자를 입력하세요.")
	dw_input.SetFocus()
	dw_input.SetColumn("issue_date")
	Return -1
End If

is_cms_file += is_trdt + is_inv_class +".txt"  
is_giro_file += is_trdt + is_inv_class +".txt"
//is_giro_file_delay  +=is_trdt +".txt"
Return 0 
end event

event type integer ue_process();call super::ue_process;b5u_dbmgr7_vtel lu_dbmgr
Integer li_rc
lu_dbmgr = Create b5u_dbmgr7_vtel


If LeftA(is_inv_class,2) ='kt' then
	//File 생성하러 감
	lu_dbmgr.is_title = Title
	lu_dbmgr.is_caller = "Create Invoice vtel kt"
	lu_dbmgr.is_data[1] = is_chargedt
	lu_dbmgr.is_data[2] = is_trdt
	lu_dbmgr.is_data[3] = is_inv_class
	lu_dbmgr.is_data[4] = is_file
//	lu_dbmgr.is_data[5] = is_pre_desc
	lu_dbmgr.is_data[5] = is_manager_tel
	lu_dbmgr.is_data[6] = is_issue_dt //청구서 발행일자
	//미납액청구파일추가(2004.7.2)
//	lu_dbmgr.is_data[10] = is_giro_file_delay
//	lu_dbmgr.is_data[11] = is_giro_delay_yn
	
	
	lu_dbmgr.uf_prc_db_01()
	li_rc = lu_dbmgr.ii_rc

Else
	//File 생성하러 감
	lu_dbmgr.is_title = Title
	lu_dbmgr.is_caller = "Create Invoice vtel giro"
	lu_dbmgr.is_data[1] = is_chargedt
	lu_dbmgr.is_data[2] = is_trdt
	lu_dbmgr.is_data[3] = is_inv_class
	lu_dbmgr.is_data[4] = is_file		
	lu_dbmgr.is_data[5] = is_manager_tel
	lu_dbmgr.is_data[6] = is_issue_dt //청구서 발행일자	
	lu_dbmgr.uf_prc_db_02()
	li_rc = lu_dbmgr.ii_rc
End If	
	

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

type p_ok from w_a_prc`p_ok within b5w_prc_invoice_vtel_1
integer x = 1417
integer y = 72
boolean originalsize = false
end type

type dw_input from w_a_prc`dw_input within b5w_prc_invoice_vtel_1
integer y = 44
integer width = 1262
integer height = 352
string dataobject = "b5dw_cnd_prc_invoice_vtel_1"
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

type dw_msg_time from w_a_prc`dw_msg_time within b5w_prc_invoice_vtel_1
integer y = 848
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_prc_invoice_vtel_1
integer y = 452
integer height = 380
end type

type ln_up from w_a_prc`ln_up within b5w_prc_invoice_vtel_1
integer beginy = 432
integer endy = 432
end type

type ln_down from w_a_prc`ln_down within b5w_prc_invoice_vtel_1
integer beginy = 1136
integer endy = 1136
end type

type p_close from w_a_prc`p_close within b5w_prc_invoice_vtel_1
integer x = 1417
integer y = 180
end type

type gb_cond from w_a_prc`gb_cond within b5w_prc_invoice_vtel_1
integer width = 1312
integer height = 416
end type

