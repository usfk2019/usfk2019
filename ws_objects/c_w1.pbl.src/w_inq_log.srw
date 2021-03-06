﻿$PBExportHeader$w_inq_log.srw
$PBExportComments$[kEnn] Inquriy SYSLOG1T(from w_a_inq_m)
forward
global type w_inq_log from w_a_inq_m
end type
type tv_item from treeview within w_inq_log
end type
type st_vertical from statictext within w_inq_log
end type
type dw_log from u_d_base within w_inq_log
end type
end forward

global type w_inq_log from w_a_inq_m
integer width = 3515
integer height = 2052
tv_item tv_item
st_vertical st_vertical
dw_log dw_log
end type
global w_inq_log w_inq_log

type variables
//DataStore	ids_log
String		is_where_cnd

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Left							//Reference to the Top Left control
Dragobject	idrg_Right							//Reference to the Top Right control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

end variables

forward prototypes
public function long wfl_tv_add (integer ai_level, long al_node, string as_label, string as_data)
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public function integer wfi_screen_init ()
public function integer wfi_tv_dts_close ()
public function long wfl_tv_dts_init ()
public function integer wfi_tv_refresh (long al_rows)
public subroutine of_refreshbars ()
public function long wfl_tv_dts_filter (string as_filter)
end prototypes

public function long wfl_tv_add (integer ai_level, long al_node, string as_label, string as_data);Long ll_node
TreeViewItem ltvi_new

ltvi_new.Label = as_label
ltvi_new.Data = as_data
ltvi_new.PictureIndex = ai_level + 1

Choose Case ai_level
	Case 0, 1, 2
		ltvi_new.SelectedPictureIndex = ai_level + 1
	Case 3
		ltvi_new.SelectedPictureIndex = ai_level + 2
End Choose

ll_node = tv_item.InsertItemLast(al_node, ltvi_new)

Return ll_node

end function

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_vertical.X < cii_WindowBorder + 150 Then
	st_vertical.X = cii_WindowBorder + 150
End If

If st_vertical.X > WorkSpaceWidth() - 150 - cii_BarThickness Then
	st_vertical.X = WorkSpaceWidth() - 150 - cii_BarThickness
End If

st_vertical.Move(st_vertical.X, idrg_Left.Y)
st_vertical.Resize(cii_Barthickness, idrg_Left.Height)

of_RefreshBars()

end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

Long		ll_Width, ll_Height

// Validate the controls.
If Not IsValid(idrg_Right) Or Not IsValid(idrg_Left) Then Return

ll_Width = WorkSpaceWidth()
ll_Height = WorkspaceHeight()

// Left processing
idrg_Left.Move(cii_WindowBorder, cii_WindowBorder + ii_WindowTop)
idrg_Left.Resize(st_vertical.X - idrg_Left.X, idrg_Left.Height)

// Right Processing
idrg_Right.Move(st_vertical.X + cii_BarThickness, cii_WindowBorder + ii_WindowTop)
idrg_Right.Resize(ll_Width - (st_vertical.X + cii_BarThickness) - cii_WindowBorder, idrg_Left.Height)

end subroutine

public function integer wfi_screen_init ();Return 0

end function

public function integer wfi_tv_dts_close ();//Destroy ids_log

Return 0

end function

public function long wfl_tv_dts_init ();//Long ll_rows
//
//SetPointer(HourGlass!)
//
//ids_log = Create DataStore
//ids_log.DataObject = "d_dts_log"
//ids_log.SetTransObject(sqlca)
//ll_rows = ids_log.Retrieve()
//
//SetPointer(Arrow!)
//
//Return ll_rows
Return 0


end function

public function integer wfi_tv_refresh (long al_rows);Boolean lb_skip
Integer li_level
Long ll_row
Long ll_rows
Long ll_node1, ll_node2, ll_node3
String ls_pgm_id, ls_pgm_name, ls_pgm_item, ls_chg_item
String ls_label, ls_data
String ls_old1, ls_old2, ls_new1, ls_new2

//기존의 Item을 전부 삭제
tv_item.DeleteItem(0)

//Root
li_level = 0
ls_label = "변경이력"
ls_data = "|"
ll_node1 = wfl_tv_add(li_level, 0, ls_label, ls_data)

