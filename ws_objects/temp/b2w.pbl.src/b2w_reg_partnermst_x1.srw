$PBExportHeader$b2w_reg_partnermst_x1.srw
$PBExportComments$xener:sysdbusrw:[parkkh] 대리점정보등록
forward
global type b2w_reg_partnermst_x1 from w_a_reg_m_tm2
end type
end forward

global type b2w_reg_partnermst_x1 from w_a_reg_m_tm2
integer width = 3584
integer height = 2208
end type
global b2w_reg_partnermst_x1 b2w_reg_partnermst_x1

type variables
Boolean ib_new			//신규 등록  True
String is_check, is_root, is_partner_old, is_logid_old


end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename)
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

on b2w_reg_partnermst_x1.create
int iCurrent
call super::create
end on

on b2w_reg_partnermst_x1.destroy
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

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert시 조건
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
		
	Case 3								//Tab 3
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

event type integer ue_extra_save(integer ai_select_tab);//Save
String ls_partner, ls_partnernm, ls_levelcod, ls_hpartner, ls_logid, ls_password, ls_emp_id, ls_todt
String ls_hprefixno, ls_hprefixno_1, ls_prefixno, ls_sql, ls_credit_yn, ls_bondtype, ls_fromdt, ls_bondamt
Long ll_row, ll_len, ll_len_1, ll_cnt
Integer li_rc, ll_i

//Row 수가 없으면aasaa
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

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
		ls_logid = Trim(tab_1.idw_tabpage[ai_select_tab].object.logid[ll_row])
		ls_password = Trim(tab_1.idw_tabpage[ai_select_tab].object.logpwd[ll_row])
		ls_emp_id = Trim(tab_1.idw_tabpage[ai_select_tab].object.emp_id[ll_row])
		ls_credit_yn = Trim(tab_1.idw_tabpage[ai_select_tab].object.credit_yn[ll_row])

		If IsNull(ls_partner) Then ls_partner = ""
		If IsNull(ls_partnernm) Then ls_partnernm = ""
		If IsNull(ls_levelcod) Then ls_levelcod = ""
		If IsNull(ls_password) Then ls_password = ""
		If IsNull(ls_logid) Then ls_logid = ""
		If IsNull(ls_hpartner) Then ls_hpartner = ""
		If IsNull(ls_emp_id) Then ls_emp_id = ""
    	If IsNull(ls_credit_yn) Then ls_credit_yn = ""
		
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

		If ls_logid= "" Then
			f_msg_usr_err(200, title, "Web Login ID")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("logid")
			Return -2
		End If

		If ls_credit_yn = "" Then
			f_msg_usr_err(200, title, "여신한도관리여부")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("credit_yn")
			Return -2
		End If

	
	   //sysdbusrw에서 uniq check한다. xener만 수정...
	   If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_row, "logid", Primary!) = DataModified! THEN

			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			  from sysdbusrw
			 where logid = :ls_logid;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(This.Title, "logid check")
				RollBack;
				Return -1
			End If				
			
			If ll_cnt <> 0 Then
				f_msg_usr_err(9000, Title, "이미 사용중인 logid입니다. 다시 입력하세요!!")  //삭제 안됨 
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("logid")
				tab_1.idw_tabpage[ai_select_tab].object.logid[1] = is_logid_old
				tab_1.idw_tabpage[ai_select_tab].SetItemStatus(1, "logid", Primary!, NotModified!)	
				Return -2
			End If
			
		End IF
		
		If ls_password = "" Then
			f_msg_usr_err(200, title, "Password")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("logpwd")
			Return -2
		End If
		
		If ls_emp_id = "" Then
			f_msg_usr_err(200, title, "System User ID")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("emp_id")
			Return -2
		End If

		If ib_new = True Then		//신규
		
