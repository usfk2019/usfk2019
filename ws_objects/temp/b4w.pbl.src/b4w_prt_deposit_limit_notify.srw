$PBExportHeader$b4w_prt_deposit_limit_notify.srw
$PBExportComments$[juede] 보증금한도초과 조치이력
forward
global type b4w_prt_deposit_limit_notify from w_a_print
end type
end forward

global type b4w_prt_deposit_limit_notify from w_a_print
integer width = 3296
end type
global b4w_prt_deposit_limit_notify b4w_prt_deposit_limit_notify

on b4w_prt_deposit_limit_notify.create
call super::create
end on

on b4w_prt_deposit_limit_notify.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_crtfrom, ls_crtto
Date     ld_crtfrom, ld_crtto


ls_crtfrom		= Trim(String(dw_cond.object.crtdt_from[1],'yyyymmdd'))
ld_crtfrom     = dw_cond.Object.crtdt_from[1]
ls_crtto			= Trim(String(dw_cond.object.crtdt_to[1],'yyyymmdd'))
ld_crtto       = dw_cond.object.crtdt_to[1]


If( IsNull(ls_crtfrom) ) Then ls_crtfrom = ""
If( IsNull(ls_crtto) ) Then ls_crtto = ""


If ls_crtfrom = "" Then
	f_msg_usr_err(200, Title, "작업일from")
	dw_cond.SetColumn("crtdt_from")
	dw_cond.SetFocus()
   Return 
Else 
	If ls_crtto = "" Then		
		dw_cond.Object.crtdt_to[1] = ld_crtfrom
	ElseIf ld_crtto < ld_crtfrom Then
		f_msg_usr_err(200, Title, "작업일From 을 확인하세요.")
		dw_cond.SetColumn("crtdt_from")
		dw_cond.SetFocus()
		Return 		
	End If
End If

If ls_crtto <>"" Then
	If ls_crtfrom = "" Then
		f_msg_usr_err(200, Title, "작업일from")
		dw_cond.SetColumn("crtdt_from")
		dw_cond.SetFocus()
  		Return 		
	End If
	
	If ld_crtto < ld_crtfrom Then
		f_msg_usr_err(200, Title, "작업일From 을 확인하세요.")
		dw_cond.SetColumn("crtdt_from")
		dw_cond.SetFocus()
		Return 		
	End If	
End If
	

//Dynamic SQL
ls_where = ""

If( ls_crtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(d.crtdt, 'YYYYMMDD') >= '"+ ls_crtfrom +"'"
End If

If( ls_crtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(d.crtdt, 'YYYYMMDD') <= '"+ ls_crtto +"'"
End If

dw_list.is_where	= ls_where

//MessageBox("쿼리", ls_where)

//Retrieve
ll_rows	= dw_list.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
End If
end event

event ue_init();call super::ue_init;ii_orientation = 2
dw_list.object.datawindow.print.orientation = ii_orientation

end event

type dw_cond from w_a_print`dw_cond within b4w_prt_deposit_limit_notify
integer width = 1751
integer height = 280
string dataobject = "b4dw_cnd_prt_deposit_limit_notify"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "payid"
		Object.customernm[1] = ""
		
End Choose
end event

type p_ok from w_a_print`p_ok within b4w_prt_deposit_limit_notify
integer x = 1975
integer y = 32
end type

type p_close from w_a_print`p_close within b4w_prt_deposit_limit_notify
integer x = 2277
integer y = 32
end type

type dw_list from w_a_print`dw_list within b4w_prt_deposit_limit_notify
integer y = 400
integer width = 3182
integer height = 1220
string dataobject = "b4dw_prt_deposit_limit_notify"
end type

type p_1 from w_a_print`p_1 within b4w_prt_deposit_limit_notify
end type

type p_2 from w_a_print`p_2 within b4w_prt_deposit_limit_notify
end type

type p_3 from w_a_print`p_3 within b4w_prt_deposit_limit_notify
end type

type p_5 from w_a_print`p_5 within b4w_prt_deposit_limit_notify
end type

type p_6 from w_a_print`p_6 within b4w_prt_deposit_limit_notify
end type

type p_7 from w_a_print`p_7 within b4w_prt_deposit_limit_notify
end type

type p_8 from w_a_print`p_8 within b4w_prt_deposit_limit_notify
end type

type p_9 from w_a_print`p_9 within b4w_prt_deposit_limit_notify
end type

type p_4 from w_a_print`p_4 within b4w_prt_deposit_limit_notify
end type

type gb_1 from w_a_print`gb_1 within b4w_prt_deposit_limit_notify
end type

type p_port from w_a_print`p_port within b4w_prt_deposit_limit_notify
end type

type p_land from w_a_print`p_land within b4w_prt_deposit_limit_notify
end type

type gb_cond from w_a_print`gb_cond within b4w_prt_deposit_limit_notify
integer width = 1879
integer height = 368
integer taborder = 30
end type

type p_saveas from w_a_print`p_saveas within b4w_prt_deposit_limit_notify
end type

