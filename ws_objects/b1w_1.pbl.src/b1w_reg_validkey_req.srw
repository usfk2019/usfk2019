$PBExportHeader$b1w_reg_validkey_req.srw
$PBExportComments$[islim] 인증키요청처리
forward
global type b1w_reg_validkey_req from w_a_reg_m_m
end type
end forward

global type b1w_reg_validkey_req from w_a_reg_m_m
integer width = 4398
integer height = 2124
end type
global b1w_reg_validkey_req b1w_reg_validkey_req

type variables
String is_priceplan		//Price Plan Code
String is_xener
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
public function integer wfi_get_partner (string as_partner)
end prototypes

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

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner
  and partner_type= '0';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

on b1w_reg_validkey_req.create
call super::create
end on

on b1w_reg_validkey_req.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_validkey_req
	Desc.	: 	인증KEY 요청처리
	Ver.	:	
	Date	: 	2004.07.20
	Programer : insook
--------------------------------------------------------------------------*/
Date ld_sysdate
String ls_tmp, ls_ref_desc, ls_name[]
ls_tmp= fs_get_control("B1", "P203", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
is_xener = ls_name[1] //제너용 서비스


ld_sysdate = Date(fdt_get_dbserver_now())

dw_cond.object.reqdt[1] = ld_sysdate


end event

event ue_ok();call super::ue_ok;String ls_reqdt, ls_reqtype, ls_status, ls_req_partner
String ls_where
Long ll_row
String ls_add, ls_modify, ls_cancel
String ls_tmp, ls_name[], ls_ref_desc
String ls_key_status,ls_reqstatus

ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_status   = ls_name[1]   //인증키요청처리상태(요청)

dw_cond.AcceptText()


ls_reqdt = String(dw_cond.object.reqdt[1],'yyyymmdd')
ls_reqtype = Trim(dw_cond.object.reqtype[1])
ls_status = Trim(dw_cond.object.status[1])
ls_req_partner = Trim(dw_cond.object.req_partner[1])


If IsNull(ls_reqdt) Then ls_reqdt = ""
If IsNull(ls_reqtype) Then ls_reqtype = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_req_partner) Then ls_req_partner = ""


IF ls_reqdt <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(validkeyreq.reqdt,'yyyymmdd') <= '" + ls_reqdt + "' "
End If

IF ls_reqtype <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "validkeyreq.reqtype = '" + ls_reqtype + "' "
End If

IF ls_status <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "validkeyreq.status = " + ls_status + " "
End If

IF ls_req_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "validkeyreq.req_partner= '" + ls_req_partner + "' "
End If


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
	return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If


ls_reqstatus = dw_master.object.status[1]


	If ls_key_status = ls_reqstatus Then	
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")		

	Else 
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")				

	End If
	
return
end event

event type integer ue_extra_save();//Save Check
String ls_reqtype, ls_req_status, ls_req_validkey, ls_req_customerid, ls_req_svccod
String ls_req_contractseq, ls_vpassword, ls_req_auth_method
String ls_req_validitem2, ls_req_validitem1, ls_req_validitem3
String ls_req_remark, ls_req_langtype, ls_bef_validkey
String ls_tmp, ls_ref_desc, ls_name[], ls_xener
String ls_vreqno, ls_remark, ls_reqdt, ls_today
String ls_auth_method_stcip, ls_auth_method_both
Dec ld_vreqno
Long ll_rows , i, ll_result, ll_rc
String ls_add, ls_modify, ls_cancel, ls_con_status, ls_fromdt


