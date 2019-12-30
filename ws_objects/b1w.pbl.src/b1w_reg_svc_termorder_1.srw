$PBExportHeader$b1w_reg_svc_termorder_1.srw
$PBExportComments$[ceusee] 해지신청/처리(위약금 포함)
forward
global type b1w_reg_svc_termorder_1 from w_a_reg_m_m
end type
type dw_detail3 from u_d_base within b1w_reg_svc_termorder_1
end type
type dw_detail2 from u_d_base within b1w_reg_svc_termorder_1
end type
end forward

global type b1w_reg_svc_termorder_1 from w_a_reg_m_m
integer width = 3355
integer height = 2216
dw_detail3 dw_detail3
dw_detail2 dw_detail2
end type
global b1w_reg_svc_termorder_1 b1w_reg_svc_termorder_1

type variables
String is_priceplan	//Price Plan Code
String is_termstatus[], is_termenable[], is_term_where
String is_date_check  //해지일 Check 여부

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
idrg_Bottom.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height / 2 + 100)

// Bottom Procesing
dw_detail3.Move(cii_WindowBorder + dw_detail2.Width + 40, idrg_Bottom.Y + idrg_Bottom.Height + 40)
dw_detail3.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height - idrg_Bottom.Height - 40)

end subroutine

on b1w_reg_svc_termorder_1.create
int iCurrent
call super::create
this.dw_detail3=create dw_detail3
this.dw_detail2=create dw_detail2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail3
this.Control[iCurrent+2]=this.dw_detail2
end on

on b1w_reg_svc_termorder_1.destroy
call super::destroy
destroy(this.dw_detail3)
destroy(this.dw_detail2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_termorder
	Desc.	: 	서비스 해지신청
	Ver.	:	1.0
	Date	: 	2002.10.08
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp
long li_i

//해지신청상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P221", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , is_termstatus[])
End if

//해지신청가능상태정보
ls_temp = fs_get_control("B0","P224", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , is_termenable[])
End if

//무조건 해지신청 가능한 것만 select하므로... 계속 쓰인다..
is_term_where = ""
For li_i = 1 To UpperBound(is_termenable[])
	If is_term_where <> "" Then is_term_where += " Or "
	is_term_where += "contractmst.status = '" + is_termenable[li_i] + "'"
Next
is_term_where = "( " + is_term_where + " ) " 

//해지일 Check 여부
ls_ref_desc = ""
is_date_check = fs_get_control("B0", "P210", ls_ref_desc)
end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_customerid, ls_payid, ls_contractno, ls_svccod, ls_priceplan
String ls_where, ls_activedt_fr, ls_activedt_to, ls_temp, ls_result[], ls_contractseq
String ls_ref_desc, ls_where_1, ls_detail_where, ls_orderno, ls_validkey
Date ld_activedt_fr, ld_activedt_to
Long ll_row, ll_cur_row, ll_detail_row
dec ldc_contractseq
Int li_i

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_contractseq = dw_cond.object.contractseq[1]
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_validkey = Trim(dw_cond.object.validkey[1])
//ls_svccod = Trim(dw_cond.object.svccod[1])
//ls_priceplan = Trim(dw_cond.object.priceplan[1])
//ld_activedt_fr = dw_cond.object.activedt_fr[1]
//ld_activedt_to = dw_cond.object.activedt_to[1]
//ls_activedt_fr = String(ld_activedt_fr, 'yyyymmdd')
//ls_activedt_to = String(ld_activedt_to, 'yyyymmdd')

//Null Check
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_contractseq) Then ls_contractseq = ""
If IsNull(ls_contractno) Then ls_contractno = ""
If IsNull(ls_validkey) Then ls_validkey = ""
//If IsNull(ls_activedt_fr) Then ls_activedt_fr = ""
//If IsNull(ls_activedt_to) Then ls_activedt_to = ""
//If IsNull(ls_svccod) Then ls_svccod = ""
//If IsNull(ls_priceplan) Then ls_priceplan= ""

IF ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contractmst.customerid = '" + ls_customerid + "' "
End If

IF ls_payid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "customerm_a.payid = '" + ls_payid + "' "
End If

IF ls_contractseq <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contractmst.contractseq = " + ls_contractseq + " "
End If

IF ls_contractno <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contractmst.contractno like '" + ls_contractno + "%' "
End If

If ls_validkey <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " contractmst.contractseq  in (select distinct contractseq from validinfo where validkey = '" + ls_validkey+ "') "
End If

