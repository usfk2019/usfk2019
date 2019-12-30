$PBExportHeader$b1w_reg_svc_suspendorder.srw
$PBExportComments$[ceusee] 일시정지신청-후불
forward
global type b1w_reg_svc_suspendorder from w_a_reg_m_m
end type
type dw_detail2 from u_d_base within b1w_reg_svc_suspendorder
end type
type dw_detail3 from u_d_base within b1w_reg_svc_suspendorder
end type
end forward

global type b1w_reg_svc_suspendorder from w_a_reg_m_m
integer width = 3186
integer height = 2024
dw_detail2 dw_detail2
dw_detail3 dw_detail3
end type
global b1w_reg_svc_suspendorder b1w_reg_svc_suspendorder

type variables
String is_active
String is_suspendreq, is_suspend
String is_reqactive
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
public function integer wfi_get_partner (string as_partner)
public subroutine of_resizepanels ()
end prototypes

public function integer wfi_get_customerid (string as_customerid);String ls_customernm

Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.name[1] = ""
	Return -1
	
Else
	dw_cond.object.name[1] = as_customerid
End If

Return 0
end function

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
Else
	dw_detail.object.partnernm[1] = as_partner
End If

Return 0
end function

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

on b1w_reg_svc_suspendorder.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_detail3=create dw_detail3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_detail3
end on

on b1w_reg_svc_suspendorder.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_detail3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_suspendorder
	Desc	: 	일시정지 신청
	Ver.	: 	1.0
	Date	:	2002.10.11
	Programer : Choi Bo Ra
	
  -> ModiFy  :  2003.04.02 Park Kyung Hae
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_name[], ls_status
is_active = ""
is_suspendreq = ""

//개통 상태 코드
ls_ref_desc =""
is_active = fs_get_control("B0", "P223", ls_ref_desc)

//일시정지신청 상태코드
ls_status = fs_get_control("B0", "P225", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_suspendreq = ls_name[1]
//일시정지
is_suspend = ls_name[2]

//재개통 신청 상태코드
is_reqactive = fs_get_control("B0", "P226", ls_ref_desc)
end event

event ue_ok();call super::ue_ok;//조회.
String ls_customerid, ls_contractseq, ls_svccod, ls_priceplan, ls_contractno
String ls_where, ls_validkey
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
//ls_svccod = Trim(dw_cond.object.svccod[1])
//ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_contractseq) Then ls_contractseq = ""
//If IsNull(ls_svccod) Then ls_svccod = ""
//If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_contractno) Then ls_contractno = ""
If IsNull(ls_validkey) Then ls_validkey = ""

ls_where = ""
ls_where += "cnt.status = '" + is_active + "' "

If ls_customerid <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.customerid = '" + ls_customerid + "' "
End If

If ls_contractseq <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(cnt.contractseq) = '" + ls_contractseq + "' "
End If

If ls_contractno <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cnt.contractno like '" + ls_contractno + "%' "
End If

If ls_validkey <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " cnt.contractseq  in (select distinct contractseq from validinfo where validkey = '" + ls_validkey+ "') "
End If

//If ls_svccod <>  "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "cnt.svccod = '" + ls_svccod + "' "
//End If
//
//If ls_priceplan <>  "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "cnt.priceplan = '" + ls_priceplan + "' "
//End If

dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "일시정지할 고객 내역")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If




end event

event type integer ue_extra_save();call super::ue_extra_save;b1u_dbmgr 	lu_dbmgr
Integer li_rc
lu_dbmgr = Create b1u_dbmgr

lu_dbmgr.is_caller = "b1w_reg_svc_suspendorder%save"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_suspendreq			  //일시정지신청code
lu_dbmgr.is_data[2] = is_reqactive
lu_dbmgr.is_data[3] = gs_user_group
lu_dbmgr.is_data[4] = gs_user_id
lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[6] = is_suspend              //일시정지code
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
	Return li_rc
End If


Destroy lu_dbmgr

Return 0

end event

event type integer ue_save();//조회.
String ls_customerid, ls_contractseq, ls_contractno, ls_validkey

Constant Int LI_ERROR = -1
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
	f_msg_info(3010,This.Title,"일시정지 신청")
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
	f_msg_info(3000,This.Title,"일시정지 신청")
