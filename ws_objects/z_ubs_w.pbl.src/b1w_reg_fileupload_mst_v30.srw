$PBExportHeader$b1w_reg_fileupload_mst_v30.srw
$PBExportComments$[jwlee] 청구파일 upload마스터
forward
global type b1w_reg_fileupload_mst_v30 from w_a_reg_m_tm2
end type
type p_alldelete from u_p_alldelete within b1w_reg_fileupload_mst_v30
end type
type p_saveas from u_p_saveas within b1w_reg_fileupload_mst_v30
end type
type cb_copy from commandbutton within b1w_reg_fileupload_mst_v30
end type
end forward

global type b1w_reg_fileupload_mst_v30 from w_a_reg_m_tm2
integer width = 3927
integer height = 2468
event type integer ue_alldelete ( )
event ue_saveas ( )
p_alldelete p_alldelete
p_saveas p_saveas
cb_copy cb_copy
end type
global b1w_reg_fileupload_mst_v30 b1w_reg_fileupload_mst_v30

type variables
Boolean ib_new, ib_billing
String is_check, is_item[], is_dwobjectnm, is_fileformcd
Long il_cnt

end variables

forward prototypes
public function integer wf_dropdownlist (datawindow adw_obj, long al_row, string as_col, string as_value)
end prototypes

event type integer ue_alldelete();Long ll_row

tab_1.idw_tabpage[3].Accepttext()
If tab_1.idw_tabpage[3].RowCount() <= 0 Then Return -1

For ll_row = tab_1.idw_tabpage[3].RowCount() To 1 Step -1
	tab_1.idw_tabpage[3].DeleteRow(ll_row)
Next

Return 0
end event

event ue_saveas();/*------------------------------------------------------------------*/
/* 오브젝트명  : b1w_reg_fileupload_mst_v30				*/
/* 이   벤   트  : ue_saveas										*/
/* 비         고  : 2008.02.04  By JH								*/
/*------------------------------------------------------------------*/
f_excel_ascii1(tab_1.idw_tabpage[3], '파일명을 입력하세요')
/*
Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If  tab_1.idw_tabpage[3].RowCount() <= 0 Then
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

String	ls_filepath, ls_filename

IF GetFileOpenName("Select File", ls_filepath, ls_filename, "XLS", &
    + "Excel Files (*.xls),*.XLS," &
    + "All Files (*.*), *.*", &
    ".", 2) <> 1 Then Return

li_return = tab_1.idw_tabpage[3].SaveAs(ls_filepath, Excel!, True)

//setcurrentdirectorya(ls_curdir)
lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)

If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api
*/
end event

public function integer wf_dropdownlist (datawindow adw_obj, long al_row, string as_col, string as_value);String ls_SiteCode, ls_Doc_D1, ls_sql

dataWindowChild	dwc_child

adw_obj.GetChild (as_col, dwc_child)
dwc_child.SetTransObject (SQLCA)

adw_obj.Accepttext()

Choose Case lower (as_col)
		
	Case "itemcod"  
	
			ls_sql  = "	SELECT itemcod                                    " &
					  + "             , itemnm                                    " &
					  + "     FROM itemmst                                    " &
					  + "    WHERE SVCCOD  = '" + as_value + "'     " &
					  + "    ORDER BY itemnm                            " 
	Case Else  
	dwc_child.Retrieve ()

End Choose

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

il_cnt = dwc_child.Retrieve ()

Return 0
end function

on b1w_reg_fileupload_mst_v30.create
int iCurrent
call super::create
this.p_alldelete=create p_alldelete
this.p_saveas=create p_saveas
this.cb_copy=create cb_copy
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_alldelete
this.Control[iCurrent+2]=this.p_saveas
this.Control[iCurrent+3]=this.cb_copy
end on

on b1w_reg_fileupload_mst_v30.destroy
call super::destroy
destroy(this.p_alldelete)
destroy(this.p_saveas)
destroy(this.cb_copy)
end on

