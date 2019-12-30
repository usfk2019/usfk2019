﻿$PBExportHeader$c1w_prt_wholesaledet_zone_v20.srw
$PBExportComments$[ssong] wholesale  사업자 대역 정산 보고서
forward
global type c1w_prt_wholesaledet_zone_v20 from w_a_print
end type
end forward

global type c1w_prt_wholesaledet_zone_v20 from w_a_print
end type
global c1w_prt_wholesaledet_zone_v20 c1w_prt_wholesaledet_zone_v20

on c1w_prt_wholesaledet_zone_v20.create
call super::create
end on

on c1w_prt_wholesaledet_zone_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	c1w_prt_wholesaledet_zone_v20
	Desc.	: 	사업자 대역 정산 보고서 
	Ver.	:	1.0
	Date	:	2005.09.12
	Programer : Song Eun Mi
--------------------------------------------------------------------------*/

end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_inout_chk, ls_customerid, ls_fromdt, ls_todt, ls_check
String ls_itemcod, ls_zoncod, ls_where
String ls_sql, ls_sql2, ls_sqlstmt
DEC ld_exchange_rate
Long ll_rows

dw_cond.AcceptText()

ls_inout_chk = Trim(dw_cond.Object.inout_chk[1])
ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_fromdt = Trim(String(dw_cond.Object.fromdt[1],'yyyymmdd'))
ls_todt = Trim(String(dw_cond.Object.todt[1],'yyyymmdd'))
ls_check = Trim(dw_cond.Object.check[1])
ls_itemcod = Trim(dw_cond.Object.itemcod[1])
ls_zoncod = Trim(dw_cond.Object.zoncod[1])
ld_exchange_rate = dw_cond.Object.exchange_rate[1]

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""


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

If ld_exchange_rate = 0 Then
	f_msg_info(200, title, "적용환율이 '0' 입니다. 다시 입력하십시오")
	dw_cond.SetFocus()
	dw_cond.SetColumn("exchange_rate")
	Return
End If


If ls_check = "Y"  Then  
	ls_sql = " select  z.customerid, z.itemcod, z.zoncod, z.opendt, z.tmcod, z.unitsec, z.unitfee,  " + &
				"         sum(z.bilcnt) bilcnt, round(sum(z.biltime)/60,2) biltime, " +&
				"         decode(mod(sum(z.biltime),z.unitsec),0,sum(z.biltime)/z.unitsec*z.unitfee,(trunc(sum(z.biltime)/z.unitsec)+1)*z.unitfee) bilamt , '" + String(ld_exchange_rate,'#,##0.000000') +"' exchange_rate " +&
				" from    (  " + &
				" select  a.customerid, a.itemcod, a.zoncod, b.opendt, b.tmcod, b.unitsec, b.unitfee, a.bilcnt, a.biltime " + &
            " from   wholesale_det a, zoncst2 b                                            " + &
            " where  to_char(a.workdt,'yyyymmdd') >= '" + ls_fromdt + "' and to_char(a.workdt,'yyyymmdd') <= '" + ls_todt + "' " + &
				" and    decode(b.enddt,null,to_char(sysdate,'yyyymmdd'),to_char(b.enddt,'yyyymmdd')) >= '" + ls_fromdt + "' and to_char(b.opendt,'yyyymmdd') <= '" + ls_todt + "' " + &
            " and    a.svccod = b.svccod  " + &
            " and    a.priceplan = b.priceplan   " + &
				" and    a.zoncod = b.zoncod " + &
				" and    a.itemcod = b.itemcod " 
			
  ls_sql2 = " ) z " + &
            " group by z.customerid, z.itemcod, z.zoncod, z.opendt, z.tmcod, z.unitsec, z.unitfee "
				
