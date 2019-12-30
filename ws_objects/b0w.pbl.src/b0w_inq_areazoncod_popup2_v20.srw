$PBExportHeader$b0w_inq_areazoncod_popup2_v20.srw
$PBExportComments$[ohj] 대역 copy Popup v20
forward
global type b0w_inq_areazoncod_popup2_v20 from w_base
end type
type p_close from u_p_close within b0w_inq_areazoncod_popup2_v20
end type
type p_ok from u_p_ok within b0w_inq_areazoncod_popup2_v20
end type
type dw_cond from u_d_external within b0w_inq_areazoncod_popup2_v20
end type
type gb_1 from groupbox within b0w_inq_areazoncod_popup2_v20
end type
type dw_check from u_d_base within b0w_inq_areazoncod_popup2_v20
end type
end forward

global type b0w_inq_areazoncod_popup2_v20 from w_base
integer width = 2784
integer height = 432
string title = "표준대역 Load"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
p_close p_close
p_ok p_ok
dw_cond dw_cond
gb_1 gb_1
dw_check dw_check
end type
global b0w_inq_areazoncod_popup2_v20 b0w_inq_areazoncod_popup2_v20

type variables
string is_type, is_parttype
end variables

event ue_close;Close(This)
end event

event ue_ok();//표준 대역 조회
String  ls_nodeno, ls_nodeno_old, ls_svccod, ls_svccod_old, ls_pgm_id, ls_where, &
        ls_priceplan, ls_priceplan_old
Long    ll_row, i, ll_row_count, ll_cnt
Integer li_result

ls_nodeno        = fs_snvl(dw_cond.object.nodeno[1]   , '')
ls_svccod        = fs_snvl(dw_cond.object.svccod[1]   , '')
ls_priceplan     = fs_snvl(dw_cond.object.priceplan[1], '')

ls_nodeno_old    = iu_cust_msg.is_data[1]
ls_svccod_old    = iu_cust_msg.is_data[2]
ls_priceplan_old = iu_cust_msg.is_data[5]

ls_pgm_id        = iu_cust_msg.is_data[4]

If is_type = 'Y' Then
	If is_parttype = 'S' Then	
		If ls_svccod = "" Then
			f_msg_info(200, Title, "서비스")
			dw_cond.SetColumn("svccod")
			Return
		End If
			
		If ls_svccod_old = ls_svccod And ls_nodeno_old = ls_nodeno Then 
			f_msg_usr_err(9000, Title, "Copy하려는 발신지와 동일합니다. ~r~n" + &
												" 다시 선택하십시오.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("nodeno")
			Return		
		End If
		
	ElseIf is_parttype = 'P' Then
		If ls_priceplan = "" Then
			f_msg_info(200, Title, "가격정책")
			dw_cond.SetColumn("svccod")
			Return
		End If
			
		SELECT SVCCOD
		  INTO :ls_svccod
		  FROM PRICEPLANMST
		 WHERE PRICEPLAN = :ls_priceplan;
	
		If ls_svccod_old = ls_svccod And ls_priceplan_old = ls_priceplan And ls_nodeno_old = ls_nodeno Then 
			f_msg_usr_err(9000, Title, "Copy하려는 발신지와 동일합니다. ~r~n" + &
												" 다시 선택하십시오.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("nodeno")
			Return		
		End If		
	End If
	
Else
	
	If ls_nodeno = "" Then
		f_msg_info(200, Title, "발신지")
		dw_cond.SetColumn("nodeno")
		Return
	End If
	
	If ls_nodeno_old = ls_nodeno Then 
		f_msg_usr_err(9000, Title, "Copy하려는 발신지와 동일합니다. ~r~n" + &
											" 다시 선택하십시오.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("nodeno")
		Return		
	End If
		
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

ls_where = ""
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.SVCCOD = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.priceplan = '" + ls_priceplan + "' "
End If

//retrieve
dw_check.is_where = ls_where
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
	iu_cust_msg.idw_data[1].object.arezoncod2_svccod[i]    = ls_svccod_old
	iu_cust_msg.idw_data[1].object.arezoncod2_priceplan[i] = ls_priceplan_old
	iu_cust_msg.idw_data[1].object.arezoncod2_nodeno[i]    = ls_nodeno_old
	iu_cust_msg.idw_data[1].object.arezoncod2_pgm_id[i]    = ls_pgm_id
	iu_cust_msg.idw_data[1].object.arezoncod2_crt_user[i]  = gs_user_id
	iu_cust_msg.idw_data[1].object.arezoncod2_crtdt[i]     = fdt_get_dbserver_now()
	//iu_cust_msg.idw_data[1].object.arezoncod2_updt_user[i] = gs_user_id
	//iu_cust_msg.idw_data[1].object.arezoncod2_updtdt[i]    = fdt_get_dbserver_now()
Next


end event

on b0w_inq_areazoncod_popup2_v20.create
int iCurrent
call super::create
this.p_close=create p_close
this.p_ok=create p_ok
this.dw_cond=create dw_cond
this.gb_1=create gb_1
this.dw_check=create dw_check
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_close
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.dw_cond
this.Control[iCurrent+4]=this.gb_1
this.Control[iCurrent+5]=this.dw_check
end on

on b0w_inq_areazoncod_popup2_v20.destroy
call super::destroy
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.dw_cond)
destroy(this.gb_1)
destroy(this.dw_check)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b0w_inq_areazoncod_popup2_v20
	Desc.	: 표준 대역 Load
	Ver.	: 1.0
	Date	: 2005.04.14
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row, li_rc
String ls_nodeno, ls_svccod, ls_priceplan, ls_filter

DataWindowChild ldwc_nodeno

f_center_window(b0w_inq_areazoncod_popup2_v20)

ls_nodeno    = iu_cust_msg.is_data[1]
ls_svccod    = iu_cust_msg.is_data[2]
is_type      = iu_cust_msg.is_data[3]
ls_priceplan = iu_cust_msg.is_data[5]
is_parttype  = iu_cust_msg.is_data[6]

If is_type = 'Y' Then
	dw_cond.dataObject = "b0dw_cnd_reg_standard_zone2_svc_v20"
	dw_cond.SetTransObject(SQLCA)
	dw_cond.insertrow(0)
	
	If is_parttype = 'S' Then
		dw_cond.Object.priceplan.Visible   = 0
		dw_cond.Object.priceplan_t.Visible = 0		
		dw_cond.Object.svccod.Visible   = 1
		dw_cond.Object.svccod_t.Visible = 1
		dw_cond.Object.priceplan[1] = 'ALL'
		
		li_rc = dw_cond.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + ls_svccod + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "Nodeno Retrieve()")
			Return
		End If
		
	ElseIf is_parttype = 'P' Then 
		dw_cond.Object.priceplan.Visible   = 1
		dw_cond.Object.priceplan_t.Visible = 1
		dw_cond.Object.svccod.Visible   = 0
		dw_cond.Object.svccod_t.Visible = 0
		
		dw_cond.Object.svccod[1] = 'ALL'
		
		SELECT SVCCOD
	  	  INTO :ls_svccod
	     FROM PRICEPLANMST
	    WHERE PRICEPLAN = :ls_priceplan;
		
		li_rc = dw_cond.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + ls_svccod + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "Nodeno Retrieve()")
			Return
		End If				
	End If			
