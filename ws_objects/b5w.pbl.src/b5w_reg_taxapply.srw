$PBExportHeader$b5w_reg_taxapply.srw
$PBExportComments$[chooys-backgu] Tax적용유형관리 Window
forward
global type b5w_reg_taxapply from w_a_reg_m_m
end type
end forward

global type b5w_reg_taxapply from w_a_reg_m_m
integer width = 1966
integer height = 1972
end type
global b5w_reg_taxapply b5w_reg_taxapply

type variables
String is_taxtype = ""
end variables

on b5w_reg_taxapply.create
call super::create
end on

on b5w_reg_taxapply.destroy
call super::destroy
end on

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row] = gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

//PackageCod
dw_detail.Object.taxtype[al_insert_row] = is_taxtype

RETURN 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt, ll_found
String	ls_taxcod, ls_taxseq, ls_sort

//필수항목 Check
ll_rows	= dw_detail.RowCount()
//순위 중복 Check  - DW를 Sort한다.
dw_detail.SetRedraw(False)
ls_sort = "taxseq"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()  

FOR ll_rowcnt=1 TO ll_rows
	ls_taxcod	= Trim(dw_detail.Object.taxcod[ll_rowcnt])
	IF IsNull(ls_taxcod) THEN ls_taxcod = ""
	
	ls_taxseq	= Trim(String(dw_detail.Object.taxseq[ll_rowcnt]))
	IF IsNull(ls_taxseq) THEN ls_taxseq = ""

	//TAX코드 체크
	IF ls_taxcod = "" THEN
		f_msg_usr_err(200, Title, "Tax Code")
		dw_detail.setColumn("taxcod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		dw_detail.SetRedraw(True)		
		RETURN -2
	END IF
	
	//적용순서 체크
	IF ls_taxseq = "" THEN
		f_msg_usr_err(200, Title, "Priority")
		dw_detail.setColumn("taxseq")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		dw_detail.SetRedraw(True)		
		RETURN -2
	END IF
	
	If ll_rowcnt <> ll_rows Then	
		ll_found = dw_detail.Find("taxseq = " + ls_taxseq + "", ll_rowcnt + 1, ll_rows)
	End If
	
	If ll_found > 0 Then
		f_msg_usr_err(9000, Title, "적용순서가 중복되었습니다.")
		dw_detail.setColumn("taxseq")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		dw_detail.SetRedraw(True)		
		RETURN -2
	End If
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
		dw_detail.Object.pgm_id[ll_rowcnt]		= gs_pgm_id[gi_open_win_no]
	END IF
NEXT

dw_detail.SetRedraw(True)
//No Error
RETURN 0
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_typename

//Condition
ls_typename	= Trim(dw_cond.Object.taxtypename[1])

IF IsNull(ls_typename) THEN ls_typename = ""

//Dynamic SQL
ls_where = ""

IF ls_typename <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "codenm LIKE '%" + ls_typename + "%'"
END IF

//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF

end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.taxtypename[1] = ""

RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b5w_reg_taxapply
integer x = 87
integer y = 56
integer width = 1138
integer height = 136
string dataobject = "b5dw_cnd_regtaxapply"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b5w_reg_taxapply
integer x = 1344
integer y = 60
end type

type p_close from w_a_reg_m_m`p_close within b5w_reg_taxapply
integer x = 1637
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b5w_reg_taxapply
integer x = 41
integer y = 8
integer width = 1211
integer height = 236
end type

type dw_master from w_a_reg_m_m`dw_master within b5w_reg_taxapply
integer x = 41
integer y = 288
integer width = 1851
integer height = 784
string dataobject = "b5dw_inq_taxapply"
end type

event dw_master::clicked;call super::clicked;String ls_type

ls_type = dwo.Type

Choose Case UPPER(ls_type)
	Case "COLUMN"
		   return 1
	Case "ROW"
			return 1		
End Choose

end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.code_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b5w_reg_taxapply
integer x = 41
integer y = 1108
integer width = 1847
integer height = 556
string dataobject = "b5dw_reg_taxapply"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows

//Set PackageCod
is_taxtype = Trim(dw_master.Object.code[al_select_row])

//Retrieve
If al_select_row > 0 Then
	ls_where = "taxtype = '" + is_taxtype + "' "
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

type p_insert from w_a_reg_m_m`p_insert within b5w_reg_taxapply
integer x = 46
integer y = 1716
end type

type p_delete from w_a_reg_m_m`p_delete within b5w_reg_taxapply
integer x = 347
integer y = 1716
end type

type p_save from w_a_reg_m_m`p_save within b5w_reg_taxapply
integer x = 649
integer y = 1716
end type

type p_reset from w_a_reg_m_m`p_reset within b5w_reg_taxapply
integer x = 1294
integer y = 1716
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b5w_reg_taxapply
integer x = 46
integer y = 1072
end type

