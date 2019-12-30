$PBExportHeader$p1w_reg_ani_insert.srw
$PBExportComments$[jykim] Ani 번호 등록
forward
global type p1w_reg_ani_insert from w_a_reg_m_m
end type
end forward

global type p1w_reg_ani_insert from w_a_reg_m_m
end type
global p1w_reg_ani_insert p1w_reg_ani_insert

type variables
String is_status
Long il_validkeycnt

end variables

on p1w_reg_ani_insert.create
call super::create
end on

on p1w_reg_ani_insert.destroy
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

event type integer ue_extra_save();Long		ll_row, ll_rows, ll_cntani, ll_cnt
String	ls_anino, ls_pid , ls_fromdt, ls_langtype
String ls_temp, ls_ref_desc, ls_svctype

ls_ref_desc = ""
ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)

//필수항목 Check
ll_rows = dw_detail.RowCount()
For ll_row = 1 To ll_rows

	//Ⅰ. Current Row의 조건 확인
	ls_anino = Trim(dw_detail.Object.validkey[ll_row])
	ls_pid = Trim(dw_detail.Object.pid[ll_row])
	ls_fromdt = String(dw_detail.Object.fromdt[ll_row],'yyyymmdd')
	ls_langtype = String (dw_detail.Object.langtype[ll_row])
	ls_fromdt = Trim(ls_fromdt)
	
	If IsNull(ls_anino) Then ls_anino = ""
	If IsNull(ls_pid) Then ls_pid = ""
	If IsNull(ls_langtype) Then ls_langtype = ""	
	
	If ls_anino = "" Then
		f_msg_usr_err(200, Title, "ANI #")
		dw_detail.SetColumn("validkey")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetFocus()
		Return -2
	End If
	
	If ls_pid = "" Then
		f_msg_usr_err(200, Title, "PIN #")
		dw_detail.SetColumn("pid")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetFocus()
		Return -2
	End If
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용 시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetFocus()
		Return -2
	End If
	
	If ls_langtype = "" Then
		f_msg_usr_err(200, Title, "멘트언어")
		dw_detail.SetColumn("langtype")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetFocus()
		Return -2
	End If
	
	// pin번호 중복 체크
	SELECT count(*) 
	INTO :ll_cnt
	FROM validinfo
	WHERE pid = :ls_pid and validkey = :ls_anino;

//	// ANI # 중복 체크
	If ll_cnt <> 1 Then
		SELECT count(*) 
		INTO :ll_cntani
		FROM validinfo
		WHERE validkey = :ls_anino
		AND svctype = :ls_svctype;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title,  "Database Error(p_anino)" )
			return -2
		End If
		
		If ll_cntani > 0 Then
			f_msg_usr_err(9000, Title, ls_anino + "는 등록된 ANI# 입니다.")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetFocus()
			dw_detail.SetColumn("validkey")
			return -2	
		End If
	End If
	
	//SQL Update
	
   If dw_detail.GetItemStatus(ll_row, 0, Primary!) = DataModified! THEN	
		dw_detail.object.updt_user[ll_row] = gs_user_id
		dw_detail.object.updtdt[ll_row] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_row] = gs_pgm_id[gi_open_win_no]
	End If
Next


Return 0

end event

event type integer ue_insert();
// override : vgene
Constant Int LI_ERROR = -1
Long ll_row, ll_cnt, ll_master
String ls_pid, ls_priceplan
DateTime ld_enddt
String ls_svccod, ls_customerid, ls_svctype, ls_status, ls_contractseq, ls_langtype
String ls_tmp, ls_ref_desc, ls_result[]
Integer li_return

ll_cnt = dw_detail.RowCount()
If ll_cnt >= il_validkeycnt Then
	f_msg_usr_err(9000,title,"해당가격정책에 ANI# 등록은 ~r~n~r~n" +string(il_validkeycnt)+ "개까지 등록 가능합니다.")
	Return LI_ERROR
End If

ll_master = dw_master.GetselectedRow(0)

ls_pid = dw_master.Object.p_cardmst_pid[ll_master]
If IsNull(ls_pid) Then ls_pid =""

ls_priceplan = dw_master.Object.p_cardmst_priceplan[ll_master]
If IsNull(ls_priceplan) Then ls_priceplan =""

//ld_enddt = dw_master.Object.p_cardmst_enddt[ll_master]
//If IsNull(ld_enddt) Then setNull(ld_enddt)

ls_langtype = dw_master.object.wkflag2[ll_master]
If IsNull(ls_langtype) Then ls_langtype = ""

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.Object.pid[ll_row] = ls_pid
dw_detail.Object.fromdt[ll_row] = Date(fdt_get_dbserver_now())
//dw_detail.Object.todt[ll_row] = ld_enddt
dw_detail.Object.langtype[ll_row] = ls_langtype