//IF ls_svccod <> "" Then 
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "contractmst.svccod= '" + ls_svccod + "' "
//End If
//
//IF ls_priceplan <> "" Then 
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "contractmst.priceplan= '" + ls_priceplan + "' "
//End If

//If ls_activedt_fr <> "" Then
//  If ls_where <> "" Then ls_where += " And "  
//  ls_where += "to_char(contractmst.activedt,'YYYYMMDD') >='" + ls_activedt_fr + "' " 
//End if
//
//If ls_activedt_to <> "" Then
//  If ls_where <> "" Then ls_where += " And "  
//  ls_where += "to_char(contractmst.activedt,'YYYYMMDD') <='" + ls_activedt_to + "' " 
//End if

//해지신청가능 상태코드: open에서 instance 변수에 담음...<=해지신청 가능한 것만 select함!
If ls_where <> "" Then
	If is_term_where <> "" Then ls_where = ls_where + " And  " + is_term_where + "  "  
Else
	ls_where = is_term_where
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
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_detail2.Reset()
dw_detail3.Reset()
dw_cond.SetColumn("customerid")

Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_termdt, ls_partner, ls_termtype, ls_contractseq, ls_sysdt, ls_activedt, ls_prm_check
String ls_act_status, ls_ref_desc, ls_customerid
Boolean lb_check
Long ll_rows , ll_rc, ll_svccnt
DateTime ldt_termdt
b1u_dbmgr2 lu_dbmgr2

dw_detail.AcceptText()
ls_contractseq = String(dw_detail.object.contractmst_contractseq[1])
ls_termdt = string(dw_detail.object.termdt[1],'yyyymmdd')
ldt_termdt = dw_detail.object.termdt[1]
ls_partner = Trim(dw_detail.object.partner[1])
ls_termtype = dw_detail.object.termtype[1]
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_activedt = String(dw_detail.object.contractmst_activedt[1],'yyyymmdd')
ls_prm_check = String(dw_detail.object.prm_check[1])
ls_customerid =dw_detail.object.contractmst_customerid[1]

//Null Check
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_termtype) Then ls_termtype = ""
If IsNull(ls_termdt) Then ls_termdt = ""
If IsNull(ls_customerid) Then ls_customerid = ""

