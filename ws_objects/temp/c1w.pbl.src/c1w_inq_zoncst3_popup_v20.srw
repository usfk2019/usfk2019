$PBExportHeader$c1w_inq_zoncst3_popup_v20.srw
$PBExportComments$[ohj] 홀세일 대역별 요율 등록 popup v20
forward
global type c1w_inq_zoncst3_popup_v20 from w_base
end type
type dw_check from u_d_base within c1w_inq_zoncst3_popup_v20
end type
type p_close from u_p_close within c1w_inq_zoncst3_popup_v20
end type
type p_ok from u_p_ok within c1w_inq_zoncst3_popup_v20
end type
type dw_cond from u_d_external within c1w_inq_zoncst3_popup_v20
end type
type gb_1 from groupbox within c1w_inq_zoncst3_popup_v20
end type
end forward

global type c1w_inq_zoncst3_popup_v20 from w_base
integer width = 1851
integer height = 564
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
global c1w_inq_zoncst3_popup_v20 c1w_inq_zoncst3_popup_v20

type variables
DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col)
end prototypes

event ue_close;Close(This)
end event

event ue_ok();//표준 요금 조회
String   ls_priceplan, ls_pgm_id, ls_priceplan_old, ls_svccod, ls_svccod_old
Long     ll_row, i, ll_baserate, ll_addrate, ll_cnt
Dec{6}   ldc_baseamt, ldc_addamt, ldc_baseamt_1, ldc_unitfee_1
Dec{6}   ldc_unitfee_2, ldc_unitfee_3, ldc_unitfee_4, ldc_unitfee_5
DateTime ldt_sysdate
Integer   li_result

dw_cond.accepttext()
ldt_sysdate = fdt_get_dbserver_now() 

ls_priceplan     = fs_snvl(dw_cond.object.priceplan[1], '')
ls_svccod        = fs_snvl(dw_cond.object.svccod[1]   , '')
ls_priceplan_old = iu_cust_msg.is_data[1]
ls_pgm_id        = iu_cust_msg.is_data[2]
ls_svccod_old    = iu_cust_msg.is_data[3]
ldc_baseamt      = dw_cond.object.baseamt[1]
ll_baserate      = dw_cond.object.baserate[1]
ll_addrate       = dw_cond.object.addrate[1]
ldc_addamt       = dw_cond.object.addamt[1]

//필수 항목 Check
If ls_svccod = "" Then
	f_msg_info(200, Title,"Service Code")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
   Return
End If

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

If ls_svccod_old = ls_svccod And ls_priceplan_old = ls_priceplan Then 
	f_msg_usr_err(9000, Title, "Copy하려는 서비스/가격정책과 동일합니다. ~r~n" + &
	                           " 다시 선택하십시오.")
	
	dw_cond.SetFocus()
	
	dw_cond.SetColumn("svccod")
		
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
ll_row = dw_check.Retrieve(ls_svccod, ls_priceplan)
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
	iu_cust_msg.idw_data[1].object.svccod[i]    = ls_svccod_old
	iu_cust_msg.idw_data[1].object.priceplan[i] = ls_priceplan_old
	iu_cust_msg.idw_data[1].object.pgm_id[i]	  = ls_pgm_id
	iu_cust_msg.idw_data[1].object.crt_user[i]  = gs_user_id
	iu_cust_msg.idw_data[1].object.crtdt[i]     = ldt_sysdate
	iu_cust_msg.idw_data[1].object.updt_user[i] = gs_user_id
	iu_cust_msg.idw_data[1].object.updtdt[i]    = ldt_sysdate
Next

end event

public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col);String ls_svccod, ls_Doc_D1, ls_sql

dataWindowChild	dwc_child

adw_obj.GetChild (as_col, dwc_child)
dwc_child.SetTransObject (SQLCA)

adw_obj.Accepttext()

