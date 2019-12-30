$PBExportHeader$w_a_reg_m_tm2.srw
$PBExportComments$[kEnn] multi master,tab,multi row Register - Update for tab selctionchanged ( from w_a_m_master)
forward
global type w_a_reg_m_tm2 from w_a_m_master
end type
type p_insert from u_p_insert within w_a_reg_m_tm2
end type
type p_delete from u_p_delete within w_a_reg_m_tm2
end type
type p_save from u_p_save within w_a_reg_m_tm2
end type
type p_reset from u_p_reset within w_a_reg_m_tm2
end type
type tab_1 from u_tab_reg within w_a_reg_m_tm2
end type
type tab_1 from u_tab_reg within w_a_reg_m_tm2
end type
type st_horizontal from statictext within w_a_reg_m_tm2
end type
end forward

global type w_a_reg_m_tm2 from w_a_m_master
integer width = 3131
integer height = 2096
event type integer ue_insert ( )
event type integer ue_delete ( )
event type integer ue_save ( )
event type integer ue_extra_insert ( integer ai_selected_tab,  long al_insert_row )
event type integer ue_extra_delete ( )
event type integer ue_extra_save ( integer ai_select_tab )
event type integer ue_reset ( )
p_insert p_insert
p_delete p_delete
p_save p_save
p_reset p_reset
tab_1 tab_1
st_horizontal st_horizontal
end type
global w_a_reg_m_tm2 w_a_reg_m_tm2

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app

//tab 관련 기능 작동을 위한 Flag
Boolean ib_retrieve, ib_update = False, ib_no_retrieve = False

//AncestorReturnValue사용으로 필요없어짐
//Int ii_error_chk 

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Bottom							//Reference to the Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

//Sort by lys 2015-02-03
String		is_tab_dwntxtnm, is_tab_dwncolnm
Boolean		ib_sort2_use[]
s_dw_sort	is_tab_sort[]

end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public subroutine of_refreshbars ()
public subroutine wf_tab_init (integer ai_max_tab)
public subroutine of_set_tab_objects (datawindow adw_dw, integer ai_tab)
public function integer of_tab_find_col (string arg_col, integer ai_tab)
public subroutine wf_tab_sort (integer ai_tab_dw)
end prototypes

event ue_insert;Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return

//ii_error_chk = -1

li_curtab = tab_1.Selectedtab
ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0


end event

event ue_delete;Constant Int LI_ERROR = -1

//Int li_return

//ii_error_chk = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End If

If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
	tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
	tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
End if

//ii_error_chk = 0
Return 0

end event

event ue_save;Constant Int LI_ERROR = -1
Int li_tab_index, li_return

//ii_error_chk = -1

li_tab_index = tab_1.SelectedTab
//For li_tab_index = 1 To tab_1.ii_enable_max_tab
	//If tab_1.ib_tabpage_check[li_tab_index] = True Then
		If tab_1.idw_tabpage[li_tab_index].AcceptText() < 0 Then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title

			iu_cust_db_app.uf_prc_db()
	
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If

			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			Return LI_ERROR
		End If

		li_return = Trigger Event ue_extra_save(li_tab_index)
		Choose Case li_return
			Case -2
				//필수항목 미입력
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return -2
			Case -1
				//ROLLBACK와 동일한 기능
				iu_cust_db_app.is_caller = "ROLLBACK"
				iu_cust_db_app.is_title = tab_1.is_parent_title
				iu_cust_db_app.uf_prc_db()
				If iu_cust_db_app.ii_rc = -1 Then
					ib_update = False
					Return -1
				End If
		
				f_msg_info(3010, tab_1.is_parent_title, "Save")
				ib_update = False
				Return -1
		End Choose
		
		If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title
			iu_cust_db_app.uf_prc_db()
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If
		
			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			f_msg_info(3010,tab_1.is_parent_title,"Save")
			Return LI_ERROR
		End If
	//End If
