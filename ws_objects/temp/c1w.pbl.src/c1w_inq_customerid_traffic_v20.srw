$PBExportHeader$c1w_inq_customerid_traffic_v20.srw
$PBExportComments$[parkkh] 사업자별트래픽현황(ASR)
forward
global type c1w_inq_customerid_traffic_v20 from w_a_inq_m
end type
type p_saveas from u_p_saveas within c1w_inq_customerid_traffic_v20
end type
end forward

global type c1w_inq_customerid_traffic_v20 from w_a_inq_m
integer width = 3570
integer height = 1844
event ue_saveas ( )
p_saveas p_saveas
end type
global c1w_inq_customerid_traffic_v20 c1w_inq_customerid_traffic_v20

type variables
boolean ib_sort_use
string is_method[], is_type[]
end variables

event ue_saveas();Boolean lb_return
String ls_curdir
u_api lu_api
Long ll_rc, ll_selrow
Integer li_curtab, li_return

	
If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
	
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api
end event

on c1w_inq_customerid_traffic_v20.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on c1w_inq_customerid_traffic_v20.destroy
call super::destroy
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;String ls_customerid, ls_yyyymmdd_fr, ls_yyyymmdd_to
String ls_where
Long   ll_rows

dw_cond.AcceptText()

ls_yyyymmdd_fr  = Trim(String(dw_cond.Object.yyyymmdd_fr[1],'yyyymmdd'))
ls_yyyymmdd_to    = Trim(String(dw_cond.Object.yyyymmdd_to[1],'yyyymmdd'))
ls_customerid = Trim(dw_cond.Object.customerid[1])

If IsNull(ls_yyyymmdd_fr) Then ls_yyyymmdd_fr = ""
If IsNull(ls_yyyymmdd_to) Then ls_yyyymmdd_to = ""
If IsNull(ls_customerid) Then ls_customerid = ""

If ls_yyyymmdd_fr = "" Then
	f_msg_info(200, Title, "기간 from")
	dw_cond.SetColumn("yyyymmdd_fr")
	dw_cond.SetFocus()
	Return
End If

If ls_yyyymmdd_to = "" Then
	f_msg_info(200, Title, "기간 to")
	dw_cond.SetColumn("yyyymmdd_to")
	dw_cond.SetFocus()
	Return
End If

IF  (ls_yyyymmdd_fr > ls_yyyymmdd_to) THEN
	f_msg_info(200, Title, "기간from 은 기간to 보다 작아야 합니다.")
	dw_cond.SetColumn("yyyymmdd_fr")
	dw_cond.SetFocus()
	RETURN
END IF

//Dynamic SQL
ls_where = ""

If ls_yyyymmdd_fr <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(a.workdt,'YYYYMMDD') >= '" + ls_yyyymmdd_fr + "' "
End If

If ls_yyyymmdd_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(a.workdt,'YYYYMMDD') <= '" + ls_yyyymmdd_to + "' "
End IF

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.customerid = '" + ls_customerid + "' "
End If

dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
ElseIF ll_rows > 0 Then
End If
end event

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	c1w_inq_customerid_traffic_v20
	Desc.	:	사업자별 트래픽 현황
	Ver	: 	1.0
	Date	: 	2005.12.16
	Prgromer : Park Kyung Hae(parkkh)
---------------------------------------------------------------------------*/



end event

type dw_cond from w_a_inq_m`dw_cond within c1w_inq_customerid_traffic_v20
integer y = 72
integer width = 1390
integer height = 264
string dataobject = "c1dw_cnd_customerid_traffic_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within c1w_inq_customerid_traffic_v20
integer x = 1723
integer y = 104
end type

type p_close from w_a_inq_m`p_close within c1w_inq_customerid_traffic_v20
integer x = 2025
integer y = 104
end type

type gb_cond from w_a_inq_m`gb_cond within c1w_inq_customerid_traffic_v20
integer width = 1559
integer height = 360
end type

type dw_detail from w_a_inq_m`dw_detail within c1w_inq_customerid_traffic_v20
integer y = 392
integer width = 3479
integer height = 1268
string dataobject = "c1dw_inq_customerid_traffic_v20"
boolean ib_sort_use = false
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_SORT = Object.customerid_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_detail::constructor;call super::constructor;ib_sort_use = true
end event

event dw_detail::clicked;call super::clicked;If row = 0 then Return
If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

type p_saveas from u_p_saveas within c1w_inq_customerid_traffic_v20
integer x = 2331
integer y = 104
boolean bringtotop = true
boolean originalsize = false
end type

