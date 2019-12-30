$PBExportHeader$p1w_reg_master_v20.srw
$PBExportComments$[ohj] 선불카드관리 Window v20
forward
global type p1w_reg_master_v20 from w_a_reg_m_tm2
end type
type p_find from u_p_find within p1w_reg_master_v20
end type
type dw_workdt from u_d_help within p1w_reg_master_v20
end type
end forward

global type p1w_reg_master_v20 from w_a_reg_m_tm2
integer width = 3717
integer height = 2080
event ue_find ( )
p_find p_find
dw_workdt dw_workdt
end type
global p1w_reg_master_v20 p1w_reg_master_v20

type variables
String is_format
end variables

forward prototypes
public subroutine of_resizepanels ()
protected function integer wf_cdr_inq (string as_validkey, string as_workdt_fr, string as_workdt_to, readonly datawindow as_dw)
end prototypes

event ue_find();Long ll_rc, ll_selrow, ll_row
Integer li_curtab, li_return
String ls_where, ls_pid, ls_contno, ls_sale_month
String ls_workdt_fr, ls_workdt_to, ls_validkey, ls_rtelnum

dw_workdt.AcceptText()

li_curtab = tab_1.selectedtab
ll_selrow = dw_master.GetSelectedRow(0)
If Not (ll_selrow > 0) Then Return
ls_pid = dw_master.Object.pid[ll_selrow]
If IsNull(ls_pid) Or ls_pid = "" Then Return
//ls_validkey = dw_master.Object.pid[ll_selrow]
//If IsNull(ls_validkey) Or ls_validkey = "" Then Return
ls_contno = dw_master.Object.contno[ll_selrow]
If IsNull(ls_contno) Or ls_contno = "" Then Return

Choose Case li_curtab
	Case 2	//일자별CDR조회
		tab_1.idw_tabpage[li_curtab].Object.pid.Text = ls_pid
		tab_1.idw_tabpage[li_curtab].Object.contno.Text = ls_contno
		
	
		//필수입력사항 check
//		If ls_validkey = "" Then
//			RETURN
//		End If
		
		ls_workdt_fr = String(dw_workdt.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_workdt.Object.workdt_to[1], "yyyymmdd")
		
		
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
				
		//***** 사용자 입력사항 검증 *****
		If ls_workdt_fr = "" Then
			f_msg_info(200, Title, "일자(From)")
			dw_workdt.setfocus()
			dw_workdt.SetColumn("workdt_fr")
			Return
		End If
		
		If ls_workdt_to = "" Then
			f_msg_info(200, Title, "일자(To)")
			dw_workdt.setfocus()
			dw_workdt.SetColumn("workdt_to")
			Return
		End If
		
		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(210, Title, "일자(From) <= 일자(To)")
					Return
				End If
			End If
		End If
		
		tab_1.idw_tabpage[li_curtab].setredraw(False)
		
		If wf_cdr_inq(ls_pid, ls_workdt_fr, ls_workdt_to, tab_1.idw_tabpage[li_curtab]) = -1 Then
			return
		End if
		
		tab_1.idw_tabpage[li_curtab].setredraw(True)
		
		If tab_1.idw_tabpage[li_curtab].rowcount() = 0 Then
			f_msg_info(1000, Title, "")
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetitemStatus(1, 0, Primary!, NotModified!)

	Case 3	//정산CDR조회
		tab_1.idw_tabpage[li_curtab].Object.pid.Text = ls_pid
		tab_1.idw_tabpage[li_curtab].Object.contno.Text = ls_contno
				
		//필수입력사항 check
		If ls_pid = "" Then
			RETURN
		End If
		
		ls_workdt_fr = String(dw_workdt.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_workdt.Object.workdt_to[1], "yyyymmdd")
		
		
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
				
		//***** 사용자 입력사항 검증 *****
		If ls_workdt_fr = "" Then
			f_msg_info(200, Title, "일자(From)")
			dw_workdt.setfocus()
			dw_workdt.SetColumn("workdt_fr")
			Return
		End If
		
		If ls_workdt_to = "" Then
			f_msg_info(200, Title, "일자(To)")
			dw_workdt.setfocus()
			dw_workdt.SetColumn("workdt_to")
			Return
		End If
		
		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(210, Title, "일자(From) <= 일자(To)")
					Return
				End If
			End If
		End If
		
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where		
		ll_row = tab_1.idw_tabpage[li_curtab].Retrieve(ls_pid,ls_workdt_fr,ls_workdt_to)	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return
		End If
		
		If tab_1.idw_tabpage[li_curtab].rowcount() = 0 Then
			f_msg_info(1000, Title, "")
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetitemStatus(1, 0, Primary!, NotModified!)
End Choose
end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.
Integer	li_index

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

For li_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_index].Height = tab_1.Height - 125
Next

end subroutine

protected function integer wf_cdr_inq (string as_validkey, string as_workdt_fr, string as_workdt_to, readonly datawindow as_dw);//**   Argument :
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1
String ls_where, ls_rtelnum, ls_seqno
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
DateTime ldt_stime, ldt_etime, ldt_crtdt
Dec ldc_bilamt
String ls_yyyymmdd
String ls_areacod, ls_pid

ll_insrow = 0

ls_type = 'PRE_CDR'

ls_pid = as_validkey
If Isnull(ls_pid) Then ls_pid = ""
If ls_pid = "" then
	
	RETURN -1
End if

// 선불카드인 경우에는 pid로 조회 
ls_where = "WHERE pid = '" + ls_pid + "'"


DECLARE cur_read_cdr_table DYNAMIC CURSOR FOR SQLSA;
DECLARE cur_read_cdr DYNAMIC CURSOR FOR SQLSA;

ls_sql = "SELECT tname " + &
			"FROM tab " + &
			"WHERE tabtype = 'TABLE' " + &
			" AND " + "tname >= '" + ls_type + as_workdt_fr + "' " + &
			" AND " + "tname <= '" + ls_type + as_workdt_to + "' "  + &
			" AND " + "substr(tname,1,7) = '" + LeftA(ls_type,7) + "'"  + &
		    " AND LENGTH(TNAME) = 15 " + &
			" ORDER BY tname DESC"
	
