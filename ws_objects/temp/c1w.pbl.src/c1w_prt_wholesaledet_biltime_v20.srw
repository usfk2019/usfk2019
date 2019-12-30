$PBExportHeader$c1w_prt_wholesaledet_biltime_v20.srw
$PBExportComments$[ohj] wholesale 사업자 대역별 통화량 보고서(in/out) v20
forward
global type c1w_prt_wholesaledet_biltime_v20 from w_a_print
end type
end forward

global type c1w_prt_wholesaledet_biltime_v20 from w_a_print
end type
global c1w_prt_wholesaledet_biltime_v20 c1w_prt_wholesaledet_biltime_v20

on c1w_prt_wholesaledet_biltime_v20.create
call super::create
end on

on c1w_prt_wholesaledet_biltime_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	c1w_prt_wholesaledet_CURRENCY_TYPE_v20
	Desc.	: 	사업자 대역 정산 보고서(통화유형) 
	Ver.	:	1.0
	Date	:	2006.01.10
	Programer : OH HYE JIN
--------------------------------------------------------------------------*/

end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_inout_chk, ls_customerid, ls_fromdt, ls_todt, ls_check//, ls_currency_type
String ls_itemcod, ls_zoncod, ls_where
String ls_sql, ls_sql2, ls_sqlstmt
Long ll_rows

dw_cond.AcceptText()

ls_inout_chk     = Trim(dw_cond.Object.inout_chk[1])
ls_customerid    = Trim(dw_cond.Object.customerid[1])
ls_fromdt        = Trim(String(dw_cond.Object.fromdt[1],'yyyymmdd'))
ls_todt          = Trim(String(dw_cond.Object.todt[1],'yyyymmdd'))
ls_check         = Trim(dw_cond.Object.check[1])
ls_itemcod       = Trim(dw_cond.Object.itemcod[1])
ls_zoncod        = Trim(dw_cond.Object.zoncod[1])
//ls_currency_type = Trim(dw_cond.Object.currency_type[1])

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt)   Then ls_todt = ""

//If ls_currency_type  = "" Then
//	f_msg_info(200, title, "통화구분")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("currency_type")
//	Return
//End If

If ls_fromdt = "" Then
	f_msg_info(200, title, "기간을 입력하십시오")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_todt = "" Then
	f_msg_info(200, title, "기간을 입력하십시오")
	dw_cond.SetFocus()
	dw_cond.SetColumn("todt")
	Return
End If

If ls_fromdt > ls_todt Then
	f_msg_info(200, title, "기간설정 구간이 잘못되었습니다. 다시 입력하십시오")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

ls_where = ""
If ls_check = "Y"  Then 
	ls_where += " to_char(a.workdt,'yyyymmdd') >= '" + ls_fromdt + "' and to_char(a.workdt,'yyyymmdd') <= '" + ls_todt + "' "	
Else	
	ls_where += " to_char(a.stime, 'yyyymmdd') >= '" + ls_fromdt + "' and to_char(a.stime, 'yyyymmdd') <= '" + ls_todt + "' "				
End if

//If ls_currency_type <> "ALL" Then
//	 ls_where += " And "
//    ls_where += " b.currency_type = '" + ls_currency_type + "' "
//End If

If ls_inout_chk <> "A" Then
	 ls_where += " And "
    ls_where += " a.inout_chk = '" + ls_inout_chk + "' "
End If

If ls_customerid <> "" Then
	 ls_where += " And "
    ls_where += " a.customerid = '" + ls_customerid + "' "	 
End If

If ls_itemcod <> "" Then
	 ls_where += " And "
    ls_where += " a.itemcod = '" + ls_itemcod + "' "
End If

If ls_zoncod <> "" Then
	 ls_where += " And "
    ls_where += " a.zoncod = '" + ls_zoncod + "' "
End If

dw_list.Object.t_3.text = MidA(ls_fromdt,1,4) + "-" + MidA(ls_fromdt,5,2) + "-" + MidA(ls_fromdt,7,2) 
dw_list.Object.t_5.text = MidA(ls_todt,1,4) + "-" + MidA(ls_todt,5,2) + "-" + MidA(ls_todt,7,2) 

dw_list.is_where = ls_where
ll_rows = dw_list.Retrieve()

If ll_rows = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If	

