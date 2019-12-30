﻿$PBExportHeader$b1w_inq_inv_detail_cv.srw
$PBExportComments$[ceusee] 청구및 상세내역 조회(전화사용제외)
forward
global type b1w_inq_inv_detail_cv from w_a_inq_m_tm
end type
type dw_cond2 from u_d_help within b1w_inq_inv_detail_cv
end type
type p_find from u_p_find within b1w_inq_inv_detail_cv
end type
end forward

global type b1w_inq_inv_detail_cv from w_a_inq_m_tm
integer width = 3424
integer height = 2076
boolean resizable = false
event ue_find ( )
dw_cond2 dw_cond2
p_find p_find
end type
global b1w_inq_inv_detail_cv b1w_inq_inv_detail_cv

type variables
Boolean ib_ctype3
end variables

forward prototypes
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public subroutine of_resizepanels ()
end prototypes

event ue_find();Long ll_rc, ll_selrow
Integer li_curtab, li_return
String ls_where, ls_customerid, ls_payid, ls_sale_month
String ls_workdt_fr, ls_workdt_to, ls_tr_month

dw_cond2.AcceptText()

li_curtab = tab_1.selectedtab
ll_selrow = dw_master.GetSelectedRow(0)
If Not (ll_selrow > 0) Then Return
ls_payid = dw_master.Object.customerm_payid[ll_selrow]
If IsNull(ls_payid) Or ls_payid = "" Then Return
ls_customerid = dw_master.Object.customerm_customerid[ll_selrow]
If IsNull(ls_customerid) Or ls_customerid = "" Then Return

Choose Case li_curtab
	Case 4	        //판매내역 tab
		
//		***** 사용자 입력사항 변수에 대입 *****
		ls_sale_month = Trim(dw_cond2.Object.yyyymm[1])
		If isnull(ls_sale_month) Then ls_sale_month = ""
		
		ls_where = " payid = '" + ls_payid + "' "
		
//    년월형식 check
	   If ls_sale_month <> "" Then
			If Isdate(LeftA(ls_sale_month,4) + "/" + RightA(ls_sale_month,2) + "/01") Then
			else
				f_msg_usr_err(211, This.Title, "판매년월")
				dw_cond2.setfocus()
				dw_cond2.SetColumn("yyyymm")
				Return
			End if
			ls_where += " And to_char(sale_month,'yyyymm') = '" + ls_sale_month + "' "			
	   End if

		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)		

	Case 5
//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
		

		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "통화일(From) <= 통화일(To)")
					Return
				End If
			End If
		End If

		ls_where = " payid = '" + ls_payid + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(workdt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(workdt,'yyyymmdd') <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)

	Case 6
//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		ls_tr_month = trim(dw_cond2.Object.yyyymm[1])
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
		If Isnull(ls_tr_month) Then ls_tr_month = ""		
		
		If ls_tr_month = "" Then
			f_msg_usr_err(211, This.Title, "청구년월")
			dw_cond2.setfocus()
			dw_cond2.SetColumn("yyyymm")
			Return
		End If

		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "통화일(From) <= 통화일(To)")
					Return
				End If
			End If
		End If
		
//    년월형식 check
		If Isdate(LeftA(ls_tr_month,4) + "/" + RightA(ls_tr_month,2) + "/01") Then
		else
			f_msg_usr_err(211, This.Title, "청구년월")
			dw_cond2.setfocus()
			dw_cond2.SetColumn("yyyymm")
			Return
   	End if			

		ls_where = " payid = '" + ls_payid + "' "
		ls_where += " And to_char(trdt,'yyyymm') = '" + ls_tr_month + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(workdt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(workdt,'yyyymmdd') <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
		
End Choose
end event

public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check);//선불 고객인지 확인
String ls_ctype3
ab_check = False
	
	select ctype3 
	into :ls_ctype3
	from customerm
	where customerid = :as_customerid;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("선불고객", "Select customerm Table")
		Return 0
	End If
	
	If ls_ctype3 = "0" Then
		ab_check = True
	Else
		ab_check = False
	End If
 
Return 0
end function

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.
Integer	li_index

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

For li_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_index].Height = tab_1.Height - 125
Next

end subroutine

on b1w_inq_inv_detail_cv.create
int iCurrent
call super::create
this.dw_cond2=create dw_cond2
this.p_find=create p_find
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cond2
this.Control[iCurrent+2]=this.p_find
end on

