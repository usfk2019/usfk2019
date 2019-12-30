$PBExportHeader$b5w_inq_billfile_create_popup_v20.srw
$PBExportComments$[ohj] 청구file 생성-popup
forward
global type b5w_inq_billfile_create_popup_v20 from w_a_inq_s
end type
type p_1 from u_p_create within b5w_inq_billfile_create_popup_v20
end type
end forward

global type b5w_inq_billfile_create_popup_v20 from w_a_inq_s
integer width = 2642
integer height = 976
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_create ( )
p_1 p_1
end type
global b5w_inq_billfile_create_popup_v20 b5w_inq_billfile_create_popup_v20

type variables
String  is_cnd_invf_type, is_cnd_pay_method, is_cnd_inv_type, is_cnd_chargedt, &
        is_cnd_bankpay, is_cnd_creditpay, is_cnd_etcpay, is_ctype_10, is_ctype_20,&
		  is_pathname, is_invf_giro, is_invf_auto, is_result[], is_result1[], is_result2[], &
		  is_invf_gubun[]
Date    id_workdt, id_inputclosedt, id_cnd_trdt
Integer li_return
end variables

event ue_create();Integer li_i, li_rc
Long ll_prccount, ll_return
String ls_choice[8], ls_mark[8], ls_filename[8], ls_cnd_file_loc
String ls_caller, ls_pathname, ls_trdt, ls_gubun, ls_ctype, ls_cnd_trdt, ls_workdt
Decimal lc0_prcamt
dw_cond.Accepttext()

b5u_dbmgr9_v20 iu_db
iu_db = Create b5u_dbmgr9_v20

SetPointer(HourGlass!)

id_cnd_trdt       = dw_cond.object.cnd_trdt[1]
ls_cnd_trdt       = string(dw_cond.object.cnd_trdt[1], 'yyyymmdd')
is_cnd_invf_type  = fs_snvl(dw_cond.object.cnd_invf_type[1] ,  '')
is_cnd_chargedt   = fs_snvl(dw_cond.object.cnd_chargedt[1]  ,  '')
is_cnd_inv_type   = fs_snvl(dw_cond.object.cnd_inv_type[1]  ,  '')	
id_workdt         = dw_cond.object.cnd_workdt[1]
ls_workdt         = string(id_workdt, 'yyyymmdd')
id_inputclosedt   = dw_cond.object.cnd_inputclosedt[1] // 입금마감일
ls_cnd_file_loc   = dw_cond.object.cnd_file_location[1] //경로

If Isnull(ls_cnd_trdt) Then ls_cnd_trdt = ''

If is_cnd_invf_type = '' Then
	f_msg_usr_err(200, Title, "청구파일유형을 선택하세요!")
	dw_cond.SetColumn("cnd_invf_type")
	Return 
End If

If ls_cnd_trdt = '' Then
	f_msg_usr_err(200, Title, "청구주기를 선택하세요!")
	dw_cond.SetColumn("cnd_trdt")
	Return 
End If

ls_mark[1] = Trim(dw_cond.Object.choice1[1])
ls_mark[2] = Trim(dw_cond.Object.choice2[1])
ls_mark[3] = Trim(dw_cond.Object.choice3[1])
ls_mark[4] = Trim(dw_cond.Object.choice4[1])

ls_filename[1] = Trim(dw_cond.Object.file1[1])
ls_filename[2] = Trim(dw_cond.Object.file2[1])
ls_filename[3] = Trim(dw_cond.Object.file3[1])
ls_filename[4] = Trim(dw_cond.Object.file4[1])

//ll_return = b5fi_cdr_group_v20()
//
//If ll_return <> 0 Then
//	f_msg_info(9000, Title,"청구그룹별 cdr Table 생성 오류")
//	Return
//End If

For li_i = 1 To 4
	If li_i <= 2 Then //Or li_i = 5 Or li_i = 6 Then 
		ls_ctype = is_ctype_10 
	Else
		ls_ctype = is_ctype_20	
	End If
	
	If ls_mark[li_i] <> "EXC" Then
	//	w_msg_wait.Title = "청구대행파일생성 : " + ls_filename[li_i]
		
		iu_db.is_title = Title
		iu_db.is_data[1] = is_cnd_invf_type
		iu_db.is_data[2] = string(id_cnd_trdt, 'yyyymmdd')
		iu_db.is_data[3] = ls_cnd_file_loc//is_pathname
		iu_db.is_data[4] = ls_filename[li_i]
		iu_db.is_data[5] = ls_ctype  //개인, 법인코드	
		iu_db.is_data[6] = ls_mark[li_i]  //정상(0,2), 연체구분(1, 3)
		iu_db.is_data[7] = is_cnd_inv_type
		iu_db.is_data[8] = ls_workdt
		iu_db.is_data[9] = is_cnd_chargedt
		iu_db.is_data[10] = string(id_inputclosedt, 'yyyymmdd')
