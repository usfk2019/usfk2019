$PBExportHeader$ssrt_prt_receipt_list.srw
$PBExportComments$[1hera]영수증리스트
forward
global type ssrt_prt_receipt_list from w_a_print
end type
end forward

global type ssrt_prt_receipt_list from w_a_print
integer width = 3598
end type
global ssrt_prt_receipt_list ssrt_prt_receipt_list

on ssrt_prt_receipt_list.create
call super::create
end on

on ssrt_prt_receipt_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2 //세로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;//조회
String 	ls_where, &
			ls_saledt_fr,	ls_saledt_to, ls_customerid, ls_memberid, ls_partner, ls_approvalno, &
			ls_shopnm, ls_term_fr, ls_term_to
Long 		ll_row

dw_cond.AcceptText()
ls_saledt_fr   = String(dw_cond.object.saledt_fr[1], 'yyyymmdd')
ls_term_fr   	= String(dw_cond.object.saledt_fr[1], 'mm-dd-yyyy')
ls_saledt_to   = String(dw_cond.object.saledt_to[1], 'yyyymmdd')
ls_term_to   	= String(dw_cond.object.saledt_to[1], 'mm-dd-yyyy')

ls_customerid  = Trim(dw_cond.object.customerid[1])
ls_memberid    = Trim(dw_cond.object.memberid[1])
ls_partner     = Trim(dw_cond.object.partner[1])
ls_approvalno  = Trim(dw_cond.object.approvalno[1])

If IsNull(ls_memberid) 		Then ls_memberid 		= ""
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_saledt_fr) 	Then ls_saledt_fr 	= ""
If IsNull(ls_saledt_to) 	Then ls_saledt_to 	= ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
IF IsNull(ls_approvalno) 	then ls_approvalno 	= ""

If ls_partner = "" Then
	 f_msg_usr_err(200, Title, "Shop")
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("partner")
	 Return 
End IF

//Retrieve
ls_where = ""
If ls_saledt_fr <> "" and ls_saledt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(paydt, 'yyyymmdd') >='" + ls_saledt_fr + "' " + &
	   			"and to_char(paydt, 'yyyymmdd') <= '" + ls_saledt_to + "' "

ElseIf ls_saledt_fr <> "" and ls_saledt_to = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(paydt,'YYYYMMDD') >= '" + ls_saledt_fr + "' "
ElseIf ls_saledt_fr = "" and ls_saledt_to <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(paydt, 'YYYYMMDD') <= '" + ls_saledt_to + "' " 
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.shopid = '" + ls_partner + "' "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.customerid = '" + ls_customerid + "' "
End If


If ls_approvalno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.seq_app = '" + ls_approvalno + "' "
End If

//dw_list.Modify ( "p_work.text='기간만료'" )
//dw_list.Modify ( "p_work.text='잔액만료'" )
//dw_list.Modify ( "p_priceplan.text='" + ls_priceplan + "'" )
//ls_priceplan_txt = dw_cond.object.compute_priceplan[1] 
//dw_list.object.t_priceplan.Text = ls_priceplan_txt

ls_shopnm = dw_cond.Describe("evaluate('lookupdisplay(partner)',1 )")

dw_list.object.t_shop.Text = ls_shopnm
dw_list.object.t_sales_date.Text = ls_term_fr + ' ~ ' + ls_term_to

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_prt_receipt_list
	Desc	: 	영수증 List
	Ver.	:	2.0
	Date	:   2007.01.10
	Programer : 1hera
-------------------------------------------------------------------------*/

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_receipt_list
integer x = 46
integer y = 40
integer width = 2592
integer height = 284
integer taborder = 0
string dataobject = "ssrt_cnd_prt_receipt_list"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;if dwo.name = "contno_fr" Then
	This.Object.contno_to[1] = data
End If


end event

type p_ok from w_a_print`p_ok within ssrt_prt_receipt_list
integer x = 2953
end type

type p_close from w_a_print`p_close within ssrt_prt_receipt_list
integer x = 3255
end type

type dw_list from w_a_print`dw_list within ssrt_prt_receipt_list
integer y = 376
integer width = 3483
integer height = 1212
string dataobject = "ssrt_prt_receipt_list"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_receipt_list
end type

type p_2 from w_a_print`p_2 within ssrt_prt_receipt_list
end type

type p_3 from w_a_print`p_3 within ssrt_prt_receipt_list
end type

type p_5 from w_a_print`p_5 within ssrt_prt_receipt_list
end type

type p_6 from w_a_print`p_6 within ssrt_prt_receipt_list
end type

type p_7 from w_a_print`p_7 within ssrt_prt_receipt_list
end type

type p_8 from w_a_print`p_8 within ssrt_prt_receipt_list
end type

type p_9 from w_a_print`p_9 within ssrt_prt_receipt_list
end type

type p_4 from w_a_print`p_4 within ssrt_prt_receipt_list
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_receipt_list
end type

type p_port from w_a_print`p_port within ssrt_prt_receipt_list
end type

type p_land from w_a_print`p_land within ssrt_prt_receipt_list
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_receipt_list
integer width = 2624
integer height = 336
integer taborder = 0
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_receipt_list
end type

