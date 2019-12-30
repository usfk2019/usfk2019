$PBExportHeader$b2w_prt_customercostcomparison.srw
$PBExportComments$[ssong] 고객별 원가대비 수익율 현황
forward
global type b2w_prt_customercostcomparison from w_a_print
end type
end forward

global type b2w_prt_customercostcomparison from w_a_print
integer width = 3159
end type
global b2w_prt_customercostcomparison b2w_prt_customercostcomparison

type variables
String is_fromdt, is_todt
end variables

on b2w_prt_customercostcomparison.create
call super::create
end on

on b2w_prt_customercostcomparison.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b2w_prt_customer_costcomparison
	Desc.	: 고객별 원가대비 수익률현황
	Ver.	: 1.0
	Date	: 2003.9.20
	Programer : Song Eun Mi(ssong)
-------------------------------------------------------------------------*/

dw_cond.object.fromdt[1] = fdt_get_dbserver_now()
dw_cond.object.todt[1]   = fdt_get_dbserver_now()
dw_cond.object.worktype[1]  = 'B'


end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;String ls_fromdt, ls_todt, ls_customerid, ls_worktype, ls_svccod, ls_priceplan, ls_where
String ls_sql, ls_sql2, ls_sql3, ls_sqlstmt
Date ld_fromdt, ld_todt
Long ll_row 

dw_cond.AcceptText()

ld_fromdt = dw_cond.object.fromdt[1]
ld_todt   = dw_cond.object.todt[1]
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_todt   = String(ld_todt, 'yyyymmdd')
ls_customerid = dw_cond.object.customerid[1]
ls_worktype  = Trim(dw_cond.object.worktype[1])
ls_svccod   = Trim(dw_cond.object.svccod[1])
ls_priceplan  = Trim(dw_cond.object.priceplan[1])

//Null Check
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_worktype) Then ls_worktype = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
		
//Retrieve
If ls_fromdt = "" Then
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_todt = "" Then
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("todt")
	Return
End If

If ls_fromdt <> "" And ls_todt <> "" Then
	If ls_fromdt > ls_todt Then
		f_msg_usr_err(210, title, "작업일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fromdt")
		Return
	End If
End If

If ls_worktype = "" Then
	f_msg_info(200, title, "작업구분")
	dw_cond.SetFocus()
	dw_cond.SetColumn("worktype")
	Return
End If

If ls_worktype = "A"  Then  
	ls_sql = " select  z.customerid, z.customernm, z.svccod, z.zoncod,                                      " + &
				"         sum(z.biltime) biltime, sum(z.bilamt) bilamt, sum(z.cost) cost                       " + &
				" from    (                                                                                    " + &
				" select  a.customerid, b.customernm, a.svccod, a.zoncod, round(sum(a.biltime)/60, 2) biltime, " + &
            "         sum(a.bilamt * (select d.exchange_value                                              " + &
				"                           from currency_exchange d                                           " + &
            "                          where to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "'           " + &
				"                            and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'" + &
            "                            and d.currency = c.currency_type ) ) bilamt                       " + &
				"      , sum(nvl(a.cost,0)) cost                                                                    " + &
            " from   post_bilcdr a, customerm b, priceplanmst c                                            " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "'                 " + &
            " and    a.customerid = b.customerid                                                           " + &
            " and    a.priceplan = c.priceplan                                                             "
			
    ls_sql2 = " group by a.customerid, b.customernm, a.svccod, a.zoncod " + &
            " Union all " + &
            " select  a.customerid, b.customernm, a.svccod, a.zoncod, round(sum(a.biltime)/60, 2) biltime, " + &
				"         sum(a.bilamt * (select d.exchange_value from currency_exchange d                     " + &
            "                          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "'          " + &
            "                            and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "                            and d.currency = c.currency_type ) ) bilamt                       " + &
				"      , sum(nvl(a.cost,0)) cost                                                                    " + &
            " from   post_bilcdrh a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
		
     ls_sql3 = " group by a.customerid, b.customernm, a.svccod, a.zoncod ) Z " + &
	            " group by z.customerid, z.customernm, z.svccod, z.zoncod     "
				