on b1w_inq_inv_detail_cv.destroy
call super::destroy
destroy(this.dw_cond2)
destroy(this.p_find)
end on

event ue_ok();call super::ue_ok;//조회
String ls_customerid, ls_customername, ls_payid, ls_logid, ls_value, ls_name
String ls_ssno, ls_corpno, ls_corpnm, ls_cregno, ls_phone, ls_status
String ls_ctype1, ls_ctype2, ls_ctype3, ls_macod, ls_location, ls_new, ls_where
String ls_enterdtfrom, ls_enterdtto, ls_termdtfrom, ls_termdtto
String ls_buildingno, ls_roomno
Date ld_enterdtfrom, ld_enterdtto, ld_termdtfrom, ld_termdtto
Integer li_check
Long ll_row

tab_1.Enabled = True
//p_find.TriggerEvent("ue_enable")

ls_value = Trim(dw_cond.object.value[1])
ls_name = Trim(dw_cond.object.name[1])
ls_location = Trim(dw_cond.object.location[1])
ls_buildingno = Trim(dw_cond.object.buildingno[1])
ls_roomno = Trim(dw_cond.object.roomno[1])


If IsNull(ls_value) Then ls_value = ""
If IsNull(ls_name) Then ls_name = ""
If IsNull(ls_location) Then ls_location = ""
If IsNull(ls_buildingno) Then ls_buildingno = ""
If IsNull(ls_roomno) Then ls_roomno = ""

IF ls_location = "" AND ls_buildingno = "" AND ls_roomno = "" THEN
	If ls_value = "" Then
		f_msg_info(200, Title, "조건항목")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If
	
	If ls_name = "" Then
		f_msg_info(200, Title, "조건내역")
		dw_cond.SetFocus()
		dw_cond.setColumn("name")
		Return 
	End If
END IF


ls_where = ""
If ls_value <> "" Then
	If ls_name <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_value
			Case "customerid"
				ls_where += "cus.customerid like '" + ls_name + "%' "
			Case "customernm"
				ls_where += "Upper(cus.customernm) like '%" + Upper(ls_name) + "%' "
			Case "payid"
				ls_where += "cus.payid like '" + ls_name + "%' "
			Case "logid"
				ls_where += "Upper(cus.logid) like '" + Upper(ls_name) + "%' "
			Case "ssno"
				ls_where += "cus.ssno like '" + ls_name + "%' "
			Case "corpno"
				ls_where += "cus.corpno like '" + ls_name + "%' "
			Case "corpnm"
				ls_where += "cus.corpnm like '" + ls_name + "%' "
			Case "cregno"
				ls_where += "cus.cregno like '" + ls_name + "%' "
			Case "phone1"
				ls_where += "cus.phone1 like '" + ls_name + "%' "
		End Choose		
   End If
End If

IF ls_location<> "" THEN
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.location = '" + ls_location + "' "
END IF

IF ls_buildingno<> "" THEN
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.buildingno = '" + ls_buildingno + "' "
END IF

IF ls_roomno<> "" THEN
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.roomno = '" + ls_roomno + "' "
END IF



dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100,Title,"(Master)")
	Return
End If
end event

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b1w_inq_inv_detail
	Desc.	:	청구 및 사용내역 상세 조회
	Ver	: 	1.0
	Date	: 	2002.09.30
	Prgromer : Park Kyung Hae(parkkh)
---------------------------------------------------------------------------*/
Date ld_sysdate
String ls_ref_desc

ld_sysdate = Date(fdt_get_dbserver_now())
p_find.TriggerEvent("ue_disable")
tab_1.Enabled = False
//dw_cond2.Object.workdt_fr[1] = ld_sysdate
//dw_cond2.Object.workdt_to[1] = ld_sysdate

//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)

end event

event resize;call super::resize;Int li_index

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	dw_cond2.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space 
	p_find.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height -125
	Next

	dw_cond2.Y	= newheight - iu_cust_w_resize.ii_button_space 
	p_find.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)
end event

type dw_cond from w_a_inq_m_tm`dw_cond within b1w_inq_inv_detail_cv
integer x = 37
integer y = 44
integer width = 2158
integer height = 208
string dataobject = "b1dw_cnd_inq_inv_detail_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m_tm`p_ok within b1w_inq_inv_detail_cv
integer x = 2341
integer y = 36
end type