event open;call super::open;
String  ls_temp, ls_svccod, ls_ref_desc, ls_groupno
Integer i, li_tab
Long    ll_cnt, ll_cnt_1, ll_preseq, ll_row

ib_new = False
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)

ll_row = dw_master.getrow()

//청구파일 Upload 항목정의(청구파일 Upload 항목정의(맵핑키-인증키;매핑키-가격정책;매출일자;요금항목;일반정보;))
		//      A001;A002;B001;C001;C002;
		
ls_temp = fs_get_control("ZM", "C760", ls_ref_desc)
If ls_temp = "" Then Return -1
fi_cut_string(ls_temp, ";" , is_item[])

If is_item[1] = "" Then
	F_GET_MSG(259, title, 'ZM:C760')
	Return -1
End If
end event

event resize;call super::resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//

CALL w_a_m_master::resize

Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)
// Call the resize functions
of_ResizeBars()
of_ResizePanels()

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_alldelete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	//
	p_saveas.Y 	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 250
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_alldelete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	//
	p_saveas.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.Width - 50
	Next
End If



SetRedraw(True)

end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Long ll_master_row, ll_cnt, ll_cnt_check
String ls_fileformcd

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

Choose Case tab_1.SelectedTab
	Case 1						//Tab
		ls_fileformcd = dw_master.object.fileformcd[ll_master_row]
		
		//상세자료존재시 삭제 불가.
		Select count(*)
		  into :ll_cnt
		  from REQFILEFORMDET
		 where fileformcd = :ls_fileformcd;
			 
		If SQLCA.SQLCode < 0 Then
			//f_msg_sql_err(This.Title, "Select Error")
			F_GET_MSG(201, THIS.TITLE, SQLCA.SQLErrText)
			RollBack;
			Return -1
		End If				
		
		//체크자료존재시 삭제 불가.
		Select count(*)
		  into :ll_cnt_check
		  from FILEDATACHECK
		 where fileformcd = :ls_fileformcd;
			 
		If SQLCA.SQLCode < 0 Then
			//f_msg_sql_err(This.Title, "Select Error")
			F_GET_MSG(201, THIS.TITLE, SQLCA.SQLErrText)
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Or ll_cnt_check <> 0 Then
			//f_msg_usr_err(9000, Title, "삭제불가! 체크자료존재")  //삭제 안됨 
			F_GET_MSG(90, Title, "")
			Return -1
		Else 							
			is_check = "DEL"							   //삭제 가능
			ib_new = False
		End If
		
End Choose
dw_cond.object.file_code[1] = ''
return 0
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert
b1u_check lu_check	
Integer li_rc, li_tab
Long ll_master_row
String ls_fileformcd, ls_ref_desc, ls_reqnum_dw, ls_name[]
Boolean lb_check1
li_tab = ai_selected_tab
lu_check = create b1u_check

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row <> 0 Then
	If ll_master_row < 0 Then Return -1
	ls_fileformcd = Trim(dw_master.object.fileformcd[ll_master_row])
End If

Choose Case li_tab
	Case 1		//Tab 1 
	
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[1] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[1] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[1] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updt[1] = fdt_get_dbserver_now()
		
	Case 2		//Tab 2
		//Setting
		tab_1.idw_tabpage[li_tab].object.fileformcd[al_insert_row] = ls_fileformcd
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updt[al_insert_row] = fdt_get_dbserver_now()
		
	Case 3		//Tab 3 인증정보
		//Setting
		tab_1.idw_tabpage[li_tab].object.fileformcd[al_insert_row] = ls_fileformcd
		tab_1.idw_tabpage[li_tab].object.use_yn[al_insert_row]     = 'Y'
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updt[al_insert_row] = fdt_get_dbserver_now()
	

End Choose

Destroy lu_check
Return 0

end event

event ue_extra_save;//Save

