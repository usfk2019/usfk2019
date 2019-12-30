$PBExportHeader$b5w_inq_reqconf_goodtel.srw
$PBExportComments$[parkkh] 청구주기 Control-goodtel용(workdays추가)
forward
global type b5w_inq_reqconf_goodtel from w_a_reg_m
end type
end forward

global type b5w_inq_reqconf_goodtel from w_a_reg_m
integer width = 4480
integer height = 1244
end type
global b5w_inq_reqconf_goodtel b5w_inq_reqconf_goodtel

on b5w_inq_reqconf_goodtel.create
call super::create
end on

on b5w_inq_reqconf_goodtel.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_chargedt

ls_where = ""
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
//	
//	dwObject ldwo_reqdt
//	String ls_reqdt
//
//	ldwo_reqdt = dw_detail.Object.reqdt
//	ls_reqdt = string(dw_detail.Object.reqdt[1],'yyyymmdd')
//	dw_detail.Trigger Event Itemchanged(1, ldwo_reqdt, ls_reqdt)
//	p_insert.TriggerEvent("ue_enable")

End If

dw_detail.SetRedraw(True)
end event

event open;call super::open;String ls_module, ls_ref_no, ls_ref_desc
String ls_edit

dw_detail.SetRowfocusIndicator(Off!)

//dw_cond.SetFocus()
This.TriggerEvent("ue_ok")

end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_close.Y   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_close.Y   = newheight - iu_cust_w_resize.ii_button_space
	
End If

/*
If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If
*/

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b5w_inq_reqconf_goodtel
boolean visible = false
integer y = -32768
integer width = 1230
integer height = 144
string dataobject = "b5d_cnd_reg_reqconf"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_inq_reqconf_goodtel
boolean visible = false
integer x = 1280
integer y = 32
boolean enabled = false
end type

type p_close from w_a_reg_m`p_close within b5w_inq_reqconf_goodtel
integer x = 4110
integer y = 900
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_inq_reqconf_goodtel
boolean visible = false
integer x = 503
integer y = 1036
integer height = 152
end type

type p_delete from w_a_reg_m`p_delete within b5w_inq_reqconf_goodtel
boolean visible = false
integer x = 384
integer y = 916
end type

type p_insert from w_a_reg_m`p_insert within b5w_inq_reqconf_goodtel
boolean visible = false
integer x = 64
integer y = 916
end type

type p_save from w_a_reg_m`p_save within b5w_inq_reqconf_goodtel
boolean visible = false
integer x = 704
integer y = 916
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_inq_reqconf_goodtel
integer x = 50
integer y = 52
integer width = 4366
integer height = 820
string dataobject = "b5d_inq_reqconf_goodtel"
boolean vscrollbar = false
end type

event dw_detail::retrieveend;////Override
//p_ok.TriggerEvent("ue_disable")
//
////p_insert.TriggerEvent("ue_enable")
//p_delete.TriggerEvent("ue_enable")
//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//
//dw_cond.Enabled = False
//
end event

event dw_detail::itemchanged;call super::itemchanged;//String ls_reqdt, ls_reqterm, ls_date
//Long   ll_row
//Int    li_cnt
//
//ll_row = dw_detail.RowCount()
//
//Choose Case dwo.Name
//	Case "reqdt"
//		For li_cnt = 1 to ll_row
//			ls_reqdt =String(Object.reqdt[li_cnt],"yyyymmdd")
//			ls_date = String(Object.reqdt[li_cnt],"yyyy-mm-dd")
//
//			If Not IsDate(ls_date) Then
//				setrow(li_cnt)
//				Object.opendt[li_cnt] = ""
//				Object.enddt[li_cnt] = ""
//				Object.salesdt[li_cnt] = ""
//			Else
//				ls_reqterm = b5fs_reqterm("", ls_reqdt)
//				setrow(li_cnt)
//				Object.opendt[li_cnt] = String(Mid(ls_reqterm, 1, 8), "@@@@-@@-@@")
//				Object.enddt[li_cnt] = String(Mid(ls_reqterm, 9, 8), "@@@@-@@-@@")
//				Object.salesdt[li_cnt] = String(Mid(ls_reqterm, 1, 8), "@@@@-@@-@@")
//			  	This.SetitemStatus(li_cnt, "opendt", Primary!, NotModified!)   //수정 안되었다고 인식.
//			  	This.SetitemStatus(li_cnt, "enddt", Primary!, NotModified!)   //수정 안되었다고 인식.
//			  	This.SetitemStatus(li_cnt, "salesdt", Primary!, NotModified!)   //수정 안되었다고 인식.				  
//			End If
//		Next
//End Choose
//
end event

event dw_detail::clicked;call super::clicked;If row = 0 then Return -1

If IsSelected( row ) then
	 SelectRow( row ,FALSE)
Else
	SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
	

end event

event dw_detail::doubleclicked;call super::doubleclicked;window lw_temp

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_id = "000"
iu_cust_msg.is_pgm_name = "Monthly Cyclical Billing Process"
iu_cust_msg.is_grp_name = this.title
iu_cust_msg.is_call_name[1] = "b5w_prc_reqpgm_goodtel"
iu_cust_msg.is_pgm_type = "P"
iu_cust_msg.is_data[1] = This.object.chargedt_1[row]

//OpenWithParm(b5w_prc_reqpgm_goodtel, iu_cust_msg) 

//해당 윈도우를 연다.
If OpenWithParm(lw_temp, iu_cust_msg, iu_cust_msg.is_call_name[1], gw_mdi_frame) <> 1 Then
   f_msg_usr_err_app(503, This.Title, "'" + iu_cust_msg.is_call_name[1] + "' " + "window is not opened")
End If
end event

type p_reset from w_a_reg_m`p_reset within b5w_inq_reqconf_goodtel
boolean visible = false
integer y = 876
end type