If ls_termdt = "" Then
	f_msg_usr_err(200, Title, "해지요청일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("termdt")
	Return -2
End If

If fb_reqdt_check(Title,ls_customerid,ls_termdt,"해지요청일") Then
Else
	dw_detail.SetFocus()
	dw_detail.SetColumn("termdt")
	Return -2
End If

////// 날짜 체크
If ls_termdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_termdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'개통일자의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("termdt")
		Return -2
	End If
	
	IF is_date_check = 'Y' Then
		If ls_termdt <= ls_sysdt Then
			f_msg_usr_err(210, Title, "해지요청일은 오늘보다 커야합니다.")
			dw_detail.SetFocus()
			dw_detail.SetColumn("termdt")
			Return -2
		End If		
	End If
	
	If ls_termdt <= ls_activedt Then
		f_msg_usr_err(210, Title, "'해지요청일은 개통일보다 커야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("termdt")
		Return -2
	End If	
	
	//개통상태코드
	ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

	//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 변경요청일이 커야한다.
	Select count(*)
	  Into :ll_svccnt
	  from validinfo
	 Where to_char(fromdt,'yyyymmdd') >= :ls_termdt
	   and to_char(contractseq) = :ls_contractseq
	   and status = :ls_act_status;	
	   
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Select count Error(validinfo)")
		Return  -2
	End If
	
	If ll_svccnt > 0 Then
		f_msg_usr_err(210, Title, "해지요청일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("termdt")
		Return -2
	End If
		
End if

If ls_termtype = "" Then
	f_msg_usr_err(200, Title, "해지사유")
	dw_detail.SetFocus()
	dw_detail.SetColumn("termtype")
	Return -2
End If

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "수행처")
	dw_detail.SetFocus()
	dw_detail.SetColumn("partner")
	Return -2
End If

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_svc_termorder_1%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = dw_detail
lu_dbmgr2.is_data[1] = ls_contractseq
lu_dbmgr2.is_data[2] = is_termstatus[1]        //해지신청상태코드
lu_dbmgr2.is_data[3] = ls_termdt
lu_dbmgr2.is_data[4] = ls_partner
lu_dbmgr2.is_data[5] = ls_termtype
lu_dbmgr2.is_data[6] = ls_prm_check
lu_dbmgr2.is_data[7] = is_termstatus[2]        //해지상태코드
lu_dbmgr2.idt_data[1] = ldt_termdt

lu_dbmgr2.uf_prc_db_02()
ll_rc = lu_dbmgr2.ii_rc

If ll_rc < 0 Then
	dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.	
	Destroy lu_dbmgr2
	Return ll_rc
End If

Destroy lu_dbmgr2

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
Constant Int LI_ERROR = -1

String ls_activedt, ls_bil_fromdt
String ls_customerid, ls_payid, ls_contractseq, ls_validkey , ls_contractno
Long ll_row, li_chk, i
Integer li_rc

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

li_chk =  f_msg_ques_yesno2(9000, Title, "[확인Message] 해지신청 하시겠습니까?!", 1)

If li_chk = 1 Then		//Yes

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
		f_msg_info(3010,This.Title,"해지신청")
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
		f_msg_info(3000,This.Title,"해지신청")
	ElseIF li_rc = -2 Then
		Return LI_ERROR
	End if
	
//	p_save.TriggerEvent("ue_disable")
End If

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_contractseq = dw_cond.object.contractseq[1]
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

Trigger Event ue_reset()
dw_cond.object.customerid[1] = ls_customerid
dw_cond.object.payid[1] = ls_payid
dw_cond.object.contractseq[1] = ls_contractseq
dw_cond.object.contractno[1] = ls_contractno 
dw_cond.object.validkey[1] = ls_validkey
Trigger Event ue_ok()

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_termorder_1
integer x = 41
integer y = 52
integer width = 2437
integer height = 280
string dataobject = "b1dw_cnd_svc_termorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

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
		
	Case "payid"
		
		 If data = "" then 
				This.Object.paynm[row] = ""			
				This.SetFocus()
				This.SetColumn("payid")
				Return -1
 		 End If		 
		 
		 SELECT customernm
		 INTO :ls_paynm
		 FROM customerm
		 WHERE customerid = :data
		   AND customerid = payid;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select 납입고객명")
			 Return 1
		 End If		 
		 
		 If ls_paynm = "" or isnull(ls_paynm ) then
//				This.Object.payid[row] = ""
				This.Object.paynm[row] = ""
				This.SetFocus()
				This.SetColumn("payid")
				Return -1
		 End if
		 
		 This.Object.paynm[row] = ls_paynm
		  
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"

//납입고객
This.idwo_help_col[2] = This.Object.payid
This.is_help_win[2] = "b1w_hlp_payid"
This.is_data[2] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
	Case "payid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.payid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.paynm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_termorder_1
integer x = 2638
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_termorder_1
integer x = 2944
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_termorder_1
integer width = 2501
integer height = 360
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_termorder_1
integer y = 396
integer width = 3237
integer height = 644
string dataobject = "b1dw_reg_svc_termorder_m"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::clicked;call super::clicked;//click 할때마다....  이미 해지신청한 내용을 가져와서 보여주고.. save 버튼을 disable 하는 우선 작업 막음!!

//Dec ldc_ref_contractseq
//String ls_termtype, ls_partner, ls_partnernm, ls_type, ls_contractpartner
//Long ll_row, ll_selected_row
//Datetime ldt_termdt
//
//dw_detail.SetRedraw(false)
//
//ll_selected_row = dw_detail.rowcount()
//
//If ll_selected_row > 0 Then
//
////	ls_partner = dw_detail.object.contractmst_partner[1]
//	ldc_ref_contractseq = dw_detail.object.contractmst_contractseq[1]
//	
//	Select svc.requestdt,
//			 svc.termtype,
//			 svc.partner,
//			 part.partnernm
//	 Into :ldt_termdt,
//			:ls_termtype,
//			:ls_partner,
//			:ls_partnernm
//	 From svcorder svc, partnermst part
//	Where svc.partner = part.partner
//	  And ref_contractseq = :ldc_ref_contractseq
//	  And status = :is_termstatus[1];
//	
//	If SQLCA.SQLCode < 0 Then
//		f_msg_sql_err(This.Title,"contractmst select")
//		Return -2
//	ElseIf SQLCA.SQLCode = 100 Then
//		p_save.TriggerEvent("ue_enable")	
//		dw_detail.object.termdt.protect = 0
//		dw_detail.object.termtype.protect = 0
//		dw_detail.object.partner.protect = 0
//   Else
//		dw_detail.object.termdt[1] = ldt_termdt
//		dw_detail.object.termtype[1] = ls_termtype
//		dw_detail.object.partner[1] = ls_partner
//		dw_detail.object.partner_1[1] = ls_partner
//		dw_detail.object.termdt.protect = 1
//		dw_detail.object.termtype.protect = 1
//		dw_detail.object.partner.protect = 1
//		p_save.TriggerEvent("ue_disable")	
////      dw_detail.object.all_termorder.visible = False
//		
//		dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
//	End If
//
//End If
//
//dw_detail.SetRedraw(true)

Long ll_selected_row,ll_old_selected_row
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

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
end event

event dw_master::retrieveend;call super::retrieveend;//click 할때마다....  이미 해지신청한 내용을 가져와서 보여주고.. save 버튼을 disable 하는 우선 작업 막음!!

//String ls_contractseq, ls_termtype, ls_partner, ls_partnernm
//Dec ldc_contractseq
//DateTime ldt_termdt
//
//If rowcount > 0 Then
//
//	ldc_contractseq = dw_master.object.contractmst_contractseq[1]
//	ls_contractseq = string(ldc_contractseq)
//
//	Select svc.requestdt,
//			 svc.termtype,
//			 svc.partner,
//			 part.partnernm
//	 Into :ldt_termdt,
//			:ls_termtype,
//			:ls_partner,
//			:ls_partnernm
//	 From svcorder svc, partnermst part
//	Where svc.partner = part.partner
//	  And ref_contractseq = :ldc_contractseq
//	  And status = :is_termstatus[1];
//	
//	If SQLCA.SQLCode < 0 Then
//		f_msg_sql_err(This.Title,"svcorder select")
//		Return -2
//	ElseIf SQLCA.SQLCode = 100 Then
//		p_save.TriggerEvent("ue_enable")	
//		dw_detail.object.termdt.protect = 0
//		dw_detail.object.termtype.protect = 0
//		dw_detail.object.partner.protect = 0
//   Else
//		dw_detail.object.termdt[1] = ldt_termdt
//		dw_detail.object.termtype[1] = ls_termtype
//		dw_detail.object.partner[1] = ls_partner
//		dw_detail.object.partner_1[1] = ls_partner
//		dw_detail.object.termdt.protect = 1
//		dw_detail.object.termtype.protect = 1
//		dw_detail.object.partner.protect = 1
//		p_save.TriggerEvent("ue_disable")		
//	End If
//
//End If
//
//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
//
//dw_detail.SetRedraw(true)
//
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_termorder_1
integer x = 1467
integer y = 1076
integer width = 1801
integer height = 588
string dataobject = "b1dw_reg_svc_termorder_detail"
boolean vscrollbar = false
end type

event dw_detail::buttonclicked;call super::buttonclicked;//Butonn Click
String ls_payid, ls_paynm, ls_termtype, ls_partner, ls_partnernm
String ls_customerid, ls_contractseq, ls_contractno, ls_validkey
Dec ldc_contractseq
Datetime ldt_termdt

Choose Case dwo.Name
	Case "all_termorder" //신청내역취소버튼

		ls_payid = Trim(This.object.customerm_payid[row])
		ls_paynm = ls_payid
//		ls_paynm = Trim(This.object.customerm_customernm_1[row])

		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "납입고객소속 전체고객 해지신청"
		iu_cust_msg.is_grp_name = "해지신청"
		iu_cust_msg.is_data[1] = ls_payid			   //납입고객 ID
		iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]			 //프로그램 ID
		iu_cust_msg.is_data[3] = is_term_where			//해지가능고객 where문
		iu_cust_msg.is_data[4] = is_termstatus[1]		//해지신청상태코드
		iu_cust_msg.is_data[5] = String(This.object.termdt[row],'yyyy-mm-dd')   //해지요청일
		iu_cust_msg.is_data[6] = Trim(This.object.termtype[row])                //해지유형
		iu_cust_msg.is_data[7] = Trim(This.object.partner[row])			        //수행처
		iu_cust_msg.is_data[8] = String(This.object.prm_check[row])		     	//위약금유형
		iu_cust_msg.is_data[9] = is_termstatus[2]						     	//해지상태코드
		iu_cust_msg.is_data[10] = String(This.object.enddt[row],'yyyy-mm-dd')   //해지요청일
		iu_cust_msg.is_data[11] = This.object.act_gu[row]					    //해지처리확정
	
		OpenWithParm(b1w_reg_termorder_pop_1, iu_cust_msg)
		
    	dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.	

		//다시 Reset
		ls_customerid = Trim(dw_cond.object.customerid[1])
		ls_payid = Trim(dw_cond.object.payid[1])
		ls_contractseq = dw_cond.object.contractseq[1]
		ls_contractno = Trim(dw_cond.object.contractno[1])
		ls_validkey = Trim(dw_cond.object.validkey[1])
		
		Trigger Event ue_reset()
		dw_cond.object.customerid[1] = ls_customerid
		dw_cond.object.payid[1] = ls_payid
		dw_cond.object.contractseq[1] = ls_contractseq
		dw_cond.object.contractno[1] = ls_contractno 
		dw_cond.object.validkey[1] = ls_validkey
		Trigger Event ue_ok()

//		ldc_contractseq = dw_detail.object.contractmst_contractseq[1]
//	
//		Select svc.requestdt,
//				 svc.termtype,
//				 svc.partner,
//				 part.partnernm
//		 Into :ldt_termdt,
//				:ls_termtype,
//				:ls_partner,
//				:ls_partnernm
//		 From svcorder svc, partnermst part
//		Where svc.partner = part.partner
//		  And ref_contractseq = :ldc_contractseq
//		  And status = :is_termstatus[1];
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title,"contractmst select")
//			Return -2
//		ElseIf SQLCA.SQLCode = 100 Then
//			p_save.TriggerEvent("ue_enable")	
//			dw_detail.object.termdt.protect = 0
//			dw_detail.object.termtype.protect = 0
//			dw_detail.object.partner.protect = 0
//		Else
//			dw_detail.object.termdt[1] = ldt_termdt
//			dw_detail.object.termtype[1] = ls_termtype
//			dw_detail.object.partner[1] = ls_partner
//			dw_detail.object.termdt.protect = 1
//			dw_detail.object.termtype.protect = 1
//			dw_detail.object.partner.protect = 1
//			p_save.TriggerEvent("ue_disable")	
//			
//			dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
//		End If

