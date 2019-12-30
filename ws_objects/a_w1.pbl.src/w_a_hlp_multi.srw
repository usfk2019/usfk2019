$PBExportHeader$w_a_hlp_multi.srw
$PBExportComments$Multi select help window ( from w_base )
forward
global type w_a_hlp_multi from w_base
end type
type dw_cond from u_d_external within w_a_hlp_multi
end type
type p_ok from u_p_ok within w_a_hlp_multi
end type
type p_close from u_p_close within w_a_hlp_multi
end type
type p_1 from u_p_find within w_a_hlp_multi
end type
type dw_hlp from u_d_mul_sel_ext within w_a_hlp_multi
end type
end forward

global type w_a_hlp_multi from w_base
integer width = 1861
string title = "HELP"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
event ue_ok ( )
event ue_close ( )
event ue_find ( )
event ue_extra_ok ( )
dw_cond dw_cond
p_ok p_ok
p_close p_close
p_1 p_1
dw_hlp dw_hlp
end type
global w_a_hlp_multi w_a_hlp_multi

type variables
u_cust_a_msg iu_cust_help
datawindow dw_source
string is_data[], is_data_nm[]
string is_data2[], is_data3[], is_temp[]
end variables

event ue_ok;call super::ue_ok;Long ll_row
Integer li_ret
dw_hlp.AcceptText() 

ll_row = dw_hlp.GetSelectedRow( 0 ) 
if ll_row = 0 Then Return

trigger event ue_extra_ok( )

Close( this )	
end event

event ue_close;call super::ue_close;iu_cust_help.is_data[] = is_data[] 
Close( This )


end event

event ue_find;call super::ue_find;dw_cond.AcceptText()
end event

on w_a_hlp_multi.create
int iCurrent
call super::create
this.dw_cond=create dw_cond
this.p_ok=create p_ok
this.p_close=create p_close
this.p_1=create p_1
this.dw_hlp=create dw_hlp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cond
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.p_1
this.Control[iCurrent+5]=this.dw_hlp
end on

on w_a_hlp_multi.destroy
call super::destroy
destroy(this.dw_cond)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.p_1)
destroy(this.dw_hlp)
end on

event open;// Overrided
iu_cust_help = Message.PowerObjectParm

dw_source = iu_cust_help.idw_data[1]
is_temp[] = iu_cust_help.is_temp[]

// initialize as upperbound = 0
string ls_temp[]
iu_cust_help.is_data[] = ls_temp[]
iu_cust_help.is_data2[] = ls_temp[]
iu_cust_help.is_data3[] = ls_temp[]

end event

event close;// Overrided

iu_cust_help.is_data[] = is_data[]
iu_cust_help.is_data2[] = is_data2[]
iu_cust_help.is_data3[] = is_data3[]
iu_cust_help.is_data_nm[] = is_data_nm[]
end event

type dw_cond from u_d_external within w_a_hlp_multi
integer x = 18
integer y = 52
integer width = 1079
integer height = 372
integer taborder = 20
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;//SetTransObject(SQLCA)
//InsertRow( 0 )
end event

event destructor;//
end event

type p_ok from u_p_ok within w_a_hlp_multi
integer x = 1408
integer y = 72
end type

type p_close from u_p_close within w_a_hlp_multi
integer x = 1413
integer y = 196
boolean originalsize = false
end type

type p_1 from u_p_find within w_a_hlp_multi
integer x = 1175
integer y = 68
integer width = 201
integer height = 176
end type

type dw_hlp from u_d_mul_sel_ext within w_a_hlp_multi
integer x = 18
integer y = 472
integer width = 1787
integer height = 1344
integer taborder = 10
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

