$PBExportHeader$b1w_reg_svc_actprc_1_v20.srw
$PBExportComments$[ohj]서비스개통처리(후불) v20
forward
global type b1w_reg_svc_actprc_1_v20 from w_a_reg_m_m
end type
end forward

global type b1w_reg_svc_actprc_1_v20 from w_a_reg_m_m
integer width = 3218
integer height = 2052
end type
global b1w_reg_svc_actprc_1_v20 b1w_reg_svc_actprc_1_v20

type variables
String is_priceplan		//Price Plan Code
String is_actstatus
Boolean ib_save
String is_date_allow_yn
end variables

on b1w_reg_svc_actprc_1_v20.create
call super::create
end on

on b1w_reg_svc_actprc_1_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actprc_cl
	Desc.	: 	서비스개통처리
	Ver.	:	1.0
	Date	: 	2002.10.03
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
Date ld_sysdate
String ls_partner, ls_partnernm

ld_sysdate = Date(fdt_get_dbserver_now())
ib_save = False									//처리 여부

Select partnernm
 Into :ls_partnernm
 From partnermst 
 Where partner = :gs_user_group
  AND act_yn = 'Y';

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title,"수행처 select")
	Return -1
End If

dw_cond.Object.partner[1] = gs_user_group
dw_cond.Object.partnernm[1] = ls_partnernm
dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate
end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_partner, ls_where, ls_orderdt, ls_requestdt, ls_temp, ls_result[], ls_result1[]
String ls_ref_desc, ls_where_1, ls_detail_where, ls_orderno, ls_where_2
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
	ls_where += "svcorder.partner = '" + ls_partner + "' "
End If

If ls_orderdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(svcorder.orderdt, 'YYYYMMDD') <= '" + ls_orderdt + "' " 
End if

If ls_requestdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "( to_char(svcorder.requestdt, 'YYYYMMDD') <='" + ls_requestdt + "' Or svcorder.requestdt is null )" 
End if

//개통요청상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P220", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result[])
End if

ls_where_1 = ""
For li_i = 1 To UpperBound(ls_result[])
	If ls_where_1 <> "" Then ls_where_1 += " And "
	ls_where_1 += "svcorder.status = '" + ls_result[li_i] + "'"
Next

//구매확인Call 서비스코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P300", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result[])
End if
For li_i = 1 To UpperBound(ls_result[])
	If ls_where_1 <> "" Then
		If li_i = 1 Then
			ls_where_1 += " And ( "
		Else
			ls_where_1 += " Or  "
		End If
	End If
	
	ls_where_1 += " svcorder.svccod <> '" + ls_result[li_i] + "' "
Next
ls_where_1 += ")"

If ls_where <> "" Then
	If ls_where_1 <> "" Then ls_where = ls_where + " And (( " + ls_where_1 + " )  "  
Else
	ls_where = ls_where_1
End if

//구매확인완료상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P229", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result1[])
End if

ls_where_2 = ""
For li_i = 1 To UpperBound(ls_result1[])
	If ls_where_2 <> "" Then ls_where_2 += " And "
	ls_where_2 += " svcorder.status = '" + ls_result1[li_i] + "' "
Next

//구매확인Call 서비스코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P300", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result1[])
End if
For li_i = 1 To UpperBound(ls_result1[])
	If ls_where_2 <> "" Then
		If li_i = 1 Then
			ls_where_2 += " And ("
		Else
			ls_where_2 += " Or "
		End If
	End If
		
	ls_where_2 += " svcorder.svccod = '" + ls_result1[li_i] + "' "
Next
ls_where_2 += ")"

If ls_where <> "" Then
	If ls_where_2 <> "" Then ls_where = ls_where + " OR ( " + ls_where_2 + " )) "
Else
	ls_where = ls_where_2
End If
	
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

Select partnernm
 Into :ls_partnernm
 From partnermst 
 Where partner = :gs_user_group;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title,"수행처 select")
	Return -1
End If

dw_cond.Object.partner[1] = gs_user_group
dw_cond.Object.partnernm[1] = ls_partnernm
dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetColumn("orderdt")

dw_cond.SetRedraw(true)

Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_activedt, ls_bil_fromdt, ls_sysdt
Boolean lb_check
Long ll_rows , ll_rc, ll_svcctl_cnt
b1u_dbmgr1_v20 lu_dbmgr
string ls_priceplan,ls_svccod

dw_detail.AcceptText()

