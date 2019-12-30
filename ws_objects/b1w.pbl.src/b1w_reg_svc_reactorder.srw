$PBExportHeader$b1w_reg_svc_reactorder.srw
$PBExportComments$[parkkh] 일시정지재개통신청-후불
forward
global type b1w_reg_svc_reactorder from w_a_reg_m_m
end type
type dw_detail2 from u_d_base within b1w_reg_svc_reactorder
end type
type dw_detail3 from u_d_base within b1w_reg_svc_reactorder
end type
end forward

global type b1w_reg_svc_reactorder from w_a_reg_m_m
integer width = 3218
integer height = 1920
dw_detail2 dw_detail2
dw_detail3 dw_detail3
end type
global b1w_reg_svc_reactorder b1w_reg_svc_reactorder

type variables
String is_suspend_status[], is_react_status
end variables

forward prototypes
public subroutine of_resizepanels ()
end prototypes

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

//// Bottom Procesing
dw_detail2.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
dw_detail2.Resize(idrg_Top.Width / 2 - 200, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder + dw_detail2.Width + 40, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height / 2 + 50)

// Bottom Procesing
dw_detail3.Move(cii_WindowBorder + dw_detail2.Width + 40, idrg_Bottom.Y + idrg_Bottom.Height + 40)
dw_detail3.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height - idrg_Bottom.Height - 40)

end subroutine

on b1w_reg_svc_reactorder.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_detail3=create dw_detail3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_detail3
end on

on b1w_reg_svc_reactorder.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_detail3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_reactorder
	Desc.	: 	일시정지 재개통 신청
	Ver.	:	1.0
	Date	: 	2002.10.10
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp
long li_i

//일시정지 상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P225", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , is_suspend_status[])
End if
//재개통신청 상태코드
is_react_status = fs_get_control("B0","P226", ls_ref_desc)
end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
String ls_actdt, ls_partner, ls_fromdt, ls_sysdt, ls_contractseq
Boolean lb_check
Long ll_rows , ll_rc
b1u_dbmgr2 lu_dbmgr2

dw_detail.AcceptText()
ls_contractseq = String(dw_detail.object.contractmst_contractseq[1])
ls_actdt = string(dw_detail.object.actdt[1],'yyyymmdd')
ls_partner = Trim(dw_detail.object.partner[1])
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_fromdt = dw_detail.object.fromdt[1]

//Null Check
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_actdt) Then ls_actdt = ""
If IsNull(ls_actdt) Then ls_fromdt = ""

