$PBExportHeader$b5w_inq_billfile_record_detail_popup.srw
$PBExportComments$[ohj] 청구file record 상세구성-popup
forward
global type b5w_inq_billfile_record_detail_popup from w_base
end type
type p_select from picture within b5w_inq_billfile_record_detail_popup
end type
type dw_check from u_d_base within b5w_inq_billfile_record_detail_popup
end type
type dw_cond from u_d_external within b5w_inq_billfile_record_detail_popup
end type
type p_close from u_p_close within b5w_inq_billfile_record_detail_popup
end type
type p_ok from u_p_ok within b5w_inq_billfile_record_detail_popup
end type
type gb_1 from groupbox within b5w_inq_billfile_record_detail_popup
end type
end forward

global type b5w_inq_billfile_record_detail_popup from w_base
integer width = 2839
integer height = 1368
string title = "Copy Standard Rate Zones"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
p_select p_select
dw_check dw_check
dw_cond dw_cond
p_close p_close
p_ok p_ok
gb_1 gb_1
end type
global b5w_inq_billfile_record_detail_popup b5w_inq_billfile_record_detail_popup

event ue_close;Close(This)
end event

event ue_ok();Long ll_row

//Retrieve
ll_row = dw_cond.Retrieve()

dw_cond.SetFocus()
dw_cond.SelectRow(0, False)
dw_cond.ScrollToRow(1)
dw_cond.SelectRow(1, True)


If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

on b5w_inq_billfile_record_detail_popup.create
int iCurrent
call super::create
this.p_select=create p_select
this.dw_check=create dw_check
this.dw_cond=create dw_cond
this.p_close=create p_close
this.p_ok=create p_ok
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_select
this.Control[iCurrent+2]=this.dw_check
this.Control[iCurrent+3]=this.dw_cond
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.p_ok
this.Control[iCurrent+6]=this.gb_1
end on

on b5w_inq_billfile_record_detail_popup.destroy
call super::destroy
destroy(this.p_select)
destroy(this.dw_check)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b5w_inq_billfile_record_detail_popup
	Desc.	: 
	Ver.	: 1.0
	Date	: 2005.02.23
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row
String ls_itemcod

f_center_window(b5w_inq_billfile_record_detail_popup)

TriggerEvent("ue_ok")

//dw_cond.object.priceplan[1] = iu_cust_msg.is_data[1]



Return 0 

end event

type p_select from picture within b5w_inq_billfile_record_detail_popup
integer x = 2510
integer y = 152
integer width = 283
integer height = 96
string picturename = "select_e.gif"
boolean focusrectangle = false
end type

event clicked;//표준 요금 조회
//String ls_priceplan, ls_pgm_id, ls_priceplan_old
//Long ll_row, i, ll_baserate, ll_addrate, ll_cnt
//Dec{6} ldc_baseamt, ldc_addamt, ldc_baseamt_1, ldc_unitfee_1
//Dec{6} ldc_unitfee_2, ldc_unitfee_3, ldc_unitfee_4, ldc_unitfee_5
//DateTime ldt_sysdate
//Integer li_result

//dw_cond.accepttext()
//ldt_sysdate = fdt_get_dbserver_now() 
//
//ls_priceplan = Trim(dw_cond.object.priceplan[1])
//ls_priceplan_old = iu_cust_msg.is_data[1]
//ls_pgm_id = iu_cust_msg.is_data[2]
//ldc_baseamt = dw_cond.object.baseamt[1]
//ll_baserate = dw_cond.object.baserate[1]
//ll_addrate = dw_cond.object.addrate[1]
//ldc_addamt = dw_cond.object.addamt[1]
//
//If IsNull(ls_priceplan) Then ls_priceplan = ""
//
////필수 항목 Check
//If ls_priceplan = "" Then
//	f_msg_info(200, Title,"Price Plan")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("priceplan")
//   Return
//End If
//
//If ll_baserate < 0 Then 
//	f_msg_usr_err(201, title, "Initial Rate x (Fixed Rate)")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("baserate")
//	Return
//End If
//
//If ll_addrate < 0 Then 
//	f_msg_usr_err(201, title, "Add'l Rate  x (Fixed Rate)")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("addrate")
//	Return
//End If
String ls_itemkey_desc, ls_itemtype, ls_pgmcode
Long   ll_row, ll_itemkey, ll_new_row

If dw_cond.Rowcount() <= 0 Then
	Return 
End If

ll_row          = dw_cond.Getrow()
ll_itemkey      = dw_cond.object.itemkey[ll_row]
ls_itemkey_desc = dw_cond.object.itemkey_desc[ll_row]
ls_itemtype     = dw_cond.object.itemtype[ll_row]
ls_pgmcode      = dw_cond.object.pgmcode[ll_row]
iu_cust_msg.idw_data[1].AcceptText()
//ll_rows = iu_cust_msg.idw_data[1].RowCount()
							

//해당 PricePlan으로 Setting
ll_new_row = iu_cust_msg.idw_data[1].Insertrow(iu_cust_msg.idw_data[1].GetRow()+1)

iu_cust_msg.idw_data[1].ScrollToRow(ll_new_row)

iu_cust_msg.idw_data[1].object.itemkey[ll_new_row]      = ll_itemkey
iu_cust_msg.idw_data[1].object.itemkey_desc[ll_new_row] = ls_itemkey_desc
iu_cust_msg.idw_data[1].object.itemtype[ll_new_row]     = ls_itemtype
iu_cust_msg.idw_data[1].object.pgmcode[ll_new_row]      = ls_pgmcode
iu_cust_msg.idw_data[1].object.invf_type[ll_new_row]    = iu_cust_msg.is_data[1]
iu_cust_msg.idw_data[1].object.record[ll_new_row]       = iu_cust_msg.is_data[2]

//복사한다.
//dw_check.RowsCopy(1,dw_check.RowCount(), &
//								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)
//	

//For i = ll_row To ll_row
//	iu_cust_msg.idw_data[1].object.priceplan[i] = ls_priceplan_old
//	iu_cust_msg.idw_data[1].object.pgm_id[i]	= ls_pgm_id
//	iu_cust_msg.idw_data[1].object.crt_user[i] = gs_user_id
//	iu_cust_msg.idw_data[1].object.crtdt[1] = ldt_sysdate
//	iu_cust_msg.idw_data[1].object.updt_user[i] = gs_user_id
//	iu_cust_msg.idw_data[1].object.updtdt[1] = ldt_sysdate
//Next

end event

type dw_check from u_d_base within b5w_inq_billfile_record_detail_popup
boolean visible = false
integer x = 37
integer y = 408
integer width = 2555
integer height = 672
integer taborder = 20
string dataobject = "b0dw_reg_zoncst3_check"
borderstyle borderstyle = stylebox!
end type

type dw_cond from u_d_external within b5w_inq_billfile_record_detail_popup
integer x = 50
integer y = 56
integer width = 2327
integer height = 1184
integer taborder = 10
string dataobject = "b5dw_inq_billfile_record_detail_popup"
boolean hsplitscroll = true
end type

event rowfocuschanged;call super::rowfocuschanged;
If currentrow = 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
End If
end event

type p_close from u_p_close within b5w_inq_billfile_record_detail_popup
integer x = 2510
integer y = 256
boolean originalsize = false
end type

type p_ok from u_p_ok within b5w_inq_billfile_record_detail_popup
integer x = 2510
integer y = 44
end type

type gb_1 from groupbox within b5w_inq_billfile_record_detail_popup
integer x = 37
integer y = 8
integer width = 2363
integer height = 1252
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