//	Case "item_detail" //상세품목조회
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "상세품목조회"
//		iu_cust_msg.is_grp_name = "서비스해지신청"
//		iu_cust_msg.is_data[1] = Trim(String(Object.contractmst_contractseq[1]))
//		
//		OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
//		
End Choose

Return 0 
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_contractseq, ls_termtype, ls_partner, ls_partnernm
Long ll_row
Dec ldc_contractseq
DateTime ldt_termdt

ldc_contractseq = dw_master.object.contractmst_contractseq[al_select_row]
ls_contractseq = string(ldc_contractseq)
If IsNull(ldc_contractseq) Then ls_contractseq = ""
ls_where = ""
If ls_contractseq <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contractmst.contractseq = " + ls_contractseq + ""
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
dw_detail.object.termdt[1] = relativedate(date(fdt_get_dbserver_now()),1)
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

If dw_detail2.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

If dw_detail3.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

dw_detail.SetRedraw(true)

Return 0
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_act_gu
datetime ldt_date

setnull(ldt_date)
Choose Case dwo.name
	Case "termdt" 
		
		ls_act_gu = This.object.act_gu[row]
		If ls_act_gu = 'Y' Then
			This.object.enddt[row] = datetime(relativedate(date(This.object.termdt[row]), -1))			
		End If
		
	Case "act_gu" 
		
		If data = 'Y' Then
			This.object.enddt[row] = datetime(relativedate(date(This.object.termdt[row]), -1))			
		ElseIf  data = 'N'Then
			This.object.enddt[row] = ldt_date
		End If
			
End Choose	
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_termorder_1
boolean visible = false
integer y = 1716
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_termorder_1
boolean visible = false
integer y = 1716
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_termorder_1
integer x = 69
integer y = 1988
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_termorder_1
integer x = 375
integer y = 1988
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_termorder_1
integer y = 1040
integer height = 40
end type

type dw_detail3 from u_d_base within b1w_reg_svc_termorder_1
event type integer ue_retrieve ( long al_select_row )
integer x = 1467
integer y = 1676
integer width = 1801
integer height = 284
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

type dw_detail2 from u_d_base within b1w_reg_svc_termorder_1
event type integer ue_retrieve ( long al_select_row )
integer x = 32
integer y = 1076
integer width = 1390
integer height = 884
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

