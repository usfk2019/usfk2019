$PBExportHeader$b1w_reg_svc_actorder_cv.srw
$PBExportComments$[ceusee] 서비스 신청/개통 (할부가능)
forward
global type b1w_reg_svc_actorder_cv from w_a_reg_m_m3
end type
end forward

global type b1w_reg_svc_actorder_cv from w_a_reg_m_m3
integer width = 3314
integer height = 1940
end type
global b1w_reg_svc_actorder_cv b1w_reg_svc_actorder_cv

type variables
Long il_orderno, il_validkey_cnt, il_contractseq
String is_act_gu, is_cus_status, is_validkey_yn, is_svctype
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public subroutine of_resizepanels ()
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm
Select customernm,
	   status
Into :ls_customernm,
	 :is_cus_status
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0

end function

public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check);//선불 고객인지 확인
String ls_ctype3
ab_check = False
	
	select ctype3 
	into :ls_ctype3
	from customerm
	where customerid = :as_customerid;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("선불고객", "Select customerm Table")
		Return 0
	End If
	
	If ls_ctype3 = "0" Then
		ab_check = True
		
	
	Else
		ab_check = False
		
	End If
 
Return 0
end function

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

Long		ll_Width, ll_Height, ll_long, ll_long_1, ll_long_2

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return

ll_Width = WorkSpaceWidth()
ll_Height = WorkspaceHeight()

// Middle processing
idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness)

If il_validkey_cnt > 0 Then
	idrg_Middle.Resize(idrg_Top.Width, st_horizontal.Y  - st_horizontal2.Y  )	
Else
//	idrg_Middle.Resize(idrg_Top.Width, ll_Height - (dw_cond.Height + cii_BarThickness * 3 ) - (ll_Height - p_insert.Y )	)
	idrg_Middle.Resize(idrg_Top.Width, p_insert.Y - st_horizontal2.Y - cii_BarThickness * 2)	
End If


end subroutine

on b1w_reg_svc_actorder_cv.create
call super::create
end on

on b1w_reg_svc_actorder_cv.destroy
call super::destroy
end on

event open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actorder
	Desc	: 	서비스 신청
	Ver.	:	1.0
	Date	:   2003.03.03
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
call w_a_condition::open

iu_cust_db_app = Create u_cust_db_app

//// Set the TopLeft, TopRight, and Bottom Controls
idrg_Top = dw_master
idrg_Middle = dw_detail2
idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
ii_WindowMiddle = idrg_Middle.Y
st_horizontal.BackColor = BackColor
st_horizontal2.BackColor = BackColor
il_HiddenColor = BackColor

dw_detail.Enabled = False
dw_detail.visible = False

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

//수정불가능
dw_cond.object.priceplan.Protect = 1
dw_cond.object.prmtype.Protect = 1
dw_cond.object.svccod.Protect = 1

//날짜 Setting
dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.sale_partnernm[1] = gs_user_group


