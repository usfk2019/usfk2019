$PBExportHeader$b2w_reg_partnermst_v20_1.srw
$PBExportComments$[kem] 대리점정보등록(com&life)
forward
global type b2w_reg_partnermst_v20_1 from w_a_reg_m_tm2
end type
end forward

global type b2w_reg_partnermst_v20_1 from w_a_reg_m_tm2
integer width = 3584
integer height = 2208
end type
global b2w_reg_partnermst_v20_1 b2w_reg_partnermst_v20_1

type variables
Boolean ib_new			//신규 등록  True
String is_check, is_root


end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename)
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
end prototypes

public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[]);//문자열을 특정구분자(as_cut)로 자른다.
Long ll_rc = 1
Int li_index = 0

as_source = Trim(as_source)
If as_source <> '' Then
	Do While(ll_rc <> 0 )
		li_index ++
		ll_rc = PosA(as_source, as_cut)
		If ll_rc <> 0 Then
			as_result[li_index] = Trim(LeftA(as_source, ll_rc - 1))
		Else
			as_result[li_index] = Trim(as_source)
		End If

		as_source = MidA(as_source, ll_rc + 2)
	Loop
End If

Return li_index
end function

public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename);// 코드별 명붙이기... or select column

CHOOSE CASE as_gu
	CASE "C"
		SELECT customernm
		INTO :as_codename
		FROM customerm
		WHERE customerid = :as_code ;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title,"고객명(wfi_set_codename)")
			Return -2
		End If
		
	CASE "T"
		
		SELECT codenm
		INTO :as_codename
		FROM syscod2t
		WHERE grcode = 'B330' 
		  and use_yn = 'Y'
		  and code = :as_code ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title,"민원요청(wfi_set_codename)")
			Return -2
		End If
		
	CASE "P"
		SELECT partnernm
		INTO :as_codename
		FROM partnermst
		WHERE partner = :as_code
		  AND act_yn = 'Y';
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title,"수행처(wfi_set_codename)")
			Return -2
		End If

	CASE ELSE
		
END CHOOSE

Return 0
end function

public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE zoncod like :as_zoncod;

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(Title, ":CURSOR cur_get_arezoncod")
	Return -1
End If

OPEN cur_get_arezoncod;
Do While(True)
	FETCH cur_get_arezoncod
	INTO :ls_zoncod;
			
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(Title, ":cur_get_arezoncod")
		CLOSE cur_get_arezoncod;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	ll_rows += 1
	as_arezoncod[ll_rows] = ls_zoncod
	
Loop
CLOSE cur_get_arezoncod;

Return ll_rows
end function

on b2w_reg_partnermst_v20_1.create
int iCurrent
call super::create
end on

on b2w_reg_partnermst_v20_1.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_reg_partnermst
	Desc.	: 대리점등록
	Ver.	: 1.0
	Date	: 2002.10.01
	Programer : Park Kyung Hae (parkkh)
------------------------------------------------------------------------*/
string ls_ref_desc

tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[5].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[6].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[7].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[8].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[9].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[10].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[11].SetRowFocusIndicator(off!)

ib_new = False
is_check = ""

//본사영업대리점 prefixno(관리코드)
ls_ref_desc = ""
is_root = fs_get_control("A1", "C101", ls_ref_desc)
end event

event ue_ok();call super::ue_ok;//dw_master 조회
String ls_partner, ls_partnernm, ls_levelcod, ls_prefixno, ls_temp, ls_result[]
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

dw_cond.AcceptText()
ls_partner = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_levelcod = Trim(dw_cond.object.levelcod[1])
ls_prefixno = Trim(dw_cond.object.prefixno[1])
ls_new  = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then ib_new = True

//신규 등록 
If ib_new = True Then
	
	tab_1.SelectedTab = 1		//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   p_insert.TriggerEvent("Clicked")
	Return
Else
		//Null Check
		If IsNull(ls_partner) Then ls_partner = ""
		If IsNull(ls_partnernm) Then ls_partnernm = ""
		If IsNull(ls_levelcod) Then ls_levelcod = ""
		If IsNull(ls_prefixno) Then ls_prefixno = ""
		
		//Retrieve
		ls_where = ""
		IF ls_partner <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "partner like '" + ls_partner + "%' "
		End If

		IF ls_partnernm <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "Upper(partnernm) like '" + upper(ls_partnernm) + "%' "
		End If
		
		IF ls_levelcod <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "levelcod = '" + ls_levelcod + "' "
		End If
		
		IF ls_prefixno <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "prefixno like '" + ls_prefixno + "%' "
		End If
		
		dw_master.is_where = ls_where
		ll_row = dw_master.Retrieve()
		
		If ll_row = 0 Then 
			f_msg_info(1000, Title, "")
//			//Insert Row
//			ib_new = True
//			tab_1.SelectedTab = 1				//Tab 1 Select
//			p_ok.TriggerEvent("ue_disable")
//			dw_cond.Enabled = False
//			p_delete.TriggerEvent("ue_disable")
//			p_save.TriggerEvent("ue_enable")
//			p_reset.TriggerEvent("ue_enable")
//			tab_1.Enabled = True
//			tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
//			TriggerEvent("ue_insert")			//첫 페이지에 Insert row 한다.
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return
		Else
			//검색을 찾으면 Tab를 활성화 시킨다.
			tab_1.Trigger Event SelectionChanged(1, 1)
			tab_1.Enabled = True
		End If
End If

end event

event ue_extra_insert;call super::ue_extra_insert;//Insert시 조건
Dec lc_troubleno
Dec lc_num
Long ll_master_row, ll_seq , i, ll_row
String ls_partner

ll_master_row = dw_master.GetRow()

Choose Case ai_selected_tab
	Case 1								//Tab 1
		If ib_new = True Then
			//Display
			tab_1.idw_tabpage[ai_selected_tab].object.partner.Protect = 0
			tab_1.idw_tabpage[ai_selected_tab].object.levelcod.Protect = 0
		   tab_1.idw_tabpage[ai_selected_tab].Object.hpartner.Protect = 1
			tab_1.idw_tabpage[ai_selected_tab].Object.levelcod.Background.Color = RGB(108, 147, 137)
			tab_1.idw_tabpage[ai_selected_tab].Object.levelcod.Color = RGB(255, 255, 255)		
			tab_1.idw_tabpage[ai_selected_tab].Object.hpartner.Background.Color = RGB(108, 147, 137)
			tab_1.idw_tabpage[ai_selected_tab].Object.hpartner.Color = RGB(255, 255, 255)		
			
