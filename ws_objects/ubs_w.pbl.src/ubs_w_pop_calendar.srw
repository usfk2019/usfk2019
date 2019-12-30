$PBExportHeader$ubs_w_pop_calendar.srw
$PBExportComments$[jhchoi] Calendar - 2009.02.19
forward
global type ubs_w_pop_calendar from window
end type
type dw_temp from datawindow within ubs_w_pop_calendar
end type
type uo_1 from u_calendar_sams within ubs_w_pop_calendar
end type
type gb_2 from groupbox within ubs_w_pop_calendar
end type
end forward

global type ubs_w_pop_calendar from window
integer width = 978
integer height = 868
boolean titlebar = true
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 80269524
event ue_ok ( )
dw_temp dw_temp
uo_1 uo_1
gb_2 gb_2
end type
global ubs_w_pop_calendar ubs_w_pop_calendar

type variables
// 달력관련 추가-1hera
s_calendar_sams istr_cal

u_cust_a_msg 	iu_cust_msg

String is_customerid
datawindow idw_data

String 	is_reqdt, 	is_userid, 	is_pgm_id, &
			is_basecod, 		is_control,	is_time[], &
			is_worktype[]
String 	is_emp_grp, is_schedule_type, is_svccod, is_priceplan
INTEGER	ii_maxnum, ii_troubleno, ii_time =  19 //Time의 간격수
Boolean 	ib_order
date		idt_reqdt
end variables

event ue_ok();return

end event

on ubs_w_pop_calendar.create
this.dw_temp=create dw_temp
this.uo_1=create uo_1
this.gb_2=create gb_2
this.Control[]={this.dw_temp,&
this.uo_1,&
this.gb_2}
end on

on ubs_w_pop_calendar.destroy
destroy(this.dw_temp)
destroy(this.uo_1)
destroy(this.gb_2)
end on

event open;uo_1.Show()
istr_cal.caldate = Today()
uo_1.uf_InitCal(istr_cal.caldate)

iu_cust_msg = CREATE u_cust_a_msg
iu_cust_msg = Message.PowerObjectParm

//window 중앙에
f_center_window(THIS)

//iu_cust_help2.is_pgm_name = "Calendar"
//iu_cust_help2.is_grp_name = "날짜선택"
//iu_cust_help2.ib_data[1]  = True
//iu_cust_help2.idw_data[1] = dw_master
	
idw_data = iu_cust_msg.idw_data[1]

THIS.Title = iu_cust_msg.is_pgm_name
end event

event close;Close(This)
end event

type dw_temp from datawindow within ubs_w_pop_calendar
boolean visible = false
integer x = 1001
integer y = 872
integer width = 411
integer height = 128
integer taborder = 60
string title = "none"
string dataobject = "ubs_dw_calendar_t"
boolean livescroll = true
end type

event constructor;SetTransObject(sqlca)

end event

type uo_1 from u_calendar_sams within ubs_w_pop_calendar
integer x = 32
integer y = 24
integer width = 887
integer taborder = 20
end type

event ue_clicked();call super::ue_clicked;String ls_date_selected

idw_data.Object.lease_period[1] = id_date_selected

idw_data.Event ItemChanged(1, idw_data.Object.lease_period, STRING(id_date_selected, 'yyyymmdd')) 

close(parent)
end event

on uo_1.destroy
call u_calendar_sams::destroy
end on

type gb_2 from groupbox within ubs_w_pop_calendar
integer x = 23
integer y = 8
integer width = 905
integer height = 732
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
borderstyle borderstyle = stylelowered!
end type