//		If is_cnd_invf_type = is_invf_giro Then 
//			iu_db.uf_prc_db_03()
//		ElseIf is_cnd_invf_type = is_invf_auto Then 
			iu_db.uf_prc_db_04()		
//		End If	
		
		li_rc = iu_db.ii_rc

//		If li_rc < 0 Then 
//			Destroy b5u_dbmgr9
//			Return 
//		End If
		
		Choose Case li_rc			
			Case -1
				rollback;				
				f_msg_info(3010, Title,ls_filename[li_i] +"Save")
				Destroy b5u_dbmgr9_v20		
				Return			
		End Choose			
	End If
Next

//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy b5u_dbmgr9_v20

li_return = li_rc

//wf_billfile_create()
////u_cust_db_app iu_cust_db_app
//li_return = 

Choose Case li_return	
	Case -1
		rollback;
		
		f_msg_info(3010, Title,"Save")
				
	Case Is >= 0
		commit;
		//This.Trigger Event ue_ok()
		
		f_msg_info(3000, Title,"Save")
		TriggerEvent("ue_close")
	   //iu_cust_msg.idw_data[1].Trigger Event ue_ok()
End Choose	
	//ii_error_chk = 0
	//p_new.TriggerEvent("ue_enable")
	
Return 

SetPointer(Arrow!)
end event