Choose Case lower (as_col)
	Case "priceplan" 
		ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')
		ls_sql  = "		SELECT DISTINCT 'ALL' PRICEPLAN_DESC               " &
		        + "         , 'ALL' PRICEPLAN                             " &
				  + "         , 'ALL' svccod                                " &
				  + "      FROM PRICEPLANMST                                " &
				  + "     WHERE PRICETABLE = (SELECT REF_CONTENT            " & 
				  + "                           FROM SYSCTL1T               " &
				  + "                          WHERE MODULE = 'B0'          " & 
				  + "                            AND REF_NO = 'P100')       " &
				  + " UNION ALL                                             " &
				  + "    SELECT priceplan_desc, priceplan, svccod           " &
				  + "      FROM priceplanmst                                " &
				  + "     WHERE use_yn ='Y'                                 " &
				  + "       and pricetable = (select ref_content            " &
				  + "                           from sysctl1t               " &
				  + "                          where module = 'B0'          " &
				  + "                            and ref_no = 'P100')       " &
				  + "       AND SVCCOD     = '" + ls_svccod +             "'" &
				  + "  ORDER BY priceplan, priceplan_desc                   " 
				  
	Case Else
	
		dwc_child.Retrieve ()

End Choose

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

dwc_child.Retrieve ()
//adw_obj.uf_MatchDDDW (as_col)

Return 0
end function

on c1w_inq_zoncst3_popup_v20.create
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

on c1w_inq_zoncst3_popup_v20.destroy
call super::destroy
destroy(this.dw_check)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.dw_cond)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	:c1w_inq_zoncst3_popup_v20
	Desc.	: 표준 요금 Load
	Ver.	: 1.0
	Date	: 2005.04.18
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row
String ls_svccod, ls_filter

f_center_window(c1w_inq_zoncst3_popup_v20)

dw_cond.object.svccod[1]    = iu_cust_msg.is_data[3] 
dw_cond.object.priceplan[1] = iu_cust_msg.is_data[1]
	
ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')

dw_cond.Setfocus()

//서비스별로 가격정책가져오기 all포함
ll_row = dw_cond.GetChild("priceplan", idc_itemcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "svccod IN ('ALL', '" + ls_svccod + "') "
idc_itemcod.SetFilter(ls_filter)			//Filter정함
idc_itemcod.Filter()
idc_itemcod.SetTransObject(SQLCA)
ll_row =idc_itemcod.Retrieve()

dw_cond.SetColumn("priceplan")

Return 0 

end event

type dw_check from u_d_base within c1w_inq_zoncst3_popup_v20
boolean visible = false
integer x = 23
integer y = 472
integer width = 2555
integer height = 672
integer taborder = 20
string dataobject = "c1dw_reg_zoncst3_check_v20"
borderstyle borderstyle = stylebox!
end type

type p_close from u_p_close within c1w_inq_zoncst3_popup_v20
integer x = 1527
integer y = 164
boolean originalsize = false
end type

type p_ok from u_p_ok within c1w_inq_zoncst3_popup_v20
integer x = 1527
integer y = 48
end type

type dw_cond from u_d_external within c1w_inq_zoncst3_popup_v20
integer x = 46
integer y = 56
integer width = 1330
integer height = 332
integer taborder = 10
string dataobject = "c1dw_cnd_reg_standard_zoncst3_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;String ls_svccod, ls_filter
Long   ll_row

dw_cond.Accepttext()

ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')

//서비스별 가격정책 가져오기 all포함 
ll_row = dw_cond.GetChild("priceplan", idc_itemcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "svccod IN ('ALL', '" + ls_svccod + "') "
idc_itemcod.SetFilter(ls_filter)			//Filter정함
idc_itemcod.Filter()
idc_itemcod.SetTransObject(SQLCA)
ll_row =idc_itemcod.Retrieve()

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
Else
	dw_cond.SetColumn("priceplan")	//찾았을 경우 적용이 빨리 안되서
End If

end event

event clicked;call super::clicked;//wf_dropdownlist(This, This.getrow(), This.GetColumnName())
end event

type gb_1 from groupbox within c1w_inq_zoncst3_popup_v20
integer x = 27
integer width = 1399
integer height = 432
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

