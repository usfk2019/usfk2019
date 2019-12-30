$PBExportHeader$b1w_reg_svc_actorder_1.srw
$PBExportComments$-현재사용안함-[ceusee] 서비스 신청/개통 PopUp(할부가능)
forward
global type b1w_reg_svc_actorder_1 from w_a_reg_m
end type
end forward

global type b1w_reg_svc_actorder_1 from w_a_reg_m
integer width = 2944
integer height = 1832
end type
global b1w_reg_svc_actorder_1 b1w_reg_svc_actorder_1

type variables
Long il_orderno
String is_pgm_id, is_customerid
DataWindow idw_data[]

end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
public subroutine wfi_get_child (string as_data)
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
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
	Desc	: 고객 Id 구하기]
	Date	: 2002.10.01
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_customernm
Select customernm
Into :ls_customernm
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

public subroutine wfi_get_child (string as_data);DataWindowChild ldc_svccod
Integer li_exist
String ls_filter
Boolean lb_check

li_exist = dw_cond.GetChild("svccod", ldc_svccod)
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 서비스")
wfi_get_ctype3(as_data, lb_check)
//선불 고객이면 
If lb_check Then
	ls_filter = "svctype = '0'"
Else
	ls_filter = "svctype = '1'"
End If

ldc_svccod.SetTransObject(SQLCA)
li_exist =ldc_svccod.Retrieve()
ldc_svccod.SetFilter(ls_filter)			//Filter정함
ldc_svccod.Filter()
end subroutine

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

on b1w_reg_svc_actorder_1.create
call super::create
end on

on b1w_reg_svc_actorder_1.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actorder_1
	Desc	: 	서비스 신청
	Ver.	:	1.0
	Date	: 2002.10.01
	Programer : choi bo ra(ceusee)
-------------------------------------------------------------------------*/
String ls_svccod
dwObject ldwo_svccod

ldwo_svccod = dw_cond.object.svccod

f_center_window(This)

//수정 불가능
dw_cond.object.priceplan.Protect = 1
dw_cond.object.svccod.Protect = 1
dw_cond.object.customerid.Protect = 1


is_customerid = iu_cust_msg.is_data[1] 
dw_cond.object.customerid[1] = is_customerid
dw_cond.object.svccod[1] = iu_cust_msg.is_data[2]
dw_cond.object.priceplan[1] = iu_cust_msg.is_data[3]
is_pgm_id = iu_cust_msg.is_data[4]
ls_svccod = iu_cust_msg.is_data[2]
idw_data[1] = iu_cust_msg.idw_data[1]

//날짜 Setting
dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
il_orderno = 0
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.sale_partnernm[1] = gs_user_group


//Item Changed Event 발생
dw_cond.Event ItemChanged(1,ldwo_svccod ,ls_svccod)
end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String ls_svccod, ls_priceplan, ls_customerid, ls_partner, ls_requestdt
String ls_where
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_partner) Then ls_partner = ""

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

ls_where = ""
ls_where += "det.priceplan ='" + ls_priceplan + "' "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If
end event

event ue_extra_save;Long ll_row
Integer li_rc
b1u_dbmgr 	lu_dbmgr

ll_row  = dw_detail.RowCount()
If ll_row = 0 Then Return 0

//저장
lu_dbmgr = Create b1u_dbmgr
lu_dbmgr.is_caller = "b1w_reg_svc_actorder%save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail
lu_dbmgr.is_data[1] = gs_user_id
lu_dbmgr.is_data[2] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	Return -1
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	Return -2
End If

il_orderno = lu_dbmgr.il_data[1]
Destroy lu_dbmgr
Return 0
end event

event type integer ue_save();String ls_quota_yn, ls_chk
Long i, ll_row, j
Integer li_return
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

li_return = This.Trigger Event ue_extra_save()

If li_return < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"서비스 신청")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
End If

//저장한거로 인식하게 함.
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)  

f_msg_info(3000,This.Title,"서비스 신청")
p_save.TriggerEvent("ue_disable")		//버튼 비활성화

//Save시 tab_1 다시 조회
ll_row = idw_data[1].Retrieve(is_customerid)

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If


String ls_customerid
Boolean lb_quota
iu_cust_msg = Create u_cust_a_msg
j = 1
//할부 품목을 신청했으면
ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0
For i = 1 To ll_row
	ls_chk = Trim(dw_detail.object.chk[i])
	If ls_chk = "Y" Then
		ls_quota_yn = Trim(dw_detail.object.quota_yn[i])
		If ls_quota_yn = "Y" Then
			iu_cust_msg.is_data[j] = Trim(dw_detail.object.itemcod[i])
			j++
		End If
	End If
Next

