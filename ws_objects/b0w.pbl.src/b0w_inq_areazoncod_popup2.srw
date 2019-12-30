$PBExportHeader$b0w_inq_areazoncod_popup2.srw
$PBExportComments$[kem] 표준 대역 load 팝업2
forward
global type b0w_inq_areazoncod_popup2 from w_base
end type
type dw_check from u_d_base within b0w_inq_areazoncod_popup2
end type
type p_close from u_p_close within b0w_inq_areazoncod_popup2
end type
type p_ok from u_p_ok within b0w_inq_areazoncod_popup2
end type
type dw_cond from u_d_external within b0w_inq_areazoncod_popup2
end type
type gb_1 from groupbox within b0w_inq_areazoncod_popup2
end type
end forward

global type b0w_inq_areazoncod_popup2 from w_base
integer width = 1769
integer height = 380
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
global b0w_inq_areazoncod_popup2 b0w_inq_areazoncod_popup2

event ue_close;Close(This)
end event

event ue_ok();//표준 대역 조회
String ls_nodeno, ls_nodeno_old, ls_pgm_id
Long ll_row, i, ll_row_count, ll_cnt
Integer li_result

ls_nodeno = Trim(dw_cond.object.nodeno[1])
ls_pgm_id = iu_cust_msg.is_data[2]
ls_nodeno_old = iu_cust_msg.is_data[1]


If IsNull(ls_nodeno) Then ls_nodeno = ""

If ls_nodeno = "" Then
	f_msg_info(200, Title, "발신지")
	dw_cond.SetColumn("nodeno")
	Return
End If

//2003.10.15 김은미 수정
// 지역별 대역정의 DW의 Rowcount가 있는지 알아와서 Message 처리
iu_cust_msg.idw_data[1].AcceptText()
ll_cnt = iu_cust_msg.idw_data[1].RowCount()

If ll_cnt > 0 Then
	li_result = f_msg_ques_yesno2(3000,title,"",2)
	If li_result = 2 Then
		Return
	End If
End If

//Retrieve
ll_row = dw_check.Retrieve(ls_nodeno)
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
	iu_cust_msg.idw_data[1].object.arezoncod2_nodeno[i]    = ls_nodeno_old
	iu_cust_msg.idw_data[1].object.arezoncod2_pgm_id[i]    = ls_pgm_id
	iu_cust_msg.idw_data[1].object.arezoncod2_crt_user[i]  = gs_user_id
	iu_cust_msg.idw_data[1].object.arezoncod2_crtdt[1]     = fdt_get_dbserver_now()
	iu_cust_msg.idw_data[1].object.arezoncod2_updt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.arezoncod2_updtdt[1]    = fdt_get_dbserver_now()
Next


end event

on b0w_inq_areazoncod_popup2.create
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

on b0w_inq_areazoncod_popup2.destroy
call super::destroy
destroy(this.dw_check)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.dw_cond)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b0w_inq_areazoncod_popup2
	Desc.	: 표준 대역 Load
	Ver.	: 1.0
	Date	: 2003.10.01
	Programer : Kim Eun Mi(kem)
---------------------------------------------------------*/
Long   ll_row
String ls_nodeno

f_center_window(b0w_inq_areazoncod_popup2)
ls_nodeno = iu_cust_msg.is_data[1]
dw_cond.object.nodeno[1] = ls_nodeno 

Return 0 

end event

type dw_check from u_d_base within b0w_inq_areazoncod_popup2
boolean visible = false
integer x = 18
integer y = 332
integer width = 3173
integer height = 508
integer taborder = 20
boolean bringtotop = true
string dataobject = "b0dw_reg_areazoncod_check2"
end type

type p_close from u_p_close within b0w_inq_areazoncod_popup2
integer x = 1431
integer y = 156
boolean originalsize = false
end type

type p_ok from u_p_ok within b0w_inq_areazoncod_popup2
integer x = 1431
integer y = 48
end type

type dw_cond from u_d_external within b0w_inq_areazoncod_popup2
integer x = 41
integer y = 40
integer width = 1266
integer height = 200
integer taborder = 10
string dataobject = "b0dw_cnd_reg_standard_zone2"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type gb_1 from groupbox within b0w_inq_areazoncod_popup2
integer x = 23
integer width = 1312
integer height = 268
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

