$PBExportHeader$b1w_inq_svcorder.srw
$PBExportComments$[chooys] 서비스 신청내역 조회/취소 Window
forward
global type b1w_inq_svcorder from w_a_inq_m_m
end type
type p_1 from u_p_reset within b1w_inq_svcorder
end type
type st_horizontal2 from st_horizontal within b1w_inq_svcorder
end type
end forward

global type b1w_inq_svcorder from w_a_inq_m_m
integer width = 4009
integer height = 1916
event ue_reset ( )
p_1 p_1
st_horizontal2 st_horizontal2
end type
global b1w_inq_svcorder b1w_inq_svcorder

type variables
String is_partner, is_status_1, is_status_2, is_action
String is_termcodes[], is_cancelcodes[], is_actorder
Integer ii_termcodcnt, ii_cancelcnt
end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
end prototypes

event ue_reset();dw_cond.reset()
dw_cond.insertrow(1)

dw_master.reset()
dw_detail.reset()

dw_detail.Enabled = False
dw_detail.visible = False

of_ResizeBars()
of_ResizePanels()

end event

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

st_horizontal.Y = WorkSpaceHeight() - cii_BarThickness - (WorkSpaceHeight() * 0.25)

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

st_horizontal2.Move(idrg_Top.X, st_horizontal2.Y)
st_horizontal2.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()
end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness)

// Top processing
If dw_detail.rowcount() > 0 Then
	idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
	idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y - cii_BarThickness)
Else
	idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
	idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y + idrg_Bottom.Height )
End If




end subroutine

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_orderno
String	ls_orderdtfrom, ls_orderdtto, ls_status
String	ls_requestdtfrom, ls_requestdtto, ls_svccod
String	ls_priceplan, ls_prmtype
String	ls_partner, ls_settle_partner
String	ls_maintain_partner, ls_reg_partner
String	ls_sale_partner, ls_validkey

ls_customerid		= Trim(dw_cond.Object.customerid[1])
ls_orderno			= Trim(dw_cond.Object.orderno[1])
ls_orderdtfrom		= Trim(String(dw_cond.object.orderdtfrom[1],'yyyymmdd'))
ls_orderdtto		= Trim(String(dw_cond.object.orderdtto[1],'yyyymmdd'))
ls_status			= Trim(dw_cond.Object.status[1])
ls_requestdtfrom	= Trim(String(dw_cond.object.requestdtfrom[1],'yyyymmdd'))
ls_requestdtto		= Trim(String(dw_cond.object.requestdtto[1],'yyyymmdd'))
ls_svccod			= Trim(dw_cond.Object.svccod[1])
ls_priceplan		= Trim(dw_cond.Object.priceplan[1])
ls_prmtype			= Trim(dw_cond.Object.prmtype[1])
ls_partner			= Trim(dw_cond.Object.partner[1])
ls_settle_partner	= Trim(dw_cond.Object.settle_partner[1])
ls_maintain_partner	= Trim(dw_cond.Object.maintain_partner[1])
ls_reg_partner		= Trim(dw_cond.Object.reg_partner[1])
ls_sale_partner	= Trim(dw_cond.Object.sale_partner[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_orderno) ) Then ls_orderno = ""
If( IsNull(ls_orderdtfrom) ) Then ls_orderdtfrom = ""
If( IsNull(ls_orderdtto) ) Then ls_orderdtto = ""
If( IsNull(ls_status) ) Then ls_status = ""
If( IsNull(ls_requestdtfrom) ) Then ls_requestdtfrom = ""
If( IsNull(ls_requestdtto) ) Then ls_requestdtto = ""
If( IsNull(ls_svccod) ) Then ls_svccod = ""
If( IsNull(ls_priceplan) ) Then ls_priceplan = ""
If( IsNull(ls_prmtype) ) Then ls_prmtype = ""
If( IsNull(ls_partner) ) Then ls_partner = ""
If( IsNull(ls_settle_partner) ) Then ls_settle_partner = ""
If( IsNull(ls_maintain_partner) ) Then ls_maintain_partner = ""
If( IsNull(ls_reg_partner) ) Then ls_reg_partner = ""
If( IsNull(ls_sale_partner) ) Then ls_sale_partner = ""
If IsNull(ls_validkey) Then ls_validkey = ""


//Dynamic SQL
ls_where = ""
If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "svcorder.customerid = '"+ ls_customerid +"'"
End If

