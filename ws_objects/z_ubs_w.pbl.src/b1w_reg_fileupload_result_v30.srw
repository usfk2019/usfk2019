$PBExportHeader$b1w_reg_fileupload_result_v30.srw
$PBExportComments$[jwlee] 청구파일 upload결과조회 및 재처리
forward
global type b1w_reg_fileupload_result_v30 from w_a_reg_m_tm2
end type
type p_saveas from u_p_saveas within b1w_reg_fileupload_result_v30
end type
type p_2 from u_p_delete within b1w_reg_fileupload_result_v30
end type
type cb_process from commandbutton within b1w_reg_fileupload_result_v30
end type
end forward

global type b1w_reg_fileupload_result_v30 from w_a_reg_m_tm2
integer width = 4709
integer height = 2472
p_saveas p_saveas
p_2 p_2
cb_process cb_process
end type
global b1w_reg_fileupload_result_v30 b1w_reg_fileupload_result_v30

type variables
Boolean ib_new, ib_billing
String is_check, is_dwobjectnm, is_item[], is_status[], is_customerid, is_customernm
String is_checklist[], is_validkey,	is_mapping, is_priceplan
Long il_cnt

end variables

on b1w_reg_fileupload_result_v30.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
this.p_2=create p_2
this.cb_process=create cb_process
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
this.Control[iCurrent+2]=this.p_2
this.Control[iCurrent+3]=this.cb_process
end on

on b1w_reg_fileupload_result_v30.destroy
call super::destroy
destroy(this.p_saveas)
destroy(this.p_2)
destroy(this.cb_process)
end on

event open;call super::open;String ls_temp, ls_ref_desc
ib_new = False
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)

//청구파일 Upload 항목정의(고객맵핑키;인증키;매출일자;요금항목;일반정보;고객매핑키-회선번호)
//                           A001;A002;B001;C001;C002;A003
//ls_temp = fs_get_control("B7", "C760", ls_ref_desc)

//청구파일 Upload 항목정의(맵핑키-인증키;매핑키-가격정책;매출일자;요금항목;일반정보;)
//A001;A002;B001;C001;C002;A003
ls_temp = fs_get_control("ZM", "C760", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_item[])

If is_item[1] = "" Then
   F_GET_MSG(259, TITLE, 'ZM:C760')
	Close(This)
End If


//청구파일 청구파일 Upload 상태(처리완료;오류발생;원본데이터 수정;청구완료)
//           S;E;M;C
//ls_temp = fs_get_control("B7", "C800", ls_ref_desc)

//청구파일 Upload 상태(처리완료;오류발생;원본데이터 수정;청구완료)
//S;E;M;C
ls_temp = fs_get_control("ZM", "C800", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_status[])

If is_status[1] = "" Then
	F_GET_MSG(259, title, 'ZM:C800')
	Return
End If

//청구파일 data검증코드(인증키 존재여부;고객과 인증키의 일치체크;유일인증키체크)
//                          A1;A2;A3
//ls_temp = fs_get_control("B7", "C770", ls_ref_desc)

//청구파일 data검증코드(인증키 존재여부;고객과 인증키의 일치체크;유일인증키체크)
//A1;A2;A3
ls_temp = fs_get_control("ZM", "C770", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_checklist[])

If is_checklist[1] = "" Then
   F_GET_MSG(259, TITLE, 'ZM:C770')
	Close(This)
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

	p_insert.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	cb_process.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_saveas.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height 	= newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 250
	Next


	p_insert.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	cb_process.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_saveas.Y		= newheight - iu_cust_w_resize.ii_button_space_1
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

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;//Save

Long ll_row, ll_workno, ll_lineno, ll_cnt, ll_check_cnt
Integer li_count, i, j, k, p

String ls_discountid, ls_discountnm, ls_discountdesc, ls_cdtype, ls_discountid_old
String ls_remark, ls_pass_yn, ls_customer, ls_fileformcd, ls_validkey, ls_priceplan, ls_filedata[], ls_data[]
String ls_j, ls_k, ls_p, ls_temp, ls_ref_desc, ls_find = 'N', ls_customerid, ls_customernm, ls_check_cd, &
		ls_check_value
				

// Empty Row Check
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

