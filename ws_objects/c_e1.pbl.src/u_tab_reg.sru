$PBExportHeader$u_tab_reg.sru
$PBExportComments$Register Tab User Object(from t_tab_title)
forward
global type u_tab_reg from u_tab_title
end type
type dw_1 from u_d_indicator within tabpage_1
end type
type dw_2 from u_d_indicator within tabpage_2
end type
type dw_3 from u_d_indicator within tabpage_3
end type
type dw_4 from u_d_indicator within tabpage_4
end type
type dw_5 from u_d_indicator within tabpage_5
end type
type dw_6 from u_d_indicator within tabpage_6
end type
type dw_7 from u_d_indicator within tabpage_7
end type
type dw_8 from u_d_indicator within tabpage_8
end type
type dw_9 from u_d_indicator within tabpage_9
end type
type dw_10 from u_d_indicator within tabpage_10
end type
type tabpage_11 from userobject within u_tab_reg
end type
type dw_11 from u_d_indicator within tabpage_11
end type
type tabpage_11 from userobject within u_tab_reg
dw_11 dw_11
end type
type tabpage_12 from userobject within u_tab_reg
end type
type dw_12 from u_d_indicator within tabpage_12
end type
type tabpage_12 from userobject within u_tab_reg
dw_12 dw_12
end type
type tabpage_13 from userobject within u_tab_reg
end type
type dw_13 from u_d_indicator within tabpage_13
end type
type tabpage_13 from userobject within u_tab_reg
dw_13 dw_13
end type
type tabpage_14 from userobject within u_tab_reg
end type
type dw_14 from u_d_indicator within tabpage_14
end type
type tabpage_14 from userobject within u_tab_reg
dw_14 dw_14
end type
type tabpage_15 from userobject within u_tab_reg
end type
type dw_15 from u_d_indicator within tabpage_15
end type
type tabpage_15 from userobject within u_tab_reg
dw_15 dw_15
end type
end forward

global type u_tab_reg from u_tab_title
integer width = 2523
integer height = 944
tabpage_11 tabpage_11
tabpage_12 tabpage_12
tabpage_13 tabpage_13
tabpage_14 tabpage_14
tabpage_15 tabpage_15
event type integer ue_itemchanged ( long row,  dwobject dwo,  string data )
event type integer ue_itemerror ( long row,  dwobject dwo,  string data )
event type long ue_dw_doubleclicked ( integer ai_tabpage,  integer ai_xpos,  integer ai_ypos,  long al_row,  dwobject adwo_dwo )
event type long ue_dw_clicked ( integer ai_tabpage,  integer ai_xpos,  integer ai_ypos,  long al_row,  dwobject adwo_dwo )
event type integer ue_dw_buttonclicked ( integer ai_tabpage,  long al_row,  long al_actionreturncode,  dwobject adwo_dwo )
end type
global u_tab_reg u_tab_reg

type variables
string is_dwobject[]
u_d_indicator idw_tabpage[]
boolean ib_tabpage_check[]

String is_close = 'ue_close'
end variables

forward prototypes
private function long ufl_trigger_ue_dw_doubleclicked (integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo)
private function long ufl_trigger_ue_dw_clicked (integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo)
private function long ufl_trigger_ue_dw_buttonclicked (integer ai_tabpage, long al_row, long al_actionreturncode, dwobject adwo_dwo)
end prototypes

event ue_itemchanged;Return 0

end event

event ue_itemerror;Return 0 //hhm
end event

private function long ufl_trigger_ue_dw_doubleclicked (integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);Return Trigger Event ue_dw_doubleclicked(ai_tabpage, ai_xpos, ai_ypos, al_row, adwo_dwo)
end function

private function long ufl_trigger_ue_dw_clicked (integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);Return Trigger Event ue_dw_clicked(ai_tabpage, ai_xpos, ai_ypos, al_row, adwo_dwo)

end function

private function long ufl_trigger_ue_dw_buttonclicked (integer ai_tabpage, long al_row, long al_actionreturncode, dwobject adwo_dwo);Return Trigger Event ue_dw_buttonclicked(ai_tabpage, al_row, al_actionreturncode, adwo_dwo)

end function

event constructor;call super::constructor;int li_i

For li_i = 1 To ii_enable_max_tab
	CHOOSE CASE li_i
		CASE 1
			idw_tabpage[li_i] = This.tabpage_1.dw_1
		CASE 2
			idw_tabpage[li_i] = This.tabpage_2.dw_2
		CASE 3
			idw_tabpage[li_i] = This.tabpage_3.dw_3
		CASE 4
			idw_tabpage[li_i] = This.tabpage_4.dw_4
		CASE 5
			idw_tabpage[li_i] = This.tabpage_5.dw_5
		CASE 6
			idw_tabpage[li_i] = This.tabpage_6.dw_6
		CASE 7
			idw_tabpage[li_i] = This.tabpage_7.dw_7
		CASE 8
			idw_tabpage[li_i] = This.tabpage_8.dw_8
		CASE 9
			idw_tabpage[li_i] = This.tabpage_9.dw_9
		CASE 10
			idw_tabpage[li_i] = This.tabpage_10.dw_10
		CASE 11
			idw_tabpage[li_i] = This.tabpage_11.dw_11
		CASE 12
			idw_tabpage[li_i] = This.tabpage_12.dw_12
		CASE 13
			idw_tabpage[li_i] = This.tabpage_13.dw_13
		CASE 14
			idw_tabpage[li_i] = This.tabpage_14.dw_14
		CASE 15
			idw_tabpage[li_i] = This.tabpage_15.dw_15
	END CHOOSE

	idw_tabpage[li_i].DataObject = is_dwobject[li_i]
	idw_tabpage[li_i].Height = tabpage_1.Height - idw_tabpage[li_i].Y * 2
	idw_tabpage[li_i].Width = tabpage_1.Width - idw_tabpage[li_i].X * 2
	idw_tabpage[li_i].HScrollBar = True	
	ib_tabpage_check[li_i] = False
