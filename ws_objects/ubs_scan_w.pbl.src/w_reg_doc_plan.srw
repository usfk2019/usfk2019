$PBExportHeader$w_reg_doc_plan.srw
$PBExportComments$가격정책별구비서류
forward
global type w_reg_doc_plan from w_a_reg_m
end type
type p_saveas from u_p_saveas within w_reg_doc_plan
end type
end forward

global type w_reg_doc_plan from w_a_reg_m
integer width = 4626
integer height = 2732
windowstate windowstate = normal!
p_saveas p_saveas
end type
global w_reg_doc_plan w_reg_doc_plan

type variables

end variables

on w_reg_doc_plan.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on w_reg_doc_plan.destroy
call super::destroy
destroy(this.p_saveas)
end on

event resize;call super::resize;//p_saveas 추가
//2008-02-13 by JH
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_saveas.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	p_saveas.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event ue_ok;call super::ue_ok;string ls_priceplan, ls_svccd, ls_doc_type
long ll_row

dw_cond.accepttext()

ls_priceplan = dw_cond.object.priceplan[1]
ls_svccd     = dw_cond.object.service[1]
ls_doc_type  = dw_cond.object.doc_type[1]

dw_detail.reset()

ll_row = dw_detail.retrieve(ls_priceplan, ls_svccd, ls_doc_type)

if ll_row = 0 then
	messagebox("확인", "Record not found")
	p_insert.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
end if
end event

event ue_insert;call super::ue_insert;datetime ld_fromdt
int      li_row
string   ls_priceplan, ls_doc_type

dw_cond.accepttext()

li_row = dw_detail.getrow()

ld_fromdt = Datetime(fdt_get_dbserver_now())

dw_detail.object.fromdt[li_row] = ld_fromdt
dw_detail.setitem(li_row, "crt_user", gs_user_id)
dw_detail.setitem(li_row, "crtdt", ld_fromdt)
dw_detail.setitem(li_row, "pgm_id", gs_pgm_id[gi_open_win_no])


ls_priceplan = dw_cond.object.priceplan[1] 

if ls_priceplan <> '%' then
	dw_detail.object.priceplan[li_row] = ls_priceplan
end if

ls_doc_type = dw_cond.object.doc_type[1] 

if ls_doc_type <> '%' then
	dw_detail.object.doc_type[li_row] = ls_doc_type
	dw_detail.trigger event itemchanged(li_row, dw_detail.object.doc_type, ls_doc_type)
end if

return 1
end event

event open;call super::open;dw_cond.trigger event ue_init()

end event

event ue_extra_save;call super::ue_extra_save;string   ls_doc_type, ls_updt_user
int      li_qty, i
datetime ld_sysdate, ld_updtdt

dwItemStatus l_status

ld_sysdate = Datetime(fdt_get_dbserver_now())

dw_detail.accepttext()

if dw_detail.rowcount() = 0 then return 0

l_status  = dw_detail.GetItemStatus(1, 0, Primary!)

for i = 1 to dw_detail.rowcount()
	l_status  = dw_detail.GetItemStatus(i, 0, Primary!)
	if l_status = DataModified! then
		dw_detail.setitem(i, "updt_user", gs_user_id)
		dw_detail.setitem(i, "updtdt", ld_sysdate)
	end if
next
return 1

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_doc_plan
integer x = 69
integer width = 1664
integer height = 280
string dataobject = "d_cnd_doc_plan"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;DataWindowChild ldwc_col

//가격정책 ALL
dw_cond.getchild("priceplan", ldwc_col)
ldwc_col.SetTransObject(SQLCA)
ldwc_col.retrieve('')
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "priceplan_desc", "ALL")
ldwc_col.setitem(1, "priceplan", "%")
//
////서비스 ALL
dw_cond.getchild("service", ldwc_col)
ldwc_col.SetTransObject(SQLCA)
ldwc_col.retrieve()
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "svcdesc", "ALL")
ldwc_col.setitem(1, "svccod", "%")