il_orderno = 0
end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String ls_svccod, ls_priceplan, ls_customerid, ls_partner, ls_requestdt
String ls_where, ls_contract_no, ls_gkid, ls_auth_method, ls_sysdt
String ls_ip_address, ls_h323id, ls_bil_fromdt, ls_reg_partner, ls_sale_partner
Long ll_row

ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_bil_fromdt = String(dw_cond.object.bil_fromdt[1],'yyyymmdd')
ls_partner = Trim(dw_cond.object.partner[1])
is_act_gu = Trim(dw_cond.object.act_gu[1])
ls_reg_partner = Trim(dw_cond.object.reg_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(is_act_gu) Then is_act_gu = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""


If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	ll_row = wfi_get_customerid(ls_customerid)		//올바른 고객인지 확인
	If ll_row = -1 Then Return
	 
End If

If ls_requestdt = "" Then
	f_msg_info(200, Title, "개통요청일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If


If ls_requestdt < ls_sysdt Then
	f_msg_usr_err(210, Title, "개통요청일은 오늘날짜 이상이여야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If		

If ls_partner = "" Then
	f_msg_info(200, Title, "수행처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

If ls_svccod = "" Then
	f_msg_info(200, Title, "신청서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

If ls_priceplan = "" Then
	f_msg_info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
	Return
End If

If is_act_gu = "" Then
	f_msg_info(200, Title, "개통처리")
	dw_cond.SetFocus()
	dw_cond.SetColumn("act_gu")
	Return
End IF

If is_act_gu = "Y" Then
	If ls_bil_fromdt = "" Then
		f_msg_info(200, Title, "과금시작일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If
	
	If ls_bil_fromdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "과금시작일은 오늘날짜 이상이여야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If		

End IF


If ls_reg_partner = "" Then
	f_msg_info(200, Title, "유치처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reg_partner")
	Return
End If

If ls_sale_partner = "" Then
	f_msg_info(200, Title, "매출처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("sale_partner")
	Return
End If


//If il_validkey_cnt > 0 Then
//
//	ls_gkid = Trim(dw_cond.object.gkid[1])
//	ls_auth_method = Trim(dw_cond.object.auth_method[1])
//	ls_h323id = Trim(dw_cond.object.h323id[1])
//	ls_ip_address = Trim(dw_cond.object.ip_address[1])
//
//	If IsNull(ls_gkid) Then ls_gkid = ""
//	If IsNull(ls_auth_method) Then ls_auth_method = ""
//	If IsNull(ls_h323id) Then ls_h323id = ""
//	If IsNull(ls_ip_address) Then ls_ip_address = ""
//	
//	If ls_gkid = "" Then
//		f_msg_info(200, Title, "GKID")		
//		dw_cond.SetFocus()
//		dw_cond.SetColumn("gkid")
//		Return 
//	End If		
//	
//	If ls_auth_method = "" Then
//		f_msg_info(200, Title, "인증방법")
//		dw_cond.SetFocus()
//		dw_cond.SetColumn("auth_method")
//		Return 
//	End If		
//	
//	If left(ls_auth_method,1) = 'S' Then
//		ls_ip_address = dw_cond.object.ip_address[1]
//		If IsNull(ls_ip_address) Then ls_ip_address = ""				
//		If ls_ip_address = "" Then
//			f_msg_info(200, Title, "IP ADDRESS")
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("ip_address")
//			Return
//		End If		
//	End if
//	
//	If mid(ls_auth_method,7,1) <> 'E' Then
//		ls_h323id = dw_cond.object.h323id[1]
//		If IsNull(ls_h323id) Then ls_h323id = ""							
//		If ls_h323id = "" Then
//			f_msg_info(200, Title, "H323ID")
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("h323id")
//			Return 
//		End If		
//	End if	
	
//End If

ls_where = ""
ls_where += "det.priceplan ='" + ls_priceplan + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

SetRedraw(False)

If ll_row > 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail2.SetFocus()
	
	dw_detail2.Enabled = True
	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
End If

If il_validkey_cnt > 0 Then
	dw_detail.ib_insert = True
	dw_detail.ib_delete = True	
	dw_detail.Enabled = True
	dw_detail.visible = True	
	dw_detail.setfocus()	
Else 
	dw_detail.ib_insert = False
	dw_detail.ib_delete = False
	dw_detail.Enabled = False
	dw_detail.visible = False
End If

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event ue_reset();call super::ue_reset;dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.sale_partnernm[1] = gs_user_group


is_validkey_yn= 'N'
il_validkey_cnt = 0 

SetRedraw(False)

dw_detail.Enabled = False
dw_detail.visible = False

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event type integer ue_save();String ls_quota_yn, ls_chk
Long i, ll_row, j
Int li_rc
Constant Int LI_ERROR = -1

If dw_detail2.AcceptText() < 0 Then
	dw_detail2.SetFocus()
	Return LI_ERROR
End If

This.Trigger Event ue_extra_save(li_rc)
If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail2.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"개통신청(처리)")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail2.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"개통신청(처리)")
ElseIF li_rc = -2 Then
	dw_detail2.SetFocus()	
	Return LI_ERROR
ElseIF li_rc = -3 Then
	dw_detail2.SetFocus()	
	Return LI_ERROR
ElseIF li_rc = -4 Then
	dw_detail2.SetFocus()	
	Return LI_ERROR
ElseIF li_rc = -5 Then
	dw_detail2.SetFocus()	
	Return LI_ERROR
End if
//저장한거로 인식하게 함.
//저장한거로 인식하게 함.
For i = 1 To dw_detail.RowCount()
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next  
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   

p_save.TriggerEvent("ue_disable")		//버튼 비활성화
p_insert.TriggerEvent("ue_disable")		//버튼 비활성화
p_delete.TriggerEvent("ue_disable")		//버튼 비활성화
dw_detail2.ib_insert = False
dw_detail2.ib_delete = False


//String ls_customerid
//Boolean lb_quota
//iu_cust_msg = Create u_cust_a_msg
//j = 1
////할부 품목을 신청했으면
//ll_row = dw_detail2.RowCount()
//If ll_row = 0 Then Return 0
//For i = 1 To ll_row
//	ls_chk = Trim(dw_detail2.object.chk[i])
//	If ls_chk = "Y" Then
//		ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
//		If ls_quota_yn = "Y" Then
//			iu_cust_msg.is_data[j] = Trim(dw_detail2.object.itemcod[i])
//			j++
//		End If
//	End If
//Next
//
//For i = 1 To ll_row
//	ls_chk = Trim(dw_detail2.object.chk[i])
//	If ls_chk = "Y" Then
//		ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
//		If ls_quota_yn = "Y" Then
//			lb_quota = TRUE
//			Exit
//		Else
//			lb_quota = FALSE
//		End If
//	End If
//Next
//	
//If lb_quota Then			//할부 Check한게 있으면
//	ls_customerid = Trim(dw_cond.object.customerid[1])
//	
//	iu_cust_msg.is_pgm_name = "서비스품목 할부 등록"
//	iu_cust_msg.is_grp_name = "서비스 신청"
//	iu_cust_msg.il_data[1] = il_orderno							//order number
//	iu_cust_msg.il_data[2] = il_contractseq					//contractseq
//	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
//	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
//	iu_cust_msg.is_data2[4] = is_act_gu                   //실행 여부
//	
//	 
//   OpenWithParm(b1w_reg_quotainfo_pop_1, iu_cust_msg)
//	
//End If

Return 0
end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;Long ll_row
Integer li_rc
b1u_dbmgr 	lu_dbmgr

SetNull(il_contractseq)
ll_row  = dw_detail2.RowCount()
If ll_row = 0 Then 
	ai_return = 0
	Return
End if

//If il_validkey_cnt > 0 Then
//	ll_row  = dw_detail.RowCount()
//	If ll_row = 0 Then 
//		f_msg_usr_err(9000, Title, "사용할 인증KEY를 입력하셔야 합니다.")		
//		ai_return = -2
//		Return
//	End if
//End if

//MainItem 한개만 입력
Int li_main, i
li_main = 0
For i = 1 To ll_row
	IF dw_detail2.object.mainitem_yn[i] = "Y" AND dw_detail2.object.chk[i] = "Y" THEN
		li_main++ 
	END IF
Next

IF li_main = 0 THEN
	f_msg_usr_err(9000, Title, "기본품목을 한개 선택해야 합니다.")
	ai_return = -4
	return
ELSEIF li_main > 1 THEN
	ai_return = -5
	return
END IF


//저장
lu_dbmgr = Create b1u_dbmgr
lu_dbmgr.is_caller = "b1w_reg_svc_actorder_cv%save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2                //품목
lu_dbmgr.idw_data[3] = dw_detail			     //인증KEY
lu_dbmgr.is_data[1] = gs_user_id
lu_dbmgr.is_data[2] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[3] = is_act_gu                  //개통처리 check
lu_dbmgr.is_data[4] = is_cus_status              //고객상태
lu_dbmgr.is_data[5] = is_svctype                 //svctype
lu_dbmgr.is_data[6] = string(il_validkey_cnt)    //인증KEY갯수

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	ai_return = -1
	Return
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	ai_return = -2	
	Return
End If

il_orderno = lu_dbmgr.il_data[1]
If is_act_gu = "Y" Then
	il_contractseq = lu_dbmgr.il_data[2]
End If

Destroy lu_dbmgr

ai_return = li_rc

Return
end event

type dw_cond from w_a_reg_m_m3`dw_cond within b1w_reg_svc_actorder_cv
integer y = 56
integer width = 2578
integer height = 592
string dataobject = "b1dw_cnd_reg_svc_actorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod
Long li_exist
String ls_filter, ls_validkey_yn, ls_customerid, ls_currency_type
Boolean lb_check

//선불고객에는 선불 서비스만
//If dwo.name = "customerid" Then
//   wfi_get_child(data)
//End If

Choose Case dwo.name
	Case "customerid" 
   		wfi_get_customerid(data)		
		   
	Case "svccod"
		
		ls_customerid = Trim(dw_cond.object.customerid[1])

		Select svctype
		  Into :is_svctype
		  From svcmst
		where svccod = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT svctype from svcmst")				
			Return 1
		End If	
		
		//고객의 납입자의 화폐단위 가져오기
		select currency_type into :ls_currency_type from billinginfo bil, customerm cus
		where bil.customerid = cus.payid and  cus.customerid =:ls_customerid;
		
		
		li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		ls_filter = "svccod = '" + data  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' And " + &
		            "currency_type ='" + ls_currency_type + "' " 
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  
		
		//선택할수 있게
		dw_cond.object.priceplan.Protect = 0
		
		//약정유형
		li_exist = dw_cond.GetChild("prmtype", ldc_svcpromise)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 약정유형")
		ls_filter = "svccod = '" + data  + "' "
		ldc_svcpromise.SetTransObject(SQLCA)
		li_exist =ldc_svcpromise.Retrieve()
		ldc_svcpromise.SetFilter(ls_filter)			//Filter정함
		ldc_svcpromise.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1
		End If  
		
		dw_cond.object.prmtype.Protect = 0
		
	Case "priceplan"
		
		Select nvl(validkeycnt,0)
		  Into :il_validkey_cnt
		  From priceplanmst
		where priceplan  = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT validkey_yn from priceplanmst")				
			Return 1
		End If	
		
//		If il_validkey_cnt > 0 Then
//			This.object.gkid.Protect = 0
//			This.object.auth_method.Protect = 0
//			This.Object.h323id.Protect = 0
//			This.Object.ip_address.Protect = 0
//			This.Object.gkid.Background.Color = RGB(108, 147, 137)
//			This.Object.gkid.Color = RGB(255, 255, 255)
//			This.Object.auth_method.Background.Color = RGB(108, 147, 137)
//			This.Object.auth_method.Color = RGB(255, 255, 255)
//			This.Object.h323id.Background.Color = RGB(255, 255, 255)
//			This.Object.h323id.Color = RGB(0, 0, 0)
//			This.Object.ip_address.Background.Color = RGB(255, 255, 255)
//			This.Object.ip_address.Color = RGB(0, 0, 0)
//		ElseIf il_validkey_cnt = 0 Then
//			This.object.gkid[1] = ""
//			This.object.auth_method[1] = ""
//			This.Object.h323id[1] = ""
//			This.Object.ip_address[1] = ""
//			This.object.gkid.Protect = 1
//			This.object.auth_method.Protect = 1
//			This.Object.h323id.Protect = 1
//			This.Object.ip_address.Protect = 1
//			This.Object.gkid.Background.Color = RGB(255, 251, 240)
//			This.Object.gkid.Color = RGB(0, 0, 0)		
//			This.Object.auth_method.Background.Color = RGB(255, 251, 240)
//			This.Object.auth_method.Color = RGB(0, 0, 0)		
//			This.Object.h323id.Background.Color = RGB(255, 251, 240)
//			This.Object.h323id.Color = RGB(0, 0, 0)
//			This.Object.ip_address.Background.Color = RGB(255, 251, 240)
//			This.Object.ip_address.Color = RGB(0, 0, 0)
//		End If
		
	Case "reg_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.reg_partnernm[1] = ""
		Else
			Object.reg_partnernm[1] = data
		End IF
		
	Case "sale_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.sale_partnernm[1] = ""
		Else
			Object.sale_partnernm[1] = data
		End IF
		
	Case "auth_method"
	
		If LeftA(data, 1) = 'D' Then This.object.ip_address[1] = ""
	
		If MidA(data, 7,1) = 'E' Then This.object.h323id[1]= ""
	
End Choose	
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"

//유치파트너
This.idwo_help_col[2] = This.Object.reg_partner
This.is_help_win[2] = "b1w_hlp_partner"
This.is_data[2] = "CloseWithReturn"

//매출 파트너 
This.idwo_help_col[3] = This.Object.sale_partner
This.is_help_win[3] = "b1w_hlp_partner"
This.is_data[3] = "CloseWithReturn"
end event

event dw_cond::clicked;call super::clicked;If dwo.name = "svccod" Then
	dw_cond.object.priceplan[1] = ""
	dw_cond.object.prmtype[1] = ""
End If
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist
Boolean lb_check
String ls_filter

Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
			 is_cus_status = dw_cond.iu_cust_help.is_data[3]
		End If
		dw_cond.object.svccod.Protect = 0					 		
  Case "reg_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.reg_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.reg_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
	Case "sale_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.sale_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.sale_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_m3`p_ok within b1w_reg_svc_actorder_cv
integer x = 2688
integer y = 60
end type

type p_close from w_a_reg_m_m3`p_close within b1w_reg_svc_actorder_cv
integer x = 2990
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b1w_reg_svc_actorder_cv
integer x = 41
integer y = 4
integer width = 2624
integer height = 680
end type

type dw_master from w_a_reg_m_m3`dw_master within b1w_reg_svc_actorder_cv
boolean visible = false
integer x = 23
integer y = 952
integer width = 2670
end type

type dw_detail from w_a_reg_m_m3`dw_detail within b1w_reg_svc_actorder_cv
integer x = 37
integer y = 1408
integer width = 3186
integer height = 280
string dataobject = "b1dw_reg_svc_actorder_ipn"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

end event

type p_insert from w_a_reg_m_m3`p_insert within b1w_reg_svc_actorder_cv
integer x = 46
integer y = 1716
end type

type p_delete from w_a_reg_m_m3`p_delete within b1w_reg_svc_actorder_cv
integer x = 338
integer y = 1716
end type

type p_save from w_a_reg_m_m3`p_save within b1w_reg_svc_actorder_cv
integer x = 631
integer y = 1716
end type

type p_reset from w_a_reg_m_m3`p_reset within b1w_reg_svc_actorder_cv
integer x = 1381
integer y = 1716
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b1w_reg_svc_actorder_cv
integer x = 37
integer y = 744
integer width = 3186
integer height = 624
string dataobject = "b1dw_reg_svc_actorder_cv"
end type

event dw_detail2::constructor;call super::constructor;dw_detail2.SetRowFocusIndicator(off!)
end event

event dw_detail2::retrieveend;call super::retrieveend;Long i
String ls_mainitem_yn

If rowcount = 0 Then
	p_save.TriggerEvent("ue_disable")
End If


For i = 1 To rowcount 

	IF dw_detail2.object.mainitem_yn[i] = "Y" Then
		dw_detail2.object.chk[i] = "Y"
		Exit
	END IF

	This.SetItemStatus(i, 0, Primary!, NotModified!)

Next
end event

event dw_detail2::ue_init();call super::ue_init;ib_delete = False
ib_insert = False

end event

event dw_detail2::itemchanged;call super::itemchanged;Int i
Long rowcount

Choose Case dwo.name

	Case "chk"
		rowcount = dw_detail2.rowcount()
		IF data = "Y" AND dw_detail2.object.mainitem_yn[row] = "Y" THEN
			For i = 1 To rowcount
				IF dw_detail2.object.mainitem_yn[i] = "Y" THEN
					dw_detail2.object.chk[i] = "N" 
				END IF
			Next
			dw_detail2.object.chk[row] = "Y"
		END IF
		//This.SetItemStatus(i, 0, Primary!, NotModified!)
End Choose
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b1w_reg_svc_actorder_cv
integer y = 704
integer height = 36
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within b1w_reg_svc_actorder_cv
boolean visible = false
integer y = 1372
integer height = 36
end type

