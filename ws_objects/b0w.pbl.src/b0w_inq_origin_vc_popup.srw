$PBExportHeader$b0w_inq_origin_vc_popup.srw
$PBExportComments$[parkkh] 발신지 Copy popup
forward
global type b0w_inq_origin_vc_popup from w_base
end type
type dw_check from u_d_base within b0w_inq_origin_vc_popup
end type
type dw_cond from u_d_external within b0w_inq_origin_vc_popup
end type
type p_close from u_p_close within b0w_inq_origin_vc_popup
end type
type p_ok from u_p_ok within b0w_inq_origin_vc_popup
end type
type gb_1 from groupbox within b0w_inq_origin_vc_popup
end type
end forward

global type b0w_inq_origin_vc_popup from w_base
integer width = 1678
integer height = 400
string title = "표준대역 Load"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
dw_check dw_check
dw_cond dw_cond
p_close p_close
p_ok p_ok
gb_1 gb_1
end type
global b0w_inq_origin_vc_popup b0w_inq_origin_vc_popup

event ue_close;Close(This)
end event

event ue_ok();//표준 요금 조회
String ls_sacnum, ls_pgm_id, ls_sacnum_old
Long ll_row, i, ll_baserate, ll_addrate
Dec{6} ldc_baseamt, ldc_addamt, ldc_baseamt_1, ldc_unitfee_1
Dec{6} ldc_unitfee_2, ldc_unitfee_3, ldc_unitfee_4, ldc_unitfee_5
DateTime ldt_sysdate

dw_cond.accepttext()

ldt_sysdate = fdt_get_dbserver_now() 

ls_sacnum = Trim(dw_cond.object.sacnum[1])
ls_sacnum_old = iu_cust_msg.is_data[1]
ls_pgm_id = iu_cust_msg.is_data[2]

If IsNull(ls_sacnum) Then ls_sacnum = ""

//필수 항목 Check
If ls_sacnum = "" Then
	f_msg_info(200, Title,"접속번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("sacnum")
   Return
End If

//Retrieve
ll_row = dw_check.Retrieve(ls_sacnum)
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

//복사한다.
dw_check.RowsCopy(1,dw_check.RowCount(), &
								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)

//해당 sacnum으로 Setting
ll_row = iu_cust_msg.idw_data[1].RowCount()
For i = 1 To ll_row
	iu_cust_msg.idw_data[1].object.sacnum[i] = ls_sacnum_old
	iu_cust_msg.idw_data[1].object.pgm_id[i]	= ls_pgm_id
	iu_cust_msg.idw_data[1].object.crt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.crtdt[1] = ldt_sysdate
	iu_cust_msg.idw_data[1].object.updt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.updtdt[1] = ldt_sysdate
Next
end event

on b0w_inq_origin_vc_popup.create
int iCurrent
call super::create
this.dw_check=create dw_check
this.dw_cond=create dw_cond
this.p_close=create p_close
this.p_ok=create p_ok
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_check
this.Control[iCurrent+2]=this.dw_cond
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.p_ok
this.Control[iCurrent+5]=this.gb_1
end on

on b0w_inq_origin_vc_popup.destroy
call super::destroy
destroy(this.dw_check)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b0w_inq_origin_vc_popup
	Desc.	: 발신지 Copy
	Ver.	: 1.0
	Date	: 2003.12.19
	Programer : Park Kyung Hae(parkkh)
---------------------------------------------------------*/

f_center_window(b0w_inq_origin_vc_popup)

Return 0 

end event

type dw_check from u_d_base within b0w_inq_origin_vc_popup
boolean visible = false
integer x = 27
integer y = 340
integer width = 1929
integer height = 672
integer taborder = 20
string dataobject = "b0dw_reg_origin_vc_check"
borderstyle borderstyle = stylebox!
end type

type dw_cond from u_d_external within b0w_inq_origin_vc_popup
integer x = 46
integer y = 80
integer width = 1147
integer height = 156
integer taborder = 10
string dataobject = "b0dw_cnd_reg_origin_vc_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type p_close from u_p_close within b0w_inq_origin_vc_popup
integer x = 1307
integer y = 160
boolean originalsize = false
end type

type p_ok from u_p_ok within b0w_inq_origin_vc_popup
integer x = 1307
integer y = 44
end type

type gb_1 from groupbox within b0w_inq_origin_vc_popup
integer x = 27
integer y = 4
integer width = 1234
integer height = 260
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

