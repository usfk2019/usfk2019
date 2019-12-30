$PBExportHeader$c1w_inq_workdt_traffic_v20.srw
$PBExportComments$[parkkh] 일자별트래픽현황(ASR)
forward
global type c1w_inq_workdt_traffic_v20 from w_a_inq_m_tm
end type
type p_saveas from u_p_saveas within c1w_inq_workdt_traffic_v20
end type
end forward

global type c1w_inq_workdt_traffic_v20 from w_a_inq_m_tm
integer width = 2642
integer height = 2076
boolean resizable = false
event ue_saveas ( )
p_saveas p_saveas
end type
global c1w_inq_workdt_traffic_v20 c1w_inq_workdt_traffic_v20

type variables
Boolean ib_ctype3
String  is_format
end variables

forward prototypes
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public subroutine of_resizepanels ()
end prototypes

event ue_saveas();Boolean lb_return
String ls_curdir
u_api lu_api
Long ll_rc, ll_selrow
Integer li_curtab, li_return
String ls_saveas

ls_saveas = dw_cond.object.saveas[1]
If IsNull(ls_saveas) Then ls_saveas = ""

If ls_saveas = "" Then
	f_msg_info(200, Title, "파일저장대상")
	dw_cond.SetColumn("saveas")
	dw_cond.SetFocus()
	Return
End If

li_curtab = tab_1.selectedtab
ll_selrow = dw_master.GetSelectedRow(0)

If ls_saveas = 'M'Then 
	If dw_master.RowCount() <= 0 Then
		f_msg_info(1000, This.Title, "Data exporting")
		Return
	End If

	lu_api = Create u_api
	ls_curdir = lu_api.uf_getcurrentdirectorya()
	If IsNull(ls_curdir) Or ls_curdir = "" Then
		f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
		Destroy lu_api
		Return
	End If
	
	li_return = dw_master.SaveAs("", Excel!, True)
	
	lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
	If li_return <> 1 Then
		f_msg_info(9000, This.Title, "User cancel current job.")
		
	Else
		f_msg_info(9000, This.Title, "Data export finished.")
	End If
	
	Destroy lu_api
ElseIF ls_saveas = 'D' Then
	
	Choose Case li_curtab
		Case 1,2 
			If tab_1.idw_tabpage[li_curtab].RowCount() <= 0 Then
				f_msg_info(1000, This.Title, "Data exporting")
				Return
			End If
	
			lu_api = Create u_api
			ls_curdir = lu_api.uf_getcurrentdirectorya()
			If IsNull(ls_curdir) Or ls_curdir = "" Then
				f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
				Destroy lu_api
				Return
			End If
			
			li_return = tab_1.idw_tabpage[li_curtab].SaveAs("", Excel!, True)
			
			lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
			If li_return <> 1 Then
				f_msg_info(9000, This.Title, "User cancel current job.")
				
			Else
				f_msg_info(9000, This.Title, "Data export finished.")
			End If
			
			Destroy lu_api
			
	End Choose
End IF
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

on c1w_inq_workdt_traffic_v20.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on c1w_inq_workdt_traffic_v20.destroy
call super::destroy
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;String ls_customerid, ls_yyyymmdd_fr, ls_yyyymmdd_to
String ls_where
Long   ll_rows

dw_cond.AcceptText()

ls_yyyymmdd_fr  = Trim(String(dw_cond.Object.yyyymmdd_fr[1],'yyyymmdd'))
ls_yyyymmdd_to    = Trim(String(dw_cond.Object.yyyymmdd_to[1],'yyyymmdd'))
ls_customerid = Trim(dw_cond.Object.customerid[1])

If IsNull(ls_yyyymmdd_fr) Then ls_yyyymmdd_fr = ""
If IsNull(ls_yyyymmdd_to) Then ls_yyyymmdd_to = ""
If IsNull(ls_customerid) Then ls_customerid = ""

If ls_yyyymmdd_fr = "" Then
	f_msg_info(200, Title, "기간 from")
	dw_cond.SetColumn("yyyymmdd_fr")
	dw_cond.SetFocus()
	Return
End If

If ls_yyyymmdd_to = "" Then
	f_msg_info(200, Title, "기간 to")
	dw_cond.SetColumn("yyyymmdd_to")
	dw_cond.SetFocus()
	Return
End If

IF  (ls_yyyymmdd_fr > ls_yyyymmdd_to) THEN
	f_msg_info(200, Title, "기간from 은 기간to 보다 작아야 합니다.")
	dw_cond.SetColumn("yyyymmdd_fr")
	dw_cond.SetFocus()
	RETURN
END IF

//Dynamic SQL
ls_where = ""

If ls_yyyymmdd_fr <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(a.workdt,'YYYYMMDD') >= '" + ls_yyyymmdd_fr + "' "
End If

If ls_yyyymmdd_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(a.workdt,'YYYYMMDD') <= '" + ls_yyyymmdd_to + "' "
End IF

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.customerid = '" + ls_customerid + "' "
End If

dw_master.is_where = ls_where
ll_rows = dw_master.Retrieve()
If ll_rows < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100,Title,"(Master)")
	Return
End If
end event

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	c1w_inq_workdt_traffic_v20
	Desc.	:	일자별 트래픽 현황
	Ver	: 	1.0
	Date	: 	2005.12.09
	Prgromer : Park Kyung Hae(parkkh)