Long ll_row, ll_sortno
Integer li_count, i, ll_cnt1, ll_cnt2, ll_cnt3

String ls_discountid, ls_discountnm, ls_discountdesc, ls_cdtype, ls_discountid_old
String ls_remark, ls_groupno, ls_itemcod, ls_fileitem

// Empty Row Check
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

Choose Case ai_select_tab
	Case 1 
		// 정보수정자 기록 
		tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.updt[ll_row] = fdt_get_dbserver_now()
		
	Case 2 
		// 정보수정자 기록 
		FOR i = 1 TO tab_1.idw_tabpage[ai_select_tab].ROWCOUNT()
			tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] = gs_user_id
			tab_1.idw_tabpage[ai_select_tab].object.updt[i] = fdt_get_dbserver_now()
		NEXT
		
	Case 3 
		// 정보수정자 기록 
		FOR i = 1 TO tab_1.idw_tabpage[ai_select_tab].ROWCOUNT()
			ls_remark   = fs_snvl(tab_1.idw_tabpage[ai_select_tab].object.remark[i],"")
			ls_groupno  = fs_snvl(tab_1.idw_tabpage[ai_select_tab].object.groupno[i],"")
			ls_itemcod  = fs_snvl(tab_1.idw_tabpage[ai_select_tab].object.itemcod[i],"")
			ls_fileitem = fs_snvl(tab_1.idw_tabpage[ai_select_tab].object.fileitem[i],"")
			ll_sortno   = tab_1.idw_tabpage[ai_select_tab].object.seq[i]
			
			//원본데이타의 타이틀 명으로 사용하기위해 리마크도 필수로 한다.
			If ls_remark = "" Then
				F_GET_MSG(259, THIS.TITLE, 'remark')
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].setColumn("remark")
				Return -1
			End If
			
			//비교항목명 필수 체크.
			If ls_fileitem = "" Then
				F_GET_MSG(259, THIS.TITLE, 'fileitem')
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].setColumn("fileitem")
				Return -1
			End If
			
			//그룹코드가 요금항목이면 품목을 필수로 한다.ㅣ
			If ls_groupno = is_item[4] Then
				If ls_itemcod = "" Then
					F_GET_MSG(259, THIS.TITLE, 'itemcod')
					tab_1.idw_tabpage[ai_select_tab].SetFocus()
					tab_1.idw_tabpage[ai_select_tab].setColumn("itemcod")
					Return -1
				End If
			End If
			
			//정렬순서 Null 체크
			If IsNull(ll_sortno) Then
				F_GET_MSG(259, THIS.TITLE, 'seq')
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].setColumn("seq")
				Return -1				
			End If
			
			//Old
			//필수적인 항목 체크
			//고객맵핑키(A001)/고객맵핑키-회선번호(A003),매출일자(B001),인증키(A002)은 필수이다.
			
			//New
			//맵핑키-인증키;매핑키-가격정책;매출일자;요금항목;일반정보;
			//A001;A002;B001;C001;C002;
			If ls_groupno = is_item[1] Or ls_groupno = is_item[2] Then	//고객맵핑키(A001 or A002)
				ll_cnt1 ++
			ElseIf ls_groupno = is_item[4] Then		//요금항목(C001)
				ll_cnt2 ++
			ElseIf ls_groupno = is_item[3] Then		//매출일자(B001)
				ll_cnt3 ++
			End If
			
			tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] = gs_user_id
			tab_1.idw_tabpage[ai_select_tab].object.updt[i] = fdt_get_dbserver_now()
		NEXT
		
		//3개 항목중 하나라도 빠진게 있으면 오류 표시.
		//2007.11.08  매출일자(B001)가 필수항목에서 제외됨(by kes)
		//If ll_cnt1 = 0 Or ll_cnt2 = 0 Then
		//If ll_cnt1 = 0 Or ll_cnt2 = 0 Or ll_cnt3 = 0 Then
		If ll_cnt1 = 0 Or ll_cnt2 = 0 Then
			F_GET_MSG(259, THIS.TITLE, 'groupno')
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].setColumn("groupno")
			Return -1
		End If
			