PREPARE SQLSA FROM :ls_sql;
OPEN DYNAMIC cur_read_cdr_table;

//DW 초기화
ll_rows = as_dw.RowCount()
If ll_rows > 0 Then as_dw.RowsDiscard(1, ll_rows, Primary!)
ll_rows = 0

Do While(True)
	FETCH cur_read_cdr_table
	INTO :ls_tname;

	If SQLCA.SQLCode < 0 Then
		clipboard(ls_sql)
		f_msg_sql_err(title, " cur_read_cdr_table")
		CLOSE cur_read_cdr_table;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If

		  
	//검색된 테이블에서 자료를 읽기
	ls_sql_1 = " SELECT to_char(SEQNO), YYYYMMDD, STIME, BILTIME, NODENO, RTELNUM, AREACOD, BILAMT, CRTDT" + &
			    " FROM " + ls_tname + " " + &
				 + ls_where + &
			  " ORDER BY STIME DESC "
			  

	PREPARE SQLSA FROM :ls_sql_1;
	OPEN DYNAMIC cur_read_cdr;

	Do While True
		FETCH cur_read_cdr
		INTO :ls_seqno, :ls_yyyymmdd, :ldt_stime, :ll_biltime,
		     :ls_nodeno, :ls_rtelnum, :ls_areacod, :ldc_bilamt, :ldt_crtdt;
		 
		If SQLCA.SQLCode < 0 Then
			clipboard(ls_sql)			
			f_msg_sql_err(title, "cur_read_cdr")
			CLOSE cur_read_cdr;
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
		End If

		ll_insrow = as_dw.InsertRow(0)
		as_dw.Object.seqno[ll_insrow] = ls_seqno   			
		as_dw.Object.yyyymmdd[ll_insrow] = ls_yyyymmdd
		as_dw.Object.stime[ll_insrow] = ldt_stime
		as_dw.Object.biltime[ll_insrow] = ll_biltime
		as_dw.Object.nodeno[ll_insrow] = ls_nodeno
		as_dw.Object.rtelnum[ll_insrow] = ls_rtelnum
		as_dw.Object.areacod[ll_insrow] = ls_areacod
		as_dw.Object.bilamt[ll_insrow] = ldc_bilamt
		as_dw.Object.crtdt[ll_insrow] = ldt_crtdt
//		as_dw.SetItemStatus(ll_insrow, 0, Primary!, NotModified!)
		ll_rows++
	Loop
	CLOSE cur_read_cdr ;
Loop
CLOSE cur_read_cdr_table;

If ll_insrow > 0 Then
	as_dw.SetSort("SEQNO D")
	as_dw.Sort()
End If

return 1
end function

on p1w_reg_master_v20.create
int iCurrent
call super::create
this.p_find=create p_find
this.dw_workdt=create dw_workdt
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_find
this.Control[iCurrent+2]=this.dw_workdt
end on

on p1w_reg_master_v20.destroy
call super::destroy
destroy(this.p_find)
destroy(this.dw_workdt)
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	p1w_reg_master
	Desc.	:	Card Master 수정조회
	Ver	: 	1.0
	Date	: 	2003.05.16
	Prgromer : Choo Youn Shik (chooys)
---------------------------------------------------------------------------*/
String ls_ref_desc

//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[5].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[6].SetRowFocusIndicator(off!)


dw_workdt.Object.workdt_fr[1] = Date(fdt_get_dbserver_now())
dw_workdt.Object.workdt_to[1] = Date(fdt_get_dbserver_now())
dw_workdt.visible = FALSE
p_find.TriggerEvent("ue_disable")

is_format = fs_get_control('B1', 'Z200', ls_ref_desc)

end event

event ue_ok();call super::ue_ok;//조회
String ls_pid
String ls_contnofr
String ls_contnoto
String ls_status
String ls_issuedtfr
String ls_issuedtto
String ls_partner
String ls_model
String ls_lotno
String ls_priceplan
String ls_validkey
Long ll_row
String ls_where