//			tab_1.idw_tabpage[ai_selected_tab].object.partner.Pointer = "help.cur"
//			tab_1.idw_tabpage[ai_selected_tab].idwo_help_col[1] = tab_1.idw_tabpage[ai_selected_tab].object.partner
//			
			//Setting
			tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()			//등록일자
			tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
			tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[ai_selected_tab].object.updt_user[al_insert_row] = gs_user_id	
			tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()

			//Insert 시 해당 row 첫번째 컬럼에 포커스
			tab_1.idw_tabpage[ai_selected_tab].SetColumn("partner")
		End  If
		
	Case 4								//Tab 3
		ls_partner = dw_master.object.partner[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()			//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
		tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]			
		tab_1.idw_tabpage[ai_selected_tab].object.partner[al_insert_row] = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.upd_user[al_insert_row] = gs_user_id	
		tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()

		//보증금 일련번호 생성
		Long ll_bondseqno
		
		SELECT nvl(max(bondseqno)+1,1)
		INTO :ll_bondseqno
		FROM partnerbond
		WHERE	partner = :ls_partner;
		
		tab_1.idw_tabpage[ai_selected_tab].object.bondseqno[al_insert_row] = ll_bondseqno
		//Insert 시 해당 row 첫번째 컬럼에 포커스
		tab_1.idw_tabpage[ai_selected_tab].SetColumn("bondtype")
		
	Case 5
		ls_partner = dw_master.object.partner[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.parttype[al_insert_row]  = 'S'
		tab_1.idw_tabpage[ai_selected_tab].object.partcod[al_insert_row]   = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.roundflag[al_insert_row] = 'U'
		tab_1.idw_tabpage[ai_selected_tab].object.frpoint[al_insert_row]   = 0
		tab_1.idw_tabpage[ai_selected_tab].object.unitsec[al_insert_row]   = 0
		tab_1.idw_tabpage[ai_selected_tab].object.unitfee[al_insert_row]   = 0
		tab_1.idw_tabpage[ai_selected_tab].object.opendt[al_insert_row]    = fdt_get_dbserver_now()
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]     = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row]  = gs_user_id						//등록자	
		tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]			
		
		
	Case 6
		ls_partner = dw_master.object.partner[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.parttype[al_insert_row] = 'S'
		tab_1.idw_tabpage[ai_selected_tab].object.partcod[al_insert_row]  = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.opendt[al_insert_row]   = fdt_get_dbserver_now()
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
		tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
		
		
	Case 7
		ls_partner = dw_master.object.partner[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.partner[al_insert_row]  = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id
		//등록자	
		
	Case 8
		ls_partner = dw_master.object.partner[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.partner[al_insert_row]  = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row]    = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.updt_user[al_insert_row] = gs_user_id
		//등록자	
		
	Case 9
		ls_partner = dw_master.object.partner[ll_master_row]
		tab_1.idw_tabpage[ai_selected_tab].object.partner[al_insert_row]  = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id
		
	Case 10
		ls_partner = dw_master.object.partner[ll_master_row]
		tab_1.idw_tabpage[ai_selected_tab].object.partner[al_insert_row]   = ls_partner
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row]  = gs_user_id
		tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row]    = fdt_get_dbserver_now()		//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
		
End Choose

Return 0 
end event

event close;call super::close;ib_new = False		//초기화
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("partner")
tab_1.SelectedTab = 1
ib_new = False
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
Return 0 
end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Dec lc_troubleno
Long ll_master_row, ll_cnt
String ls_partner

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

Choose Case tab_1.SelectedTab
	Case 1						//Tab
		ls_partner = dw_master.object.partner[ll_master_row]

		//삭제하고자하는 대리점코드가 svcorder(서비스신청내역) table에 존재할때 삭제불가
		Select count(*)
		  into :ll_cnt
		  from svcorder
		 where reg_partner = :ls_partner
		    or maintain_partner = :ls_partner
		    or sale_partner = :ls_partner
		    or settle_partner = :ls_partner
		    or partner = :ls_partner;
			 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Error")
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, Title, "삭제불가! 서비스신청내역에 해당대리점이 존재합니다.")  //삭제 안됨 
			Return -1
		End If
		
		//삭제하고자하는 대리점코드가 contractmst(계약마스터) table에 존재할때 삭제불가		
		Select count(*)
		  into :ll_cnt
		  from contractmst
		 where reg_partner = :ls_partner
		    or maintain_partner = :ls_partner
		    or sale_partner = :ls_partner
		    or settle_partner = :ls_partner
		    or partner = :ls_partner;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Error")
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, Title, "삭제불가! 계약마스터에 해당대리점이 존재합니다.")  //삭제 안됨 
			Return -1
		End If
		
		//삭제하고자하는 대리점코드를 상위대리점으로 하는 대리점이 존재하면 삭제 할 수 없다.
		ll_cnt = 0
		Select count(*)
		Into :ll_cnt
		From partnermst
		Where hpartner = :ls_partner;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Error")
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, Title, "삭제불가! 소속 하위대리점을 먼저 삭제하셔야 합니다.")  //삭제 안됨 
			Return -1
		Else 							
			is_check = "DEL"							   //삭제 가능
		End If
		
End Choose

Return 0 
end event

event ue_extra_save;call super::ue_extra_save;//Save
String ls_partner, ls_partnernm, ls_levelcod, ls_hpartner, ls_todt, ls_enddt, ls_priceplan_1, ls_partner_1
String ls_hprefixno, ls_hprefixno_1, ls_prefixno, ls_sql, ls_credit_yn, ls_bondtype, ls_fromdt, ls_bondamt
String ls_emp_id, ls_password, ls_password_out, ls_user_group_id, ls_errmsg, ls_emp_group
String ls_empnm, ls_emp_auth, ls_ref_desc
Long ll_row, ll_len, ll_len_1, ll_cnt, ll_master_row, ll_cnt_1, ll_cnt_2
Integer li_rc, ll_i, i
Double ll_return

Long ll_rows, ll_findrow, ll_zoncodcnt
String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype, ls_areanum, ls_itemcod
String ls_date, ls_sort
Dec lc_data, lc_frpoint, lc_Ofrpoint

String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt, ls_cnt_limitflag, ls_amt_limitflag
Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
Boolean lb_addX, lb_notExist
Constant Integer li_MAXTMKIND = 3

String ls_parttype1, ls_partcod1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
String ls_parttype2, ls_partcod2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
Long   ll_rows1, ll_rows2

//tab_1.idw_tabpage[ai_select_tab].AcceptText()

//Row 수가 없으면aasaa
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()
ll_master_row = dw_master.GetRow()

//tab_1.idw_tabpage[ai_select_tab].AcceptText()

