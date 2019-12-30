$PBExportHeader$p0w_prt_callingcard_invoice.srw
$PBExportComments$[chooys] CallingCard Invoice Window
forward
global type p0w_prt_callingcard_invoice from w_a_print
end type
end forward

global type p0w_prt_callingcard_invoice from w_a_print
end type
global p0w_prt_callingcard_invoice p0w_prt_callingcard_invoice

type variables
String is_logo
String is_address
end variables

on p0w_prt_callingcard_invoice.create
call super::create
end on

on p0w_prt_callingcard_invoice.destroy
call super::destroy
end on

event open;call super::open;String ls_ref, ls_result

is_logo= fs_get_control("B5", "N100", ls_ref)
is_address= fs_get_control("B5", "N101", ls_ref)
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2//세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_desc
String ls_partner
String ls_invoiceno
String ls_gstno
String ls_outdt_from, ls_outdt_to
Integer li_rc, li_row
Dec ldc_gst

ls_partner = dw_cond.object.partner[1]
ls_invoiceno = dw_cond.object.invoiceno[1]
ls_gstno = dw_cond.object.gstno[1]
ls_outdt_from = String(dw_cond.object.outdt_from[1],"YYYYMMDD")
ls_outdt_to = String(dw_cond.object.outdt_to[1],"YYYYMMDD")

If IsNull(ls_partner) Then ls_partner =""
If IsNull(ls_invoiceno) Then ls_invoiceno =""
If IsNull(ls_gstno) Then ls_gstno =""
If IsNull(ls_outdt_from) Then ls_outdt_from =""
If IsNull(ls_outdt_to) Then ls_outdt_to =""


If ls_invoiceno ="" Then
	f_msg_info(200, Title, "Invoice No. Prefix")
	dw_cond.SetFocus()
	dw_cond.SetColumn("invoiceno")
	Return
End If

If ls_outdt_from ="" Then
	f_msg_info(200, Title,"Activation Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("outdt_from")
	Return
End If

If ls_outdt_to ="" Then
	f_msg_info(200, Title,"Activation Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("outdt_to")
	Return
End If

If ls_gstno ="" Then
	f_msg_info(200, Title,"GST No. Prefix")
	dw_cond.SetFocus()
	dw_cond.SetColumn("gstno")
	Return
End If

dw_list.Object.t_invoiceno.text = ls_invoiceno
dw_list.Object.t_gstno.text = ls_gstno
dw_list.Object.t_invoiceno2.text = ls_invoiceno
dw_list.Object.t_gstno2.text = ls_gstno


ls_where = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "olog.partner_prefix = '" + ls_partner + "'"
End If

If ls_outdt_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(olog.outdt,'YYYYMMDD') >= '" + ls_outdt_from + "'"
End If

If ls_outdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(olog.outdt,'YYYYMMDD') <= '" + ls_outdt_to + "'"
End If

//GST 비율.
ldc_gst = Dec(fs_get_control("P0","P200",ls_desc))

dw_list.SetRedraw(False)

dw_list.is_where = ls_where
li_row = dw_list.Retrieve(ldc_gst)

If li_row = 0 Then
	f_msg_info(1000, title, "")
ElseIf li_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return
End If

//이미지 삽입
dw_list.Modify("p_logo.filename='" + is_logo + "'")
dw_list.Modify("p_address.filename='" + is_address + "'")

dw_list.Modify("p_logo2.filename='" + is_logo + "'")
dw_list.Modify("p_address2.filename='" + is_address + "'")

//Format

dw_list.SetRedraw(TRUE)


	
end event

event ue_set_header();dw_cond.SetFocus()
end event

event ue_saveas_init();call super::ue_saveas_init;//ib_saveas = True
//idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p0w_prt_callingcard_invoice
integer x = 78
integer y = 56
integer width = 2016
integer height = 208
string dataobject = "p0dw_cnd_prt_callingcard_invoice"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p0w_prt_callingcard_invoice
integer x = 2149
end type

type p_close from w_a_print`p_close within p0w_prt_callingcard_invoice
integer x = 2450
end type

type dw_list from w_a_print`dw_list within p0w_prt_callingcard_invoice
integer y = 304
integer height = 1316
string dataobject = "p0dw_prt_callingcard_invoice"
end type

type p_1 from w_a_print`p_1 within p0w_prt_callingcard_invoice
end type

type p_2 from w_a_print`p_2 within p0w_prt_callingcard_invoice
end type

type p_3 from w_a_print`p_3 within p0w_prt_callingcard_invoice
end type

type p_5 from w_a_print`p_5 within p0w_prt_callingcard_invoice
end type

type p_6 from w_a_print`p_6 within p0w_prt_callingcard_invoice
end type

type p_7 from w_a_print`p_7 within p0w_prt_callingcard_invoice
end type

type p_8 from w_a_print`p_8 within p0w_prt_callingcard_invoice
end type

type p_9 from w_a_print`p_9 within p0w_prt_callingcard_invoice
end type

type p_4 from w_a_print`p_4 within p0w_prt_callingcard_invoice
end type

type gb_1 from w_a_print`gb_1 within p0w_prt_callingcard_invoice
end type

type p_port from w_a_print`p_port within p0w_prt_callingcard_invoice
end type

type p_land from w_a_print`p_land within p0w_prt_callingcard_invoice
end type

type gb_cond from w_a_print`gb_cond within p0w_prt_callingcard_invoice
integer width = 2066
integer height = 276
end type

type p_saveas from w_a_print`p_saveas within p0w_prt_callingcard_invoice
end type