ElseIf	ls_worktype = "B"  Then 
	ls_sql =  " select  z.customerid, z.customernm, z.svccod, z.zoncod,                                     " + &
				"         sum(z.biltime) biltime, sum(z.bilamt) bilamt, sum(z.cost) cost                       " + &
				" from    (                                                                                    " + &
				" select  a.customerid, b.customernm, a.svccod, a.zoncod, round(sum(a.biltime)/60, 2) biltime, " + &
            "         sum(a.bilamt * (select d.exchange_value from currency_exchange d " + &
            "          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "' " + &
				"          and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "          and d.currency = c.currency_type ) ) bilamt, sum(nvl(a.cost,0)) cost " + &
            " from   pre_bilcdr a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
				
    ls_sql2 = " group by a.customerid, b.customernm, a.svccod, a.zoncod " + &
            " Union all " + &
            " select  a.customerid, b.customernm, a.svccod, a.zoncod, round(sum(a.biltime)/60, 2) biltime, " + &
				"         sum(a.bilamt * (select d.exchange_value from currency_exchange d " + &
            "          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "' " + &
            "          and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "          and d.currency = c.currency_type ) ) bilamt, sum(nvl(a.cost,0)) cost " + &
            " from   pre_bilcdrh a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
				
    ls_sql3 = " group by a.customerid, b.customernm, a.svccod, a.zoncod ) Z " + &
	           " group by z.customerid, z.customernm, z.svccod, z.zoncod     "
				
ElseIf ls_worktype = "C" Then
	ls_sql = " select a.carrier, b.customernm, a.svccod, a.zoncod " + &
	         "      , sum(nvl(a.biltime, 0)) as biltime " + &
				"      , sum(nvl(a.bilamt, 0))  as bilamt  " + &
				"      , sum(nvl(a.cost,0))     as cost    " + &
            "from   wholesale_det a, customerm b       " + &
            "where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " +&
            "and    a.carrier = b.customerid " + &
				" group by a.carrier, b.customernm, a.svccod, a.zoncod "

End if

ls_where = ""

If ls_customerid <> "" Then
	ls_where += " And "
	If ls_worktype = "C" Then
		ls_where += " a.carrier = '" + ls_customerid + "' "
	Else
		ls_where += " a.customerid = '" + ls_customerid + "' "
	End If
End If

If ls_svccod <> "" Then
	ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "' "
End If

If ls_worktype = "C" Then
	If ls_where <> "" Then
		ls_sqlstmt = ls_sql + ls_where
	Else
		ls_sqlstmt = ls_sql
	End If
Else
	If ls_where <> "" Then
		ls_sqlstmt = ls_sql + ls_where + ls_sql2 + ls_where + ls_sql3
	Else
		ls_sqlstmt = ls_sql + ls_sql2 + ls_sql3
	End If
End If

dw_list.SetRedraw(false)
dw_list.SetSQLSelect(ls_sqlstmt)

//If ls_worktype = "A"  Then 
//	dw_list.DataObject = "b2dw_prt_det_customer_costcomparison_2"
//ElseIf ls_worktype = "B" Then
//	dw_list.DataObject = "b2dw_prt_det_customer_costcomparison_1"
//ElseIf ls_worktype = "C" Then
//	dw_list.DataObject = "b2dw_prt_det_customer_costcomparison_3"
//End If