ls_tmp= fs_get_control("B1", "P500", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_add    = ls_name[1]  //요청Type(추가)
ls_modify = ls_name[2]  //변경
ls_cancel = ls_name[3]  //취소



dw_detail.AcceptText()
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

ls_vreqno         = String(dw_detail.object.validkeyreq_vreqno[1])
ls_reqtype        = dw_detail.object.validkeyreq_reqtype[1]
ls_req_status     = dw_detail.object.validkeyreq_status[1]
ls_req_validkey   = Trim(dw_detail.object.validkeyreq_validkey[1])
ls_reqdt          = String(dw_detail.object.validkeyreq_reqdt[1],'yyyymmdd')
ls_req_customerid = dw_detail.object.validkeyreq_customerid[1]
ls_req_svccod     = dw_detail.object.validkeyreq_svccod[1]
ls_req_contractseq = String(dw_detail.object.validkeyreq_contractseq[1])
ls_vpassword       = dw_detail.object.validkeyreq_vpassword[1]
ls_req_auth_method = dw_detail.object.validkeyreq_auth_method[1]
ls_req_validitem1  = Trim(dw_detail.object.validkeyreq_validitem1[1])  //발신번호
ls_req_validitem2  = Trim(dw_detail.object.validkeyreq_validitem2[1])  //ipaddress
ls_req_validitem3  = Trim(dw_detail.object.validkeyreq_validitem3[1])  //H323ID
ls_req_langtype    = dw_detail.object.validkeyreq_langtype[1]
ls_bef_validkey    = dw_detail.object.validkeyreq_bef_validkey[1]
ls_remark	       = Trim(dw_detail.Object.validkeyreq_remark[1])	//비고
ls_con_status      = dw_detail.object.contractmst_status[1]

//인증방법
ls_auth_method_stcip=LeftA(String(dw_detail.object.validkeyreq_auth_method[1]),5)
ls_auth_method_both = MidA(String(dw_detail.object.validkeyreq_auth_method[1]),7)

ls_today = String(Today(), "yyyymmdd")

//Null Check
If IsNull(ls_reqdt) then ls_reqdt = ""
If IsNull(ls_vpassword) then ls_vpassword = ""
If IsNull(ls_req_auth_method) Then ls_req_auth_method = ""
If IsNull(ls_req_validitem2) Then ls_req_validitem2 = ""
If IsNull(ls_req_validitem3) Then ls_req_validitem3 = ""
If IsNull(ls_req_validitem1) Then ls_req_validitem1 = ""
If IsNull(ls_req_langtype) Then ls_req_langtype = ""
If IsNull(ls_remark) Then ls_remark = ""


If ls_reqdt = "" Then
	f_msg_usr_err(200, Title, "적용요청일자")
	dw_detail.SetFocus()
	dw_detail.SetColumn("validkeyreq_reqdt")
	Return -2
End If


////// 날짜 체크
If ls_reqdt <> "" Then
	If ls_today >ls_reqdt Then
		f_msg_usr_err(210, Title, "적용요청일자는 오늘날짜보다 크거나 같아야합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("validkeyreq_reqdt")
		Return -2
	End If		
End If

//If ls_reqtype = ls_cancel Then	
//	ll_result = b1fi_validkey_fromdt(Title,ls_req_validkey,ls_fromdt)
//	If ls_reqdt < ls_fromdt Then
//		f_msg_usr_err(210, Title, "적용요청일자는 적용시작일 보다 커야 합니다.")
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("validkeyreq_reqdt")
//		Return -2
//	End If		
//End If

If ls_reqtype = ls_add or ls_reqtype = ls_modify Then
		If ls_vpassword = "" Then
			f_msg_usr_err(200, Title, "인증Password")
			dw_detail.SetFocus()
			dw_detail.SetColumn("validkeyreq_vpassword")
			Return -2
		End If

		//xener 서비스일때 인증방법 필수
		ll_result = PosA(ls_req_svccod, ls_xener)
		If ll_result > 0 Then
			If ls_req_auth_method = "" Then
				f_msg_usr_err(200, Title, "인증방법")
				dw_detail.SetFocus()
				dw_detail.SetColumn("validkeyreq_auth_method")
				Return -2	
			End If
		End If
		
		
		Choose Case ls_auth_method_stcip
			Case "STCIP"         //소분류
				If ls_req_validitem2 = "" Then
					f_msg_usr_err(200, Title, "IPADDRESS")
					dw_detail.SetFocus()
					dw_detail.SetColumn("validkeyreq_validitem2")
					Return -2	
				End If
				Choose Case ls_auth_method_both
					Case "BOTH"
						If ls_req_validitem3 = "" Then
							f_msg_usr_err(200, Title, "H323ID")
							dw_detail.SetFocus()
							dw_detail.SetColumn("validkeyreq_validitem3")
							Return -2	
						End If
						
					Case "H323ID"
						If ls_req_validitem3 = "" Then
							f_msg_usr_err(200, Title, "H323ID")
							dw_detail.SetFocus()
							dw_detail.SetColumn("validkeyreq_validitem3")
							Return -2	
						End If
				End Choose
						
			Case "DYNIP"
				Choose Case ls_auth_method_both
					Case "BOTH"
						If ls_req_validitem3 = "" Then
							f_msg_usr_err(200, Title, "H323ID")
							dw_detail.SetFocus()
							dw_detail.SetColumn("validkeyreq_validitem3")
							Return -2	
						End If
						
					Case "H323ID"
						If ls_req_validitem3 = "" Then
							f_msg_usr_err(200, Title, "H323ID")
							dw_detail.SetFocus()
							dw_detail.SetColumn("validkeyreq_validitem3")
							Return -2	
						End If
				End Choose
		End Choose
	End If

b1u_dbmgr10 lu_dbmgr
lu_dbmgr = CREATE b1u_dbmgr10

If ls_reqtype = ls_add Then
	lu_dbmgr.is_caller = "b1w_reg_validkey_req_add%save"
	lu_dbmgr.is_title  = Title
	lu_dbmgr.idw_data[1] = dw_detail
	lu_dbmgr.idw_data[2] = dw_master
	lu_dbmgr.is_data[1] = ls_vreqno
	lu_dbmgr.is_data[2] = ls_reqtype
	lu_dbmgr.is_data[3] = ls_req_status
	lu_dbmgr.is_data[4] = ls_req_validkey 
	lu_dbmgr.is_data[5] = ls_reqdt
	lu_dbmgr.is_data[6] = ls_req_customerid
	lu_dbmgr.is_data[7] = ls_req_svccod
	lu_dbmgr.is_data[8] = ls_req_contractseq 
	lu_dbmgr.is_data[9] = ls_vpassword
	lu_dbmgr.is_data[10] = ls_req_auth_method 
	lu_dbmgr.is_data[11] = ls_req_validitem1
	lu_dbmgr.is_data[12] = ls_req_validitem2
	lu_dbmgr.is_data[13] = ls_req_validitem3
	lu_dbmgr.is_data[14] = ls_req_langtype
	lu_dbmgr.is_data[15] = ls_bef_validkey
	lu_dbmgr.is_data[16] = ls_remark

	lu_dbmgr.uf_prc_db()
	ll_rc = lu_dbmgr.ii_rc

ElseIf ls_reqtype = ls_modify Then
	lu_dbmgr.is_caller = "b1w_reg_validkey_req_modify%save"
	lu_dbmgr.is_title  = Title
	lu_dbmgr.idw_data[1] = dw_detail
	lu_dbmgr.idw_data[2] = dw_master
	lu_dbmgr.is_data[1] = ls_vreqno
	lu_dbmgr.is_data[2] = ls_reqtype
	lu_dbmgr.is_data[3] = ls_req_status
	lu_dbmgr.is_data[4] = ls_req_validkey 
	lu_dbmgr.is_data[5] = ls_reqdt
	lu_dbmgr.is_data[6] = ls_req_customerid
	lu_dbmgr.is_data[7] = ls_req_svccod
	lu_dbmgr.is_data[8] = ls_req_contractseq 
	lu_dbmgr.is_data[9] = ls_vpassword
	lu_dbmgr.is_data[10] = ls_req_auth_method 
	lu_dbmgr.is_data[11] = ls_req_validitem1
	lu_dbmgr.is_data[12] = ls_req_validitem2
	lu_dbmgr.is_data[13] = ls_req_validitem3
	lu_dbmgr.is_data[14] = ls_req_langtype
	lu_dbmgr.is_data[15] = ls_bef_validkey
	lu_dbmgr.is_data[16] = ls_remark

	lu_dbmgr.uf_prc_db_01()
	ll_rc = lu_dbmgr.ii_rc	
	
ElseIf ls_reqtype = ls_cancel Then
	lu_dbmgr.is_caller = "b1w_reg_validkey_req_cancel%save"
	lu_dbmgr.is_title  = Title
	lu_dbmgr.idw_data[1] = dw_detail
	lu_dbmgr.idw_data[2] = dw_master

	lu_dbmgr.uf_prc_db_02()
	ll_rc = lu_dbmgr.ii_rc	
	
End If


If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)		
	Destroy lu_dbmgr
	Return ll_rc
End If


dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)