//Program
ls_old1 = ""
ls_old2 = ""
ls_new1 = ""
ls_new2 = ""
For ll_row = 1 To al_rows
	ls_old1 = ls_new1
	ls_old2 = ls_new2

	ls_pgm_id = Trim(dw_log.Object.pgm_id[ll_row])
	If IsNull(ls_pgm_id) Then ls_pgm_id = ""
	ls_new1 = ls_pgm_id
	If ls_pgm_id = "" Then Continue

	ls_pgm_name = Trim(dw_log.Object.syspgm1t_pgm_nm[ll_row])
	If IsNull(ls_pgm_name) Then ls_pgm_name = ""

	ls_pgm_item = Trim(dw_log.Object.pgm_item[ll_row])
	If IsNull(ls_pgm_item) Then ls_pgm_item = ""
	ls_new2 = ls_pgm_item
	If ls_pgm_item = "" Then Continue

	ls_chg_item = Trim(dw_log.Object.chg_item[ll_row])
	If IsNull(ls_chg_item) Then ls_chg_item = ""
	If ls_chg_item = "" Then Continue
	
	If ls_new1 <> ls_old1 Then
		li_level = 1
		ls_label = ls_pgm_name
		ls_data = "|"
		ll_node2 = wfl_tv_add(li_level, ll_node1, ls_label, ls_data)

		If ls_pgm_item = "|" Then
			lb_skip = True
		Else
			lb_skip = False
			li_level = 2
			ls_label = ls_pgm_item
			ls_data = "|"
			ll_node3 = wfl_tv_add(li_level, ll_node2, ls_label, ls_data)
		End If

		li_level = 3
		ls_label = ls_chg_item
		ls_data = ls_pgm_id + "`" + ls_pgm_item + "`" + ls_chg_item
		If lb_skip Then
			wfl_tv_add(li_level, ll_node2, ls_label, ls_data)
		Else
			wfl_tv_add(li_level, ll_node3, ls_label, ls_data)
		End If
	Else
		If ls_new2 <> ls_old2 Then
			If ls_pgm_item = "|" Then
				lb_skip = True
			Else
				lb_skip = False
				li_level = 2
				ls_label = ls_pgm_item
				ls_data = "|"
				ll_node3 = wfl_tv_add(li_level, ll_node2, ls_label, ls_data)
			End If
	
			li_level = 3
			ls_label = ls_chg_item
			ls_data = ls_pgm_id + "`" + ls_pgm_item + "`" + ls_chg_item
			If lb_skip Then
				wfl_tv_add(li_level, ll_node2, ls_label, ls_data)
			Else
				wfl_tv_add(li_level, ll_node3, ls_label, ls_data)
			End If
		Else
			If ls_pgm_item = "|" Then
				lb_skip = True
			Else
				lb_skip = False
			End If
	
			li_level = 3
			ls_label = ls_chg_item
			ls_data = ls_pgm_id + "`" + ls_pgm_item + "`" + ls_chg_item
			If lb_skip Then
				wfl_tv_add(li_level, ll_node2, ls_label, ls_data)
			Else
				wfl_tv_add(li_level, ll_node3, ls_label, ls_data)
			End If
		End If
	End If
Next

tv_item.ExpandItem(1)

Return 0

end function

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_vertical.SetPosition(ToTop!)

// Make sure the Width is not lost
st_vertical.Width = cii_BarThickness

end subroutine

public function long wfl_tv_dts_filter (string as_filter);//Long		ll_rows
//String	ls_filter
//
//ls_filter = as_filter
//ids_log.SetFilter(ls_filter)
//ids_log.Filter()
//ll_rows = ids_log.RowCount()

Long		ll_rows
String	ls_where

ls_where = as_filter
dw_log.is_where = ls_where
ll_rows = dw_log.Retrieve()

Return ll_rows

end function

on w_inq_log.create
int iCurrent
call super::create
this.tv_item=create tv_item
this.st_vertical=create st_vertical
this.dw_log=create dw_log
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tv_item
this.Control[iCurrent+2]=this.st_vertical
this.Control[iCurrent+3]=this.dw_log
end on

on w_inq_log.destroy
call super::destroy
destroy(this.tv_item)
destroy(this.st_vertical)
destroy(this.dw_log)
end on

event open;call super::open;//wfl_tv_dts_init()

// Set the TopLeft, TopRight, and Bottom Controls
idrg_Left = tv_item
idrg_Right = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Left.Y
st_vertical.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_pgm_id, ls_pgm_item, ls_chg_item
String	ls_reg_dt_fr, ls_reg_dt_to
String	ls_date

//condition for TreeView Data Retrieve
//Program/Item/변경항목
ls_pgm_id = dw_cond.Object.pgm_id[1]
ls_pgm_item = dw_cond.Object.pgm_item[1]
ls_chg_item = dw_cond.Object.chg_item[1]
ls_reg_dt_fr = String(dw_cond.Object.reg_dt_fr[1], "yyyymmdd")
ls_reg_dt_to = String(dw_cond.Object.reg_dt_to[1], "yyyymmdd")

If IsNull(ls_pgm_id) Then ls_pgm_id = ""
If IsNull(ls_pgm_item) Then ls_pgm_item = ""
If IsNull(ls_chg_item) Then ls_chg_item = ""

ls_where = ""
If ls_pgm_id <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "syslog1t.pgm_id = '" + ls_pgm_id + "'"
End If

If ls_pgm_item <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "syslog1t.pgm_item like '%" + ls_pgm_item + "%'"
End If

If ls_chg_item <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "syslog1t.chg_item like '%" + ls_chg_item + "%'"
End If