//ls_where = ""
//If ls_inout_chk <> "A" Then
//	If ls_where <> "" Then ls_where += " And "
//    ls_where += " a.inout_chk = '" + ls_inout_chk + "' "
//End If
//
//If ls_customerid <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//    ls_where += " a.customerid = '" + ls_customerid + "' "
//End If
//
//If ls_check = 'Y' Then
//   If ls_fromdt <> "" Then
//	   If ls_where <> "" Then ls_where += " And "
//	      ls_where += "to_char(a.workdt,'yyyymmdd') >= '" + ls_fromdt + "' "
//   End If
//	If ls_todt <> "" Then
//	   If ls_where <> "" Then ls_where += " And "
//	      ls_where += "to_char(a.workdt,'yyyymmdd') <= '" + ls_todt + "' "	
//   End If
//Else
//	If ls_fromdt <> "" Then
//	   If ls_where <> "" Then ls_where += " And "
//	      ls_where += "to_char(a.stime,'yyyymmdd') >= '" + ls_fromdt + "' "
//   End If
//	If ls_todt <> "" Then
//	   If ls_where <> "" Then ls_where += " And "
//	      ls_where += "to_char(a.stime,'yyyymmdd') <= '" + ls_todt + "' "	
//   End If
//End If
//
//If ls_itemcod <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//    ls_where += " a.itemcod = '" + ls_itemcod + "' "
//End If
//
//If ls_zoncod <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//    ls_where += " a.zoncod = '" + ls_zoncod + "' "
//End If
//
//dw_list.Object.t_3.text = mid(ls_fromdt,1,4) + "-" + mid(ls_fromdt,5,2) + "-" + mid(ls_fromdt,7,2) 
//dw_list.Object.t_5.text = mid(ls_todt,1,4) + "-" + mid(ls_todt,5,2) + "-" + mid(ls_todt,7,2) 
//  
// dw_list.is_where = ls_where
// ll_rows	= dw_list.Retrieve()
// If( ll_rows = 0 ) Then
//	f_msg_info(1000, Title, "")
// ElseIf( ll_rows < 0 ) Then
//	f_msg_usr_err(2100, Title, "Retrieve()")
// End If
//
//
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset;call super::ue_reset;//Date ld_sysdate
//
//ld_sysdate = date(fdt_get_dbserver_now())
//
//dw_cond.Object.start_month[1] = ld_sysdate
end event

type dw_cond from w_a_print`dw_cond within c1w_prt_wholesaledet_biltime_v20
integer y = 64
integer height = 356
string dataobject = "c1dw_prt_cnd_wholesaledet_biltime_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Long ll_row
String ls_inout_chk, ls_filter
DataWindowChild ldc_customerid

dw_cond.Accepttext()

If dwo.name = "inout_chk" Then
	IF data = 'A' THEN
		data = ''
	END IF
	ll_row = dw_cond.GetChild("customerid", ldc_customerid)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
	ls_filter = " customer_type LIKE '" + data + "%' "
	
	ldc_customerid.SetFilter(ls_filter)			//Filter정함
	ll_row = ldc_customerid.Filter()
	ldc_customerid.SetTransObject(SQLCA)
	ll_row = ldc_customerid.Retrieve()
	
End If

return

end event

type p_ok from w_a_print`p_ok within c1w_prt_wholesaledet_biltime_v20
end type

type p_close from w_a_print`p_close within c1w_prt_wholesaledet_biltime_v20
end type

type dw_list from w_a_print`dw_list within c1w_prt_wholesaledet_biltime_v20
integer x = 32
integer y = 448
integer height = 1160
string dataobject = "c1dw_prt_det_wholesaledet_biltime_v20"
end type

type p_1 from w_a_print`p_1 within c1w_prt_wholesaledet_biltime_v20
end type

type p_2 from w_a_print`p_2 within c1w_prt_wholesaledet_biltime_v20
end type

type p_3 from w_a_print`p_3 within c1w_prt_wholesaledet_biltime_v20
end type

type p_5 from w_a_print`p_5 within c1w_prt_wholesaledet_biltime_v20
end type

type p_6 from w_a_print`p_6 within c1w_prt_wholesaledet_biltime_v20
end type

type p_7 from w_a_print`p_7 within c1w_prt_wholesaledet_biltime_v20
end type

type p_8 from w_a_print`p_8 within c1w_prt_wholesaledet_biltime_v20
end type

type p_9 from w_a_print`p_9 within c1w_prt_wholesaledet_biltime_v20
end type

type p_4 from w_a_print`p_4 within c1w_prt_wholesaledet_biltime_v20
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_wholesaledet_biltime_v20
end type

type p_port from w_a_print`p_port within c1w_prt_wholesaledet_biltime_v20
end type

type p_land from w_a_print`p_land within c1w_prt_wholesaledet_biltime_v20
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_wholesaledet_biltime_v20
integer height = 436
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_wholesaledet_biltime_v20
end type

