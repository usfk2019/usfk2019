﻿$PBExportHeader$b5w_1_prt_postbil_err_vtel.srw
$PBExportComments$[jsha] 통화상품Rating오류보고서
forward
global type b5w_1_prt_postbil_err_vtel from w_a_print
end type
end forward

global type b5w_1_prt_postbil_err_vtel from w_a_print
end type
global b5w_1_prt_postbil_err_vtel b5w_1_prt_postbil_err_vtel

event open;call super::open;ii_orientation = 2

end event

event ue_ok();call super::ue_ok;String ls_where, ls_fromdt, ls_todt, ls_validkey, &
		 ls_customerid, ls_originnum, ls_rtelnum, &
		 ls_priceplan, ls_zoncod, ls_svccod
Date ld_fromdt, ld_todt
Long ll_row

ld_fromdt = dw_cond.Object.stime[1]
ld_todt = dw_cond.Object.etime[1]
ls_fromdt = String(ld_Fromdt, 'yyyymmdd')
ls_todt = String(ld_todt, 'yyyymmdd')
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_customerid = Trim(dw_cond.Object.customerid[1])
//ls_originnum = Trim(dw_cond.Object.originnum[1])
//ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
ls_svccod = Trim(dw_cond.Object.svccod[1])
ls_priceplan = Trim(dw_cond.Object.priceplan[1])
//ls_zoncod = Trim(dw_cond.Object.zoncod[1])

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_customerid) Then ls_customerid = ""
//If IsNull(ls_originnum) Then ls_originnum = ""
//If IsNull(ls_rtelnum) Then ls_rtelnum = ""
If IsNull(ls_svccod) Then ls_svccod=""
If IsNull(ls_priceplan) Then ls_priceplan = ""
//If IsNull(ls_zoncod) Then ls_zoncod = ""

//** Mandatory Input Condition Check **//
If ls_fromdt = "" Then
	f_msg_usr_err(200, This.Title, "통화일자")
	dw_cond.SetColumn("stime")
	dw_cond.SetFocus()
	Return
End If
If ls_todt = "" Then
	f_msg_usr_err(200, This.Title, "통화일자")
	dw_cond.SetColumn("etime")
	dw_cond.SetFocus()
	Return
End If

/*
If ls_validkey = "" AND ls_customerid = "" AND ls_originnum = "" AND ls_rtelnum = "" &
	AND ls_priceplan = "" AND ls_zoncod = "" Then
	f_msg_usr_err(9000, This.Title, "조건들중에 적어도 한가지는 입력하셔야 합니다.")
	Return
End If
*/

//** Making Dynamic SQL **//
ls_where = ""
ls_where += " flag = 'E'  AND BILTIME > 0 " 

If ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "workdt >= to_date('" + ls_fromdt + "') "
End If
If ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "workdt <= to_date('" + ls_todt + "') + 0.99999 "  
End If
If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "validkey = '" + ls_validkey + "' "
End If
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "customerid = '" + ls_customerid + "' "
End If
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "svccod = '" + ls_svccod +"' "
End If
/*If ls_originnum <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "originnum = '" + ls_originnum + "' "
End If
IF ls_rtelnum <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "rtelnum = '" + ls_rtelnum + "' "
ENd If*/
If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "priceplan = '" + ls_priceplan + "' "
ENd If
/*
If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "zoncod = '" + ls_zoncod + "' "
End If
*/

//** Retrieve **//
dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
	Return
End If

Return
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on b5w_1_prt_postbil_err_vtel.create
call super::create
end on

on b5w_1_prt_postbil_err_vtel.destroy
call super::destroy
end on

type dw_cond from w_a_print`dw_cond within b5w_1_prt_postbil_err_vtel
integer width = 1998
integer height = 396
string dataobject = "b5dw_1_cnd_prt_postbil_err_vtel"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			This.Object.customerid[1] = iu_cust_help.is_data[1]
		End If
End Choose
end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = This.Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "ClosewithReturn"

end event

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan
String ls_svccod, ls_svctype, ls_filter
Int    li_exist




This.AcceptText()

Choose Case dwo.name

	Case "svccod"
		ls_svccod = data
		
		Select svctype
		  Into :ls_svctype
		  From svcmst
		 where svccod = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT svctype from svcmst")				
			Return 1
		End If	
				
		li_exist = This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		ls_filter = "svccod = '" + data  + "'" 

		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  
		
End Choose
end event

type p_ok from w_a_print`p_ok within b5w_1_prt_postbil_err_vtel
integer x = 2240
end type

type p_close from w_a_print`p_close within b5w_1_prt_postbil_err_vtel
integer x = 2542
end type

type dw_list from w_a_print`dw_list within b5w_1_prt_postbil_err_vtel
integer x = 27
integer y = 508
integer height = 1100
string dataobject = "b5dw_1_prt_postbil_err_vtel"
end type

type p_1 from w_a_print`p_1 within b5w_1_prt_postbil_err_vtel
end type

type p_2 from w_a_print`p_2 within b5w_1_prt_postbil_err_vtel
end type

type p_3 from w_a_print`p_3 within b5w_1_prt_postbil_err_vtel
end type

type p_5 from w_a_print`p_5 within b5w_1_prt_postbil_err_vtel
end type

type p_6 from w_a_print`p_6 within b5w_1_prt_postbil_err_vtel
end type

type p_7 from w_a_print`p_7 within b5w_1_prt_postbil_err_vtel
end type

type p_8 from w_a_print`p_8 within b5w_1_prt_postbil_err_vtel
end type

type p_9 from w_a_print`p_9 within b5w_1_prt_postbil_err_vtel
end type

type p_4 from w_a_print`p_4 within b5w_1_prt_postbil_err_vtel
end type

type gb_1 from w_a_print`gb_1 within b5w_1_prt_postbil_err_vtel
end type

type p_port from w_a_print`p_port within b5w_1_prt_postbil_err_vtel
end type

type p_land from w_a_print`p_land within b5w_1_prt_postbil_err_vtel
end type

type gb_cond from w_a_print`gb_cond within b5w_1_prt_postbil_err_vtel
integer width = 2057
integer height = 484
end type

type p_saveas from w_a_print`p_saveas within b5w_1_prt_postbil_err_vtel
end type

