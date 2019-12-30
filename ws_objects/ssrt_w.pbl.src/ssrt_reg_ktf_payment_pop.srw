$PBExportHeader$ssrt_reg_ktf_payment_pop.srw
$PBExportComments$[1hera] KTF Payment
forward
global type ssrt_reg_ktf_payment_pop from w_a_reg_m
end type
type dw_detail2 from datawindow within ssrt_reg_ktf_payment_pop
end type
type p_print from u_p_print within ssrt_reg_ktf_payment_pop
end type
end forward

global type ssrt_reg_ktf_payment_pop from w_a_reg_m
integer width = 2322
integer height = 2888
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_search ( )
event ue_print ( )
dw_detail2 dw_detail2
p_print p_print
end type
global ssrt_reg_ktf_payment_pop ssrt_reg_ktf_payment_pop

type variables

end variables

event ue_print();dw_detail2.Print()
end event

on ssrt_reg_ktf_payment_pop.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.p_print=create p_print
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.p_print
end on

on ssrt_reg_ktf_payment_pop.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.p_print)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_ktf_payment_pop
	Desc	: 	KTF Payment Request
	Ver.	:	1.0
	Date	: 	2007.1.4
	programer : 1hera
-------------------------------------------------------------------------*/
//window 중앙에
f_center_window(this)

String ls_payid, ls_trdt, ls_validkey, ls_customernm
String	ls_desc[]
date		ld_trdt
dec{2}	lc_charge[]
Long		ll_jj,		ll_row,	ll_cnt


//Data 받아오기
ld_trdt 			= iu_cust_msg.id_data[1]
ls_payid 		= iu_cust_msg.is_data2[1]
ls_customernm 	= iu_cust_msg.is_data2[2]
ls_validkey 	= iu_cust_msg.is_data2[3]

ls_desc[] 	= iu_cust_msg.is_data[]
lc_charge[]	= iu_cust_msg.ic_data[]

FOR ll_jj =  30 to 1 step -1
	IF ls_desc[ll_jj] <> '' then
		ll_cnt = ll_jj
		EXIT
	END IF
NEXT
FOR ll_jj =  1 to ll_cnt
	ll_row = dw_detail2.InsertRow(0)
	dw_detail2.Object.trdt[ll_row] 			= ld_trdt
	dw_detail2.Object.payid[ll_row] 			= ls_payid
	dw_detail2.Object.customernm[ll_row] 	= ls_customernm
	dw_detail2.Object.validkey[ll_row] 		= ls_validkey
	dw_detail2.Object.desct[ll_row] 			= ls_desc[ll_jj]
	dw_detail2.Object.charge[ll_row] 		= lc_charge[ll_jj]
NEXT
dw_detail2.GroupCalc()
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 2048
integer y = 1016
integer width = 187
integer height = 52
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 3058
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_ktf_payment_pop
integer x = 1989
integer y = 20
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 2030
integer y = 952
integer width = 242
integer height = 148
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 1989
integer y = 1696
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 1989
integer y = 1588
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 1989
integer y = 1372
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 2025
integer y = 1120
integer width = 160
integer height = 56
boolean enabled = false
string dataobject = "b1dw_reg_quotainfo_pop1_cl"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;//Setting
Long ll_row, i
ll_row = dw_detail.RowCount()
//임대여서 자료 없을때
If ll_row = 0 Then 
	dw_cond.object.cnt[1] = 1
	Return 0
End If

dw_cond.object.cnt[1] = ll_row
For i = 1 To ll_row
	dw_detail.object.amt[i] = dw_detail.object.sale_amt[i]
Next
If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

Return 0
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_ktf_payment_pop
boolean visible = false
integer x = 1989
integer y = 1480
boolean enabled = true
end type

type dw_detail2 from datawindow within ssrt_reg_ktf_payment_pop
integer x = 23
integer y = 12
integer width = 1947
integer height = 2752
integer taborder = 11
string title = "none"
string dataobject = "ssrt_reg_ktf_payment_pop"
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type p_print from u_p_print within ssrt_reg_ktf_payment_pop
integer x = 1989
integer y = 176
boolean bringtotop = true
boolean originalsize = false
end type

