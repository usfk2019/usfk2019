$PBExportHeader$b4w_prt_penaltydet_1.srw
$PBExportComments$[jykim] 위약금발생내역리스트
forward
global type b4w_prt_penaltydet_1 from w_a_print
end type
end forward

global type b4w_prt_penaltydet_1 from w_a_print
integer width = 3296
end type
global b4w_prt_penaltydet_1 b4w_prt_penaltydet_1

on b4w_prt_penaltydet_1.create
call super::create
end on

on b4w_prt_penaltydet_1.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid
String	ls_svccod, ls_termdtfrom, ls_termdtto , ls_selldtfrom ,  ls_selldtto


ls_customerid		= Trim(dw_cond.Object.customerid[1])
ls_svccod			= Trim(dw_cond.Object.svccod[1])
ls_termdtfrom		= Trim(String(dw_cond.object.termdtfrom[1],'yyyymmdd'))
ls_termdtto			= Trim(String(dw_cond.object.termdtto[1],'yyyymmdd'))
ls_termdtfrom		= Trim(String(dw_cond.object.selldtfrom[1],'yyyymmdd'))
ls_termdtto			= Trim(String(dw_cond.object.selldtto[1],'yyyymmdd'))

If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_svccod) ) Then ls_svccod = ""
If( IsNull(ls_termdtfrom) ) Then ls_termdtfrom = ""
If( IsNull(ls_termdtto) ) Then ls_termdtto = ""
If( IsNull(ls_selldtfrom) ) Then ls_selldtfrom = ""
If( IsNull(ls_selldtto) ) Then ls_selldtto = ""

//Dynamic SQL
ls_where = ""

If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "p.customerid = '"+ ls_customerid +"'"
End If

If( ls_svccod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "p.svccod = '"+ ls_svccod +"'"
End If

If( ls_termdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(p.termdt, 'YYYYMMDD') >= '"+ ls_termdtfrom +"'"
End If

If( ls_termdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(p.termdt, 'YYYYMMDD') <= '"+ ls_termdtto +"'"
End If


If( ls_selldtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(p.sale_month, 'YYYYMMDD') >= '"+ ls_selldtfrom +"'"
End If

If( ls_selldtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(p.sale_month, 'YYYYMMDD') <= '"+ ls_selldtto +"'"
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

type dw_cond from w_a_print`dw_cond within b4w_prt_penaltydet_1
integer width = 2469
integer height = 232
string dataobject = "b4dw_cnd_prt_penaltydet"
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

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "customerid"
		Object.customernm[1] = ""
		
End Choose
end event

type p_ok from w_a_print`p_ok within b4w_prt_penaltydet_1
integer x = 2642
integer y = 56
end type

type p_close from w_a_print`p_close within b4w_prt_penaltydet_1
integer x = 2944
integer y = 56
end type

type dw_list from w_a_print`dw_list within b4w_prt_penaltydet_1
integer y = 304
integer width = 3182
integer height = 1316
string dataobject = "b4dw_prt_penaltydet_1"
end type

event dw_list::retrieveend;call super::retrieveend;String ls_type, ls_desc

ls_type = fs_get_control("B5", "H200", ls_desc)

If ls_type = '0' Then
	This.object.penaltydet_penalty.Format = "#,##0"
	This.object.penaltydet_prm_baseamt.Format = "#,##0"
	This.object.penaltydet_prm_penalty.Format = "#,##0"
	This.object.sum_penalty.Format = "#,##0"
	
ElseIf ls_type = '1' Then
	This.object.penaltydet_penalty.Format = "#,##0.0"
	This.object.penaltydet_prm_baseamt.Format = "#,##0.0"
	This.object.penaltydet_prm_penalty.Format = "#,##0.0"
	This.object.sum_penalty.Format = "#,##0.0"
	
ElseIf ls_type = '2' Then
	This.object.penaltydet_penalty.Format = "#,##0.00"
	This.object.penaltydet_prm_baseamt.Format = "#,##0.00"
	This.object.penaltydet_prm_penalty.Format = "#,##0.00"
	This.object.sum_penalty.Format = "#,##0.00"

ElseIf ls_type = '3' Then
	This.object.penaltydet_penalty.Format = "#,##0.000"
	This.object.penaltydet_prm_baseamt.Format = "#,##0.000"
	This.object.penaltydet_prm_penalty.Format = "#,##0.000"
	This.object.sum_penalty.Format = "#,##0.000"
	
Else
	This.object.penaltydet_penalty.Format = "#,##0.0000"
	This.object.penaltydet_prm_baseamt.Format = "#,##0.0000"
	This.object.penaltydet_prm_penalty.Format = "#,##0.0000"
	This.object.sum_penalty.Format = "#,##0.0000"
	
End If

Return 0
end event

type p_1 from w_a_print`p_1 within b4w_prt_penaltydet_1
end type

type p_2 from w_a_print`p_2 within b4w_prt_penaltydet_1
end type

type p_3 from w_a_print`p_3 within b4w_prt_penaltydet_1
end type

type p_5 from w_a_print`p_5 within b4w_prt_penaltydet_1
end type

type p_6 from w_a_print`p_6 within b4w_prt_penaltydet_1
end type

type p_7 from w_a_print`p_7 within b4w_prt_penaltydet_1
end type

type p_8 from w_a_print`p_8 within b4w_prt_penaltydet_1
end type

type p_9 from w_a_print`p_9 within b4w_prt_penaltydet_1
end type

type p_4 from w_a_print`p_4 within b4w_prt_penaltydet_1
end type

type gb_1 from w_a_print`gb_1 within b4w_prt_penaltydet_1
end type

type p_port from w_a_print`p_port within b4w_prt_penaltydet_1
end type

type p_land from w_a_print`p_land within b4w_prt_penaltydet_1
end type

type gb_cond from w_a_print`gb_cond within b4w_prt_penaltydet_1
integer width = 2514
integer height = 288
integer taborder = 30
end type

type p_saveas from w_a_print`p_saveas within b4w_prt_penaltydet_1
end type

