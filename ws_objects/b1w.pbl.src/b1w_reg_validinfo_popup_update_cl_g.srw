$PBExportHeader$b1w_reg_validinfo_popup_update_cl_g.srw
$PBExportComments$[kem] 인증정보 update popup window(tab3)
forward
global type b1w_reg_validinfo_popup_update_cl_g from w_a_reg_m
end type
end forward

global type b1w_reg_validinfo_popup_update_cl_g from w_a_reg_m
integer width = 3392
integer height = 1164
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
end type
global b1w_reg_validinfo_popup_update_cl_g b1w_reg_validinfo_popup_update_cl_g

type variables
String is_cusid, is_cusnm, is_pgm_id, is_svctype, is_svccod, is_priceplan
String is_status_1, is_status_2, is_fromdt, is_validkey, is_SP_code
String is_Xener_svccod[],is_xener_svc



end variables

on b1w_reg_validinfo_popup_update_cl_g.create
call super::create
end on

on b1w_reg_validinfo_popup_update_cl_g.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_validinfo_popup_update_cl_g
	Desc	: 	고객정보등록(tab3:인증정보)- update popup
	Ver.	:	1.0
	Date	: 	2005.03.17
	programer : ohj
-------------------------------------------------------------------------*/
Long ll_row
String ls_where, ls_ref_desc, ls_temp, ls_result[]

is_cusid = ""
is_cusnm = ""

//window 중앙에
f_center_window(b1w_reg_validinfo_popup_update_cl_g)

is_svctype = iu_cust_msg.is_data[1]    //svctype
is_pgm_id = iu_cust_msg.is_data[2]     //프로그램 id
is_validkey = iu_cust_msg.is_data[3]   //validkey
is_fromdt = iu_cust_msg.is_data[4]     //fromdt

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

//Serial Phone 서비스코드
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P200", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_result[])
is_SP_code = ls_result[2]

ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   //Xener GateKeeper 연동 svccode

//차후 선불/선불카드 추가시 다르게 감...
//IF is_svctype = '1' Then
//	dw_detail.dataObject = "b1dw_reg_validinfo_popup_update_1"
//	dw_detail.SetTransObject(SQLCA)
//Elseif is_svctype = '2' Then
//	dw_detail.dataObject = "b1dw_reg_validinfo_popup_update_2"
//	dw_detail.SetTransObject(SQLCA)
//Elseif is_svctype = '0' Then
//	dw_detail.dataObject = "b1dw_reg_validinfo_popup_update_0"
//	dw_detail.SetTransObject(SQLCA)	
//End If

//retrieve
ls_where = " validkey = '" + is_validkey + "' And to_char(fromdt,'yyyymmdd') = '" + is_fromdt + "' And svctype = '" + is_svctype + "'"  

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If

//dw_cond.Enabled = True
//dw_cond.SetFocus()
end event

event ue_ok();call super::ue_ok;String ls_where
Long ll_row

is_svccod = Trim(dw_cond.object.svccod[1])
is_priceplan = Trim(dw_cond.object.priceplan[1])
is_svctype = Trim(dw_cond.object.svctype[1])

If IsNull(is_svccod) Then is_svccod = ""
If IsNull(is_svctype) Then is_svctype = ""
If IsNull(is_priceplan) Then is_priceplan = ""

If is_svccod = "" Then
	f_msg_info(200, Title, "서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

If is_priceplan = "" Then
	f_msg_info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
	Return
End If

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

//IF is_svctype = '1' Then
//	dw_detail.dataObject = "b1dw_reg_validinfo_popup_update_1"
//	dw_detail.SetTransObject(SQLCA)
//Elseif is_svctype = '2' Then
//	dw_detail.dataObject = "b1dw_reg_validinfo_popup_update_2"
//	dw_detail.SetTransObject(SQLCA)
//Elseif is_svctype = '0' Then
//	dw_detail.dataObject = "b1dw_reg_validinfo_popup_update_0"
//	dw_detail.SetTransObject(SQLCA)	
//End If

TriggerEvent('ue_insert')

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_disable")

dw_cond.Enabled = False
dw_detail.SetFocus()
end event

event resize;call super::resize;SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
else
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_validkey, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
String ls_cid, ls_pricemodel, ls_pid
String ls_fromdt, ls_todt
Long ll_row, ll_cnt

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 

ls_fromdt = string(dw_detail.object.fromdt[1],'yyyymmdd')
ls_todt = string(dw_detail.object.todt[1],'yyyymmdd')
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) or ls_todt = "" Then ls_todt = '99991231'

