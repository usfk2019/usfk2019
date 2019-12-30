$PBExportHeader$ssrt_exchange_rate_pop.srw
forward
global type ssrt_exchange_rate_pop from w_a_hlp
end type
end forward

global type ssrt_exchange_rate_pop from w_a_hlp
integer width = 1577
integer height = 872
string title = ""
end type
global ssrt_exchange_rate_pop ssrt_exchange_rate_pop

type variables

end variables

on ssrt_exchange_rate_pop.create
call super::create
end on

on ssrt_exchange_rate_pop.destroy
call super::destroy
end on

event open;This.Title = " Exchange Rate"
p_ok.TriggerEvent("ue_enable")


DEC{2}	ldc_rate

//window 중앙에
f_center_window(this)

dw_cond.Reset()
dw_cond.InsertRow(0)

select rate INTO :ldc_rate from exchangerate
 where to_char(fromdt, 'yyyymmdd')  = ( select MAX(fromdt) from exchangerate ) ;
 
IF IsNull(ldc_rate) then ldc_rate = 0

dw_cond.Object.rate[1] =  ldc_rate
dw_cond.SetFocus()
dw_cond.SetColumn('WON')





end event

event ue_ok();DEC{2}	ldc_rate, ldc_won, ldc_usd


dw_cond.AcceptText()
ldc_rate =  dw_cond.Object.rate[1]
ldc_won 	=  dw_cond.Object.won[1]

IF IsNull(ldc_won) then ldc_won = 0
IF ldc_won > 0 then
	ldc_usd = Round(ldc_won / ldc_rate, 2)
	dw_cond.Object.usd[1] = ldc_usd
END IF

end event

event ue_close();call super::ue_close;Close(This)
end event

type p_1 from w_a_hlp`p_1 within ssrt_exchange_rate_pop
boolean visible = false
integer x = 485
integer y = 624
end type

type dw_cond from w_a_hlp`dw_cond within ssrt_exchange_rate_pop
integer x = 41
integer width = 1458
integer height = 436
string dataobject = "ssrt_cnd_exchange_rate"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within ssrt_exchange_rate_pop
integer x = 786
integer y = 628
end type

type p_close from w_a_hlp`p_close within ssrt_exchange_rate_pop
integer x = 1093
integer y = 628
end type

type gb_cond from w_a_hlp`gb_cond within ssrt_exchange_rate_pop
integer x = 23
integer width = 1499
integer height = 572
end type

type dw_hlp from w_a_hlp`dw_hlp within ssrt_exchange_rate_pop
boolean visible = false
integer x = 82
integer y = 496
integer width = 306
integer height = 68
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_hlp::clicked;call super::clicked;//MessageBox("xpos",String (xpos) + "  "  + String(ypos) + String (dwo))
end event

