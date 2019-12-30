$PBExportHeader$b0w_reg_callingnum_blacklist_v20.srw
$PBExportComments$[ssong] 발신제한 v20
forward
global type b0w_reg_callingnum_blacklist_v20 from w_a_reg_m
end type
end forward

global type b0w_reg_callingnum_blacklist_v20 from w_a_reg_m
integer width = 3328
integer height = 1836
event ue_fileread ( )
event ue_saveas ( )
end type
global b0w_reg_callingnum_blacklist_v20 b0w_reg_callingnum_blacklist_v20

type variables
String is_priceplan		//Item에 해당하는 Price plan
String is_svccod_control
DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wfl_get_arezoncod (string as_priceplan, string as_zoncod, ref string as_arezoncod[])
end prototypes

public function integer wfl_get_arezoncod (string as_priceplan, string as_zoncod, ref string as_arezoncod[]);Long ll_rows
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

on b0w_reg_callingnum_blacklist_v20.create
call super::create
end on

on b0w_reg_callingnum_blacklist_v20.destroy
call super::destroy
end on

event open;call super::open;/*--------------------------------------------------------------------------
	Name	:	b0w_reg_callingnum_blacklist_v20
	Desc.	:	발신제한 번호 등록
	Ver.	: 	1.0
	Date	: 	2005.07.15
	Programer: Song Eun mi
----------------------------------------------------------------------------*/

dw_cond.Object.parttype[1] = "S"



end event

event ue_extra_insert;String ls_parttype

ls_parttype = Trim(dw_cond.object.parttype[1])


If ls_parttype = 'S' Then
	//Insert 시 해당 row 첫번째 컬럼에 포커스
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("callingnum")
	
	//Setting
	dw_detail.object.svccod[al_insert_row] = Trim(dw_cond.object.svccod[1])
	dw_detail.object.priceplan[al_insert_row] = 'ALL'
	dw_detail.object.fromdt[al_insert_row] = fdt_get_dbserver_now()
	

	
Else
	//select svccod
	//into  :ls_svccod
	//from  priceplanmst
	//where priceplan =: l
	
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("callingnum")
	
	dw_detail.object.svccod[al_insert_row] = Trim(dw_cond.object.svccod[1])
	dw_detail.object.priceplan[al_insert_row] = Trim(dw_cond.object.priceplan[1])
	dw_detail.object.fromdt[al_insert_row] = fdt_get_dbserver_now()

End If
//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row]   = fdt_get_dbserver_now()

Return 0
end event

event ue_ok;//조회
String ls_parttype, ls_priceplan, ls_zoncod, ls_where, ls_svccod
Long ll_row

ls_parttype = fs_snvl(dw_cond.object.parttype[1], '')
ls_zoncod   = fs_snvl(dw_cond.object.zoncod[1]  , '')
ls_where    = ""

