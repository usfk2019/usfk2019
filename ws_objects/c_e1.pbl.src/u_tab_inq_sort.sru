$PBExportHeader$u_tab_inq_sort.sru
$PBExportComments$Inquiry Tab User Object(from t_tab_title)
forward
global type u_tab_inq_sort from u_tab_title
end type
type dw_1 from u_d_sort within tabpage_1
end type
type dw_2 from u_d_base within tabpage_2
end type
type dw_3 from u_d_base within tabpage_3
end type
type dw_4 from u_d_base within tabpage_4
end type
type dw_5 from u_d_base within tabpage_5
end type
type dw_6 from u_d_base within tabpage_6
end type
type dw_7 from u_d_base within tabpage_7
end type
type dw_8 from u_d_base within tabpage_8
end type
type dw_9 from u_d_base within tabpage_9
end type
type dw_10 from u_d_base within tabpage_10
end type
type tabpage_11 from userobject within u_tab_inq_sort
end type
type dw_11 from u_d_base within tabpage_11
end type
type tabpage_11 from userobject within u_tab_inq_sort
dw_11 dw_11
end type
type tabpage_12 from userobject within u_tab_inq_sort
end type
type dw_12 from u_d_base within tabpage_12
end type
type tabpage_12 from userobject within u_tab_inq_sort
dw_12 dw_12
end type
type tabpage_13 from userobject within u_tab_inq_sort
end type
type dw_13 from u_d_base within tabpage_13
end type
type tabpage_13 from userobject within u_tab_inq_sort
dw_13 dw_13
end type
type tabpage_14 from userobject within u_tab_inq_sort
end type
type dw_14 from u_d_base within tabpage_14
end type
type tabpage_14 from userobject within u_tab_inq_sort
dw_14 dw_14
end type
type tabpage_15 from userobject within u_tab_inq_sort
end type
type dw_15 from u_d_base within tabpage_15
end type
type tabpage_15 from userobject within u_tab_inq_sort
dw_15 dw_15
end type
end forward

global type u_tab_inq_sort from u_tab_title
integer width = 2523
integer height = 944
tabpage_11 tabpage_11
tabpage_12 tabpage_12
tabpage_13 tabpage_13
tabpage_14 tabpage_14
tabpage_15 tabpage_15
event type long ue_dw_doubleclicked ( integer ai_tabpage,  integer ai_xpos,  integer ai_ypos,  long al_row,  dwobject adwo_dwo )
end type
global u_tab_inq_sort u_tab_inq_sort

type variables
string is_dwobject[]
u_d_base idw_tabpage[]
boolean ib_tabpage_check[]
end variables

forward prototypes
private function long ufl_trigger_ue_dw_doubleclicked (integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo)
end prototypes

private function long ufl_trigger_ue_dw_doubleclicked (integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);Return Trigger Event ue_dw_doubleclicked(ai_tabpage, ai_xpos, ai_ypos, al_row, adwo_dwo)
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

on u_tab_inq_sort.create
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

on u_tab_inq_sort.destroy
call super::destroy
destroy(this.tabpage_11)
destroy(this.tabpage_12)
destroy(this.tabpage_13)
destroy(this.tabpage_14)
destroy(this.tabpage_15)
end on

type tabpage_1 from u_tab_title`tabpage_1 within u_tab_inq_sort
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

type tabpage_2 from u_tab_title`tabpage_2 within u_tab_inq_sort
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

type tabpage_3 from u_tab_title`tabpage_3 within u_tab_inq_sort
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

type tabpage_4 from u_tab_title`tabpage_4 within u_tab_inq_sort
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

type tabpage_5 from u_tab_title`tabpage_5 within u_tab_inq_sort
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

type tabpage_6 from u_tab_title`tabpage_6 within u_tab_inq_sort
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

type tabpage_7 from u_tab_title`tabpage_7 within u_tab_inq_sort
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

type tabpage_8 from u_tab_title`tabpage_8 within u_tab_inq_sort
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

type tabpage_9 from u_tab_title`tabpage_9 within u_tab_inq_sort
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

type tabpage_10 from u_tab_title`tabpage_10 within u_tab_inq_sort
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

type dw_1 from u_d_sort within tabpage_1
integer y = 52
integer width = 1710
integer height = 460
integer taborder = 12
end type

type dw_2 from u_d_base within tabpage_2
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_3 from u_d_base within tabpage_3
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_4 from u_d_base within tabpage_4
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_5 from u_d_base within tabpage_5
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_6 from u_d_base within tabpage_6
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_7 from u_d_base within tabpage_7
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_8 from u_d_base within tabpage_8
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_9 from u_d_base within tabpage_9
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type dw_10 from u_d_base within tabpage_10
integer x = 5
integer y = 8
integer taborder = 2
boolean bringtotop = true
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type tabpage_11 from userobject within u_tab_inq_sort
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

type dw_11 from u_d_base within tabpage_11
integer x = 5
integer y = 8
integer taborder = 2
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)




end event

type tabpage_12 from userobject within u_tab_inq_sort
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

type dw_12 from u_d_base within tabpage_12
integer x = 5
integer y = 8
integer taborder = 2
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type tabpage_13 from userobject within u_tab_inq_sort
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

type dw_13 from u_d_base within tabpage_13
integer x = 5
integer y = 8
integer taborder = 2
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type tabpage_14 from userobject within u_tab_inq_sort
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

type dw_14 from u_d_base within tabpage_14
integer x = 5
integer y = 8
integer taborder = 2
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

type tabpage_15 from userobject within u_tab_inq_sort
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

type dw_15 from u_d_base within tabpage_15
integer x = 5
integer y = 8
integer taborder = 2
end type

event doubleclicked;call super::doubleclicked;String ls_type, ls_name

ls_name = dwo.Name
If Upper(LeftA(ls_name, 2)) = "B_" Then Return 0
ls_type = dwo.Type
If Upper(ls_type) <> "COLUMN" Then Return 0

Return ufl_trigger_ue_dw_doubleclicked(SelectedTab, xpos, ypos, row, dwo)
end event

