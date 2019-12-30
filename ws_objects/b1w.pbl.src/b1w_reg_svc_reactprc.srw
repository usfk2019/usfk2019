$PBExportHeader$b1w_reg_svc_reactprc.srw
$PBExportComments$[parkkh] 일시정지 재개통 처리
forward
global type b1w_reg_svc_reactprc from w_a_reg_m_m
end type
end forward

global type b1w_reg_svc_reactprc from w_a_reg_m_m
integer width = 3218
integer height = 2056
end type
global b1w_reg_svc_reactprc b1w_reg_svc_reactprc

type variables
String is_priceplan		//Price Plan Code
end variables

on b1w_reg_svc_reactprc.create
call super::create
end on

on b1w_reg_svc_reactprc.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_reactprc
	Desc.	: 	일시정지 재개통 처리
	Ver.	:	1.0
	Date	: 	2002.10.11
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/
Date ld_sysdate
String ls_partner, ls_partnernm

ld_sysdate = Date(fdt_get_dbserver_now())

//Select partnernm
// Into :ls_partnernm
// From partnermst 
// Where partner = :gs_user_group
//  AND act_yn = 'Y';
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title,"수행처 select")
//	Return -1
//End If
//
dw_cond.Object.partner[1] = gs_user_group
//dw_cond.Object.partnernm[1] = ls_partnernm
dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetFocus()
dw_cond.SetColumn("orderdt")

end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_partner, ls_where, ls_orderdt, ls_requestdt, ls_temp, ls_result[]
String ls_ref_desc, ls_where_1, ls_detail_where, ls_orderno, ls_react_status
Date ld_orderdt, ld_requestdt
Long ll_row, ll_cur_row, ll_detail_row
Int li_i

ld_orderdt = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_orderdt = String(ld_orderdt, 'yyyymmdd')
ls_requestdt = String(ld_requestdt, 'yyyymmdd')
ls_partner = Trim(dw_cond.object.partner[1])

//Null Check
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_orderdt) Then ls_orderdt = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""

IF ls_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.partner = '" + ls_partner + "' "
End If

If ls_orderdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(svc.orderdt, 'YYYYMMDD') <='" + ls_orderdt + "' " 
End if

If ls_requestdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(svc.requestdt, 'YYYYMMDD') <='" + ls_requestdt + "'" 
End if

//재개통신청 상태코드
ls_ref_desc = ""
ls_react_status = fs_get_control("B0","P226", ls_ref_desc)

If ls_react_status <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "svc.status ='" + ls_react_status + "'" 
End if

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If
end event

event type integer ue_reset();call super::ue_reset;//초기화
Date ld_sysdate
String ls_partner, ls_partnernm

dw_cond.SetRedraw(false)
//dw_cond.ReSet()
//dw_cond.InsertRow(0)

ld_sysdate = Date(fdt_get_dbserver_now())

//Select partnernm
// Into :ls_partnernm
// From partnermst 
// Where partner = :gs_user_group;
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title,"수행처 select")
//	Return -1
//End If

dw_cond.Object.partner[1] = gs_user_group
//dw_cond.Object.partnernm[1] = ls_partnernm
dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetFocus()
dw_cond.SetColumn("orderdt")
dw_cond.SetRedraw(true)
Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_actdt, ls_fromdt, ls_sysdt, ls_contractseq, ls_svccod, ls_customerid, ls_orderno
Boolean lb_check
Long ll_rows , ll_rc
b1u_dbmgr2 lu_dbmgr2

dw_detail.AcceptText()

ls_actdt = string(dw_detail.object.actdt[1],'yyyymmdd')
ls_contractseq = String(dw_detail.object.contractmst_contractseq[1])
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_fromdt = String(dw_detail.object.suspendinfo_fromdt[1],'yyyymmdd')
ls_svccod = dw_detail.object.contractmst_svccod[1]
ls_customerid = dw_detail.object.contractmst_customerid[1]
ls_orderno = String(dw_detail.object.svcorder_orderno[1])