//			ll_cnt = 0
//			select count(*)
//			  into :ll_cnt
//			  from partnermst
//			 where partner = :ls_partner;
//			  
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(This.Title, "대리점 코드 check")
//				RollBack;
//				Return -1
//			End If				
//			
//			If ll_cnt <> 0 Then
//				f_msg_usr_err(9000, Title, "이미 사용중인 대리점코드입니다. 다시 입력하세요!!")  //삭제 안됨 
//				tab_1.idw_tabpage[ai_select_tab].SetFocus()
//				tab_1.idw_tabpage[ai_select_tab].SetColumn("partner")
//				return -2
//			End If
			
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

			ll_cnt = 0
			select count(*)
			  into :ll_cnt
			  from sysdbusrw
			 where logid = :ls_logid;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(This.Title, "logid check")
				Return -1
			End If				
			
			If ll_cnt <> 0 Then
				f_msg_usr_err(9000, Title, "이미 사용중인 logid입니다. 다시 입력하세요!!")  //삭제 안됨 
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("logid")
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
		
	Case 3

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
End Choose

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
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
	Case 1,3
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

type dw_cond from w_a_reg_m_tm2`dw_cond within b2w_reg_partnermst_x1
integer x = 55
integer y = 40
integer width = 2665
integer height = 240
string dataobject = "b2dw_cnd_reg_partnermst"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within b2w_reg_partnermst_x1
integer x = 2889
integer y = 56
end type

type p_close from w_a_reg_m_tm2`p_close within b2w_reg_partnermst_x1
integer x = 3195
integer y = 56
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b2w_reg_partnermst_x1
integer width = 2747
integer height = 292
end type

type dw_master from w_a_reg_m_tm2`dw_master within b2w_reg_partnermst_x1
integer y = 320
integer width = 3470
integer height = 604
string dataobject = "b2dw_inq_partnermst"
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
		
	Case 2
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 3
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
		
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_tm2`p_insert within b2w_reg_partnermst_x1
integer y = 1920
end type

type p_delete from w_a_reg_m_tm2`p_delete within b2w_reg_partnermst_x1
integer y = 1920
end type

type p_save from w_a_reg_m_tm2`p_save within b2w_reg_partnermst_x1
integer y = 1920
end type

type p_reset from w_a_reg_m_tm2`p_reset within b2w_reg_partnermst_x1
integer y = 1920
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b2w_reg_partnermst_x1
integer y = 964
integer width = 3461
integer height = 928
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "기초정보"
is_tab_title[2] = "하위대리점정보"
is_tab_title[3] = "여신정보"

is_dwobject[1] = "b2dw_reg_partnermst_t1"
is_dwobject[2] = "b2dw_reg_partnermst_t2"
is_dwobject[3] = "b2dw_reg_partnermst_t3"

end event

event tab_1::constructor;call super::constructor;//help Window
//idw_tabpage[1].is_help_win[3] = "b2w_hlp_partnermst"
//idw_tabpage[1].idwo_help_col[3] = idw_tabpage[1].Object.partner
//idw_tabpage[1].is_data[3] = "CloseWithReturn"

idw_tabpage[1].is_help_win[1] = "b2w_hlp_logid_x1"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.logid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

idw_tabpage[1].is_help_win[2] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[2] = idw_tabpage[1].Object.zipcod
idw_tabpage[1].is_data[2] = "CloseWithReturn"
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
			Case "logid"		//Log ID
			//	If ib_new = True Then
					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					End If
			//	End If
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
End Choose  

Return 0 

end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Change Event
String ls_codename, ls_closeyn, ls_code
integer li_rc, li_seltab
datetime ldt_date
Long li_exist
String ls_filter
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
End Choose

Return 0 
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Retrieve
String ls_where, ls_partner, ls_prefixno, ls_credit_yn
Long ll_row
Dec lc_troubleno

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
		is_logid_old = tab_1.idw_tabpage[ai_select_tabpage].object.logid[1]
		
	Case 2								//Tab 2
		ls_prefixno = dw_master.object.prefixno[al_master_row]		
		ls_where = "prefixno like '" + ls_prefixno + "%' and prefixno <> '" + ls_prefixno + "'"
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 3								//Tab 1
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
	Case 3
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
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 3
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b2w_reg_partnermst_x1
integer y = 924
end type

