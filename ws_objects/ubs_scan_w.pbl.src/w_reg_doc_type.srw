$PBExportHeader$w_reg_doc_type.srw
$PBExportComments$구비서류 TYPE등록
forward
global type w_reg_doc_type from w_a_reg_m
end type
type p_saveas from u_p_saveas within w_reg_doc_type
end type
end forward

global type w_reg_doc_type from w_a_reg_m
integer width = 3365
integer height = 1816
windowstate windowstate = normal!
p_saveas p_saveas
end type
global w_reg_doc_type w_reg_doc_type

type variables

end variables

on w_reg_doc_type.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on w_reg_doc_type.destroy
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

event open;call super::open;dw_detail.retrieve()
end event

event ue_ok;call super::ue_ok;dw_detail.reset()
dw_detail.retrieve()

end event

event ue_extra_save;call super::ue_extra_save;int    i , ll_rowcnt
string ls_doc_type, ls_doc_type_desc
long   ll_doc_type_qty

dw_detail.accepttext()

ll_rowcnt = dw_detail.rowcount()

for i = 1 to ll_rowcnt
	ls_doc_type      = dw_detail.object.doc_type[i] 
	ls_doc_type_desc = dw_detail.object.doc_type_desc[i] 
	ll_doc_type_qty  = dw_detail.getitemnumber(i, 'doc_type_qty')
	
	If IsNull(ls_doc_type) Then ls_doc_type = ""
	If IsNull(ls_doc_type_desc) Then ls_doc_type = ""
	
	if ls_doc_type = '' then
		messagebox('확인', '구비서류Type을 입력해주세요')
		return -1
	end if
	
	if ls_doc_type_desc = '' then
		messagebox('확인', '구비서류Type명을 입력해주세요')
		return -1
	end if
	
	if fs_snvl(String(ll_doc_type_qty),"") = "" or ll_doc_type_qty = 0 then
		messagebox('확인', '총장수를 입력해주세요')
		return -1
	end if

next
return 0
end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_doc_type
boolean visible = false
integer width = 123
integer height = 72
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_doc_type
integer x = 2624
integer y = 32
end type

type p_close from w_a_reg_m`p_close within w_reg_doc_type
integer x = 2930
integer y = 32
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_doc_type
boolean visible = false
integer width = 169
integer height = 136
end type

type p_delete from w_a_reg_m`p_delete within w_reg_doc_type
integer x = 635
integer y = 1588
end type

type p_insert from w_a_reg_m`p_insert within w_reg_doc_type
integer y = 1588
end type

type p_save from w_a_reg_m`p_save within w_reg_doc_type
integer x = 334
integer y = 1588
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_doc_type
integer y = 156
integer width = 3218
integer height = 1416
string dataobject = "d_reg_doc_type"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(Off!)
end event

type p_reset from w_a_reg_m`p_reset within w_reg_doc_type
boolean visible = false
integer x = 2313
integer y = 1876
end type

type p_saveas from u_p_saveas within w_reg_doc_type
event ue_saveas_init ( )
boolean visible = false
integer x = 2322
integer y = 2072
boolean bringtotop = true
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