If IsNull(ls_actdt) Then ls_actdt = ""
If ls_actdt = "" Then
	f_msg_usr_err(200, Title, "재개통일자")
	dw_detail.SetFocus()
	dw_detail.SetColumn("actdt")
	Return -2
End If

//// 날짜 체크
If ls_actdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_actdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'재개통일자의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If
	
	If ls_actdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "'재개통일자는 오늘날짜 이상이여야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If		
	
	If ls_actdt <= ls_fromdt Then
		f_msg_usr_err(210, Title, "'재개통일자는 일시정지일자보다 커야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If		
End if

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_svc_reactprc%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = dw_detail
lu_dbmgr2.is_data[1] = ls_contractseq
lu_dbmgr2.is_data[2] = ls_actdt
lu_dbmgr2.is_data[3] = ls_svccod
lu_dbmgr2.is_data[4] = ls_customerid
lu_dbmgr2.is_data[5] = ls_orderno

lu_dbmgr2.uf_prc_db_03()
ll_rc = lu_dbmgr2.ii_rc

If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)		
	Destroy lu_dbmgr2
	Return ll_rc
End If

Destroy lu_dbmgr2

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
String ls_activedt, ls_bil_fromdt, ls_contractno, ls_contractseq
Long ll_row
Int li_rc

Constant Int LI_ERROR = -1

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
	f_msg_info(3010,This.Title,"재개통처리")
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
	f_msg_info(3000,This.Title,"재개통처리")
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//재정의
String ls_partner
Date ld_orderdt, ld_requestdt

ld_orderdt = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_partner = Trim(dw_cond.object.partner[1])

//Reset
Trigger Event ue_reset()
dw_cond.object.orderdt[1] = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt
dw_cond.object.partner[1] = ls_partner
Trigger Event ue_ok()

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_reactprc
integer x = 59
integer width = 2089
integer height = 200
string dataobject = "b1dw_cnd_svc_actprc"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_reactprc
integer x = 2277
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_reactprc
integer x = 2583
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_reactprc
integer width = 2153
integer height = 284
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_reactprc
integer x = 23
integer y = 296
integer width = 3118
integer height = 556
string dataobject = "b1dw_inq_svc_reactprc"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_reactprc
integer x = 23
integer y = 880
integer width = 3118
integer height = 888
string dataobject = "b1dw_reg_svc_reactprc"
boolean vscrollbar = false
end type

event dw_detail::buttonclicked;call super::buttonclicked;//Butonn Click
String ls_payid, ls_paynm, ls_termtype, ls_partner,	ls_partnernm
Dec ldc_contractseq
Datetime ldt_termdt

Choose Case dwo.Name
	Case "item_detail" //상세품목조회
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "상세품목조회"
		iu_cust_msg.is_grp_name = "서비스재개통신청"
		iu_cust_msg.is_data[1] = Trim(String(Object.contractmst_contractseq[1]))
		
		OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
		
End Choose

Return 0 
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_contractseq, ls_termtype, ls_partner, ls_partnernm, ls_orderno, ls_susseq
Long ll_row
Dec ldc_contractseq
DateTime ldt_termdt

ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])
ls_susseq = String(dw_master.object.suspendinfo_seq[al_select_row])
If IsNull(ls_orderno) Then ls_orderno = ""
If IsNull(ls_susseq) Then ls_susseq = ""

ls_where = " ( sus.todt is null OR to_char(sus.todt,'yyyymmdd') <= '19000000' )"

If ls_orderno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.orderno = " + ls_orderno + ""
End If

If ls_susseq <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "sus.seq = " + ls_susseq + ""
End If

//dw_detail 조회
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

This.object.actdt[1] = This.object.svcorder_requestdt[1]

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

dw_detail.SetRedraw(True)

Return 0
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_reactprc
boolean visible = false
integer y = 1716
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_reactprc
boolean visible = false
integer y = 1716
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_reactprc
integer x = 37
integer y = 1820
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_reactprc
integer x = 347
integer y = 1820
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_reactprc
integer x = 23
integer y = 848
end type