Choose Case ai_select_tab
	Case 1 
		// 정보수정자 기록 
		tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] 	= gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.updt[ll_row] 		= fdt_get_dbserver_now()
		
	Case 2 
		// 정보수정자 기록 
		
		For i = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
		
			tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] 	= gs_user_id
			tab_1.idw_tabpage[ai_select_tab].object.updt[i] 		= fdt_get_dbserver_now()
			ll_workno = tab_1.idw_tabpage[ai_select_tab].Object.workno[i]
			ll_lineno = tab_1.idw_tabpage[ai_select_tab].Object.lineno[i]
			ls_pass_yn = fs_snvl(tab_1.idw_tabpage[ai_select_tab].Object.pass_yn[i],'N')
			
			Update REQUPLOAD_ERR
			   Set Pass_yn = :ls_pass_yn
			 Where workno  = :ll_workno
			   And lineno  = :ll_lineno;
		Next
		
		cb_process.TriggerEvent(Clicked!)	
		
	Case 4
		
		//1. 수정된 datawindow정보를 저장하고 commit;
		If tab_1.idw_tabpage[ai_select_tab].Update(True,False) < 0 then			
			iu_cust_db_app.is_caller 	= "ROLLBACK"
			iu_cust_db_app.is_title 	= tab_1.is_parent_title
			iu_cust_db_app.uf_prc_db()
			
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				Return -1
			End If

			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			F_GET_MSG(215, title, '')
			Return -1
		End If
		
		tab_1.idw_tabpage[ai_select_tab].ResetUpdate()
		
		//2. fileupload과정 수행 		
		// 저장과 동시에 재처리를 수행하기때문에 고객맵핑키 정보를 찾아서 
		// REQUPLOAD_ORG_D에 Update
		ls_fileformcd 	= dw_master.Object.fileformcd[dw_master.GetSelectedRow(0)]
		ll_workno 		= dw_master.Object.workno[dw_master.GetSelectedRow(0)]
		
		//체크항목중 고객과 인증키의 일치체크가 있는지 찾는다 (CHECK_CD=A2)
		Select Count(*)		INTO :ll_check_cnt		FROM FILEDATACHECK
		 Where fileformcd 	= :ls_fileformcd
		   And CHECK_CD   	= :is_checklist[2];
		
		//체크항목중 고객과 인증키의 일치체크가 있을때만 찾는다
		If ll_check_cnt <> 0 Then		
			
			//고객키(그룹통합코드) 멥핑항목을 찾는다
			is_customerid = 'N'
			
			// 고객키(납부자명) 멥핑항목을 찾는다
			is_customernm = 'N'
		End If

		
		// 인증키 멥핑항목을 찾는다 (맵핑키-인증키 : A001)
		SELECT FILEITEM		INTO :ls_validkey		FROM REQFILEFORMDET
		 WHERE GROUPNO 		= :is_item[1]
		   AND fileformcd 	= :ls_fileformcd;
			
		If SQLCA.SQLCode < 0 OR SQLCA.SQLCode = 100 Then
			F_GET_MSG(201, title, 'REQFILEFORMDET(validkey) :'+SQLCA.SQLErrText)	
			Return -1
		End If
		
		// 가격정책 멥핑항목을 찾는다 (맵핑키-가격정책 : A002)
		SELECT FILEITEM		INTO :ls_priceplan		FROM REQFILEFORMDET
		 WHERE GROUPNO 		= :is_item[2]
			AND fileformcd 	= :ls_fileformcd;
		
		If SQLCA.SQLCode < 0 OR SQLCA.SQLCode = 100 Then
			F_GET_MSG(201, title, 'REQFILEFORMDET(priceplan) :'+SQLCA.SQLErrText)	
			Return -1
		End If			
		
		//작업번호로 인증키 및 가격정책이 어디에 있는지 순번으로 찾음
		 SELECT  name01,name02,name03,name04,name05,name06,name07,name08,name09,name10,
			name11,name12,name13,name14,name15,name16,name17,name18,name19,name20,
			name21,name22,name23,name24,name25,name26,name27,name28,name29,name30,
			name31,name32,name33,name34,name35,name36,name37,name38,name39,name40,
			name41,name42,name43,name44,name45,name46,name47,name48,name49,name50,
			name51,name52,name53,name54,name55,name56,name57,name58,name59,name60,
			name61,name62,name63,name64,name65,name66,name67,name68,name69,name70,
			name71,name72,name73,name74,name75,name76,name77,name78,name79,name80,
			name81,name82,name83,name84,name85,name86,name87,name88,name89,name90,
			name91,name92,name93,name94,name95,name96,name97,name98,name99,name100
		  INTO	 :ls_data[1] ,:ls_data[2] , :ls_data[3] ,:ls_data[4] ,:ls_data[5] ,:ls_data[6],:ls_data[7] ,:ls_data[8],:ls_data[9] ,:ls_data[10],
			:ls_data[11],:ls_data[12],:ls_data[13],:ls_data[14],:ls_data[15],:ls_data[16],:ls_data[17],:ls_data[18],:ls_data[19],:ls_data[20],
			:ls_data[21],:ls_data[22],:ls_data[23],:ls_data[24],:ls_data[25],:ls_data[26],:ls_data[27],:ls_data[28],:ls_data[29],:ls_data[30],
			:ls_data[31],:ls_data[32],:ls_data[33],:ls_data[34],:ls_data[35],:ls_data[36],:ls_data[37],:ls_data[38],:ls_data[39],:ls_data[40],
			:ls_data[41],:ls_data[42],:ls_data[43],:ls_data[44],:ls_data[45],:ls_data[46],:ls_data[47],:ls_data[48],:ls_data[49],:ls_data[50],
			:ls_data[51],:ls_data[52],:ls_data[53],:ls_data[54],:ls_data[55],:ls_data[56],:ls_data[57],:ls_data[58],:ls_data[59],:ls_data[60],
			:ls_data[61],:ls_data[62],:ls_data[63],:ls_data[64],:ls_data[65],:ls_data[66],:ls_data[67],:ls_data[68],:ls_data[69],:ls_data[70],
			:ls_data[71],:ls_data[72],:ls_data[73],:ls_data[74],:ls_data[75],:ls_data[76],:ls_data[77],:ls_data[78],:ls_data[79],:ls_data[80],
			:ls_data[81],:ls_data[82],:ls_data[83],:ls_data[84],:ls_data[85],:ls_data[86],:ls_data[87],:ls_data[88],:ls_data[89],:ls_data[90],
			:ls_data[91],:ls_data[92],:ls_data[93],:ls_data[94],:ls_data[95],:ls_data[96],:ls_data[97],:ls_data[98],:ls_data[99],:ls_data[100]
		 From REQUPLOAD_ORG_M 
		Where workno = :ll_workno ;
		
		If SQLCA.SQLCode < 0 OR SQLCA.SQLCode = 100 Then
			F_GET_MSG(201, title, 'REQUPLOAD_ORG_M :'+SQLCA.SQLErrText)	
			Return -1
		End If	
		
		
		//체크항목중 고객과 인증키의 일치체크가 있을때만 찾는다
		//고객맵핑키가 몇번째 컬럼인지 찾는다	- UBS는 upload파일에 고객키가 없기 때문에 찾지 않는다.
				
		//인증키가 몇번째 컬럼인지 찾는다
		FOR k = 1 TO UPPERBOUND(ls_data[])		
			IF ls_data[k] = ls_validkey THEN 
				ls_find = 'Y'
				EXIT;
			END IF
		NEXT
		
		//가격정책이 몇번째 컬럼인지 찾는다 - UBS추가 2015-02-15. lys
		FOR p = 1 TO UPPERBOUND(ls_data[])		
			IF ls_data[p] = ls_priceplan THEN 
				ls_find = 'Y'
				EXIT;
			END IF
		NEXT
		
		If LenA(String(k)) = 1 Then
			ls_k = '0'+String(k)
		Else
			ls_k = String(k)
		End If		
		
		If LenA(String(p)) = 1 Then
			ls_p = '0'+String(p)
		Else
			ls_p = String(p)
		End If
		

		FOR i = 1 TO tab_1.idw_tabpage[4].ROWCOUNT()
						
			If ls_find = 'Y' Then		
				// 인증키와 요금제를 insert
				is_validkey = tab_1.idw_tabpage[4].GetItemString(i,"value"+ls_k)
				tab_1.idw_tabpage[4].object.validkey[i] = is_validkey
				
				is_priceplan = tab_1.idw_tabpage[4].GetItemString(i,"value"+ls_p)
				tab_1.idw_tabpage[4].object.priceplan[i] = is_priceplan				
			End If			
				
			tab_1.idw_tabpage[4].object.updt_user[i] 	= gs_user_id
			tab_1.idw_tabpage[4].object.UPDTDT[i] 		= fdt_get_dbserver_now()
		NEXT
		
		tab_1.idw_tabpage[4].AcceptText()
		IF tab_1.idw_tabpage[4].update() = 1 then		
		
			//log상태를 청구자료 수정으로 Update함. (원본데이터 수정 : M)
			UPDATE REQUPLOAD_WORKLOG 
			   SET STATUS 	= :is_status[3]
			 WHERE WORKNO 	= :ll_workno;
		 
			If SQLCA.SQLCode < 0 Then
				F_GET_MSG(201, title, 'REQUPLOAD_ORG_M UPDATE:'+SQLCA.SQLErrText)	
				Return -1
			End If		
		
			DELETE REQUPLOAD_OK 
			 WHERE WORKNO = :ll_workno;
		 
			If SQLCA.SQLCode < 0 Then
				F_GET_MSG(201, title, 'REQUPLOAD_OK DELETE:'+SQLCA.SQLErrText)	
				Return -1
			End If		
		
			DELETE REQUPLOAD_ERR 
			 WHERE WORKNO = :ll_workno;
		 
			If SQLCA.SQLCode < 0 Then
				F_GET_MSG(201, title, 'REQUPLOAD_ERR DELETE:'+SQLCA.SQLErrText)	
				Return -1
			End If		
		
			cb_process.TriggerEvent(Clicked!)	
		END IF		