Choose Case is_svctype
	Case '1'  //후불

		ls_validkey = dw_detail.object.validkey[1]
		ls_svccod = dw_detail.object.svccod[1]
		ls_priceplan = dw_detail.object.priceplan[1]
		ls_svctype = dw_detail.object.svctype[1]
		ls_gkid = dw_detail.object.gkid[1]
		ls_cid  = dw_detail.object.validitem1[1]
		
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_cid) Then ls_cid = ""


		If ls_validkey = "" Then
			f_msg_usr_err(200, Title, "인증 Key")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("validkey")
			Return - 1
		End If

		If ls_svccod = "" Then
			f_msg_usr_err(200, Title, "서비스코드")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svccod")
			Return - 1
		End If
		
		If ls_priceplan = "" Then
			f_msg_usr_err(200, Title, "가격정책")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("priceplan")
			Return - 1
		End If		

		If ls_svctype = "" Then
			f_msg_usr_err(200, Title, "서비스 유형")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svctype")
			Return - 1
		End If		

	Case '0' //선불
		ls_validkey = dw_detail.object.validkey[1]
		ls_svccod = dw_detail.object.svccod[1]
		ls_priceplan = dw_detail.object.priceplan[1]
		ls_svctype = dw_detail.object.svctype[1]
		ls_cid  = dw_detail.object.validitem1[1]

		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_cid) Then ls_cid = ""			
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, Title, "인증 Key")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("validkey")
			Return - 1
		End If

		If ls_svccod = "" Then
			f_msg_usr_err(200, Title, "서비스코드")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svccod")
			Return - 1
		End If
		
		If ls_priceplan = "" Then
			f_msg_usr_err(200, Title, "가격정책")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("priceplan")
			Return - 1
		End If		

		If ls_svctype = "" Then
			f_msg_usr_err(200, Title, "서비스 유형")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svctype")
			Return - 1
		End If		

	Case '2' //선불카드
		ls_validkey = dw_detail.object.validkey[1]
		ls_svccod = dw_detail.object.svccod[1]
		ls_priceplan = dw_detail.object.priceplan[1]
		ls_svctype = dw_detail.object.svctype[1]
		ls_pid = dw_detail.object.pid[1]
		ls_cid  = dw_detail.object.validitem1[1]
		
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_pid) Then ls_pid = ""
		If IsNull(ls_cid) Then ls_cid = ""
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, Title, "인증 Key")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("validkey")
			Return - 1
		End If

		If ls_svccod = "" Then
			f_msg_usr_err(200, Title, "서비스코드")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svccod")
			Return - 1
		End If
		
		If ls_priceplan = "" Then
			f_msg_usr_err(200, Title, "가격정책")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("priceplan")
			Return - 1
		End If		

		If ls_svctype = "" Then
			f_msg_usr_err(200, Title, "서비스 유형")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svctype")
			Return - 1
		End If		

		If ls_pid = "" Then
			f_msg_usr_err(200, Title, "PIN #")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("pid")
			Return - 1
		End If		
		
End Choose	

//자기자신을 빼고 적용시작일과 적용종료일의 중복을 막는다.
select count(*)
  into :ll_cnt
 from validinfo
where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
                to_char(fromdt,'yyyymmdd') <= :ls_todt)  or
		  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
		   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
   and	validkey = :ls_validkey
   and  to_char(fromdt,'yyyymmdd') <> :is_fromdt;
		  