type p_close from w_a_inq_m_tm`p_close within b1w_inq_inv_detail_cv
integer x = 2638
integer y = 36
end type

type gb_cond from w_a_inq_m_tm`gb_cond within b1w_inq_inv_detail_cv
integer x = 23
integer width = 2190
integer height = 264
end type

type dw_master from w_a_inq_m_tm`dw_master within b1w_inq_inv_detail_cv
integer x = 23
integer y = 308
integer width = 3310
integer height = 500
string dataobject = "b1dw_inq_inv_detail_m"
end type

event dw_master::ue_init();dwObject ldwo_SORT

ib_sort_use = True
ldwo_SORT = Object.customerm_customernm_t
uf_init(ldwo_SORT)

end event

event dw_master::rowfocuschanged;Long ll_row
ll_row = this.GetRow()
if ll_row < 1 then return
this.SelectRow (0, false)			// Turn off previous highlight
this.SelectRow (ll_row, true)		// Highlight current row


end event

event dw_master::clicked;// Override
CALL w_a_m_master`dw_master::Clicked

Long ll_selected_row
Int li_tab_index

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	For li_tab_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_tab_index].Reset()
		tab_1.ib_tabpage_check[li_tab_index] = False
	Next

	If ll_selected_row > 0 Then
		tab_1.Trigger Event SelectionChanged(1, Tab_1.SelectedTab)
	End If

	// find 화면 보여주는 것...start
	Int li_seltab
	li_seltab = tab_1.SelectedTab
	If IsSelected(row) Then
		Choose Case li_seltab
			Case 1,2,3
				dw_cond2.Visible = False
				p_find.TriggerEvent("ue_disable")
			Case 4,5,6
//				dw_cond2.Object.userid[1] = Object.userhis_userid[row]
				p_find.TriggerEvent("ue_enable")
		End Choose
	Else
//		dw_cond2.Object.userid[1] = ""
		dw_cond2.Visible = False
		p_find.TriggerEvent("ue_disable")
	End If
	// End 
End If


end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
	ib_retrieve = True
//	dw_cond2.Object.userid[1] = Object.userhis_userid[1]	
	
	tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)	
End If

end event

