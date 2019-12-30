$PBExportHeader$u_tab_base.sru
$PBExportComments$Base Tab User Object
forward
global type u_tab_base from tab
end type
type tabpage_1 from userobject within u_tab_base
end type
type tabpage_1 from userobject within u_tab_base
end type
end forward

global type u_tab_base from tab
integer width = 1221
integer height = 892
integer taborder = 1
integer textsize = -9
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 79741120
boolean raggedright = true
integer selectedtab = 1
tabpage_1 tabpage_1
end type
global u_tab_base u_tab_base

on u_tab_base.create
this.tabpage_1=create tabpage_1
this.Control[]={this.tabpage_1}
end on

on u_tab_base.destroy
destroy(this.tabpage_1)
end on

type tabpage_1 from userobject within u_tab_base
integer x = 18
integer y = 108
integer width = 1184
integer height = 768
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
end type