event open;call super::open;/*-------------------------------------------------------
	Name	: b5w_inq_billfile_create_popup
	Desc.	: 
	Ver.	: 1.0
	Date	: 2005.02.23
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row
String ls_itemcod, ls_ref_content, ls_result[], ls_ref_desc

//iu_mdb_app = Create u_cust_db_app

f_center_window(b5w_inq_billfile_create_popup_v20)

dw_cond.SetItem(1, 'cnd_workdt', fdt_get_dbserver_now() )
//dw_cond.SetItem(1, 'cnd_inputclosedt', fdt_get_dbserver_now() )
//dw_cond.SetItem(1, 'cnd_pay_method', 'Y')

//TriggerEvent("ue_ok")

//dw_cond.object.priceplan[1] = iu_cust_msg.is_data[1]
// 청구파일유형
ls_ref_content =  fs_get_control("B7", "C600", ls_ref_desc)
If ls_ref_content = "" Then
	f_msg_usr_err(9000, Title, "파일이름 대한 정보가 없습니다.(SYSCTL1T:B7:C600)")
	Return
End If
li_return = fi_cut_string(ls_ref_content, ";", is_invf_gubun[])

// 파일이름 00321
ls_ref_content =  fs_get_control("B7", "C400", ls_ref_desc)
If ls_ref_content = "" Then
	f_msg_usr_err(9000, Title, "파일이름 대한 정보가 없습니다.(SYSCTL1T:B7:C400)")
	Return
End If

li_return = fi_cut_string(ls_ref_content, ";", is_result[])

// 파일이름 세이버
ls_ref_content =  fs_get_control("B7", "C410", ls_ref_desc)
If ls_ref_content = "" Then
	f_msg_usr_err(9000, Title, "파일이름 대한 정보가 없습니다.(SYSCTL1T:B7:C410)")
	Return
End If

li_return = fi_cut_string(ls_ref_content, ";", is_result1[])

// 파일이름 로밍
ls_ref_content =  fs_get_control("B7", "C420", ls_ref_desc)
If ls_ref_content = "" Then
	f_msg_usr_err(9000, Title, "파일이름 대한 정보가 없습니다.(SYSCTL1T:B7:C420)")
	Return
End If

li_return = fi_cut_string(ls_ref_content, ";", is_result2[])

//If li_return < 8 Then 
//	f_msg_usr_err(9000, Title, "파일이름 대한 정보가 부족합니다.(SYSCTL1T:B7:13)")
//	Return
//End If	

//dw_cond.Object.file1[1]  = ls_result[1]
//dw_cond.Object.file2[1]  = ls_result[2]
//dw_cond.Object.file3[1]  = ls_result[3]
//dw_cond.Object.file4[1]  = ls_result[4]
//dw_cond.Object.file5[1]  = ls_result[5]
//dw_cond.Object.file6[1]  = ls_result[6]
//dw_cond.Object.file7[1]  = ls_result[7]
//dw_cond.Object.file8[1]  = ls_result[8]

//개인 코드
is_ctype_10    = fs_get_control("B0", "P111", ls_ref_desc) 

//법인코드
ls_ref_content	= fs_get_control("B0", "P110", ls_ref_desc) 
li_return      = fi_cut_string(ls_ref_content, ";", ls_result[])
is_ctype_20    = ls_result[1]

//저장경로
is_pathname	= fs_get_control("B7", "C500", ls_ref_desc)
dw_cond.Object.cnd_file_location[1] = is_pathname
Return 0
end event

on b5w_inq_billfile_create_popup_v20.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b5w_inq_billfile_create_popup_v20.destroy
call super::destroy
destroy(this.p_1)
end on

type dw_cond from w_a_inq_s`dw_cond within b5w_inq_billfile_create_popup_v20
integer width = 2103
integer height = 800
string dataobject = "b5dw_inq_billfile_create_popup_v20"
end type

event dw_cond::itemchanged;call super::itemchanged;Choose Case dwo.name
	Case "cnd_invf_type"
		
		If data = is_invf_gubun[1] Then   //00321giro
			dw_cond.Object.file1[1]  = is_result[1]
			dw_cond.Object.file2[1]  = is_result[2]
			dw_cond.Object.file3[1]  = is_result[3]
			dw_cond.Object.file4[1]  = is_result[4]
			
		ElseIf data = is_invf_gubun[2] Then //00321auto
			dw_cond.Object.file1[1]  = is_result[5]
			dw_cond.Object.file2[1]  = is_result[6]
			dw_cond.Object.file3[1]  = is_result[7]
			dw_cond.Object.file4[1]  = is_result[8]
		ElseIf data = is_invf_gubun[3] Then   //세이버giro
			dw_cond.Object.file1[1]  = is_result1[1]
			dw_cond.Object.file2[1]  = is_result1[2]
			dw_cond.Object.file3[1]  = is_result1[3]
			dw_cond.Object.file4[1]  = is_result1[4]
			
		ElseIf data = is_invf_gubun[4] Then //세이버auto
			dw_cond.Object.file1[1]  = is_result1[5]
			dw_cond.Object.file2[1]  = is_result1[6]
			dw_cond.Object.file3[1]  = is_result1[7]
			dw_cond.Object.file4[1]  = is_result1[8]
			
		ElseIf data = is_invf_gubun[5] Then   //로밍giro
			dw_cond.Object.file1[1]  = is_result2[1]
			dw_cond.Object.file2[1]  = is_result2[2]
			dw_cond.Object.file3[1]  = is_result2[3]
			dw_cond.Object.file4[1]  = is_result2[4]
			
		ElseIf data = is_invf_gubun[6] Then //로밍auto
			dw_cond.Object.file1[1]  = is_result2[5]
			dw_cond.Object.file2[1]  = is_result2[6]
			dw_cond.Object.file3[1]  = is_result2[7]
			dw_cond.Object.file4[1]  = is_result2[8]	
		End If	
	Case "cnd_chargedt"
		
		Date ld_reqdt, ld_inputclosedt
		SELECT REQDT
		     , ADD_MONTHS( INPUTCLOSEDT, 1)
		  INTO :ld_reqdt
		     , :ld_inputclosedt
		  FROM REQCONF
		 WHERE CHARGEDT = :data ;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "select Error(REQCONF)")
			Return -1
			
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_sql_err(Title, "select no-data(REQCONF)")

		Else
			dw_cond.SetItem(row, 'cnd_trdt'        , ld_reqdt       )
		   dw_cond.SetItem(row, 'cnd_inputclosedt', ld_inputclosedt)
		End If		
End Choose

Return 0
end event

type p_ok from w_a_inq_s`p_ok within b5w_inq_billfile_create_popup_v20
boolean visible = false
end type

type p_close from w_a_inq_s`p_close within b5w_inq_billfile_create_popup_v20
integer x = 2299
integer y = 156
end type

type gb_cond from w_a_inq_s`gb_cond within b5w_inq_billfile_create_popup_v20
integer x = 27
integer width = 2149
integer height = 872
end type

type dw_detail from w_a_inq_s`dw_detail within b5w_inq_billfile_create_popup_v20
boolean visible = false
integer x = 165
integer y = 900
integer width = 1902
integer height = 752
end type

event dw_detail::itemchanged;call super::itemchanged;Choose Case dwo.name
	Case "cnd_chargedt"
		
		Date ld_reqdt
		SELECT REQDT
		  INTO :ld_reqdt
		  FROM REQCONF
		 WHERE CHARGEDT = :data ;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "select Error(REQCONF)")
			Return -1
			
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_sql_err(Title, "select no-data(REQCONF)")

		Else
			dw_cond.SetItem(row, 'cnd_trdt', ld_reqdt)
		
		End If		
		  
End Choose

Return 0
end event

type p_1 from u_p_create within b5w_inq_billfile_create_popup_v20
integer x = 2299
integer y = 52
boolean bringtotop = true
end type

