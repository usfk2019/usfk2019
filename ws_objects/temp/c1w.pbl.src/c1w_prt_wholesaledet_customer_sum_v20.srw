$PBExportHeader$c1w_prt_wholesaledet_customer_sum_v20.srw
$PBExportComments$[ssong] wholesale  대역별 합산 보고서
forward
global type c1w_prt_wholesaledet_customer_sum_v20 from w_a_print
end type
end forward

global type c1w_prt_wholesaledet_customer_sum_v20 from w_a_print
end type
global c1w_prt_wholesaledet_customer_sum_v20 c1w_prt_wholesaledet_customer_sum_v20

on c1w_prt_wholesaledet_customer_sum_v20.create
call super::create
end on

on c1w_prt_wholesaledet_customer_sum_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	c1w_prt_wholesaledet_zone_sum_v20
	Desc.	: 	대역별 합산 보고서
	Ver.	:	1.0
	Date	:	2005.09.13
	Programer : Song Eun Mi
--------------------------------------------------------------------------*/

end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_inout_chk, ls_fromdt, ls_todt, ls_check
String ls_itemcod, ls_zoncod, ls_where
String ls_sql, ls_sql2, ls_sqlstmt
Long ll_rows

dw_cond.AcceptText()

ls_inout_chk = Trim(dw_cond.Object.inout_chk[1])
ls_fromdt = Trim(String(dw_cond.Object.fromdt[1],'yyyymmdd'))
ls_todt = Trim(String(dw_cond.Object.todt[1],'yyyymmdd'))
ls_check = Trim(dw_cond.Object.check[1])
ls_itemcod = Trim(dw_cond.Object.itemcod[1])
ls_zoncod = Trim(dw_cond.Object.zoncod[1])

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

If ls_check = "Y"  Then  
	ls_sql = " select  z.yyyymmdd, z.customerid, z.tmcod, z.unitsec, z.unitfee,                                     " + &
				"         sum(z.bilcnt) bilcnt, round(sum(z.biltime)/60,2) biltime, sum(z.bilamt) bilamt                       " + &
				" from    (                                                                                    " + &
				" select  a.yyyymmdd, a.customerid, b.tmcod, b.unitsec, b.unitfee, a.bilcnt, a.biltime, " + &
            "         decode(mod(a.biltime,b.unitsec),0,a.biltime/b.unitsec*b.unitfee,(trunc(a.biltime/b.unitsec)+1)*b.unitfee) bilamt  " + &                                             
				" from   wholesale_det a, zoncst2 b                                            " + &
            " where  to_char(a.workdt,'yyyymmdd') >= '" + ls_fromdt + "' and to_char(a.workdt,'yyyymmdd') <= '" + ls_todt + "'                 " + &
            " and    a.svccod = b.svccod                                                           " + &
            " and    a.priceplan = b.priceplan                                                         " + &
				" and    a.zoncod = b.zoncod " + &
				" and    a.itemcod = b.itemcod " 
			
  ls_sql2 = " ) z " + &
            " group by z.yyyymmdd, z.customerid, z.tmcod, z.unitsec, z.unitfee "
				
Else	
	ls_sql = " select  z.yyyymmdd, z.customerid, z.tmcod, z.unitsec, z.unitfee,                                     " + &
				"         sum(z.bilcnt) bilcnt,round(sum(z.biltime)/60,2) biltime, sum(z.bilamt) bilamt                       " + &
				" from    (                                                                                    " + &
				" select  a.yyyymmdd, customerid, b.tmcod, b.unitsec, b.unitfee, a.bilcnt, a.biltime, " + &
            "         decode(mod(a.biltime,b.unitsec),0,a.biltime/b.unitsec*b.unitfee,(trunc(a.biltime/b.unitsec)+1)*b.unitfee) bilamt  " + &                                             
				" from   wholesale_det a, zoncst2 b                                            " + &
            " where  to_char(a.stime,'yyyymmdd') >= '" + ls_fromdt + "' and to_char(a.stime,'yyyymmdd') <= '" + ls_todt + "'                 " + &
            " and    a.svccod = b.svccod                                                           " + &
            " and    a.priceplan = b.priceplan                                                         " + &
				" and    a.zoncod = b.zoncod " + &
				" and    a.itemcod = b.itemcod " 
			
  ls_sql2 = " ) z " + &
            " group by z.yyyymmdd, z.customerid, z.tmcod, z.unitsec, z.unitfee "
  
End if

ls_where = ""

If ls_inout_chk <> "A" Then
	 ls_where += " And "
    ls_where += " a.inout_chk = '" + ls_inout_chk + "' "
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

type dw_cond from w_a_print`dw_cond within c1w_prt_wholesaledet_customer_sum_v20
integer y = 40
integer height = 260
string dataobject = "c1dw_prt_cnd_wholesaledet_custom_sum_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_close from w_a_print`p_close within c1w_prt_wholesaledet_customer_sum_v20
end type

type dw_list from w_a_print`dw_list within c1w_prt_wholesaledet_customer_sum_v20
integer y = 320
integer height = 1292
string dataobject = "c1dw_prt_det_wholesale_customer_sum_v20"
end type

type p_1 from w_a_print`p_1 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_2 from w_a_print`p_2 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_3 from w_a_print`p_3 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_5 from w_a_print`p_5 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_6 from w_a_print`p_6 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_7 from w_a_print`p_7 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_8 from w_a_print`p_8 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_9 from w_a_print`p_9 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_4 from w_a_print`p_4 within c1w_prt_wholesaledet_customer_sum_v20
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_port from w_a_print`p_port within c1w_prt_wholesaledet_customer_sum_v20
end type

type p_land from w_a_print`p_land within c1w_prt_wholesaledet_customer_sum_v20
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_wholesaledet_customer_sum_v20
integer height = 308
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_wholesaledet_customer_sum_v20
end type

