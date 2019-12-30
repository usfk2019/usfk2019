$PBExportHeader$b5w_inq_cardtext_v20.srw
$PBExportComments$[ssong] 신용카드 승인/결재 정보조회
forward
global type b5w_inq_cardtext_v20 from w_a_inq_m
end type
type p_1 from u_p_reset within b5w_inq_cardtext_v20
end type
type p_saveas from u_p_saveas within b5w_inq_cardtext_v20
end type
end forward

global type b5w_inq_cardtext_v20 from w_a_inq_m
integer width = 4247
integer height = 1916
event ue_reset ( )
event ue_saveas ( )
event ue_saveas_init ( )
p_1 p_1
p_saveas p_saveas
end type
global b5w_inq_cardtext_v20 b5w_inq_cardtext_v20

type variables
String is_format
Integer ii_cnt
end variables

event ue_reset;dw_cond.reset()
dw_cond.insertrow(1)


dw_detail.reset()



//of_ResizeBars()
//of_ResizePanels()

end event

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

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

//저장을 못하거나 완료 하면 삭제한다.
//Delete curr_tmpcdr
//where emp_id = :gs_user_id
//and to_char(stime, 'yyyymmddhh24') >= :is_fromdt 
//and to_char(stime, 'yyyymmddhh24') <= :is_todt;
//
//If sqlca.sqlcode < 0 Then
//	f_msg_sql_err(title, "Delete curr_tmpcdr")				
//	Return 
//End If
//
//commit;
//

//p_1.TriggerEvent("ue_disable")




end event

on b5w_inq_cardtext_v20.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_saveas
end on

on b5w_inq_cardtext_v20.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;String ls_status, ls_bil_status, ls_svckind, ls_payerkey, ls_card_no
String ls_approvaldt_fr, ls_approvaldt_to, ls_inv_senddt_fr, ls_inv_senddt_to, ls_inv_resultdt_fr, ls_inv_resultdt_to
String ls_workno
String ls_card_type, ls_memberid, ls_where
Long   ll_rows

ls_status = Trim(dw_cond.Object.status[1])
ls_bil_status = Trim(dw_cond.Object.bil_status[1])
ls_svckind = Trim(dw_cond.Object.svckind[1])
ls_payerkey = Trim(dw_cond.Object.payerkey[1])
ls_card_no = Trim(dw_cond.Object.card_no[1])
ls_approvaldt_fr = Trim(String(dw_cond.Object.approvaldt_fr[1],'yyyymmdd'))
ls_approvaldt_to = Trim(String(dw_cond.Object.approvaldt_to[1],'yyyymmdd'))
ls_inv_senddt_fr = Trim(String(dw_cond.Object.inv_senddt_fr[1],'yyyymmdd'))
ls_inv_senddt_to = Trim(String(dw_cond.Object.inv_senddt_to[1],'yyyymmdd'))
ls_inv_resultdt_fr = Trim(String(dw_cond.Object.inv_resultdt_fr[1],'yyyymmdd'))
ls_inv_resultdt_to = Trim(String(dw_cond.Object.inv_resultdt_to[1],'yyyymmdd'))
ls_workno = Trim(String(dw_cond.Object.workno[1]))
ls_card_type = Trim(dw_cond.Object.card_type[1])
ls_memberid = Trim(dw_cond.Object.memberid[1])

If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_bil_status) Then ls_bil_status = ""
If IsNull(ls_svckind) Then ls_svckind = ""
If IsNull(ls_payerkey) Then ls_payerkey = ""
If IsNull(ls_card_no) Then ls_card_no = ""
If IsNull(ls_approvaldt_fr) Then ls_approvaldt_fr = ""
If IsNull(ls_approvaldt_to) Then ls_approvaldt_to = ""
If IsNull(ls_inv_senddt_fr) Then ls_inv_senddt_fr = ""
If IsNull(ls_inv_senddt_to) Then ls_inv_senddt_to = ""
If IsNull(ls_inv_resultdt_fr) Then ls_inv_resultdt_fr = ""
If IsNull(ls_inv_resultdt_to) Then ls_inv_resultdt_to = ""
If IsNull(ls_workno) Then ls_workno = ""
If IsNull(ls_card_type) Then ls_card_type = ""
If IsNull(ls_memberid) Then ls_memberid = ""

