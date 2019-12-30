$PBExportHeader$ssrt2_reg_bill_cancel_shop.srw
$PBExportComments$[hcjung] 수납 취소
forward
global type ssrt2_reg_bill_cancel_shop from w_a_reg_m_m
end type
end forward

global type ssrt2_reg_bill_cancel_shop from w_a_reg_m_m
integer width = 3685
end type
global ssrt2_reg_bill_cancel_shop ssrt2_reg_bill_cancel_shop

type variables
DATE 		idt_shop_closedt
String 	is_paydt,	is_seq_app,	is_payid
Long		ib_seq
end variables

on ssrt2_reg_bill_cancel_shop.create
call super::create
end on

on ssrt2_reg_bill_cancel_shop.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where
Long ll_row


is_paydt 	= String(dw_cond.object.paydt[1], 'yyyymmdd')
is_payid 	= Trim(dw_cond.object.payid[1])
is_seq_app 	= Trim(dw_cond.object.seq_app[1])

If IsNull(is_paydt) 		Then is_paydt 	= ""
If IsNull(is_payid) 		Then is_payid 	= ""
If IsNull(is_seq_app) 	Then is_seq_app 	= ""

ls_where = ""

//SHOPID
If GS_SHOPID <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "shopid = '" + GS_SHOPID + "' "
End If

//paydt
If is_paydt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(trdt, 'yyyymmdd') = '" + is_paydt + "' "
End If
//payid
If is_payid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " customerid = '" + is_payid + "' "
End If
//seq_app
If is_seq_app <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " seq_app = '" + is_seq_app + "' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If



end event

event open;call super::open;dw_cond.object.paydt[1] 		= f_find_shop_closedt(GS_SHOPID)
end event

type dw_cond from w_a_reg_m_m`dw_cond within ssrt2_reg_bill_cancel_shop
integer width = 1856
integer height = 292
string dataobject = "ssrt2_cnd_bill_cancel_shop"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within ssrt2_reg_bill_cancel_shop
integer x = 1966
end type

type p_close from w_a_reg_m_m`p_close within ssrt2_reg_bill_cancel_shop
integer x = 2272
end type

type gb_cond from w_a_reg_m_m`gb_cond within ssrt2_reg_bill_cancel_shop
integer width = 1902
integer height = 380
end type

type dw_master from w_a_reg_m_m`dw_master within ssrt2_reg_bill_cancel_shop
integer x = 32
integer y = 400
integer width = 3474
integer height = 532
string dataobject = "ssrt_reg_cancel_payment_sum_shop"
end type

type dw_detail from w_a_reg_m_m`dw_detail within ssrt2_reg_bill_cancel_shop
integer y = 1148
integer height = 484
end type

type p_insert from w_a_reg_m_m`p_insert within ssrt2_reg_bill_cancel_shop
end type

type p_delete from w_a_reg_m_m`p_delete within ssrt2_reg_bill_cancel_shop
end type

type p_save from w_a_reg_m_m`p_save within ssrt2_reg_bill_cancel_shop
end type

type p_reset from w_a_reg_m_m`p_reset within ssrt2_reg_bill_cancel_shop
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ssrt2_reg_bill_cancel_shop
integer x = 32
integer y = 1120
end type

