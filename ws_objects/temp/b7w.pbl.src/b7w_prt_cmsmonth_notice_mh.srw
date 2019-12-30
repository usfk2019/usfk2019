$PBExportHeader$b7w_prt_cmsmonth_notice_mh.srw
$PBExportComments$[islim] 청구서(월별)
forward
global type b7w_prt_cmsmonth_notice_mh from w_a_print
end type
type cb_shift_r from commandbutton within b7w_prt_cmsmonth_notice_mh
end type
type cb_shift_l from commandbutton within b7w_prt_cmsmonth_notice_mh
end type
type dw_select2 from u_d_external within b7w_prt_cmsmonth_notice_mh
end type
type dw_select1 from u_d_sgl_sel within b7w_prt_cmsmonth_notice_mh
end type
type cb_shift_r_all from commandbutton within b7w_prt_cmsmonth_notice_mh
end type
type cb_shift_l_all from commandbutton within b7w_prt_cmsmonth_notice_mh
end type
end forward

global type b7w_prt_cmsmonth_notice_mh from w_a_print
integer width = 3579
integer height = 2196
cb_shift_r cb_shift_r
cb_shift_l cb_shift_l
dw_select2 dw_select2
dw_select1 dw_select1
cb_shift_r_all cb_shift_r_all
cb_shift_l_all cb_shift_l_all
end type
global b7w_prt_cmsmonth_notice_mh b7w_prt_cmsmonth_notice_mh

type variables
//SUBMST.subkind->SUBID/ANI#
String	is_chargedt, is_reqdt, is_subkind
Date id_reqdt, id_inputclosedt
String is_manager_tel, is_editdt

end variables

on b7w_prt_cmsmonth_notice_mh.create
int iCurrent
call super::create
this.cb_shift_r=create cb_shift_r
this.cb_shift_l=create cb_shift_l
this.dw_select2=create dw_select2
this.dw_select1=create dw_select1
this.cb_shift_r_all=create cb_shift_r_all
this.cb_shift_l_all=create cb_shift_l_all
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_shift_r
this.Control[iCurrent+2]=this.cb_shift_l
this.Control[iCurrent+3]=this.dw_select2
this.Control[iCurrent+4]=this.dw_select1
this.Control[iCurrent+5]=this.cb_shift_r_all
this.Control[iCurrent+6]=this.cb_shift_l_all
end on

on b7w_prt_cmsmonth_notice_mh.destroy
call super::destroy
destroy(this.cb_shift_r)
destroy(this.cb_shift_l)
destroy(this.dw_select2)
destroy(this.dw_select1)
destroy(this.cb_shift_r_all)
destroy(this.cb_shift_l_all)
end on

event ue_ok();call super::ue_ok;Integer li_rc, li_return
Long ll_rows, ll_lower_amt, ll_payidRows, ll_curRow
String ls_where, ls_where_payid
String ls_chargedt, ls_trdt, ls_paydt, ls_usedt_fr, ls_usedt_to, ls_editdt
String ls_payid, ls_selectPayid[], ls_busyn, ls_lastbal, ls_dly_mfr, ls_dly_mto
String ls_ref_desc, ls_ref_content, ls_result[], ls_kind
String ls_pay_method, ls_history_yn


ls_chargedt = Trim(dw_cond.Object.chargedt[1])
ls_trdt = String(dw_cond.Object.trdt[1], "yyyymmdd")
ls_paydt = String(dw_cond.Object.paydt[1], "yyyymmdd")
ls_usedt_fr = String(dw_cond.Object.usedt_fr[1], "yyyymmdd")
ls_usedt_to = String(dw_cond.Object.usedt_to[1], "yyyymmdd")
ls_editdt = String(dw_cond.Object.editdt[1], "yyyy-mm-dd")
ls_payid = Trim(dw_cond.Object.payid[1])
ls_pay_method = Trim(dw_cond.Object.pay_method[1])
ls_history_yn = Trim(dw_cond.object.history_yn[1])

If IsNull(ls_chargedt) Then ls_chargedt = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_history_yn) Then ls_history_yn = "N"