Choose Case ai_select_tab
	Case 1
		//Update Log
		tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()
		
		tab_1.idw_tabpage[ai_select_tab].AcceptText()
		//필수 Check
		ls_partner = Trim(tab_1.idw_tabpage[ai_select_tab].object.partner[ll_row])
		ls_partnernm = Trim(tab_1.idw_tabpage[ai_select_tab].object.partnernm[ll_row])
		ls_levelcod = Trim(tab_1.idw_tabpage[ai_select_tab].object.levelcod[ll_row])
		ls_hpartner = Trim(tab_1.idw_tabpage[ai_select_tab].object.hpartner[ll_row])
		ls_credit_yn = Trim(tab_1.idw_tabpage[ai_select_tab].object.credit_yn[ll_row])

		If IsNull(ls_partner) Then ls_partner = ""
		If IsNull(ls_partnernm) Then ls_partnernm = ""
		If IsNull(ls_levelcod) Then ls_levelcod = ""
		If IsNull(ls_hpartner) Then ls_hpartner = ""
		If IsNull(ls_credit_yn) Then ls_credit_yn = ""
		

		If ls_partnernm = "" Then
			f_msg_usr_err(200, title, "대리점명")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("partnernm")
			Return -2
		End If

		If ls_levelcod = "" Then
			f_msg_usr_err(200, title, "Levelcod")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("levelcod")
			Return -2
		End If

		If ls_hpartner = "" Then
			f_msg_usr_err(200, title, "상위대리점")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("hpartner")
			Return -2
		End If

		If ls_credit_yn = "" Then
			f_msg_usr_err(200, title, "여신한도관리여부")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("credit_yn")
			Return -2
		End If

		If ib_new = True Then		//신규
		
			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			  from partnermst
			 where partner_type = '0'
				and levelcod = (select max(code)
										from syscod2t
									 where grcode = 'A100' and use_yn = 'Y' 
									   and code < :ls_levelcod )
				and partner = :ls_hpartner;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(This.Title, "상위대리점 check")
				RollBack;
				Return -1
			End If
			
			If ll_cnt = 0 Then
				f_msg_usr_err(9000, Title, "입력하신 상위대리점은 levelcod가 틀립니다.!!")  //삭제 안됨 
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("hpartner")
				Return -2
			End If

		   select prefixno,
			       length(prefixno)
			  into :ls_hprefixno,
			  		 :ll_len
   		  from partnermst
			 where partner = :ls_hpartner
			   and partner_type = '0';
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, "상위대리점 관리코드 select")
				Return -1
			End If				
			
			IF ll_len >= 60 Then
				f_msg_usr_err(9000, Title, "입력불가!! 관리코드 생성범위 초과!!~r~n~r~n데이타베이스관리자에게 문의하세요!! ")  //생성불가
				return -2
			End If
			
			//상위대리점 관리코드가 본사영업본부 관리코드랑 같으면... 첫 셋팅!
			If ls_hprefixno = is_root Then
				ll_len = 0
				ls_hprefixno = ''
			End if
			
			ll_len_1 = ll_len + 1
		   ls_hprefixno_1 = ls_hprefixno + "%"
			
			SELECT to_char(:ls_hprefixno||to_char(to_number(nvl(max(substr(prefixno,:ll_len_1,3)),'100'))+1))
			 into :ls_prefixno
			 FROM partnermst 
	      WHERE prefixno like :ls_hprefixno_1
			 and prefixno <> :is_root
			 and partner_type = '0';
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, "관리코드 생성")
				Return -1
			End If				

			tab_1.idw_tabpage[ai_select_tab].object.prefixno[ll_row] = ls_prefixno
			
			//partner seq 가져 오기
			Select 'A'|| to_char(seq_partnerno.nextval)
			Into :ls_partner
			From dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, "SELECT seq_partnerno.nextval")			
				Return -1
			End If	
			
			tab_1.idw_tabpage[ai_select_tab].object.partner[ll_row] = ls_partner
			
		End if
		
	Case 2
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		ls_emp_group = dw_master.Object.partner[ll_master_row]
		//ls_empnm = fs_get_Control("A1", "C700", ls_ref_desc)
		ls_emp_auth = fs_get_Control("A1", "C710", ls_ref_desc)
		
		ls_errmsg = space(256)
		ls_password_out = space(32)
		For ll_i = 1 To ll_row
			ls_emp_id = fs_snvl(Trim(tab_1.idw_tabpage[ai_select_tab].object.emp_id[ll_i]), "")
			ls_password = fs_snvl(Trim(tab_1.idw_tabpage[ai_select_tab].object.password[ll_i]), "")
			ls_empnm = fs_snvl(Trim(tab_1.idw_tabpage[ai_select_tab].object.empnm[ll_i]), "")
			ls_user_group_id = fs_snvl(Trim(tab_1.idw_tabpage[ai_select_tab].object.user_group_id[ll_i]), "")
			
			If ls_emp_id = "" Then
				f_msg_usr_err(200, title, "Login ID")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("emp_id")
				Return -2
			End If
			
			If ls_password = "" Then
				f_msg_usr_err(200, title, "Password")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("password")
				Return -2
			End If
			
			If ls_empnm = "" Then
				f_msg_usr_err(200, title, "User Name")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("empnm")
				Return -2
			End If
			
			If ls_user_group_id = "" Then
				f_msg_usr_err(200, title, "웹사용자그룹")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("user_group_id")
				Return -2
			End If
			
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, "emp_id", Primary!) = DataModified! Then
				ll_cnt = 0
				SELECT count(*)
				INTO	:ll_cnt
				FROM	sysusr1t
				WHERE	emp_id = :ls_emp_id;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(This.Title, "LOGID DUP CHECK")
					RollBack;
					Return -1
				End If
				
				If ll_cnt > 0 Then
					f_msg_usr_err(9000, Title, "이미 존재하는 ID입니다.")  //삭제 안됨 
					tab_1.idw_tabpage[ai_select_tab].SetFocus()
					tab_1.idw_tabpage[ai_select_tab].SetColumn("emp_id")
					Return -2
				End If
			End If
			
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, "password", Primary!) = DataModified! Then
			
				// Password Encryption
				SQLCA.PASSWORD_DESENCRYPT(ls_password, ls_password_out, ll_return, ls_errmsg)
				
				If SQLCA.SQLCode < 0 Then		//For Programer
					MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
					ll_return = -1
				ElseIf ll_return < 0 Then	//For User
					MessageBox(This.Title, ls_errmsg)
				End If
			
				If ll_return <> 0 Then	//실패
					Return -1
				Else				//성공
					tab_1.idw_tabpage[ai_select_tab].object.password[ll_i] = ls_password_out
				End If
			End If
			
			//tab_1.idw_tabpage[ai_select_tab].object.empnm[ll_i] = ls_empnm
			tab_1.idw_tabpage[ai_select_tab].object.emp_auth[ll_i] = Long(ls_emp_auth)
			tab_1.idw_tabpage[ai_select_tab].object.emp_type[ll_i] = 'W'
			tab_1.idw_tabpage[ai_select_tab].object.emp_group[ll_i] = ls_emp_group
		
		Next
		
	Case 4

		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For ll_i = 1 To ll_row
		
			tab_1.idw_tabpage[ai_select_tab].AcceptText()
	
			//유형 체크
			ls_bondtype	= Trim(tab_1.idw_tabpage[ai_select_tab].Object.bondtype[ll_i])
			IF IsNull(ls_bondtype) THEN ls_bondtype = ""
		
			IF ls_bondtype = "" THEN
				f_msg_usr_err(200, Title, "유형")
				tab_1.idw_tabpage[ai_select_tab].setColumn("bondtype")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				RETURN -2
			END IF
			
			//적용시작일 체크
			ls_fromdt	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.fromdt[ll_i],'yyyymmdd'))
			IF IsNull(ls_fromdt) THEN ls_fromdt = ""
		
			IF ls_fromdt = "" THEN
				f_msg_usr_err(200, Title, "적용시작일")
				tab_1.idw_tabpage[ai_select_tab].setColumn("fromdt")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				RETURN -2
			END IF

			//적용종료일 체크
			ls_todt	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.todt[ll_i],'yyyymmdd'))
			IF IsNull(ls_todt) THEN ls_todt = ""
			
			IF ls_todt <> "" THEN
				If ls_fromdt > ls_todt THEN
					f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
					tab_1.idw_tabpage[ai_select_tab].setColumn("todt")
					tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
					tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
					tab_1.idw_tabpage[ai_select_tab].setFocus()
					RETURN -2
				END IF
			END IF
			
			//금액 체크
			ls_bondamt	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.bondamt[ll_i]))
			IF IsNull(ls_bondamt) THEN ls_bondamt = ""
		
			IF ls_bondamt = "" THEN
				f_msg_usr_err(200, Title, "금액")
				tab_1.idw_tabpage[ai_select_tab].setColumn("bondamt")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				RETURN -2
			END IF
	
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.upd_user[ll_i] = gs_user_id	
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_i] = fdt_get_dbserver_now()
			End If
	   Next
		
	Case 5
		If tab_1.idw_tabpage[ai_select_tab].RowCount()  = 0 Then Return 0

		//  대역/시간대코드/개시일자
		ls_Ozoncod = ""
		ls_Otmcod  = ""
		ls_tmcodX = ""
		li_tmcodcnt = 0
		li_cnt_tmkind = 0

		//해당 priceplan 찾기
		ls_priceplan = 'ALL'

		//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
		li_return = wfl_get_arezoncod(ls_zoncod, ls_arezoncod[])
		If li_return < 0 Then Return -2

		ll_rows = tab_1.idw_tabpage[ai_select_tab].RowCount()
		If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0
	

		//정리하기 위해서 Sort
		tab_1.idw_tabpage[ai_select_tab].SetRedraw(False)
		ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
		tab_1.idw_tabpage[ai_select_tab].SetSort(ls_sort)
		tab_1.idw_tabpage[ai_select_tab].Sort()


		For ll_row = 1 To ll_rows
			ls_zoncod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.zoncod[ll_row])
			ls_opendt = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_row],'yyyymmdd')
			ls_tmcod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.tmcod[ll_row])
			ls_areanum = Trim(tab_1.idw_tabpage[ai_select_tab].Object.areanum[ll_row])
			ls_itemcod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.itemcod[ll_row])
			
			If IsNull(ls_zoncod) Then ls_zoncod = ""
			If IsNull(ls_opendt) Then ls_opendt = ""
			If IsNull(ls_tmcod) Then ls_tmcod = ""
			If IsNull(ls_areanum) Then ls_areanum = ""
			If IsNull(ls_itemcod) Then ls_itemcod = ""
			
		   //필수 항목 check 
			If ls_zoncod = "" Then
				f_msg_usr_err(200, Title, "대역")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("zoncod")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
	
			If ls_opendt = "" Then
				f_msg_usr_err(200, Title, "적용개시일")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("opendt")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
			
			If ls_areanum = "" Then
				f_msg_usr_err(200, Title, "착신지번호")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("areanum")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
	
			If ls_tmcod = "" Then
				f_msg_usr_err(200, Title, "시간대")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If

			//시작Point - khpark 추가 -
			lc_frpoint = tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row]
			If IsNull(lc_frpoint) Then tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row] = 0
	
			If tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row] < 0 Then
				f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("frpoint")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
			
			If ls_itemcod = "" Then
				f_msg_usr_err(200, Title, "품목")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("itemcod")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
			
			If tab_1.idw_tabpage[ai_select_tab].Object.unitsec[ll_row] = 0 Then
				f_msg_usr_err(200, Title, "기본시간")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("unitsec")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
	
			If tab_1.idw_tabpage[ai_select_tab].Object.unitfee[ll_row] < 0 Then
				f_msg_usr_err(200, Title, "기본요금")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("unitfee")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
	
			If tab_1.idw_tabpage[ai_select_tab].Object.munitsec[ll_row] = 0 Then
				f_msg_usr_err(200, Title, "기본시간(멘트)")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("munitsec")
				tab_1.idw_tabpage[ai_select_tab].Object.DataWindow.HorizontalScrollPosition='10000'
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
			
			If tab_1.idw_tabpage[ai_select_tab].Object.munitfee[ll_row] < 0 Then
				f_msg_usr_err(200, Title, "기본요금(멘트)")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("munitfee")
				tab_1.idw_tabpage[ai_select_tab].Object.DataWindow.HorizontalScrollPosition='10000'
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
	
			// 1 zoncod가 같으면 
			If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
				
				//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
				If MidA(ls_tmcod, 2, 1) <> MidA(ls_Otmcod, 2, 1) Then
					f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
					tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
					tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
					tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
					Return -2
			
				ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
					li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
				End If	// 2 close						
	
			// 1 else	
			Else
				//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
				If lb_notExist = False Then
					lb_notExist = True
					For ll_i = 1 To UpperBound(ls_arezoncod)
						If ls_arezoncod[ll_i] = ls_zoncod Then 
							lb_notExist = False
							Exit
						End If
					Next
				End If	 // 3 close	
			  If ls_Ozoncod <>  ls_zoncod Then 
					ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
				End If
				  
				// 4 zonecod가  바뀌었거나 처음 row 일때
				// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
				If ll_row > 1 Then
					
					If ls_tmcodX <> 'X' and LenA(ls_tmcodX) <> li_MAXTMKIND Then
						f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
						tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
						tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row - 1)
						tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row - 1)
						tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
						Return -2
					End If 
					
					li_rtmcnt = -1
					//이미 Select됐된 시간대인지 Check
					For li_i = 1 To li_cnt_tmkind
						If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
					Next
				
					// 5 tmcod에 해당 pricecod 별로 tmcod check
					If li_rtmcnt < 0 Then
						li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
						If li_return < 0 Then 
							tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
							Return -2
						End If
						
						li_cnt_tmkind += 1
						ls_tmkind[li_cnt_tmkind,1] = LeftA(ls_Otmcod, 2)
						ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
					End If // 5 close
					
					//누락된 시간대코드가 없는지 Check
					If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
						f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
						tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
						tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row - 1)
						tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row - 1)
						tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
						Return -2
					End If
			
					li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
					 ls_tmcodX = ""
				Else // 4 else	 
					li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
					
				End If // 4 close
			End If // 1 close ls_Ozoncod = ls_zoncod 조건 
			
			// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
			If LeftA(ls_tmcod, 1) = 'X' Then
				If LenA(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
					f_msg_usr_err(9000, Title, "모든 시간대는 다른 시간대랑 같이 사용 할 수 없습니다." )
					tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
					tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
					tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
					Return -2
				ElseIf LenA(ls_tmcodX) = 0 Then 
					ls_tmcodX += LeftA(ls_tmcod, 1)
				End If
			Else
				lb_addX = True
				For li_i = 1 To LenA(ls_tmcodX)
					If MidA(ls_tmcodX, li_i, 1) = LeftA(ls_tmcod, 1) Then lb_addX = False
				Next
				If lb_addX Then ls_tmcodX += LeftA(ls_tmcod, 1)
			End If				
			
			ll_findrow = 0
			If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
				
				ll_findrow = tab_1.idw_tabpage[ai_select_tab].Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
													 "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
											"' and frpoint = 0", 1, ll_rows)
		
				If ll_findrow <= 0 Then
					f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
					tab_1.idw_tabpage[ai_select_tab].SetColumn("frpoint")
					tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
					tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
					return -2
				End IF
				
			End IF
				
			ls_Ozoncod = ls_zoncod
			ls_Otmcod  = ls_tmcod
			ls_Oopendt = ls_opendt
		Next
		
		
		// zoncod가 하나만 있을경우 
		If LenA(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
			f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
			Return -2
		End If
		
		li_rtmcnt = -1
		//이미 Select됐된 시간대인지 Check
		For li_i = 1 To li_cnt_tmkind
			If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
		Next
		
		//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
		If li_rtmcnt < 0 Then
			li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
			If li_return < 0 Then
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
		End If
		
		//누락된 시간대코드가 없는지 Check
		If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
			f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
			tab_1.idw_tabpage[ai_select_tab].SetColumn("tmcod")
			tab_1.idw_tabpage[ai_select_tab].SetRow(ll_rows)
			tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_rows)
			tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
			Return -2
		End If
		
		//같은 시간대  code error 처리
		ls_Ozoncod = ""
		ls_Otmcod  = ""
		ls_Oopendt = ""
		lc_Ofrpoint = -1
		For ll_row = 1 To ll_rows
			ls_zoncod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.zoncod[ll_row])
			ls_opendt = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_row],'yyyymmdd')
			ls_tmcod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.tmcod[ll_row])
			lc_frpoint = tab_1.idw_tabpage[ai_select_tab].Object.frpoint[ll_row]
			
			If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
				f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
				tab_1.idw_tabpage[ai_select_tab].SetColumn("frpoint")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
				Return -2
			End If
			ls_Ozoncod = ls_zoncod
			ls_Oopendt = ls_opendt
			ls_Otmcod = ls_tmcod
			lc_Ofrpoint = lc_frpoint
		Next		
		
		If lb_notExist Then
			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 대역입니다." )
			//Return -2
		End If
		
		If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
			f_msg_info(9000, Title, "정의된 모든 대역에 대해서 요율을 등록해야 합니다.")
			//Return -2
		End If
		
		
		ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
		tab_1.idw_tabpage[ai_select_tab].SetSort(ls_sort)
		tab_1.idw_tabpage[ai_select_tab].Sort()
		tab_1.idw_tabpage[ai_select_tab].SetRedraw(True)
		
		//적용종료일 체크
		For i = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
			ls_opendt = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.opendt[i], 'yyyymmdd'))
			ls_enddt  = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.enddt[i], 'yyyymmdd'))
			
			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
			
			If ls_opendt > ls_enddt Then
				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
				tab_1.idw_tabpage[ai_select_tab].setColumn("enddt")
				tab_1.idw_tabpage[ai_select_tab].setRow(i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				Return -2
			End If
		Next
		
		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
		For ll_rows1 = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
			ls_parttype1  = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows1])
			ls_partcod1   = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows1])
			ls_zoncod1    = Trim(tab_1.idw_tabpage[ai_select_tab].object.zoncod[ll_rows1])
			ls_tmcod1     = Trim(tab_1.idw_tabpage[ai_select_tab].object.tmcod[ll_rows1])
			ls_frpoint1   = String(tab_1.idw_tabpage[ai_select_tab].object.frpoint[ll_rows1])
			ls_areanum1   = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows1])
			ls_itemcod1   = Trim(tab_1.idw_tabpage[ai_select_tab].object.itemcod[ll_rows1])
			ls_opendt1    = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows1], 'yyyymmdd')
			ls_enddt1     = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows1], 'yyyymmdd')
	
			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
	
			For ll_rows2 = tab_1.idw_tabpage[ai_select_tab].RowCount() To ll_rows1 - 1 Step -1
				If ll_rows1 = ll_rows2 Then
					Exit
				End If
				ls_parttype2 = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows2])
				ls_partcod2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows2])
				ls_zoncod2   = Trim(tab_1.idw_tabpage[ai_select_tab].object.zoncod[ll_rows2])
				ls_tmcod2    = Trim(tab_1.idw_tabpage[ai_select_tab].object.tmcod[ll_rows2])
				ls_frpoint2  = String(tab_1.idw_tabpage[ai_select_tab].object.frpoint[ll_rows2])
				ls_areanum2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows2])
				ls_itemcod2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.itemcod[ll_rows2])
				ls_opendt2   = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows2], 'yyyymmdd')
				ls_enddt2    = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows2], 'yyyymmdd')
				
				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
				
				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
					And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
					
					If ls_enddt1 >= ls_opendt2 Then
						f_msg_info(9000, Title, "같은 대역[ " + ls_zoncod1 + " ], 같은 착신지번호[ " + ls_areanum1 + " ], 같은 시간대[ " + ls_tmcod1 + " ], " &
														+ "같은 사용범위[ " + ls_frpoint1 + " ], 같은 품목[ " + ls_itemcod1 + " ]으로 적용개시일이 중복됩니다.")
						Return -1
					End If
				End If
				
			Next
		Next
		
		//Update Log
		For ll_row = 1  To ll_rows
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_row, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()
			End If
		Next
		
	Case 6
		
		
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		If ll_row < 0 Then Return 0

		For i = 1 To ll_row
			ls_areanum = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[1])
			ls_opendt = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[1], 'YYYYMMDD')
				
			If IsNull(ls_areanum) Then ls_areanum = ""
			If IsNull(ls_opendt) Then ls_opendt = ""
					
			If ls_areanum = "" Then
				f_msg_usr_err(200, Title, "제한번호")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("areanum")
				Return -2
			End If
					
			If ls_opendt = "" Then
				f_msg_usr_err(200, Title, "적용개시일")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("opendt")
				Return -2
			End If
		
		Next
		
		//적용종료일 체크
		For i = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
			ls_opendt = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.opendt[i], 'yyyymmdd'))
			ls_enddt  = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.enddt[i], 'yyyymmdd'))
			
			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
			
			If ls_opendt > ls_enddt Then
				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
				tab_1.idw_tabpage[ai_select_tab].setColumn("enddt")
				tab_1.idw_tabpage[ai_select_tab].setRow(i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				Return -2
			End If
		Next
		
		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
		For ll_rows = 1 To tab_1.idw_tabpage[ai_select_tab].RowCount()
			ls_parttype1 = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows])
			ls_partcod1  = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows])
			ls_areanum1  = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows])
			ls_opendt1   = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows], 'yyyymmdd')
			ls_enddt1    = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows], 'yyyymmdd')
			
			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
			
			For ll_rows1 = tab_1.idw_tabpage[ai_select_tab].RowCount() To ll_rows - 1 Step -1
				If ll_rows = ll_rows1 Then
					Exit
				End If
				ls_parttype2 = Trim(tab_1.idw_tabpage[ai_select_tab].object.parttype[ll_rows1])
				ls_partcod2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.partcod[ll_rows1])
				ls_areanum2  = Trim(tab_1.idw_tabpage[ai_select_tab].object.areanum[ll_rows1])
				ls_opendt2   = String(tab_1.idw_tabpage[ai_select_tab].object.opendt[ll_rows1], 'yyyymmdd')
				ls_enddt2    = String(tab_1.idw_tabpage[ai_select_tab].object.enddt[ll_rows1], 'yyyymmdd')
				
				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
				
				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_areanum1 = ls_areanum2) Then
					If ls_enddt1 >= ls_opendt2 Then
						f_msg_info(9000, Title, "같은 제한번호[ " + ls_areanum1 + " ]로 적용개시일이 중복됩니다.")
						Return -1
					End If
				End If
				
			Next
			
		Next
		
			
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		//Update Log
		For i = 1  To ll_row
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] = gs_user_id
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[i] = fdt_get_dbserver_now()
			End If
		Next
		
		Case 7

      tab_1.idw_tabpage[ai_select_tab].AcceptText()
		
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For ll_i = 1 To ll_row
		
			//tab_1.idw_tabpage[ai_select_tab].AcceptText()
	
			//유형 체크
			
			ls_partner_1    = Trim(tab_1.idw_tabpage[ai_select_tab].Object.partner[ll_i])
			ls_priceplan_1  = Trim(tab_1.idw_tabpage[ai_select_tab].Object.priceplan[ll_i])
			ls_cnt_limitflag = Trim(tab_1.idw_tabpage[ai_select_tab].Object.cnt_limit_flag[ll_i])
			ls_amt_limitflag = Trim(tab_1.idw_tabpage[ai_select_tab].Object.amt_limit_flag[ll_i]) 
	      
			IF IsNull(ls_partner_1) THEN ls_partner_1 = ""
			IF IsNull(ls_priceplan_1) THEN ls_priceplan_1 = ""
			IF IsNull(ls_cnt_limitflag) THEN ls_cnt_limitflag = ""
			If IsNull(ls_amt_limitflag) THEN ls_amt_limitflag = ""
			
			IF ls_priceplan_1 = "" THEN
				f_msg_usr_err(200, Title, "가격정책")
				tab_1.idw_tabpage[ai_select_tab].setColumn("priceplan")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				RETURN -2
			END IF
			
			select count(cnt_limit_flag)
           into :ll_cnt_1
           from partner_priceplan
          where partner    =:ls_partner_1 
			   and priceplan = :ls_priceplan_1
				;


          If SQLCA.SQLCode < 0 Then	
	          f_msg_sql_err(title,  " Select Error" )
	          Return -2 	
          End if

         select count(amt_limit_flag)
           into :ll_cnt_2
           from partner_priceplan
          where partner = :ls_partner_1
			   and priceplan = :ls_priceplan_1;


         If SQLCA.SQLCode < 0 Then	
	         f_msg_sql_err(title,  " Select Error" )
	         Return -2 	
         End if
			//라인 맞춰라
			
			IF ls_cnt_limitflag <> "" THEN
				If ls_amt_limitflag <> "" then
					f_msg_usr_err(200, Title, "한도건수 관리유형 또는 금액건수 관리유형중 한가지만 등록 가능합니다.")
					tab_1.idw_tabpage[ai_select_tab].setColumn("cnt_limit_flag")
					tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
					tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
					tab_1.idw_tabpage[ai_select_tab].setFocus()
					tab_1.idw_tabpage[ai_select_tab].object.cnt_limit_flag[ll_i] = ""
					tab_1.idw_tabpage[ai_select_tab].object.amt_limit_flag[ll_i] = ""
					RETURN -2
				END IF
			End if
			
			/*IF ls_cnt_limitflag = "" THEN
				If ls_amt_limitflag = "" then
				f_msg_usr_err(200, Title, "한도건수 관리유형 또는 금액건수 관리유형중 한가지는 등록 해야 합니다.")
				tab_1.idw_tabpage[ai_select_tab].setColumn("cnt_limit_flag")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				tab_1.idw_tabpage[ai_select_tab].object.cnt_limit_flag[ll_i] = ""
				tab_1.idw_tabpage[ai_select_tab].object.amt_limit_flag[ll_i] = ""
				RETURN -2
			   END IF
		    End if
			 
			 IF ls_amt_limitflag <> "" THEN
				If ls_cnt_limitflag <> "" then
				f_msg_usr_err(200, Title, "한도건수 관리유형 또는 금액건수 관리유형중 한가지만 등록 가능합니다.")
				tab_1.idw_tabpage[ai_select_tab].setColumn("cnt_limit_flag")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				tab_1.idw_tabpage[ai_select_tab].object.cnt_limit_flag[ll_i] = ""
				RETURN -2
			   END IF
		    End if
			 
			 IF ll_cnt_1 > 0 then
		      IF ls_amt_limitflag <> "" Then
			    f_msg_usr_err(201, Title, "한도건수 관리유형 또는 한도금액 관리유형중 한가지만 등록 가능합니다.")
			    tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
		       tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
		       tab_1.idw_tabpage[ai_select_tab].setColumn("amt_limit_flag")
			    tab_1.idw_tabpage[ai_select_tab].object.amt_limit_flag[ll_i] = ""
		       Return -2
		      end if	
          elseIf ll_cnt_2 > 0 then
	         if ls_cnt_limitflag <> "" then 
		       f_msg_usr_err(201, Title, "한도건수 관리유형 또는 한도금액 관리유형중 한가지만 등록 가능합니다.")
		       tab_1.idw_tabpage[ai_select_tab].setRow(ll_i)
		       tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_i)
		       tab_1.idw_tabpage[ai_select_tab].setColumn("cnt_limit_flag")
			    tab_1.idw_tabpage[ai_select_tab].object.cnt_limit_flag[ll_i] = ""
		       Return -2
	         end if
          End if*/
		next