---------------------------------------------------------------------------*/
Date ld_sysdate
String ls_ref_desc

ld_sysdate = Date(fdt_get_dbserver_now())
//p_saveas.TriggerEvent("ue_disable")

tab_1.Enabled = True

//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
end event

event resize;call super::resize;//Int li_index
//
//SetRedraw(False)
//
//If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
//	tab_1.Height = 0
//	For li_index = 1 To tab_1.ii_enable_max_tab
//		tab_1.idw_tabpage[li_index].Height = 0
//	Next
//	p_saveas.Y = tab_1.Y + iu_cust_w_resize.ii_dw_button_space
//Else
//	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
//	For li_index = 1 To tab_1.ii_enable_max_tab
//		tab_1.idw_tabpage[li_index].Height = tab_1.Height -125
//	Next
//	p_saveas.Y = newheight - iu_cust_w_resize.ii_button_space
//End If
//
//// Call the resize functions
////of_ResizeBars()
////of_ResizePanels()
//
//SetRedraw(True)
end event

type dw_cond from w_a_inq_m_tm`dw_cond within c1w_inq_workdt_traffic_v20
integer x = 78
integer y = 52
integer width = 1435
integer height = 272
string dataobject = "c1dw_cnd_workdt_traffic_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m_tm`p_ok within c1w_inq_workdt_traffic_v20
integer x = 1705
integer y = 44
end type

type p_close from w_a_inq_m_tm`p_close within c1w_inq_workdt_traffic_v20
integer x = 2002
integer y = 44
end type

type gb_cond from w_a_inq_m_tm`gb_cond within c1w_inq_workdt_traffic_v20
integer x = 23
integer width = 1577
integer height = 368
end type

type dw_master from w_a_inq_m_tm`dw_master within c1w_inq_workdt_traffic_v20
integer x = 23
integer y = 408
integer width = 2546
integer height = 464
string dataobject = "c1dw_inq_workdt_traffic_m_v20"
end type

event dw_master::ue_init();dwObject ldwo_SORT

ib_sort_use = True
ldwo_SORT = Object.workdt_t
uf_init(ldwo_SORT)

end event

event dw_master::rowfocuschanged;Long ll_row
ll_row = this.GetRow()
if ll_row < 1 then return
this.SelectRow (0, false)			// Turn off previous highlight
this.SelectRow (ll_row, true)		// Highlight current row


end event

event dw_master::clicked;call super::clicked;//// Override
//CALL w_a_m_master`dw_master::Clicked
//
//Long ll_selected_row
//Int li_tab_index
//
//If row > 0 Then
//	ll_selected_row = This.GetSelectedRow(0)
//
//	For li_tab_index = 1 To tab_1.ii_enable_max_tab
//		tab_1.idw_tabpage[li_tab_index].Reset()
//		tab_1.ib_tabpage_check[li_tab_index] = False
//	Next
//
//	If ll_selected_row > 0 Then
//		tab_1.Trigger Event SelectionChanged(1, Tab_1.SelectedTab)
//	End If
//
//End If
//
//
end event

event dw_master::retrieveend;call super::retrieveend;//If rowcount > 0 Then
//	SelectRow( 1, True )
//	ib_retrieve = True
//	tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)	
//End If
//
end event

type tab_1 from w_a_inq_m_tm`tab_1 within c1w_inq_workdt_traffic_v20
integer y = 908
integer width = 2441
integer height = 828
end type

event tab_1::ue_init();call super::ue_init;//Tab Control의 Parent
iw_parent = parent  
//사용할 Tab Page의 갯수 (15 이하)
ii_enable_max_tab = 2

//Tab Page에 들어갈 title
is_tab_title[1] = "지역별"
is_tab_title[2] = "지역그룹별"

//Tab Page에 해당되는  DataWindow 할당
is_dwObject[1] = "c1dw_inq_workdt_traffic_areacod_v20"
is_dwObject[2] = "c1dw_inq_workdt_traffic_areagroup_v20"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);Integer li_rc
Long ll_rc, ll_row
String ls_where
String ls_workdt, ls_workdt_t
Date ld_workdt, ld_workdt_to

//Master에 Row 없으면 
If  al_master_row = -1 Then Return -1

dw_master.AcceptText()		
idw_tabpage[ai_select_tabpage].Reset()
ls_workdt = string(dw_master.Object.workdt[al_master_row],'yyyymmdd')
ls_workdt_t = string(dw_master.Object.workdt[al_master_row],'yyyy-mm-dd')
If IsNull(ls_workdt) Then ls_workdt = ""

idw_tabpage[ai_select_tabpage].Object.workdt_t.Text = " [ " + ls_workdt_t + " ]  "
idw_tabpage[ai_select_tabpage].SetRedraw(false)

Choose Case ai_select_tabpage
	Case 1, 2																//Tab 1, Tab 2
		ls_where  = " to_char(a.workdt,'yyyymmdd') = '" + ls_workdt + "' "
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

Return 0
end event

event tab_1::selectionchanged;call super::selectionchanged;idw_tabpage[newindex].Visible	 = True		

end event

type st_horizontal from w_a_inq_m_tm`st_horizontal within c1w_inq_workdt_traffic_v20
integer y = 872
integer height = 40
end type

type p_saveas from u_p_saveas within c1w_inq_workdt_traffic_v20
integer x = 2299
integer y = 44
boolean bringtotop = true
boolean originalsize = false
end type

