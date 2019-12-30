$PBExportHeader$u_tab_title.sru
$PBExportComments$Title Tab User Object(from t_tab_base)
forward
global type u_tab_title from u_tab_base
end type
type tabpage_2 from userobject within u_tab_title
end type
type tabpage_3 from userobject within u_tab_title
end type
type tabpage_4 from userobject within u_tab_title
end type
type tabpage_5 from userobject within u_tab_title
end type
type tabpage_6 from userobject within u_tab_title
end type
type tabpage_7 from userobject within u_tab_title
end type
type tabpage_8 from userobject within u_tab_title
end type
type tabpage_9 from userobject within u_tab_title
end type
type tabpage_10 from userobject within u_tab_title
end type
type tabpage_2 from userobject within u_tab_title
end type
type tabpage_3 from userobject within u_tab_title
end type
type tabpage_4 from userobject within u_tab_title
end type
type tabpage_5 from userobject within u_tab_title
end type
type tabpage_6 from userobject within u_tab_title
end type
type tabpage_7 from userobject within u_tab_title
end type
type tabpage_8 from userobject within u_tab_title
end type
type tabpage_9 from userobject within u_tab_title
end type
type tabpage_10 from userobject within u_tab_title
end type
end forward

global type u_tab_title from u_tab_base
int Width=2414
boolean MultiLine=true
boolean BoldSelectedText=true
tabpage_2 tabpage_2
tabpage_3 tabpage_3
tabpage_4 tabpage_4
tabpage_5 tabpage_5
tabpage_6 tabpage_6
tabpage_7 tabpage_7
tabpage_8 tabpage_8
tabpage_9 tabpage_9
tabpage_10 tabpage_10
event ue_init ( )
end type
global u_tab_title u_tab_title

type variables
int ii_enable_max_tab
window iw_parent
string is_tab_title[]
string is_parent_title
end variables

on u_tab_title.create
this.tabpage_2=create tabpage_2
this.tabpage_3=create tabpage_3
this.tabpage_4=create tabpage_4
this.tabpage_5=create tabpage_5
this.tabpage_6=create tabpage_6
this.tabpage_7=create tabpage_7
this.tabpage_8=create tabpage_8
this.tabpage_9=create tabpage_9
this.tabpage_10=create tabpage_10
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tabpage_2
this.Control[iCurrent+2]=this.tabpage_3
this.Control[iCurrent+3]=this.tabpage_4
this.Control[iCurrent+4]=this.tabpage_5
this.Control[iCurrent+5]=this.tabpage_6
this.Control[iCurrent+6]=this.tabpage_7
this.Control[iCurrent+7]=this.tabpage_8
this.Control[iCurrent+8]=this.tabpage_9
this.Control[iCurrent+9]=this.tabpage_10
end on

on u_tab_title.destroy
call super::destroy
destroy(this.tabpage_2)
destroy(this.tabpage_3)
destroy(this.tabpage_4)
destroy(this.tabpage_5)
destroy(this.tabpage_6)
destroy(this.tabpage_7)
destroy(this.tabpage_8)
destroy(this.tabpage_9)
destroy(this.tabpage_10)
end on

event selectionchanged;call super::selectionchanged;If is_parent_title = "" Then
	is_parent_title = iw_parent.title
End if

iw_Parent.Title = is_parent_title + "[" + This.Control[newindex].Text + "]"
end event

event constructor;This.TriggerEvent('ue_init')

Int li_i
Int li_max_index

li_max_index = UpperBound(This.Control) //Contorl[] : Tab Control내의 TabPages들

If ii_enable_max_tab > li_max_index Then
	MessageBox("ERROR","TAB CONTROL의 허용 범위가 넘었습니다.!",StopSign!)
	Return 
End if

For li_i = ii_enable_max_tab + 1 To li_max_index
	This.Control[li_i].Visible = False
Next

For li_i = 1 To ii_enable_max_tab
	This.Control[li_i].Text = is_tab_title[li_i]
Next

end event

type tabpage_1 from u_tab_base`tabpage_1 within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
end type

type tabpage_2 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_3 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_4 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_5 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_6 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_7 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_8 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_9 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

type tabpage_10 from userobject within u_tab_title
int X=18
int Y=108
int Width=2377
int Height=768
long BackColor=67108864
string Text="none"
long TabBackColor=67108864
long TabTextColor=33554432
long PictureMaskColor=536870912
end type