Next


end event

event ue_init;call super::ue_init;//상속후 다음과 같이 초기화를 시켜야 한다.
//Title과 DataWindow는 Enable갯수에 맞게 설정해야한다.

//iw_parent = parent  //Tab Control의 Parent
//ii_enable_max_tab = 3 //사용할 Tab Page의 갯수 (15 이하)
//
//is_tab_title[1] = "test1"  //Tab Page에 들어갈 title
//is_tab_title[2] = "test2"
//is_tab_title[3] = "test3"
//     .
//		 .
//		 .
//is_dwobject[1] = "d_show_master_multi"  //Tab Page에 해당되는  DataWindow 할당 
//is_dwobject[2] = "d_show_master_multi"
//is_dwobject[3] = "d_show_master_multi"
//		 .
//		 .
//		 .
		 

end event

on u_tab_reg.create
this.tabpage_11=create tabpage_11
this.tabpage_12=create tabpage_12
this.tabpage_13=create tabpage_13
this.tabpage_14=create tabpage_14
this.tabpage_15=create tabpage_15
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tabpage_11
this.Control[iCurrent+2]=this.tabpage_12
this.Control[iCurrent+3]=this.tabpage_13
this.Control[iCurrent+4]=this.tabpage_14
this.Control[iCurrent+5]=this.tabpage_15
end on

on u_tab_reg.destroy
call super::destroy
destroy(this.tabpage_11)
destroy(this.tabpage_12)
destroy(this.tabpage_13)
destroy(this.tabpage_14)
destroy(this.tabpage_15)
end on

type tabpage_1 from u_tab_title`tabpage_1 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_1 dw_1
end type

on tabpage_1.create
this.dw_1=create dw_1
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on tabpage_1.destroy
call super::destroy
destroy(this.dw_1)
end on

type tabpage_2 from u_tab_title`tabpage_2 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_2 dw_2
end type

on tabpage_2.create
this.dw_2=create dw_2
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
end on

on tabpage_2.destroy
call super::destroy
destroy(this.dw_2)
end on

type tabpage_3 from u_tab_title`tabpage_3 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_3 dw_3
end type

on tabpage_3.create
this.dw_3=create dw_3
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_3
end on

on tabpage_3.destroy
call super::destroy
destroy(this.dw_3)
end on

type tabpage_4 from u_tab_title`tabpage_4 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_4 dw_4
end type

on tabpage_4.create
this.dw_4=create dw_4
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_4
end on

on tabpage_4.destroy
call super::destroy
destroy(this.dw_4)
end on

type tabpage_5 from u_tab_title`tabpage_5 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_5 dw_5
end type

on tabpage_5.create
this.dw_5=create dw_5
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_5
end on

on tabpage_5.destroy
call super::destroy
destroy(this.dw_5)
end on

type tabpage_6 from u_tab_title`tabpage_6 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_6 dw_6
end type

on tabpage_6.create
this.dw_6=create dw_6
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_6
end on

on tabpage_6.destroy
call super::destroy
destroy(this.dw_6)
end on

type tabpage_7 from u_tab_title`tabpage_7 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_7 dw_7
end type

on tabpage_7.create
this.dw_7=create dw_7
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_7
end on

on tabpage_7.destroy
call super::destroy
destroy(this.dw_7)
end on

type tabpage_8 from u_tab_title`tabpage_8 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_8 dw_8
end type

on tabpage_8.create
this.dw_8=create dw_8
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_8
end on

on tabpage_8.destroy
call super::destroy
destroy(this.dw_8)
end on

type tabpage_9 from u_tab_title`tabpage_9 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_9 dw_9
end type

on tabpage_9.create
this.dw_9=create dw_9
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_9
end on

on tabpage_9.destroy
call super::destroy
destroy(this.dw_9)
end on

type tabpage_10 from u_tab_title`tabpage_10 within u_tab_reg
integer y = 200
integer width = 2487
integer height = 728
dw_10 dw_10
end type

on tabpage_10.create
this.dw_10=create dw_10
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_10
end on

on tabpage_10.destroy
call super::destroy
destroy(this.dw_10)
end on

type dw_1 from u_d_indicator within tabpage_1
integer x = 5
integer y = 8
integer taborder = 2
end type

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_1 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_1 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
			
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_1 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