End Choose

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_partner
Dec lc_troubleno
Long ll_master_row

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

IF 	li_tab_index = 4 Then   //여신정보저장 시 partnermst의 tot_credit 계산을 다시한다.
	
	String ls_errmsg
	long ll_return
	Double ldb_count
	
	ll_return = -1
	ls_errmsg = space(256)
	
	ll_master_row = dw_master.GetRow()
	If ll_master_row = 0 Then Return -1		//해당 고객 없음
	ls_partner = dw_master.object.partner[ll_master_row]
	//처리부분...
	//subroutine B2W_PARTNERBOUND_CAL(string P_FLAG,string P_PARTNER,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"CPASS~".~"B2W_PARTNERBOUND_CAL~""
	SQLCA.B2W_PARTNERBOUND_CAL('P',ls_partner,gs_user_id, ll_return, ls_errmsg, ldb_count)
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
		ll_return = -1
	ElseIf ll_return < 0 Then	//For User
		MessageBox(This.Title, ls_errmsg)
	End If

	If ll_return <> 0 Then	//실패
		Return -1
	End If	   
End IF

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

String ls_troubletype
Long ll_row, ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab

If ib_new = True Then					//신규 등록이면		
	ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
	If ll_tab_rowcount < 1 Then Return 0
 	
	 If  li_selectedtab = 1 Then			//Tab 1
	 ls_partner = tab_1.idw_tabpage[1].Object.partner[1]	//조건을 넣고
	 TriggerEvent("ue_reset")
	 dw_cond.object.partner[1] = ls_partner
	 dw_cond.object.new[1] = "N"
	 ib_new = False	 					//초기화 
	 dw_cond.Enabled = True
	 ll_row = TriggerEvent("ue_ok")		//조회
	 
	 If ll_row < 0 Then 
		f_msg_usr_err(2100,Title, "Retrieve()")
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
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1,2,4,5,6,7
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

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
CALL w_a_m_master::resize