If ls_approvaldt_fr = "" AND ls_approvaldt_to <> "" Then
			f_msg_usr_err(210, Title, "승인일자의 기간설정이 잘못되었습니다.")
			dw_cond.SetFocus()
			dw_cond.setColumn("approvaldt_fr")
			Return 
End If

If ls_approvaldt_fr <> "" AND ls_approvaldt_to <> "" Then
	If ls_approvaldt_fr > ls_approvaldt_to Then
			f_msg_usr_err(210, Title, "승인일자의 기간설정이 잘못되었습니다.")
			dw_cond.SetFocus()
			dw_cond.setColumn("approvaldt_fr")
			Return 
	End If
End If



If ls_status = "" AND ls_bil_status = "" AND ls_svckind = "A" AND ls_payerkey = "" AND ls_card_no = "" AND ls_approvaldt_fr = "" AND ls_approvaldt_to = "" AND ls_inv_senddt_fr = "" AND ls_inv_senddt_to = "" AND ls_inv_resultdt_fr = "" AND ls_inv_resultdt_to = "" AND ls_workno = "" AND ls_card_type = "" AND ls_memberid = "" Then
	f_msg_info(200, Title, "한가지 이상의 조건을 선택하십시오")
	dw_cond.SetFocus()
	dw_cond.setColumn("status")
	Return 
End If

ls_where = ""

If ls_status <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "status = '" + ls_status + "' "
	End If
	
If ls_bil_status <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "bil_status = '" + ls_bil_status + "' "
	End If
	
If ls_svckind <> "A" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "svckind = '" + ls_svckind + "' "
	End If
	
If ls_payerkey <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "payerkey = '" + ls_payerkey + "' "
	End If
	
If ls_card_no <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "card_no = '" + ls_card_no + "' "
	End If
	
If ls_approvaldt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(approvaldt,'YYYYMMDD') > = '" + ls_approvaldt_fr + "' "
	End If
	
If ls_approvaldt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(approvaldt,'YYYYMMDD') < = '" + ls_approvaldt_to + "' "
	End If
	
If ls_inv_senddt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(inv_senddt,'YYYYMMDD') > = '" + ls_inv_senddt_fr + "' "
	End If
	
If ls_inv_senddt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(inv_senddt,'YYYYMMDD') < = '" + ls_inv_senddt_to + "' "
	End If
	
If ls_inv_resultdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(inv_resultdt,'YYYYMMDD') > = '" + ls_inv_resultdt_fr + "' "
	End If
	
If ls_inv_resultdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(inv_resultdt,'YYYYMMDD') < = '" + ls_inv_resultdt_to + "' "
	End If
	
If ls_workno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "to_char(workno) = '" + ls_workno + "' "
	End If
	
If ls_card_type <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "card_type = '" + ls_card_type + "' "
	End If
	
If ls_memberid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	   ls_where += "memberid = '" + ls_memberid + "' "
	End If
	
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()

If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

type dw_cond from w_a_inq_m`dw_cond within b5w_inq_cardtext_v20
integer x = 55
integer y = 44
integer width = 3205
integer height = 432
string dataobject = "b5dw_inq_cnd_cardtext_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m`p_ok within b5w_inq_cardtext_v20
integer x = 3301
integer y = 60
end type

type p_close from w_a_inq_m`p_close within b5w_inq_cardtext_v20
integer x = 3886
integer y = 60
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_inq_cardtext_v20
integer x = 27
integer width = 3250
integer height = 488
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_inq_cardtext_v20
integer y = 508
integer width = 4146
integer height = 1264
string dataobject = "b5dw_inq_det_cardtext_v20"
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.approvaldt_t
//uf_init(ldwo_SORT)
uf_init(ldwo_sort,'D', RGB(0,0,128))
end event

type p_1 from u_p_reset within b5w_inq_cardtext_v20
integer x = 3593
integer y = 60
boolean bringtotop = true
boolean originalsize = false
end type

type p_saveas from u_p_saveas within b5w_inq_cardtext_v20
integer x = 3593
integer y = 196
boolean bringtotop = true
end type

