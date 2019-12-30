$PBExportHeader$b1w_reg_validinfo_popup_update_cl_1k.srw
$PBExportComments$[islim] 인증정보 update popup window(tab3)-킬트
forward
global type b1w_reg_validinfo_popup_update_cl_1k from b1w_reg_validinfo_popup_update_cl
end type
end forward

global type b1w_reg_validinfo_popup_update_cl_1k from b1w_reg_validinfo_popup_update_cl
end type
global b1w_reg_validinfo_popup_update_cl_1k b1w_reg_validinfo_popup_update_cl_1k

on b1w_reg_validinfo_popup_update_cl_1k.create
call super::create
end on

on b1w_reg_validinfo_popup_update_cl_1k.destroy
call super::destroy
end on

event type integer ue_extra_save();String ls_validkey, ls_vpassword, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
String ls_cid, ls_auth_method, ls_ip_address, ls_h323id, ls_pricemodel, ls_pid
String ls_fromdt, ls_todt
Long ll_row, ll_cnt

String ls_validitem3_t

dw_detail.AcceptText()

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 

ls_fromdt = string(dw_detail.object.fromdt[1],'yyyymmdd')
ls_todt = string(dw_detail.object.todt[1],'yyyymmdd')
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) or ls_todt = "" Then ls_todt = '99991231'

