$PBExportHeader$b1w_reg_svc_termprc_b_v20_back.srw
$PBExportComments$[ohj] 서비스 해지 처리-선불제&후불
forward
global type b1w_reg_svc_termprc_b_v20_back from w_a_reg_m_m
end type
end forward

global type b1w_reg_svc_termprc_b_v20_back from w_a_reg_m_m
integer width = 3365
integer height = 2112
end type
global b1w_reg_svc_termprc_b_v20_back b1w_reg_svc_termprc_b_v20_back

type variables
String is_reqterm	//해지 신청 코드
String is_term	 	//해지 코드
String is_requestactive //개통 신청 상태 코드
String is_termstatus //고객 해지 상태
String is_date_check  //해지일 Check 여부

Integer ii_cnt
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_payid (string as_payid)
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

public function integer wfi_get_payid (string as_payid);String ls_payernm

Select customernm
Into :ls_payernm
From customerm
Where customerid = :as_payid;

If SQLCA.SQLCODE = 100 Then
		dw_cond.object.name[1] = ""
	Return -1
Else
	dw_cond.object.name[1] = as_payid
End If

Return 0
end function

on b1w_reg_svc_termprc_b_v20_back.create
call super::create
end on

on b1w_reg_svc_termprc_b_v20_back.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_termprc
	Desc	: 	해지처리
	Ver.	: 	1.0
	Date	:	2002.10.08
	Programer : Choi Bo Ra
-------------------------------------------------------------------------*/
String ls_partnernm, ls_status, ls_ref_desc, ls_name[]
dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())

is_requestactive = ""
is_reqterm = ""
is_term = ""
is_termstatus = ""
//수행처 Default
//Select partnernm
//Into :ls_partnernm
//From partnermst 
//Where partner = :gs_user_group
//AND act_yn = 'Y';
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title,"수행처 select")
//	Return -1
//End If

dw_cond.Object.partner[1] = gs_user_group
dw_cond.Object.partnernm[1] = gs_user_group

//해지신청 상태코드 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_reqterm = ls_name[1]
is_term	 = ls_name[2]

is_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
is_termstatus = fs_get_control("B0", "P201", ls_ref_desc)

//서비스계약/신청 :개통해지날짜 CHECK여부 ohj 05.04.26
is_date_check = fs_get_control("B0", "P210", ls_ref_desc)
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

event ue_ok;call super::ue_ok;//조회
String ls_orderdt, ls_requestdt, ls_partner, ls_payid, ls_where
Long ll_row

ls_orderdt = String(dw_cond.object.orderdt[1],'yyyymmdd')
ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_partner = Trim(dw_cond.object.partner[1])
ls_payid = Trim(dw_cond.object.payid[1])

If IsNull(ls_orderdt) Then ls_orderdt = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_payid) Then ls_payid = ""

ls_where = ""
ls_where += "svc.status = '" + is_reqterm + "' "

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

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.payid = '" + ls_payid + "' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "해지신청 내역")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
	

end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_priceplan
Long   ll_result
b1u_dbmgr2_v20 	lu_dbmgr
Integer li_rc

ls_priceplan = Trim(dw_detail.Object.contractmst_priceplan[1])

//인증Key 관리 수정 - 2004.06.02 -> 주석처리... 05.04.25 ohj
//ll_result = b1fi_validkeytype_check('서비스개통신청', ls_priceplan, ii_cnt)
//
//If ll_result < 0 Then
//	f_msg_info(9000, Title , "가격정책별 인증Key Type을 찾을 수가 없습니다.")
//	Return -1
//End If

lu_dbmgr = Create b1u_dbmgr2_v20

lu_dbmgr.is_caller = "b1w_reg_svc_termprc_b_v20%save"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_reqterm
lu_dbmgr.is_data[2] = is_term
lu_dbmgr.is_data[3] = gs_user_group
lu_dbmgr.is_data[4] = is_requestactive
lu_dbmgr.is_data[5] = is_termstatus
lu_dbmgr.is_data[6] = gs_user_id
lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[8] = is_date_check
lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.ii_data[1] = ii_cnt
lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
	Return li_rc
End If


Destroy lu_dbmgr

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
	f_msg_info(3010,This.Title,"해지처리")
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
	f_msg_info(3000,This.Title,"해지처리")
ElseIf li_rc = -2 Then
	Return LI_ERROR
	
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
String ls_partner, ls_payid
Date ld_orderdt, ld_requestdt
ld_orderdt = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_partner = Trim(dw_cond.object.partner[1])
ls_payid = Trim(dw_cond.object.payid[1])

Trigger Event ue_reset()
dw_cond.object.orderdt[1] = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt
dw_cond.object.partner[1] = ls_partner
dw_cond.object.payid[1] = ls_payid
Trigger Event ue_ok()

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_termprc_b_v20_back
integer width = 1952
integer height = 296
string dataobject = "b1dw_cnd_reg_termprc_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;//고객
This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b1w_hlp_payid"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;If dwo.name = "payid" Then
	If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.payid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.Object.name[row] = &
			 dw_cond.iu_cust_help.is_data[2]
	End If
End If
end event

event dw_cond::itemchanged;call super::itemchanged;if dwo.name = "partner" Then
	wfi_get_partner(data)
	
ElseIf dwo.name = "payid" Then
	wfi_get_payid(data)
		
End If
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_termprc_b_v20_back
integer x = 2167
integer y = 48
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_termprc_b_v20_back
integer x = 2496
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_termprc_b_v20_back
integer width = 2043
integer height = 356
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_termprc_b_v20_back
integer x = 32
integer y = 368
integer width = 3287
integer height = 532
string dataobject = "b1dw_inq_termprc_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_termprc_b_v20_back
integer y = 940
integer width = 3269
integer height = 856
string dataobject = "b1dw_reg_tremprc_a_v20"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);//조회
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

dw_detail.object.termdt[1] = relativedate(date(fdt_get_dbserver_now()),1)

dw_detail.object.enddt[1] = datetime(relativedate(relativedate(date(fdt_get_dbserver_now()),1), -1))			


dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

Return 0


end event

event dw_detail::buttonclicked;//Butonn Click
iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "상세품목조회"
iu_cust_msg.is_grp_name = "서비스 해지 처리"
iu_cust_msg.is_data[1] = Trim(String(This.object.contractmst_contractseq[row]))
		
OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)

Return 0 
end event

event dw_detail::itemchanged;call super::itemchanged;//Setting
If dwo.name = "termdt" Then
	dw_detail.object.enddt[row] =  datetime(relativedate(date(This.object.termdt[row]), -1))			
End If
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_termprc_b_v20_back
boolean visible = false
integer y = 1876
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_termprc_b_v20_back
boolean visible = false
integer y = 1876
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_termprc_b_v20_back
integer x = 59
integer y = 1880
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_termprc_b_v20_back
integer x = 375
integer y = 1880
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_termprc_b_v20_back
integer y = 908
end type

