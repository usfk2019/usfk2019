$PBExportHeader$p1w_reg_master_1.srw
$PBExportComments$[chooys] 선불카드관리 Window - Ani 등록 빠짐
forward
global type p1w_reg_master_1 from w_a_reg_m_tm2
end type
type p_find from u_p_find within p1w_reg_master_1
end type
type dw_workdt from u_d_help within p1w_reg_master_1
end type
end forward

global type p1w_reg_master_1 from w_a_reg_m_tm2
integer width = 3717
integer height = 2080
event ue_find ( )
p_find p_find
dw_workdt dw_workdt
end type
global p1w_reg_master_1 p1w_reg_master_1

type variables
String is_format
end variables

forward prototypes
public subroutine of_resizepanels ()
protected function integer wf_cdr_inq (string as_validkey, string as_workdt_fr, string as_workdt_to, datawindow as_dw)
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

protected function integer wf_cdr_inq (string as_validkey, string as_workdt_fr, string as_workdt_to, datawindow as_dw);//**   Argument :
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

on p1w_reg_master_1.create
int iCurrent
call super::create
this.p_find=create p_find
this.dw_workdt=create dw_workdt
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_find
this.Control[iCurrent+2]=this.dw_workdt
end on

on p1w_reg_master_1.destroy
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
//tab_1.idw_tabpage[5].SetRowFocusIndicator(off!)


dw_workdt.Object.workdt_fr[1] = Date(fdt_get_dbserver_now())
dw_workdt.Object.workdt_to[1] = Date(fdt_get_dbserver_now())
dw_workdt.visible = FALSE
p_find.TriggerEvent("ue_disable")

is_format = fs_get_control("B1", "Z200", ls_ref_desc)

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

type dw_cond from w_a_reg_m_tm2`dw_cond within p1w_reg_master_1
integer width = 2597
integer height = 376
string dataobject = "p1dw_cnd_reg_master"
end type

type p_ok from w_a_reg_m_tm2`p_ok within p1w_reg_master_1
integer x = 2807
end type

type p_close from w_a_reg_m_tm2`p_close within p1w_reg_master_1
integer x = 3109
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within p1w_reg_master_1
integer width = 2647
integer height = 432
end type

type dw_master from w_a_reg_m_tm2`dw_master within p1w_reg_master_1
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

type p_insert from w_a_reg_m_tm2`p_insert within p1w_reg_master_1
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within p1w_reg_master_1
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within p1w_reg_master_1
end type

type p_reset from w_a_reg_m_tm2`p_reset within p1w_reg_master_1
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within p1w_reg_master_1
integer y = 1140
integer width = 3616
integer height = 668
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 4		//Tab 갯수

//Tab Title
is_tab_title[1] = "카드정보"
is_tab_title[2] = "일자별CDR조회"
is_tab_title[3] = "정산CDR조회"
is_tab_title[4] = "충전Log조회"
//is_tab_title[5] = "단축번호"
//is_tab_title[5] = "Ani#정보조회"

//Tab에 해당하는 dw
is_dwObject[1] = "p1dw_reg_master_t1"
is_dwObject[2] = "p1dw_reg_master_t2"
is_dwObject[3] = "p1dw_reg_master_t3"
is_dwObject[4] = "p1dw_reg_master_t4"
//is_dwObject[5] = "p1dw_reg_master_t5"
//is_dwObject[5] = "p1dw_reg_master_t6"


end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_pid, ls_contno
String ls_filter, ls_partner, ls_partner_prefix, ls_wkflag2
String ls_where, ls_temp, ls_langtype, ls_ref_desc
Long ll_row, i
Integer li_rc, li_tab
DataWindowChild ldc_priceplan, ldc_pricemodel

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
		
		idw_tabpage[li_tab].Object.pid.Text = ls_pid
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

type st_horizontal from w_a_reg_m_tm2`st_horizontal within p1w_reg_master_1
integer x = 37
integer y = 1100
end type

event st_horizontal::mousemove;call super::mousemove;dw_workdt.Y = p_insert.Y
p_find.Y = p_insert.Y


end event

type p_find from u_p_find within p1w_reg_master_1
integer x = 3223
integer y = 1840
boolean bringtotop = true
end type

type dw_workdt from u_d_help within p1w_reg_master_1
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