End Choose

Return 0
end event

event ue_ok();call super::ue_ok;Long ll_row, ll_curRow
Int li_return, i
String ls_file_code, ls_desc, ls_new
String ls_where, ls_temp, ls_ref_desc, ls_result[], ls_workno

ll_curRow = dw_master.GetSelectedRow(0)

dw_cond.Accepttext()

ls_new = fs_snvl(dw_cond.object.new[1],'N')

If ls_new = "Y" Then 
	ib_new = True
Else
	ib_new = False
End If

//신규 등록
If ib_new Then
	
    tab_1.SelectedTab = 1		//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
    TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.

	Return
//조회
Else
	ls_file_code   = fs_snvl(Trim(dw_cond.object.file_code[1]),"")
	ls_desc         = fs_snvl(Trim(dw_cond.object.desc[1]),"")

	ls_where = ""
	If ls_file_code <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "fileformcd='" + ls_file_code + "' "
	End If
	
	If ls_desc <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "desc like '%" + ls_desc + "%' "
	End If
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	
	If ll_row = 0 Then
         F_GET_MSG(268, THIS.TITLE, '')
	ElseIf ll_row < 0 Then
         F_GET_MSG(295, THIS.TITLE, '')
	End If
End If

// 수정후 dw_master 재 Retrieve

if ll_curRow > 0  and dw_master.Rowcount() >= ll_curRow and is_check <> "DEL" then
	
	//ls_file_code = String(dw_master.object.fileformcd[ll_curRow])
	
	FOR i = 1 To dw_master.Rowcount()
		If dw_master.object.fileformcd[i] = is_fileformcd Then
			Exit
		End If
	NEXT
			
	ls_file_code = String(dw_master.object.fileformcd[i])
	ls_where = "fileformcd = '" + ls_file_code + "' "
	tab_1.idw_tabpage[1].is_where = ls_where
	tab_1.idw_tabpage[1].Retrieve()	
	
	dw_master.SelectRow(0,false)
	dw_master.SetRow(i)
	dw_master.SelectRow(i,true)
	dw_master.ScrollToRow(i)
			
end if	
Return
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