If ls_actdt = "" Then
	f_msg_usr_err(200, Title, "재개통 요청일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("actdt")
	Return -2
End If

////// 날짜 체크
If ls_actdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_actdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'재개통요청일의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If
	
	If ls_actdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "재개통요청일은 오늘날짜 이상이여야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If		
	
	If ls_actdt <= ls_fromdt Then
		f_msg_usr_err(210, Title, "'재개통요청일은 일시정지시작일보다 커야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If		
End if

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "수행처")
	dw_detail.SetFocus()
	dw_detail.SetColumn("partner")
	Return -2
End If

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_svc_reactorder%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = dw_detail
lu_dbmgr2.is_data[1] = ls_contractseq
lu_dbmgr2.is_data[2] = is_react_status
lu_dbmgr2.is_data[3] = ls_actdt
lu_dbmgr2.is_data[4] = ls_partner

lu_dbmgr2.uf_prc_db_03()
ll_rc = lu_dbmgr2.ii_rc

If ll_rc < 0 Then
	Destroy lu_dbmgr2
	Return ll_rc
End If

Destroy lu_dbmgr2

Return 0
end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_customerid, ls_payid, ls_contractno, ls_svccod, ls_priceplan, ls_validkey
String ls_where, ls_activedt_fr, ls_activedt_to, ls_temp, ls_result[], ls_contractseq
String ls_ref_desc, ls_where_1, ls_detail_where, ls_orderno
Date ld_activedt_fr, ld_activedt_to
Long ll_row, ll_cur_row, ll_detail_row
dec ldc_contractseq
Int li_i

ls_customerid = Trim(dw_cond.object.customerid[1])
//ls_svccod = Trim(dw_cond.object.svccod[1])
//ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

//Null Check
If IsNull(ls_customerid) Then ls_customerid = ""
//If IsNull(ls_svccod) Then ls_svccod = ""
//If IsNull(ls_priceplan) Then ls_priceplan= ""
If IsNull(ls_contractseq) Then ls_contractseq = ""
If IsNull(ls_contractno) Then ls_contractno = ""
If IsNull(ls_validkey) Then ls_validkey = ""

IF ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.customerid = '" + ls_customerid + "' "
End If

If ls_contractseq <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(con.contractseq) = '" + ls_contractseq + "' "
End If

If ls_contractno <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.contractno like '" + ls_contractno + "%' "
End If

If ls_validkey <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " con.contractseq  in (select distinct contractseq from validinfo where validkey = '" + ls_validkey+ "') "
End If

//IF ls_svccod <> "" Then 
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "con.svccod= '" + ls_svccod + "' "
//End If
//
//IF ls_priceplan <> "" Then 
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "con.priceplan= '" + ls_priceplan + "' "
//End If

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

event type integer ue_reset();call super::ue_reset;dw_detail2.Reset()
dw_detail3.Reset()
dw_cond.SetColumn("customerid")
Return 0 
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
Constant Int LI_ERROR = -1
String ls_activedt, ls_bil_fromdt
String ls_customerid, ls_contractseq, ls_contractno, ls_validkey
Long ll_row, li_chk, i
Integer li_rc

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

//li_chk =  f_msg_ques_yesno2(9000, Title, "[확인Message] 재개통 신청을 하시겠습니까?!", 1)

//If li_chk = 1 Then		//Yes

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
		f_msg_info(3010,This.Title,"재개통신청")
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
		f_msg_info(3000,This.Title,"재개통신청")
	ElseIF li_rc = -2 Then
		Return LI_ERROR
	End if
//End IF

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_contractseq = dw_cond.object.contractseq[1]
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

Trigger Event ue_reset()
dw_cond.object.customerid[1] = ls_customerid
dw_cond.object.contractseq[1] = ls_contractseq
dw_cond.object.contractno[1] = ls_contractno 
dw_cond.object.validkey[1] = ls_validkey
Trigger Event ue_ok()

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_reactorder
integer x = 46
integer y = 52
integer width = 2231
integer height = 232
string dataobject = "b1dw_cnd_reg_svc_reactorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_partner, ls_partnernm, ls_filter
String ls_customernm, ls_paynm
DataWindowChild ldc_priceplan, ldc_svcpromise
Long li_exist

Choose Case dwo.name

	Case "customerid"
		
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 SELECT customernm
		 INTO :ls_customernm
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select 고객명")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
//				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_customernm
		
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"


end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_reactorder
integer x = 2377
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_reactorder
integer x = 2688
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_reactorder
integer width = 2254
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_reactorder
integer y = 332
integer width = 3104
integer height = 496
integer taborder = 50
string dataobject = "b1dw_inq_svc_reactorder"
end type

event dw_master::clicked;call super::clicked;String ls_status, ls_todt
Long ll_row, ll_selected_row

dw_detail.SetRedraw(false)

ll_selected_row = dw_detail.rowcount()

If ll_selected_row > 0 Then

  	ls_status = dw_detail.object.contractmst_status[1]
	ls_todt = dw_detail.object.todt[1]
	
	If ls_status = is_suspend_status[2] and isNull(ls_todt) Then
  		p_save.TriggerEvent("ue_enable")	
		dw_detail.object.actdt.protect = 0
		dw_detail.object.partner.protect = 0
		dw_detail.object.act_gu.protect = 0				
   Else
		dw_detail.object.actdt.protect = 1
		dw_detail.object.partner.protect = 1
		dw_detail.object.act_gu.protect = 1				
		p_save.TriggerEvent("ue_disable")	
   End If
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

dw_detail.SetRedraw(true)
end event

event dw_master::retrieveend;call super::retrieveend;String ls_status, ls_todt
Long ll_row, ll_selected_row

dw_detail.SetRedraw(false)

ll_selected_row = dw_detail.rowcount()

If ll_selected_row > 0 Then

  	ls_status = dw_detail.object.contractmst_status[1]
	ls_todt = dw_detail.object.todt[1]
	
	If ls_status = is_suspend_status[2] and isNull(ls_todt) Then
  		p_save.TriggerEvent("ue_enable")	
		dw_detail.object.actdt.protect = 0
		dw_detail.object.partner.protect = 0
		dw_detail.object.act_gu.protect = 0
		dw_detail.object.remark.protect = 0
   Else
		dw_detail.object.actdt.protect = 1
		dw_detail.object.partner.protect = 1
		dw_detail.object.act_gu.protect = 1	
		dw_detail.object.remark.protect = 1
		p_save.TriggerEvent("ue_disable")	
   End If
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

dw_detail.SetRedraw(true)
end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_reactorder
integer x = 1486
integer y = 864
integer width = 1650
integer height = 392
integer taborder = 60
string dataobject = "b1dw_reg_svc_reactorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_detail::buttonclicked;call super::buttonclicked;////Butonn Click
//String ls_payid, ls_paynm, ls_termtype, ls_partner,	ls_partnernm
//Dec ldc_contractseq
//Datetime ldt_termdt
//
//Choose Case dwo.Name
//	Case "item_detail" //상세품목조회
//		
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "상세품목조회"
//		iu_cust_msg.is_grp_name = "서비스재개통신청"
//		iu_cust_msg.is_data[1] = Trim(String(Object.contractmst_contractseq[1]))
//		
//		OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
//		
//End Choose
//
Return 0 
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_contractseq, ls_termtype, ls_partner, ls_partnernm, ls_susseq
Long ll_row
Dec ldc_contractseq, ldc_susseq
DateTime ldt_termdt

ldc_contractseq = dw_master.object.contractmst_contractseq[al_select_row]
ldc_susseq = dw_master.object.suspendinfo_seq[al_select_row]

ls_contractseq = string(ldc_contractseq)
If IsNull(ldc_contractseq) Then ls_contractseq = ""

ls_where = ""
If ls_contractseq <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.contractseq = " + ls_contractseq + ""
End If

ls_susseq = string(ldc_susseq)
If IsNull(ldc_susseq) Then ls_susseq = ""
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

//setting
dw_detail.object.actdt[1] = fdt_get_dbserver_now()

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

If dw_detail2.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

If dw_detail3.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

dw_detail.SetRedraw(True)

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_reactorder
boolean visible = false
integer y = 1744
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_reactorder
boolean visible = false
integer y = 1744
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_reactorder
integer x = 37
integer y = 1676
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_reactorder
integer x = 338
integer y = 1676
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_reactorder
integer y = 832
end type

type dw_detail2 from u_d_base within b1w_reg_svc_reactorder
event type integer ue_retrieve ( long al_select_row )
integer x = 27
integer y = 864
integer width = 1408
integer height = 784
integer taborder = 30
boolean bringtotop = true
string dataobject = "b1dw_inq_termorder_popup"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
String ls_contractseq, ls_where
Long ll_row

This.SetRedraw(false)

If al_select_row = 0 Then Return 0
ls_contractseq = String(dw_master.object.contractmst_contractseq[al_select_row])

ll_row = dw_detail2.Retrieve(ls_contractseq)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

This.SetRedraw(True)

Return 0 
end event

type dw_detail3 from u_d_base within b1w_reg_svc_reactorder
event type integer ue_retrieve ( long al_select_row )
integer x = 1486
integer y = 1288
integer width = 1650
integer height = 360
integer taborder = 40
boolean bringtotop = true
string dataobject = "b1dw_inq_validkey"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
String ls_contractseq, ls_where
Long ll_row

This.SetRedraw(False)

If al_select_row = 0 Then Return 0
ls_contractseq = String(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " to_char(contractseq) = '" + ls_contractseq + "' "

dw_detail3.is_where = ls_where
ll_row = dw_detail3.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

This.SetRedraw(True)

If dw_detail3.rowcount() > 0 Then
	dw_detail3.visible = True
Else
	dw_detail3.visible = False
End if

Return 0
end event

