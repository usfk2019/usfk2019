$PBExportHeader$b1w_inq_inv_detail_pop.srw
$PBExportComments$[khpark]  고객정보등록 (청구정보) popup
forward
global type b1w_inq_inv_detail_pop from b1w_inq_inv_detail
end type
end forward

global type b1w_inq_inv_detail_pop from b1w_inq_inv_detail
windowstate windowstate = normal!
end type
global b1w_inq_inv_detail_pop b1w_inq_inv_detail_pop

type variables
String is_pgmid
end variables

on b1w_inq_inv_detail_pop.create
int iCurrent
call super::create
end on

on b1w_inq_inv_detail_pop.destroy
call super::destroy
end on

event open;call super::open;f_center_window(This)

//수정 불가능
dw_cond.object.value[1] = "customerid"
dw_cond.object.name[1] 	= iu_cust_msg.is_data[1]
is_pgmid       			= iu_cust_msg.is_data[2]

//Item Changed Event 발생
Trigger Event ue_ok()
end event

event ue_find;Long ll_rc, ll_selrow
Integer li_curtab, li_return
String ls_where, ls_customerid, ls_payid, ls_sale_month
String ls_workdt_fr, ls_workdt_to, ls_tr_month

dw_cond2.AcceptText()

li_curtab = tab_1.selectedtab
ll_selrow = dw_master.GetSelectedRow(0)
If Not (ll_selrow > 0) Then Return
ls_payid = dw_master.Object.customerm_payid[ll_selrow]
If IsNull(ls_payid) Or ls_payid = "" Then Return
ls_customerid = dw_master.Object.customerm_customerid[ll_selrow]
If IsNull(ls_customerid) Or ls_customerid = "" Then Return

Choose Case li_curtab
	Case 4	        //판매내역 tab
		
//		***** 사용자 입력사항 변수에 대입 *****
		ls_sale_month = Trim(dw_cond2.Object.yyyymm[1])
		If isnull(ls_sale_month) Then ls_sale_month = ""
		
//		***** 사용자 입력사항 검증 *****
//		If ls_sale_month = "" Then
//			f_msg_usr_err(211, This.Title, "판매년월")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("yyyymm")
//			Return
//		End If
		
		ls_where = " payid = '" + ls_payid + "' "
		
//    년월형식 check
	   If ls_sale_month <> "" Then
			If Isdate(LeftA(ls_sale_month,4) + "/" + RightA(ls_sale_month,2) + "/01") Then
			else
				f_msg_usr_err(211, This.Title, "판매년월")
				dw_cond2.setfocus()
				dw_cond2.SetColumn("yyyymm")
				Return
			End if
			ls_where += " And to_char(sale_month,'yyyymm') = '" + ls_sale_month + "' "			
	   End if

		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)		

	Case 5, 7
//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		ls_tr_month = trim(dw_cond2.Object.yyyymm[1])		
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""	
		If Isnull(ls_tr_month) Then ls_tr_month = ""				
		
//		***** 사용자 입력사항 검증 *****
//		If ls_workdt_fr = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(From)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_fr")
//			Return
//		End If
//		
//		If ls_workdt_to = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(to)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_to")
//			Return
//		End If
//		
		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "통화일(From) <= 통화일(To)")
					Return
				End If
			End If
		End If
		
		ls_where = " a.payid = '" + ls_payid + "' "
		//If ls_tr_month <> "" Then ls_where += " And to_char(a.trdt,'yyyymm') = '" + ls_tr_month + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(a.workdt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(a.workdt,'yyyymmdd') <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, "")
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
		p_saveas.TriggerEvent("ue_enable")

	Case 6, 8
//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		ls_tr_month = trim(dw_cond2.Object.yyyymm[1])
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
		If Isnull(ls_tr_month) Then ls_tr_month = ""		
		
//		***** 사용자 입력사항 검증 *****
//		If ls_workdt_fr = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(From)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_fr")
//			Return
//		End If
//		
//		If ls_workdt_to = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(to)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_to")
//			Return
//		End If
		
		If ls_tr_month = "" Then
			f_msg_usr_err(211, This.Title, "청구년월")
			dw_cond2.setfocus()
			dw_cond2.SetColumn("yyyymm")
			Return
		End If

		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "통화일(From) <= 통화일(To)")
					Return
				End If
			End If
		End If
		