//ii_error_chk = -1

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
		If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
			(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
			tab_1.SelectedTab = li_tab_index
			li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
			If li_rc <> 1 Then
				Return LI_ERROR
			End If
		End If
	End If
Next

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")


For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False
Next

dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
tab_1.enabled = True

ib_retrieve = FALSE

Return 0
end event

event type integer ue_save();
Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_nmtype, ls_idtype
String ls_fileformcd
Dec lc_troubleno

li_tab_index = tab_1.SelectedTab

If tab_1.idw_tabpage[li_tab_index].AcceptText() < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = tab_1.is_parent_title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return LI_ERROR
	End If

	tab_1.SelectedTab = li_tab_index
	tab_1.idw_tabpage[li_tab_index].SetFocus()
	Return LI_ERROR
End If


li_return = Trigger Event ue_extra_save(li_tab_index)


Choose Case li_return
	Case -2
		//필수항목 미입력
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return -2
	Case -1
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			ib_update = False
			Return -1
		End If

//		f_msg_info(3010, tab_1.is_parent_title, "Save")
		F_GET_MSG(215, tab_1.is_parent_title, '')

		ib_update = False
		Return -1
End Choose


If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return LI_ERROR
	End If

	tab_1.idw_tabpage[li_tab_index].SetFocus()
//	f_msg_info(3010,tab_1.is_parent_title,"Save")
	F_GET_MSG(215, tab_1.is_parent_title, '')

	Return LI_ERROR
End If

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If


if li_tab_index = 1 and ib_new = False and is_check <> "DEL" then 
	dw_cond.object.file_code[1] = ''
	is_fileformcd = tab_1.idw_tabpage[1].object.fileformcd[1]
   TriggerEvent('ue_ok')
end if

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
//f_msg_info(3000,tab_1.is_parent_title,"Save")
F_GET_MSG(214, tab_1.is_parent_title, '')


Long ll_row, ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab

If ib_new = True Then					//신규 등록이면	
   tab_1.idw_tabpage[1].accepttext()
	ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
	If ll_tab_rowcount < 1 Then Return 0
 	
	 If  li_selectedtab = 1 Then			//Tab 1
		 ls_fileformcd = tab_1.idw_tabpage[1].Object.fileformcd[1]	//조건을 넣고
		 
		 TriggerEvent("ue_reset")
		 dw_cond.object.file_code[1] = ls_fileformcd
		 dw_cond.object.new[1] = "N"
		 ib_new = False	 					//초기화 
		 dw_cond.Enabled = True
		 ll_row = TriggerEvent("ue_ok")		//조회
		 
		 If ll_row < 0 Then 
//			f_msg_usr_err(2100,Title, "Retrieve()")
			F_GET_MSG(295, Title, "Retrieve()")

			Return LI_ERROR
		 End If			
	End If
End If

If is_check = "DEL" Then	//Delete 
   If  li_selectedTab = 1 Then
		 dw_cond.Reset()
		 dw_cond.InsertRow(0)
		 TriggerEvent("ue_ok")
		 is_check = ""
	End If
End If

Return 0

////Override
//Constant Int LI_ERROR = -1
//Int li_tab_index, li_return, li_selectedTab
//String ls_fileformcd
//
//li_tab_index = tab_1.SelectedTab
//	
//If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = tab_1.is_parent_title
//	iu_cust_db_app.uf_prc_db()
//	If iu_cust_db_app.ii_rc = -1 Then
//		tab_1.idw_tabpage[li_tab_index].SetFocus()
//		Return LI_ERROR
//	End If
//
//	tab_1.SelectedTab = li_tab_index
//	tab_1.idw_tabpage[li_tab_index].SetFocus()
//	f_msg_info(3010,tab_1.is_parent_title,"Save")
//	Return LI_ERROR
//End If
//
////COMMIT와 동일한 기능
//iu_cust_db_app.is_caller = "COMMIT"
//iu_cust_db_app.is_title = tab_1.is_parent_title
//iu_cust_db_app.uf_prc_db()
//If iu_cust_db_app.ii_rc = -1 Then
//	Return LI_ERROR
//End If
//
//tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
//f_msg_info(3000,tab_1.is_parent_title,"Save")
//
//If is_check = "DEL" Then	//Delete 
//	If  li_selectedTab = 1 Then
//		 TriggerEvent("ue_reset")
//		 is_check = ""
//	End If
//End If
//
//Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_fileupload_mst_v30
integer x = 64
integer y = 80
integer width = 2414
integer height = 104
string dataobject = "b1dw_cnd_reg_fileupload_mst_v30"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_fileupload_mst_v30
integer x = 2629
integer y = 48
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_fileupload_mst_v30
integer x = 2930
integer y = 48
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_fileupload_mst_v30
integer width = 2473
integer height = 244
integer taborder = 20
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_fileupload_mst_v30
integer y = 268
integer width = 3424
integer height = 672
integer taborder = 30
string dataobject = "b1dw_m_reg_fileupload_mst_v30"
boolean ib_sort_use = false
end type

event dw_master::clicked;//Override
Integer li_SelectedTab
Long ll_selected_row
Long ll_old_selected_row
Int li_tab_index,li_rc

String ls_customerid
Boolean lb_check1, lb_check2


ll_old_selected_row = This.GetSelectedRow(0)

Call w_a_m_master`dw_master::clicked

li_SelectedTab = tab_1.SelectedTab
ll_selected_row = This.GetSelectedRow(0)

//Override - w_a_reg_m_tm2

If (tab_1.idw_tabpage[li_SelectedTab].ModifiedCount() > 0) or &
	(tab_1.idw_tabpage[li_SelectedTab].DeletedCount() > 0)	Then

// 확인 메세지 두번 나오는 문제 해결(tab_1)
//	tab_1.SelectedTab = li_tab_index
	li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
		"Do you want to cancel?",Question!,YesNo!)
	If li_rc <> 1 Then
		If ll_selected_row > 0 Then
			SelectRow(ll_selected_row ,FALSE)
		End If
		SelectRow(ll_old_selected_row , TRUE )
		ScrollToRow(ll_old_selected_row)
		tab_1.idw_tabpage[li_SelectedTab].SetFocus()
		Return 
	End If
End If
		
tab_1.idw_tabpage[li_SelectedTab].Reset()
tab_1.ib_tabpage_check[li_SelectedTab] = False

// Button Enable Or Disable
tab_1.Trigger Event SelectionChanged(li_SelectedTab, li_SelectedTab)	

Return 0




end event

event dw_master::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
	
	ib_retrieve = True
	Tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

	Tab_1.SetFocus()
	//p_save.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
	//p_insert.TriggerEvent('ue_enable')
	//p_delete.TriggerEvent('ue_enable')

	p_ok.TriggerEvent('ue_disable')
	//p_find.TriggerEvent('ue_enable')
	dw_cond.Enabled =  False
End If

end event

event dw_master::ue_init();call super::ue_init;//dwObject ldwo_SORT
//
//ib_sort_use = True
//ldwo_SORT = Object.fileupload_worklog_seqno_t
//uf_init(ldwo_SORT)
//
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_fileupload_mst_v30
integer y = 2068
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_fileupload_mst_v30
integer y = 2068
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_fileupload_mst_v30
integer y = 2068
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_fileupload_mst_v30
integer x = 1019
integer y = 2068
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_fileupload_mst_v30
integer x = 32
integer y = 988
integer width = 3424
integer height = 1032
integer taborder = 50
end type

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row, ll_exist
String  ls_type, ls_desc, ls_svccod
Boolean lb_check2
DataWindowChild ldwc_itemcod

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 
	
ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
	p_alldelete.TriggerEvent("ue_disable")
	cb_copy.visible = false
    Return 0
End If

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_alldelete.TriggerEvent("ue_disable")
		p_saveas.TriggerEvent("ue_disable")
		cb_copy.visible = false
	Case 2
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_alldelete.TriggerEvent("ue_disable")
		p_saveas.TriggerEvent("ue_disable")
		cb_copy.visible = false
	Case 3
//         tab_1.idw_tabpage[3].GetChild("itemcod", ldwc_itemcod)
//		ls_svccod = dw_master.object.svccod[dw_master.getrow()]
//		wf_dropdownlist(tab_1.idw_tabpage[3], 1, "ITEMCOD",ls_svccod)
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_alldelete.TriggerEvent("ue_enable")
		p_saveas.TriggerEvent("ue_enable")
		cb_copy.visible = true
		
End Choose

Return 0
	
end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;//w_a_reg_m_tm2.ue_dw_clicked
/*---------------------------------------------------------------------*/
/* 오브젝트명  : tab_1													*/
/* 이  벤  트  : ue_dw_clicked											*/
/* 작성  내역  : 2008.02.04											*/
/* 비      고  : 클릭한 타이틀보더를 Lowered(6)로 변경	*/
/*----------------------------------------------------------------------*/
//IF Not(ib_sort2_use[ai_tabpage]) Then Return 0
//
//String	 ls_type, ls_txtnm, ls_t, ls_b
//Int		li_colpos, li_row
//String	ls_band
//DataWindow	ldw_col
//
//ldw_col = idw_tabpage[ai_tabpage]
//ls_txtnm = adwo_dwo.name
//ls_t     = Right(ls_txtnm, 2)
//ls_b     = ldw_col.Describe(ls_txtnm + ".Border")
//ls_band  = Trim(Lower(ldw_col.Describe(ls_txtnm + ".Band")))
//
////If Len(Trim(ls_txtnm)) = 0 or ls_b = '0' Then
//If Len(Trim(ls_txtnm)) = 0 Then
//	is_tab_dwntxtnm = ""
//	is_tab_dwncolnm = ""
//	Return 0
//End If
//
///** DW의 Column Title을 Click했을 경우 */
//If Not(ls_band = 'header' and ls_t = '_t') Then		
//	is_tab_dwntxtnm = ""
//	is_tab_dwncolnm = ""	
//Else
//	is_tab_dwntxtnm = ls_txtnm
//	is_tab_dwncolnm = Left(is_tab_dwntxtnm, Len(is_tab_dwntxtnm) - 2)
////	Modify( ls_txtnm + ".Border = '5'")
//	wf_tab_sort(ai_tabpage)
//End If
//
//Return 0

String ls_svccod
DataWindowChild ldwc_itemcod

Choose Case ai_tabpage
	Case 3
		If adwo_dwo.name = 'itemcod' Then
			tab_1.idw_tabpage[3].GetChild("itemcod", ldwc_itemcod)
			ls_svccod = dw_master.object.svccod[dw_master.getrow()]
			wf_dropdownlist(tab_1.idw_tabpage[3], al_row, "ITEMCOD",ls_svccod)
	    End If
End Choose

		
return 0		
end event

event tab_1::ue_init();call super::ue_init;
String    ls_code, ls_codenm, ls_yn, ls_dwnm
long    ll_chk, ll_cnt, i, ll_num, ll_n

//Tab 초기화
ii_enable_max_tab = 3		//Tab 갯수

DECLARE fileupload_cur CURSOR FOR
		SELECT CODE,
				 CODENM,
				 DWNM,
				 USE_YN
		  FROM TABINFO
		 WHERE GUBUN = 'fileupload'
		ORDER  BY 1,2; 
	
OPEN fileupload_cur;

DO WHILE SQLCA.SQLCODE = 0
	
	FETCH fileupload_cur 
	 INTO  :ls_code    ,
			 :ls_codenm  ,
			 :ls_dwnm    ,
			 :ls_yn      ;
			 
	If sqlca.sqlcode <> 0 then
		exit;
	end if
	
	ll_cnt ++
	//Tab 초기화
	//Tab Title
		is_tab_title[ll_cnt] = ls_codenm
		is_dwObject[ll_cnt]  = ls_dwnm
LOOP 
CLOSE fileupload_cur;
//end

If ll_cnt > 2 THEN
	is_dwobjectnm = is_dwObject[2]
End If

////Tab 초기화
ii_enable_max_tab = ll_cnt		//Tab 갯수

//is_tab_title[1] = "파일유형마스터"
//is_tab_title[2] = "Data 검증항목"
//is_tab_title[3] = "파일유형상세"
//
//Tab에 해당하는 dw

//is_dwObject[1] = "b1dw_reg_fileupload_mst_t1_v30"
//is_dwObject[2] = "b1dw_reg_fileupload_mst_t2_v30"
//is_dwObject[3] = "b1dw_reg_fileupload_mst_t3_v30"

//--> Sort
wf_tab_init(ii_enable_max_tab)

end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;DataWindowChild ldc_priceplan
Long   li_exist, ll_i, li_return, ll_cnt
String ls_temp, ls_fr_partner, ls_prefixno, ls_ref_desc, ls_result[], ls_filter
String ls_validkey_type, ls_itemcod
//Boolean lb_check

dw_cond.Accepttext()

Choose Case tab_1.SelectedTab
	Case 3		//Tab 3
		Choose Case dwo.name
			Case "groupno"
								
				If Data <> is_item[4] Then		//C001
					tab_1.idw_tabpage[3].Object.itemcod[row] = ''
				End If
		End Choose	
		
End Choose
return 0
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;String ls_where, ls_fileformcd, ls_svccod
Long ll_row
DataWindowChild ldwc_itemcod

If al_master_row = -1 Then Return -1

Choose Case ai_select_tabpage
	Case 1
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
		
		ls_fileformcd = dw_master.Object.fileformcd[al_master_row]
		
		ls_where = " fileformcd = '" +ls_fileformcd + "' "
		
		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
		
		If ll_row = 0 Then
         	F_GET_MSG(268, Parent.TITLE, '')
			//Return 0
		ElseIf ll_row < 0 Then
         	F_GET_MSG(295, Parent.TITLE, '')
			Return -1
		Else
			p_save.TriggerEvent('ue_enable')
		End If
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(True)
		
	Case 2
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
		
		ls_fileformcd = dw_master.Object.fileformcd[al_master_row]
		
		ls_where = " fileformcd = '" +ls_fileformcd + "' "
		
		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
		
		If ll_row = 0 Then
			//Return 0
		ElseIf ll_row < 0 Then
         	F_GET_MSG(295, Parent.TITLE, '')
			Return -1
		Else
			p_save.TriggerEvent('ue_enable')
		End If
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(True)
		
	Case 3
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
		
		ls_fileformcd = dw_master.Object.fileformcd[al_master_row]
		
		ls_where = " fileformcd = '" +ls_fileformcd + "' "
		
		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
		
		If ll_row = 0 Then
			//Return 0
		ElseIf ll_row < 0 Then
         	F_GET_MSG(295, Parent.TITLE, '')
			Return -1
		Else
			p_save.TriggerEvent('ue_enable')
		End If
		
		
		tab_1.idw_tabpage[3].GetChild("itemcod", ldwc_itemcod)
		ls_svccod = dw_master.object.svccod[al_master_row]
		
		wf_dropdownlist(tab_1.idw_tabpage[3], 0, "ITEMCOD",ls_svccod)
	 
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(True)
		
		
End Choose

Return 0
end event

event tab_1::constructor;call super::constructor;//w_a_reg_m_tm2.constructor()
//int 	i
//s_dw_sort	str_temp
//
//for i = 1 To 10
//	ib_sort2_use[i] = False
//	is_tab_sort[i] = str_temp
//Next

ib_sort2_use[3] = True
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_fileupload_mst_v30
integer x = 32
integer y = 948
end type

type p_alldelete from u_p_alldelete within b1w_reg_fileupload_mst_v30
integer x = 1335
integer y = 2068
boolean bringtotop = true
end type

type p_saveas from u_p_saveas within b1w_reg_fileupload_mst_v30
integer x = 1751
integer y = 2068
boolean bringtotop = true
boolean originalsize = false
end type

event constructor;call super::constructor;Event ue_disable()
end event

type cb_copy from commandbutton within b1w_reg_fileupload_mst_v30
boolean visible = false
integer x = 2624
integer y = 148
integer width = 594
integer height = 92
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event clicked;//해당 고객의 
String ls_fileformcd, ls_parttype
Long ll_row
dw_cond.accepttext()

ls_fileformcd = Trim(dw_master.Object.fileformcd[dw_master.getselectedrow(0)])		//파일유형

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name 	= f_get_msginfo(442) //상세정보 Copy
iu_cust_msg.is_data[1] 		= ls_fileformcd
iu_cust_msg.is_data[2] 		= gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.idw_data[1] 	= tab_1.idw_tabpage[3]

//Open
//표준대역 윈도우 연다.
OpenWithParm(b1w_inq_fileformcd_copy_v31, iu_cust_msg)  

Return 0 
end event

event constructor;cb_copy.text = f_get_msginfo(442)
end event