Integer	li_index


If sizetype = 1 Then Return

SetRedraw(False)
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
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 250
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
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

// Call the resize functions


SetRedraw(True)

end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b2w_reg_partnermst_v20_1
integer x = 55
integer y = 40
integer width = 2665
integer height = 240
string dataobject = "b2dw_cnd_reg_partnermst"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within b2w_reg_partnermst_v20_1
integer x = 2889
integer y = 56
end type

type p_close from w_a_reg_m_tm2`p_close within b2w_reg_partnermst_v20_1
integer x = 3195
integer y = 56
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b2w_reg_partnermst_v20_1
integer width = 2747
integer height = 292
end type

type dw_master from w_a_reg_m_tm2`dw_master within b2w_reg_partnermst_v20_1
integer y = 320
integer width = 3470
integer height = 604
string dataobject = "b2dw_inq_partnermst_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.partner_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;call super::clicked;Int li_rc, li_return, li_cnt, li_i
String ls_credit_yn, ls_partner

//THIS.b_1.Enabled = TRUE
Choose Case tab_1.SelectedTab
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 3
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 4
		ls_partner = Trim(dw_master.object.partner[row])
		
		select credit_yn
		 into :ls_credit_yn
		 from partnermst
		where partner = :ls_partner;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "SELECT credit_yn")			
			Return -1
		End If	
		
		//여신한도관리여부가 Y일때만..			
		If ls_credit_yn = 'N' or isnull(ls_credit_yn) Then
			tab_1.idw_tabpage[3].Reset()
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		Else
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		End if
		
		Case 8
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_tm2`p_insert within b2w_reg_partnermst_v20_1
integer y = 1920
end type

type p_delete from w_a_reg_m_tm2`p_delete within b2w_reg_partnermst_v20_1
integer y = 1920
end type