dw_select2.AcceptText()
ll_payidRows = dw_select2.RowCount()
For ll_curRow = 1 To ll_payidRows
	ls_selectPayid[ll_curRow] = Trim(dw_select2.Object.payid[ll_curRow])
	If IsNull(ls_selectPayid[ll_curRow]) Then ls_selectPayid[ll_curRow] = ""
Next


If ls_chargedt = "" Then
	f_msg_usr_err(200, Title, "청구주기")
	dw_cond.SetFocus()
	dw_cond.SetColumn("chargedt")
	Return
End If

If ls_pay_method = "" Then
	f_msg_usr_err(200, Title, "납입방법")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pay_method")
	Return
End If

If ls_paydt = "" Then
	f_msg_usr_err(200, Title, "이체일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("paydt")
	Return
End If

If ls_editdt = "" Then
	f_msg_usr_err(200, Title, "작성일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("editdt")
	Return
End If

If ls_trdt = "" Or ls_usedt_fr = "" Or ls_usedt_to = "" Then
	f_msg_usr_err(200, Title, "청구주기컨트롤의 내용을 확인후 실행하십시오")
	dw_cond.SetFocus()
	dw_cond.SetColumn("chargedt")
	Return
End If


If ls_pay_method = "1" Then
	If ls_history_yn = "Y" Then
		dw_list.Dataobject = "b7dw_prt_giromonth_notice_v_history"
	Else
		dw_list.DataObject = "b7dw_prt_giromonth_notice_mh"		
	End If
ElseIf ls_pay_method = "2" Then
	If ls_history_yn = "Y" Then
		dw_list.DataObject = "b7dw_prt_cmsmonth_notice_v_history"
	Else
		dw_list.DataObject = "b7dw_prt_cmsmonth_notice_mh"
	End If
Else
	If ls_history_yn = "Y" Then
		dw_list.Dataobject = "b7dw_prt_ktmonth_notice_1_vtel_history"
	Else
		dw_list.DataObject = "b7dw_prt_ktmonth_notice_1_vtel"
	End If
End If

dw_list.SetTransObject(SQLCA)

ls_where = ""

If ll_payidRows < 1 Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " info.payid = '" + ls_payid + "' "
//   ls_where_payid = ls_payid
Else
	ls_where_payid = ""
	For ll_curRow = 1 To ll_payidRows
		If ls_where_payid <> "" Then ls_where_payid += ", "
		ls_where_payid += "'" + ls_selectPayid[ll_curRow] + "'"
	Next
	
	If ls_where_payid <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " info.payid in (" + ls_where_payid + ") "		
	End If
End If

dw_list.is_where = ls_where
ll_rows = dw_list.Retrieve(ls_pay_method,ls_chargedt,ls_trdt)

If ll_rows < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If

b7u_dbmgr_2_mh lu_dbmgr
lu_dbmgr = Create b7u_dbmgr_2_mh


If ls_pay_method = '1' Then  //지로
	lu_dbmgr.is_title = This.Title
	lu_dbmgr.is_caller = "b7w_prt_giro_notice_mh%ue_ok"
	//lu_dbmgr.is_data[1] = ls_busyn
	lu_dbmgr.is_data2[1] = ls_trdt
	lu_dbmgr.is_data2[2] = ls_usedt_fr
	lu_dbmgr.is_data2[3] = ls_usedt_to
	lu_dbmgr.is_data2[4] = ls_paydt
	lu_dbmgr.is_data2[5] = ls_editdt
	lu_dbmgr.is_data2[6] = ls_pay_method
	lu_dbmgr.idw_data[1] = dw_list
	lu_dbmgr.idw_data[2] = dw_select2
	
	SetPointer(HourGlass!)
	SetRedraw(False)
	lu_dbmgr.uf_prc_db_03()
	SetRedraw(True)
	SetPointer(Arrow!)
	li_rc = lu_dbmgr.ii_rc
	Destroy lu_dbmgr	
ElseIf ls_pay_method = '2' Then	//자동이체
	lu_dbmgr.is_title = This.Title
	lu_dbmgr.is_caller = "b7w_prt_cms_notice_mh%ue_ok"
	lu_dbmgr.is_data2[1] = ls_trdt
	lu_dbmgr.is_data2[2] = ls_usedt_fr
	lu_dbmgr.is_data2[3] = ls_usedt_to
	lu_dbmgr.is_data2[4] = ls_paydt
	lu_dbmgr.is_data2[5] = ls_editdt
	lu_dbmgr.idw_data[1] = dw_list
	lu_dbmgr.idw_data[2] = dw_select2
	lu_dbmgr.is_data2[6] = is_manager_tel	
	lu_dbmgr.is_data2[7] = ls_pay_method
	
	SetPointer(HourGlass!)
	SetRedraw(False)
	lu_dbmgr.uf_prc_db_01()
	SetRedraw(True)
	SetPointer(Arrow!)
	li_rc = lu_dbmgr.ii_rc
	Destroy lu_dbmgr
Else  //kt통합
	lu_dbmgr.is_title = This.Title
	lu_dbmgr.is_caller = "b7w_prt_kt_notice_v%ue_ok"
	//lu_dbmgr.is_data[1] = ls_busyn
	lu_dbmgr.is_data2[1] = ls_trdt
	lu_dbmgr.is_data2[2] = ls_usedt_fr
	lu_dbmgr.is_data2[3] = ls_usedt_to
	lu_dbmgr.is_data2[4] = ls_paydt
	lu_dbmgr.is_data2[5] = ls_editdt
	lu_dbmgr.idw_data[1] = dw_list
	lu_dbmgr.idw_data[2] = dw_select2
//	lu_dbmgr.is_data2[6] = is_manager_tel
	
	SetPointer(HourGlass!)
	SetRedraw(False)
	lu_dbmgr.uf_prc_db_01()
	SetRedraw(True)
	SetPointer(Arrow!)
	li_rc = lu_dbmgr.ii_rc
	Destroy lu_dbmgr
End If

//dw_cond.Enabled = False
//dw_select1.Enabled = False
//dw_select2.Enabled = False
//cb_shift_r.Enabled = False
//cb_shift_l.Enabled = False

end event

event ue_init;call super::ue_init;ii_orientation = 2
ib_header_set = False
ib_margin = True
end event

event ue_reset;call super::ue_reset;//dw_cond.Enabled = True
//dw_select1.Enabled = True
//dw_select2.Enabled = True
//cb_shift_r.Enabled = True
//cb_shift_l.Enabled = True

dw_select1.Reset()
dw_select2.Reset()
end event

event open;call super::open;String	ls_ref_content, ls_ref_desc

//관리점 전화번호
//is_manager_tel = fs_get_control("B0","A104", ls_ref_desc) 




end event

event ue_set_header();If  ib_header_set Then 
	dw_list.setRedraw( False )
	
	dw_list.object.company_name.alignment = 0
	dw_list.object.company_name.width = LenA( is_company_name ) * 40
	dw_list.object.company_name.text = is_company_name
	
	IF	 is_pgm_id1 <> '' Then
		string ls_pgm_id
//		ls_pgm_id  = 'PGM ID : ' + is_pgm_id1
//		dw_list.object.pgm_id1.alignment = 0
//		dw_list.object.pgm_id1.width = len( ls_pgm_id ) * 40
//		dw_list.object.pgm_id1.text = ls_pgm_id
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
	
//	dw_list.object.title.x = &
//		long( dw_list.object.title.x ) - &
//		long( (  ( len( is_title ) * 60  ) - Long( dw_list.object.title.width)   ) / 2    )
//	dw_list.object.title.width = len( is_title ) * 60
	dw_list.object.title.alignment = 2
	dw_list.object.title.text = is_title
	
	If Not Isnull( is_condition ) Then
		If is_condition <> '' Then
			dw_list.object.condition.alignment = 2
//			dw_list.object.condition.x = &
//				long( dw_list.object.condition.x ) - &
//				Long( (len( is_condition ) * 30  ) -Long( dw_list.object.condition.width)/2  )
//			dw_list.object.condition.width = len( is_condition ) * 35
			dw_list.object.condition.text = is_condition
		End If			
	End If		

	dw_list.setRedraw( True )	
End If

/*
Constant Integer lic_prt_height = 132
Integer	li_ori_height, li_title_width, li_title_x
String	ls_request, ls_describe, ls_modify
String	ls_ref_content, ls_ref_desc
String	ls_message

If Not ib_footer_set Then Return

ls_request = "p_logprt.name"
ls_describe = dw_list.Describe(ls_request)
If Lower(Trim(ls_describe)) = "p_logprt" Then Return

dw_list.SetRedraw(False)

ls_request = "datawindow.footer.height"
ls_describe = dw_list.Describe(ls_request)
li_ori_height = Integer(ls_describe)

//Title
ls_request = "title.name"
ls_describe = dw_list.Describe(ls_request)
If Lower(Trim(ls_describe)) = "title" Then
	ls_request = "title.X title.Width"
	ls_describe = dw_list.Describe(ls_request)
	li_title_x = Integer(Mid(ls_describe, 1, Pos(ls_describe, "~n") - 1))
	li_title_width = Integer(Mid(ls_describe, Pos(ls_describe, "~n") + 1))
Else
	li_title_x = 5
	li_title_width = 2745
End If

ls_modify = "datawindow.footer.height=" + String(li_ori_height + lic_prt_height)
dw_list.Modify(ls_modify)

ls_ref_content = fs_get_control("B0", "PRT1", ls_ref_desc)
If IsNull(ls_ref_content) Then ls_ref_content = ""
ls_message = ls_ref_content
ls_ref_content = fs_get_control("B0", "PRT2", ls_ref_desc)
If IsNull(ls_ref_content) Then ls_ref_content = ""
If ib_footer_line Then
	If ls_message <> "" And ls_ref_content <> "" Then ls_message += "~r~n"
Else
	If ls_message <> "" And ls_ref_content <> "" Then ls_message += " "
End If
ls_message += ls_ref_content
ls_modify = "create text(band=footer alignment=~"2~" text=~"" + ls_message + "~" border=~"0~" color=~"0~" x=~"" + String(li_title_x) + "~" y=~"" + String(li_ori_height + 24) + "~" height=~"104~" width=~"" + String(li_title_width) + "~" name=t_logprt  font.face=~"굴림체~" font.height=~"-8~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"553648127~" )"
dw_list.Modify(ls_modify)

ls_modify = "create bitmap(band=footer filename=~"logprt.jpg~" x=~"" + String(li_title_x) + "~" y=~"" + String(li_ori_height) + "~" height=~"128~" width=~"704~" border=~"0~" name=p_logprt )"
dw_list.Modify(ls_modify)

dw_list.SetRedraw(True)
*/

end event

type dw_cond from w_a_print`dw_cond within b7w_prt_cmsmonth_notice_mh
integer x = 55
integer width = 1371
integer height = 448
string dataobject = "b7dw_cnd_prt_cmsmonth_notice_new"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;
Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data[1]			//고객번호
			Object.customernm[row] = iu_cust_help.is_data[2]		//고객명
		End If
End Choose

end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
iu_cust_help.ib_data[1] = False

is_help_win[1] = "b1w_hlp_payid"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;Long ll_year, ll_mon, ll_last_day
String ls_usedt_fr, ls_usedt_to, ls_useddt, ls_trdt
Date ld_trdt, ld_useddt, ld_use_fr, ld_use_to

Choose Case dwo.Name
	Case "chargedt"
		//청구기준일 구하기
		Select reqdt
		Into :id_reqdt
		From reqconf 
		Where to_char(chargedt) = :data;
	
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Select Error(REQCONF)")
			Return 
		End If		
		//청구기준일
		//is_reqdt = String(id_reqdt, 'yyyy-mm')
		This.object.trdt[1] = id_reqdt
		is_chargedt = data
		
		//사용기간 시작일
		ld_use_fr = fd_pre_month(id_reqdt, 1)
		//사용기간 종료일
		ld_use_to = fd_date_pre(id_reqdt, 1)		

		dw_cond.Object.usedt_fr[1] = ld_use_fr
		dw_cond.Object.usedt_to[1] = ld_use_to
		
		// 납입일구하기
		Select inputclosedt
		Into :id_inputclosedt
		From reqconf 
		Where to_char(chargedt) = :data;	
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Select Error(REQCONF)")
			Return 
		End If				

		dw_cond.Object.paydt[1] = id_inputclosedt	
		
	Case "trdt"
		//청구년월
		ls_trdt = String(dw_cond.Object.trdt[1], "yyyymm")
		ld_trdt = Date(String(ls_trdt, "@@@@/@@/01"))
		//사용기간
		ld_useddt = fd_pre_month(ld_trdt, 0)
		ls_useddt = String(ld_useddt, "yyyymmdd")
		ll_year = Long(MidA(ls_useddt, 1, 4))
		ll_mon = Long(MidA(ls_useddt, 5, 2))
		ll_last_day = fl_date_count_in_month(ll_year, ll_mon)
		ls_usedt_fr = MidA(ls_useddt, 1, 6) + "01"
		ls_usedt_to = MidA(ls_useddt, 1, 6) + String(ll_last_day)		
		
		dw_cond.Object.usedt_fr[1] = Date(String(ls_usedt_fr, "@@@@/@@/@@"))
		dw_cond.Object.usedt_to[1] = Date(String(ls_usedt_to, "@@@@/@@/@@"))
		

End Choose
end event

event dw_cond::buttonclicking;call super::buttonclicking;Long ll_rows, ll_insRow
String ls_where
String ls_chargedt, ls_payid, ls_lastbal, ls_dly_mfr, ls_dly_mto
Date ld_trdt
String ls_trdt, ls_pay_method

Choose Case dwo.Name
	Case "b_select"
		dw_select1.Reset()
		dw_select2.Reset()
		dw_cond.AcceptText()
		
		ls_chargedt = Trim(dw_cond.Object.chargedt[1])
		ls_payid = Trim(dw_cond.Object.payid[1])
		ls_pay_method = Trim(dw_cond.Object.pay_method[1])
		ld_trdt  = dw_cond.Object.trdt[1]
		ls_trdt = String(ld_trdt,'yyyymmdd')

		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_chargedt) Then ls_chargedt = ""
		If IsNull(ls_trdt) Then ls_trdt = ""
		If IsNull(ls_pay_method) Then ls_pay_method = ""		

		
		If ls_trdt = "" Then
			f_msg_usr_err(200, Title, "청구년월")
			dw_cond.SetFocus()
			dw_cond.SetColumn("trdt")
			Return
		End If
			
		If ls_chargedt = "" Then
			f_msg_usr_err(200, Title, "청구주기")
			dw_cond.SetFocus()
			dw_cond.SetColumn("chargedt")
			Return
		End If
		
		If ls_pay_method = "" Then
			f_msg_usr_err(200, Title, "납입방법")
			dw_cond.SetFocus()
			dw_cond.SetColumn("pay_method")
			Return
		End If		

//		ls_where = ""		
//
//		If ls_chargedt <> "" Then
//			If ls_where <> "" Then ls_where += " AND "			
//			ls_where += "  reqamtinfo.chargedt = '" + ls_chargedt + "' "
//		End If
//		
//		If ls_pay_method <> "" Then
//			If ls_where <> "" Then ls_where += " AND "			
//			ls_where += "  reqinfo.pay_method = '" + ls_pay_method + "' "
//		End If		
//		
//		If ls_trdt <> "" Then
//			If ls_where <> "" Then ls_where += " AND "
//			ls_where += "reqamtinfo.trdt = to_date('" + ls_trdt + "','yyyymmdd') "
//		End If
//		
//		If ls_payid <> "" Then
//			If ls_where <> "" Then ls_where += " AND "
//			ls_where += " reqamtinfo.payid like '" + ls_payid + "%' "
//		End If

      If ls_payid ="" Then
			ls_payid ="%"
		End If
		
		ll_rows = dw_select1.Retrieve(ls_trdt, ls_pay_method, ls_chargedt,ls_payid)
		
//		dw_select1.is_where = ls_where
//		ll_rows = dw_select1.Retrieve()
//		
		If Not ll_rows > 0 Then 
			ll_insRow = dw_select1.InsertRow(0)
			dw_select1.Object.payid[ll_insRow] = "NON"
			dw_select1.Enabled = False
			cb_shift_r.Enabled = False
			Return
		End If
		dw_select1.Enabled = True
		cb_shift_r.Enabled = True
End Choose
		
end event

type p_ok from w_a_print`p_ok within b7w_prt_cmsmonth_notice_mh
integer x = 3314
integer y = 48
end type

type p_close from w_a_print`p_close within b7w_prt_cmsmonth_notice_mh
integer x = 3314
integer y = 244
end type

type dw_list from w_a_print`dw_list within b7w_prt_cmsmonth_notice_mh
integer x = 27
integer y = 532
integer width = 3488
integer height = 1296
string dataobject = "b7dw_prt_giromonth_notice_mh"
end type

type p_1 from w_a_print`p_1 within b7w_prt_cmsmonth_notice_mh
integer y = 1880
end type

type p_2 from w_a_print`p_2 within b7w_prt_cmsmonth_notice_mh
integer y = 1872
end type

type p_3 from w_a_print`p_3 within b7w_prt_cmsmonth_notice_mh
integer y = 1880
end type

type p_5 from w_a_print`p_5 within b7w_prt_cmsmonth_notice_mh
integer y = 1880
end type

type p_6 from w_a_print`p_6 within b7w_prt_cmsmonth_notice_mh
integer y = 1880
end type

type p_7 from w_a_print`p_7 within b7w_prt_cmsmonth_notice_mh
integer y = 1880
end type

type p_8 from w_a_print`p_8 within b7w_prt_cmsmonth_notice_mh
integer y = 1880
end type

type p_9 from w_a_print`p_9 within b7w_prt_cmsmonth_notice_mh
integer y = 1872
end type

type p_4 from w_a_print`p_4 within b7w_prt_cmsmonth_notice_mh
integer y = 1872
end type

type gb_1 from w_a_print`gb_1 within b7w_prt_cmsmonth_notice_mh
integer y = 1836
end type

type p_port from w_a_print`p_port within b7w_prt_cmsmonth_notice_mh
integer y = 1892
end type

type p_land from w_a_print`p_land within b7w_prt_cmsmonth_notice_mh
integer y = 1904
end type

type gb_cond from w_a_print`gb_cond within b7w_prt_cmsmonth_notice_mh
integer width = 1422
integer height = 504
end type

type p_saveas from w_a_print`p_saveas within b7w_prt_cmsmonth_notice_mh
integer y = 1884
end type

type cb_shift_r from commandbutton within b7w_prt_cmsmonth_notice_mh
integer x = 2313
integer y = 20
integer width = 91
integer height = 96
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = ">"
end type

event clicked;Long ll_curRow, ll_insRow
String ls_payid, ls_subid, ls_keysubid, ls_customernm

ll_curRow = dw_select1.GetSelectedRow(0)
If ll_curRow < 1 Then Return

ls_payid = Trim(dw_select1.Object.payid[ll_curRow])
ls_customernm = Trim(dw_select1.Object.customernm[ll_curRow])
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_customernm) Then ls_customernm = ""


dw_select2.SetRedraw(False)
ll_insRow = dw_select2.InsertRow(0)
dw_select2.Object.payid[ll_insRow] = ls_payid
dw_select2.Object.customernm[ll_insRow] = ls_customernm
dw_select2.SetRedraw(True)
end event

type cb_shift_l from commandbutton within b7w_prt_cmsmonth_notice_mh
integer x = 2313
integer y = 380
integer width = 91
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "<<"
end type

event clicked;Long ll_curRow, ll_insRow
Long ll_rows
String ls_payid

ll_rows = dw_select1.RowCount()
If ll_Rows < 1 Then Return

dw_select2.SetRedraw(False)
FOR ll_curRow = ll_rows TO  0 STEP -1
	dw_select2.DeleteRow(ll_curRow)
NEXT

dw_select2.SetRedraw(True)


end event

type dw_select2 from u_d_external within b7w_prt_cmsmonth_notice_mh
integer x = 2414
integer y = 20
integer width = 882
integer height = 472
integer taborder = 11
boolean bringtotop = true
string dataobject = "b7d_prt_notice_selectpayid2"
boolean hscrollbar = false
end type

event constructor;//Override
end event

event clicked;call super::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

event doubleclicked;//Override
Long ll_curRow, ll_insRow, ll_rows
String ls_payid
		
Choose Case dwo.Name
	Case "payid"
		ll_curRow = dw_select2.GetSelectedRow(0)
		If ll_curRow < 1 Then Return
		
		dw_select2.SetRedraw(False)
		dw_select2.DeleteRow(ll_curRow)
		ll_rows = dw_select2.RowCount()
		If ll_curRow > 0 Then 
			If ll_rows > ll_curRow Then
				dw_select2.SelectRow( ll_curRow , TRUE )
			Else
				dw_select2.SelectRow( ll_rows , TRUE )
			End If
		End If		
		dw_select2.SetRedraw(True)
End Choose
end event

type dw_select1 from u_d_sgl_sel within b7w_prt_cmsmonth_notice_mh
integer x = 1467
integer y = 20
integer width = 832
integer height = 472
integer taborder = 11
boolean bringtotop = true
string dataobject = "b7dw_prt_notice_selectpayid1"
end type

event ue_init;call super::ue_init;//dwObject ldwo_sort
//
ib_sort_use = False
//
//ldwo_sort = Object.reqinfo_payid_t
//uf_init(ldwo_sort)
//
end event

event doubleclicked;Long ll_curRow, ll_insRow
String ls_payid

ll_curRow = dw_select1.GetSelectedRow(0)
If ll_curRow < 1 Then Return

ls_payid = Trim(dw_select1.Object.reqinfo_payid[ll_curRow])
If IsNull(ls_payid) Then ls_payid = ""

dw_select2.SetRedraw(False)
ll_insRow = dw_select2.InsertRow(0)
dw_select2.Object.payid[ll_insRow] = ls_payid
dw_select2.SetRedraw(True)
end event

type cb_shift_r_all from commandbutton within b7w_prt_cmsmonth_notice_mh
integer x = 2313
integer y = 260
integer width = 91
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = ">>"
end type

event clicked;Long ll_curRow, ll_insRow, ll_row, ll_row_start
String ls_payid, ls_subid, ls_keysubid, ls_customernm
ll_row_start =1

ll_row = dw_select1.RowCount()
If ll_Row < 1 Then Return

dw_select2.SetRedraw(False)

FOR ll_row_start = 1 TO ll_row STEP 1
	ls_payid = Trim(dw_select1.Object.payid[ll_row_start])
	ls_customernm = Trim(dw_select1.Object.customernm[ll_row_start])
	If IsNull(ls_payid) Then ls_payid = ""
	If IsNull(ls_customernm) Then ls_customernm = ""
	ll_row_start = dw_select2.InsertRow(0)
	dw_select2.Object.payid[ll_row_start] = ls_payid
	dw_select2.Object.customernm[ll_row_start] = ls_customernm	
NEXT

dw_select2.SetRedraw(True)
end event

type cb_shift_l_all from commandbutton within b7w_prt_cmsmonth_notice_mh
integer x = 2313
integer y = 140
integer width = 91
integer height = 96
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "<"
end type

event clicked;Long ll_curRow, ll_insRow
Long ll_rows
String ls_payid

ll_curRow = dw_select2.GetSelectedRow(0)
If ll_curRow < 1 Then Return

dw_select2.SetRedraw(False)
dw_select2.DeleteRow(ll_curRow)
ll_rows = dw_select2.RowCount()
If ll_curRow > 0 Then 
	If ll_rows > ll_curRow Then
		dw_select2.SelectRow( ll_curRow , TRUE )
	Else
		dw_select2.SelectRow( ll_rows , TRUE )
	End If
End If
dw_select2.SetRedraw(True)
end event

