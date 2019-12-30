$PBExportHeader$b5w_reg_taxtr.srw
$PBExportComments$[kwon-backgu] TAX대상거래유형
forward
global type b5w_reg_taxtr from w_a_reg_m_m
end type
end forward

global type b5w_reg_taxtr from w_a_reg_m_m
integer width = 2021
integer height = 1940
end type
global b5w_reg_taxtr b5w_reg_taxtr

type variables
String is_taxcod = ""
end variables

on b5w_reg_taxtr.create
call super::create
end on

on b5w_reg_taxtr.destroy
call super::destroy
end on

event type integer ue_extra_insert(long al_insert_row);//Log 정보
dw_detail.Object.taxtr_crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.taxtr_crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.taxtr_updt_user[al_insert_row] = gs_user_id
dw_detail.Object.taxtr_updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.taxtr_pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

//PackageCod
dw_detail.Object.taxtr_taxcod[al_insert_row] = is_taxcod

RETURN 0
end event

event type integer ue_extra_save();Long		ll_rows, ll_rowcnt
String	ls_taxcod, ls_taxcodnm

//필수항목 Check
dw_detail.acceptText()
ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	ls_taxcod	= Trim(dw_detail.Object.taxtr_trcod[ll_rowcnt])
	ls_taxcodnm = Trim(dw_detail.object.trcode_trcodnm[ll_rowcnt])
	
	IF IsNull(ls_taxcod) THEN ls_taxcod = ""
	
	//ls_taxseq	= Trim(String(dw_detail.Object.taxseq[ll_rowcnt]))
	//IF IsNull(ls_taxcod) THEN ls_taxseq = ""

	//TAX코드 체크
	IF ls_taxcod = "" THEN
		f_msg_usr_err(200, Title, "Tax Code")
		dw_detail.setRow(ll_rowcnt)		
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setColumn("taxtr_trcod")
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//거래유형 체크
	IF ls_taxcodnm = "" THEN
		f_msg_usr_err(200, Title, "Transaction")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setColumn("trcode_trcodnm")
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.taxtr_updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.taxtr_updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	END IF
NEXT

//No Error
RETURN 0
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_taxcod

//Condition
ls_taxcod	= Trim(dw_cond.Object.taxcod[1])

IF IsNull(ls_taxcod) THEN ls_taxcod = ""

//Dynamic SQL
ls_where = ""

IF ls_taxcod <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "taxmst.taxname LIKE '%" + ls_taxcod + "%'"
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

event ue_reset;call super::ue_reset;dw_cond.Object.taxcod[1] = ""

RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b5w_reg_taxtr
integer x = 46
integer y = 52
integer width = 1074
integer height = 140
string dataobject = "b5dw_cnd_taxtr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b5w_reg_taxtr
integer x = 1317
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b5w_reg_taxtr
integer x = 1614
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b5w_reg_taxtr
integer width = 1179
integer height = 232
end type

type dw_master from w_a_reg_m_m`dw_master within b5w_reg_taxtr
integer x = 27
integer y = 260
integer width = 1920
integer height = 768
string dataobject = "b5dw_inq_taxtr"
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
ldwo_sort = Object.taxcod_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b5w_reg_taxtr
integer y = 1084
integer width = 1911
integer height = 580
string dataobject = "b5dw_reg_taxtr"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::ue_retrieve;String	ls_where
Long		ll_rows
//Set PackageCod
is_taxcod = Trim(dw_master.Object.taxcod[al_select_row])

//Retrieve
If al_select_row > 0 Then
	ls_where = "taxcod = '" + is_taxcod + "' "
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

event dw_detail::itemchanged;call super::itemchanged;//Item Change Event
String ls_trcod
Choose Case dwo.name
	Case "taxtr_itemcod" // 2019.04.09 품목코드 선택시 품목명, 거래코드, 거래유형 자동 Setting Modified by Han
		This.Object.itemmst_itemnm[row] = data

		SELECT NVL(trcod,' ')
		  INTO :ls_trcod
		  FROM ITEMMST
		 WHERE itemcod = :data;
		 
		This.Object.taxtr_trcod[row]    = ls_trcod
		This.Object.trcode_trcodnm[row] = ls_trcod
	Case "taxtr_trcod"
		 This.Object.trcode_trcodnm[row] = data
	 
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_m`p_insert within b5w_reg_taxtr
integer x = 41
integer y = 1696
end type

type p_delete from w_a_reg_m_m`p_delete within b5w_reg_taxtr
integer x = 352
integer y = 1696
end type

type p_save from w_a_reg_m_m`p_save within b5w_reg_taxtr
integer x = 663
integer y = 1696
end type

type p_reset from w_a_reg_m_m`p_reset within b5w_reg_taxtr
integer x = 1207
integer y = 1696
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b5w_reg_taxtr
integer y = 1036
integer height = 40
end type