type p_save from w_a_reg_m_tm2`p_save within b2w_reg_partnermst_v20_1
integer y = 1920
end type

type p_reset from w_a_reg_m_tm2`p_reset within b2w_reg_partnermst_v20_1
integer y = 1920
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b2w_reg_partnermst_v20_1
integer y = 964
integer width = 3461
integer height = 928
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 11 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "기초정보"
is_tab_title[2] = "WebID관리"
is_tab_title[3] = "하위대리점정보"
is_tab_title[4] = "여신정보"
is_tab_title[5] = "대역별요율"
is_tab_title[6] = "착신지제한번호"
is_tab_title[7] = "가격정책"
is_tab_title[8] = "사용한도"
is_tab_title[9] = "선불상품모델"
is_tab_title[10] = "선불충전정책"
is_tab_title[11] = "선불카드 Prefix"

is_dwobject[1] = "b2dw_reg_partnermst_t1_v20_1"  //2005.11.23 juede phone2 add
is_dwobject[2] = "b2dw_reg_partnermst_t7_v20"
is_dwobject[3] = "b2dw_reg_partnermst_t2_v20"
is_dwobject[4] = "b2dw_reg_partnermst_t3"
is_dwobject[5] = "b0dw_reg_particular_zoncst"  //"b2dw_reg_partnermst_t4_1"
is_dwobject[6] = "b0dw_reg_blacklist_a"  //"b2dw_reg_partnermst_t5"
is_dwobject[7] = "b2dw_reg_partnermst_t6"
is_dwobject[8] = "b2dw_reg_partnermst_t8_v20"
is_dwobject[9] = "b2dw_reg_partnermst_t9_v20"
is_dwobject[10]= "b2dw_reg_partnermst_t10_v20"
is_dwobject[11]= "b2dw_reg_partnermst_t11_v20"

end event

event tab_1::constructor;call super::constructor;//help Window
//idw_tabpage[1].is_help_win[3] = "b2w_hlp_partnermst"
//idw_tabpage[1].idwo_help_col[3] = idw_tabpage[1].Object.partner
//idw_tabpage[1].is_data[3] = "CloseWithReturn"

idw_tabpage[1].is_help_win[1] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.zipcod
idw_tabpage[1].is_data[1] = "CloseWithReturn"

idw_tabpage[2].is_help_win[1] = "b2w_hlp_logid_v20"
idw_tabpage[2].idwo_help_col[1] = idw_tabpage[2].Object.emp_id
idw_tabpage[2].is_data[1] = "CloseWithReturn"
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;Choose Case ai_tabpage
	Case 1
		Choose Case adwo_dwo.name
//			Case "partner"		//partner
//				If ib_new = True Then
//					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//						 idw_tabpage[ai_tabpage].Object.partner[al_row] = &
//						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
//						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					End If
//				End If
	
			Case "zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
	Case 2
//		If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//		    idw_tabpage[ai_tabpage].Object.emp_id[al_row] = &
//		    idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//		End If
End Choose  

Return 0 

end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Change Event
String ls_codename, ls_closeyn, ls_code, ls_opendt
integer li_rc, li_seltab
datetime ldt_date
Long li_exist
String ls_filter, ls_munitsec
DataWindowChild ldc_hpartner

li_seltab = tab_1.SelectedTab

Choose Case li_seltab
	Case 1														//Tab 1
		Choose Case dwo.name
//			Case "partner"
//				 tab_1.idw_tabpage[li_seltab].Object.logid[row] = data
//				 
			Case "levelcod"