ElseIf li_rc = -2 Then
	Return LI_ERROR
	
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
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

event type integer ue_reset();call super::ue_reset;dw_detail2.Reset()
dw_detail3.Reset()

return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_suspendorder
integer x = 46
integer y = 52
integer width = 2203
string dataobject = "b1dw_cnd_reg_svc_suspendorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;//고객
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"


end event

event dw_cond::doubleclicked;call super::doubleclicked;If dwo.name = "customerid" Then
	If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.Object.name[row] = &
			 dw_cond.iu_cust_help.is_data[1]
	End If
End if
end event

event dw_cond::itemchanged;if dwo.name = "customerid" Then
	wfi_get_customerid(data)
		
End If
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_suspendorder
integer x = 2382
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_suspendorder
integer x = 2688
integer y = 52
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_suspendorder
integer width = 2231
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_suspendorder
integer x = 27
integer y = 328
integer width = 3081
integer height = 648
string dataobject = "b1dw_inq_svc_suspendorder"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::clicked;call super::clicked;Long ll_selected_row,ll_old_selected_row
Int li_rc

ll_old_selected_row = This.GetSelectedRow(0)

//Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_selected_row > 0 Then
	Else
		dw_detail2.Reset()
		dw_detail3.Reset()		
	End If
End If

end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_suspendorder
integer x = 1449
integer y = 1008
integer width = 1659
integer height = 448
string dataobject = "b1w_reg_svc_suspendorder"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event type integer dw_detail::ue_retrieve(long al_select_row);//조회
String ls_contractseq, ls_where
Long ll_row

This.setredraw(false)

If al_select_row = 0 Then Return 0
ls_contractseq = String(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " to_char(cnt.contractseq) = '" + ls_contractseq + "' "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

//setting
dw_detail.object.partner[1] = Trim(dw_master.object.contractmst_partner[al_select_row])
dw_detail.object.partnernm[1] = Trim(dw_master.object.contractmst_partner[al_select_row])
dw_detail.object.reqdt[1] = fdt_get_dbserver_now()

dw_detail.SetItemStatus(1, 0 , Primary!,NotModified!)

If dw_detail2.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

If dw_detail3.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

This.setredraw(True)

Return 0

end event

event dw_detail::doubleclicked;call super::doubleclicked;//If dwo.name = "partner" Then
//	If dw_detail.iu_cust_help.ib_data[1] Then
//			 dw_detail.Object.partner[row] = &
//			 dw_detail.iu_cust_help.is_data[1]
//			 dw_detail.Object.partnernm[row] = &
//			 dw_detail.iu_cust_help.is_data[1]
//	End If
//End If
end event

event dw_detail::itemchanged;call super::itemchanged;//if dwo.name = "partner" Then
//	If wfi_get_customerid(data) = -1 Then
//		dw_detail.object.partnernm[row] = ""
//	End If
//End If
end event

event dw_detail::buttonclicked;call super::buttonclicked;////Butonn Click
//iu_cust_msg = Create u_cust_a_msg
//iu_cust_msg.is_pgm_name = "상세품목조회"
//iu_cust_msg.is_grp_name = "서비스 일시정지 신청"
//iu_cust_msg.is_data[1] = Trim(String(This.object.contractmst_contractseq[row]))
//		
//OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
//
//Return 0 
end event

event dw_detail::ue_init();call super::ue_init;//수행처
//dw_detail.idwo_help_col[1] = This.Object.partner
//dw_detail.is_help_win[1] = "b1w_hlp_partner_1"
//dw_detail.is_data[1] = "CloseWithReturn"
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_suspendorder
boolean visible = false
integer y = 1816
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_suspendorder
boolean visible = false
integer y = 1816
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_suspendorder
integer x = 59
integer y = 1764
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_suspendorder
integer x = 361
integer y = 1764
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_suspendorder
integer y = 976
end type

type dw_detail2 from u_d_base within b1w_reg_svc_suspendorder
event type integer ue_retrieve ( long al_select_row )
integer x = 23
integer y = 1008
integer width = 1390
integer height = 732
integer taborder = 11
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

type dw_detail3 from u_d_base within b1w_reg_svc_suspendorder
event type integer ue_retrieve ( long al_select_row )
integer x = 1449
integer y = 1472
integer width = 1659
integer height = 268
integer taborder = 11
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

