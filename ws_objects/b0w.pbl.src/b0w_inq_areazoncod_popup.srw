$PBExportHeader$b0w_inq_areazoncod_popup.srw
$PBExportComments$[cuesee] 표준 대역 load 파업
forward
global type b0w_inq_areazoncod_popup from w_base
end type
type dw_check from u_d_base within b0w_inq_areazoncod_popup
end type
type p_close from u_p_close within b0w_inq_areazoncod_popup
end type
type p_ok from u_p_ok within b0w_inq_areazoncod_popup
end type
type dw_cond from u_d_external within b0w_inq_areazoncod_popup
end type
type gb_1 from groupbox within b0w_inq_areazoncod_popup
end type
end forward

global type b0w_inq_areazoncod_popup from w_base
integer width = 1769
integer height = 420
string title = "표준대역 Load"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
dw_check dw_check
p_close p_close
p_ok p_ok
dw_cond dw_cond
gb_1 gb_1
end type
global b0w_inq_areazoncod_popup b0w_inq_areazoncod_popup

event ue_close;Close(This)
end event

event ue_ok;//표준 대역 조회
String ls_nodeno, ls_nodeno_old, ls_priceplan, ls_pgm_id, ls_priceplan_old
Long ll_row, i, ll_row_count

ls_nodeno = Trim(dw_cond.object.nodeno[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_pgm_id = iu_cust_msg.is_data[3]
ls_nodeno_old = iu_cust_msg.is_data[1]
ls_priceplan_old = iu_cust_msg.is_data[2] 

If IsNull(ls_nodeno) Then ls_nodeno = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""

If ls_priceplan = "" Then
	f_msg_info(200, Title, "가격정책")
	dw_cond.SetColumn("priceplan")
	Return
End If

If ls_nodeno = "" Then
	f_msg_info(200, Title, "발신지")
	dw_cond.SetColumn("nodeno")
	Return
End If

//Retrieve
ll_row = dw_check.Retrieve(ls_priceplan, ls_nodeno)
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

//복사한다.
dw_check.RowsCopy(1,dw_check.RowCount(), &
								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)

//해당 PricePlan으로 Setting
ll_row = iu_cust_msg.idw_data[1].RowCount()
For i = 1 To ll_row
	//보내온 priceplan으로 setting을 다시 해야 한다.
	iu_cust_msg.idw_data[1].object.arezoncod_pricecod[i] = ls_priceplan_old
	iu_cust_msg.idw_data[1].object.arezoncod_nodeno[i] = ls_nodeno_old
	iu_cust_msg.idw_data[1].object.arezoncod_pgm_id[i]	= ls_pgm_id
	iu_cust_msg.idw_data[1].object.arezoncod_crt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.arezoncod_crtdt[1] = fdt_get_dbserver_now()
	iu_cust_msg.idw_data[1].object.arezoncod_updt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.arezoncod_updtdt[1] = fdt_get_dbserver_now()
Next


end event

on b0w_inq_areazoncod_popup.create
int iCurrent
call super::create
this.dw_check=create dw_check
this.p_close=create p_close
this.p_ok=create p_ok
this.dw_cond=create dw_cond
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_check
this.Control[iCurrent+2]=this.p_close
this.Control[iCurrent+3]=this.p_ok
this.Control[iCurrent+4]=this.dw_cond
this.Control[iCurrent+5]=this.gb_1
end on

on b0w_inq_areazoncod_popup.destroy
call super::destroy
destroy(this.dw_check)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.dw_cond)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b0w_inq_areazoncod_popup
	Desc.	: 표준 대역 Load
	Ver.	: 1.0
	Date	: 2002.09.25
	Programer : Choi Bo Ra(ceusee)
---------------------------------------------------------*/
Long   ll_row
String ls_nodeno

f_center_window(b0w_inq_areazoncod_popup)
ls_nodeno = iu_cust_msg.is_data[1]
dw_cond.object.nodeno[1] = ls_nodeno 
dw_cond.object.priceplan[1] = iu_cust_msg.is_data[2]

Return 0 

end event

type dw_check from u_d_base within b0w_inq_areazoncod_popup
boolean visible = false
integer x = 18
integer y = 332
integer width = 3173
integer height = 508
integer taborder = 20
boolean bringtotop = true
string dataobject = "b0dw_reg_areazoncod_check"
end type

type p_close from u_p_close within b0w_inq_areazoncod_popup
integer x = 1431
integer y = 172
boolean originalsize = false
end type

type p_ok from u_p_ok within b0w_inq_areazoncod_popup
integer x = 1431
integer y = 48
end type

type dw_cond from u_d_external within b0w_inq_areazoncod_popup
integer x = 41
integer y = 40
integer width = 1266
integer height = 216
integer taborder = 10
string dataobject = "b0dw_cnd_reg_standard_zone"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type gb_1 from groupbox within b0w_inq_areazoncod_popup
integer x = 23
integer width = 1312
integer height = 276
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