ls_tmp = fs_get_control('P0', 'P000', ls_ref_desc)
If ls_tmp = "" Then Return -1
		
li_return = fi_cut_string(ls_tmp, ";", ls_result[])
If li_return <= 0 Then Return -1
ls_status 		= ls_result[1]			//개통상태
ls_customerid 	= ls_result[2]			//고객번호
ls_svccod 		= ls_result[3]			//서비스 코드
ls_svctype 		= ls_result[4]			//서비스 타입
ls_contractseq = ls_result[5]			//계약Seq

dw_detail.object.contractseq[ll_row] = Long(ls_contractseq)
dw_detail.object.customerid[ll_row] = ls_customerid
dw_detail.object.priceplan[ll_row] = ls_priceplan
dw_detail.object.svccod[ll_row] = ls_svccod
dw_detail.object.svctype[ll_row] = ls_svctype
dw_detail.object.status[ll_row] = ls_status
dw_detail.object.use_yn[ll_row] = 'Y'

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0




end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_anino, ls_pid, ls_contno_fr, ls_contno_to, ls_svctype, ls_ref_desc

//입력 조건 처리 부분
ls_anino = Trim(dw_cond.Object.anino[1])
ls_pid = Trim(dw_cond.Object.pid[1])
ls_contno_fr = Trim(dw_cond.Object.contno_fr[1])
ls_contno_to = Trim(dw_cond.Object.contno_to[1])

//Error 처리부분
If IsNull(ls_anino) Then ls_anino = ""
If IsNull(ls_pid) Then ls_pid = ""
If IsNull(ls_contno_fr) Then ls_contno_fr = ""
If IsNull(ls_contno_to) Then ls_contno_to = ""

ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)	// 선불카드 서비스 타입

If ls_pid = "" and ls_anino = "" and ls_contno_fr = "" and ls_contno_to = "" Then
	f_msg_usr_err(200, Title, "PIN# or ANI# or 관리번호를 입력하세요")
	dw_cond.SetColumn("pid")
	dw_cond.SetFocus()
	Return
End If

//Dynamic SQL 처리부분
//If ls_pid <> "" or ls_contno_fr <> "" or ls_contno_to <> "" Then
//	ls_where = "validinfo.pid  (+)= p_cardmst.pid "
//Else
//	ls_where = "validinfo.pid  = p_cardmst.pid "
//End If
//
If ls_anino <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.pid in (SELECT pid FROM validinfo WHERE validkey = '" +ls_anino +"' AND	svctype = '"+ls_svctype+"') "
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.pid = '" + ls_pid + "' "
End If

If ls_contno_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.contno >= '" + ls_contno_fr + "' "
End If

If ls_contno_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.contno <= '" + ls_contno_to + "' "
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

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//dw_detail.object.fromdt[al_insert_row] = dw_master.Object.p_cardmst_pid[ll_master]

return 0
end event

event open;call super::open;String ls_ref_desc

is_status = fs_get_control("B0", "P223", ls_ref_desc)

end event

type dw_cond from w_a_reg_m_m`dw_cond within p1w_reg_ani_insert
integer x = 59
integer y = 52
integer width = 2267
integer height = 204
string dataobject = "p1dw_cnd_reg_aninum"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within p1w_reg_ani_insert
end type

type p_close from w_a_reg_m_m`p_close within p1w_reg_ani_insert
end type

type gb_cond from w_a_reg_m_m`gb_cond within p1w_reg_ani_insert
integer height = 268
end type

type dw_master from w_a_reg_m_m`dw_master within p1w_reg_ani_insert
string dataobject = "p1dw_reg_aninum_master"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = This.Object.p_cardmst_pid_t

uf_init(ldwo_sort)
end event

event dw_master::clicked;call super::clicked;IF row >0 Then
	il_validkeycnt = This.object.priceplanmst_validkeycnt[row]
End IF
end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	il_validkeycnt = This.object.priceplanmst_validkeycnt[1]
End IF
end event

type dw_detail from w_a_reg_m_m`dw_detail within p1w_reg_ani_insert
string dataobject = "p1dw_reg_aninum_detail"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;Long ll_rows
String ls_where
String ls_pid

//입력 조건 처리 부분

//ls_anino = Trim(dw_master.Object.p_anipin_anino[al_select_row])
ls_pid = Trim(dw_master.Object.p_cardmst_pid[al_select_row])

//Error 처리부분
If IsNull(ls_pid) Then ls_pid = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += " pid = '" + ls_pid + "' "
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

type p_insert from w_a_reg_m_m`p_insert within p1w_reg_ani_insert
end type

type p_delete from w_a_reg_m_m`p_delete within p1w_reg_ani_insert
end type

type p_save from w_a_reg_m_m`p_save within p1w_reg_ani_insert
end type

type p_reset from w_a_reg_m_m`p_reset within p1w_reg_ani_insert
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within p1w_reg_ani_insert
end type