ls_pid = Trim(dw_cond.object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contnofr = Trim(dw_cond.object.contno_from[1])
If IsNull(ls_contnofr) Then ls_contnofr = ""

ls_contnoto = Trim(dw_cond.object.contno_to[1])
If IsNull(ls_contnoto) Then ls_contnoto = ""

ls_status = Trim(dw_cond.object.status[1])
If IsNull(ls_status) Then ls_status = ""

ls_issuedtfr = String(dw_cond.object.issuedt_from[1],"YYYYMMDD")
If IsNull(ls_issuedtfr) Then ls_issuedtfr = ""

ls_issuedtto = String(dw_cond.object.issuedt_to[1],"YYYYMMDD")
If IsNull(ls_issuedtto) Then ls_issuedtto = ""

ls_partner = Trim(dw_cond.object.partner[1])
If IsNull(ls_partner) Then ls_partner = ""

ls_model = Trim(dw_cond.object.pricemodel[1])
If IsNull(ls_model) Then ls_model = ""

ls_lotno = Trim(dw_cond.object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_priceplan = Trim(dw_cond.object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""

ls_validkey = Trim(dw_cond.object.validkey[1])
If IsNull(ls_validkey) Then ls_validkey = ""

 

If ls_issuedtfr > ls_issuedtto Then
	f_msg_usr_err(210, Title, "발행일시작 <= 발행일종료")
	dw_cond.SetFocus()
	dw_cond.setColumn("issuedt_from")
	Return 
End If


IF ls_pid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pid = '"+ ls_pid +"'"
END IF

IF ls_contnofr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.contno >= '"+ ls_contnofr +"'"
END IF

IF ls_contnoto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.contno <= '"+ ls_contnoto +"'"
END IF

IF ls_status <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.status = '"+ ls_status +"'"
END IF

IF ls_issuedtfr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(p_cardmst.issuedt,'YYYYMMDD') >= '"+ ls_issuedtfr +"'"
END IF

IF ls_issuedtto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(p_cardmst.issuedt,'YYYYMMDD') <= '"+ ls_issuedtto +"'"
END IF

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.partner_prefix = '"+ ls_partner +"'"
END IF

IF ls_model <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pricemodel = '"+ ls_model +"'"
END IF

IF ls_lotno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.lotno = '"+ ls_lotno +"'"
END IF

IF ls_priceplan <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.priceplan = '"+ ls_priceplan +"'"
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pid in (select pid from validinfo where svctype = (select ref_content from sysctl1t where module = 'P0' and ref_no = 'P100') and validkey = '"+ ls_validkey +"')"
END IF

If ls_where = "" Then
	f_msg_info(200, Title, "1가지 이상 조회 조건")
	dw_cond.SetFocus()
	dw_cond.setColumn("pid")
	Return 
End If


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")			
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
Else			
	//검색을 찾으면 Tab를 활성화 시킨다.
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
End If

end event

event resize;call super::resize;dw_workdt.Y = p_insert.Y
p_find.Y = p_insert.Y

end event

event closequery;//조상스크립트 막음...

//Int li_tab_index, li_rc
Integer li_return
Integer li_curtab

If tab_1.ii_enable_max_tab <= 0 Then Return 0

li_curtab = tab_1.SelectedTab
If li_curtab = 1 Then
	tab_1.idw_tabpage[li_curtab].AcceptText() 
	If (tab_1.idw_tabpage[li_curtab].ModifiedCount() > 0) or &
		(tab_1.idw_tabpage[li_curtab].DeletedCount() > 0)	Then
		li_return = MessageBox(Tab_1.is_parent_title, "Data is Modified.! Do you want to cancel?" &
							,Question!,YesNo!)
		If li_return <> 1 Then Return 1
	End If
End IF
end event

event ue_extra_insert;call super::ue_extra_insert;//Insert시 조건
//Dec lc_troubleno
//Dec lc_num
Long ll_master_row , i, ll_row
String ls_pid

ll_master_row = dw_master.GetRow()

Choose Case ai_selected_tab
						
	Case 6
		ls_pid = dw_master.object.pid[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.pid[al_insert_row]      = ls_pid
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
		tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
End Choose

Return 0 
end event

event ue_insert;Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 6
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)	
		
End Choose

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0
end event

event ue_reset;call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("pid")
tab_1.SelectedTab = 1
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
Return 0 
end event

event ue_save;Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_partner
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

		f_msg_info(3010, tab_1.is_parent_title, "Save")
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

	tab_1.SelectedTab = li_tab_index
	tab_1.idw_tabpage[li_tab_index].SetFocus()
	f_msg_info(3010,tab_1.is_parent_title,"Save")
	Return LI_ERROR
End If

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")


Return 0
end event

event ue_extra_save;call super::ue_extra_save;//Save
String ls_hotkey, ls_rtelno
Long ll_row, ll_len, ll_len_1, ll_cnt
Integer li_rc, ll_i, i

//Long ll_rows, ll_findrow, ll_zoncodcnt
//String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype, ls_areanum, ls_itemcod
//String ls_date, ls_sort
//Dec lc_data, lc_frpoint, lc_Ofrpoint
//
//String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt
//Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
//String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
//Boolean lb_addX, lb_notExist
//Constant Integer li_MAXTMKIND = 3
//
//String ls_parttype1, ls_partcod1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
//String ls_parttype2, ls_partcod2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
//Long   ll_rows1, ll_rows2


//Row 수가 없으면aasaa
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

Choose Case ai_select_tab
	Case 6
		
		
		tab_1.idw_tabpage[ai_select_tab].AcceptText()
		//필수 Check
		ls_hotkey = Trim(tab_1.idw_tabpage[ai_select_tab].object.hotkey[ll_row])
		ls_rtelno = Trim(tab_1.idw_tabpage[ai_select_tab].object.rtelno[ll_row])
		
		If IsNull(ls_hotkey) Then ls_hotkey = ""
		If IsNull(ls_rtelno) Then ls_rtelno = ""
				
//		If ls_partner = "" Then
//			f_msg_usr_err(200, title, "대리점코드")
//			tab_1.idw_tabpage[ai_select_tab].SetFocus()
//			tab_1.idw_tabpage[ai_select_tab].SetColumn("partner")
//			return -2
//		End If
		
//		ll_cnt = 0
//		select count(*)
//		  into :ll_cnt
//		  from partnermst
// 		 where partner = :ls_partner
//		   and partner <> :ls_partner;
//		  
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "대리점 코드 check")
//			RollBack;
//			Return -1
//		End If				
//		
//		If ll_cnt <> 0 Then
//			f_msg_usr_err(9000, Title, "이미 사용중인 대리점코드입니다. 다시 입력하세요!!")  //삭제 안됨 
//			tab_1.idw_tabpage[ai_select_tab].SetFocus()
//			tab_1.idw_tabpage[ai_select_tab].SetColumn("partner")
//			return -2
//		End If

		If ls_hotkey = "" Then
			f_msg_usr_err(200, title, "단축key")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("hotkey")
			Return -2
		End If

		If ls_rtelno = "" Then
			f_msg_usr_err(200, title, "rtelno")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("rtelno")
			Return -2
		End If

		
		
//		If ib_new = True Then		//신규
//		
////			ll_cnt = 0
////			select count(*)
////			  into :ll_cnt
////			  from partnermst
////			 where partner = :ls_partner;
////			  
////			If SQLCA.SQLCode < 0 Then
////				f_msg_sql_err(This.Title, "대리점 코드 check")
////				RollBack;
////				Return -1
////			End If				
////			
////			If ll_cnt <> 0 Then
////				f_msg_usr_err(9000, Title, "이미 사용중인 대리점코드입니다. 다시 입력하세요!!")  //삭제 안됨 
////				tab_1.idw_tabpage[ai_select_tab].SetFocus()
////				tab_1.idw_tabpage[ai_select_tab].SetColumn("partner")
////				return -2
////			End If
//			
//			ll_cnt = 0
//			select count(*)
//			  into :ll_cnt
//			  from partnermst
//			 where partner_type = '0'
//				and levelcod = (select max(code)
//										from syscod2t
//									 where grcode = 'A100' and use_yn = 'Y' 
//									   and code < :ls_levelcod )
//				and partner = :ls_hpartner;
//			  
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(This.Title, "상위대리점 check")
//				RollBack;
//				Return -1
//			End If
//			
//			If ll_cnt = 0 Then
//				f_msg_usr_err(9000, Title, "입력하신 상위대리점은 levelcod가 틀립니다.!!")  //삭제 안됨 
//				tab_1.idw_tabpage[ai_select_tab].SetFocus()
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("hpartner")
//				Return -2
//			End If
//
//			ll_cnt = 0
//			select count(*)
//			  into :ll_cnt
//			  from partnermst
//			 where logid = :ls_logid;
//			  
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(This.Title, "logid check")
//				Return -1
//			End If				
//			
//			If ll_cnt <> 0 Then
//				f_msg_usr_err(9000, Title, "이미 사용중인 logid입니다. 다시 입력하세요!!")  //삭제 안됨 
//				tab_1.idw_tabpage[ai_select_tab].SetFocus()
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("logid")
//				Return -2
//			End If
//		
//		   select prefixno,
//			       length(prefixno)
//			  into :ls_hprefixno,
//			  		 :ll_len
//   		  from partnermst
//			 where partner = :ls_hpartner
//			   and partner_type = '0';
//			 
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(title, "상위대리점 관리코드 select")
//				Return -1
//			End If				
//			
//			IF ll_len >= 60 Then
//				f_msg_usr_err(9000, Title, "입력불가!! 관리코드 생성범위 초과!!~r~n~r~n데이타베이스관리자에게 문의하세요!! ")  //생성불가
//				return -2
//			End If
//			
//			//상위대리점 관리코드가 본사영업본부 관리코드랑 같으면... 첫 셋팅!
//			If ls_hprefixno = is_root Then
//				ll_len = 0
//				ls_hprefixno = ''
//			End if
//			
//			ll_len_1 = ll_len + 1
//		   ls_hprefixno_1 = ls_hprefixno + "%"
//			
//			SELECT to_char(:ls_hprefixno||to_char(to_number(nvl(max(substr(prefixno,:ll_len_1,3)),'100'))+1))
//			 into :ls_prefixno
//			 FROM partnermst 
//	      WHERE prefixno like :ls_hprefixno_1
//			 and prefixno <> :is_root
//			 and partner_type = '0';
//			
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(title, "관리코드 생성")
//				Return -1
//			End If				
//
//			tab_1.idw_tabpage[ai_select_tab].object.prefixno[ll_row] = ls_prefixno
//			
//			//partner seq 가져 오기
//			Select 'A'|| to_char(seq_partnerno.nextval)
//			Into :ls_partner
//			From dual;
//			
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(title, "SELECT seq_partnerno.nextval")			
//				Return -1
//			End If	
//			
//			tab_1.idw_tabpage[ai_select_tab].object.partner[ll_row] = ls_partner
//			
//		End if
//		
//	Case 3
//
//		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
//		For ll_i = 1 To ll_row
//		
//			tab_1.idw_tabpage[ai_select_tab].AcceptText()
//	
//			//유형 체크
//			ls_bondtype	= Trim(tab_1.idw_tabpage[ai_select_tab].Object.bondtype[ll_i])
//			IF IsNull(ls_bondtype) THEN ls_bondtype = ""
//		
//			IF ls_bondtype = "" THEN
//				f_msg_usr_err(200, Title, "유형")
//				tab_1.idw_tabpage[ai_select_tab].setColumn("bondtype")
//				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
//				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
//				tab_1.idw_tabpage[ai_select_tab].setFocus()
//				RETURN -2
//			END IF
//			
//			//적용시작일 체크
//			ls_fromdt	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.fromdt[ll_i],'yyyymmdd'))
//			IF IsNull(ls_fromdt) THEN ls_fromdt = ""
//		
//			IF ls_fromdt = "" THEN
//				f_msg_usr_err(200, Title, "적용시작일")
//				tab_1.idw_tabpage[ai_select_tab].setColumn("fromdt")
//				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
//				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
//				tab_1.idw_tabpage[ai_select_tab].setFocus()
//				RETURN -2
//			END IF
//
//			//적용종료일 체크
//			ls_todt	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.todt[ll_i],'yyyymmdd'))
//			IF IsNull(ls_todt) THEN ls_todt = ""
//			
//			IF ls_todt <> "" THEN
//				If ls_fromdt > ls_todt THEN
//					f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//					tab_1.idw_tabpage[ai_select_tab].setColumn("todt")
//					tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
//					tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
//					tab_1.idw_tabpage[ai_select_tab].setFocus()
//					RETURN -2
//				END IF
//			END IF
//			
//			//금액 체크
//			ls_bondamt	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.bondamt[ll_i]))
//			IF IsNull(ls_bondamt) THEN ls_bondamt = ""
//		
//			IF ls_bondamt = "" THEN
//				f_msg_usr_err(200, Title, "금액")
//				tab_1.idw_tabpage[ai_select_tab].setColumn("bondamt")
//				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
//				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
//				tab_1.idw_tabpage[ai_select_tab].setFocus()
//				RETURN -2
//			END IF
//	
//			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[ai_select_tab].object.upd_user[ll_i] = gs_user_id	
//				tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_i] = fdt_get_dbserver_now()
//			End If
//	   Next
//		
//	Case 4
//		If tab_1.idw_tabpage[ai_select_tab].RowCount()  = 0 Then Return 0
//
//		//  대역/시간대코드/개시일자
//		ls_Ozoncod = ""
//		ls_Otmcod  = ""
//		ls_tmcodX = ""
//		li_tmcodcnt = 0
//		li_cnt_tmkind = 0
//
//		//해당 priceplan 찾기
//		ls_priceplan = 'ALL'
//
//		//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
//		li_return = wfl_get_arezoncod(ls_zoncod, ls_arezoncod[])
//		If li_return < 0 Then Return -2
//
//		ll_rows = tab_1.idw_tabpage[ai_select_tab].RowCount()
//		If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0
//	
//
//		//정리하기 위해서 Sort
//		tab_1.idw_tabpage[ai_select_tab].SetRedraw(False)
//		ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
//		tab_1.idw_tabpage[ai_select_tab].SetSort(ls_sort)
//		tab_1.idw_tabpage[ai_select_tab].Sort()
//
//
//		For ll_row = 1 To ll_rows
//			ls_zoncod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.zoncod[ll_row])
//			ls_opendt = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_row],'yyyymmdd')
//			ls_tmcod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.tmcod[ll_row])
//			ls_areanum = Trim(tab_1.idw_tabpage[ai_select_tab].Object.areanum[ll_row])
//			ls_itemcod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.itemcod[ll_row])
//			
//			If IsNull(ls_zoncod) Then ls_zoncod = ""
//			If IsNull(ls_opendt) Then ls_opendt = ""
//			If IsNull(ls_tmcod) Then ls_tmcod = ""
//			If IsNull(ls_areanum) Then ls_areanum = ""
//			If IsNull(ls_itemcod) Then ls_itemcod = ""
//			
//		   //필수 항목 check 
//			If ls_zoncod = "" Then
//				f_msg_usr_err(200, Title, "대역")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("zoncod")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//	
//			If ls_opendt = "" Then
//				f_msg_usr_err(200, Title, "적용개시일")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("opendt")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//			
//			If ls_areanum = "" Then
//				f_msg_usr_err(200, Title, "착신지번호")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("areanum")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//	
//			If ls_tmcod = "" Then
//				f_msg_usr_err(200, Title, "시간대")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//
//			//시작Point - khpark 추가 -
//			lc_frpoint = tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row]
//			If IsNull(lc_frpoint) Then tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row] = 0
//	
//			If tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row] < 0 Then
//				f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("frpoint")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//			
//			If ls_itemcod = "" Then
//				f_msg_usr_err(200, Title, "품목")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("itemcod")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//			
//			If tab_1.idw_tabpage[ai_select_tab].Object.unitsec[ll_row] = 0 Then
//				f_msg_usr_err(200, Title, "기본시간")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("unitsec")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//	
//			If tab_1.idw_tabpage[ai_select_tab].Object.unitfee[ll_row] < 0 Then
//				f_msg_usr_err(200, Title, "기본요금")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("unitfee")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//	
//			If tab_1.idw_tabpage[ai_select_tab].Object.munitsec[ll_row] = 0 Then
//				f_msg_usr_err(200, Title, "기본시간(멘트)")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("munitsec")
//				tab_1.idw_tabpage[ai_select_tab].Object.DataWindow.HorizontalScrollPosition='10000'
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//			
//			If tab_1.idw_tabpage[ai_select_tab].Object.munitfee[ll_row] < 0 Then
//				f_msg_usr_err(200, Title, "기본요금(멘트)")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("munitfee")
//				tab_1.idw_tabpage[ai_select_tab].Object.DataWindow.HorizontalScrollPosition='10000'
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//	
//			// 1 zoncod가 같으면 
//			If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
//				
//				//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
//				If Mid(ls_tmcod, 2, 1) <> Mid(ls_Otmcod, 2, 1) Then
//					f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
//					tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
//					tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//					tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//					Return -2
//			
//				ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
//					li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
//				End If	// 2 close						
//	
//			// 1 else	
//			Else
//				//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
//				If lb_notExist = False Then
//					lb_notExist = True
//					For ll_i = 1 To UpperBound(ls_arezoncod)
//						If ls_arezoncod[ll_i] = ls_zoncod Then 
//							lb_notExist = False
//							Exit
//						End If
//					Next
//				End If	 // 3 close	
//			  If ls_Ozoncod <>  ls_zoncod Then 
//					ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
//				End If
//				  
//				// 4 zonecod가  바뀌었거나 처음 row 일때
//				// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
//				If ll_row > 1 Then
//					
//					If ls_tmcodX <> 'X' and Len(ls_tmcodX) <> li_MAXTMKIND Then
//						f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
//						tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
//						tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row - 1)
//						tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row - 1)
//						tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//						Return -2
//					End If 
//					
//					li_rtmcnt = -1
//					//이미 Select됐된 시간대인지 Check
//					For li_i = 1 To li_cnt_tmkind
//						If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
//					Next
//				
//					// 5 tmcod에 해당 pricecod 별로 tmcod check
//					If li_rtmcnt < 0 Then
//						li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
//						If li_return < 0 Then 
//							tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//							Return -2
//						End If
//						
//						li_cnt_tmkind += 1
//						ls_tmkind[li_cnt_tmkind,1] = Left(ls_Otmcod, 2)
//						ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
//					End If // 5 close
//					
//					//누락된 시간대코드가 없는지 Check
//					If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//						f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
//						tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
//						tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row - 1)
//						tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row - 1)
//						tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//						Return -2
//					End If
//			
//					li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
//					 ls_tmcodX = ""
//				Else // 4 else	 
//					li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
//					
//				End If // 4 close
//			End If // 1 close ls_Ozoncod = ls_zoncod 조건 
//			
//			// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
//			If Left(ls_tmcod, 1) = 'X' Then
//				If Len(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
//					f_msg_usr_err(9000, Title, "모든 시간대는 다른 시간대랑 같이 사용 할 수 없습니다." )
//					tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
//					tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//					tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//					Return -2
//				ElseIf Len(ls_tmcodX) = 0 Then 
//					ls_tmcodX += Left(ls_tmcod, 1)
//				End If
//			Else
//				lb_addX = True
//				For li_i = 1 To Len(ls_tmcodX)
//					If Mid(ls_tmcodX, li_i, 1) = Left(ls_tmcod, 1) Then lb_addX = False
//				Next
//				If lb_addX Then ls_tmcodX += Left(ls_tmcod, 1)
//			End If				
//			
//			ll_findrow = 0
//			If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
//				
//				ll_findrow = tab_1.idw_tabpage[ai_select_tab].Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
//													 "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
//											"' and frpoint = 0", 1, ll_rows)
//		
//				If ll_findrow <= 0 Then
//					f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
//					tab_1.idw_tabpage[ai_select_tab].SetColumn("frpoint")
//					tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//					tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//					return -2
//				End IF
//				
//			End IF
//				
//			ls_Ozoncod = ls_zoncod
//			ls_Otmcod  = ls_tmcod
//			ls_Oopendt = ls_opendt
//		Next
//		
//		
//		// zoncod가 하나만 있을경우 
//		If Len(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
//			f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
//			tab_1.idw_tabpage[ai_select_tab].SetFocus()
//			tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//			Return -2
//		End If
//		
//		li_rtmcnt = -1
//		//이미 Select됐된 시간대인지 Check
//		For li_i = 1 To li_cnt_tmkind
//			If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
//		Next
//		
//		//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
//		If li_rtmcnt < 0 Then
//			li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
//			If li_return < 0 Then
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//		End If
//		
//		//누락된 시간대코드가 없는지 Check
//		If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//			f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
//			tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
//			tab_1.idw_tabpage[ai_select_tab].SetRow(ll_rows)
//			tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_rows)
//			tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//			Return -2
//		End If
//		
//		//같은 시간대  code error 처리
//		ls_Ozoncod = ""
//		ls_Otmcod  = ""
//		ls_Oopendt = ""
//		lc_Ofrpoint = -1
//		For ll_row = 1 To ll_rows
//			ls_zoncod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.zoncod[ll_row])
//			ls_opendt = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_row],'yyyymmdd')
//			ls_tmcod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.tmcod[ll_row])
//			lc_frpoint = tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row]
//			
//			If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
//				f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("frpoint")
//				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//				Return -2
//			End If
//			ls_Ozoncod = ls_zoncod
//			ls_Oopendt = ls_opendt
//			ls_Otmcod = ls_tmcod
//			lc_Ofrpoint = lc_frpoint
//		Next		
//		
//		If lb_notExist Then
//			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 대역입니다." )
//			//Return -2
//		End If
//		
//		If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
//			f_msg_info(9000, Title, "정의된 모든 대역에 대해서 요율을 등록해야 합니다.")
//			//Return -2
//		End If
//		
//		
//		ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
//		tab_1.idw_tabpage[ai_select_tab].SetSort(ls_sort)
//		tab_1.idw_tabpage[ai_select_tab].Sort()
//		tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
//		
//		//적용종료일 체크
//		For i = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
//			ls_opendt = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.opendt[i], 'yyyymmdd'))
//			ls_enddt  = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.enddt[i], 'yyyymmdd'))
//			
//			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
//			
//			If ls_opendt > ls_enddt Then
//				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//				tab_1.idw_tabpage[ai_select_tab].setColumn("enddt")
//				tab_1.idw_tabpage[ai_select_tab].setRow(i)
//				tab_1.idw_tabpage[ai_select_tab].scrollToRow(i)
//				tab_1.idw_tabpage[ai_select_tab].setFocus()
//				Return -2
//			End If
//		Next
//		
//		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
//		For ll_rows1 = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
//			ls_parttype1  = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows1])
//			ls_partcod1   = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows1])
//			ls_zoncod1    = Trim(tab_1.idw_tabpage[ai_select_tab].object.zoncod[ll_rows1])
//			ls_tmcod1     = Trim(tab_1.idw_tabpage[ai_select_tab].object.tmcod[ll_rows1])
//			ls_frpoint1   = String(tab_1.idw_tabpage[ai_select_tab].object.frpoint[ll_rows1])
//			ls_areanum1   = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows1])
//			ls_itemcod1   = Trim(tab_1.idw_tabpage[ai_select_tab].object.itemcod[ll_rows1])
//			ls_opendt1    = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows1], 'yyyymmdd')
//			ls_enddt1     = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows1], 'yyyymmdd')
//	
//			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
//	
//			For ll_rows2 = tab_1.idw_tabpage[ai_select_tab].RowCount() To ll_rows1 - 1 Step -1
//				If ll_rows1 = ll_rows2 Then
//					Exit
//				End If
//				ls_parttype2 = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows2])
//				ls_partcod2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows2])
//				ls_zoncod2   = Trim(tab_1.idw_tabpage[ai_select_tab].object.zoncod[ll_rows2])
//				ls_tmcod2    = Trim(tab_1.idw_tabpage[ai_select_tab].object.tmcod[ll_rows2])
//				ls_frpoint2  = String(tab_1.idw_tabpage[ai_select_tab].object.frpoint[ll_rows2])
//				ls_areanum2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows2])
//				ls_itemcod2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.itemcod[ll_rows2])
//				ls_opendt2   = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows2], 'yyyymmdd')
//				ls_enddt2    = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows2], 'yyyymmdd')
//				
//				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
//				
//				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
//					And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
//					
//					If ls_enddt1 >= ls_opendt2 Then
//						f_msg_info(9000, Title, "같은 대역[ " + ls_zoncod1 + " ], 같은 착신지번호[ " + ls_areanum1 + " ], 같은 시간대[ " + ls_tmcod1 + " ], " &
//														+ "같은 사용범위[ " + ls_frpoint1 + " ], 같은 품목[ " + ls_itemcod1 + " ]으로 적용개시일이 중복됩니다.")
//						Return -1
//					End If
//				End If
//				
//			Next
//		Next
//		
//		//Update Log
//		For ll_row = 1  To ll_rows
//			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_row, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
//				tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()
//			End If
//		Next
//		
//	Case 5
//		
//		
//		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
//		If ll_row < 0 Then Return 0
//
//		For i = 1 To ll_row
//			ls_areanum = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[1])
//			ls_opendt = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[1], 'YYYYMMDD')
//				
//			If IsNull(ls_areanum) Then ls_areanum = ""
//			If IsNull(ls_opendt) Then ls_opendt = ""
//					
//			If ls_areanum = "" Then
//				f_msg_usr_err(200, Title, "제한번호")
//				tab_1.idw_tabpage[ai_select_tab].SetFocus()
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(i)
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("areanum")
//				Return -2
//			End If
//					
//			If ls_opendt = "" Then
//				f_msg_usr_err(200, Title, "적용개시일")
//				tab_1.idw_tabpage[ai_select_tab].SetFocus()
//				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(i)
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("opendt")
//				Return -2
//			End If
//		
//		Next
//		
//		//적용종료일 체크
//		For i = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
//			ls_opendt = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.opendt[i], 'yyyymmdd'))
//			ls_enddt  = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.enddt[i], 'yyyymmdd'))
//			
//			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
//			
//			If ls_opendt > ls_enddt Then
//				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//				tab_1.idw_tabpage[ai_select_tab].setColumn("enddt")
//				tab_1.idw_tabpage[ai_select_tab].setRow(i)
//				tab_1.idw_tabpage[ai_select_tab].scrollToRow(i)
//				tab_1.idw_tabpage[ai_select_tab].setFocus()
//				Return -2
//			End If
//		Next
//		
//		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
//		For ll_rows = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
//			ls_parttype1 = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows])
//			ls_partcod1  = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows])
//			ls_areanum1  = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows])
//			ls_opendt1   = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows], 'yyyymmdd')
//			ls_enddt1    = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows], 'yyyymmdd')
//			
//			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
//			
//			For ll_rows1 = tab_1.idw_tabpage[ai_select_tab].RowCount() To ll_rows - 1 Step -1
//				If ll_rows = ll_rows1 Then
//					Exit
//				End If
//				ls_parttype2 = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows1])
//				ls_partcod2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows1])
//				ls_areanum2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows1])
//				ls_opendt2   = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows1], 'yyyymmdd')
//				ls_enddt2    = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows1], 'yyyymmdd')
//				
//				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
//				
//				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_areanum1 = ls_areanum2) Then
//					If ls_enddt1 >= ls_opendt2 Then
//						f_msg_info(9000, Title, "같은 제한번호[ " + ls_areanum1 + " ]로 적용개시일이 중복됩니다.")
//						Return -1
//					End If
//				End If
//				
//			Next
//			
//		Next
//		
//			
//		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
//		//Update Log
//		For i = 1  To ll_row
//			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] = gs_user_id
//				tab_1.idw_tabpage[ai_select_tab].object.updtdt[i] = fdt_get_dbserver_now()
//			End If
//		Next
//
End Choose

Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within p1w_reg_master_v20
integer width = 2597
integer height = 376
string dataobject = "p1dw_cnd_reg_master"
end type

type p_ok from w_a_reg_m_tm2`p_ok within p1w_reg_master_v20
integer x = 2807
end type

type p_close from w_a_reg_m_tm2`p_close within p1w_reg_master_v20
integer x = 3109
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within p1w_reg_master_v20
integer width = 2647
integer height = 432
end type

type dw_master from w_a_reg_m_tm2`dw_master within p1w_reg_master_v20
integer y = 460
integer width = 3611
integer height = 636
string dataobject = "p1dw_mst_reg_master"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.contno_t
uf_init(ldwo_SORT)
end event

event dw_master::resize;call super::resize;Int li_index

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	dw_workdt.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space 
	p_find.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height -125
	Next

	dw_workdt.Y	= newheight - iu_cust_w_resize.ii_button_space 
	p_find.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)
end event

type p_insert from w_a_reg_m_tm2`p_insert within p1w_reg_master_v20
end type

type p_delete from w_a_reg_m_tm2`p_delete within p1w_reg_master_v20
end type

type p_save from w_a_reg_m_tm2`p_save within p1w_reg_master_v20
end type

type p_reset from w_a_reg_m_tm2`p_reset within p1w_reg_master_v20
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within p1w_reg_master_v20
integer y = 1140
integer width = 3616
integer height = 684
end type

event tab_1::ue_init;call super::ue_init;//Tab 초기화
ii_enable_max_tab = 6		//Tab 갯수

//Tab Title
is_tab_title[1] = "카드정보"
is_tab_title[2] = "일자별CDR조회"
is_tab_title[3] = "정산CDR조회"
is_tab_title[4] = "충전Log조회"
//is_tab_title[5] = "단축번호"
is_tab_title[5] = "Ani#정보조회"
is_tab_title[6] = "단축번호"

//Tab에 해당하는 dw
is_dwObject[1] = "p1dw_reg_master_t1_v20"  //언어맨트 수정ohj 2005.07.09
is_dwObject[2] = "p1dw_reg_master_t2"
is_dwObject[3] = "p1dw_reg_master_t3"
is_dwObject[4] = "p1dw_reg_master_t4"
//is_dwObject[5] = "p1dw_reg_master_t5"
is_dwObject[5] = "p1dw_reg_master_t6"
is_dwObject[6] = "p1dw_reg_master_t7_v20"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_pid, ls_contno
String ls_filter, ls_partner, ls_partner_prefix, ls_wkflag2
String ls_where, ls_langtype, ls_ref_desc, ls_svccod, ls_priceplan
Long ll_row, i
Integer li_rc, li_tab
DataWindowChild ldc_priceplan, ldc_pricemodel, ldc_wkflag2

//Boolean lb_check
//b1u_check	lu_check
//lu_check = Create b1u_check

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_pid = Trim(dw_master.object.pid[al_master_row])
ls_contno = Trim(dw_master.object.contno[al_master_row])
If Isnull(ls_pid) Then ls_pid = ""

Choose Case li_tab
	Case 1								//Tab 1
		dw_workdt.visible = FALSE
		p_save.TriggerEvent("ue_enable")
		p_find.TriggerEvent("ue_disable")
		
		ls_where = "pid = '" + ls_pid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		ls_partner_prefix = idw_tabpage[li_tab].Object.partner_prefix[1]
		
		SELECT partner
		INTO :ls_partner
		FROM partnermst
		WHERE prefixno = :ls_partner_prefix;
		
		//가격정책 Filtering
		If idw_tabpage[li_tab].GetChild('priceplan', ldc_priceplan) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		ls_filter = "partner_priceplan_partner = '" + ls_partner +"'"
		ldc_priceplan.setFilter(ls_filter)
		ldc_priceplan.filter()
		
		//모델 Filtering
		If idw_tabpage[li_tab].GetChild('pricemodel', ldc_pricemodel) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		ls_filter = "partner_pricemodel_partner = '" + ls_partner +"'"
		ldc_pricemodel.setFilter(ls_filter)
		ldc_pricemodel.filter()
		
		ls_priceplan = idw_tabpage[li_tab].Object.priceplan[1]
		//가격정책의 서비스 코드 가져오기와서 언어맨트 dddw Retrieve
		SELECT SVCCOD
		  INTO :ls_svccod
		  FROM PRICEPLANMST
		 WHERE PRICEPLAN = :ls_priceplan;
		 
		ll_row = idw_tabpage[li_tab].GetChild("wkflag2", ldc_wkflag2)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
		ls_filter = "svccod = '" + ls_svccod + "' "
		ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
		ldc_wkflag2.Filter()
		ldc_wkflag2.SetTransObject(SQLCA)
		ll_row = ldc_wkflag2.Retrieve()
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
			Return -1
		End If

	Case 2
		dw_workdt.visible = TRUE
		p_save.TriggerEvent("ue_disable")
		p_find.TriggerEvent("ue_enable")
		
		idw_tabpage[li_tab].Object.pid.Text = ls_pid
		idw_tabpage[li_tab].Object.contno.Text = ls_contno
		
		If is_format = "0" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0"
			idw_tabpage[li_tab].Object.compute_2.Format = "#,##0"
		ElseIf is_format = "1" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.0"
			idw_tabpage[li_tab].Object.compute_2.Format = "#,##0.0"
		ElseIf is_format = "2" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.00"
			idw_tabpage[li_tab].Object.compute_2.Format = "#,##0.00"
		ElseIf is_format = "3" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.000"
			idw_tabpage[li_tab].Object.compute_2.Format = "#,##0.000"
		Else
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.0000"
			idw_tabpage[li_tab].Object.compute_2.Format = "#,##0.0000"
		End If
		
 	Case 3
		dw_workdt.visible = TRUE
		p_save.TriggerEvent("ue_disable")
		p_find.TriggerEvent("ue_enable")
		
		idw_tabpage[li_tab].Object.pid.Text = ls_pid
		idw_tabpage[li_tab].Object.contno.Text = ls_contno
		
		If is_format = "0" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0"
			idw_tabpage[li_tab].Object.compute_3.Format = "#,##0"
		ElseIf is_format = "1" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.0"
			idw_tabpage[li_tab].Object.compute_3.Format = "#,##0.0"
		ElseIf is_format = "2" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.00"
			idw_tabpage[li_tab].Object.compute_3.Format = "#,##0.00"
		ElseIf is_format = "3" Then
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.000"
			idw_tabpage[li_tab].Object.compute_3.Format = "#,##0.000"
		Else
			idw_tabpage[li_tab].Object.bilamt.Format    = "#,##0.0000"
			idw_tabpage[li_tab].Object.compute_3.Format = "#,##0.0000"
		End If
		
	Case 4 
		dw_workdt.visible = FALSE
		p_save.TriggerEvent("ue_disable")
		p_find.TriggerEvent("ue_disable")
		
		idw_tabpage[li_tab].Object.t_pid.Text = ls_pid
		idw_tabpage[li_tab].Object.contno.Text = ls_contno
		
		ls_where = "pid = '" + ls_pid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
//	Case 5
//		dw_workdt.visible = FALSE
//		p_save.TriggerEvent("ue_disable")
//		p_find.TriggerEvent("ue_disable")
//		
//		idw_tabpage[li_tab].Object.pid.Text = ls_pid
//		idw_tabpage[li_tab].Object.contno.Text = ls_contno
//		
//		ls_where = "pid = '" + ls_pid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		End If

	Case 5
		dw_workdt.visible = FALSE
		p_save.TriggerEvent("ue_disable")
		p_find.TriggerEvent("ue_disable")
		
		idw_tabpage[li_tab].Object.pid_t.Text = ls_pid
		idw_tabpage[li_tab].Object.contno_t.Text = ls_contno
		
		ls_where = "pid = '" + ls_pid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		Case 6
			
		idw_tabpage[li_tab].Object.t_pid.Text = ls_pid
		idw_tabpage[li_tab].Object.contno.Text = ls_contno
				
		ls_where = "pid = '" + ls_pid + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
			
End Choose

//Destroy lu_check

Return 0

end event

event type integer tab_1::ue_tabpage_update(integer oldindex, integer newindex);//****kenn : 1999-05-11 火 *****************************
// Return : -1 Save Error
//           0 Save
//           1 User Abort(Retrieve oldindex)
//           2 System Ignore
//******************************************************
Integer li_return

If oldindex <= 0 Then Return 2
If oldindex = 1 And newindex = 1 Then Return 2

If oldindex <> 1 Then return 1

ib_update = True
//If tab_1.ib_tabpage_check[oldindex] Then
	tab_1.idw_tabpage[oldindex].AcceptText()
	If (tab_1.idw_tabpage[oldindex].ModifiedCount() > 0) Or &
		(tab_1.idw_tabpage[oldindex].DeletedCount() > 0) Then
		tab_1.SelectedTab = oldindex
		li_return = MessageBox(Tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]" &
					, "Data is Modified.! Do you want to save?", Question!, YesNo!)
		If li_return <> 1 Then
			ib_update = False
			Return 1
		End If
	Else
		ib_update = False
		Return 2
	End If

	li_return = Trigger Event ue_extra_save(oldindex)
	Choose Case li_return
		Case -2
			//필수항목 미입력
			//tab_1.SelectedTab = oldindex
			//tab_1.idw_tabpage[oldindex].SetFocus()
			ib_update = False
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
	
			f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
			ib_update = False
			Return -1
	End Choose

	If tab_1.idw_tabpage[oldindex].Update(True, False) < 0 Then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			ib_update = False
			Return -1
		End If

		f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
		ib_update = False
		Return -1
	End If

	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		ib_update = False
		Return -1
	End If

	tab_1.idw_tabpage[oldindex].ResetUpdate()
	f_msg_info(3000, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
	ib_update = False
	//tab_1.SelectedTab = newindex
//End If

Return 0
end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn, ls_credit_yn
ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

Choose Case newindex
		
	case 1,2,3,4,5
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
			
	Case 6
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within p1w_reg_master_v20
integer x = 37
integer y = 1100
end type

event st_horizontal::mousemove;call super::mousemove;dw_workdt.Y = p_insert.Y
p_find.Y = p_insert.Y


end event

type p_find from u_p_find within p1w_reg_master_v20
integer x = 3223
integer y = 1840
boolean bringtotop = true
end type

type dw_workdt from u_d_help within p1w_reg_master_v20
integer x = 2094
integer y = 1820
integer width = 1088
integer height = 120
integer taborder = 11
boolean bringtotop = true
string dataobject = "p1dw_cnd2_reg_master"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

