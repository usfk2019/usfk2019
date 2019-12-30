$PBExportHeader$p1w_reg_hotkey_contractseq_v20.srw
$PBExportComments$[ssong]insert hotkey by contractseq
forward
global type p1w_reg_hotkey_contractseq_v20 from w_a_reg_m_m
end type
end forward

global type p1w_reg_hotkey_contractseq_v20 from w_a_reg_m_m
end type
global p1w_reg_hotkey_contractseq_v20 p1w_reg_hotkey_contractseq_v20

type variables
String is_status
Long il_validkeycnt

end variables

on p1w_reg_hotkey_contractseq_v20.create
call super::create
end on

on p1w_reg_hotkey_contractseq_v20.destroy
call super::destroy
end on

event type integer ue_extra_delete();call super::ue_extra_delete;Int LI_ERROR, li_rc

LI_ERROR = -1

//삭제 작업 수행 여부 확인 
//li_rc = MessageBox(This.Title, "선택하신 자료를 삭제 하시겠습니까?",&
//								Question!, YesNo!)
								
//If li_rc <> 1 Then  Return LI_ERROR

Return 0

end event

event ue_extra_save;Long		ll_row, ll_rows, ll_cnthotkey, ll_cnt, ll_rows1, ll_rows2
String	ls_contractseq, ls_hotkey , ls_rtelno, ls_sort
String   ls_hotkey1, ls_hotkey2, ls_contractseq1, ls_contractseq2
String ls_temp, ls_ref_desc, ls_svctype

//ls_ref_desc = ""
//ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)

//필수항목 Check
ll_rows = dw_detail.RowCount()
For ll_row = 1 To ll_rows

	//Ⅰ. Current Row의 조건 확인
	ls_contractseq = Trim(String(dw_detail.Object.contractseq[ll_row]))
	ls_hotkey = Trim(dw_detail.Object.hotkey[ll_row])
	ls_rtelno = Trim(dw_detail.Object.rtelno[ll_row])
	
	If IsNull(ls_contractseq) Then ls_contractseq = ""
	If IsNull(ls_hotkey) Then ls_hotkey = ""
	If IsNull(ls_rtelno) Then ls_rtelno = ""	
	
	
		
	If ls_hotkey = "" Then
		f_msg_usr_err(200, Title, "단축번호")
		dw_detail.SetColumn("hotkey")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetFocus()
		Return -2
	End If
	
	If ls_rtelno = "" Then
		f_msg_usr_err(200, Title, "착신지 번호")
		dw_detail.SetColumn("rtelno")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetFocus()
		Return -2
	End If
	
	// pin번호 중복 체크
//	SELECT count(*) 
//	INTO :ll_cnt
//	FROM hotkey_contractseq
//	WHERE hotkey = :ls_hotkey;
//
//	// hotkey 중복 체크
//	If ll_cnt >= 1 Then
//		SELECT count(*) 
//		INTO :ll_cnthotkey
//		FROM hotkey_contractseq
//		WHERE contractseq = :ls_contractseq and hotkey = :ls_hotkey;
//				
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(title,  "Database Error(p_hotkey)" )
//			return -2
//		End If
//		
//		If ll_cnthotkey > 0 Then
//			f_msg_usr_err(9000, Title, ls_hotkey + "는 등록된 단축번호 입니다.")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetFocus()
//			dw_detail.SetColumn("hotkey")
//			return -2	
//			
//		End If
//	End If
Next

ls_sort = "hotkey"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows1 = 1 To dw_detail.RowCount()
	ls_hotkey1      = Trim(dw_detail.object.hotkey[ll_rows1])
	ls_contractseq1 = Trim(String(dw_detail.object.contractseq[ll_rows1]))
		
	If IsNull(ls_hotkey1) Or ls_hotkey1 = "" Then ls_hotkey1 = ''
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		ls_hotkey2      = Trim(dw_detail.object.hotkey[ll_rows2])
		ls_contractseq2 = Trim(String(dw_detail.object.contractseq[ll_rows2]))
				
		If IsNull(ls_hotkey2) Or ls_hotkey2 = "" Then ls_hotkey2 = ''
		
		If (ls_hotkey1 = ls_hotkey2) Then
			If ls_contractseq1 = ls_contractseq2 Then
				f_msg_info(9000, Title, "같은 단축번호[ " + ls_hotkey1 + " ], 같은 계약 Seq[ " + ls_contractseq1 + " ]로 단축번호가  중복됩니다.")
				Return -2
			End If
		End If
		
	Next
	
	//Update Log
	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rows1] = gs_user_id
		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_rows1] = gs_pgm_id[1]
	End If
	
Next


Return 0
end event

event ue_insert;// override : vgene
Constant Int LI_ERROR = -1
Long ll_row, ll_cnt, ll_master
String ls_contractseq
DateTime ld_enddt
//String ls_svccod, ls_customerid, ls_svctype, ls_status, ls_contractseq, ls_langtype
String ls_tmp, ls_ref_desc, ls_result[]
Integer li_return



//ll_master = dw_master.GetselectedRow(0)
//

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)



