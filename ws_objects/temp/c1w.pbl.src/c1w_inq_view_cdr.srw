$PBExportHeader$c1w_inq_view_cdr.srw
$PBExportComments$[ceusee] 사업자 정산을 위한 CDR 엑셀작업
forward
global type c1w_inq_view_cdr from w_a_inq_m
end type
type p_1 from u_p_saveas within c1w_inq_view_cdr
end type
type dw_detail2 from u_d_base within c1w_inq_view_cdr
end type
end forward

global type c1w_inq_view_cdr from w_a_inq_m
event ue_saveas ( )
p_1 p_1
dw_detail2 dw_detail2
end type
global c1w_inq_view_cdr c1w_inq_view_cdr

type variables
String is_fromdt, is_todt
end variables

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail2.RowCount() <= 0 Then
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

li_return = dw_detail2.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
	
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

//저장을 못하거나 완료 하면 삭제한다.
Delete curr_tmpcdr
where emp_id = :gs_user_id
and to_char(stime, 'yyyymmddhh24') >= :is_fromdt 
and to_char(stime, 'yyyymmddhh24') <= :is_todt;

If sqlca.sqlcode < 0 Then
	f_msg_sql_err(title, "Delete curr_tmpcdr")				
	Return 
End If

commit;

p_1.TriggerEvent("ue_disable")




end event

on c1w_inq_view_cdr.create
int iCurrent
call super::create
this.p_1=create p_1
this.dw_detail2=create dw_detail2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.dw_detail2
end on

on c1w_inq_view_cdr.destroy
call super::destroy
destroy(this.p_1)
destroy(this.dw_detail2)
end on

event open;call super::open;/*------------------------------------------------------------------------	
	Name	: c1w_inq_view_cdr
	Desc  : 해당 일자의 CDr을 엑셀로 다운 받음
	Date	: 2003.08.22
	Auth	: C.BORA(ceusee)
-------------------------------------------------------------------------*/
p_1.TriggerEvent("ue_disable")
end event

event ue_ok();call super::ue_ok;String ls_carrierid, ls_view
String ls_errmsg, ls_where 
Long ll_return, ll_row
double lb_count

ll_return = -1
ls_errmsg = space(256)

ls_carrierid = Trim(dw_cond.object.carrierid[1])
is_fromdt = String(dw_cond.object.fromdt[1], 'yyyymmddhh')
is_todt = String(dw_cond.object.todt[1], 'yyyymmddhh')
ls_view = trim(dw_cond.object.view[1])

If IsNull(ls_carrierid) Then ls_carrierid = ""
If IsNull(is_fromdt) Then is_fromdt = ""
If IsNull(is_todt) Then is_todt = ""


If ls_carrierid = "" Then
	f_msg_info(200, Title,"회선사업자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("carrierid")
	Return
End If

If is_fromdt = "" Then
	f_msg_info(200, Title,"기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If is_todt = "" Then
	f_msg_info(200, Title,"기간")
	dw_cond.SetFocus()
   dw_cond.SetColumn("todt")
	Return
End If

If is_fromdt > is_todt Then
	f_msg_usr_err(221, title, "기간")
	dw_cond.SetFocus()
   dw_cond.SetColumn("fromdt")
	Return
End If

//프로시저 호출
//C1CURR_TMPCDR(string P_CARRIERID,string P_FROMDT,string P_TODT,string P_EMP_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"C1CURR_TMPCDR~""
SQLCA.C1CURR_TMPCDR(ls_carrierid, is_fromdt, is_todt, gs_user_id, ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
	Return
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	Return
ElseIf ll_return = 0 Then
	MessageBox(This.title, "Procedure Complate ~r" + &
	                       "Count: " + String(lb_count, "#,##0") + " 건" )
End If

//해당 윈도우 Retrieve
 ls_where = "emp_id ='" + gs_user_id + "' " + &
                      " and to_char(stime, 'yyyymmddhh24') >='" +  is_fromdt + "' " + &
							 " and to_char(stime, 'yyyymmddhh24') <='" + is_todt + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return
End If

p_1.TriggerEvent("ue_enable")

dw_detail.SetRedraw(False)
//상세 내역 보이게 하기
If ls_view = "Y" then
	dw_detail.DataObject = "c1dw_inq_view_cdr"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
	dw_detail.Retrieve()
Else
	dw_detail.DataObject = "c1dw_inq_view_cdr_1"
	dw_detail.SetTransObject(SQLCA)
End If
dw_detail.SetRedraw(True)



end event

type dw_cond from w_a_inq_m`dw_cond within c1w_inq_view_cdr
integer y = 64
integer width = 1829
integer height = 184
string dataobject = "c1dw_cnd_inq_view_cdr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within c1w_inq_view_cdr
integer x = 2039
integer y = 52
end type

type p_close from w_a_inq_m`p_close within c1w_inq_view_cdr
integer x = 2642
integer y = 52
end type

type gb_cond from w_a_inq_m`gb_cond within c1w_inq_view_cdr
integer width = 1925
end type

type dw_detail from w_a_inq_m`dw_detail within c1w_inq_view_cdr
integer width = 3017
integer height = 1364
string dataobject = "c1dw_inq_view_cdr_1"
boolean ib_sort_use = false
end type

type p_1 from u_p_saveas within c1w_inq_view_cdr
integer x = 2341
integer y = 52
boolean bringtotop = true
end type

type dw_detail2 from u_d_base within c1w_inq_view_cdr
boolean visible = false
integer x = 32
integer y = 320
integer width = 3003
integer height = 796
integer taborder = 11
boolean bringtotop = true
string dataobject = "c1dw_inq_view_cdr"
end type