Choose Case is_svctype
	Case '1'

		ls_validkey = dw_detail.object.validkey[1]
		ls_vpassword = dw_detail.object.vpassword[1]
		ls_svccod = dw_detail.object.svccod[1]
		ls_priceplan = dw_detail.object.priceplan[1]
		ls_svctype = dw_detail.object.svctype[1]
		ls_gkid = dw_detail.object.gkid[1]
		ls_cid  = dw_detail.object.validitem1[1]
		ls_auth_method = dw_detail.object.auth_method[1]
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_vpassword) Then ls_vpassword = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_gkid) Then ls_gkid = ""
		If IsNull(ls_cid) Then ls_cid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""		
		ls_ip_address = dw_detail.object.validitem2[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
		ls_h323id = dw_detail.object.validitem3[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							


		If ls_validkey = "" Then
			f_msg_usr_err(200, Title, "인증 Key")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("validkey")
			Return - 1
		End If

		If ls_vpassword = "" Then
			f_msg_usr_err(200, Title, "인증 Password")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("vpassword")
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
			f_msg_usr_err(200, Title, "서비스유형")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svctype")
			Return - 1
		End If		

//		If ls_cusnm = "" Then
//			f_msg_usr_err(200, Title, "고객명")
//			dw_detail.SetRow(1)
//			dw_detail.ScrollToRow(1)
//			dw_detail.SetColumn("validitem1")
//			Return - 1
//		End If		

		If is_xener_svc = 'Y' Then

//			If ls_gkid = "" Then
//				f_msg_usr_err(200, Title, "GKID")
//				dw_detail.SetRow(1)
//				dw_detail.ScrollToRow(1)
//				dw_detail.SetColumn("gkid")
//				Return - 1
//			End If		
			
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
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, Title, "H323ID")
					dw_detail.SetRow(1)
					dw_detail.ScrollToRow(1)
					dw_detail.SetColumn("validitem3")
					Return - 1
				End If		
			End IF
		End IF

		ls_validitem3_t = Trim(String(dw_detail.object.validitem3_t.text))		
		If ls_validitem3_t = "착신지번호"  Then
			If	ls_h323id = "" Then
				f_msg_info(200, Title, "착신지번호")
				dw_detail.SetFocus()
				dw_detail.SetColumn("validitem3")
				Return -1
			End If
		End If
		
		
		If ls_validitem3_t = "접속번호"  Then
			If ls_h323id = "" Then
				f_msg_info(200, Title, "접속번호")
				dw_detail.SetFocus()
				dw_detail.SetColumn("validitem3")
				Return -1
			End If
		End If
		
	Case '0'
		ls_validkey = dw_detail.object.validkey[1]
		ls_vpassword = dw_detail.object.vpassword[1]
		ls_svccod = dw_detail.object.svccod[1]
		ls_priceplan = dw_detail.object.priceplan[1]
		ls_svctype = dw_detail.object.svctype[1]
		ls_cid  = dw_detail.object.validitem1[1]
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_vpassword) Then ls_vpassword = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_svctype) Then ls_svctype = ""
		If IsNull(ls_cid) Then ls_cid = ""
		ls_ip_address = dw_detail.object.validitem2[1]
		If IsNull(ls_ip_address) Then ls_ip_address = ""				
		ls_h323id = dw_detail.object.validitem3[1]
		If IsNull(ls_h323id) Then ls_h323id = ""							
		
		If ls_validkey = "" Then
			f_msg_usr_err(200, Title, "인증 Key")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("validkey")
			Return - 1
		End If

		If ls_vpassword = "" Then
			f_msg_usr_err(200, Title, "인증 Password")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("vpassword")
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
			f_msg_usr_err(200, Title, "서비스유형")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("svctype")
			Return - 1
		End If		

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
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, Title, "H323ID")
					dw_detail.SetRow(1)
					dw_detail.ScrollToRow(1)
					dw_detail.SetColumn("validitem3")
					Return - 1
				End If		
			End IF
		End IF
		
	Case '2'
		ls_validkey = dw_detail.object.validkey[1]
		ls_svccod = dw_detail.object.svccod[1]
		ls_priceplan = dw_detail.object.priceplan[1]
		ls_svctype = dw_detail.object.svctype[1]
		ls_pid = dw_detail.object.pid[1]
		ls_cid  = dw_detail.object.validitem1[1]
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_vpassword) Then ls_vpassword = ""
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
			f_msg_usr_err(200, Title, "서비스유형")
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
	f_msg_usr_err(9000, Title, "인증Key:" + ls_validkey + "에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
	return -1
End if

//Log 정보
If dw_detail.GetItemStatus(1, 0, Primary!) = DataModified! THEN
	dw_detail.object.pgm_id[1] = is_pgm_id
	dw_detail.object.updt_user[1] = gs_user_id
	dw_detail.object.updtdt[1] = fdt_get_dbserver_now()
End If

Return 0 
end event

event open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_validinfo_popup_update
	Desc	: 	고객정보등록(tab3:인증정보)- update popup
	Ver.	:	1.0
	Date	: 	2003.01.31
	programer : park kyung hae(parkkh)
-------------------------------------------------------------------------*/
Long ll_row
String ls_where, ls_ref_desc, ls_temp, ls_result[]

is_cusid = ""
is_cusnm = ""

Call w_a_reg_m::Open

//window 중앙에
f_center_window(b1w_reg_validinfo_popup_update_cl_1k)

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

type dw_cond from b1w_reg_validinfo_popup_update_cl`dw_cond within b1w_reg_validinfo_popup_update_cl_1k
end type

type p_ok from b1w_reg_validinfo_popup_update_cl`p_ok within b1w_reg_validinfo_popup_update_cl_1k
end type

type p_close from b1w_reg_validinfo_popup_update_cl`p_close within b1w_reg_validinfo_popup_update_cl_1k
end type

type gb_cond from b1w_reg_validinfo_popup_update_cl`gb_cond within b1w_reg_validinfo_popup_update_cl_1k
end type

type p_delete from b1w_reg_validinfo_popup_update_cl`p_delete within b1w_reg_validinfo_popup_update_cl_1k
end type

type p_insert from b1w_reg_validinfo_popup_update_cl`p_insert within b1w_reg_validinfo_popup_update_cl_1k
end type

type p_save from b1w_reg_validinfo_popup_update_cl`p_save within b1w_reg_validinfo_popup_update_cl_1k
end type

type dw_detail from b1w_reg_validinfo_popup_update_cl`dw_detail within b1w_reg_validinfo_popup_update_cl_1k
end type

event dw_detail::retrieveend;call super::retrieveend;String ls_svccod
long ll_i

ll_i=dw_detail.rowcount()

ls_svccod=LeftA(String(dw_detail.object.svccod[ll_i]), 2)

If ll_i = 1 Then
	If ls_svccod= "X2" Then			//로밍플라이-랜드서비스
		dw_detail.object.validitem3_t.text="접속번호"
		dw_detail.object.validitem2_t.text=""
	ElseIf ls_svccod= "X3"	Then		//로밍플라이-모바일
		dw_detail.object.validitem3_t.text="착신지번호"
		dw_detail.object.validitem2_t.text=""
	End If
Else
	return -1
End If


end event

type p_reset from b1w_reg_validinfo_popup_update_cl`p_reset within b1w_reg_validinfo_popup_update_cl_1k
end type