//    년월형식 check
		If Isdate(LeftA(ls_tr_month,4) + "/" + RightA(ls_tr_month,2) + "/01") Then
		else
			f_msg_usr_err(211, This.Title, "청구년월")
			dw_cond2.setfocus()
			dw_cond2.SetColumn("yyyymm")
			Return
   	End if			

		ls_where = " a.payid = '" + ls_payid + "' "
		ls_where += " And to_char(a.trdt,'yyyymm') = '" + ls_tr_month + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(a.workdt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(a.workdt,'yyyymmdd') <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
		
End Choose
end event

event ue_saveas;Boolean lb_return
String ls_curdir
u_api lu_api


Long ll_rc, ll_selrow
Integer li_curtab, li_return
String ls_where, ls_customerid, ls_payid, ls_sale_month
String ls_workdt_fr, ls_workdt_to, ls_tr_month

dw_cond2.AcceptText()

li_curtab = tab_1.selectedtab
ll_selrow = dw_master.GetSelectedRow(0)
If Not (ll_selrow > 0) Then Return
ls_payid = dw_master.Object.customerm_payid[ll_selrow]
If IsNull(ls_payid) Or ls_payid = "" Then Return
ls_customerid = dw_master.Object.customerm_customerid[ll_selrow]
If IsNull(ls_customerid) Or ls_customerid = "" Then Return

Choose Case li_curtab

	Case 4,5,6,7,8 //판매내역,전화사용내역, 전화사용내역h

		If tab_1.idw_tabpage[li_curtab].RowCount() <= 0 Then
			f_msg_info(1000, This.Title, "Data exporting")
			Return
		End If

		lu_api = Create u_api
		ls_curdir = lu_api.uf_getcurrentdirectorya()
		If IsNull(ls_curdir) Or ls_curdir = "" Then
			f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
			Destroy lu_api
			Return
		End If
		
		li_return = tab_1.idw_tabpage[li_curtab].SaveAs("", Excel!, True)
		
		lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
		If li_return <> 1 Then
			f_msg_info(9000, This.Title, "User cancel current job.")
			
		Else
			f_msg_info(9000, This.Title, "Data export finished.")
		End If
		
		Destroy lu_api


//		p_saveas.TriggerEvent("ue_disable")

		
End Choose
end event

type dw_cond from b1w_inq_inv_detail`dw_cond within b1w_inq_inv_detail_pop
end type

type p_ok from b1w_inq_inv_detail`p_ok within b1w_inq_inv_detail_pop
end type

type p_close from b1w_inq_inv_detail`p_close within b1w_inq_inv_detail_pop
end type

type gb_cond from b1w_inq_inv_detail`gb_cond within b1w_inq_inv_detail_pop
end type

type dw_master from b1w_inq_inv_detail`dw_master within b1w_inq_inv_detail_pop
end type

type tab_1 from b1w_inq_inv_detail`tab_1 within b1w_inq_inv_detail_pop
end type

event tab_1::ue_init;//Tab Control의 Parent
iw_parent = parent  
//사용할 Tab Page의 갯수 (15 이하)
ii_enable_max_tab = 8

//Tab Page에 들어갈 title
is_tab_title[1] = "청구내역"
is_tab_title[2] = "청구내역History"
is_tab_title[3] = "입금내역"
is_tab_title[4] = "판매내역"
is_tab_title[5] = "전화사용내역상세"
is_tab_title[6] = "전화사용내역상세History"
is_tab_title[7] = "전화사용내역상세(Item)"
is_tab_title[8] = "전화사용내역상세(item)-History"


//Tab Page에 해당되는  DataWindow 할당
is_dwObject[1] = "b1dw_inq_inv_detail_t1"
is_dwObject[2] = "b1dw_inq_inv_detail_t1"
is_dwObject[3] = "b1dw_inq_inv_detail_t3"
is_dwObject[4] = "b1dw_inq_inv_detail_t4"
is_dwObject[5] = "b1dw_inq_inv_detail_t5_n"
is_dwObject[6] = "b1dw_inq_inv_detail_t6_n"
is_dwObject[7] = "b1dw_inq_inv_detail_t5_item"
is_dwObject[8] = "b1dw_inq_inv_detail_t6_item"
end event

event tab_1::selectionchanged;call super::selectionchanged;String ls_date, ls_payid, ls_customerid
Long ll_selrow

ll_selrow = dw_master.GetSelectedRow(0)
If ll_selrow > 0 Then 
	ls_payid = dw_master.Object.customerm_payid[ll_selrow]
	ls_customerid = dw_master.Object.customerm_customerid[ll_selrow]
End if	

If IsNull(ls_payid) Then ls_payid = "" 
If IsNull(ls_customerid) Then ls_customerid = "" 

Choose Case newindex
	Case 5
		dw_cond2.Object.yyyymm[1] = String(fdt_get_dbserver_now(), "yyyymm")
		dw_cond2.Event ItemChanged(1, dw_cond2.Object.yyyymm, String(fdt_get_dbserver_now(), "yyyymm"))		
		
	Case 6		
		dw_cond2.Object.yyyymm[1] = String(fdt_get_dbserver_now(), "yyyymm")		
		dw_cond2.Visible = True				
		dw_cond2.Event ItemChanged(1, dw_cond2.Object.yyyymm, String(fdt_get_dbserver_now(), "yyyymm"))		
		
   Case 7		
		p_find.TriggerEvent("ue_enable")
		p_saveas.TriggerEvent("ue_enable")
		dw_cond2.dataobject = "b1dw_cnd_inq_inv_detail4"
		dw_cond2.reset()
		dw_cond2.insertrow(0)
		dw_cond2.Setfocus()
		
		dw_cond2.Object.yyyymm[1] = String(fdt_get_dbserver_now(), "yyyymm")
		dw_cond2.Event ItemChanged(1, dw_cond2.Object.yyyymm, String(fdt_get_dbserver_now(), "yyyymm"))				
		dw_cond2.Visible = True
		
	Case 8
		p_find.TriggerEvent("ue_enable")
		p_saveas.TriggerEvent("ue_enable")
		dw_cond2.dataobject = "b1dw_cnd_inq_inv_detail2"
		dw_cond2.reset()
		dw_cond2.insertrow(0)
		dw_cond2.Setfocus()
		
		dw_cond2.Object.yyyymm[1] = String(fdt_get_dbserver_now(), "yyyymm")		
		dw_cond2.Visible = True	
		dw_cond2.Event ItemChanged(1, dw_cond2.Object.yyyymm, String(fdt_get_dbserver_now(), "yyyymm"))						

End Choose

idw_tabpage[newindex].Visible	 = True		

end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;//Master에 Row 없으면 
If  al_master_row = -1 Then Return -1

Choose Case ai_select_tabpage
	Case 7, 8
		p_saveas.TriggerEvent("ue_enable")
	
End Choose

idw_tabpage[ai_select_tabpage].SetRedraw(true)

Return 0
end event

type st_horizontal from b1w_inq_inv_detail`st_horizontal within b1w_inq_inv_detail_pop
end type

type dw_cond2 from b1w_inq_inv_detail`dw_cond2 within b1w_inq_inv_detail_pop
integer width = 1166
integer height = 208
end type

event dw_cond2::itemchanged;call super::itemchanged;INT		li_tab_index
DATE		ld_date_fr, 	ld_date_to

li_tab_index = tab_1.SelectedTab

IF dwo.name = "yyyymm" THEN
	
	CHOOSE CASE li_tab_index 
		CASE 5, 6, 7, 8	
			SELECT ADD_MONTHS(TO_DATE(:data, 'YYYYMM'), -1) - 1,
			       LAST_DAY(ADD_MONTHS(TO_DATE(:data, 'YYYYMM'), -1)) - 1  
			INTO   :ld_date_fr, :ld_date_to
			FROM   DUAL;
	
			THIS.Object.workdt_fr[1] = ld_date_fr
			THIS.Object.workdt_to[1] = ld_date_to	
	END CHOOSE
	
END IF	
end event

type p_find from b1w_inq_inv_detail`p_find within b1w_inq_inv_detail_pop
integer x = 1234
end type

type p_saveas from b1w_inq_inv_detail`p_saveas within b1w_inq_inv_detail_pop
integer x = 1541
end type