Else
	dw_cond.dataObject = "b0dw_cnd_reg_standard_zone2_v20"
	dw_cond.SetTransObject(SQLCA)
	dw_cond.insertrow(0)
	dw_cond.SetItem(1, 'svccod'   , 'ALL')
	dw_cond.SetItem(1, 'priceplan', 'ALL')
	
	li_rc = dw_cond.GetChild("nodeno", ldwc_nodeno)
	If li_rc < 0 Then
		f_msg_usr_err(9000, Title, "GetChild : nodeno")
		Return
	End If
	
	ls_filter = "b.svccod = 'ALL' "
	ldwc_nodeno.SetFilter(ls_filter)
	ldwc_nodeno.Filter()
	
	ldwc_nodeno.SetTransObject(SQLCA)
	
	li_rc = ldwc_nodeno.Retrieve()
	If li_rc < 0 Then
		f_msg_usr_err(9000, Title, "Nodeno Retrieve()")
		Return
	End If	
End If

dw_cond.object.svccod[1]    = ls_svccod 
dw_cond.object.priceplan[1] = ls_priceplan 
dw_cond.object.nodeno[1]    = ls_nodeno 

Return 0 

end event

type p_close from u_p_close within b0w_inq_areazoncod_popup2_v20
integer x = 1714
integer y = 172
boolean originalsize = false
end type

type p_ok from u_p_ok within b0w_inq_areazoncod_popup2_v20
integer x = 1714
integer y = 64
end type

type dw_cond from u_d_external within b0w_inq_areazoncod_popup2_v20
integer x = 55
integer y = 100
integer width = 1367
integer height = 188
integer taborder = 10
string dataobject = "b0dw_cnd_reg_standard_zone2_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;String ls_filter, ls_svccod, ls_priceplan
Int li_rc

DataWindowChild ldwc_nodeno

Choose Case dwo.Name
	Case "svccod"
		// dddw change
//		dw_cond.Modify("nodeno.dddw.name = 'b0dc_dddw_nodeno_v20'")
//		dw_cond.Modify("nodeno.dddw.datacolumn = 'nodeno'")
//		dw_cond.Modify("nodeno.dddw.displayColumn = 'codenm'")
//		dw_cond.Modify("nodeno.dddw.UseAsBorder = 'Yes'")
//		dw_cond.Modify("nodeno.dddw.VScrollBar	= 'Yes'")
		
		dw_cond.object.nodeno[1] = ''
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + data + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
	Case "priceplan"
		
		SELECT SVCCOD
	  	  INTO :ls_svccod
	     FROM PRICEPLANMST
	    WHERE PRICEPLAN = :data;
		 
		dw_cond.object.nodeno[1] = ''		
		
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + ls_svccod + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
		
	Case "nodeno"
		If is_type = 'Y' Then  //
			If is_parttype = "S" Then			
				
				ls_svccod = fs_snvl(dw_cond.Object.svccod[1], '')
				
				If ls_svccod = '' Then
					f_msg_info(9000, parent.title,  "서비스를 먼저 선택하여 주십시오.")
					This.Object.nodeno[1] = ""
					Return 2
				End If
				
			Else
				ls_priceplan = fs_snvl(dw_cond.Object.priceplan[1], '')
				
				If ls_priceplan = '' Then
					f_msg_info(9000, parent.title,  "가격정책을 먼저 선택하여 주십시오.")
					This.Object.nodeno[1] = ""
					Return 2
				End If
				
			End If
			
		End If
		
End Choose

end event

type gb_1 from groupbox within b0w_inq_areazoncod_popup2_v20
integer x = 23
integer width = 1614
integer height = 320
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

type dw_check from u_d_base within b0w_inq_areazoncod_popup2_v20
boolean visible = false
integer x = 18
integer y = 332
integer width = 3173
integer height = 508
integer taborder = 20
string dataobject = "b0dw_reg_areazoncod_check2_v20"
end type

