$PBExportHeader$b1w_reg_svc_suspend.srw
$PBExportComments$[ceusee] 일시정지처리-후불
forward
global type b1w_reg_svc_suspend from w_a_reg_m_m
end type
end forward

global type b1w_reg_svc_suspend from w_a_reg_m_m
integer width = 3118
integer height = 2116
end type
global b1w_reg_svc_suspend b1w_reg_svc_suspend

type variables
String is_suspendreq
String is_suspend
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.partnernm[1] = ""
	Return -1
Else
	dw_cond.object.partnernm[1] = as_partner
End If

Return 0
end function

on b1w_reg_svc_suspend.create
call super::create
end on

on b1w_reg_svc_suspend.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_suspend
	Desc	: 	일시정지 처리
	Ver.	: 	1.0
	Date	:	2002.10.11
	Programer : Choi Bo Ra
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_name[], ls_status
is_suspendreq = ""
is_suspend = ""

dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.Object.partner[1] = gs_user_group
dw_cond.Object.partnernm[1] = gs_user_group


//일시정지 상태코드
ls_status = fs_get_control("B0", "P225", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_suspendreq = ls_name[1]
is_suspend = ls_name[2]
end event

event ue_ok();call super::ue_ok;//조회
String ls_orderdt, ls_requestdt, ls_partner, ls_where
Long ll_row

ls_orderdt = String(dw_cond.object.orderdt[1],'yyyymmdd')
ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_orderdt) Then ls_orderdt = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_partner) Then ls_partner = ""

ls_where = ""
ls_where += "svc.status = '" + is_suspendreq + "' "

If ls_orderdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderdt,'yyyymmdd') <='" + ls_orderdt + "' "
End If

If ls_requestdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.requestdt,'yyyymmdd') <='" + ls_requestdt + "' "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.partner = '" + ls_partner + "' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "일시정지요청 내역")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
	
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If


p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//Setting
dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.Object.partner[1] = gs_user_group
dw_cond.Object.partnernm[1] = gs_user_group

Return 0

end event

event ue_save;Constant Int LI_ERROR = -1
Integer li_rc
If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

li_rc = This.Trigger Event ue_extra_save()
If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"일시정지 처리")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"일시정지처리")
ElseIf li_rc = -2 Then
	Return LI_ERROR
	
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
String ls_partner
Date ld_orderdt, ld_requestdt
ld_orderdt = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_partner = Trim(dw_cond.object.partner[1])

Trigger Event ue_reset()
dw_cond.object.orderdt[1] = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt
dw_cond.object.partner[1] = ls_partner
Trigger Event ue_ok()


Return 0

end event

event ue_extra_save;call super::ue_extra_save;b1u_dbmgr 	lu_dbmgr
Integer li_rc
lu_dbmgr = Create b1u_dbmgr

lu_dbmgr.is_caller = "b1w_reg_svc_suspend%save"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_suspendreq
lu_dbmgr.is_data[2] = is_suspend
lu_dbmgr.is_data[3] = gs_user_group
lu_dbmgr.is_data[4] = gs_user_id
lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.uf_prc_db_03()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
	Return li_rc
End If


Destroy lu_dbmgr

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_suspend
integer width = 1934
integer height = 208
string dataobject = "b1dw_cnd_reg_suspend"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;//수행처
This.idwo_help_col[1] = This.Object.partner
This.is_help_win[1] = "b1w_hlp_partner_1"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;if dwo.name = "partner" Then
	wfi_get_partner(data)
End iF
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_suspend
integer x = 2085
integer y = 48
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_suspend
integer x = 2386
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_suspend
integer width = 1966
integer height = 288
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_suspend
integer x = 32
integer y = 308
integer height = 508
string dataobject = "b1dw_inq_suspend"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_suspend
integer y = 848
integer height = 1000
string dataobject = "b1dw_reg_svc_suspend"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!) 
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//조회
String ls_orderno, ls_where
Long ll_row

If al_select_row = 0 Then Return 0
ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])

ls_where = ""
ls_where += "to_char(svc.orderno) = '" + ls_orderno + "' "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

//setting
dw_detail.object.suspenddt[1] = fdt_get_dbserver_now()

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

Return 0

end event

event dw_detail::buttonclicked;call super::buttonclicked;//Butonn Click
iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "상세품목조회"
iu_cust_msg.is_grp_name = "서비스 일시정지 처리"
iu_cust_msg.is_data[1] = Trim(String(This.object.contractmst_contractseq[row]))
		
OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)

Return 0 
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_suspend
boolean visible = false
integer y = 1740
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_suspend
boolean visible = false
integer y = 1740
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_suspend
integer x = 46
integer y = 1884
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_suspend
integer x = 370
integer y = 1884
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_suspend
integer y = 816
end type