//Next

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

//For li_tab_index = 1 To tab_1.ii_enable_max_tab
//	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
//	End If
//Next

f_msg_info(3000,tab_1.is_parent_title,"Save")

//ii_error_chk = 0
Return 0

end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

//ii_error_chk = -1

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
		If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
			(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
			tab_1.SelectedTab = li_tab_index
			li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
			If li_rc <> 1 Then
				Return LI_ERROR
			End If
		End If
	End If
Next

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")


For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False
Next

dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
tab_1.enabled = False

ib_retrieve = FALSE

//ii_error_chk = 0
Return 0


end event

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

end subroutine

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
	tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
Next

end subroutine

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public subroutine wf_tab_init (integer ai_max_tab);/*---------------------------------------------------------------------------------------*/
/* 함  수  명  : wf_tab_init()                                        							*/
/* 개      요  : Tab Page 내 DW Sort를 위한 초기화 작업                 			*/
/* 매개  변수  : None								                          					*/
/* 리  턴  값  : None                         													*/
/* 작성  내역  : 2008. 02. 05 By JH														*/
/* 비      고  : Tab Page Str 배열 초기화											    */
/*---------------------------------------------------------------------------------------*/
Integer		i
s_dw_sort	lst_sort

For i = 1  To ai_max_tab
	is_tab_sort[i] = lst_sort
Next
end subroutine

public subroutine of_set_tab_objects (datawindow adw_dw, integer ai_tab);/*----------------------------------------------------------------------------*/
/* 함  수  명  : of_set_objects()                  								*/
/* 개      요  : 정렬을 하기위한 칼럼,Computed Field를 초기화	*/
/* 매개  변수  :                                                      					*/
/* 리  턴  값  : None                                                 					*/
/* 작성  내역  :                                                      					*/
/* 비      고  :       By JH                                        						*/ 
/*-----------------------------------------------------------------------------*/
Integer li_exit, li_i
String  ls_objects, ls_colnm, ls_type, ls_visible, ls_band 
s_dw_sort  ls_sort

If adw_dw.DataObject = '' or IsNull(adw_dw.DataObject) Then Return 

ls_objects = String(adw_dw.Object.DataWindow.objects)
is_tab_sort[ai_tab] = ls_sort

DO WHILE TRUE
	If PosA(ls_objects, '~t') > 0 Then
		ls_colnm   = LeftA(ls_objects, PosA(ls_objects, '~t') - 1)
		ls_objects = MidA(ls_objects,  PosA(ls_objects, '~t') + 1)
	Else
		ls_colnm   = ls_objects
		li_exit    = 1
	End If
	
	If LeftA(ls_colnm,2) = 'xx' and li_exit = 1 Then
		Exit
	ElseIf LeftA(ls_colnm,2) = 'xx' Then
		Continue		
	Else
	End If
	
	/** Detail Band만 적용*/
	ls_band       = adw_dw.Describe(ls_colnm + ".band")
	ls_visible    = adw_dw.Describe(ls_colnm + ".visible")
	If ls_visible = '1' or (ls_band = 'detail') or &
	                       (ls_band = 'header') Then
 	   li_i++
	   is_tab_sort[ai_tab].col_name[li_i]  = ls_Colnm
	   is_tab_sort[ai_tab].sort_type[li_i] = 'D'
	End If
	
	If li_exit > 0 Then Exit
LOOP

end subroutine

public function integer of_tab_find_col (string arg_col, integer ai_tab);/*---------------------------------------------------------------------------------------*/
/* 함  수  명  : of_find_col()                                        							*/
/* 개      요  : 전체칼럼중 몇번째 칼럼인지 찾아낸다.                 			*/
/* 매개  변수  : String arg_col : 칼럼 이름                           					*/
/* 리  턴  값  : Integer                        													*/
/* 작성  내역  : 2008. 02. 04 By JH														*/
/* 비      고  : Return값은 전체칼럼리스트중 몇번째인지를 되돌린다.  */
/*               0일경우 찾지 못한것이다.		                         					*/
/*---------------------------------------------------------------------------------------*/
String 	ls_colname
Int	li_inc, 	li_cnt

li_cnt = UpperBound(is_tab_sort[ai_tab].col_name[])

For li_inc = 1 to li_cnt
	If arg_col = is_tab_sort[ai_tab].col_name[li_inc] Then
		return li_inc
	end if
Next

Return 0
end function

public subroutine wf_tab_sort (integer ai_tab_dw);/*-----------------------------------------*/
/* 오브젝트명  : w_a_reg_m_tm2	*/
/* Function	: wf_tab_sort				*/
/* 작성  내역  : 2008.02.05			*/
/*-----------------------------------------*/
//Ttile 선택 만으로 Sort가 가능하게 추가

//2008. 02. 05. By JH
Integer  li_colpos
String   ls_colname
DataWindow	ldw_col

ldw_col = tab_1.idw_tabpage[ai_tab_dw]

IF UpperBound(is_tab_sort[ai_tab_dw].col_name[]) = 0 Then 
	of_set_tab_objects(ldw_col, ai_tab_dw)
End IF

/**Sort*/
li_colpos = of_tab_find_col(is_tab_dwncolnm, ai_tab_dw)
/** 버튼이나 그림등 컬럼 타이틀이 아닐 경우 */
If Not(li_colpos = 0) Then
	
	ls_colname = is_tab_sort[ai_tab_dw].col_name[li_colpos]
	If is_tab_sort[ai_tab_dw].sort_type[li_colpos] = 'D' Then
		 ldw_col.SetSort(ls_colname + " A")
		 ldw_col.Sort()
		 is_tab_sort[ai_tab_dw].sort_type[li_colpos] = "A"
	Else
		 ldw_col.SetSort(ls_colname + " D")
		 ldw_col.Sort()
		 is_tab_sort[ai_tab_dw].sort_type[li_colpos] = "D"
	End If
End If


end subroutine

on w_a_reg_m_tm2.create
int iCurrent
call super::create
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.tab_1=create tab_1
this.st_horizontal=create st_horizontal
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_insert
this.Control[iCurrent+2]=this.p_delete
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.tab_1
this.Control[iCurrent+6]=this.st_horizontal
end on

on w_a_reg_m_tm2.destroy
call super::destroy
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.tab_1)
destroy(this.st_horizontal)
end on

