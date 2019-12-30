$PBExportHeader$p0w_inq_partner_stock.srw
$PBExportComments$[jojo] 대리점별카드재고현황
forward
global type p0w_inq_partner_stock from w_a_inq_m
end type
type p_1 from u_p_saveas within p0w_inq_partner_stock
end type
end forward

global type p0w_inq_partner_stock from w_a_inq_m
event ue_saveas ( )
p_1 p_1
end type
global p0w_inq_partner_stock p0w_inq_partner_stock

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

on p0w_inq_partner_stock.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on p0w_inq_partner_stock.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_partner, ls_a1, ls_a2, ls_a3, ls_a4
String ls_ref_desc, ls_tmp, ls_result[]
Integer li_check, li_ret
Long ll_row

ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_partner) Then ls_partner = ""

ls_tmp = fs_get_control('P0', 'P112', ls_ref_desc)
If ls_tmp = "" Then Return		
li_ret = fi_cut_string(ls_tmp, ";", ls_result[])
If li_ret <= 0 Then Return
ls_a1 = ls_result[3]		// 미입고
ls_a2 = ls_result[2]		// 재고
ls_a3 = ls_result[1]		// 판매출고
ls_a4 = ls_result[4]		// 반품

ls_where = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "partner_prefix = '" + ls_partner + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(ls_a1, ls_a2, ls_a3, ls_a4)
If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If
end event

type dw_cond from w_a_inq_m`dw_cond within p0w_inq_partner_stock
integer width = 1422
integer height = 144
string dataobject = "p0dw_cnd_inq_partner_stock"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within p0w_inq_partner_stock
integer x = 1833
end type

type p_close from w_a_inq_m`p_close within p0w_inq_partner_stock
integer x = 2135
end type

type gb_cond from w_a_inq_m`gb_cond within p0w_inq_partner_stock
integer width = 1691
integer height = 232
end type

type dw_detail from w_a_inq_m`dw_detail within p0w_inq_partner_stock
integer y = 256
string dataobject = "p0dw_inq_partner_stock"
boolean ib_sort_use = false
end type

type p_1 from u_p_saveas within p0w_inq_partner_stock
integer x = 2437
integer y = 64
boolean bringtotop = true
end type

