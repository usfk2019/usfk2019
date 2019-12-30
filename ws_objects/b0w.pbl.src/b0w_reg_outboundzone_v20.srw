$PBExportHeader$b0w_reg_outboundzone_v20.srw
$PBExportComments$[kem] 상품별 OutBound 정의 v20
forward
global type b0w_reg_outboundzone_v20 from w_a_reg_m
end type
type p_saveas from u_p_saveas within b0w_reg_outboundzone_v20
end type
type p_fileread from u_p_fileread within b0w_reg_outboundzone_v20
end type
end forward

global type b0w_reg_outboundzone_v20 from w_a_reg_m
integer width = 3328
integer height = 1776
event ue_fileread ( )
event ue_saveas ( )
p_saveas p_saveas
p_fileread p_fileread
end type
global b0w_reg_outboundzone_v20 b0w_reg_outboundzone_v20

type variables
String is_priceplan		//Item에 해당하는 Price plan
DataWindowChild idc_priceplan
end variables

forward prototypes
public function integer wfl_get_arezoncod (string as_priceplan, string as_zoncod, ref string as_arezoncod[])
end prototypes

event ue_fileread();//승인 요청 된 파일 불러옴
Constant Integer li_MAX_DIR = 255
String ls_filename, ls_pathname, ls_curdir
Int li_rc
Long ll_row
Boolean	lb_return

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

//파일 선택
li_rc = GetFileOpenName("Select File" , ls_pathname, ls_filename, '', &
						'Text Files(*.TXT), *.TXT')
						
If li_rc <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_info(1001, Title, ls_filename)
	Return
End If

dw_detail.Reset()
ll_row= dw_detail.RowCount()
dw_detail.importfile(ls_pathname)

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api
ls_pathname = ""

Return 
end event

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel! , True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

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

on b0w_reg_outboundzone_v20.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
this.p_fileread=create p_fileread
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
this.Control[iCurrent+2]=this.p_fileread
end on

on b0w_reg_outboundzone_v20.destroy
call super::destroy
destroy(this.p_saveas)
destroy(this.p_fileread)
end on

event open;call super::open;/*--------------------------------------------------------------------------
	Name	:	b0w_reg_zoncst_ref_v20
	Desc.	:  비교요율 대역별요율 등록
	Ver.	: 	1.0
	Date	: 	2005.04.18
	Programer: oh hye jin
----------------------------------------------------------------------------*/
String ls_tmp, ls_desc






end event

event type integer ue_extra_insert(long al_insert_row);String ls_filter, ls_priceplan, ls_itemcod, ls_svccod
Long ll_row

dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)

dw_detail.SetReDraw(False)

//Setting
ls_svccod    = fs_snvl(dw_cond.object.svccod[1], '')
dw_detail.object.svccod[al_insert_row]    = ls_svccod
dw_detail.object.fromdt[al_insert_row]    = Date(fdt_get_dbserver_now())

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
//dw_detail.object.updt_user[al_insert_row] = gs_user_id
//dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

dw_detail.SetReDraw(True)
dw_detail.SetColumn("priceplan")

Return 0

end event

event ue_ok();//조회
String ls_parttype, ls_priceplan, ls_zoncod, ls_where, ls_svccod
Long ll_row

ls_svccod    = fs_snvl(dw_cond.object.svccod[1], '')
ls_priceplan = fs_snvl(dw_cond.Object.priceplan[1], '')
ls_zoncod    = fs_snvl(dw_cond.object.zoncod[1], '')
ls_where     = ""

