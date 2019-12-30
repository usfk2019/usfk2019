$PBExportHeader$b1w_prt_quotaitem_list_1.srw
$PBExportComments$[chooys] 할부계약품목 리스트 Window
forward
global type b1w_prt_quotaitem_list_1 from w_a_print
end type
end forward

global type b1w_prt_quotaitem_list_1 from w_a_print
end type
global b1w_prt_quotaitem_list_1 b1w_prt_quotaitem_list_1

on b1w_prt_quotaitem_list_1.create
call super::create
end on

on b1w_prt_quotaitem_list_1.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_svccod, ls_activedtfrom, ls_activedtto


ls_customerid	= Trim(dw_cond.Object.customerid[1])
ls_svccod		= Trim(dw_cond.Object.svccod[1])
ls_activedtfrom= Trim(String(dw_cond.object.activedtfrom[1],'yyyymmdd'))
ls_activedtto	= Trim(String(dw_cond.object.activedtto[1],'yyyymmdd'))

If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_svccod) ) Then ls_svccod = ""
If( IsNull(ls_activedtfrom) ) Then ls_activedtfrom = ""
If( IsNull(ls_activedtto) ) Then ls_activedtto = ""

If ls_activedtfrom <> "" And ls_activedtto <> "" Then
	If ls_activedtfrom > ls_activedtto Then
		f_msg_usr_err(211, Title, "개통일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("activedtfrom")
		Return
   End If
End If

//Dynamic SQL
ls_where = ""

If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "q.customerid = '"+ ls_customerid +"'"
End If

If( ls_svccod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "c.svccod = '"+ ls_svccod +"'"
End If

If( ls_activedtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(c.activedt, 'YYYYMMDD') >= '"+ ls_activedtfrom +"'"
End If

If( ls_activedtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(c.activedt, 'YYYYMMDD') <= '"+ ls_activedtto +"'"
End If



dw_list.is_where	= ls_where

//Retrieve
ll_rows	= dw_list.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

//MessageBox( "ls_where",ls_where )
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_quotaitem_list_1
integer x = 46
integer y = 40
integer width = 2249
integer height = 224
string dataobject = "b1dw_cnd_prt_quotaitemlist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "customerid"
		Object.customernm[1] = ""

End Choose
end event

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

type p_ok from w_a_print`p_ok within b1w_prt_quotaitem_list_1
integer x = 2446
end type

type p_close from w_a_print`p_close within b1w_prt_quotaitem_list_1
integer x = 2743
end type

type dw_list from w_a_print`dw_list within b1w_prt_quotaitem_list_1
integer x = 23
integer y = 312
integer height = 1288
string dataobject = "b1dw_prt_quotaitemlist_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_quotaitem_list_1
end type

type p_2 from w_a_print`p_2 within b1w_prt_quotaitem_list_1
end type

type p_3 from w_a_print`p_3 within b1w_prt_quotaitem_list_1
end type

type p_5 from w_a_print`p_5 within b1w_prt_quotaitem_list_1
end type

type p_6 from w_a_print`p_6 within b1w_prt_quotaitem_list_1
end type

type p_7 from w_a_print`p_7 within b1w_prt_quotaitem_list_1
end type

type p_8 from w_a_print`p_8 within b1w_prt_quotaitem_list_1
end type

type p_9 from w_a_print`p_9 within b1w_prt_quotaitem_list_1
end type

type p_4 from w_a_print`p_4 within b1w_prt_quotaitem_list_1
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_quotaitem_list_1
end type

type p_port from w_a_print`p_port within b1w_prt_quotaitem_list_1
end type

type p_land from w_a_print`p_land within b1w_prt_quotaitem_list_1
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_quotaitem_list_1
integer width = 2277
integer height = 300
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_quotaitem_list_1
end type