If( ls_orderno <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.orderno = '"+ ls_orderno +"'"
End If

If( ls_orderdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(orderdt, 'YYYYMMDD') >= '"+ ls_orderdtfrom +"'"
End If

If( ls_orderdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(orderdt, 'YYYYMMDD') <= '"+ ls_orderdtto +"'"
End If

If( ls_status <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.status = '"+ ls_status +"'"
End If

If( ls_requestdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(requestdt, 'YYYYMMDD') >= '"+ ls_requestdtfrom +"'"
End If

If( ls_requestdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(requestdt, 'YYYYMMDD') <= '"+ ls_requestdtto +"'"
End If

If( ls_svccod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.svccod = '"+ ls_svccod +"'"
End If

If( ls_priceplan <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.priceplan = '"+ ls_priceplan +"'"
End If

If( ls_prmtype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.prmtype = '"+ ls_prmtype +"'"
End If

If( ls_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.partner = '"+ ls_partner +"'"
End If

If( ls_settle_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.settle_partner = '"+ ls_settle_partner +"'"
End If

If( ls_maintain_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.maintain_partner = '"+ ls_maintain_partner +"'"
End If

If( ls_reg_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.reg_partner = '"+ ls_reg_partner +"'"
End If

If( ls_sale_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "svcorder.sale_partner = '"+ ls_sale_partner +"'"
End If

If ls_validkey <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " svcorder.orderno  in (select distinct orderno from validinfo where validkey = '" + ls_validkey+ "') "
End If

dw_master.is_where	= ls_where

//Retrieve
ll_rows	= dw_master.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

on b1w_inq_svcorder.create
int iCurrent
call super::create
this.p_1=create p_1
this.st_horizontal2=create st_horizontal2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.st_horizontal2
end on

on b1w_inq_svcorder.destroy
call super::destroy
destroy(this.p_1)
destroy(this.st_horizontal2)
end on

event open;call super::open;/*--------------------------------------------------------------------
	Name	:	b1w_inq_svcorder
	Desc	:	서비스 신청 취소
	Ver.	: 	1.0
	Date	: 	2002.10.30
	Programer : Chooys(추윤식), ceusee(최보라)
--------------------------------------------------------------------*/
String ls_ref_desc, ls_termcod, ls_cancelcod
st_horizontal2.BackColor = BackColor

ls_ref_desc = ""
is_partner = fs_get_control("A1", "C102", ls_ref_desc)		//본사 대리점 코드
is_status_1 = fs_get_control("E1", "A100", ls_ref_desc)		//본사 재고 상태 코드
is_status_2 = fs_get_control("E1", "A102", ls_ref_desc)		//대리점 재고 상태 코드
is_action = fs_get_control("E1", "A302", ls_ref_desc)			//판매 취소

ls_termcod= fs_get_control("B0", "P221", ls_ref_desc)       //해지 상태 코드
ii_termcodcnt	= fi_cut_string( ls_termcod, ";", is_termcodes )
ls_cancelcod= fs_get_control("B0", "P222", ls_ref_desc)       //취소 상태 코드
ii_cancelcnt	= fi_cut_string( ls_cancelcod, ";", is_cancelcodes )
is_actorder= fs_get_control("B0", "P220", ls_ref_desc)       //개통신청상태






end event

type dw_cond from w_a_inq_m_m`dw_cond within b1w_inq_svcorder
integer x = 64
integer width = 2843
integer height = 632
string dataobject = "b1dw_cnd_inqorderbysvc"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"

idwo_help_col[2] = Object.maintain_partner
is_help_win[2] = "b1w_hlp_partner"
is_data[2] = "CloseWithReturn"

idwo_help_col[3] = Object.reg_partner
is_help_win[3] = "b1w_hlp_partner"
is_data[3] = "CloseWithReturn"

idwo_help_col[4] = Object.sale_partner
is_help_win[4] = "b1w_hlp_partner"
is_data[4] = "CloseWithReturn"


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
		
	Case "maintain_partner"
		If iu_cust_help.ib_data[1] Then
			Object.maintain_partner[row] = iu_cust_help.is_data[1]
			Object.maintain_partnernm[row] = iu_cust_help.is_data[2]
		End If
		
	Case "reg_partner"
		If iu_cust_help.ib_data[1] Then
			Object.reg_partner[row] = iu_cust_help.is_data[1]
			Object.reg_partnernm[row] = iu_cust_help.is_data[2]
		End If
		
	Case "sale_partner"
		If iu_cust_help.ib_data[1] Then
			Object.sale_partner[row] = iu_cust_help.is_data[1]
			Object.sale_partnernm[row] = iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "customerid"
		Object.customernm[1] = ""
		
	Case "maintain_partner"
		Object.maintain_partnernm[1] = ""
		
	Case "reg_partner"
		Object.reg_partnernm[1] = ""
		
	Case "sale_partner"
		Object.sale_partnernm[1] = ""
		
End Choose
end event

type p_ok from w_a_inq_m_m`p_ok within b1w_inq_svcorder
integer x = 3026
integer y = 60
end type

type p_close from w_a_inq_m_m`p_close within b1w_inq_svcorder
integer x = 3639
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b1w_inq_svcorder
integer x = 27
integer width = 2907
integer height = 688
end type

type dw_master from w_a_inq_m_m`dw_master within b1w_inq_svcorder
integer x = 27
integer y = 744
integer width = 3913
integer height = 1036
string dataobject = "b1dw_inq_mst_inqorderbysvc"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.svcorder_orderno_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_master::buttonclicked;call super::buttonclicked;long ll_master_row 

Choose Case dwo.Name
	Case "svcorder_cancel" //신청내역취소버튼
		
		ll_master_row = dw_master.Getselectedrow(0)
		If ll_master_row = 0 Then	return -1
		
		//삭제처리 User Object생성
		Integer	li_result
		li_result = f_msg_ques_yesno2(2070,title, "",2)
		If(li_result = 1) Then
			b1u_dbmgr3	lu_dbmgr3
			lu_dbmgr3 = Create b1u_dbmgr3
			lu_dbmgr3.is_caller = "b1w_inq_svcorder%cancel"
			lu_dbmgr3.is_data[1]	= Trim(String(Object.svcorder_orderno[This.getrow()]))
			lu_dbmgr3.is_data[2] = is_partner
			lu_dbmgr3.is_data[3] = is_status_1     //본사 재고  상태 코드
			lu_dbmgr3.is_data[4] = is_status_2	   //대리점 재고 상태 코드 
			lu_dbmgr3.is_data[5] = is_action	   //발생 이력
			lu_dbmgr3.is_data[6] = gs_user_id
			lu_dbmgr3.is_data[7] = gs_pgm_id[gi_open_win_no]
			lu_dbmgr3.idw_data[1] = dw_master
			lu_dbmgr3.uf_prc_db()
			IF lu_dbmgr3.ii_rc = 0 Then
				f_msg_info(3000,This.Title,"신청내역 취소")
				dw_master.Retrieve()
				Commit;
			ElseIf lu_dbmgr3.ii_rc < 0 Then
				f_msg_info(3010,This.Title,"신청내역 취소")
				Rollback;
				Destroy lu_dbmgr3
				Return
			End If
			
			Destroy lu_dbmgr3
		End If
		
	Case "svcitem_detail" //상세품목조회
		
			iu_cust_msg = Create u_cust_a_msg
			iu_cust_msg.is_pgm_name = "상세품목조회"
			iu_cust_msg.is_grp_name = "서비스 신청내역 조회/취소"
			iu_cust_msg.is_data[1] = Trim(String(Object.svcorder_orderno[This.getrow()]))
			
			OpenWithParm(b1w_inq_popup_svcorderitem, iu_cust_msg)
			
		
	Case "svcorder_update"  //수정할 수 있는 상태
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "신쳥내역 수정"
		iu_cust_msg.is_grp_name = "서비스 신청내역 수정"
		iu_cust_msg.is_data[1] = Trim(String(Object.svcorder_orderno[This.getrow()]))
		iu_cust_msg.is_data[2] = is_actorder   //개통 신청 상태
		iu_cust_msg.is_data[3] = is_termcodes[1]  //해지 신청 상태 코드
		
		OpenWithParm(b1w_reg_svcorder_update, iu_cust_msg)
			
End Choose


RETURN 0

end event

event dw_master::clicked;call super::clicked;//Check1.해지사유는 신청상태가 해지요청 또는 해지 일 경우에만 Visible
//->해지요청, 해지 신청상태 = sysctl1t.module='B0', ref_no='P221'
If row > 0 Then
	
	//해지요청, 해지신청상태 코드 알아내기
   Integer li_cnt



	This.Object.svcorder_termtype_t.visible = false
	This.Object.svcorder_termtype.visible = false
			
	For li_cnt=1 To ii_termcodcnt
		If( This.Object.svcorder_status[row] = is_termcodes[li_cnt] ) Then
			This.Object.svcorder_termtype_t.visible = true
			This.Object.svcorder_termtype.visible = true
		End If
	Next
	
	//Check2.신청상태가 취소가능한 때만 클릭할 수 있다.
	//->취소가능한 상태 = sysctl1t.module='B0', ref_no='P222'
	
	//취소가능한 상태 코드 알아내기
	
	Integer li_cnt2
    This.Object.svcorder_cancel.visible = False
	 This.Object.svcorder_update.visible = False
	
	For li_cnt2=1 To ii_cancelcnt
		If( This.Object.svcorder_status[row] = is_cancelcodes[li_cnt2] ) Then
			This.Object.svcorder_cancel.visible = True
			This.Object.svcorder_update.visible = True       //수정할 수 있게
		End If
	Next
	
	// Call the resize functions
	of_ResizeBars()
	of_ResizePanels()
	
	This.SetRow(row)
	This.ScrollToRow(row)
	
Else
	
	If dw_detail.rowcount() > 0 Then
		dw_detail.Visible = True
	Else
		dw_detail.Visible = False
	End if
	
End If






end event

event dw_master::retrieveend;call super::retrieveend;long ll_getrow

ll_getrow = This.getrow()
//Check1.해지사유는 신청상태가 해지요청 또는 해지 일 경우에만 Visible
//->해지요청, 해지 신청상태 = sysctl1t.module='B0', ref_no='P221'
If ll_getrow  > 0 Then
	
		//해지요청, 해지신청상태 코드 알아내기
   Integer li_cnt



	This.Object.svcorder_termtype_t.visible = false
	This.Object.svcorder_termtype.visible = false
			
	For li_cnt=1 To ii_termcodcnt
		If( This.Object.svcorder_status[ll_getrow] = is_termcodes[li_cnt] ) Then
			This.Object.svcorder_termtype_t.visible = true
			This.Object.svcorder_termtype.visible = true
		End If
	Next
	
	//Check2.신청상태가 취소가능한 때만 클릭할 수 있다.
	//->취소가능한 상태 = sysctl1t.module='B0', ref_no='P222'
	
	//취소가능한 상태 코드 알아내기
	
	Integer li_cnt2
    This.Object.svcorder_cancel.visible = False
	 This.Object.svcorder_update.visible = False
	
	For li_cnt2=1 To ii_cancelcnt
		If( This.Object.svcorder_status[ll_getrow] = is_cancelcodes[li_cnt2] ) Then
			This.Object.svcorder_cancel.visible = True
			This.Object.svcorder_update.visible = True       //수정할 수 있게
		End If
	Next
	
	// Call the resize functions
	of_ResizeBars()
	of_ResizePanels()
	
	This.SetRow(ll_getrow )
	This.ScrollToRow(ll_getrow )
	
Else
	
	If dw_detail.rowcount() > 0 Then
		dw_detail.Visible = True
	Else
		dw_detail.Visible = False
	End if
	
End If
end event

type dw_detail from w_a_inq_m_m`dw_detail within b1w_inq_svcorder
integer x = 27
integer y = 1376
integer width = 3566
integer height = 268
string dataobject = "b1dw_inq_validkey"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//조회
String ls_orderno, ls_where, ls_contractno
Long ll_row

This.SetRedraw(False)

If al_select_row = 0 Then Return 0
ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])
ls_contractno = String(dw_master.object.svcorder_ref_contractseq[al_select_row])

If ls_contractno  = '0' or isnull(ls_contractno) Then
	ls_where = ""
	ls_where += " to_char(orderno) = '" + ls_orderno + "'"
Else
	ls_where = ""
	ls_where += " to_char(orderno) = '" + ls_orderno + "' Or to_char(contractseq) = '" + ls_contractno + "' "
End IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

If dw_detail.rowcount() > 0 Then
	dw_detail.visible = True
Else
	dw_detail.visible = False
End if

This.SetRedraw(True)

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b1w_inq_svcorder
boolean visible = false
integer y = 1324
integer height = 52
end type

type p_1 from u_p_reset within b1w_inq_svcorder
integer x = 3333
integer y = 60
boolean bringtotop = true
boolean originalsize = false
end type

type st_horizontal2 from st_horizontal within b1w_inq_svcorder
boolean visible = true
integer y = 700
integer height = 44
end type

