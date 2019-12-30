$PBExportHeader$b1w_reg_contractupload_fun_v20.srw
$PBExportComments$[ohj] 계약자동처리시 필요기능구성 v20
forward
global type b1w_reg_contractupload_fun_v20 from w_a_reg_m
end type
end forward

global type b1w_reg_contractupload_fun_v20 from w_a_reg_m
end type
global b1w_reg_contractupload_fun_v20 b1w_reg_contractupload_fun_v20

type variables
String is_file_code
end variables

on b1w_reg_contractupload_fun_v20.create
call super::create
end on

on b1w_reg_contractupload_fun_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_req_contractupload_func_v20
	Desc.	: 	개통upload 기능정의
	Ver.	:	1.0
	Date	: 	2005.05.06
	Programer : Oh Hye Jin
--------------------------------------------------------------------------*/
String  ls_temp, ls_result[], ls_ref_desc, ls_filter
Integer li_exist
DataWindowChild ldc_file_code

//개통정보생성 CO;GK
ls_temp = fs_get_control("B1","P320", ls_ref_desc)

If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

is_file_code = ls_result[1]

//가격정책별 인증KEYTYPE
li_exist = dw_cond.GetChild("file_code", ldc_file_code)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : file code")
ls_filter = "b.group_code = '" + is_file_code + "'  " 
ldc_file_code.SetTransObject(SQLCA)
li_exist =ldc_file_code.Retrieve()
ldc_file_code.SetFilter(ls_filter)		
ldc_file_code.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return   	
End If
end event

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_file_code

ls_file_code = fs_snvl(dw_cond.Object.file_code[1], '')

If ls_file_code = '' Then
	f_msg_info(200, Title, "유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("file_code")
   Return 
End If

//Dynamic SQL
IF ls_file_code <> "" THEN	
	ls_where = "A.FILE_CODE = '" +ls_file_code +"' "
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
End If	

p_delete.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
dw_cond.Enabled = False

end event

event type integer ue_extra_save();call super::ue_extra_save;//Save
String ls_itemkey, ls_check_type, ls_outputdata, ls_itemkey1, ls_itemkey2
Long   ll_row, ll_cnt, ll_rows, ll_rows1, ll_rows2, ll_length

//Row 수가 없으면
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

dw_detail.AcceptText()

For ll_row = 1 To ll_rows
	//필수 Check
	ls_itemkey    = fs_snvl(dw_detail.object.itemkey[ll_row]   , '')
	ls_check_type = fs_snvl(dw_detail.object.check_type[ll_row], '')
	ls_outputdata = fs_snvl(dw_detail.object.outputdata[ll_row], '')
	
	//필수 항목 check 
	If ls_itemkey = "" Then
		f_msg_usr_err(200, Title, "기능key")
		dw_detail.SetColumn("itemkey")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If
	
//	If ls_check_type = "" Then
//		f_msg_usr_err(200, Title, "Check유형")
//		dw_detail.SetColumn("check_type")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		Return -1	
//	End If
Next

For ll_rows1 = 1 To dw_detail.RowCount()

	ls_itemkey1    = fs_snvl(Trim(dw_detail.object.itemkey[ll_rows1]), '')
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		
		ls_itemkey2  = fs_snvl(Trim(dw_detail.object.itemkey[ll_rows2]), '')
	
		If ls_itemkey1 = ls_itemkey2 Then
			f_msg_info(9000, Title, "기능key [ " + ls_itemkey2 + " ]이(가) 중복됩니다.")
			dw_detail.SetColumn("itemkey")
			Return -2
		End If
		
	Next
	
Next

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
dw_detail.object.file_code[al_insert_row] = dw_cond.object.file_code[1]

dw_detail.SetitemStatus(al_insert_row, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("itemkey")

Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.file_code[1] = ""

dw_cond.SetColumn("file_code")

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_contractupload_fun_v20
integer y = 84
integer width = 1609
integer height = 136
string dataobject = "b1dw_cnd_contractupload_func_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_contractupload_fun_v20
integer x = 2194
end type

type p_close from w_a_reg_m`p_close within b1w_reg_contractupload_fun_v20
integer x = 2501
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_contractupload_fun_v20
integer x = 37
integer y = 4
integer width = 2043
integer height = 236
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_contractupload_fun_v20
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_contractupload_fun_v20
end type

type p_save from w_a_reg_m`p_save within b1w_reg_contractupload_fun_v20
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_contractupload_fun_v20
integer x = 37
integer y = 268
integer height = 1300
string dataobject = "b1dw_reg_contractupload_func_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_itemkeydesc, is_remark 

//품목중분류 선택시 품목대분류 자동 뿌려줌!!
Choose Case dwo.Name
	Case "itemkey"
		SELECT ITEMKEYDESC
		     , REMARK
		  INTO :ls_itemkeydesc
		     , :is_remark
		  FROM CONTRACTUPLOAD_BFUNC
		 WHERE ITEMKEY = :data;		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT CONTRACTUPLOAD_BFUNC ")
			Return
		End If		
		
		This.Object.itemkeydesc[row] = ls_itemkeydesc
		This.Object.remark[row]      = is_remark
		
End Choose


end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_contractupload_fun_v20
end type

