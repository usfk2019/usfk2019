$PBExportHeader$b8w_reg_admst_ssrt.srw
$PBExportComments$[1hera] 장비마스터정보관리 - 조회
forward
global type b8w_reg_admst_ssrt from w_a_reg_m_tm2
end type
end forward

global type b8w_reg_admst_ssrt from w_a_reg_m_tm2
integer width = 3410
integer height = 2024
end type
global b8w_reg_admst_ssrt b8w_reg_admst_ssrt

type variables
//SN할당대리점
String is_snpartner
end variables

on b8w_reg_admst_ssrt.create
int iCurrent
call super::create
end on

on b8w_reg_admst_ssrt.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;	Long		ll_rows
	String	ls_where
	String	ls_modelno, ls_serialno_fr, ls_serialno_to
	String	ls_status
	String	ls_idatefrom, ls_idateto
	String	ls_pid
	String	ls_movedtfrom, ls_movedtto
	String	ls_mv_partner
	String	ls_adstat
	String 	ls_contno_fr, ls_contno_to, ls_note, ls_saledt_fr, ls_saledt_to

	//Condition
	ls_saledt_fr	= Trim(String(dw_cond.Object.saledt_fr[1], "YYYYMMDD"))
	ls_saledt_to	= Trim(String(dw_cond.Object.saledt_to[1], "YYYYMMDD"))	
	ls_modelno		= Trim(dw_cond.Object.modelno[1])
	ls_contno_fr	= Trim(dw_cond.Object.contno_fr[1])
	ls_contno_to	= Trim(dw_cond.Object.contno_to[1])
	ls_serialno_fr	= Trim(dw_cond.Object.serialno_fr[1])
	ls_serialno_to	= Trim(dw_cond.Object.serialno_to[1])	
	ls_status		= Trim(dw_cond.Object.status[1])
	ls_idatefrom	= Trim(String(dw_cond.Object.idatefrom[1],"YYYYMMDD"))
	ls_idateto		= Trim(String(dw_cond.Object.idateto[1],"YYYYMMDD"))
	ls_pid			= Trim(dw_cond.Object.pid[1])
	ls_movedtfrom	= Trim(String(dw_cond.Object.movedtfrom[1],"YYYYMMDD"))
	ls_movedtto		= Trim(String(dw_cond.Object.movedtto[1],"YYYYMMDD"))
	ls_mv_partner	= Trim(dw_cond.Object.mv_partner[1])
	ls_adstat		= Trim(dw_cond.Object.adstat[1])
	ls_note			= Upper(Trim(dw_cond.Object.note[1]))
		
	IF IsNull(ls_saledt_fr) 	THEN ls_saledt_fr	= ""
	IF IsNull(ls_saledt_to) 	THEN ls_saledt_to	= ""	
	IF IsNull(ls_note) 			THEN ls_note 		= ""
	IF IsNull(ls_contno_fr) 	THEN ls_contno_fr = ""
	IF IsNull(ls_contno_to) 	THEN ls_contno_to = ""
	IF IsNull(ls_modelno) 		THEN ls_modelno 	= ""
	IF IsNull(ls_serialno_fr)	THEN ls_serialno_fr = ""
	IF IsNull(ls_serialno_to)	THEN ls_serialno_to = ""	
	IF IsNull(ls_status) 		THEN ls_status 	= ""
	IF IsNull(ls_idatefrom) 	THEN ls_idatefrom = ""
	IF IsNull(ls_idateto) 		THEN ls_idateto	= ""
	IF IsNull(ls_pid) 			THEN ls_pid 		= ""
	IF IsNull(ls_movedtfrom) 	THEN ls_movedtfrom = ""
	IF IsNull(ls_movedtto) 		THEN ls_movedtto 	= ""
	IF IsNull(ls_mv_partner) 	THEN ls_mv_partner = ""
	IF IsNull(ls_adstat) 		THEN ls_adstat 	= ""
	
	//입력조건이 모두 null이면 에러
	IF ls_modelno 		= "" AND &
		ls_contno_fr 	= "" AND &
		ls_contno_to 	= "" AND &
		ls_saledt_fr	= "" AND &
		ls_saledt_to	= "" AND &		
		ls_serialno_fr	= "" AND &
		ls_serialno_to	= "" AND &
		ls_status 		= "" AND &
		ls_idatefrom 	= "" AND &
		ls_idateto 		= "" AND &
		ls_pid 			= "" AND &
		ls_movedtfrom 	= "" AND &
		ls_movedtto 	= "" AND &
		ls_mv_partner 	= "" AND &
		ls_note 			= "" AND &
		ls_adstat 		= "" THEN
		
		f_msg_usr_err(200, Title, "조회조건")
		RETURN
		
	END IF
	
	//Dynamic SQL
	ls_where = ""
	
	IF ls_modelno <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "modelno = '" + ls_modelno + "'"
	END IF
	IF ls_contno_fr <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "contno >= '" + ls_contno_fr + "'"
	END IF
	IF ls_contno_to <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "contno <= '" + ls_contno_to + "'"
	END IF
	
	
	IF ls_saledt_fr <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(saledt, 'yyyymmdd') >= '" + ls_saledt_fr + "'"
	END IF
	IF ls_saledt_to <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(saledt, 'yyyymmdd') <= '" + ls_saledt_to + "'"
	END IF

	IF ls_serialno_fr <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "serialno >= '" + ls_serialno_fr + "'"
	END IF
	
	IF ls_serialno_to <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "serialno <= '" + ls_serialno_to + "'"
	END IF

	
	IF ls_status <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "status = '" + ls_status + "'"
	END IF
	
	IF ls_idatefrom <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(idate,'YYYYMMDD') >= '" + ls_idatefrom + "'"
	END IF
	
	IF ls_idateto <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(idate,'YYYYMMDD') <= '" + ls_idateto + "'"
	END IF
	
	IF ls_pid <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "pid LIKE '" + ls_pid + "%'"
	END IF
	
	IF ls_movedtfrom <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(movedt,'YYYYMMDD') >= '" + ls_movedtfrom + "'"
	END IF
	
	IF ls_movedtto <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(movedt,'YYYYMMDD') <= '" + ls_movedtto + "'"
	END IF
	
	IF ls_mv_partner <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "mv_partner = '" + ls_mv_partner + "'"
	END IF
	
	IF ls_adstat <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "adstat = '" + ls_adstat + "'"
	END IF
	IF ls_note <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "upper(remark) = '" + ls_note + "'"
	END IF
	
	
	//Retrieve
	dw_master.is_where = ls_where
	ll_rows = dw_master.Retrieve()
	If ll_rows = 0 Then
		f_msg_info(1000, Title, "")
		p_reset.TriggerEvent("ue_enable")
	ElseIf ll_rows < 0 Then
		f_msg_usr_err(2100, Title, "")
		p_reset.TriggerEvent("ue_enable")
		Return
	Else			
		//검색결과가 있으면 Tab을 활성화 시킨다.
		tab_1.Trigger Event SelectionChanged(1, 1)
		tab_1.Enabled = True
	End If