//구비서류TYPE ALL
dw_cond.getchild("doc_type", ldwc_col)
ldwc_col.SetTransObject(SQLCA)
ldwc_col.retrieve()
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "doc_type_desc", "ALL")
ldwc_col.setitem(1, "doc_type", "%")


p_insert.TriggerEvent("ue_enable")

p_save.TriggerEvent("ue_enable")

p_delete.TriggerEvent("ue_enable")

p_reset.TriggerEvent("ue_enable")
end event

event dw_cond::itemchanged;call super::itemchanged;string ls_filter


DataWindowChild ldwc_col

Choose Case dwo.name
		
	Case "service"
		this.accepttext()
		dw_cond.getchild("priceplan", ldwc_col)			
		ldwc_col.SetTransObject(SQLCA)
		ldwc_col.reset()
		ldwc_col.retrieve(data)
		
		ldwc_col.insertrow(1)
		ldwc_col.setitem(1, "priceplan_desc", "ALL")
		ldwc_col.setitem(1, "priceplan", "%")

		
		
End Choose	
end event

type p_ok from w_a_reg_m`p_ok within w_reg_doc_plan
integer x = 3927
integer y = 28
end type

type p_close from w_a_reg_m`p_close within w_reg_doc_plan
integer x = 4233
integer y = 28
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_doc_plan
integer width = 1728
integer height = 348
end type

type p_delete from w_a_reg_m`p_delete within w_reg_doc_plan
integer x = 658
integer y = 2516
end type

type p_insert from w_a_reg_m`p_insert within w_reg_doc_plan
integer x = 55
integer y = 2516
end type

type p_save from w_a_reg_m`p_save within w_reg_doc_plan
integer x = 357
integer y = 2516
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_doc_plan
integer y = 368
integer width = 4512
integer height = 2068
string dataobject = "d_reg_doc_plan"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_init;call super::ue_init;dw_cond.accepttext()

f_dddw_list2(this, 'order_type', 'ZC100')
end event

event dw_detail::itemchanged;call super::itemchanged;string   ls_doc_type, ls_updt_user
int      li_qty

this.accepttext()
if row = 0 then return 0

Choose Case dwo.Name
	Case "doc_type"
		
		SELECT doc_type_qty
		INTO   :li_qty
		FROM   DOC_TYPE_M
		WHERE  DOC_TYPE = :DATA;
		
		this.object.doc_type_qty[row] = li_qty
		
End Choose

return 0
end event

type p_reset from w_a_reg_m`p_reset within w_reg_doc_plan
integer x = 960
integer y = 2512
end type

type p_saveas from u_p_saveas within w_reg_doc_plan
event ue_saveas_init ( )
boolean visible = false
integer x = 2642
integer y = 2712
integer width = 274
boolean bringtotop = true
boolean enabled = false
boolean originalsize = false
end type

event clicked;f_excel_ascii1(dw_detail,'파일명을 입력하세요')

//Boolean lb_return
//Integer li_return
//String ls_curdir
//u_api lu_api
//
//If dw_detail.RowCount() <= 0 Then
//	f_msg_info(1000, parent.Title, "Data exporting")
//	Return
//End If
//
//lu_api = Create u_api
//ls_curdir = lu_api.uf_getcurrentdirectorya()
//If IsNull(ls_curdir) Or ls_curdir = "" Then
//	f_msg_info(9000, parent.Title, "Can't get the Information of current directory.")
//	Destroy lu_api
//	Return
//End If
//
//li_return = dw_detail.SaveAs("", Excel!, True)
//
//lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
//If li_return <> 1 Then
//	f_msg_info(9000, parent.Title, "User cancel current job.")
//Else
//	f_msg_info(9000, parent.Title, "Data export finished.")
//End If
//
//Destroy lu_api
//
end event

