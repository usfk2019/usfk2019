$PBExportHeader$b1w_inq_reqtelmst.srw
$PBExportComments$[parkkh] KT 고객정보 조회
forward
global type b1w_inq_reqtelmst from w_a_inq_m
end type
end forward

global type b1w_inq_reqtelmst from w_a_inq_m
integer width = 3118
integer height = 1908
end type
global b1w_inq_reqtelmst b1w_inq_reqtelmst

type variables
String is_coid
end variables

on b1w_inq_reqtelmst.create
call super::create
end on

on b1w_inq_reqtelmst.destroy
call super::destroy
end on

event open;call super::open;/*--------------------------------------------------------------------
	Name	:	b1w_inq_reqtelmst
	Desc	:	KT고객정보List
	Ver.	: 	1.0
	Date	: 	2004.03.05
	Programer : parkkh(박경해)
--------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_telno
String	ls_reqdt, ls_acceptdt, ls_status
String	ls_requestdtfrom, ls_requestdtto, ls_crt_type
String	ls_priceplan, ls_prmtype
String	ls_partner, ls_settle_partner
String	ls_maintain_partner, ls_reg_partner
String	ls_sale_partner, ls_validkey

ls_telno			= Trim(dw_cond.Object.telno[1])
ls_reqdt		= Trim(String(dw_cond.object.reqdt[1],'yyyymmdd'))
ls_acceptdt		= Trim(String(dw_cond.object.acceptdt[1],'yyyymmdd'))
ls_status			= Trim(dw_cond.Object.status[1])
ls_crt_type			= Trim(dw_cond.Object.crt_type[1])
ls_customerid		= Trim(dw_cond.Object.customerid[1])

If( IsNull(ls_telno) ) Then ls_telno = ""
If( IsNull(ls_reqdt) ) Then ls_reqdt = ""
If( IsNull(ls_acceptdt) ) Then ls_acceptdt = ""
If( IsNull(ls_status) ) Then ls_status = ""
If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_crt_type) ) Then ls_crt_type = ""

//Dynamic SQL
ls_where = ""
If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= " customerid = '"+ ls_customerid +"'"
End If

If( ls_telno <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += " telno like '"+ ls_telno +"%'"
End If

If( ls_reqdt <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(reqdt, 'YYYYMMDD') = '"+ ls_reqdt +"'"
End If

If( ls_acceptdt <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(acceptdt, 'YYYYMMDD') = '"+ ls_acceptdt +"'"
End If

If( ls_status <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += " status = '"+ ls_status +"'"
End If

If( ls_crt_type <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += " crt_type = '"+ ls_crt_type +"'"
End If


dw_detail.is_where	= ls_where

//Retrieve
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If
end event

type dw_cond from w_a_inq_m`dw_cond within b1w_inq_reqtelmst
integer y = 44
integer width = 2208
integer height = 396
string dataobject = "b1dw_cnd_inqreqtelmst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within b1w_inq_reqtelmst
integer x = 2382
integer y = 68
end type

type p_close from w_a_inq_m`p_close within b1w_inq_reqtelmst
integer x = 2702
integer y = 68
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_inq_reqtelmst
integer width = 2281
integer height = 492
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_inq_reqtelmst
integer x = 32
integer y = 516
integer height = 1284
string dataobject = "b1dw_inq_reqtelmst"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.telno_t
uf_init(ldwo_SORT)
end event

