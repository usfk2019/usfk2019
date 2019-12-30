$PBExportHeader$c1w_reg_carrier_rate.srw
$PBExportComments$[ysbyun]회선정산Rate(건당)
forward
global type c1w_reg_carrier_rate from w_a_reg_m
end type
type p_fileread from u_p_fileread within c1w_reg_carrier_rate
end type
end forward

global type c1w_reg_carrier_rate from w_a_reg_m
integer width = 3090
integer height = 1900
event ue_fileread ( )
p_fileread p_fileread
end type
global c1w_reg_carrier_rate c1w_reg_carrier_rate

type variables
String is_ratetype
end variables

event ue_fileread();//승인 요청 된 파일 불러옴
String ls_filename, ls_pathname
Int li_rc
Long ll_row

//파일 선택
li_rc = GetFileOpenName("Select File" , ls_pathname, ls_filename, '', &
						'Text Files(*.TXT), *.TXT')
						
If li_rc = -1 Then 			//Error
    f_msg_usr_err(9000, Title, "This file can't be opened!") 
	Return
End If
			
ll_row= dw_detail.RowCount()
If li_rc = 1 Then
	dw_detail.importfile(ls_pathname)
	//dw_detail.importfile(ls_pathname, ll_row + 1, 0, 1, 1,5)
End If

ls_pathname = ""

Return 
end event

on c1w_reg_carrier_rate.create
int iCurrent
call super::create
this.p_fileread=create p_fileread
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_fileread
end on

on c1w_reg_carrier_rate.destroy
call super::destroy
destroy(this.p_fileread)
end on

event ue_ok();call super::ue_ok;
//조회
String ls_carrierid, ls_where, ls_opendt
Long ll_row

ls_carrierid = Trim(dw_cond.object.cdsaup[1])
ls_opendt = String(dw_cond.object.opendt[1], 'yyyymmdd')
If IsNull(ls_carrierid) Then ls_carrierid = ""
If IsNull(ls_opendt) Then ls_opendt = ""

// 필수항목 Check
If ls_carrierid = "" Then
	f_msg_info(200, Title,"회선사업자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("cdsaup")
   Return
End If

// Dynamic SQL
If ls_carrierid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " carrierid = '" + ls_carrierid + "' "
End If

If ls_opendt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	/*ls_where += "opendt IN (select Max(opendt) from carrier_rate where carrierid ='" + ls_cdsaup + "'" + &
	            " And to_char(opendt, 'yyyymmdd') <= '" + ls_opendt + "')" */
	ls_where += "to_char(opendt, 'yyyymmdd') <= '" + ls_opendt  + "' "
End If	


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")	
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("carrierid")


//Setting
dw_detail.Object.carrierid[al_insert_row] = dw_cond.Object.cdsaup[1]
dw_detail.object.opendt[al_insert_row] = date(String(today(),"yyyy-mm-dd"))
dw_detail.object.roundflag[al_insert_row] = "U"


//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0

end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//ii_error_chk = 0
Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;int li_RowCount, li_Count

// dw_detail Vaildation
  li_RowCount = dw_detail.Rowcount()
  if li_RowCount = 0 then return 0
  

for li_Count = 1 to li_RowCount
	
   // 필수 항목 check 
	If (isNull(dw_detail.Object.carrierid[li_Count])) then
		f_msg_usr_err(200, Title, "사업자ID")
		dw_detail.SetColumn("carrierid")
		dw_detail.SetRow(li_Count)
		dw_detail.ScrollToRow(li_Count)
		Return -2
	End If
	
	If (isNull(dw_detail.Object.areacod[li_Count])) then
		f_msg_usr_err(200, Title, "지역코드")
		dw_detail.SetColumn("areacod")
		dw_detail.SetRow(li_Count)
		dw_detail.ScrollToRow(li_Count)
		Return -2
	End If
	
	If (isNull(dw_detail.Object.opendt[li_Count])) then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetColumn("opendt")
		dw_detail.SetRow(li_Count)
		dw_detail.ScrollToRow(li_Count)
		Return -2
	End If
	
	If (isNull(dw_detail.Object.zoncod[li_Count])) then
		f_msg_usr_err(200, Title, "대역")
		dw_detail.SetColumn("zoncod")
		dw_detail.SetRow(li_Count)
		dw_detail.ScrollToRow(li_Count)
		Return -2
	End If
	
	If (isNull(dw_detail.Object.addsec[li_Count])) then
		f_msg_usr_err(200, Title, "추가시간단위")
		dw_detail.SetColumn("addsec")
		dw_detail.SetRow(li_Count)
		dw_detail.ScrollToRow(li_Count)
		Return -2
	End If
	
	If dw_detail.GetItemStatus(li_Count, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[li_Count] = gs_user_id
		dw_detail.object.updtdt[li_Count] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[li_Count] = gs_pgm_id[gi_open_win_no]
	End If	

Next 	

return 0
end event

event open;call super::open;String ls_ref_desc, ls_temp, ls_name[]

//회선사업자 type 코드
ls_ref_desc =""
ls_temp = fs_get_control("C1", "C120", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])		
//회선사업자 type 코드(건당)
is_ratetype = ls_name[1]

DataWindowChild ldc_ratetype
Long li_exist
String ls_filter
Boolean lb_check


li_exist = dw_cond.GetChild("cdsaup", ldc_ratetype)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 회선사업자")
ls_filter = "ratetype = '" + is_ratetype + "'" 
ldc_ratetype.SetTransObject(SQLCA)
li_exist = ldc_ratetype.Retrieve()
ldc_ratetype.SetFilter(ls_filter)			//Filter정함
ldc_ratetype.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If  



end event

type dw_cond from w_a_reg_m`dw_cond within c1w_reg_carrier_rate
integer x = 46
integer y = 56
integer width = 1125
integer height = 212
string dataobject = "c1dw_cnd_reg_carrier_rate"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within c1w_reg_carrier_rate
integer x = 1312
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within c1w_reg_carrier_rate
integer x = 1925
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within c1w_reg_carrier_rate
integer width = 1179
integer height = 324
end type

type p_delete from w_a_reg_m`p_delete within c1w_reg_carrier_rate
integer y = 1592
boolean enabled = true
end type

type p_insert from w_a_reg_m`p_insert within c1w_reg_carrier_rate
integer y = 1592
boolean enabled = true
end type

type p_save from w_a_reg_m`p_save within c1w_reg_carrier_rate
integer y = 1592
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within c1w_reg_carrier_rate
integer x = 27
integer y = 348
integer height = 1176
string dataobject = "c1dw_inq_reg_carrier_rate"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within c1w_reg_carrier_rate
integer y = 1592
boolean enabled = true
end type

type p_fileread from u_p_fileread within c1w_reg_carrier_rate
integer x = 1618
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