Destroy lu_dbmgr

//If dw_detail.GetItemStatus(1, 0, Primary!) = DataModified! THEN
//	dw_detail.object.contractmst_updt_user[1] = gs_user_id
//	dw_detail.object.contractmst_updtdt[1] = fdt_get_dbserver_now()
//End If
	
Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
String ls_activedt, ls_bil_fromdt, ls_contractno, ls_contractseq
String ls_req_partner, ls_reqtype, ls_status
Date ld_reqdt
String ls_add, ls_modify, ls_cancel, ls_bef_validkey, ls_req_validkey
String ls_tmp, ls_name[], ls_ref_desc

Long ll_row
Int li_rc

ls_tmp= fs_get_control("B1", "P500", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_add    = ls_name[1]  //요청Type(추가)
ls_modify = ls_name[2]  //변경
ls_cancel = ls_name[3]  //취소

Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

ls_reqtype = dw_detail.object.validkeyreq_reqtype[1]
ls_bef_validkey = dw_detail.object.validkeyreq_bef_validkey[1]
ls_req_validkey = dw_detail.object.validkeyreq_validkey[1]


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
	
//	If ls_modify = ls_reqtype Then
//		f_msg_info(3000,This.Title,ls_bef_validkey+" 에서 "+ls_req_validkey+" 로 변경되었습니다.")
//	End If

ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

//재정의

ld_reqdt = dw_cond.object.reqdt[1]
ls_reqtype = dw_cond.object.reqtype[1]
ls_status = Trim(dw_cond.object.status[1])
ls_req_partner = Trim(dw_cond.object.req_partner[1])

//Reset
Trigger Event ue_reset()
dw_cond.object.reqdt[1] =ld_reqdt  
dw_cond.object.reqtype[1] = ls_reqtype 
dw_cond.object.status[1] = ls_status 
dw_cond.object.req_partner[1] = ls_req_partner
Trigger Event ue_ok()



Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
Date ld_sysdate
String ls_reqtype, ls_status, ls_req_partner

ld_sysdate = Date(fdt_get_dbserver_now())

dw_cond.object.reqdt[1] =ld_sysdate
dw_cond.object.reqtype[1] = ""
dw_cond.object.status[1] = ""
dw_cond.object.req_partner[1] = ""

dw_cond.SetColumn("reqdt")

dw_cond.SetRedraw(true)
dw_master.SetRedraw(true)

Return 0 
end event

event type integer ue_extra_delete();Long ll_result, ll_row, ll_rc
Dec ldc_vreqno
String ls_tmp, ls_ref_desc, ls_name[]
String ls_add, ls_modify, ls_cancel,ls_reqtype
b1u_dbmgr9 lu_dbmgr

ls_tmp= fs_get_control("B1", "P500", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_add    = ls_name[1]  //요청Type(추가)
ls_modify = ls_name[2]  //변경
ls_cancel = ls_name[3]  //취소


dw_master.AcceptText()

ll_row = dw_master.getSelectedRow(0)

ldc_vreqno = dw_master.object.vreqno[ll_row]
ls_reqtype = dw_master.object.reqtype[ll_row]

ll_result = Messagebox(This.title +"해지처리", "요청내역을 취소하시겠습니까?", Question!,YesNo!)


If ls_cancel = ls_reqtype Then
	If ll_result = 2 Then
		RollBack;
		return -1
	ElseIf ll_result = 1 Then		
		b1fi_validkeyreq_delete(This.Title, ldc_vreqno)
	End If
ElseIf ls_add = ls_reqtype or ls_modify = ls_reqtype  Then
	If ll_result = 2 Then
		Rollback;
		return -1
	ElseIf ll_result = 1 Then
		b1fi_validkeyreq_delete(This.Title, ldc_vreqno)		

		lu_dbmgr = CREATE b1u_dbmgr9
		lu_dbmgr.is_caller = "b1w_reg_validkey_req%delete"
		lu_dbmgr.is_title  = Title
		lu_dbmgr.idw_data[1] = dw_detail
		lu_dbmgr.idw_data[2] = dw_master
		lu_dbmgr.uf_prc_db_03()
		ll_rc = lu_dbmgr.ii_rc		
			
	End If
End If
		
If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)		
	Destroy lu_dbmgr
	Return ll_rc
End If


dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)


