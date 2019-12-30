$PBExportHeader$b0w_inq_zoncst3_popup.srw
$PBExportComments$[kem] 표준요금 load 파업2
forward
global type b0w_inq_zoncst3_popup from w_base
end type
type dw_check from u_d_base within b0w_inq_zoncst3_popup
end type
type dw_cond from u_d_external within b0w_inq_zoncst3_popup
end type
type p_close from u_p_close within b0w_inq_zoncst3_popup
end type
type p_ok from u_p_ok within b0w_inq_zoncst3_popup
end type
type gb_1 from groupbox within b0w_inq_zoncst3_popup
end type
end forward

global type b0w_inq_zoncst3_popup from w_base
integer width = 1870
integer height = 504
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
global b0w_inq_zoncst3_popup b0w_inq_zoncst3_popup

event ue_close;Close(This)
end event

event ue_ok();//표준 요금 조회
String ls_priceplan, ls_pgm_id, ls_priceplan_old
Long ll_row, i, ll_baserate, ll_addrate, ll_cnt
Dec{6} ldc_baseamt, ldc_addamt, ldc_baseamt_1, ldc_unitfee_1
Dec{6} ldc_unitfee_2, ldc_unitfee_3, ldc_unitfee_4, ldc_unitfee_5
DateTime ldt_sysdate
Integer li_result

dw_cond.accepttext()
ldt_sysdate = fdt_get_dbserver_now() 

ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_priceplan_old = iu_cust_msg.is_data[1]
ls_pgm_id = iu_cust_msg.is_data[2]
ldc_baseamt = dw_cond.object.baseamt[1]
ll_baserate = dw_cond.object.baserate[1]
ll_addrate = dw_cond.object.addrate[1]
ldc_addamt = dw_cond.object.addamt[1]

If IsNull(ls_priceplan) Then ls_priceplan = ""

//필수 항목 Check
If ls_priceplan = "" Then
	f_msg_info(200, Title,"Price Plan")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
   Return
End If

If ll_baserate < 0 Then 
	f_msg_usr_err(201, title, "기본정률")
	dw_cond.SetFocus()
	dw_cond.SetColumn("baserate")
	Return
End If

If ll_addrate < 0 Then 
	f_msg_usr_err(201, title, "요금정률")
	dw_cond.SetFocus()
	dw_cond.SetColumn("addrate")
	Return
End If

//2003.10.15 김은미 수정
//대역별 요율등록 DW의 Rowcount가 있는지 알아와서 Message 처리
iu_cust_msg.idw_data[1].AcceptText()
ll_cnt = iu_cust_msg.idw_data[1].RowCount()

If ll_cnt > 0 Then
	li_result = f_msg_ques_yesno2(3000,title,"",2)
	If li_result = 2 Then
		Return
	End If
End If


//Retrieve
ll_row = dw_check.Retrieve(ls_priceplan)
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If


//데이터 조작
For i = 1 To dw_check.Rowcount()
	If ll_baserate > 0 Or ldc_baseamt <> 0 Then
      ldc_baseamt_1 = dw_check.object.unitfee[i]
		//정액 정률 계산
		ldc_baseamt_1 = (ldc_baseamt_1 * (ll_baserate / 100)) + (ldc_baseamt_1 + ldc_baseamt)
		dw_check.object.unitfee[i] = ldc_baseamt_1
	End If
	
	If ll_addrate > 0 Or ldc_addamt <> 0 Then
      ldc_unitfee_1 = dw_check.object.unitfee1[i]
		ldc_unitfee_2 = dw_check.object.unitfee2[i]
		ldc_unitfee_3 = dw_check.object.unitfee3[i]
		ldc_unitfee_4 = dw_check.object.unitfee4[i]
		ldc_unitfee_5 = dw_check.object.unitfee5[i]
		//정액 정률 계산
		ldc_unitfee_1 = (ldc_unitfee_1 * (ll_addrate / 100)) + (ldc_unitfee_1 + ldc_addamt)
		ldc_unitfee_2 = (ldc_unitfee_2 * (ll_addrate / 100)) + (ldc_unitfee_2 + ldc_addamt)
		ldc_unitfee_3 = (ldc_unitfee_3 * (ll_addrate / 100)) + (ldc_unitfee_3 + ldc_addamt)
		ldc_unitfee_4 = (ldc_unitfee_4 * (ll_addrate / 100)) + (ldc_unitfee_4 + ldc_addamt)
		ldc_unitfee_5 = (ldc_unitfee_5 * (ll_addrate / 100)) + (ldc_unitfee_5 + ldc_addamt)
		dw_check.object.unitfee1[i] = ldc_unitfee_1
		dw_check.object.unitfee2[i] = ldc_unitfee_2
		dw_check.object.unitfee3[i] = ldc_unitfee_3
		dw_check.object.unitfee4[i] = ldc_unitfee_4
		dw_check.object.unitfee5[i] = ldc_unitfee_5
	End If
Next	

//복사한다.
dw_check.RowsCopy(1,dw_check.RowCount(), &
								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)
								

//해당 PricePlan으로 Setting
ll_row = iu_cust_msg.idw_data[1].RowCount()
For i = 1 To ll_row
	iu_cust_msg.idw_data[1].object.priceplan[i] = ls_priceplan_old
	iu_cust_msg.idw_data[1].object.pgm_id[i]	= ls_pgm_id
	iu_cust_msg.idw_data[1].object.crt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.crtdt[1] = ldt_sysdate
	iu_cust_msg.idw_data[1].object.updt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.updtdt[1] = ldt_sysdate
Next

end event

on b0w_inq_zoncst3_popup.create
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

on b0w_inq_zoncst3_popup.destroy
call super::destroy
destroy(this.dw_check)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b0w_inq_zoncst_popup
	Desc.	: 표준 요금 Load
	Ver.	: 1.0
	Date	: 2002.09.26
	Programer : Choi Bo Ra(ceusee)
---------------------------------------------------------*/
Long   ll_row
String ls_itemcod

f_center_window(b0w_inq_zoncst3_popup)
dw_cond.object.priceplan[1] = iu_cust_msg.is_data[1]



Return 0 

end event

type dw_check from u_d_base within b0w_inq_zoncst3_popup
boolean visible = false
integer x = 37
integer y = 408
integer width = 2555
integer height = 672
integer taborder = 20
string dataobject = "b0dw_reg_zoncst3_check"
borderstyle borderstyle = stylebox!
end type

type dw_cond from u_d_external within b0w_inq_zoncst3_popup
integer x = 41
integer y = 56
integer width = 1335
integer height = 280
integer taborder = 10
string dataobject = "b0dw_cnd_reg_standard_zoncst3"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type p_close from u_p_close within b0w_inq_zoncst3_popup
integer x = 1527
integer y = 164
boolean originalsize = false
end type

type p_ok from u_p_ok within b0w_inq_zoncst3_popup
integer x = 1527
integer y = 48
end type

type gb_1 from groupbox within b0w_inq_zoncst3_popup
integer x = 27
integer width = 1399
integer height = 388
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