//ls_tmp = fs_get_control('P0', 'P000', ls_ref_desc)
//If ls_tmp = "" Then Return -1
		

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0




end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_validkey

//입력 조건 처리 부분
ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_validkey = Trim(dw_cond.Object.validkey[1])

If IsNull(ls_customerid) then ls_customerid = ""
If IsNull(ls_validkey) then ls_validkey = ""

If (ls_customerid = "" ) And ( ls_validkey = "") Then
		f_msg_info(200, Title, "고객번호 혹은 인증Key")
		dw_cond.SetFocus()
		dw_cond.setColumn("customerid")
		Return 
End If

//select contractseq
//into   :ls_contractseq
//from   validinfo
//where  contractseq in (select contractseq
//                         from validinfo
//							   where validkey =:ls_validkey);
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title, "validkey")
//	Return -1
//End If

//Error 처리부분
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_validkey) Then ls_validkey = ""

ls_where = ""

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.CUSTOMERID = '" + ls_customerid + "' "
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " C.VALIDKEY = '" + ls_validkey + "' "
End If


dw_master.is_where = ls_where
//자료 읽기 및 관련 처리부분
ll_rows = dw_master.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
//	p_insert.TriggerEvent('ue_enable') 
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
	Return
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

//p_insert.TriggerEvent("ue_disable")

end event

event ue_extra_insert;call super::ue_extra_insert;
Long ll_master_row , i, ll_row
//String ls_contractseq

ll_master_row = dw_master.GetRow()
						

		//ls_contractseq = Trim(String(dw_master.object.contractmst_contractseq[ll_master_row]))
		//Setting
		//dw_detail.object.contractseq[al_insert_row] = ls_contractseq
		dw_detail.object.contractseq[al_insert_row] = dw_master.Object.contractmst_contractseq[ll_master_row]
		dw_detail.object.crt_user[al_insert_row]    = gs_user_id
      dw_detail.object.crtdt[al_insert_row]       = fdt_get_dbserver_now()
      dw_detail.object.pgm_id[al_insert_row]      = gs_pgm_id[gi_open_win_no]
		

return 0
end event

event open;call super::open;String ls_ref_desc

is_status = fs_get_control("B0", "P223", ls_ref_desc)

end event

type dw_cond from w_a_reg_m_m`dw_cond within p1w_reg_hotkey_contractseq_v20
integer x = 59
integer y = 60
integer width = 2267
integer height = 204
string dataobject = "p1dw_reg_cnd_hotkey_contractseq"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name
	Case "customerid"
		
		If data <> "" then 
			SELECT CUSTOMERNM
			  INTO :ls_customernm
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :data ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, title, 'select error')
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, title, 'select not found')
			Else
				This.object.customernm[1] = ls_customernm
			End If
		Else
			This.object.customernm[1] = ""
			
		End If		 
		 
End Choose

Return 0 
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

type p_ok from w_a_reg_m_m`p_ok within p1w_reg_hotkey_contractseq_v20
end type

type p_close from w_a_reg_m_m`p_close within p1w_reg_hotkey_contractseq_v20
end type

type gb_cond from w_a_reg_m_m`gb_cond within p1w_reg_hotkey_contractseq_v20
integer height = 292
end type

type dw_master from w_a_reg_m_m`dw_master within p1w_reg_hotkey_contractseq_v20
string dataobject = "p1dw_reg_master_hotkey_contractseq_1"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_sort = This.Object.customerm_customerid_t

uf_init(ldwo_sort)
end event

event dw_master::clicked;call super::clicked;//IF row >0 Then
//	il_validkeycnt = This.object.priceplanmst_validkeycnt[row]
//End IF
end event

event dw_master::retrieveend;call super::retrieveend;//If rowcount > 0 Then
//	il_validkeycnt = This.object.priceplanmst_validkeycnt[1]
//End IF

Triggerevent("ue_reset")
end event

type dw_detail from w_a_reg_m_m`dw_detail within p1w_reg_hotkey_contractseq_v20
string dataobject = "p1dw_reg_det_hotkey_contractseq"
end type

event dw_detail::ue_retrieve;call super::ue_retrieve;Long ll_rows
String ls_where
String ls_contractseq

//입력 조건 처리 부분

//ls_anino = Trim(dw_master.Object.p_anipin_anino[al_select_row])
ls_contractseq = Trim(String(dw_master.Object.contractmst_contractseq[al_select_row]))

//Error 처리부분
If IsNull(ls_contractseq) Then ls_contractseq = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_contractseq <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += " contractseq = '" + ls_contractseq + "' "
End If

//자료 읽기 및 관련 처리부분
is_where = ls_where
ll_rows = Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)

end event

type p_insert from w_a_reg_m_m`p_insert within p1w_reg_hotkey_contractseq_v20
end type

type p_delete from w_a_reg_m_m`p_delete within p1w_reg_hotkey_contractseq_v20
end type

type p_save from w_a_reg_m_m`p_save within p1w_reg_hotkey_contractseq_v20
end type

type p_reset from w_a_reg_m_m`p_reset within p1w_reg_hotkey_contractseq_v20
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within p1w_reg_hotkey_contractseq_v20
end type

