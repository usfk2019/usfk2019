$PBExportHeader$b5w_prt_inv_call_detail_myphon.srw
$PBExportComments$[kem] 청구서 발행
forward
global type b5w_prt_inv_call_detail_myphon from w_a_print
end type
end forward

global type b5w_prt_inv_call_detail_myphon from w_a_print
integer width = 3333
integer height = 2164
end type
global b5w_prt_inv_call_detail_myphon b5w_prt_inv_call_detail_myphon

type variables
String is_main, is_address_1, is_address_2, is_address_3, is_address_4, is_address_5
String is_format
end variables

on b5w_prt_inv_call_detail_myphon.create
call super::create
end on

on b5w_prt_inv_call_detail_myphon.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_chargedt, ls_trdt, ls_where, ls_langtype, ls_inv_method, ls_pay_method
String ls_payid, ls_picture, ls_picture_1
String ls_msg_1, ls_msg_2, ls_msg_3, ls_msg_4, ls_msg_5
Date ld_trdt, ld_use_fr, ld_use_to
Integer li_rc, li_row

String ls_city, ls_province, ls_bilcity, ls_bilprovince
DataWindowChild ldc


ls_payid = Trim(dw_cond.object.payid[1])
ls_chargedt = Trim(dw_cond.object.chargedt[1])
ld_trdt = dw_cond.object.trdt[1]
ls_trdt = String(ld_trdt, 'yyyymmdd')

ls_inv_method = Trim(dw_cond.object.inv_method[1])
ls_pay_method = Trim(dw_cond.object.pay_method[1])
ls_langtype = Trim(dw_cond.object.langtype[1])


If IsNull(ls_chargedt) Then ls_chargedt =""
If IsNull(ls_trdt) Then ls_trdt = ""
If IsNull(ls_langtype) Then ls_langtype =""
If IsNull(ls_pay_method) Then ls_pay_method =""
If IsNull(ls_payid) Then ls_payid = ""

If ls_chargedt ="" Then
	f_msg_usr_err(200, title, "Billing Cycle (Due Date)")
	dw_cond.SetFocus()
	dw_cond.SetColumn("chargedt")
	Return
End If