event closequery;//Int li_tab_index, li_rc
Integer li_return
Integer li_curtab

If tab_1.ii_enable_max_tab <= 0 Then Return 0

li_curtab = tab_1.SelectedTab

tab_1.idw_tabpage[li_curtab].AcceptText() 
If (tab_1.idw_tabpage[li_curtab].ModifiedCount() > 0) or &
	(tab_1.idw_tabpage[li_curtab].DeletedCount() > 0)	Then
	li_return = MessageBox(Tab_1.is_parent_title, "Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
	If li_return <> 1 Then Return 1
End If

end event

event close;call super::close;Destroy iu_cust_db_app

end event

event open;call super::open;iu_cust_db_app = Create u_cust_db_app
TriggerEvent("ue_reset")

// Set the Top, Bottom Controls
idrg_Top = dw_master
idrg_Bottom = tab_1

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event ue_ok;call super::ue_ok;Int li_tab_index

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False	
Next

ib_retrieve = False


end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.Width - 50
	Next
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_m_master`dw_cond within w_a_reg_m_tm2
integer width = 2171
integer height = 260
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_m_master`p_ok within w_a_reg_m_tm2
integer x = 2405
integer y = 60
end type

type p_close from w_a_m_master`p_close within w_a_reg_m_tm2
integer x = 2706
integer y = 60
end type

type gb_cond from w_a_m_master`gb_cond within w_a_reg_m_tm2
integer height = 336
end type

type dw_master from w_a_m_master`dw_master within w_a_reg_m_tm2
integer y = 352
integer width = 3013
integer height = 524
end type

event dw_master::clicked;Long ll_selected_row,ll_old_selected_row
Int li_tab_index,li_rc

ll_old_selected_row = This.GetSelectedRow(0)

Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_old_selected_row > 0 Then
		For li_tab_index = 1 To tab_1.ii_enable_max_tab
			If tab_1.ib_tabpage_check[li_tab_index] = True Then
				tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
				If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
					(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
					tab_1.SelectedTab = li_tab_index
					li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
						"Do you want to cancel?",Question!,YesNo!)
					If li_rc <> 1 Then
						If ll_selected_row > 0 Then
							SelectRow(ll_selected_row ,FALSE)
						End If
						SelectRow(ll_old_selected_row , TRUE )
						ScrollToRow(ll_old_selected_row)
						tab_1.idw_tabpage[li_tab_index].SetFocus()
						Return 
					End If
				End If
			End If	
		Next
	End If
		
	For li_tab_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_tab_index].Reset()
		tab_1.ib_tabpage_check[li_tab_index] = False
	Next
		
	If ll_selected_row > 0 Then
		tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)
		p_insert.TriggerEvent('ue_enable') 
		p_delete.TriggerEvent('ue_enable')
		p_save.TriggerEvent('ue_enable')
		p_reset.TriggerEvent('ue_enable')
		tab_1.enabled = true
		tab_1.idw_tabpage[Tab_1.SelectedTab].SetFocus()
	Else		
		p_insert.TriggerEvent('ue_disable')
		p_delete.TriggerEvent('ue_disable')
		p_save.TriggerEvent('ue_disable')
		p_reset.TriggerEvent('ue_disable')
		tab_1.enabled = false
	End If
End If
end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	ib_retrieve = True
	Tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

	Tab_1.SetFocus()
	p_save.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
	p_insert.TriggerEvent('ue_enable')
	p_delete.TriggerEvent('ue_enable')

	p_ok.TriggerEvent('ue_disable')
	dw_cond.Enabled =  False
End If

end event

event ue_after_sort;//PB 6.0 : Sort()후의 첫번째 열의 자동 선택에 따른 해결책(Sort()전에 선택된 열이 존재시)
Long ll_select_row

ll_select_row = GetSelectedRow(0)

If ll_select_row > 0 Then
	Trigger Event Clicked(0, 0, ll_select_row, Object.a_d)
End If

Return 0

end event

type p_insert from u_p_insert within w_a_reg_m_tm2
integer x = 37
integer y = 1844
boolean enabled = false
boolean originalsize = false
end type

type p_delete from u_p_delete within w_a_reg_m_tm2
integer x = 329
integer y = 1844
boolean enabled = false
boolean originalsize = false
end type

type p_save from u_p_save within w_a_reg_m_tm2
integer x = 626
integer y = 1844
boolean enabled = false
boolean originalsize = false
end type

type p_reset from u_p_reset within w_a_reg_m_tm2
integer x = 1157
integer y = 1844
boolean enabled = false
boolean originalsize = false
end type

type tab_1 from u_tab_reg within w_a_reg_m_tm2
event type integer ue_tabpage_retrieve ( long al_master_row,  integer ai_select_tabpage )
event type integer ue_tabpage_update ( integer oldindex,  integer newindex )
integer x = 27
integer y = 916
integer width = 3013
integer height = 892
integer taborder = 30
long backcolor = 29478337
end type

event ue_tabpage_retrieve;Return 0 //이것이 존재하지 않을 경우 자손에서 이 부분에 코딩시 Window쪽으로 이벤트가 형성됨.


end event

event ue_tabpage_update;//****kenn : 1999-05-11 火 *****************************
// Return : -1 Save Error
//           0 Save
//           1 User Abort(Retrieve oldindex)
//           2 System Ignore
//******************************************************
Integer li_return

If oldindex <= 0 Then Return 2
If oldindex = 1 And newindex = 1 Then Return 2
ib_update = True
//If tab_1.ib_tabpage_check[oldindex] Then
	tab_1.idw_tabpage[oldindex].AcceptText()
	If (tab_1.idw_tabpage[oldindex].ModifiedCount() > 0) Or &
		(tab_1.idw_tabpage[oldindex].DeletedCount() > 0) Then
		tab_1.SelectedTab = oldindex
		li_return = MessageBox(Tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]" &
					, "Data is Modified.! Do you want to save?", Question!, YesNo!)
		If li_return <> 1 Then
			ib_update = False
			Return 1
		End If
	Else
		ib_update = False
		Return 2
	End If

	li_return = Trigger Event ue_extra_save(oldindex)
	Choose Case li_return
		Case -2
			//필수항목 미입력
			//tab_1.SelectedTab = oldindex
			//tab_1.idw_tabpage[oldindex].SetFocus()
			ib_update = False
			Return -2
		Case -1
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title
			iu_cust_db_app.uf_prc_db()
			If iu_cust_db_app.ii_rc = -1 Then
				ib_update = False
				Return -1
			End If
	
			f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
			ib_update = False
			Return -1
	End Choose

	If tab_1.idw_tabpage[oldindex].Update(True, False) < 0 Then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			ib_update = False
			Return -1
		End If

		f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
		ib_update = False
		Return -1
	End If

	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		ib_update = False
		Return -1
	End If

	tab_1.idw_tabpage[oldindex].ResetUpdate()
	f_msg_info(3000, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
	ib_update = False
	//tab_1.SelectedTab = newindex
//End If

Return 0

end event

event ue_init;call super::ue_init;iw_parent = Parent


end event

event selectionchanged;call super::selectionchanged;Integer li_return
Long ll_selected_row

If ib_update Or ib_no_retrieve Then Return 0
ll_selected_row = dw_master.GetSelectedRow(0)
li_return = Trigger Event ue_tabpage_update(oldindex, newindex)
Choose Case li_return
	Case -2
		tab_1.idw_tabpage[oldindex].SetFocus()
		Return
	Case 1
		//Trigger Event ue_tabpage_retrieve(ll_selected_row, oldindex)
		tab_1.idw_tabpage[oldindex].Reset()
		ib_no_retrieve = True
		tab_1.SelectedTab = newindex
		ib_no_retrieve = False
//	Case 2
//		Return
   Case 0
		tab_1.idw_tabpage[oldindex].SetFocus()
		Return
//	Case 0 /*HHM*/
//		tab_1.idw_tabpage[oldindex].Reset()
//		ib_no_retrieve = True
//		tab_1.SelectedTab = newindex
//		ib_no_retrieve = False
End Choose

If ib_retrieve Then
	//If Not tab_1.ib_tabpage_check[newindex] Then
		ll_selected_row = dw_master.GetSelectedRow(0)
		If ll_selected_row > 0 Then
			If Trigger Event ue_tabpage_retrieve(ll_selected_row, newindex) < 0 Then
				Return
			End If
			tab_1.ib_tabpage_check[newindex] = True
		End If
	//End If
End If

end event

type st_horizontal from statictext within w_a_reg_m_tm2
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 27
integer y = 888
integer width = 745
integer height = 32
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string pointer = "SizeNS!"
long textcolor = 33554432
long backcolor = 16776960
boolean focusrectangle = false
end type

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = Y

	// Refresh the Bar attributes.
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
	If Not IsValid(idrg_Bottom) Then Return
	If li_prevposition > idrg_Bottom.Y Then idrg_Bottom.SetRedraw(True)
End If

end event

event mouseup;// Hide the bar
BackColor = il_HiddenColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.

end event