//필수 항목 Check
If ls_parttype = "" Then
	f_msg_info(200, Title,"작업선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("parttype")
   Return
End If

If ls_parttype = "S" Then
	ls_priceplan = "ALL"
	ls_svccod    = fs_snvl(dw_cond.object.svccod[1], '')
	
	If ls_svccod = "" Then
		f_msg_info(200, Title,"서비스")
		dw_cond.SetFocus()
		dw_cond.SetColumn("svccod")
	   Return
	End If	
	
	dw_cond.object.priceplan[1]    = ls_priceplan	
Else
	ls_priceplan = Trim(dw_cond.object.priceplan[1])
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	 
	If ls_priceplan = "" Then
		f_msg_info(200, Title,"가격정책")
		dw_cond.SetFocus()
		dw_cond.SetColumn("priceplan")
	   Return
	End If
	
	SELECT SVCCOD
	  INTO :ls_svccod
	  FROM PRICEPLANMST
	 WHERE PRICEPLAN = :ls_priceplan;

	dw_cond.object.svccod[1]    = ls_svccod
	 
End If

//retrieve
If ls_where <> "" Then ls_where += " And "
ls_where += " svccod = '" + ls_svccod + "' "

If ls_where <> "" Then ls_where += " And "
ls_where += " priceplan = '" + ls_priceplan + "' "



dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_extra_save;//Save Check
String ls_parttype, ls_svccod, ls_priceplan, ls_callingnum, ls_fromdt, ls_todt
String ls_svccod1, ls_priceplan1, ls_callingnum1, ls_fromdt1, ls_todt1
String ls_svccod2, ls_priceplan2, ls_callingnum2, ls_fromdt2, ls_todt2
Long i, ll_row, ll_rows, ll_rows1

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0

ls_parttype = Trim(dw_cond.object.parttype[1])

If  ls_parttype = 'S'  Then
	For i = 1 To ll_row
		ls_callingnum = Trim(dw_detail.object.callingnum[i])
		If IsNull(ls_callingnum) Then ls_callingnum = ""
		If ls_callingnum = "" Then
			f_msg_usr_err(200, Title, "발신제한번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("callingnum")
			Return -1
		End If
	
		ls_fromdt = String(dw_detail.object.fromdt[i], 'YYYYMMDD')
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If ls_fromdt = "" Then
			f_msg_usr_err(200, Title, "적용개시일")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("fromdt")
			Return -1
		End If
		
		
	
		//Update Log
		If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i]   = fdt_get_dbserver_now()
	   End If
	Next

ElseIf ls_parttype = 'R' Then
	For i = 1 To ll_row
		ls_callingnum = Trim(dw_detail.object.callingnum[i])
		If IsNull(ls_callingnum) Then ls_callingnum = ""
		If ls_callingnum = "" Then
			f_msg_usr_err(200, Title, "발신제한번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("callingnum")
			Return -1
		End If
	
		ls_fromdt = String(dw_detail.object.fromdt[i], 'YYYYMMDD')
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If ls_fromdt = "" Then
			f_msg_usr_err(200, Title, "적용개시일")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("fromdt")
			Return -1
		End If
		
		
	
		//Update Log
		If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i]   = fdt_get_dbserver_now()
	   End If
	Next
End If

//적용종료일 체크
For i = 1 To ll_row
	ls_fromdt = Trim(String(dw_detail.object.fromdt[i], 'yyyymmdd'))
	ls_todt  = Trim(String(dw_detail.object.todt[i], 'yyyymmdd'))
	
	If IsNull(ls_todt) Or ls_todt = "" Then ls_todt = "99991231"
	
	If ls_fromdt > ls_todt Then
		f_msg_usr_err(9000, Title, "적용종료일은 적용개시일보다 크거나 같아야 합니다.")
		dw_detail.setColumn("todt")
		dw_detail.setRow(i)
		dw_detail.scrollToRow(i)
		dw_detail.setFocus()
		Return -2
	End If
Next

//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows = 1 To dw_detail.RowCount()
	ls_svccod1     = Trim(dw_detail.object.svccod[ll_rows])
	ls_priceplan1  = Trim(dw_detail.object.priceplan[ll_rows])
	ls_callingnum1 = Trim(dw_detail.object.callingnum[ll_rows])
	ls_fromdt1     = String(dw_detail.object.fromdt[ll_rows], 'yyyymmdd')
	ls_todt1       = String(dw_detail.object.todt[ll_rows], 'yyyymmdd')
	
	If IsNull(ls_todt1) Or ls_todt1 = "" Then ls_todt1 = '99991231'
	
	For ll_rows1 = dw_detail.RowCount() To ll_rows - 1 Step -1
		If ll_rows = ll_rows1 Then
			Exit
		End If
		ls_svccod2     = Trim(dw_detail.object.svccod[ll_rows1])
		ls_priceplan2  = Trim(dw_detail.object.priceplan[ll_rows1])
		ls_callingnum2 = Trim(dw_detail.object.callingnum[ll_rows1])
		ls_fromdt2     = String(dw_detail.object.fromdt[ll_rows1], 'yyyymmdd')
		ls_todt2       = String(dw_detail.object.todt[ll_rows1], 'yyyymmdd')
		
		If IsNull(ls_todt2) Or ls_todt2 = "" Then ls_todt2 = '99991231'
		
		If (ls_svccod1 = ls_svccod2) And (ls_priceplan1 = ls_priceplan2) And (ls_callingnum1 = ls_callingnum2) Then
			If ls_todt1 >= ls_todt2 Then
				f_msg_info(9000, Title, "같은 서비스[ " + ls_svccod1 + " ], 같은 가격정책[ " + ls_priceplan1 + " ]에 같은 발신제한번호[ " + ls_callingnum1 + " ]로 적용개시일이 중복됩니다.")
				Return -1
			End If
		End If
		
	Next
	
Next

Return 0
	
	
end event

event ue_save;String ls_priceplan
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

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
End If

//cb_load.Enabled = False
Return 0
end event

event ue_reset;call super::ue_reset;String ls_tmp, ls_desc

//cb_load.Enabled = False
dw_cond.Object.parttype[1] = 'S'

dw_cond.Object.priceplan.Visible = 0
dw_cond.Object.priceplan_t.Visible = 0

dw_cond.Object.svccod.Visible = 1
dw_cond.Object.svccod_t.Visible = 1



Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_callingnum_blacklist_v20
integer x = 41
integer y = 40
integer width = 2464
integer height = 244
string dataobject = "b0dw_reg_cnd_callingnum_blacklist_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Long ll_row
String ls_filter, ls_itemcod
DataWindowChild ldc


If dwo.name = "parttype" Then
	
	If data = "S" Then
		This.Object.priceplan.Visible = 0
		This.Object.priceplan_t.Visible = 0
		This.Object.svccod.Visible = 1
		This.Object.svccod_t.Visible = 1		
	
	Else
		This.Object.priceplan.Visible = 1
		This.Object.priceplan_t.Visible = 1
		This.Object.svccod.Visible = 0
		This.Object.svccod_t.Visible = 0	
   End If
End If
end event

type p_ok from w_a_reg_m`p_ok within b0w_reg_callingnum_blacklist_v20
integer x = 2670
integer y = 128
end type

type p_close from w_a_reg_m`p_close within b0w_reg_callingnum_blacklist_v20
integer x = 2967
integer y = 128
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_callingnum_blacklist_v20
integer x = 23
integer width = 2491
integer height = 304
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_callingnum_blacklist_v20
integer y = 1600
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_callingnum_blacklist_v20
integer y = 1600
end type

type p_save from w_a_reg_m`p_save within b0w_reg_callingnum_blacklist_v20
integer y = 1600
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_callingnum_blacklist_v20
integer x = 27
integer y = 312
integer width = 3237
integer height = 1248
string dataobject = "b0dw_reg_det_callingnum_blacklist_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;String ls_parttype

If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If



	
Return 0

end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_callingnum_blacklist_v20
integer x = 1097
integer y = 1600
end type