//Condition for Detail Data Retrieve
//변경일자(From-To)
is_where_cnd = ""
If ls_reg_dt_fr <> "" Then
	ls_date = MidA(ls_reg_dt_fr, 1, 4) + "-" + MidA(ls_reg_dt_fr, 5, 2) + "-" + MidA(ls_reg_dt_fr, 7, 2)
	If Not IsDate(ls_date) Then
		f_msg_usr_err(210, Title, "변경일자")
		dw_cond.SetColumn("reg_dt_fr")
		dw_cond.SetFocus()
		Return
	Else
		If is_where_cnd <> "" Then is_where_cnd += " and "
		is_where_cnd += "reg_dt >= '" + ls_reg_dt_fr + "000000'"
	End If
End If

If ls_reg_dt_to <> "" Then
	ls_date = MidA(ls_reg_dt_to, 1, 4) + "-" + MidA(ls_reg_dt_to, 5, 2) + "-" + MidA(ls_reg_dt_to, 7, 2)
	If Not IsDate(ls_date) Then
		f_msg_usr_err(210, Title, "변경일자")
		dw_cond.SetColumn("reg_dt_to")
		dw_cond.SetFocus()
		Return
	Else
		If is_where_cnd <> "" Then is_where_cnd += " and "
		is_where_cnd += "reg_dt <= '" + ls_reg_dt_to + "235959'"
	End If
End If

If ls_reg_dt_fr <> "" And ls_reg_dt_to <> "" Then
	If ls_reg_dt_fr > ls_reg_dt_to Then
		f_msg_usr_err(211, Title, "변경일자")
		dw_cond.SetColumn("reg_dt_fr")
		dw_cond.SetFocus()
		Return
	End If
End If

//TreeView Refresh
ll_rows = wfl_tv_dts_filter(ls_where)
wfi_tv_refresh(ll_rows)

end event

event close;call super::close;wfi_tv_dts_close()

end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//Treeview가 존재하므로 추가 Script
SetRedraw(False)

If newheight < dw_detail.Y Then
	tv_item.Height = 0
Else
	tv_item.Height = newheight - tv_item.Y - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_inq_m`dw_cond within w_inq_log
integer x = 46
integer y = 56
integer width = 2350
integer height = 200
string dataobject = "d_cnd_inq_log"
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m`p_ok within w_inq_log
integer x = 2601
end type

type p_close from w_a_inq_m`p_close within w_inq_log
integer x = 2912
integer y = 56
end type

type gb_cond from w_a_inq_m`gb_cond within w_inq_log
end type

type dw_detail from w_a_inq_m`dw_detail within w_inq_log
integer x = 1051
integer y = 324
integer width = 2395
integer height = 1572
string dataobject = "d_inq_log"
end type

event dw_detail::constructor;call super::constructor;dwObject ldwo_sort

ldwo_sort = Object.seq_t
uf_init(ldwo_sort, "D", 255)

end event

type tv_item from treeview within w_inq_log
integer x = 18
integer y = 324
integer width = 1001
integer height = 1572
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 16777215
borderstyle borderstyle = stylelowered!
string picturename[] = {"Step!","Window!","CreateIndex!","EditStops!","SingletonReturn!"}
long picturemaskcolor = 12632256
long statepicturemaskcolor = 536870912
end type

event selectionchanged;Integer li_return
String ls_result[]
String ls_where
String ls_pk, ls_pgm_id, ls_pgm_item, ls_chg_item
TreeViewItem ltvi_cur

GetItem(newhandle, ltvi_cur)
If ltvi_cur.Data = "|" Then
	dw_detail.Reset()
	Return
End If

ls_pk = String(ltvi_cur.Data)
li_return = fi_cut_string(ls_pk, "`", ls_result[])

ls_where = ""
If is_where_cnd <> "" Then ls_where = is_where_cnd + " and "
ls_where += "chg_item = '" + ls_result[3] + "'"
ls_where += " and " + "pgm_item = '" + ls_result[2] + "'"
ls_where += " and " + "pgm_id = '" + ls_result[1] + "'"

dw_detail.is_where = ls_where
dw_detail.Retrieve()

end event

event constructor;//***********************************
//Pictures
//***********************************
//1:Step!
//2:Window!
//3:CreateIndex!
//4:EditStops!
//5:SingletonReturn!

end event

type st_vertical from statictext within w_inq_log
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 1019
integer y = 320
integer width = 27
integer height = 540
string dragicon = "Exclamation!"
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string pointer = "SizeWE!"
long textcolor = 255
long backcolor = 255
long bordercolor = 276856960
boolean focusrectangle = false
end type

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = X

	// Refresh the Bar attributes.
	If Not (Parent.PointerX() <= idrg_Left.X + li_MoveLimit Or Parent.PointerX() >= idrg_Right.X + idrg_Right.Width - li_MoveLimit) Then
		X = Parent.PointerX()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Left) Or Not IsValid(idrg_Right) Then Return
	If li_prevposition > idrg_Right.X Then idrg_Right.SetRedraw(True)
	If li_prevposition < idrg_Left.X + idrg_Left.Width Then idrg_Left.SetRedraw(True)
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

type dw_log from u_d_base within w_inq_log
boolean visible = false
integer x = 3218
integer y = 32
integer width = 187
integer height = 80
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_dts_log"
end type