End Choose

Return 0
end event

event ue_ok;call super::ue_ok;Long ll_row, ll_curRow
Int li_return, li_tab_index
String ls_file_code, ls_workno, ls_status, ls_fdate, ls_tdate
String ls_where, ls_temp, ls_ref_desc, ls_result[]
li_tab_index = tab_1.SelectedTab
ll_curRow = dw_master.GetSelectedRow(0)
dw_cond.Accepttext()

ls_file_code = fs_snvl(Trim(dw_cond.object.file_code[1]),"")
ls_workno    = fs_snvl(String(dw_cond.object.workno[1]),"")
ls_status    = fs_snvl(Trim(dw_cond.object.status[1]),"")
ls_fdate     = fs_snvl(Trim(String(dw_cond.object.f_crtdt[1],'yyyymmdd')),"")
ls_tdate     = fs_snvl(Trim(String(dw_cond.object.t_crtdt[1],'yyyymmdd')),"")

//사용자 요구에 의한 주석 처리
//2008.02.11 By JH
//If ls_file_code = "" Then
////	f_msg_info(200, Title, "파일유형")
//	F_GET_MSG(259, THIS.TITLE, '')
//	dw_cond.SetFocus()
//	dw_cond.setColumn("file_code")
//	Return 
//End If

ls_where = ""
If ls_file_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "fileformcd='" + ls_file_code + "' "
End If