type dw_2 from u_d_indicator within tabpage_2
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_2 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If

end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_2 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_2 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_3 from u_d_indicator within tabpage_3
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_3 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_3 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_3 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_4 from u_d_indicator within tabpage_4
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_4 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_4 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_4 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_5 from u_d_indicator within tabpage_5
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_5 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_5 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_5 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_6 from u_d_indicator within tabpage_6
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_6 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_6 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_6 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_7 from u_d_indicator within tabpage_7
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_7 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_7 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_7 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_8 from u_d_indicator within tabpage_8
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_8 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_8 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_8 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_9 from u_d_indicator within tabpage_9
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_9 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_9 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_9 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type dw_10 from u_d_indicator within tabpage_10
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_10 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_10 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_10 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type tabpage_11 from userobject within u_tab_reg
integer x = 18
integer y = 200
integer width = 2487
integer height = 728
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_11 dw_11
end type

on tabpage_11.create
this.dw_11=create dw_11
this.Control[]={this.dw_11}
end on

on tabpage_11.destroy
destroy(this.dw_11)
end on

type dw_11 from u_d_indicator within tabpage_11
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_11 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_11 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_11 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type tabpage_12 from userobject within u_tab_reg
integer x = 18
integer y = 200
integer width = 2487
integer height = 728
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_12 dw_12
end type

on tabpage_12.create
this.dw_12=create dw_12
this.Control[]={this.dw_12}
end on

on tabpage_12.destroy
destroy(this.dw_12)
end on

type dw_12 from u_d_indicator within tabpage_12
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_12 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_12 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_12 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()
  
	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
	//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type tabpage_13 from userobject within u_tab_reg
integer x = 18
integer y = 200
integer width = 2487
integer height = 728
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_13 dw_13
end type

on tabpage_13.create
this.dw_13=create dw_13
this.Control[]={this.dw_13}
end on

on tabpage_13.destroy
destroy(this.dw_13)
end on

type dw_13 from u_d_indicator within tabpage_13
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_13 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_13 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_13 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type tabpage_14 from userobject within u_tab_reg
integer x = 18
integer y = 200
integer width = 2487
integer height = 728
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_14 dw_14
end type

on tabpage_14.create
this.dw_14=create dw_14
this.Control[]={this.dw_14}
end on

on tabpage_14.destroy
destroy(this.dw_14)
end on

type dw_14 from u_d_indicator within tabpage_14
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_14 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_14 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_14 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

type tabpage_15 from userobject within u_tab_reg
integer x = 18
integer y = 200
integer width = 2487
integer height = 728
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_15 dw_15
end type

on tabpage_15.create
this.dw_15=create dw_15
this.Control[]={this.dw_15}
end on

on tabpage_15.destroy
destroy(this.dw_15)
end on

type dw_15 from u_d_indicator within tabpage_15
integer x = 5
integer y = 8
integer taborder = 11
end type

event buttonclicked;Return ufl_trigger_ue_dw_buttonclicked(SelectedTab, row, actionreturncode, dwo)

end event

event clicked;Return ufl_trigger_ue_dw_clicked(SelectedTab, xpos, ypos, row, dwo)

end event

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

event itemchanged;call super::itemchanged;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_15 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return = ltab.Trigger Event Dynamic ue_itemchanged(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then 
	Return li_return
End If

//If current col. is null, Automatically set by 0 (only when itemchagned event has script)
If String(This.Object.Data[This.GetRow(), This.GetColumn()]) = '0' &
 And LeftA(Trim(This.Describe("#" + String(This.GetColumn()) + ".coltype")), 7) = 'decimal' Then
	This.Object.Data[This.GetRow(), This.GetColumn()] = 0
	Return 2
End If
end event

event itemerror;long ll_row
dwobject ldwo_dwo
String ls_data
Int li_return
tab ltab
tabpage_15 ltabpage

ll_row = row
ldwo_dwo = dwo
ls_data = data

ltabpage = This.GetParent()
ltab = ltabpage.GetParent()

li_return =  ltab.Trigger Event Dynamic ue_itemerror(ll_row,ldwo_dwo,ls_data)

If li_return <> 0 Then
	Return li_return
End If

end event

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
window lw_parent
tab ltab
tabpage_15 ltabpage

If keyflags = 0 Then
	ltabpage = This.GetParent()
	ltab = ltabpage.GetParent()
	lw_parent = ltab.GetParent()

	Choose Case key
		Case KeyDownArrow!
			If ib_downarrow Then
				If GetRow() = RowCount() Then
					lw_parent.triggerevent( "ue_insert" )
				End If
			End If
		Case KeyEscape!
			lw_parent.TriggerEvent(is_close)
		//Help 호출
	   Case keyF1!
			fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

//If ib_downarrow  And keyflags = 0 Then
//	If key = KeyDownArrow! Then
//		If GetRow() = RowCount() Then
//			ltabpage = This.GetParent()
//			ltab = ltabpage.GetParent()
//			lw_parent = ltab.GetParent()
//			lw_parent.triggerevent( "ue_insert" )
//		End If
//	End If
//End If

end event