end event

event type integer ue_reset();call super::ue_reset;dw_cond.reset()
dw_cond.insertRow(0)

RETURN 0

end event

event open;call super::open;tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)

p_reset.TriggerEvent("ue_enable")
end event

event ue_save;//Override
CONSTANT INT LI_ERROR = -1
INT		li_tab_index,		li_return
STRING	ls_snpartner,		ls_status,			ls_status_old,			ls_action
DATE		ldt_null
LONG		ll_adseq,			ll_seq

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

IF li_tab_index = 1 THEN
   //Update정보
	tab_1.idw_tabpage[li_tab_index].Object.admst_updt_user[1] = gs_user_id
	tab_1.idw_tabpage[li_tab_index].Object.updtdt[1] = fdt_get_dbserver_now()
	
	//S/N변경정보
	ls_snpartner = Trim(tab_1.idw_tabpage[li_tab_index].Object.admst_sn_partner[1])
	IF is_snpartner <> ls_snpartner THEN
		IF ls_snpartner = "" THEN
			SetNull(ldt_null)
			tab_1.idw_tabpage[li_tab_index].Object.snmovedt[1] = ldt_null
		ELSE
			tab_1.idw_tabpage[li_tab_index].Object.snmovedt[1] = fdt_get_dbserver_now()
		END IF
	END If	
END IF


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

IF li_tab_index = 1 THEN
	ll_adseq		  = tab_1.idw_tabpage[li_tab_index].Object.adseq[1]
	ls_status	  = tab_1.idw_tabpage[li_tab_index].Object.status[1]
	ls_status_old = tab_1.idw_tabpage[li_tab_index].Object.status_old[1]
	
	IF ls_status <> ls_status_old THEN
		//ADMSTLOG_NEW 테이블에 ACTION 값 ( 상태변경 )
		SELECT ref_content INTO :ls_action FROM sysctl1t 
		WHERE module = 'U2' AND ref_no = 'A107';
		
		//장비이력(admstlog) Table에 정보저장
		//일련번호(seq)추출
		SELECT seq_admstlog.nextval	INTO :ll_seq	FROM dual;
				
		INSERT INTO ADMSTLOG_NEW		
			( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
			  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
			  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
			  PGM_ID, IDATE )
		SELECT ADSEQ, :ll_seq, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, :ls_status,
				 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
				 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
				 :gs_pgm_id[gi_open_win_no], IDATE
		FROM   ADMST
		WHERE  ADSEQ = :ll_adseq;
		
		IF SQLCA.SQLCODE < 0 THEN
			f_msg_sql_err(Title, "ADMSTLOG_NEW INSERT Error")
			ROLLBACK;			
			return -1
		END IF		
	END IF