If sqlca.sqlcode < 0 Then
	f_msg_sql_err(title,"Select validinfo (count)")				
	Return -1
End If

If ll_cnt > 0 Then
	f_msg_usr_err(9000, Title, "인증 Key:" + ls_validkey + "에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
	return -1
End if

//Log 정보
If dw_detail.GetItemStatus(1, 0, Primary!) = DataModified! THEN
	dw_detail.object.pgm_id[1] = is_pgm_id
	dw_detail.object.updt_user[1] = gs_user_id
	dw_detail.object.updtdt[1] = fdt_get_dbserver_now()
End If


// 2005.02.21 ohj 인증방법 체크 , 위 체크 사항중 필요없는 부분 삭제처리.. 
String ls_vpassword, ls_auth_method, ls_ip_address, ls_h323id

ls_auth_method = dw_detail.object.auth_method[1]
ls_vpassword   = dw_detail.object.vpassword[1]
ls_ip_address  = dw_detail.object.validitem2[1]
ls_h323id      = dw_detail.object.validitem3[1]

If IsNull(ls_auth_method) Then ls_auth_method = ""
If IsNull(ls_vpassword)   Then ls_vpassword   = ""
If IsNull(ls_ip_address)  Then ls_ip_address  = ""				
If IsNull(ls_h323id)      Then ls_h323id      = ""

//선불제, 후불이면서.. 제너 연동일 때만
If is_svctype = '0' Or is_svctype = '1' Then
	If is_xener_svc = 'Y' Then
	
		If ls_auth_method = "" Then
			f_msg_usr_err(200, Title, "인증방법")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("auth_method")
			Return - 1
		End If		
		
		If LeftA(ls_auth_method,1) = 'S' Then
			If ls_ip_address = "" Then
				f_msg_usr_err(200, Title, "IP ADDRESS")
				dw_detail.SetRow(1)
				dw_detail.ScrollToRow(1)
				dw_detail.SetColumn("validitem2")
				Return - 1
			End If		
		End if
		
		If MidA(ls_auth_method,7,1) = 'B' Then
			If ls_h323id = "" Then
				f_msg_usr_err(200, Title, "H323ID")
				dw_detail.SetRow(1)
				dw_detail.ScrollToRow(1)
				dw_detail.SetColumn("validitem3")
				Return - 1
			End If		
		End IF
		
		If LeftA(ls_auth_method,1) = 'P' Then  
			If ls_vpassword = "" Then
				f_msg_usr_err(200, Title, "password")
				dw_detail.SetRow(1)
				dw_detail.ScrollToRow(1)
				dw_detail.SetColumn("vpassword")
				Return - 1
			End If		
		End IF
	
//	//제너와 연동 no
//	Else
//		If ls_auth_method = "" Then
//			f_msg_usr_err(200, Title, "Method of authentication")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("auth_method")
//			Return - 1
//		End If	
//		
//		//패스워드 인증
//		If left(ls_auth_method,1) = 'P' Then  
//			If ls_vpassword = "" Then
//				f_msg_usr_err(200, Title, "password")
//				dw_detail.SetRow(1)
//				dw_detail.ScrollToRow(1)
//				dw_detail.SetColumn("vpassword")
//				Return - 1
//			End If		
//		End IF	
		
	End IF
	
End If

Return 0 
//ohj 수정전... 
//String ls_validkey, ls_vpassword, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
//String ls_cid, ls_auth_method, ls_ip_address, ls_h323id, ls_pricemodel, ls_pid
//String ls_fromdt, ls_todt
//Long ll_row, ll_cnt
//
//ll_row = dw_detail.RowCount()
//If ll_row = 0 Then Return 0 
//
//ls_fromdt = string(dw_detail.object.fromdt[1],'yyyymmdd')
//ls_todt = string(dw_detail.object.todt[1],'yyyymmdd')
//If IsNull(ls_fromdt) Then ls_fromdt = ""
//If IsNull(ls_todt) or ls_todt = "" Then ls_todt = '99991231'
//
//Choose Case is_svctype
//	Case '1'  //후불
//
//		ls_validkey = dw_detail.object.validkey[1]
//		ls_vpassword = dw_detail.object.vpassword[1]
//		ls_svccod = dw_detail.object.svccod[1]
//		ls_priceplan = dw_detail.object.priceplan[1]
//		ls_svctype = dw_detail.object.svctype[1]
//		ls_gkid = dw_detail.object.gkid[1]
//		ls_cid  = dw_detail.object.validitem1[1]
//		ls_auth_method = dw_detail.object.auth_method[1]
//		If IsNull(ls_validkey) Then ls_validkey = ""
//		If IsNull(ls_vpassword) Then ls_vpassword = ""
//		If IsNull(ls_svccod) Then ls_svccod = ""
//		If IsNull(ls_priceplan) Then ls_priceplan = ""
//		If IsNull(ls_svctype) Then ls_svctype = ""
//		If IsNull(ls_gkid) Then ls_gkid = ""
//		If IsNull(ls_cid) Then ls_cid = ""
//		If IsNull(ls_auth_method) Then ls_auth_method = ""		
//		ls_ip_address = dw_detail.object.validitem2[1]
//		If IsNull(ls_ip_address) Then ls_ip_address = ""				
//		ls_h323id = dw_detail.object.validitem3[1]
//		If IsNull(ls_h323id) Then ls_h323id = ""							
//
//
//		If ls_validkey = "" Then
//			f_msg_usr_err(200, Title, "Authorization Code")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("validkey")
//			Return - 1
//		End If
//
//		If ls_vpassword = "" Then
//			f_msg_usr_err(200, Title, "Authorization Password")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("vpassword")
//			Return - 1
//		End If
//		
//		If ls_svccod = "" Then
//			f_msg_usr_err(200, Title, "Service Code")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("svccod")
//			Return - 1
//		End If
//		
//		If ls_priceplan = "" Then
//			f_msg_usr_err(200, Title, "Price Plan")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("priceplan")
//			Return - 1
//		End If		
//
//		If ls_svctype = "" Then
//			f_msg_usr_err(200, Title, "Service Type")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("svctype")
//			Return - 1
//		End If		
//
////		If ls_cusnm = "" Then
////			f_msg_usr_err(200, Title, "고객명")
////			dw_detail.SetRow(1)
////			dw_detail.ScrollToRow(1)
////			dw_detail.SetColumn("validitem1")
////			Return - 1
////		End If		
//
//		If is_xener_svc = 'Y' Then
//
////			If ls_gkid = "" Then
////				f_msg_usr_err(200, Title, "GKID")
////				dw_detail.SetRow(1)
////				dw_detail.ScrollToRow(1)
////				dw_detail.SetColumn("gkid")
////				Return - 1
////			End If		
//			
//			If ls_auth_method = "" Then
//				f_msg_usr_err(200, Title, "Method of authentication")
//				dw_detail.SetRow(1)
//				dw_detail.ScrollToRow(1)
//				dw_detail.SetColumn("auth_method")
//				Return - 1
//			End If		
//			
//			If left(ls_auth_method,1) = 'S' Then
//				If ls_ip_address = "" Then
//					f_msg_usr_err(200, Title, "IP ADDRESS")
//					dw_detail.SetRow(1)
//					dw_detail.ScrollToRow(1)
//					dw_detail.SetColumn("validitem2")
//					Return - 1
//				End If		
//			End if
//			
//			If mid(ls_auth_method,7,1) <> 'E' Then
//				If ls_h323id = "" Then
//					f_msg_usr_err(200, Title, "H323ID")
//					dw_detail.SetRow(1)
//					dw_detail.ScrollToRow(1)
//					dw_detail.SetColumn("validitem3")
//					Return - 1
//				End If		
//			End IF
//		End IF
//		
//	Case '0' //선불
//		ls_validkey = dw_detail.object.validkey[1]
//		ls_vpassword = dw_detail.object.vpassword[1]
//		ls_svccod = dw_detail.object.svccod[1]
//		ls_priceplan = dw_detail.object.priceplan[1]
//		ls_svctype = dw_detail.object.svctype[1]
//		ls_cid  = dw_detail.object.validitem1[1]
//		ls_auth_method = dw_detail.object.auth_method[1]
//		
//		If IsNull(ls_validkey) Then ls_validkey = ""
//		If IsNull(ls_vpassword) Then ls_vpassword = ""
//		If IsNull(ls_svccod) Then ls_svccod = ""
//		If IsNull(ls_priceplan) Then ls_priceplan = ""
//		If IsNull(ls_svctype) Then ls_svctype = ""
//		If IsNull(ls_cid) Then ls_cid = ""
//		If IsNull(ls_auth_method) Then ls_auth_method = ""
//		ls_ip_address = dw_detail.object.validitem2[1]
//		If IsNull(ls_ip_address) Then ls_ip_address = ""				
//		ls_h323id = dw_detail.object.validitem3[1]
//		If IsNull(ls_h323id) Then ls_h323id = ""							
//		
//		If ls_validkey = "" Then
//			f_msg_usr_err(200, Title, "Authorization Code")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("validkey")
//			Return - 1
//		End If
//
//		If ls_vpassword = "" Then
//			f_msg_usr_err(200, Title, "Authorization Password")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("vpassword")
//			Return - 1
//		End If
//		
//		If ls_svccod = "" Then
//			f_msg_usr_err(200, Title, "Service Code")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("svccod")
//			Return - 1
//		End If
//		
//		If ls_priceplan = "" Then
//			f_msg_usr_err(200, Title, "Price Plan")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("priceplan")
//			Return - 1
//		End If		
//
//		If ls_svctype = "" Then
//			f_msg_usr_err(200, Title, "Service Type")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("svctype")
//			Return - 1
//		End If		
//
//		If is_xener_svc = 'Y' Then
//			
//			If ls_auth_method = "" Then
//				f_msg_usr_err(200, Title, "Method of authentication")
//				dw_detail.SetRow(1)
//				dw_detail.ScrollToRow(1)
//				dw_detail.SetColumn("auth_method")
//				Return - 1
//			End If		
//			
//			If left(ls_auth_method,1) = 'S' Then
//				If ls_ip_address = "" Then
//					f_msg_usr_err(200, Title, "IP ADDRESS")
//					dw_detail.SetRow(1)
//					dw_detail.ScrollToRow(1)
//					dw_detail.SetColumn("validitem2")
//					Return - 1
//				End If		
//			End if
//			
//			If mid(ls_auth_method,7,1) <> 'E' Then
//				If ls_h323id = "" Then
//					f_msg_usr_err(200, Title, "H323ID")
//					dw_detail.SetRow(1)
//					dw_detail.ScrollToRow(1)
//					dw_detail.SetColumn("validitem3")
//					Return - 1
//				End If		
//			End IF
//		End IF
//		
//	Case '2' //선불카드
//		ls_validkey = dw_detail.object.validkey[1]
//		ls_svccod = dw_detail.object.svccod[1]
//		ls_priceplan = dw_detail.object.priceplan[1]
//		ls_svctype = dw_detail.object.svctype[1]
//		ls_pid = dw_detail.object.pid[1]
//		ls_cid  = dw_detail.object.validitem1[1]
//		ls_auth_method = dw_detail.object.auth_method[1]
//		
//		If IsNull(ls_auth_method) Then ls_auth_method = ""
//		If IsNull(ls_validkey) Then ls_validkey = ""
//		If IsNull(ls_vpassword) Then ls_vpassword = ""
//		If IsNull(ls_svccod) Then ls_svccod = ""
//		If IsNull(ls_priceplan) Then ls_priceplan = ""
//		If IsNull(ls_svctype) Then ls_svctype = ""
//		If IsNull(ls_pid) Then ls_pid = ""
//		If IsNull(ls_cid) Then ls_cid = ""
//		
//		If ls_validkey = "" Then
//			f_msg_usr_err(200, Title, "Authorization Code")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("validkey")
//			Return - 1
//		End If
//
//		If ls_svccod = "" Then
//			f_msg_usr_err(200, Title, "Service Code")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("svccod")
//			Return - 1
//		End If
//		
//		If ls_priceplan = "" Then
//			f_msg_usr_err(200, Title, "Price Plan")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("priceplan")
//			Return - 1
//		End If		
//
//		If ls_svctype = "" Then
//			f_msg_usr_err(200, Title, "Service Type")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("svctype")
//			Return - 1
//		End If		
//
//		If ls_pid = "" Then
//			f_msg_usr_err(200, Title, "PIN #")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("pid")
//			Return - 1
//		End If		
//		
//End Choose	
//
////자기자신을 빼고 적용시작일과 적용종료일의 중복을 막는다.
//select count(*)
//  into :ll_cnt
// from validinfo
//where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt and
//                to_char(fromdt,'yyyymmdd') <= :ls_todt)  or
//		  (to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
//		   :ls_fromdt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
//   and	validkey = :ls_validkey
//   and  to_char(fromdt,'yyyymmdd') <> :is_fromdt;
//		  
//If sqlca.sqlcode < 0 Then
//	f_msg_sql_err(title,"Select validinfo (count)")				
//	Return -1
//End If
//
//If ll_cnt > 0 Then
//	f_msg_usr_err(9000, Title, "Authorization Key:" + ls_validkey + "Starting date and Ending date is overlapped .~r~n~r~nPlease again!!")
//	return -1
//End if
//
////Log 정보
//If dw_detail.GetItemStatus(1, 0, Primary!) = DataModified! THEN
//	dw_detail.object.pgm_id[1] = is_pgm_id
//	dw_detail.object.updt_user[1] = gs_user_id
//	dw_detail.object.updtdt[1] = fdt_get_dbserver_now()
//End If
//
//Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_validinfo_popup_update_cl_g
boolean visible = false
integer x = 23
integer y = 24
integer width = 1810
integer height = 264
integer taborder = 10
string dataobject = "b1dw_cnd_reg_validinfo_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_validinfo_popup_update_cl_g
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within b1w_reg_validinfo_popup_update_cl_g
integer x = 2967
integer y = 932
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_validinfo_popup_update_cl_g
boolean visible = false
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_validinfo_popup_update_cl_g
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_validinfo_popup_update_cl_g
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_validinfo_popup_update_cl_g
integer x = 2656
integer y = 932
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_validinfo_popup_update_cl_g
integer y = 52
integer width = 3301
integer height = 812
integer taborder = 20
string dataobject = "b1dw_reg_validinfo_popup_update_cl_g"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;IF dwo.name= "auth_method" Then
	//DYNIP_BOTH, DYNIP_E164
	If LeftA(data, 1) = 'D' Then This.object.validitem2[1] = ""
	
	//STCIP_BOTH, STCIP_E164
	If MidA(data, 7,1) = 'E' Then This.object.validitem3[1]= ""	
	
End If
end event

event dw_detail::retrieveend;call super::retrieveend;string  ls_svccod
long ll_i

ls_svccod = This.object.svccod[1]

is_xener_svc = 'N'
For ll_i = 1  to UpperBound(is_Xener_svccod)
	IF ls_svccod = is_Xener_svccod[ll_i] Then
		is_xener_svc = 'Y'
		Exit
	End IF
NEXT	

If is_xener_svc = 'N' Then
	This.object.auth_method.Protect = 1
	This.Object.auth_method.Background.Color = RGB(255, 251, 240)
	This.Object.auth_method.Color = RGB(0, 0, 0)		
ElseIf is_xener_svc = 'Y' Then
	This.object.auth_method.Protect = 0
	This.Object.auth_method.Background.Color = RGB(108, 147, 137)
	This.Object.auth_method.Color = RGB(255, 255, 255)
End If
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_validinfo_popup_update_cl_g
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

