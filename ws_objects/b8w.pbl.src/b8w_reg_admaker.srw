$PBExportHeader$b8w_reg_admaker.srw
$PBExportComments$[chooys] 제조사 등록 Window
forward
global type b8w_reg_admaker from w_a_reg_m_m
end type
end forward

global type b8w_reg_admaker from w_a_reg_m_m
integer width = 2587
event ue_modeinsert ( )
event ue_modemodify ( )
end type
global b8w_reg_admaker b8w_reg_admaker

type variables
//신규등록여
Boolean	ib_new
end variables

event ue_modeinsert();p_delete.TriggerEvent("ue_diable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

p_insert.TriggerEvent("ue_enable")
end event

event ue_modemodify();//p_insert.TriggerEvent("ue_disable")

p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")


end event

on b8w_reg_admaker.create
call super::create
end on

on b8w_reg_admaker.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_item, ls_value

//Condition
ls_item	= Trim(dw_cond.Object.item[1])
ls_value	= Trim(dw_cond.Object.value[1])

IF IsNull(ls_item) THEN ls_item = ""
IF IsNull(ls_value) THEN ls_value = ""


//Dynamic SQL
ls_where = ""

IF ls_item = "makercd" AND ls_value <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "makercd = '" + ls_value + "'"
END IF

IF ls_item = "makernm" AND ls_value <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "makernm LIKE '%" + ls_value + "%'"
END IF

//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
END IF

end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_makercd, ls_makernm

//필수항목 Check
ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	ls_makercd	= Trim(dw_detail.Object.makercd[ll_rowcnt])
	IF IsNull(ls_makercd) THEN ls_makercd = ""
	
	ls_makernm	= Trim(String(dw_detail.Object.makernm[ll_rowcnt]))
	IF IsNull(ls_makernm) THEN ls_makernm = ""

	//제조사번호 체크
	IF ls_makercd = "" THEN
		f_msg_usr_err(200, Title, "제조사번호")
		dw_detail.setColumn("makercd")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//제조사번호 중복 체크 -Seq No. 이므로 체크 불필요
	/*
	Int li_cnt
	
	SELECT count(*)
	INTO :li_cnt
	FROM admaker
	WHERE makercd = :ls_makercd;
	
	IF li_cnt > 0 THEN
		f_msg_usr_err(200, Title, "제조사번호 중복")
		dw_detail.setColumn("makercd")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	*/
	
	//제조사명 체크
	IF ls_makernm = "" THEN
		f_msg_usr_err(200, Title, "제조사명")
		dw_detail.setColumn("makernm")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	END IF
NEXT

//No Error
RETURN 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.item[1] = ""
dw_cond.Object.value[1] = ""

TriggerEvent("ue_modeinsert")

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;TriggerEvent("ue_reset")
dw_detail.insertRow(0)
dw_detail.setColumn("makernm")
dw_detail.setRow(1)
dw_detail.scrollToRow(1)
dw_detail.setFocus()



//제조사코드
String	ls_makercd

SELECT to_char(seq_makercd.nextval)
INTO :ls_makercd
FROM dual;

dw_detail.Object.makercd[1] = ls_makercd

//Log 정보
dw_detail.Object.crt_user[1] 	= gs_user_id
dw_detail.Object.crtdt[1] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[1] = gs_user_id
dw_detail.Object.updtdt[1]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[1]		= gs_pgm_id[gi_open_win_no]

TriggerEvent("ue_modemodify")

RETURN 0

end event

event type integer ue_delete();//삭제할 제조사로 등록되어 있는 모델이 있을 경우 삭제 불가
String 	ls_makercd
Int		li_cnt

ls_makercd = Trim(dw_detail.Object.makercd[1])

IF(ls_makercd = "") THEN
	f_msg_info(3010,This.title,"Delete")
	RETURN -2
END IF

SELECT count(*)
INTO :li_cnt
FROM admodel
WHERE makercd = :ls_makercd;

IF li_cnt > 0 THEN
	MessageBox("삭제불가","모델이 등록되어 있는 제조사이므로 삭제불가")
	f_msg_info(3010,This.title,"Delete")
	RETURN -2
END IF


DELETE admaker
WHERE makercd = :ls_makercd;


IF SQLCA.SqlCode < 0 THEN
	f_msg_info(3010,This.title,"Delete")
	RollBack;
ELSE
	f_msg_info(3000,This.title,"Delete")
	Commit;
	
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
	TriggerEvent("ue_ok")
END IF

return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
	
	TriggerEvent("ue_ok")
	
End if

//ii_error_chk = 0
RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b8w_reg_admaker
integer x = 55
integer y = 40
integer width = 1833
integer height = 116
string dataobject = "b8dw_cnd_regadmaker"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b8w_reg_admaker
integer x = 1943
end type

type p_close from w_a_reg_m_m`p_close within b8w_reg_admaker
integer x = 2245
end type

type gb_cond from w_a_reg_m_m`gb_cond within b8w_reg_admaker
integer width = 1874
integer height = 204
end type

type dw_master from w_a_reg_m_m`dw_master within b8w_reg_admaker
integer y = 232
integer width = 2432
integer height = 684
string dataobject = "b8dw_inq_regadmaker"
end type

event dw_master::clicked;call super::clicked;Parent.TriggerEvent("ue_modemodify")

String ls_type

ls_type = dwo.Type

Choose Case UPPER(ls_type)
	Case "COLUMN"
		   return 1
	Case "ROW"
			return 1		
End Choose

end event

event dw_master::retrieveend;call super::retrieveend;Parent.TriggerEvent("ue_modemodify")
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.makernm_t
uf_init( ldwo_sort )

end event

type dw_detail from w_a_reg_m_m`dw_detail within b8w_reg_admaker
integer x = 37
integer y = 956
integer width = 2432
integer height = 668
string dataobject = "b8dw_reg_regadmaker_sams"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_taxtype


//Set PackageCod
ls_taxtype = Trim(dw_master.Object.makercd[al_select_row])

//Retrieve
If al_select_row > 0 Then
	ls_where = "makercd = '" + ls_taxtype + "' "
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b8w_reg_admaker
integer x = 37
end type

type p_delete from w_a_reg_m_m`p_delete within b8w_reg_admaker
integer x = 329
integer y = 1656
end type

type p_save from w_a_reg_m_m`p_save within b8w_reg_admaker
integer x = 626
integer y = 1656
end type

type p_reset from w_a_reg_m_m`p_reset within b8w_reg_admaker
integer x = 1353
integer y = 1656
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b8w_reg_admaker
integer x = 0
integer y = 924
end type