Else	
	ls_sql = " select  z.customerid, z.itemcod, z.zoncod, z.opendt, z.tmcod, z.unitsec, z.unitfee, " + &
				"         sum(z.bilcnt) bilcnt, round(sum(z.biltime)/60,2) biltime, " + &
				"         decode(mod(sum(z.biltime),z.unitsec),0,sum(z.biltime)/z.unitsec*z.unitfee,(trunc(sum(z.biltime)/z.unitsec)+1)*z.unitfee) bilamt '" + String(ld_exchange_rate,'#,##0.000000') +"' exchange_rate " +&
				" from    ( " + &
				" select  a.customerid, a.itemcod, a.zoncod, b.opendt, b.tmcod, b.unitsec,b.unitfee, a.bilcnt, a.biltime " + &
            " from   wholesale_det a, zoncst2 b " + &
            " where  to_char(a.stime,'yyyymmdd') >= '" + ls_fromdt + "' and to_char(a.stime,'yyyymmdd') <= '" + ls_todt + "' " + &
				" and    decode(b.enddt,null,to_char(sysdate,'yyyymmdd'),to_char(b.enddt,'yyyymmdd')) >= '" + ls_fromdt + "' and to_char(b.opendt,'yyyymmdd') <= '" + ls_todt + "' " + &
            " and    a.svccod = b.svccod                                                           " + &
            " and    a.priceplan = b.priceplan                                                         " + &
				" and    a.zoncod = b.zoncod " + &
				" and    a.itemcod = b.itemcod " 
			
  ls_sql2 = " ) z " + &
            " group by z.customerid, z.itemcod, z.zoncod, z.opendt, z.tmcod, z.unitsec, z.unitfee "
  
End if

ls_where = ""

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



If ls_where <> "" Then
		ls_sqlstmt = ls_sql + ls_where + ls_sql2 
	Else
		ls_sqlstmt = ls_sql + ls_sql2

End If

dw_list.SetRedraw(false)
dw_list.SetSQLSelect(ls_sqlstmt)



dw_list.SetTransObject(SQLCA)
dw_list.Object.t_3.text = MidA(ls_fromdt,1,4) + "-" + MidA(ls_fromdt,5,2) + "-" + MidA(ls_fromdt,7,2) 
dw_list.Object.t_5.text = MidA(ls_todt,1,4) + "-" + MidA(ls_todt,5,2) + "-" + MidA(ls_todt,7,2) 
dw_list.Object.exchange_rate[1] = ld_exchange_rate
ll_rows = dw_list.Retrieve()


dw_list.SetRedraw(True)

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

type dw_cond from w_a_print`dw_cond within c1w_prt_wholesaledet_zone_v20
integer y = 40
integer height = 332
string dataobject = "c1dw_prt_cnd_wholesaledet_zone_v20"
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
	
	ls_filter = "WHOLESALE_CUSTOMER_CUSTOMER_TYPE like '" + data+'%' + "' "
	
	ldc_customerid.SetFilter(ls_filter)			//Filter정함
	ll_row = ldc_customerid.Filter()
	ldc_customerid.SetTransObject(SQLCA)
	ll_row = ldc_customerid.Retrieve()
	
End If

return

end event

type p_ok from w_a_print`p_ok within c1w_prt_wholesaledet_zone_v20
end type

type p_close from w_a_print`p_close within c1w_prt_wholesaledet_zone_v20
end type

type dw_list from w_a_print`dw_list within c1w_prt_wholesaledet_zone_v20
integer y = 396
integer height = 1216
string dataobject = "c1dw_prt_det_wholesaledet_zone_1_v20"
end type

type p_1 from w_a_print`p_1 within c1w_prt_wholesaledet_zone_v20
end type

type p_2 from w_a_print`p_2 within c1w_prt_wholesaledet_zone_v20
end type

type p_3 from w_a_print`p_3 within c1w_prt_wholesaledet_zone_v20
end type

type p_5 from w_a_print`p_5 within c1w_prt_wholesaledet_zone_v20
end type

type p_6 from w_a_print`p_6 within c1w_prt_wholesaledet_zone_v20
end type

type p_7 from w_a_print`p_7 within c1w_prt_wholesaledet_zone_v20
end type

type p_8 from w_a_print`p_8 within c1w_prt_wholesaledet_zone_v20
end type

type p_9 from w_a_print`p_9 within c1w_prt_wholesaledet_zone_v20
end type

type p_4 from w_a_print`p_4 within c1w_prt_wholesaledet_zone_v20
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_wholesaledet_zone_v20
end type

type p_port from w_a_print`p_port within c1w_prt_wholesaledet_zone_v20
end type

type p_land from w_a_print`p_land within c1w_prt_wholesaledet_zone_v20
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_wholesaledet_zone_v20
integer height = 388
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_wholesaledet_zone_v20
end type