dw_list.SetTransObject(SQLCA)
dw_list.object.fr_to.Text = String(dw_cond.object.fromdt[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.todt[1], 'yyyy-mm-dd')
ll_row = dw_list.Retrieve()

dw_list.SetRedraw(True)

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

/*
If ls_worktype = "A"  Then  
	ls_sql = " select  a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, round(sum(a.biltime)/60, 2) biltime, " + &
            "         sum(a.bilamt * (select d.exchange_value from currency_exchange d " + &
            "          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "' " + &
				"          and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "          and d.currency = c.currency_type ) ) bilamt, nvl(a.cost,0) cost, a.priceplan " + &
            " from   post_bilcdr a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
			
    ls_sql2 = " group by a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, a.cost, a.priceplan " + &
            " Union all " + &
            " select  a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, round(sum(a.biltime)/60, 2) biltime, " + &
				"         sum(a.bilamt * (select d.exchange_value from currency_exchange d " + &
            "          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "' " + &
            "          and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "          and d.currency = c.currency_type ) ) bilamt, nvl(a.cost,0) cost, a.priceplan " + &
            " from   post_bilcdrh a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
		
     ls_sql3 = " group by a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, a.cost, a.priceplan "
				
ElseIf	ls_worktype = "B"  Then 
	ls_sql = " select  a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, round(sum(a.biltime)/60, 2) biltime, " + &
            "         sum(a.bilamt * (select d.exchange_value from currency_exchange d " + &
            "          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "' " + &
				"          and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "          and d.currency = c.currency_type ) ) bilamt, nvl(a.cost,0) cost, a.priceplan " + &
            " from   pre_bilcdr a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
				
    ls_sql2 = " group by a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, a.cost, a.priceplan " + &
            " Union all " + &
            " select  a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, round(sum(a.biltime)/60, 2) biltime, " + &
				"         sum(a.bilamt * (select d.exchange_value from currency_exchange d " + &
            "          where  to_char(d.fromdt,'yyyymmdd') <= '" + ls_fromdt + "' " + &
            "          and decode(d.todt, null, '" + ls_todt + "', to_char(d.todt, 'yyyymmdd')) >= '" + ls_todt + "'  " + &
            "          and d.currency = c.currency_type ) ) bilamt, nvl(a.cost,0) cost, a.priceplan " + &
            " from   pre_bilcdrh a, customerm b, priceplanmst c " + &
            " where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " + &
            " and    a.customerid = b.customerid " + &
            " and    a.priceplan = c.priceplan "
				
    ls_sql3 = " group by a.customerid, b.customernm, a.svccod, a.zoncod, c.currency_type, a.cost, a.priceplan "
				
ElseIf ls_worktype = "C" Then
	ls_sql = "select a.carrier, b.customernm, a.svccod, a.priceplan, a.itemcod, a.biltime, nvl(a.cost,0) cost, a.zoncod, a.bilamt " + &
            "from   wholesale_det a, customerm b " + &
            "where  a.yyyymmdd >= '" + ls_fromdt + "' and a.yyyymmdd <= '" + ls_todt + "' " +&
            "and    a.carrier = b.customerid "
				
End if
*/
end event

event ue_reset();call super::ue_reset;dw_cond.object.fromdt[1] = fdt_get_dbserver_now()
dw_cond.object.todt[1]   = fdt_get_dbserver_now()
dw_cond.Object.worktype[1] = 'B'
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_customercostcomparison
integer y = 60
integer width = 2414
integer height = 260
string dataobject = "b2dw_prt_cnd_customer_costcomparison"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name
	Case "customerid"
		
		If data <> "" then 
			SELECT CUSTOMERNM
			  INTO :ls_customernm
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :data ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, title, 'select error')
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, title, 'select not found')
			Else
				This.object.customernm[1] = ls_customernm
			End If
		Else
			This.object.customernm[1] = ""
			
		End If		 
		 
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_print`p_ok within b2w_prt_customercostcomparison
integer x = 2510
end type

type p_close from w_a_print`p_close within b2w_prt_customercostcomparison
integer x = 2811
end type

type dw_list from w_a_print`dw_list within b2w_prt_customercostcomparison
integer width = 3054
string dataobject = "b2dw_prt_det_customer_costcomparison_1"
end type

type p_1 from w_a_print`p_1 within b2w_prt_customercostcomparison
end type

type p_2 from w_a_print`p_2 within b2w_prt_customercostcomparison
end type

type p_3 from w_a_print`p_3 within b2w_prt_customercostcomparison
end type

type p_5 from w_a_print`p_5 within b2w_prt_customercostcomparison
end type

type p_6 from w_a_print`p_6 within b2w_prt_customercostcomparison
end type

type p_7 from w_a_print`p_7 within b2w_prt_customercostcomparison
end type

type p_8 from w_a_print`p_8 within b2w_prt_customercostcomparison
end type

type p_9 from w_a_print`p_9 within b2w_prt_customercostcomparison
end type

type p_4 from w_a_print`p_4 within b2w_prt_customercostcomparison
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_customercostcomparison
end type

type p_port from w_a_print`p_port within b2w_prt_customercostcomparison
end type

type p_land from w_a_print`p_land within b2w_prt_customercostcomparison
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_customercostcomparison
integer width = 2455
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_customercostcomparison
end type