If ls_workno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "workno = '" +ls_workno + "' "
End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "status ='" + ls_status + "' "
End If

If ls_fdate <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(crtdt,'yyyymmdd') >='" + ls_fdate + "' "
End If

If ls_tdate <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(crtdt,'yyyymmdd') <='" + ls_tdate + "' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then
		F_GET_MSG(268, THIS.TITLE, '')
ElseIf ll_row < 0 Then
		F_GET_MSG(295, THIS.TITLE, '')
End If

// 수정후 dw_master 재 Retrieve
IF dw_master.Rowcount()  > 0  and ll_curRow = 0 Then ll_curRow = 1

if ll_curRow > 0  and dw_master.Rowcount() >= ll_curRow then
	ls_workno = String(dw_master.object.workno[ll_curRow])
	
	Choose Case li_tab_index
		Case 2
			ls_where = "a.workno = '" + ls_workno + "' "
		Case 4
			ls_where = "b.workno = '" + ls_workno + "' "
		Case Else
			ls_where = "workno = '" + ls_workno + "' "
	End Choose
		
	tab_1.idw_tabpage[li_tab_index].is_where = ls_where
	tab_1.idw_tabpage[li_tab_index].Retrieve()	
	
	dw_master.SelectRow(0,false)
	dw_master.SetRow(ll_curRow)
	dw_master.SelectRow(ll_curRow,true)
	dw_master.ScrollToRow(ll_curRow)
			
end if	
Return
end event

event ue_reset;call super::ue_reset;Constant Int LI_ERROR = -1
Int li_tab_index,li_rc
String ls_date

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

//작업일자 set
ls_date = String(fdt_get_dbserver_now(), 'yyyy-mm-dd')
dw_cond.Object.f_crtdt[1] = Date(ls_date)
dw_cond.Object.t_crtdt[1] = Date(ls_date)
dw_cond.SetFocus()

tab_1.enabled = True

ib_retrieve = FALSE

Return 0
end event

event type integer ue_save();//저장 버튼
//1
Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_nmtype, ls_idtype
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

		F_GET_MSG(215, tab_1.is_parent_title, '')

		ib_update = False
		Return -1
End Choose

If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller 	= "ROLLBACK"
	iu_cust_db_app.is_title 	= tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return LI_ERROR
	End If

	tab_1.idw_tabpage[li_tab_index].SetFocus()
	F_GET_MSG(215, tab_1.is_parent_title, '')

	Return LI_ERROR
End If

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller 	= "COMMIT"
iu_cust_db_app.is_title 	= tab_1.is_parent_title

iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

TriggerEvent('ue_ok')

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		

Return 0

end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_fileupload_result_v30
integer x = 55
integer width = 2816
integer height = 220
string dataobject = "b1dw_cnd_reg_fileupload_result_v30"
end type

event dw_cond::ue_init;//작업일자 set
this.Object.f_crtdt[1] = fdt_get_dbserver_now()
this.Object.t_crtdt[1] = fdt_get_dbserver_now()
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_fileupload_result_v30
integer x = 3067
integer y = 84
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_fileupload_result_v30
integer x = 3662
integer y = 84
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_fileupload_result_v30
integer y = 4
integer width = 2871
integer height = 276
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_fileupload_result_v30
integer y = 288
integer width = 3625
integer height = 584
string dataobject = "b1dw_reg_fileupload_result_log_v30"
end type

event dw_master::clicked;//Override
Integer li_SelectedTab
Long ll_selected_row
Long ll_old_selected_row
Int li_tab_index,li_rc
Date ld_sale_month
Decimal ll_exchange_rate, ll_margin_rate

String ls_customerid
Boolean lb_check1, lb_check2


If row = 0 then Return

ll_old_selected_row = This.GetSelectedRow(0)