END IF

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

RETURN 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b8w_reg_admst_ssrt
integer x = 41
integer width = 3003
integer height = 464
string dataobject = "b8dw_cnd_inq_admst_ssrt"
end type

event dw_cond::losefocus;call super::losefocus;AcceptText()
end event

event dw_cond::itemchanged;call super::itemchanged;choose case dwo.name
	case 'contno_fr'
		this.Object.contno_to[1] =  data
		
	case 'serialno_fr'
		this.Object.serialno_to[1] = data		
end choose
end event

type p_ok from w_a_reg_m_tm2`p_ok within b8w_reg_admst_ssrt
integer x = 3086
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_tm2`p_close within b8w_reg_admst_ssrt
integer x = 3086
integer y = 156
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b8w_reg_admst_ssrt
integer x = 27
integer width = 3035
integer height = 520
end type

type dw_master from w_a_reg_m_tm2`dw_master within b8w_reg_admst_ssrt
integer x = 23
integer y = 544
integer width = 3314
integer height = 444
string dataobject = "b8dw_inq_admst"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort
ldwo_sort = Object.adseq_t
uf_init( ldwo_sort )

end event

event dw_master::clicked;call super::clicked;//마지막에 선택된 Row로 간다.
tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

end event

type p_insert from w_a_reg_m_tm2`p_insert within b8w_reg_admst_ssrt
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b8w_reg_admst_ssrt
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b8w_reg_admst_ssrt
integer x = 361
integer y = 1784
end type