//				Modify("hpartner.dddw.name=''")
//				Modify("hpartner.dddw.DataColumn=''")
//				Modify("hpartner.dddw.DisplayColumn=''")
//				tab_1.idw_tabpage[li_seltab].Modify("hpartner.dddw.name='b2dc_dddw_hpartner'")
//				tab_1.idw_tabpage[li_seltab].Modify("hpartner.dddw.DataColumn='partner'")
//				tab_1.idw_tabpage[li_seltab].Modify("hpartner.dddw.DisplayColumn='partnernm'")

				//LEVELCOD가 바뀜에 따라서 상위대리점 바뀐다...
//				tab_1.idw_tabpage[li_seltab].object.hpartner[row] = ''		//DDDW 구함				
				li_exist = tab_1.idw_tabpage[li_seltab].GetChild("hpartner", ldc_hpartner)		//DDDW 구함
				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 상위대리점")
			
				SELECT max(code)
				  INTO :ls_code
				  FROM syscod2t
				 WHERE grcode = 'A100'
				   AND use_yn= 'Y'
					AND code < :data;
					
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(parent.title, "SELECT SYSCOD2T MAX(CODE)")				
					Return 1
				End If	
				
				If isnull(ls_code) Then ls_code = ' '
//				ls_filter = "levelcod = ( select max(code) from syscod2t where grcode='A100' and use_yn='Y' and code < '" + data  + "')" 
				ls_filter = "levelcod = '" + ls_code  + "'" 				
				ldc_hpartner.SetTransObject(SQLCA)
				li_exist =ldc_hpartner.Retrieve()
				ldc_hpartner.SetFilter(ls_filter)			//Filter정함
				ldc_hpartner.Filter()
				
//				ldc_hpartner.SetTransObject(SQLCA)
//				li_exist =ldc_hpartner.Retrieve(data)
				
				If li_exist < 0 Then 				
				  	f_msg_usr_err(2100, Title, "Retrieve()")
			  		Return 1  		//선택 취소 focus는 그곳에
				End If  
				
				//선택할수 있게
			   tab_1.idw_tabpage[li_seltab].Object.hpartner.Protect = 0
				