Call w_a_m_master`dw_master::clicked

li_SelectedTab = tab_1.SelectedTab
ll_selected_row = This.GetSelectedRow(0)


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
Else
	//환율/마진 정보 체크 
	ld_sale_month = Date(this.Object.sale_month[row])
	
	If fs_snvl(String(ld_sale_month),' ')  <> ' ' Then	
		//환율정보 조회
		SELECT RATE INTO :ll_exchange_rate		
		  FROM EXCHANGERATE_CDR
		 WHERE 1=1
			AND FROMDT = (SELECT MAX(FROMDT) 
			                FROM EXCHANGERATE_CDR
                        WHERE FROMDT <= :ld_sale_month
							 )
							 ;
		
		If SQLCA.SQLCode <> 0 Then
			F_GET_MSG(295, title, '환율을 등록하여 주십시오.')	
			Return -1
		End If
		
		//마진정보 조회
		SELECT RATE INTO :ll_margin_rate		
		  FROM MARGIN_CDR
		 WHERE 1=1
			AND FROMDT = (SELECT MAX(FROMDT) 
			                FROM MARGIN_CDR
                        WHERE FROMDT <= :ld_sale_month
							 )
							 ;
		
		If SQLCA.SQLCode <> 0 Then
			F_GET_MSG(295, title, '마진율을 등록하여 주십시오.')	
			Return -1
		End If
		
		//환율, 마진 정보 설정
		dw_cond.Object.exchange_rate[1] = ll_exchange_rate;
		dw_cond.Object.margin_rate[1]   = ll_margin_rate;
	Else
		//환율, 마진 정보 초기화
		dw_cond.Object.exchange_rate[1] = "";
		dw_cond.Object.margin_rate[1]   = "";		
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
	p_reset.TriggerEvent('ue_enable')
	p_ok.TriggerEvent('ue_disable')
	dw_cond.Enabled =  False
End If

end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ib_sort_use = True
ldwo_SORT = Object.workno_t
//uf_init(ldwo_SORT)
uf_init( ldwo_sort , "D", RGB(0,0,128))

end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_fileupload_result_v30
boolean visible = false
integer y = 2020
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_fileupload_result_v30
integer x = 347
integer y = 2020
boolean enabled = true
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_fileupload_result_v30
integer x = 41
integer y = 2020
boolean enabled = true
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_fileupload_result_v30
integer x = 1175
integer y = 2020
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_fileupload_result_v30
integer width = 3625
integer height = 1060
end type

event tab_1::constructor;call super::constructor;// TAB 내의 DW Sort 기능 동작
// 2008. 02. 11 By JH
ib_sort2_use[3] = True
ib_sort2_use[4] = True
end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row, ll_exist, ll_workno, i
String  ls_type, ls_desc, ls_fileformcd, ls_data[], ls_i, ls_value, ls_remark, ls_find, ls_status
Boolean lb_check2
DataWindowChild ldwc_itemcod

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 
	

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	//cb_process.visible = False
	p_reset.TriggerEvent("ue_enable")
    Return 0
End If

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_disable")
		
//		If ls_status = is_status[1] Then
//		   p_save.TriggerEvent("ue_enable")
//		ElseIf ls_status = is_status[2] Then
//		   p_save.TriggerEvent("ue_enable")
//		ElseIf ls_status = is_status[3] Then
//		   p_save.TriggerEvent("ue_enable")
//		ElseIf ls_status = is_status[4] Then
//		   p_save.TriggerEvent("ue_disable")
//		End If
	Case 3, 4
		
		ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()
		ls_fileformcd = dw_master.Object.fileformcd[ll_master_row]
		ll_workno = dw_master.Object.workno[ll_master_row]
		
		 SELECT  name01,name02,name03,name04,name05,name06,name07,name08,name09,name10,
					name11,name12,name13,name14,name15,name16,name17,name18,name19,name20,
					name21,name22,name23,name24,name25,name26,name27,name28,name29,name30,
					name31,name32,name33,name34,name35,name36,name37,name38,name39,name40,
					name41,name42,name43,name44,name45,name46,name47,name48,name49,name50,
					name51,name52,name53,name54,name55,name56,name57,name58,name59,name60,
					name61,name62,name63,name64,name65,name66,name67,name68,name69,name70,
					name71,name72,name73,name74,name75,name76,name77,name78,name79,name80,
					name81,name82,name83,name84,name85,name86,name87,name88,name89,name90,
					name91,name92,name93,name94,name95,name96,name97,name98,name99,name100
		  INTO	 :ls_data[1] ,:ls_data[2] , :ls_data[3] ,:ls_data[4] ,:ls_data[5] ,:ls_data[6],:ls_data[7] ,:ls_data[8],:ls_data[9] ,:ls_data[10],
					:ls_data[11],:ls_data[12],:ls_data[13],:ls_data[14],:ls_data[15],:ls_data[16],:ls_data[17],:ls_data[18],:ls_data[19],:ls_data[20],
					:ls_data[21],:ls_data[22],:ls_data[23],:ls_data[24],:ls_data[25],:ls_data[26],:ls_data[27],:ls_data[28],:ls_data[29],:ls_data[30],
					:ls_data[31],:ls_data[32],:ls_data[33],:ls_data[34],:ls_data[35],:ls_data[36],:ls_data[37],:ls_data[38],:ls_data[39],:ls_data[40],
					:ls_data[41],:ls_data[42],:ls_data[43],:ls_data[44],:ls_data[45],:ls_data[46],:ls_data[47],:ls_data[48],:ls_data[49],:ls_data[50],
					:ls_data[51],:ls_data[52],:ls_data[53],:ls_data[54],:ls_data[55],:ls_data[56],:ls_data[57],:ls_data[58],:ls_data[59],:ls_data[60],
					:ls_data[61],:ls_data[62],:ls_data[63],:ls_data[64],:ls_data[65],:ls_data[66],:ls_data[67],:ls_data[68],:ls_data[69],:ls_data[70],
					:ls_data[71],:ls_data[72],:ls_data[73],:ls_data[74],:ls_data[75],:ls_data[76],:ls_data[77],:ls_data[78],:ls_data[79],:ls_data[80],
					:ls_data[81],:ls_data[82],:ls_data[83],:ls_data[84],:ls_data[85],:ls_data[86],:ls_data[87],:ls_data[88],:ls_data[89],:ls_data[90],
					:ls_data[91],:ls_data[92],:ls_data[93],:ls_data[94],:ls_data[95],:ls_data[96],:ls_data[97],:ls_data[98],:ls_data[99],:ls_data[100]
			 From REQUPLOAD_ORG_M 
			Where workno = :ll_workno ;
		
		tab_1.idw_tabpage[newindex].SetRedraw(False)
		FOR i = 1 TO UpperBound(ls_data[])
			
			SELECT REMARK
			  INTO :ls_remark
			  FROM REQFILEFORMDET
			 WHERE FILEFORMCD = :ls_fileformcd
				AND FILEITEM   = :ls_data[i];
				
				If SQLCA.SQLCODE = 100 THEN
					ls_find = 'N'
				ELSEIF SQLCA.SQLCODE < 0 THEN
					return -1
				ELSE
					ls_find = 'Y'
				END IF
								
				If LenA(String(i)) = 1 Then
					ls_i = '0'+String(i)
				Else
					ls_i = String(i)
				End If

				tab_1.idw_tabpage[newindex].Modify("value"+ls_i+"_t.Text="+"'"+ls_remark+"'")
				
				IF ls_find = 'N' THEN
					tab_1.idw_tabpage[newindex].Modify("value"+ls_i+"_t.visible= False")
					tab_1.idw_tabpage[newindex].Modify("value"+ls_i+".visible= False")
				ELSE
					tab_1.idw_tabpage[newindex].Modify("value"+ls_i+"_t.visible= True")
					tab_1.idw_tabpage[newindex].Modify("value"+ls_i+".visible= True")
				END IF
				
		NEXT
		tab_1.idw_tabpage[newindex].SetRedraw(True)
		
		p_insert.TriggerEvent("ue_disable")
		
		//에러페이지만 수정 가능
		IF newindex = 4 THEN
			p_delete.TriggerEvent("ue_enable")
			
			SELECT STATUS
			  INTO :ls_status
			  FROM REQUPLOAD_WORKLOG
			 WHERE WORKNO = :ll_workno;
			 
			//청구파일 청구파일 Upload 상태(처리완료;오류발생;원본데이터 수정;청구완료)
			//S;E;M;C
			If ls_status = is_status[1] Then
				p_save.TriggerEvent("ue_enable")
				//cb_process.visible = false
			ElseIf ls_status = is_status[2] Then
				p_save.TriggerEvent("ue_enable")
				//cb_process.visible = true
			ElseIf ls_status = is_status[3] Then
				p_save.TriggerEvent("ue_enable")
				//cb_process.visible = true
			ElseIf ls_status = is_status[4] Then
				//cb_process.visible = false
				p_save.TriggerEvent("ue_disable")
			End If			
		ELSE
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
		END IF

//		If ls_status = is_status[4] Then
//		   p_save.TriggerEvent("ue_disable")
//			cb_process.TriggerEvent("ue_disable")
//		ElseIf ls_status = is_status[1] Then
//		   p_save.TriggerEvent("ue_enable")
//			cb_process.TriggerEvent("ue_disable")
//		Else
//			cb_process.TriggerEvent("ue_enable")
//		   p_save.TriggerEvent("ue_enable")
//		End If
		
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0
	
end event

event type integer tab_1::ue_dw_buttonclicked(integer ai_tabpage, long al_row, long al_actionreturncode, dwobject adwo_dwo);call super::ue_dw_buttonclicked;//Butonn Click
Long i, ll_workno, ll_lineno
String ls_return


//에러내용을 수정하기위해 화면을 띄운다.
If ai_tabpage = 2 Then  
//	Choose Case adwo_dwo.name
//		Case "b_modify"
//			tab_1.idw_tabpage[2].AcceptText()
//			ll_workno = tab_1.idw_tabpage[2].object.workno[al_row]
//			ll_lineno = tab_1.idw_tabpage[2].object.lineno[al_row]
//		
//			iu_cust_msg = Create u_cust_a_msg
//			iu_cust_msg.is_pgm_name = "에러 내용수정"
//		
//			iu_cust_msg.idw_data[1] = dw_master
//			
//			OpenWithParm(b1w_reg_prepayment_termdelay_pop_v21, iu_cust_msg)
//
//			ls_return = Message.stringparm
//			
//	End Choose

End If


Return 0 
end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;If al_row  <> 0 then

   tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
	tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
End If

return 0
end event

event tab_1::ue_init();call super::ue_init;String    ls_code, ls_codenm, ls_yn, ls_dwnm
long    ll_chk, ll_cnt, i, ll_num, ll_n

//Tab 초기화
ii_enable_max_tab = 4		//Tab 갯수

DECLARE fileupload_cur CURSOR FOR
	SELECT CODE,
	       CODENM,
	       DWNM,
			 USE_YN
	  FROM TABINFO
	 WHERE GUBUN = 'fileupload_result'
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

////Tab Title
//is_tab_title[1] = "정상처리상세"
//is_tab_title[2] = "오류상세"
//
////Tab에 해당하는 dw
//is_dwObject[1] = "b1dw_reg_fileupload_ok_v30"
//is_dwObject[2] = "b1dw_reg_fileupload_err_v30"


end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;String ls_where, ls_workno, ls_status
Long ll_row

al_master_row = dw_master.GetSelectedRow(0)

If al_master_row = -1 Then Return -1
ls_status  = dw_master.object.status[al_master_row]
Choose Case ai_select_tabpage
	Case 1
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
		
		ls_workno = String(dw_master.Object.workno[al_master_row])
		
		ls_where = " workno = '" +ls_workno + "' "
		
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
		
	Case 2
		
		ls_workno = String(dw_master.Object.workno[al_master_row])
		
		ls_where = " a.workno = '" +ls_workno + "' "
		
		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
		
		If ll_row = 0 Then
         cb_process.enabled = False
		ElseIf ll_row < 0 Then
         	F_GET_MSG(295, Parent.TITLE, '')
			Return -1
		Else
			p_save.TriggerEvent('ue_enable')
         cb_process.enabled = True
		End If
		
		If ls_status = is_status[1] Then
		   p_save.TriggerEvent("ue_enable")
		ElseIf ls_status = is_status[2] Then
		   p_save.TriggerEvent("ue_enable")
		ElseIf ls_status = is_status[3] Then
		   p_save.TriggerEvent("ue_enable")
		ElseIf ls_status = is_status[4] Then
		   p_save.TriggerEvent("ue_disable")
		End If
	Case 3, 4
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
		
		ls_workno = String(dw_master.Object.workno[al_master_row])
		
		If ai_select_tabpage = 4 Then
			ls_where = " b.workno = '" +ls_workno + "' "
		Else
			ls_where = " workno = '" +ls_workno + "' "
		End If
		
		
		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
		
		If ll_row = 0 Then
         cb_process.enabled = False
		ElseIf ll_row < 0 Then
         	F_GET_MSG(295, Parent.TITLE, '')
			Return -1
		Else
			p_save.TriggerEvent('ue_enable')
         cb_process.enabled = True
		End If
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(True)
		
		If ls_status = is_status[1] Then
		   p_save.TriggerEvent("ue_enable")
		   p_delete.TriggerEvent("ue_enable")
		ElseIf ls_status = is_status[2] Then
		   p_save.TriggerEvent("ue_enable")
		   p_delete.TriggerEvent("ue_enable")
		ElseIf ls_status = is_status[3] Then
		   p_save.TriggerEvent("ue_enable")
		   p_delete.TriggerEvent("ue_enable")
		ElseIf ls_status = is_status[4] Then
		   p_save.TriggerEvent("ue_disable")
		   p_delete.TriggerEvent("ue_disable")
		End If			
End Choose
If tab_1.idw_tabpage[ai_select_tabpage].getrow() <> 0 then
	 tab_1.idw_tabpage[ai_select_tabpage].SelectRow( 1 ,TRUE)
End IF

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_fileupload_result_v30
end type

type p_saveas from u_p_saveas within b1w_reg_fileupload_result_v30
integer x = 654
integer y = 2020
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;
Long li_selected

li_selected = tab_1.Selectedtab
f_text_ascii1(tab_1.idw_tabpage[li_selected],'파일명을 입력하세요')
//ib_saveas = True
//idw_saveas = tab_1.idw_tabpage[li_selected]

//Boolean lb_return
//Integer li_return
//String ls_curdir
//u_api lu_api
//
//If tab_1.idw_tabpage[li_selected].RowCount() <= 0 Then
//	f_msg_info(1000, Title, "Data exporting")
//	Return
//End If
//
//lu_api = Create u_api
//ls_curdir = lu_api.uf_getcurrentdirectorya()
//If IsNull(ls_curdir) Or ls_curdir = "" Then
//	f_msg_info(9000, Title, "Can't get the Information of current directory.")
//	Destroy lu_api
//	Return
//End If
//
//li_return = tab_1.idw_tabpage[li_selected].SaveAs("", text!, True)
//
//lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
//If li_return <> 1 Then
//	f_msg_info(9000, Title, "User cancel current job.")
//Else
//	f_msg_info(9000, Title, "Data export finished.")
//End If
//
//Destroy lu_api
//
end event

type p_2 from u_p_delete within b1w_reg_fileupload_result_v30
integer x = 3365
integer y = 84
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Long ll_workno, i, ll_rc, ll_count

   
ll_rc = F_GET_QUES(319 , Title, "", "YesNo!")   //삭제하시겠습니까?
	
If ll_rc <> 1 Then
	Return -1
End If

For i = 1 To dw_master.Rowcount()
	If dw_master.Object.check_flag[i] = 'Y' Then
		ll_workno = dw_master.Object.workno[i]
		ll_count ++
		
		If dw_master.Object.status[i] = is_status[4] Then	//데이터삭제(C)
			F_GET_MSG(151, tab_1.is_parent_title, '')	//이미 처리되었습니다.
			Return
		End If
		
		//삭제처리한 row의 상태를 데이터삭제(C)상태로 바꿈.
		UPDATE REQUPLOAD_WORKLOG 
		   SET status = :is_status[4]	
		 WHERE workno = :ll_workno;
		 
		If SQLCA.SQLCode < 0 Then
			F_GET_MSG(201, tab_1.is_parent_title, SQLCA.SQLErrText)
			RollBack;
			Return -1
		End If
		
		//삭제처리된 것의 requpload_ok, requpload_err자료삭제 (이중과금방지)
		//2007.11.08 by kes
		DELETE FROM REQUPLOAD_OK
		 WHERE workno = :ll_workno;
		 
		If SQLCA.SQLCode < 0 Then
			F_GET_MSG(201, tab_1.is_parent_title, SQLCA.SQLErrText)
			RollBack;
			Return -1
		End If
		
		DELETE FROM REQUPLOAD_ERR
		 WHERE workno = :ll_workno;
		 
		If SQLCA.SQLCode < 0 Then
			F_GET_MSG(201, tab_1.is_parent_title, SQLCA.SQLErrText)
			RollBack;
			Return -1
		End If		
		 
	End If
Next

If ll_count = 0 Then
	F_GET_MSG(103, tab_1.is_parent_title, '')
	Return
End If

If SQLCA.SQLCODE = 0 THEN
	F_GET_MSG(214, tab_1.is_parent_title, '')
	COMMIT;
ELSE
	F_GET_MSG(215, tab_1.is_parent_title, '')
	ROLLBACK;
END IF


dw_cond.object.workno[1] = ll_workno

parent.TriggerEvent("ue_ok")		//조회
end event

type cb_process from commandbutton within b1w_reg_fileupload_result_v30
boolean visible = false
integer x = 1632
integer y = 2020
integer width = 343
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
end type

event clicked;
String ls_errmsg, ls_fileformcd, ls_trdt, ls_customerid, ls_customernm 
Long   ll_rc, ll_workno, LI_ERROR, ll_check_cnt
double lb_count, ll_return


//li_tab_index = tab_1.SelectedTab
ll_return 		= -1
ls_errmsg 		= space(800)
//ls_fileformcd  	= dw_cond.Object.file_code[1]
ls_fileformcd  	= dw_master.object.fileformcd[dw_master.GetSelectedRow(0)]
ll_workno      	= dw_master.Object.workno[dw_master.GetSelectedRow(0)]
ls_trdt        	= String(dw_master.Object.sale_month[dw_master.GetSelectedRow(0)],'yyyymmdd')

//에러에서 저장후 넘어 올때를 대비해서 한번더 찾는다
//체크항목중 고객과 인증키의 일치체크가 있는지 찾는다
SELECT Count(*)	INTO :ll_check_cnt		FROM FILEDATACHECK
 WHERE fileformcd 		= :ls_fileformcd
   AND CHECK_CD   		= :is_checklist[2];

//체크항목중 고객과 인증키의 일치체크가 있을때만 찾는다 - UBS는 upload파일에 고객키가 없기 때문에, 사용하지 않는다.
If ll_check_cnt <> 0 Then
	//고객키(그룹통합코드) 멥핑항목을 찾는다
	is_customerid = 'N'
	
	// 고객키(납부자명) 멥핑항목을 찾는다
	is_customernm = 'N'
End If

//처리부분...
//SQLCA.B1W_INV_FILEUPLOAD_REP(ll_workno, ls_trdt, ls_fileformcd, is_customerid, is_customernm, gs_user_id, ll_return, ls_errmsg, lb_count)
SQLCA.B1W_INV_FILEUPLOAD(ll_workno, ls_trdt, ls_fileformcd, is_customerid, is_customernm, gs_user_id, ll_return, ls_errmsg, lb_count)

ll_rc = ll_return

If ll_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller 	= "ROLLBACK"
	iu_cust_db_app.is_title 	= PARENT.TITLE

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		Return LI_ERROR
	End If
	
	F_GET_MSG(215, tab_1.is_parent_title, '')
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = parent.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		Return LI_ERROR
	End If
	
	dw_cond.object.workno[1] = ll_workno
	
	parent.TriggerEvent("ue_ok")		//조회-------
	
	If ll_rc = -2 Then //비정상적인 데이타로 인해 에러는 났지만 저장한 한다. 대신 메세지는 에러라고 함
		//f_msg_info(3010,parent.Title,"Save")
		F_GET_MSG(439, tab_1.is_parent_title, '')
	Else
		//_msg_info(3000,parent.Title,"Save")
		F_GET_MSG(214, tab_1.is_parent_title, '')
	End If
	
End if

Return 0

end event

event constructor;
cb_process.text = f_get_msginfo(446)
end event