If ls_trdt ="" Then
	f_msg_usr_err(200, title, "Billing Cycle Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return
End If



ls_where = ""
ls_where = " info.chargedt = '" + ls_chargedt + "' "
ls_where += " And to_char(info.trdt, 'yyyymmdd') = '" + ls_trdt + "' "


If ls_pay_method <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " info.pay_method = '" + ls_pay_method + "' "
End If


If ls_inv_method <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " info.inv_method = '" + ls_inv_method + "' "
End If

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " info.payid = '" + ls_payid + "' "
End If


dw_list.SetRedraw(False)

dw_list.is_where = ls_where

li_row = dw_list.Retrieve(is_format)

If li_row = 0 Then
	f_msg_info(1000, title, "")
ElseIf li_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return
End If


dw_list.SetRedraw(TRUE)



	
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2//세로2, 가로1
ib_margin = False
end event

event open;call super::open;String ls_ref, ls_result

//is_main= fs_get_control("B5", "N100", ls_ref)
//is_address_1= fs_get_control("B5", "N101", ls_ref)
//if is_address_1 = '*' Then is_address_1 = ""
//is_address_2= fs_get_control("B5", "N102", ls_ref)
//if is_address_2 = '*' Then is_address_2 = ""
//is_address_3= fs_get_control("B5", "N103", ls_ref)
//if is_address_3 = '*' Then is_address_3 = ""
//is_address_4= fs_get_control("B5", "N104", ls_ref)
//if is_address_4 = '*' Then is_address_4 = ""
//is_address_5= fs_get_control("B5", "N105", ls_ref)
//if is_address_5 = '*' Then is_address_5 = ""
//
is_format= fs_get_control("B5", "N106", ls_ref)



end event

event ue_set_header();If  ib_header_set Then 
	dw_list.setRedraw( False )
	
	dw_list.object.company_name.alignment = 0
	dw_list.object.company_name.width = LenA( is_company_name ) * 40
	dw_list.object.company_name.text = is_company_name
	
	IF	 is_pgm_id1 <> '' Then
		string ls_pgm_id

	End If		
	
//****kenn Modify 1998-12-04 Fri****
//**이유 : Title이 긴 출력물에서는 빈종이가 한장 더 출력 된다.
//**조치 : date_time과 title Text Object의 X, Width를 조정하지 못하게 한다.
//	dw_list.object.date_time.x = &
//		long( dw_list.object.date_time.x ) - &
//		( (len( is_date_time ) * 30  ) -Long( dw_list.object.date_time.width)  )
//	dw_list.object.date_time.width = len( is_date_time ) * 30
//****kenn****
	dw_list.object.date_time.alignment = 1
	dw_list.object.date_time.text = is_date_time
	

	dw_list.object.title.alignment = 2
	dw_list.object.title.text = is_title
	
	If Not Isnull( is_condition ) Then
		If is_condition <> '' Then
			dw_list.object.condition.alignment = 2

			dw_list.object.condition.text = is_condition
		End If			
	End If		

	dw_list.setRedraw( True )	
End If



dw_list.SetRedraw(True)
dw_cond.SetFocus()

end event

type dw_cond from w_a_print`dw_cond within b5w_prt_inv_call_detail_myphon
integer y = 64
integer width = 2450
integer height = 304
string dataobject = "b5dw_cnd_prt_inv_call_detail_myphone"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::clicked;call super::clicked;string docname, named
integer value

IF value = 1 THEN FileOpen(docname)
Choose Case dwo.name
	Case "p_1"
		value = GetFileOpenName("Select File", &
		+ docname, named, "", &
		+ "JPG Files (*.JPG),*.JPG," &
		+ "GIF Files (*.GIF),*.GIF," &
	   + "All Files (*.*),*.*" )
		
		If value = 1 Then //성공
			This.object.picture[1] = docname 
		End If
	Case "p_2"
		value = GetFileOpenName("Select File", &
		+ docname, named, "", &
		+ "JPG Files (*.JPG),*.JPG," &
		+ "GIF Files (*.GIF),*.GIF," &
	   + "All Files (*.*),*.*" )
		
		If value = 1 Then //성공
			This.object.picture_1[1] = docname 
		End If
		
End Choose
Return 0 
end event

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst"
This.is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "payid"
		
     If this.iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
		End If
End Choose

Return 0 
end event

event dw_cond::itemchanged;call super::itemchanged;DateTime ldt_trdt

Choose Case dwo.name
	Case "chargedt"
		
		select reqdt
		into :ldt_trdt
		from reqconf
		where chargedt = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title ,  " Select REQCONF Error")
			Return 
		End If		
		
		This.object.trdt[1] = ldt_trdt
End Choose
Return 0

end event

type p_ok from w_a_print`p_ok within b5w_prt_inv_call_detail_myphon
integer x = 2670
end type

type p_close from w_a_print`p_close within b5w_prt_inv_call_detail_myphon
integer x = 2971
end type

type dw_list from w_a_print`dw_list within b5w_prt_inv_call_detail_myphon
integer y = 416
integer width = 3227
integer height = 1400
string dataobject = "b5dw_prt_inv_call_detail_m"
end type

type p_1 from w_a_print`p_1 within b5w_prt_inv_call_detail_myphon
integer x = 2688
integer y = 1868
end type

type p_2 from w_a_print`p_2 within b5w_prt_inv_call_detail_myphon
integer x = 503
integer y = 1868
end type

type p_3 from w_a_print`p_3 within b5w_prt_inv_call_detail_myphon
integer x = 2386
integer y = 1868
end type

type p_5 from w_a_print`p_5 within b5w_prt_inv_call_detail_myphon
integer x = 1207
integer y = 1868
end type

type p_6 from w_a_print`p_6 within b5w_prt_inv_call_detail_myphon
integer x = 1810
integer y = 1868
end type

type p_7 from w_a_print`p_7 within b5w_prt_inv_call_detail_myphon
integer x = 1609
integer y = 1868
end type

type p_8 from w_a_print`p_8 within b5w_prt_inv_call_detail_myphon
integer x = 1408
integer y = 1868
end type

type p_9 from w_a_print`p_9 within b5w_prt_inv_call_detail_myphon
integer x = 800
integer y = 1868
end type

type p_4 from w_a_print`p_4 within b5w_prt_inv_call_detail_myphon
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_inv_call_detail_myphon
integer x = 41
integer y = 1828
end type

type p_port from w_a_print`p_port within b5w_prt_inv_call_detail_myphon
integer x = 87
integer y = 1892
end type

type p_land from w_a_print`p_land within b5w_prt_inv_call_detail_myphon
integer x = 247
integer y = 1904
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_inv_call_detail_myphon
integer width = 2533
integer height = 380
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_inv_call_detail_myphon
integer x = 2094
integer y = 1868
end type

