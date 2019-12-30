$PBExportHeader$ssrt2_inq_mwr_report.srw
$PBExportComments$[hcjung] MWR 리포트 조회
forward
global type ssrt2_inq_mwr_report from w_a_inq_m
end type
type p_2 from u_p_saveas within ssrt2_inq_mwr_report
end type
end forward

global type ssrt2_inq_mwr_report from w_a_inq_m
event ue_saves ( )
event ue_saveas ( )
p_2 p_2
end type
global ssrt2_inq_mwr_report ssrt2_inq_mwr_report

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

on ssrt2_inq_mwr_report.create
int iCurrent
call super::create
this.p_2=create p_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_2
end on

on ssrt2_inq_mwr_report.destroy
call super::destroy
destroy(this.p_2)
end on

event ue_ok();call super::ue_ok;//조회
String ls_svctype, ls_workdt_fr, ls_basecod, ls_where, ls_status, ls_fromdate, ls_todate
Long ll_row

//필수입력사항 check
ls_svctype = Trim(dw_cond.object.service[1])
ls_workdt_fr = String(dw_cond.Object.fromdate[1], "yyyymm")
ls_basecod = Trim(dw_cond.object.basecod[1])
ls_status = Trim(dw_cond.object.status[1])

select to_char(add_months(to_date(:ls_workdt_fr || '01','yyyymmdd'),-1),'yyyymmdd') into :ls_fromdate from dual;
ls_fromdate = MidA(ls_fromdate,1,4) + "-" +  MidA(ls_fromdate, 5,2)+ "-" +  MidA(ls_fromdate, 7,2) 

select to_char(to_date(:ls_workdt_fr || '01','yyyymmdd') - 1, 'yyyymmdd') into :ls_todate from dual;
ls_todate = MidA(ls_todate,1,4) + "-" +  MidA(ls_todate, 5,2)+ "-" +  MidA(ls_todate, 7,2) 

If Isnull(ls_svctype) OR ls_svctype = '5' Then ls_svctype = ""				
If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
If Isnull(ls_basecod) Then ls_basecod = ""
If Isnull(ls_status) Then ls_status = ""

If ls_workdt_fr = "" Then
	f_msg_info(200, Title, "Date")
	dw_cond.setfocus()
	dw_cond.SetColumn("fromdate")
	Return
End If

dw_detail.reset()

ls_where = ""

IF ls_basecod <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
    ls_where += "BASEMST.BASECOD = '" + ls_basecod + "' "
END IF

IF ls_svctype <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
    ls_where += "MWR_REPORT_LIST.G_SVCCOD = '" + ls_svctype + "' "
END IF

IF ls_workdt_fr <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "MWR_REPORT_LIST.YYYYMM = '" + ls_workdt_fr + "' "
END IF
	
IF ls_status <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "MWR_REPORT_LIST.STATUS = '" + ls_status + "' "
END IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ELSEIF ll_row > 0 THEN
	dw_detail.object.fromdate.text = ls_fromdate
	dw_detail.object.todate.text = ls_todate
End If
end event

type dw_cond from w_a_inq_m`dw_cond within ssrt2_inq_mwr_report
integer y = 64
integer width = 1970
integer height = 204
string dataobject = "ssrt2_cnd_inq_mwr_report"
end type

type p_ok from w_a_inq_m`p_ok within ssrt2_inq_mwr_report
integer x = 2391
integer y = 60
end type

type p_close from w_a_inq_m`p_close within ssrt2_inq_mwr_report
integer x = 2693
integer y = 60
end type

type gb_cond from w_a_inq_m`gb_cond within ssrt2_inq_mwr_report
integer width = 2025
end type

type dw_detail from w_a_inq_m`dw_detail within ssrt2_inq_mwr_report
string dataobject = "ssrt2_inq_mwr_report"
end type

type p_2 from u_p_saveas within ssrt2_inq_mwr_report
integer x = 2391
integer y = 192
boolean bringtotop = true
end type