type p_reset from w_a_reg_m_tm2`p_reset within b8w_reg_admst_ssrt
integer x = 667
integer y = 1784
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b8w_reg_admst_ssrt
integer x = 23
integer y = 1032
integer width = 3301
integer height = 728
end type

event tab_1::ue_init;call super::ue_init;//Tab 초기화
ii_enable_max_tab = 2		//Tab 갯수
//Tab Title
is_tab_title[1] = "Equipment Master"
is_tab_title[2] = "Equipment History"



//Tab에 해당하는 dw
is_dwObject[1] = "b8dw_inq_admst_t1_ssrt"
is_dwObject[2] = "b8dw_inq_admst_t2_ssrt"






end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row		
String ls_status, ls_status_nm, ls_filter
Boolean lb_check1, lb_check2

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
   Return 0
End If

Choose Case newindex
	Case 1
			datawindowchild dw_status
			
			ls_status = dw_master.object.status[ll_master_row]
			
			select codenm into :ls_status_nm From syscod2t
			where grcode = 'B813'
			   and code = :ls_status;
				
			ls_filter = "codenm = '"+ ls_status_nm +" '"

			tab_1.idw_tabpage[1].GetChild("status", dw_status)
			dw_status.SetTransObject(SQLCA)
			dw_status.SetFilter (ls_filter)
			//dw_status.SetFilter ("")
			dw_status.Filter( ) 
		 	dw_status.retrieve()
	Case 2	


End Choose
Return 0
	
end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_adseq
String ls_where
Long ll_row
Int li_tab

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_adseq = Trim(String(dw_master.object.adseq[al_master_row]))

Choose Case li_tab
	Case 1								//Tab 1
		
	
		ls_where = "adseq = '" + ls_adseq + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		is_snpartner = Trim(idw_tabpage[li_tab].Object.admst_sn_partner[1])
      	p_save.TriggerEvent("ue_enable")
	
		
	
	Case 2								//Tab 2
		ls_where = "adseq = '" + ls_adseq + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		String ls_row
		ls_row = String(al_master_row)
		//세부 정보 표시..
		idw_tabpage[li_tab].object.t_ad_seq.Text = String(dw_master.object.adseq[al_master_row])
		idw_tabpage[li_tab].object.t_serialno.Text = String(dw_master.object.serialno[al_master_row])
		idw_tabpage[li_tab].object.t_modelno.Text  = &
			dw_master.Describe(" evaluate('lookupdisplay(modelno)', " + ls_row + ")" )
		
		
		p_save.TriggerEvent("ue_disable")

End Choose


Return 0

end event

event tab_1::ue_itemchanged;call super::ue_itemchanged;//Tab Retrieve
String ls_sale_flag, ls_use_yn, ls_status, ls_desc
String ls_where, ls_partner, ls_contno, ls_emp_group, ls_status_old
Long ll_row, ll_adseq
Int li_tab
datawindowchild dw_status
li_tab = 1

Choose Case li_tab
	Case 1								//Tab 1
		Choose Case dwo.name
			Case "use_yn"
				
				ls_sale_flag = Trim(idw_tabpage[li_tab].Object.sale_flag[1])
				
				If data = 'N' Then
					If ls_sale_flag <> '1' Then
						idw_tabpage[li_tab].Object.sale_flag[1] = '9'
					End If
				Else
					If ls_sale_flag <> '1' Then
						idw_tabpage[li_tab].Object.sale_flag[1] = '0'
					End If
				End If
			Case "status"  //displayed goods(DG100) 이면 use_yn = 'N'
				
				
				ls_sale_flag = Trim(idw_tabpage[li_tab].Object.sale_flag[1])
				If data = 'DG100' Then
					idw_tabpage[li_tab].Object.use_yn[1] = 'N'
					If ls_sale_flag <> '1' Then
						idw_tabpage[li_tab].Object.sale_flag[1] = '0'
					End If
				Else 
					idw_tabpage[li_tab].Object.use_yn[1] = 'Y'
					If ls_sale_flag <> '1' Then
						idw_tabpage[li_tab].Object.sale_flag[1] = '0'
					End If
				end If
				
		End Choose				
		
//		is_snpartner = Trim(idw_tabpage[li_tab].Object.admst_sn_partner[1])
		
		p_save.TriggerEvent("ue_enable")
	

End Choose


Return 0

end event

event tab_1::ue_dw_clicked;call super::ue_dw_clicked;Int li_tab
string ls_status, ls_emp_group, ls_partner, ls_contno, ls_status_nm, ls_filter
long ll_adseq
datawindowchild dw_status

li_tab = ai_tabpage
If al_row = 0 Then Return -1

Choose Case li_tab
	Case 1
		
		tab_1.idw_tabpage[li_tab].GetChild("status", dw_status)
		dw_status.SetTransObject(SQLCA)
		
		if adwo_dwo.name= 'status' then
			
			//권한확인
			ll_adseq =  tab_1.idw_tabpage[li_tab].object.adseq[1]
			ls_partner =  tab_1.idw_tabpage[li_tab].object.mv_partner[1]
			ls_contno = tab_1.idw_tabpage[li_tab].object.admst_contno[1]
			select emp_group into :ls_emp_group from sysusr1t where emp_id = :gs_user_id;
			select mv_partner into :ls_partner from admst where adseq = :ll_adseq;
		
	
			//		재고상태 : "SYSCOD2T"."GRCODE" = 'B813'  
			//		Displayed Goods	DG100
			//		Entering Goods	SN100
			//		Moving Goods	MG100
			//		Rental Goods	RP100
			//		Returning Goods	RT100
			//		Selling Goods	SG100	
			
			//		다음 3개의 케이스만 변경가능 1)Entering -> Displayed, 2) Returning -> Displayed , 3)Displayed -> Entering 	
			
			ls_status = tab_1.idw_tabpage[li_tab].object.status[1]
			
		
			
			If ls_status = 'SN100' or ls_status = 'RT100' Then
				
				IF ls_partner <> ls_emp_group THEN
						f_msg_usr_err(9000, Title, "샵 권한이 불충분합니다. Control No : " + ls_contno )
						Return     -1
			  	END IF
				  
				  	select codenm into :ls_status_nm From syscod2t
					where grcode = 'B813'
						and code =  'DG100' ;
				  
				  ls_filter = "codenm = '"+ ls_status_nm +" '"
			  	 dw_status.SetFilter  (ls_filter)
				 dw_status.Filter( ) 
				 dw_status.retrieve()
	
			elseif  ls_status = 'DG100'  Then
				
				IF ls_partner <> ls_emp_group THEN
						f_msg_usr_err(9000, Title, "샵 권한이 불충분합니다. Control No : " + ls_contno )
						Return     -1
			  	END IF
				  
				  	select codenm into :ls_status_nm From syscod2t
					where grcode = 'B813'
						and code =  'SN100' ;
				  
				  ls_filter = "codenm = '"+ ls_status_nm +" '"
			  	 dw_status.SetFilter  (ls_filter)
				 dw_status.Filter( ) 
				 dw_status.retrieve()
				
			else
				dw_status.SetFilter ("")
				dw_status.Filter( ) 
				dw_status.retrieve()
			End If
			
			
			
		End If	
		
		//dw_status.accepttext()
	



End Choose

return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b8w_reg_admst_ssrt
integer x = 14
integer y = 996
end type