For i = 1 To ll_row
	ls_chk = Trim(dw_detail.object.chk[i])
	If ls_chk = "Y" Then
		ls_quota_yn = Trim(dw_detail.object.quota_yn[i])
		If ls_quota_yn = "Y" Then
			lb_quota = TRUE
			Exit
		Else
			lb_quota = FALSE
		End If
	End If
Next

	
If lb_quota Then			//할부 Check한게 있으면
	ls_customerid = Trim(dw_cond.object.customerid[1])
	
	iu_cust_msg.is_pgm_name = "서비스품목 할부 등록"
	iu_cust_msg.is_grp_name = "서비스 신청"
	iu_cust_msg.il_data[1] = il_orderno							//order number
	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
   
	 
   OpenWithParm(b1w_reg_quotainfo_pop_1, iu_cust_msg)
	
End If
Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.object.priceplan.Protect = 0
dw_cond.object.svccod.Protect = 0
dw_cond.object.customerid.Protect = 1


dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
dw_cond.object.customerid[1] = is_customerid
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.sale_partnernm[1] = gs_user_group


Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_svc_actorder_1
integer width = 2519
integer height = 620
string dataobject = "b1dw_cnd_reg_svc_actorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
//This.idwo_help_col[1] = This.Object.customerid
//This.is_help_win[1] = "b1w_hlp_customerm"
//This.is_data[1] = "CloseWithReturn"

//유치파트너
This.idwo_help_col[1] = This.Object.reg_partner
This.is_help_win[1] = "b1w_hlp_partner"
This.is_data[1] = "CloseWithReturn"

//관리
This.idwo_help_col[2] = This.Object.maintain_partner
This.is_help_win[2] = "b1w_hlp_partner"
This.is_data[2] = "CloseWithReturn"

//매출 파트너 
This.idwo_help_col[3] = This.Object.sale_partner
This.is_help_win[3] = "b1w_hlp_partner"
This.is_data[3] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist
Boolean lb_check
String ls_filter

Choose Case dwo.name
//	Case "customerid"
//		If dw_cond.iu_cust_help.ib_data[1] Then
//			 dw_cond.Object.customerid[row] = &
//			 dw_cond.iu_cust_help.is_data[1]
//			 dw_cond.object.customernm[row] = &
//			 dw_cond.iu_cust_help.is_data[2]
//		End If
  Case "reg_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.reg_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.reg_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
	Case "maintain_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.maintain_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.maintain_partnernm[row] = &
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

event dw_cond::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod
Long li_exist
String ls_filter
Boolean lb_check

//선불고객에는 선불 서비스만
//If dwo.name = "customerid" Then
//   wfi_get_child(data)
//End If

//priceplan
If dwo.name = "svccod" Then
	li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
	If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
	ls_filter = "svccod = '" + data  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' " 
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
End If

Choose Case dwo.name		
	//추가 ceusee
	Case "maintain_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.maintain_partnernm[1] = ""
		Else
			Object.maintain_partnernm[1] = data
		End IF
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
End Choose	
end event

event dw_cond::clicked;call super::clicked;If dwo.name = "svccod" Then
	dw_cond.object.priceplan[1] = ""
	dw_cond.object.prmtype[1] = ""
	
End If
end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_svc_actorder_1
integer x = 2601
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b1w_reg_svc_actorder_1
integer x = 2601
integer y = 172
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_svc_actorder_1
integer x = 37
integer width = 2551
integer height = 676
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_svc_actorder_1
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_svc_actorder_1
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_svc_actorder_1
integer x = 59
integer y = 1600
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_svc_actorder_1
integer y = 688
integer width = 2843
integer height = 872
string dataobject = "b1dw_reg_svc_actorder"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;Long i
String ls_mainitem_yn

If rowcount = 0 Then
	p_save.TriggerEvent("ue_disable")
End If


For i = 1 To rowcount 
	dw_detail.object.chk[i] = "Y" 
//	If dw_detail.object.mainitem_yn[i] = "Y" Then
//		dw_detail.object.itemcod.Color = RGB(255,0,255)
//		dw_detail.object.itemnm.Color = RGB(255,0,255)
//		dw_detail.object.quota_yn.Color = RGB(255,0,255)
//		dw_detail.object.chk.Color = RGB(255,0,255)
//	Else
//		dw_detail.object.itemcod.Color = RGB(0,0,0)
//		dw_detail.object.itemnm.Color = RGB(0,0,0)
//		dw_detail.object.quota_yn.Color = RGB(0,0,0)
//		dw_detail.object.chk.Color = RGB(0,0,0)
//	End If

This.SetItemStatus(i, 0, Primary!, NotModified!)
Next


end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_svc_actorder_1
integer x = 370
integer y = 1600
boolean enabled = true
end type