type tab_1 from w_a_inq_m_tm`tab_1 within b1w_inq_inv_detail_cv
integer y = 844
integer width = 3314
integer height = 892
end type

event tab_1::ue_init();call super::ue_init;//Tab Control의 Parent
iw_parent = parent  
//사용할 Tab Page의 갯수 (15 이하)
ii_enable_max_tab = 4

//Tab Page에 들어갈 title
is_tab_title[1] = "청구내역"
is_tab_title[2] = "청구내역History"
is_tab_title[3] = "입금내역"
is_tab_title[4] = "판매내역"


//Tab Page에 해당되는  DataWindow 할당
is_dwObject[1] = "b1dw_inq_inv_detail_t1"
is_dwObject[2] = "b1dw_inq_inv_detail_t1"
is_dwObject[3] = "b1dw_inq_inv_detail_t3"
is_dwObject[4] = "b1dw_inq_inv_detail_t4"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);Integer li_rc
Long ll_rc, ll_row
String ls_where
String ls_userid, ls_marknm , ls_payid, ls_paynm, ls_workdt, ls_workdt_to
Date ld_workdt, ld_workdt_to
b1u_dbmgr2 lu_dbmgr2

//Master에 Row 없으면 
If  al_master_row = -1 Then Return -1

//find 추가시 살리자!
li_rc = dw_cond2.AcceptText()
If li_rc <> 1 Then
	f_msg_usr_err(2100, Parent.Title, "dw_cond2.AcceptText()")
	Return -1
End If

dw_master.AcceptText()		
idw_tabpage[ai_select_tabpage].Reset()
ls_payid  = Trim(dw_master.Object.customerm_payid[al_master_row])
ls_paynm = Trim(dw_master.Object.customerm_customernm_1[al_master_row])
If IsNull(ls_payid) Then ls_payid = ""

idw_tabpage[ai_select_tabpage].Object.t_payid.Text = " [ " + ls_payid + " ]  " + ls_paynm + " "
idw_tabpage[ai_select_tabpage].SetRedraw(false)

Choose Case ai_select_tabpage
	Case 1, 2																//Tab 1, Tab 2
		//월별 청구 거래별로 합계 계산...
		//tab1과 tab2는 모두 동등하고 단지... select table만 다름 tab1=>reqdtl, tab2=>reqdtlh
		lu_dbmgr2 = CREATE b1u_dbmgr2
		
		lu_dbmgr2.is_caller = "b1dw_inq_inv_detail_t1%tabpage_retrieve"
		lu_dbmgr2.is_title  = Title
		lu_dbmgr2.is_data[1] = ls_payid
		lu_dbmgr2.is_data[2] = string(ai_select_tabpage)
		lu_dbmgr2.idw_data[1] = idw_tabpage[ai_select_tabpage]
		
		lu_dbmgr2.uf_prc_db()
		li_rc = lu_dbmgr2.ii_rc
		DESTROY lu_dbmgr2

		If li_rc < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case  3
		ls_where  = " PAYID = '" + ls_payid + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_rc = idw_tabpage[ai_select_tabpage].Retrieve()	

		If ll_rc < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rc = 0 Then
			Return 0				
		End If
		
	Case 4
		ls_where = " PAYID = '" + ls_payid + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_rc = idw_tabpage[ai_select_tabpage].Retrieve()	

		If ll_rc < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rc = 0 Then
			Return 0				
		End If
		
End Choose

idw_tabpage[ai_select_tabpage].SetRedraw(true)

DESTROY lu_dbmgr2
Return 0
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부
String ls_trdt

Choose Case ai_tabpage
		
	Case 1, 2
		idw_tabpage[ai_tabpage].accepttext()
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "청구내역상세조회"
		iu_cust_msg.is_grp_name = "청구 및 사용내역 상세조회"
		ls_trdt = idw_tabpage[ai_tabpage].object.trdt[al_row]
		iu_cust_msg.is_data[2] = idw_tabpage[ai_tabpage].object.reqnum[al_row]
		iu_cust_msg.is_data[3] = MidA(ls_trdt, 1, 4) + '-' + MidA(ls_trdt, 5,2) + '-' + MidA(ls_trdt, 7,2)
		iu_cust_msg.is_data[4] = string(al_row)
		
		OpenWithParm(b1w_inq_reqdtl_popup, iu_cust_msg)
		Destroy u_cust_a_msg
	Case 3
		
		idw_tabpage[ai_tabpage].accepttext()
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "입금내역상세조회"
		iu_cust_msg.is_grp_name = "청구 및 사용내역 상세조회"
		iu_cust_msg.is_data[2] = String(idw_tabpage[ai_tabpage].object.seqno[al_row])
		iu_cust_msg.is_data[3] = String(idw_tabpage[ai_tabpage].object.paydt[al_row],'yyyy-mm-dd')
		iu_cust_msg.is_data[4] = Trim(idw_tabpage[ai_tabpage].object.paytype[al_row])
		iu_cust_msg.is_data[5] = string(al_row)
		
		OpenWithParm(b1w_reqpay_popup, iu_cust_msg)
		Destroy u_cust_a_msg
		
End Choose  

Return 0
end event

event tab_1::selectionchanged;call super::selectionchanged;String ls_date, ls_payid, ls_customerid
Long ll_selrow

ll_selrow = dw_master.GetSelectedRow(0)
If ll_selrow > 0 Then 
	ls_payid = dw_master.Object.customerm_payid[ll_selrow]
	ls_customerid = dw_master.Object.customerm_customerid[ll_selrow]
End if	

If IsNull(ls_payid) Then ls_payid = "" 
If IsNull(ls_customerid) Then ls_customerid = "" 

Choose Case newindex
	Case 1,2,3
		p_find.TriggerEvent("ue_disable")
		dw_cond2.Visible = False
		
	Case 4
		p_find.TriggerEvent("ue_enable")
		//fine datawindow을 보여준다.
		dw_cond2.dataobject = "b1dw_cnd_inq_inv_detail3"
		dw_cond2.reset()
		dw_cond2.insertrow(0)
		dw_cond2.Setfocus()
		dw_cond2.Visible = True		

End Choose

idw_tabpage[newindex].Visible	 = True		

end event

type st_horizontal from w_a_inq_m_tm`st_horizontal within b1w_inq_inv_detail_cv
integer y = 808
integer height = 40
end type

type dw_cond2 from u_d_help within b1w_inq_inv_detail_cv
integer x = 23
integer y = 1760
integer width = 1097
integer height = 188
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_cnd_inq_inv_detail2"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_find from u_p_find within b1w_inq_inv_detail_cv
integer x = 1166
integer y = 1768
boolean bringtotop = true
end type
