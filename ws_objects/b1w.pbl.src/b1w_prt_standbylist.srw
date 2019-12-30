$PBExportHeader$b1w_prt_standbylist.srw
$PBExportComments$[ceusee] 신청 미처리 리스트
forward
global type b1w_prt_standbylist from w_a_print
end type
end forward

global type b1w_prt_standbylist from w_a_print
integer width = 3250
end type
global b1w_prt_standbylist b1w_prt_standbylist

type variables
String is_status[]
end variables

on b1w_prt_standbylist.create
call super::create
end on

on b1w_prt_standbylist.destroy
call super::destroy
end on

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_standlist
	Desc.	: 서비스 미처리 리스트
	Date	: 2002.10.13
	Ver.	: 1.0
	Programer : Choi Bo Ra(ceusee)
-------------------------------------------------------------------------*/
end event

event ue_ok;call super::ue_ok;//조회
String ls_orderfromdt, ls_ordertodt, ls_reqfromdt, ls_reqtodt
String ls_svccod, ls_partner, ls_priceplan, ls_status, ls_where, ls_where1
Date ld_orderfromdt, ld_ordertodt, ld_reqfromdt, ld_reqtodt
Long ll_row
Integer li_check, i

ld_orderfromdt = dw_cond.object.orderfromdt[1]
ld_ordertodt = dw_cond.object.ordertodt[1]
ld_reqfromdt = dw_cond.object.reqfromdt[1]
ld_reqtodt = dw_cond.object.reqtodt[1]
ls_orderfromdt = String(ld_orderfromdt, 'yyyymmdd')
ls_ordertodt = String(ld_ordertodt,'yyyymmdd')
ls_reqfromdt = String(ld_reqfromdt, 'yyyymmdd')
ls_reqtodt = String(ld_reqtodt,'yyyymmdd')
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_partner = Trim(dw_cond.object.partner[1])
ls_status = Trim(dw_cond.object.status[1])

If IsNull(ls_orderfromdt) Then ls_orderfromdt = ""
If IsNull(ls_ordertodt) Then ls_ordertodt = ""
If IsNull(ls_reqfromdt) Then ls_reqfromdt = ""
If IsNull(ls_reqtodt) Then ls_reqtodt = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_status) Then ls_status = ""

ls_where = ""
ls_where1 = ""
If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where = "svc.status = '" + ls_status + "' "
Else
	For i = 1 To UpperBound(is_status[])
		If ls_where1 <> "" Then  ls_where1 += " Or "
		ls_where1 += "svc.status = '" + is_status[i] + "'"
   Next
	ls_where = "(" + ls_where1 + ")"

End If


If ls_orderfromdt <> ""  and ls_ordertodt <> "" Then
	li_check = fi_chk_frto_day(ld_orderfromdt, ld_ordertodt)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "신청일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("orderfromdt")
		Return
	Else
		If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(svc.orderdt, 'yyyymmdd') >= '" + ls_orderfromdt + "' And " + &
						"to_char(svc.orderdt,'yyyymmdd') < = '" + ls_ordertodt + "' "
	End If
	
ElseIf ls_orderfromdt <> "" And ls_ordertodt = "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(svc.orderdt,'yyyymmdd') >= '" + ls_orderfromdt + "' " 
						
ElseIf ls_orderfromdt = "" And ls_ordertodt <> "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(svc.orderdt,'yyyymmdd') <= '" + ls_ordertodt + "' "
End If

If ls_reqfromdt <> ""  and ls_reqtodt <> "" Then
	li_check = fi_chk_frto_day(ld_reqfromdt,  ld_reqtodt)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "요청일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("reqfromdt")
		Return
	Else
		If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(svc.requestdt, 'yyyymmdd') >= '" + ls_reqfromdt + "' And " + &
						"to_char(svc.requestdt,'yyyymmdd') < = '" + ls_reqtodt + "' "
	End If
	  
ElseIf ls_reqfromdt <> "" And ls_ordertodt = "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(svc.requestdt,'yyyymmdd') >= '" + ls_reqfromdt + "' " 
			
ElseIf ls_reqfromdt = "" And ls_reqtodt <> "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(svc.requestdt,'yyyymmdd') <= '" + ls_reqtodt + "' "
		
End If


If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.svccod = '" + ls_svccod + "' "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.partner = '" + ls_partner + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.priceplan = '" + ls_priceplan + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

		



end event

type dw_cond from w_a_print`dw_cond within b1w_prt_standbylist
integer y = 36
integer width = 2363
integer height = 288
string dataobject = "b1dw_cnd_prt_standlist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::constructor;call super::constructor;//초기화
String ls_ref_desc, ls_status, ls_filter
DataWindowChild ldc_status
Integer li_exist, i

ls_ref_desc =""
ls_status = fs_get_control("B0", "P222", ls_ref_desc)
fi_cut_string(ls_status, ";", is_status[])		


li_exist = dw_cond.GetChild("status", ldc_status)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 신청상태")
For i = 1 To UpperBound(is_status[])
	If ls_filter <> "" Then  ls_filter += " Or "
	ls_filter += "code = '" + is_status[i] + "'"

Next

ldc_status.SetTransObject(SQLCA)
li_exist =ldc_status.Retrieve()
ldc_status.SetFilter(ls_filter)			//Filter정함
ldc_status.Filter()

  
If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If  
end event

type p_ok from w_a_print`p_ok within b1w_prt_standbylist
integer x = 2597
integer y = 64
end type

type p_close from w_a_print`p_close within b1w_prt_standbylist
integer x = 2898
integer y = 64
end type

type dw_list from w_a_print`dw_list within b1w_prt_standbylist
integer y = 388
integer width = 3127
integer height = 1232
string dataobject = "b1dw_prt_standbylist"
end type

type p_1 from w_a_print`p_1 within b1w_prt_standbylist
end type

type p_2 from w_a_print`p_2 within b1w_prt_standbylist
end type

type p_3 from w_a_print`p_3 within b1w_prt_standbylist
end type

type p_5 from w_a_print`p_5 within b1w_prt_standbylist
end type

type p_6 from w_a_print`p_6 within b1w_prt_standbylist
end type

type p_7 from w_a_print`p_7 within b1w_prt_standbylist
end type

type p_8 from w_a_print`p_8 within b1w_prt_standbylist
end type

type p_9 from w_a_print`p_9 within b1w_prt_standbylist
end type

type p_4 from w_a_print`p_4 within b1w_prt_standbylist
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_standbylist
end type

type p_port from w_a_print`p_port within b1w_prt_standbylist
end type

type p_land from w_a_print`p_land within b1w_prt_standbylist
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_standbylist
integer width = 2441
integer height = 364
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_standbylist
end type