Destroy lu_dbmgr		


return 1
end event

event type integer ue_delete();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
String ls_activedt, ls_bil_fromdt, ls_contractno, ls_contractseq
String ls_req_partner, ls_reqtype, ls_status
Date ld_reqdt
String ls_add, ls_modify, ls_cancel, ls_bef_validkey, ls_req_validkey
String ls_tmp, ls_name[], ls_ref_desc

Long ll_row
Int li_rc

ls_tmp= fs_get_control("B1", "P500", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_add    = ls_name[1]  //요청Type(추가)
ls_modify = ls_name[2]  //변경
ls_cancel = ls_name[3]  //취소

Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

ls_reqtype = dw_detail.object.validkeyreq_reqtype[1]
ls_bef_validkey = dw_detail.object.validkeyreq_bef_validkey[1]
ls_req_validkey = dw_detail.object.validkeyreq_validkey[1]


li_rc = This.Trigger Event ue_extra_delete()

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
	

ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

//재정의

ld_reqdt = dw_cond.object.reqdt[1]
ls_reqtype = dw_cond.object.reqtype[1]
ls_status = Trim(dw_cond.object.status[1])
ls_req_partner = Trim(dw_cond.object.req_partner[1])

//Reset
Trigger Event ue_reset()
dw_cond.object.reqdt[1] =ld_reqdt  
dw_cond.object.reqtype[1] = ls_reqtype 
dw_cond.object.status[1] = ls_status 
dw_cond.object.req_partner[1] = ls_req_partner
Trigger Event ue_ok()



Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_validkey_req
integer x = 55
integer width = 2094
integer height = 204
string dataobject = "b1dw_cnd_reg_validkeyreq"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_validkey_req
integer x = 2304
integer y = 64
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_validkey_req
integer x = 2606
integer y = 64
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_validkey_req
integer width = 2176
integer height = 276
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_validkey_req
integer x = 23
integer y = 300
integer width = 4293
integer height = 692
string dataobject = "b1dw_inq_reg_validkeyreq"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.vreqno_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::rowfocuschanged;call super::rowfocuschanged;String ls_tmp, ls_ref_desc, ls_name[], ls_status,ls_reqstatus

ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_status   = ls_name[1]   //인증키요청처리상태(요청)
			
If currentrow > 0 Then
	ls_reqstatus = dw_master.object.status[currentrow]


	If ls_status = ls_reqstatus Then	
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")		
	
	Else 
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")				
	
	End If
End If

return 0
	
	




end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_validkey_req
integer x = 23
integer y = 1080
integer width = 4288
integer height = 784
string dataobject = "b1dw_reg_validkeyreq_add"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_vreq_no, ls_reqstatus, ls_status
String ls_add, ls_modify, ls_cancel, ls_req_type, ls_svccod
String ls_name[], ls_tmp, ls_ref_desc
String ls_auth_method_stcip,ls_auth_method_both
Long ll_row, ll_result
Dec ldc_vreq_no
DateTime ldt_termdt

ldc_vreq_no = dw_master.object.vreqno[al_select_row]
ls_vreq_no = string(ldc_vreq_no)
If IsNull(ldc_vreq_no) Then ls_vreq_no = ""

ls_status = Trim(dw_master.object.status[al_select_row]) 
ls_req_type = Trim(dw_master.object.reqtype[al_select_row])
ls_svccod = Trim(dw_master.object.svccod[al_select_row])

ls_tmp= fs_get_control("B1", "P501", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_reqstatus = ls_name[1] //요청상태(요청)

ls_tmp= fs_get_control("B1", "P500", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_add    = ls_name[1]  //요청Type(추가)
ls_modify = ls_name[2]  //변경
ls_cancel = ls_name[3]  //취소



ll_result = PosA(ls_svccod, is_xener)

If ls_status = ls_reqstatus Then
	If ls_req_type = ls_add Then		
		dw_detail.DataObject = "b1dw_reg_validkeyreq_add"
		If ll_result <> 0 Then
			dw_detail.object.validkeyreq_auth_method.protect=0
			dw_detail.object.validkeyreq_auth_method.background.color = RGB(108,147,137)
			dw_detail.object.validkeyreq_auth_method.color = RGB(255,255,255)

			ls_auth_method_stcip=LeftA(String(dw_detail.object.validkeyreq_auth_method[1]),5)
			ls_auth_method_both = MidA(String(dw_detail.object.validkeyreq_auth_method[1]),7)
				
			Choose Case ls_auth_method_stcip
				Case "STCIP"         //소분류
						dw_detail.object.validkeyreq_validitem2.background.color = RGB(108,147,137)
						dw_detail.object.validkeyreq_validitem2.color=RGB(255,255,255)		
					Choose Case ls_auth_method_both
						Case "BOTH"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)								
						Case "H323ID"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)	
						CASE ELSE
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,255,255)
							dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)	
					End Choose
							
				Case "DYNIP"
						dw_detail.object.validkeyreq_validitem2.background.color = RGB(255,255,255)
						dw_detail.object.validkeyreq_validitem2.color=RGB(0,0,0)		
					Choose Case ls_auth_method_both
						Case "BOTH"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)								
						Case "H323ID"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)	
						CASE ELSE
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,255,255)
							dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)	
					End Choose									
			End Choose

		ElseIf ll_result = 0 Then	
			dw_detail.object.validkeyreq_auth_method.protect=1
			dw_detail.object.validkeyreq_auth_method.background.color = RGB(255,251,240)
			dw_detail.object.validkeyreq_auth_method.color = RGB(0,0,0)
			dw_detail.object.validkeyreq_validitem2.protect=1
			dw_detail.object.validkeyreq_validitem2.background.color = RGB(255,251,240)
			dw_detail.object.validkeyreq_validitem2.color=RGB(0,0,0)		
			dw_detail.object.validkeyreq_validitem3.protect=1
			dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,251,240)
			dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)		

		End If
		
	ElseIf ls_req_type = ls_modify Then
		dw_detail.DataObject = "b1dw_reg_validkeyreq_modify"
		If ll_result <> 0 Then
			dw_detail.object.validkeyreq_auth_method.protect=0
			dw_detail.object.validkeyreq_auth_method.background.color = RGB(108,147,137)
			dw_detail.object.validkeyreq_auth_method.color = RGB(255,255,255)

			ls_auth_method_stcip=LeftA(String(dw_detail.object.validkeyreq_auth_method[1]),5)
			ls_auth_method_both = MidA(String(dw_detail.object.validkeyreq_auth_method[1]),7)
				
			Choose Case ls_auth_method_stcip
				Case "STCIP"         //소분류
						dw_detail.object.validkeyreq_validitem2.background.color = RGB(108,147,137)
						dw_detail.object.validkeyreq_validitem2.color=RGB(255,255,255)		
					Choose Case ls_auth_method_both
						Case "BOTH"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)								
						Case "H323ID"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)	
						CASE ELSE
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,255,255)
							dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)	
					End Choose
							
				Case "DYNIP"
						dw_detail.object.validkeyreq_validitem2.background.color = RGB(255,255,255)
						dw_detail.object.validkeyreq_validitem2.color=RGB(0,0,0)		
					Choose Case ls_auth_method_both
						Case "BOTH"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)								
						Case "H323ID"
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
							dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)	
						CASE ELSE
							dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,255,255)
							dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)	
					End Choose									
			End Choose

		ElseIf ll_result = 0 Then	
			dw_detail.object.validkeyreq_auth_method.protect=1
			dw_detail.object.validkeyreq_auth_method.background.color = RGB(255,251,240)
			dw_detail.object.validkeyreq_auth_method.color = RGB(0,0,0)
			dw_detail.object.validkeyreq_validitem2.protect=1
			dw_detail.object.validkeyreq_validitem2.background.color = RGB(255,251,240)
			dw_detail.object.validkeyreq_validitem2.color=RGB(0,0,0)		
			dw_detail.object.validkeyreq_validitem3.protect=1
			dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,251,240)
			dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)		

		End If	
	ElseIf ls_req_type = ls_cancel Then
		dw_detail.DataObject = "b1dw_reg_validkeyreq_cancel"		
	End If