//			Case "hpartner"
//
//				//LEVELCOD가 바뀜에 따라서 상위대리점 바뀐다...
//				tab_1.idw_tabpage[li_seltab].object.hpartner[row] = ''		//DDDW 구함				
//				li_exist = tab_1.idw_tabpage[li_seltab].GetChild("hpartner", ldc_hpartner)		//DDDW 구함
//				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 상위대리점")
//			
//				SELECT max(code)
//				  INTO :ls_code
//				  FROM syscod2t
//				 WHERE grcode = 'A100'
//				   AND use_yn= 'Y'
//					AND code < :data;
//					
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(parent.title, "SELECT SYSCOD2T MAX(CODE)")				
//					Return 1
//				End If	
//				
//				If isnull(ls_code) Then ls_code = ' '
////				ls_filter = "levelcod = ( select max(code) from syscod2t where grcode='A100' and use_yn='Y' and code < '" + data  + "')" 
//				ls_filter = "levelcod = '" + ls_code  + "'" 				
//				ldc_hpartner.SetTransObject(SQLCA)
//				li_exist =ldc_hpartner.Retrieve()
//				ldc_hpartner.SetFilter(ls_filter)			//Filter정함
//				ldc_hpartner.Filter()
//				
////				ldc_hpartner.SetTransObject(SQLCA)
////				li_exist =ldc_hpartner.Retrieve(data)
//				
//				If li_exist < 0 Then 				
//				  	f_msg_usr_err(2100, Title, "Retrieve()")
//			  		Return 1  		//선택 취소 focus는 그곳에
//				End If  
//				
//				//선택할수 있게
//			   tab_1.idw_tabpage[li_seltab].Object.hpartner.Protect = 0
//				
				
	   End Choose
		
	Case 5
		If (tab_1.idw_tabpage[4].GetItemStatus(row, 0, Primary!) = New!) Or (tab_1.idw_tabpage[4].GetItemStatus(row, 0, Primary!)) = NewModified!	Then
			ls_munitsec = "0"
		Else
			ls_munitsec = String(tab_1.idw_tabpage[4].object.munitsec[row])
			If IsNull(ls_munitsec) Then ls_munitsec = ""
		End If

		Choose Case dwo.name
			Case "zoncod"
				If data <> "ALL" Then
					tab_1.idw_tabpage[4].Object.areanum[row] = "ALL"
					tab_1.idw_tabpage[4].Object.areanum.Protect = 1
				Else
					tab_1.idw_tabpage[4].Object.areanum[row] = ""
					tab_1.idw_tabpage[4].Object.areanum.Protect = 0
				End If
				
			Case "enddt"
				ls_opendt	= Trim(String(tab_1.idw_tabpage[4].Object.opendt[row],'yyyymmdd'))
		
				If data <> "" Then
					If ls_opendt > data Then
						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
						tab_1.idw_tabpage[4].setColumn("enddt")
						tab_1.idw_tabpage[4].setRow(row)
						tab_1.idw_tabpage[4].scrollToRow(row)
						tab_1.idw_tabpage[4].setFocus()
						Return -1
					End If
				End If
				
			Case "unitsec"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitsec[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitsec[row] = Long(data)
					End If
				End If
				
			Case "unitfee"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitfee[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitfee[row] = Long(data)
					End If
				End If
				
			Case "tmrange1"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.mtmrange1[row] > 0)  Then
						tab_1.idw_tabpage[4].object.mtmrange1[row] = Long(data)
					End If
				End If
				
			Case "unitsec1"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].object.munitsec1[row] > 0) Then
						tab_1.idw_tabpage[4].object.munitsec1[row] = Long(data)
					End If
				End If
				
			Case "unitfee1"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].object.munitfee[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitfee1[row] = Long(data)
					End If
				End If
				
			Case "tmrange2"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.mtmrange2[row] > 0)  Then
						tab_1.idw_tabpage[4].object.mtmrange2[row] = Long(data)
					End If
				End If
			
				
			Case "unitsec2"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitsec2[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitsec2[row] = Long(data)
					End If
				End If
				
			Case "unitfee2"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitfee2[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitfee2[row] = Long(data)
					End If
				End If
				
			Case "tmrange3"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.mtmrange3[row] > 0)  Then
						tab_1.idw_tabpage[4].object.mtmrange3[row] = Long(data)
					End If
				End If
				
			Case "unitsec3"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitsec3[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitsec3[row] = Long(data)
					End If
				End If
				
			Case "unitfee3"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitfee3[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitfee3[row] = Long(data)
					End If
				End If
				
			Case "tmrange4"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.mtmrange4[row] > 0)  Then
						tab_1.idw_tabpage[4].object.mtmrange4[row] = Long(data)
					End If
				End If
				
			Case "unitsec4"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitsec4[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitsec4[row] = Long(data)
					End If
				End If
				
			Case "unitfee4"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitfee4[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitfee4[row] = Long(data)
					End If
				End If
				
			Case "tmrange5"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.mtmrange5[row] > 0)  Then
						tab_1.idw_tabpage[4].object.mtmrange5[row] = Long(data)
					End If
				End If
				
			Case "unitsec5"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitsec5[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitsec5[row] = Long(data)
					End If
				End If
				
			Case "unitfee5"
				If ls_munitsec = '0' Or ls_munitsec = "" Then
					If NOT(tab_1.idw_tabpage[4].Object.munitfee5[row] > 0)  Then
						tab_1.idw_tabpage[4].object.munitfee5[row] = Long(data)
					End If
				End If
		End Choose
		
	Case 6
		Choose Case dwo.name
			Case "enddt"
				ls_opendt	= Trim(String(tab_1.idw_tabpage[5].Object.opendt[row],'yyyymmdd'))
		
				If data <> "" Then
					If ls_opendt > data Then
						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
						tab_1.idw_tabpage[5].setColumn("enddt")
						tab_1.idw_tabpage[5].setRow(row)
						tab_1.idw_tabpage[5].scrollToRow(row)
						tab_1.idw_tabpage[5].setFocus()
						Return -1
					End If
				End If
		End Choose
End Choose

Return 0 
end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;//Retrieve
String ls_where, ls_partner, ls_prefixno, ls_credit_yn, ls_type, ls_desc
Long ll_row, i
Dec lc_troubleno, lc_data

If al_master_row = 0 Then Return -1		//해당 고객 없음

Choose Case ai_select_tabpage
	Case 1								//Tab 1
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partner = '" + ls_partner + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
//		tab_1.idw_tabpage[ai_select_tabpage].object.partner.Protect = 1
		tab_1.idw_tabpage[ai_select_tabpage].object.levelcod.Protect = 1
		tab_1.idw_tabpage[ai_select_tabpage].Object.hpartner.Protect = 1
		tab_1.idw_tabpage[ai_select_tabpage].Object.levelcod.Background.Color = RGB(255, 251, 240)
		tab_1.idw_tabpage[ai_select_tabpage].Object.levelcod.Color = RGB(0, 0, 0)		
		tab_1.idw_tabpage[ai_select_tabpage].Object.hpartner.Background.Color = RGB(255, 251, 240)
		tab_1.idw_tabpage[ai_select_tabpage].Object.hpartner.Color = RGB(0, 0, 0)		
		
		//partner 값 수정 못한다...
//		tab_1.idw_tabpage[ai_select_tabpage].object.partner.Pointer = "Arrow!"
//		tab_1.idw_tabpage[ai_select_tabpage].idwo_help_col[1] = idw_tabpage[ai_select_tabpage].object.updt_user

	Case 2
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "emp_group = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 3								//Tab 2
		ls_prefixno = dw_master.object.prefixno[al_master_row]		
		ls_where = "prefixno like '" + ls_prefixno + "%' and prefixno <> '" + ls_prefixno + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 4								//Tab 1
		ls_partner = dw_master.object.partner[al_master_row]		
		
		select credit_yn
		 into :ls_credit_yn
		 from partnermst
		where partner = :ls_partner;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "SELECT credit_yn")			
			Return -1
		End If	
		
		//여신한도관리여부 확인
		If ls_credit_yn= "N" or isnull(ls_credit_yn) Then
		   idw_tabpage[ai_select_tabpage].Reset()
			Return 0		//조회하지 않는다.
		End If	
		  
		ls_where = "partner = '" + ls_partner + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
	
	Case 5
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partcod = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		ls_type = fs_get_control("B1", "Z100", ls_desc)
		
		If ls_type = "0" Then
			tab_1.idw_tabpage[5].object.frpoint.Format = "#,##0"
			tab_1.idw_tabpage[5].object.confee.Format = "#,##0"
			tab_1.idw_tabpage[5].object.unitfee.Format = "#,##0"
			tab_1.idw_tabpage[5].object.unitfee1.Format = "#,##0"
			tab_1.idw_tabpage[5].object.unitfee2.Format = "#,##0"
			tab_1.idw_tabpage[5].object.unitfee3.Format = "#,##0"
			tab_1.idw_tabpage[5].object.unitfee4.Format = "#,##0"
			tab_1.idw_tabpage[5].object.unitfee5.Format = "#,##0"
			tab_1.idw_tabpage[5].object.munitfee.Format  = "#,##0"
			tab_1.idw_tabpage[5].object.munitfee1.Format = "#,##0"
			tab_1.idw_tabpage[5].object.munitfee2.Format = "#,##0"
			tab_1.idw_tabpage[5].object.munitfee3.Format = "#,##0"
			tab_1.idw_tabpage[5].object.munitfee4.Format = "#,##0"
			tab_1.idw_tabpage[5].object.munitfee5.Format = "#,##0"
		ElseIf ls_type = "1" Then
			tab_1.idw_tabpage[5].object.frpoint.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.confee.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.unitfee.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.unitfee1.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.unitfee2.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.unitfee3.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.unitfee4.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.unitfee5.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.munitfee.Format  = "#,##0.0"
			tab_1.idw_tabpage[5].object.munitfee1.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.munitfee2.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.munitfee3.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.munitfee4.Format = "#,##0.0"
			tab_1.idw_tabpage[5].object.munitfee5.Format = "#,##0.0"
		ElseIf ls_type = "2" Then
			tab_1.idw_tabpage[5].object.frpoint.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.confee.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.unitfee.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.unitfee1.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.unitfee2.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.unitfee3.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.unitfee4.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.unitfee5.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.munitfee.Format  = "#,##0.00"
			tab_1.idw_tabpage[5].object.munitfee1.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.munitfee2.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.munitfee3.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.munitfee4.Format = "#,##0.00"
			tab_1.idw_tabpage[5].object.munitfee5.Format = "#,##0.00"
		ElseIF ls_type = "3" Then
			tab_1.idw_tabpage[5].object.frpoint.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.confee.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.unitfee.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.unitfee1.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.unitfee2.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.unitfee3.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.unitfee4.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.unitfee5.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.munitfee.Format  = "#,##0.000"
			tab_1.idw_tabpage[5].object.munitfee1.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.munitfee2.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.munitfee3.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.munitfee4.Format = "#,##0.000"
			tab_1.idw_tabpage[5].object.munitfee5.Format = "#,##0.000"
		Else
			tab_1.idw_tabpage[5].object.frpoint.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.confee.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.unitfee.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.unitfee1.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.unitfee2.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.unitfee3.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.unitfee4.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.unitfee5.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.munitfee.Format  = "#,##0.0000"
			tab_1.idw_tabpage[5].object.munitfee1.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.munitfee2.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.munitfee3.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.munitfee4.Format = "#,##0.0000"
			tab_1.idw_tabpage[5].object.munitfee5.Format = "#,##0.0000"
		End If
		
		For i =1 To tab_1.idw_tabpage[5].RowCount()
			lc_data = tab_1.idw_tabpage[5].object.unbilsec[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unbilsec[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.confee[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.confee[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitfee1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitfee1[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.tmrange1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.tmrange1[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitsec1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitsec1[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitfee2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitfee2[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.tmrange2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.tmrange2[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitsec2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitsec2[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitfee3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitfee3[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.tmrange3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.tmrange3[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitsec3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitsec3[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitfee4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitfee4[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.tmrange4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.tmrange4[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitsec4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitsec4[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitfee5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitfee5[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.tmrange5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.tmrange5[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.unitsec5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.unitsec5[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitfee1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitfee1[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.mtmrange1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.mtmrange1[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitsec1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitsec1[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitfee2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitfee2[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.mtmrange2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.mtmrange2[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitsec2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitsec2[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitfee3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitfee3[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.mtmrange3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.mtmrange3[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitsec3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitsec3[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitfee4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitfee4[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.mtmrange4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.mtmrange4[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitsec4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitsec4[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitfee5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitfee5[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.mtmrange5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.mtmrange5[i] = 0
			lc_data = tab_1.idw_tabpage[5].object.munitsec5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[5].object.munitsec5[i] = 0

			tab_1.idw_tabpage[5].SetItemStatus(i, 0, Primary!, NotModified!)
		Next		
		
	Case 6
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partcod = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 7
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partner = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 8
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partner = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 9
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partner = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 10
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partner = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 11
		ls_partner = dw_master.object.partner[al_master_row]		
		ls_where = "partner = '" + ls_partner + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
End Choose

Return 0 
		
end event

event tab_1::selectionchanging;call super::selectionchanging;//1  Prevent the selection from changing
String ls_credit_yn, ls_partner
Long ll_master_row
ll_master_row = dw_master.GetSelectedRow(0)
//신규 등록이면
If ib_new = TRUE Then Return 1

Choose Case newindex
	Case 4
		If ll_master_row > 0 Then
			ls_partner = Trim(dw_master.object.partner[ll_master_row])
			
			select credit_yn
			 into :ls_credit_yn
			 from partnermst
			where partner = :ls_partner;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, "SELECT credit_yn")			
				Return -1
			End If	
		
			//선불고객이거나 고객과 납입자가 다를경우 
			If ls_credit_yn = 'N' or isnull(ls_credit_yn) Then Return 1
		End If
End Choose

end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn, ls_credit_yn
ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 3
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 4
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 5
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 6
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 7
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 8
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 9
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 10
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 11
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")	
		
End Choose

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b2w_reg_partnermst_v20_1
integer y = 924
end type