If ls_svccod = "" Then
	f_msg_info(200, Title,"서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If	
	
//retrieve
If ls_where <> "" Then ls_where += " And "
ls_where += " svccod = '" + ls_svccod + "'"

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " priceplan = '" + ls_priceplan + "' "
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " zoncod = '" + ls_zoncod + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event type integer ue_extra_save();//Save
String ls_priceplan, ls_zoncod, ls_fromdt, ls_todt, ls_out_priceplan
String ls_priceplan1, ls_zoncod1, ls_fromdt1, ls_todt1
String ls_priceplan2, ls_zoncod2, ls_fromdt2, ls_todt2, ls_sort
Long   ll_row, ll_rows, ll_rows1, ll_rows2

If dw_detail.RowCount()  = 0 Then Return 0


ll_rows = dw_detail.RowCount()
If ll_rows < 1 Then Return 0


For ll_row = 1 To ll_rows
	ls_priceplan     = Trim(dw_detail.Object.priceplan[ll_row])
	ls_zoncod        = Trim(dw_detail.Object.zoncod_cost[ll_row])
	ls_fromdt        = String(dw_detail.object.fromdt[ll_row],'yyyymmdd')
	ls_todt          = String(dw_detail.object.todt[ll_row], 'yyyymmdd')
	ls_out_priceplan = Trim(dw_detail.Object.out_priceplan[ll_row])
	
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	If IsNull(ls_zoncod) Then ls_zoncod = ""
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	If IsNull(ls_todt) Then ls_todt = ""
	If IsNull(ls_out_priceplan) Then ls_out_priceplan = ""
	
   //필수 항목 check
	If ls_priceplan = "" Then
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.SetColumn("priceplan")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2	
	End If
	
	If ls_zoncod = "" Then
		f_msg_usr_err(200, Title, "대역")
		dw_detail.SetColumn("zoncod_cost")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2	
	End If
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2
	End If
	
	//적용종료일 체크
	If ls_todt <> "" Then
		If ls_fromdt > ls_todt Then
			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
			dw_detail.setColumn("todt")
			dw_detail.setRow(ll_row)
			dw_detail.scrollToRow(ll_row)
			Return -2
		End If
	End If
	
Next

ls_sort = "svccod, priceplan, zoncod_cost, to_char(fromdt,'yyyymmdd')"
dw_detail.SetRedraw(False)
dw_detail.SetSort(ls_sort)
dw_detail.Sort()


//적용종료일과 적용개시일의 중복check
For ll_rows1 = 1 To dw_detail.RowCount()
	ls_priceplan1 = Trim(dw_detail.object.priceplan[ll_rows1])
	ls_zoncod1    = Trim(dw_detail.object.zoncod_cost[ll_rows1])
	ls_fromdt1    = String(dw_detail.object.fromdt[ll_rows1], 'yyyymmdd')
	ls_todt1      = String(dw_detail.object.todt[ll_rows1], 'yyyymmdd')
	
	If IsNull(ls_todt1) Or ls_todt1 = "" Then ls_todt1 = '99991231'
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		
		ls_priceplan2 = Trim(dw_detail.object.priceplan[ll_rows2])
		ls_zoncod2    = Trim(dw_detail.object.zoncod_cost[ll_rows2])
		ls_fromdt2    = String(dw_detail.object.fromdt[ll_rows2], 'yyyymmdd')
		ls_todt2     = String(dw_detail.object.todt[ll_rows2], 'yyyymmdd')
		
		If IsNull(ls_todt2) Or ls_todt2 = "" Then ls_todt2 = '99991231'
		
		If (ls_priceplan1 = ls_priceplan2) And (ls_zoncod1 = ls_zoncod2) Then
			If ls_todt1 >= ls_fromdt2 Then
				f_msg_info(9000, Title, "같은 가격정책[ " + ls_priceplan2 + " ], 같은 원가대역[ " + ls_zoncod2 + " ] " &
												+ "으로 적용시작일이 중복됩니다.")
				dw_detail.SetRedraw(True)
				dw_detail.setColumn("fromdt")
				dw_detail.setRow(ll_rows2)
				dw_detail.scrollToRow(ll_rows2)
				Return -2
			End If
		End If
		
	Next
	
Next

ls_sort = "svccod, priceplan, zoncod_cost, to_char(fromdt,'yyyymmdd')"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

//Update Log
If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
	dw_detail.object.updt_user[ll_rows1] = gs_user_id
	dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
	dw_detail.object.pgm_id[ll_rows1] = gs_pgm_id[1]
End If
	



Return 0
end event

event type integer ue_save();String ls_priceplan
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

Return 0
end event

event type integer ue_reset();call super::ue_reset;
p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_enable")

p_saveas.TriggerEvent("ue_disable")
p_fileread.TriggerEvent("ue_disable")


Return 0 
end event

event resize;call super::resize;If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_saveas.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_fileread.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_saveas.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_fileread.Y	= newheight - iu_cust_w_resize.ii_button_space
	
	
End If
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_outboundzone_v20
integer x = 37
integer y = 56
integer width = 2446
integer height = 204
string dataobject = "b0dw_cnd_reg_outboundzone_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_svccod, ls_filter
Long   ll_row

dw_cond.Accepttext()

ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')

//서비스별 가격정책 가져오기 all포함 
ll_row = dw_cond.GetChild("priceplan", idc_priceplan)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "svccod IN ('ALL', '" + ls_svccod + "') "
idc_priceplan.SetFilter(ls_filter)			//Filter정함
idc_priceplan.Filter()
idc_priceplan.SetTransObject(SQLCA)
ll_row =idc_priceplan.Retrieve()

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
Else
	dw_cond.SetColumn("priceplan")	//찾았을 경우 적용이 빨리 안되서
End If

end event

type p_ok from w_a_reg_m`p_ok within b0w_reg_outboundzone_v20
integer x = 2670
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b0w_reg_outboundzone_v20
integer x = 2967
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_outboundzone_v20
integer x = 23
integer width = 2491
integer height = 284
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_outboundzone_v20
integer y = 1548
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_outboundzone_v20
integer y = 1548
end type

type p_save from w_a_reg_m`p_save within b0w_reg_outboundzone_v20
integer y = 1548
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_outboundzone_v20
integer x = 27
integer y = 304
integer width = 3237
integer height = 1208
string dataobject = "b0dw_reg_outboundzone"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;String ls_svccod, ls_filter
Long   ll_row

dw_cond.Accepttext()

ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')

//서비스별 가격정책 가져오기 all포함 
ll_row = This.GetChild("priceplan", idc_priceplan)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "svccod IN ('ALL', '" + ls_svccod + "') "
idc_priceplan.SetFilter(ls_filter)			//Filter정함
idc_priceplan.Filter()
idc_priceplan.SetTransObject(SQLCA)
ll_row =idc_priceplan.Retrieve()

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
Else
	This.SetColumn("priceplan")	//찾았을 경우 적용이 빨리 안되서
End If

end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_outboundzone_v20
integer x = 1097
integer y = 1548
end type

type p_saveas from u_p_saveas within b0w_reg_outboundzone_v20
integer x = 1536
integer y = 1548
boolean bringtotop = true
boolean originalsize = false
end type

type p_fileread from u_p_fileread within b0w_reg_outboundzone_v20
integer x = 1842
integer y = 1548
boolean bringtotop = true
boolean originalsize = false
end type