Else
	dw_detail.DataObject="b1dw_reg_validkeyreq_1"	
End If


dw_detail.SetTransObject(SQLCA)
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve(ls_vreq_no)
If ll_row < 0 Then
f_msg_usr_err(2100, Title, "Retrieve()")
Return -2
End If

dw_detail.SetRedraw(true)

If ls_status = ls_reqstatus Then	
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")		

Else 
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")				
End If

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_auth_method_stcip, ls_auth_method_both

ls_auth_method_stcip=LeftA(String(dw_detail.object.validkeyreq_auth_method[1]),5)
ls_auth_method_both = MidA(String(dw_detail.object.validkeyreq_auth_method[1]),7)


Choose Case dwo.Name
	Case "validkeyreq_auth_method"
		Choose Case ls_auth_method_stcip
			Case "STCIP"         //소분류
					dw_detail.object.validkeyreq_validitem2.background.color = RGB(108,147,137)
					dw_detail.object.validkeyreq_validitem2.color=RGB(255,255,255)		
				Choose Case ls_auth_method_both
					Case "BOTH"
						dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
						dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)								
					Case "H323ID"
						dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
						dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)	
					CASE ELSE
						dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,255,255)
						dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)	
				End Choose
						
			Case "DYNIP"
					dw_detail.object.validkeyreq_validitem2.background.color = RGB(255,255,255)
					dw_detail.object.validkeyreq_validitem2.color=RGB(0,0,0)		
				Choose Case ls_auth_method_both
					Case "BOTH"
						dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
						dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)								
					Case "H323ID"
						dw_detail.object.validkeyreq_validitem3.background.color = RGB(108,147,137)
						dw_detail.object.validkeyreq_validitem3.color=RGB(255,255,255)	
					CASE ELSE
						dw_detail.object.validkeyreq_validitem3.background.color = RGB(255,255,255)
						dw_detail.object.validkeyreq_validitem3.color=RGB(0,0,0)	
				End Choose					
	
   	End Choose
End Choose
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_validkey_req
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_validkey_req
integer x = 370
integer y = 1892
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_validkey_req
integer x = 41
integer y = 1896
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_validkey_req
integer x = 695
integer y = 1888
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_validkey_req
integer x = 14
integer y = 1016
end type