ls_activedt = string(dw_detail.object.activedt[1],'yyyymmdd')
ls_bil_fromdt = string(dw_detail.object.bil_fromdt[1],'yyyymmdd')
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')

If IsNull(ls_activedt) Then ls_activedt = ""
If ls_activedt = "" Then
	f_msg_usr_err(200, Title, "개통일자")
	dw_detail.SetFocus()
	dw_detail.SetColumn("activedt")
	Return -2
End If

If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If ls_bil_fromdt = "" Then
	f_msg_usr_err(200, Title, "과금시작일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("bil_fromdt")
	Return -2
End If

//2005-12-23 khpark add start
ls_svccod = dw_detail.object.svcorder_svccod[1]
ls_priceplan = dw_detail.object.svcorder_priceplan[1]

//개통일 check 여부 
IF b1fi_date_allow_chk_yn_v20(this.title,ls_svccod,ls_priceplan,is_date_allow_yn) < 0 Then
	 return -1
End IF
//2005-12-23 khpark add end

////// 날짜 체크
If ls_activedt <> "" Then 
	lb_check = fb_chk_stringdate(ls_activedt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'개통일자의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("activedt")
		Return -2
	End If
// SSRT 일시적으로 막음.	
//	IF is_date_allow_yn = 'N' Then
//		If ls_activedt < ls_sysdt Then
//			f_msg_usr_err(210, Title, "'개통일자는 오늘날짜 이상이여야 합니다.")
//			dw_detail.SetFocus()
//			dw_detail.SetColumn("activedt")
//			Return -1
//		End If		
//	End IF
End if

If ls_bil_fromdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_bil_fromdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'과금시작일의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("bil_fromdt")
		Return -2
	End If
	
//	IF is_date_allow_yn = 'N' Then
		If ls_bil_fromdt < ls_activedt Then
			f_msg_usr_err(210, Title, "'과금시작일은 개통일보다 크거나 같아야 합니다.")
			dw_detail.SetFocus()
			dw_detail.SetColumn("bil_fromdt")
			Return -2
		End If		
//	End IF
End if

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

lu_dbmgr = CREATE b1u_dbmgr1_v20

lu_dbmgr.is_caller = "b1w_reg_svc_actprc_1_v20%save"
lu_dbmgr.is_title  = Title
lu_dbmgr.idw_data[1] = dw_detail

lu_dbmgr.uf_prc_db()
ll_rc = lu_dbmgr.ii_rc

If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy lu_dbmgr
	Return ll_rc
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy lu_dbmgr

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
//	f_msg_info(3010,This.Title,"서비스개통처리")
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
//	f_msg_info(3000,This.Title,"재개통처리")
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

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

//ls_contractseq = dw_detail.object.contractseq[1]
//If Isnull(ls_contractseq) or ls_contractseq = '' Then
//	p_save.TriggerEvent("ue_enable")	
//	dw_detail.object.activedt.protect = 0
//	dw_detail.object.bil_fromdt.protect = 0
//	dw_detail.object.contract_no.protect = 0
//	dw_detail.object.contractseq.protect = 0
//Else
//	p_save.TriggerEvent("ue_disable")		
//	dw_detail.object.activedt.protect = 1
//	dw_detail.object.bil_fromdt.protect = 1
//	dw_detail.object.contract_no.protect = 1
//	dw_detail.object.contractseq.protect = 1
//End if

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_actprc_1_v20
integer x = 46
integer width = 2048
integer height = 192
string dataobject = "b1dw_cnd_svc_actprc_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_actprc_1_v20
integer x = 2304
integer y = 40
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_actprc_1_v20
integer x = 2606
integer y = 40
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_actprc_1_v20
integer width = 2135
integer height = 276
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_actprc_1_v20
integer x = 23
integer y = 296
integer width = 3118
integer height = 556
string dataobject = "b1dw_reg_svc_actprc_m_cl_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::clicked;call super::clicked;//Dec ldc_ref_contractseq
//String ls_activedt, ls_bil_fromdt, ls_contractno, ls_type
//datetime ldt_activedt, ldt_bil_fromdt
//Long ll_row, ll_selected_row
//
//ll_selected_row = dw_detail.rowcount()
//
//If ll_selected_row > 0 Then
//
//	ldc_ref_contractseq = dw_detail.object.svcorder_ref_contractseq[1]
//	
//	If Isnull(ldc_ref_contractseq) Then
//		p_save.TriggerEvent("ue_enable")	
//		dw_detail.object.activedt.protect = 0
//		dw_detail.object.bil_fromdt.protect = 0
//		dw_detail.object.contract_no.protect = 0
//		dw_detail.object.contractseq.protect = 0
//		
//	Else
//		Select activedt,
//				 bil_fromdt,
//				 contractno
//		 Into :ldt_activedt,
//				:ldt_bil_fromdt,
//				:ls_contractno
//		 From contractmst
//		Where contractseq = :ldc_ref_contractseq;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title,"contractmst select")
//			Return -2
//		End If
//		
//		dw_detail.object.activedt[1] = ldt_activedt
//		dw_detail.object.bil_fromdt[1] = ldt_bil_fromdt
//		dw_detail.object.contract_no[1] = ls_contractno
//		dw_detail.object.contractseq[1] = string(ldc_ref_contractseq)
//		dw_detail.object.activedt.protect = 1
//		dw_detail.object.bil_fromdt.protect = 1
//		dw_detail.object.contract_no.protect = 1
//		dw_detail.object.contractseq.protect = 1
//		p_save.TriggerEvent("ue_disable")		
//		
//		dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
//		
//	End If
//End If
//
//dw_detail.SetRedraw(true)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_actprc_1_v20
integer x = 23
integer y = 880
integer width = 3118
integer height = 888
string dataobject = "b1dw_reg_svc_actprc_detail_v20"
boolean vscrollbar = false
end type

event dw_detail::buttonclicked;call super::buttonclicked;//Butonn Click

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "상세품목조회"
iu_cust_msg.is_grp_name = "서비스 신청내역 조회/취소"
iu_cust_msg.is_data[1] = Trim(String(This.object.svcorder_orderno[row]))
		
OpenWithParm(b1w_inq_popup_svcorderitem_v20, iu_cust_msg)

Return 0 
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_orderno
Long ll_row
dec ldc_ref_contractseq

ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])
If IsNull(ls_orderno) Then ls_orderno = ""
ls_where = ""
If ls_orderno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.orderno = " + ls_orderno + ""
End If

//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
dw_detail.SetRedraw(false)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

//If al_select_row > 0 Then
//
//	ldc_ref_contractseq = dw_detail.object.svcorder_ref_contractseq[1]
//	
//	If Isnull(ldc_ref_contractseq) Then
//		p_save.TriggerEvent("ue_enable")	
//		dw_detail.object.activedt.protect = 0
//		dw_detail.object.bil_fromdt.protect = 0
//		dw_detail.object.contract_no.protect = 0
//		dw_detail.object.contractseq.protect = 0
//	Else
//		dw_detail.object.activedt.protect = 1
//		dw_detail.object.bil_fromdt.protect = 1
//		dw_detail.object.contract_no.protect = 1
//		dw_detail.object.contractseq.protect = 1
//		p_save.TriggerEvent("ue_disable")		
//	End If
//	
//End If

// 무조건 오늘 날짜로 나오게 2007 08 20 hcjung
This.object.activedt[1] = fdt_get_dbserver_now() //This.object.svcorder_requestdt[1]
This.object.bil_fromdt[1] = fdt_get_dbserver_now() //This.object.svcorder_requestdt[1]

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

dw_detail.SetRedraw(true)

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;//Item Change Event

Choose Case dwo.name
	Case "activedt"
		 This.Object.bil_fromdt[row] = This.Object.activedt[row]
End Choose

Return 0 
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_actprc_1_v20
boolean visible = false
integer y = 1716
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_actprc_1_v20
boolean visible = false
integer y = 1716
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_actprc_1_v20
integer x = 46
integer y = 1824
string picturename = "active_e.gif"
end type

event p_save::ue_buttondown;call super::ue_buttondown;This.PictureName = "active_x.gif"
end event

event p_save::ue_buttonup;call super::ue_buttonup;This.PictureName = "active_e.gif"
end event

event p_save::ue_disable();call super::ue_disable;This.PictureName = "active_d.gif"
end event

event p_save::ue_enable();call super::ue_enable;If fb_enable_button("SAVE", gi_group_auth) Then
	This.PictureName = "active_e.gif"
	This.Enabled = TRUE
Else
	This.PictureName = "active_d.gif"
	This.Enabled = FALSE
End If
end event

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_actprc_1_v20
integer x = 347
integer y = 1824
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_actprc_1_v20
integer x = 23
integer y = 848
end type

