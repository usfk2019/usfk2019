$PBExportHeader$rpt0w_reg_level_declare.srw
$PBExportComments$[parkkh] Drive Level Declare  Window
forward
global type rpt0w_reg_level_declare from w_a_reg_m_m3
end type
end forward

global type rpt0w_reg_level_declare from w_a_reg_m_m3
integer width = 3570
integer height = 1900
end type
global rpt0w_reg_level_declare rpt0w_reg_level_declare

type variables
String is_modified[]//, is_modify_levelno
DEC ic_levelno, ic_levelno_ue_select
end variables

forward prototypes
public function string wfs_get_level_description (decimal ac_levelno)
public function string wfs_get_codenm (string as_grcode, string as_code)
public function boolean wfb_get_glname (string as_glcod, string as_glname)
end prototypes

public function string wfs_get_level_description (decimal ac_levelno);// Level_Dec테이블에 levelno가 존재하는 지 검증하는 함수

String ls_title, ls_return

ls_title = "wfs_get_level_description"

SELECT UNIQUE description
INTO  :ls_return
FROM   level_dec
WHERE  levelno = :ac_levelno  ;


If SQLCA.SQLCode = 100 Then
	ls_return = ""
	//f_msg_usr_err(1100,ls_title,"Level No " + String(ac_levelno) + "가 존재하지 않습니다.")
ElseIf SQLCA.SQLCode < 0 Then
	ls_return = ""
	f_msg_sql_err(ls_title,"")
Else           //levelno가 있다면....
	
End If

Return ls_return
end function

public function string wfs_get_codenm (string as_grcode, string as_code);//계정그룹에 따른 그룹코드명 리턴

String ls_codenm, ls_return, ls_title

ls_title = "wfs_get_codenm"

SELECT   codenm
INTO    :ls_codenm
FROM    syscod2t
WHERE   grcode = :as_grcode AND code = :as_code ;

If SQLCA.SQLCode = 100 Then
	ls_return = ""
	
ElseIf SQLCA.SQLCode < 0 Then
	ls_return = ""
	f_msg_sql_err(ls_title,"")
Else
	ls_return = Trim(ls_codenm)
	If IsNull(ls_return) Then ls_return = ""
End If

Return ls_return
end function

public function boolean wfb_get_glname (string as_glcod, string as_glname);//올바른 계정코드 여부와 계정코드로 계정명 인수로 전달
Boolean lb_return
String ls_glname, ls_title
Long ll_count

ls_title = ""

SELECT count(*)
INTO  :ll_count
FROM   glcodm
WHERE  glcod = :as_glcod;


If ll_count > 0 Then
	lb_return = True
Else
	lb_return = False
	f_msg_usr_err(1100,ls_title,"계정코드 " + as_glcod + "가 존재하지 않습니다.")

End If

If lb_return Then   //계정코드가 있는 경우만 ..
	
	SELECT   glname
	INTO    :ls_glname
	FROM    glcodm
	WHERE   glcod = :as_glcod ;
	
Else 
	ls_glname = ""
End If

//as_glname = ls_glname  //계정명을 인수로 전달..   ---->취소 Pass By 수정해야 한다.
Return lb_return       //계정코드의 유무를 리턴..
end function

on rpt0w_reg_level_declare.create
call super::create
end on

on rpt0w_reg_level_declare.destroy
call super::destroy
end on

event ue_ok();// Not extend ancestor script

//ancestor script..
If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End if

//Event ue_ok_after()

//.............
String ls_levelno_fr, ls_levelno_to, ls_description
Long ll_row
String ls_where

ls_levelno_fr = Trim(dw_cond.Object.levelno_fr[1])
ls_levelno_to = Trim(dw_cond.Object.levelno_to[1])
ls_description = Trim(dw_cond.Object.description[1])

If IsNull(ls_levelno_fr) Then ls_levelno_fr = ""
If IsNull(ls_levelno_to) Then ls_levelno_to = ""
If IsNull(ls_description) Then ls_description = ""

//Level No:  valid check
If ls_levelno_fr <> "" And ls_levelno_to <> "" Then
	If Long(ls_levelno_fr) > Long(ls_levelno_to) Then
		f_msg_usr_err(202,Title,"Level No")
		dw_cond.SetFocus()
		dw_cond.SetColumn("levelno_fr")
		Return
	End If
End If

//sql where 절..
ls_where = ""
If ls_levelno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.levelno >= '" + ls_levelno_fr + "' "
End If

If ls_levelno_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.levelno <= '" + ls_levelno_to + "' "
End If

If ls_description <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.description like '%" + ls_description + "%' "
End If

//Retrieve
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100,Title,"Retrieve(): dw_master")
	Return 
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100,Title,"") 
	//Insert button enable
    p_insert.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
End If

Event ue_ok_after()
end event

event ue_extra_insert(long al_insert_row, ref integer ai_return);call super::ue_extra_insert;Long ll_rct_detail2, ll_newrow, ll_row_cur_detail, ll_currow_master
DEC lc_levelno_detail2
//String ls_delete_flag

ll_rct_detail2 = dw_detail2.RowCount()
ll_currow_master = dw_master.GetRow()

//If ll_currow_master > 0 Then
//	ls_delete_flag = Trim(dw_master.Object.delete_flag[ll_currow_master])
//End If

If ll_rct_detail2 > 0 Then     //기존 자료 수정
	//모든 update는 dw_detail을 이용하므로 dw_detail2는 하나의 row만 insert한다.
Else     //dw_detail의 기존자료를 모두 삭제했거나 새로운 입력일 경우
	ll_newrow = dw_detail2.InsertRow(0)
	dw_detail2.ScrollToRow(ll_newrow)
	dw_detail2.SetFocus()
	
	//dw_master에 선택된 열이 있는 경우(신규입력이 아니고 기존 자료의 모든 열을 삭제후 다시 첫 열부터  insert하는 경우:dw_master에 자료가 있다.)
	If dw_master.GetSelectedRow(0) <> 0 Then   // ---> dw_detail2의 항목은 dw_master의 항목으로 한다.                                         
		dw_detail2.Object.levelno[1] = dw_master.Object.levelno[ll_currow_master]
		dw_detail2.Object.description[1] = Trim(dw_master.Object.description[ll_currow_master])
	End If
	
End If

//dw_detail2의 Level No입력되어야 dw_detail에 추가적인 row Insert가 가능하도록..
lc_levelno_detail2 = dw_detail2.Object.levelno[1] 
ll_row_cur_detail = dw_detail.GetRow()
If ll_rct_detail2 > 0 Then
	If IsNull(lc_levelno_detail2) Then
		f_msg_usr_err(200,Title,"먼저 Level No를 입력하십시오")
		dw_detail2.SetFocus()
		dw_detail2.SetColumn("levelno")
		ai_return = -1
		dw_detail.DeleteRow(ll_row_cur_detail)
		Return
	End If
End IF

//Delete,Save 버튼 활성화
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
end event

event ue_insert();//Not extend ancestor script
Long ll_row, ll_rct_detail2, ll_i, ll_rct_detail
Int li_return

ll_rct_detail2 = dw_detail2.RowCount()

ii_error_chk = -1

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

ll_rct_detail = dw_detail.RowCount()  //새로 생긴 row를 포함해서..

//Seq는 그 row의 row넘버로 한다.
For ll_i = 1 To ll_rct_detail 
	dw_detail.Object.seq[ll_i] = ll_i
Next

//  Default data
dw_detail.Object.crtdt[ll_row] = fdt_get_dbserver_now()
dw_detail.Object.crt_user[ll_row] = gs_user_id
dw_detail.Object.updt_user[ll_row] = gs_user_id
dw_detail.Object.updtdt[ll_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[ll_row] = gs_pgm_id[gi_open_win_no]

If ll_rct_detail2 > 0 Then    //첫 Insert가 아닌 경우, 즉 dw_detail2에 row가 있는 경우 포커스 처리
	
	dw_detail.ScrollToRow(ll_row)
	dw_detail.SetRow(ll_row)
	dw_detail.SetFocus()

End If

This.Trigger Event ue_extra_insert(ll_row,li_return)

If li_return < 0 Then
	Return
End if

ii_error_chk = 0
end event

event ue_extra_delete;call super::ue_extra_delete;Long ll_rct_detail//,ll_currow_master

ll_rct_detail = dw_detail.RowCount()

If ll_rct_detail < 1 Then   //dw_detail의 모든 row가 삭제될 때 dw_detail2의 row도 같이 삭제된다.
	dw_detail2.DeleteRow(0)
//	ll_currow_master = dw_master.GetRow()
//	dw_master.Object.delete_flag[ll_currow_master] = "ON"
End If
end event

event ue_delete;//Not extend ancestor script
Int li_return
Long ll_i, ll_rct_detail

ii_error_chk = -1

//This.Trigger Event ue_extra_delete(li_return)

If li_return < 0 Then
	Return
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
End if

This.Trigger Event ue_extra_delete(li_return)

ii_error_chk = 0

//Delete로 인해서 Seq컬럼의 값과 row 넘버가 달라진 것을 일치시킨다.
ll_rct_detail = dw_detail.RowCount()

For ll_i = 1 To ll_rct_detail
	dw_detail.Object.seq[ll_i] = ll_i
Next
end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;String ls_description, ls_wkcod, ls_codiv, ls_from_rptcod, ls_to_rptcod
String ls_opcod
DEC lc_levelno, lc_seq, lc_levelno1, lc_levelno2, lc_factor
Long ll_i, ll_rct_detail
DEC lc_levelno_old, lc_seq_old, lc_levelno1_old, lc_levelno2_old, lc_factor_old
String ls_description_old, ls_wkcod_old, ls_codiv_old, ls_from_rptcod_old, ls_to_rptcod_old
String ls_opcod_old
String ls_from_rptname, ls_to_rptname
Boolean lb_from_rptcod, lb_to_rptcod

//모두 삭제후 저장하는 경우는 아래의 문을 실행하지 않는다.
If dw_detail.RowCount() = 0 Then	
	Return
End If

//******dw_detail2 관련******
//필수입력항목 체크
lc_levelno = dw_detail2.Object.levelno[1]
ls_description = Trim(dw_detail2.Object.description[1])

If IsNull(lc_levelno) Or Not lc_levelno > 0 Then     // Level No가 Null이거나 0이하일 경우..
	f_msg_usr_err(200,Title,"Level No")
	SetNull(lc_levelno)
	dw_detail2.Object.levelno[1] = lc_levelno
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("levelno")
	ai_return = -1
	Return
End If

If IsNull(ls_description) Or ls_description = "" Then       // Description ....
	f_msg_usr_err(200,Title,"Description")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("description")
	ai_return = -1
	Return
End If

//*******dw_detail관련******
//필수입력항목 체크
ll_rct_detail = dw_detail.RowCount()
For  ll_i = 1 To ll_rct_detail
	
	ls_wkcod = Trim(dw_detail.Object.wkcod[ll_i])
	
	If IsNull(ls_wkcod) Or ls_wkcod = "" Then       // wkcod ....
		f_msg_usr_err(200,Title,"구분")
		dw_detail.SetFocus()
		dw_detail.SetColumn("wkcod")
		dw_detail.ScrollToRow(ll_i)
		ai_return = -1
		Return
	End If
	
	// wkcod의 값에 따라서 두가지의 경우로 나누어 체크
	If ls_wkcod = "A" Or ls_wkcod = "S" Then      //구분이 A,S일 경우....
		
		ls_from_rptcod = Trim(dw_detail.Object.from_rptcod[ll_i])
		If IsNull(ls_from_rptcod) Then ls_from_rptcod = ""
		
		If ls_from_rptcod = "" Then
			f_msg_usr_err(200,Title,"From계정")
			dw_detail.SetFocus()
			dw_detail.SetColumn("from_rptcod")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
		
		//To계정코드 Valid Check
		ls_to_rptcod = Trim(dw_detail.Object.to_rptcod[ll_i])
		If IsNull(ls_to_rptcod) Then ls_to_rptcod = ""
			
		
	ElseIf ls_wkcod = "C" Then      //구분이 C일 경우...
		
		//Level 1 필수입력 체크
		lc_levelno1 = dw_detail.Object.levelno1[ll_i]
		
		If IsNull(lc_levelno1) Or Not lc_levelno1 > 0 Then       
			f_msg_usr_err(200,Title,"Level 1")
			dw_detail.SetFocus()
			dw_detail.SetColumn("levelno1")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If

		//Operation 필수입력 체크
		ls_opcod = Trim(dw_detail.Object.opcod[ll_i])
		
		If IsNull(ls_opcod) Or ls_opcod = "" Then       
			f_msg_usr_err(200,Title,"Operation")
			dw_detail.SetFocus()
			dw_detail.SetColumn("opcod")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
		
		//Level 2와 Factor는 동시에 입력할 수 없다.
		lc_levelno2 = dw_detail.Object.levelno2[ll_i]
		lc_factor = dw_detail.Object.factor[ll_i]
		
//		levelno2와 factor가 0일 경우
		If lc_levelno2 = 0 Then
			f_msg_usr_err(201,Title,"level > 0")
			SetNull(lc_levelno2)
			dw_detail.Object.levelno2[ll_i] = lc_levelno2
			dw_detail.SetFocus()
			dw_detail.SetColumn("levelno2")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
		If lc_factor = 0 Then
			f_msg_usr_err(201,Title,"factor > 0")
			SetNull(lc_factor)
			dw_detail.Object.factor[ll_i] = lc_factor
			dw_detail.SetFocus()
			dw_detail.SetColumn("factor")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
			
		
		If (lc_levelno2 > 0) And (lc_factor > 0) Then
			f_msg_usr_err(9000,Title,"Level 2와 Factor는 동시에 입력할 수 없습니다")
			dw_detail.SetFocus()
			dw_detail.SetColumn("levelno2")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
		
		//dw_detail의 Level 1, Level 2의 값은 항상 dw_detail2의 Level No보다 작아야 한다.
		If lc_levelno1 >= lc_levelno Then
			f_msg_usr_err(9000,Title,"현재 Level보다 작은 Level의 연산만 할 수 있습니다")
			dw_detail.SetFocus()
			dw_detail.SetColumn("levelno1")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
		
		If lc_levelno2 >= lc_levelno Then
			f_msg_usr_err(9000,Title,"현재 Level보다 작은 Level의 연산만 할 수 있습니다")
			dw_detail.SetFocus()
			dw_detail.SetColumn("levelno2")
			dw_detail.ScrollToRow(ll_i)
			ai_return = -1
			Return
		End If
	
	End If   //ls_wkcod 조건문 끝
	
Next

//모든 체크가 끝난 후 dw_detail2의 항목을 dw_detail에서 Update할 수 있도록 준비...
For ll_i = 1 To ll_rct_detail
	dw_detail.Object.levelno[ll_i] = lc_levelno
	dw_detail.Object.description[ll_i] = ls_description
	
Next

//기존 자료 수정시 Work Date, Work UserId 수정

For ll_i = 1 To ll_rct_detail
	
	lc_levelno = dw_detail.Object.levelno.Primary.Current[ll_i]
	lc_levelno_old = dw_detail.Object.levelno.Primary.Original[ll_i]
	
	lc_seq = dw_detail.Object.seq.Primary.Current[ll_i]
	lc_seq_old = dw_detail.Object.seq.Primary.Original[ll_i]
	
	lc_levelno1 = dw_detail.Object.levelno1.Primary.Current[ll_i]
	lc_levelno1_old = dw_detail.Object.levelno1.Primary.Original[ll_i]
	
	lc_levelno2 = dw_detail.Object.levelno2.Primary.Current[ll_i]
	lc_levelno2_old = dw_detail.Object.levelno2.Primary.Original[ll_i]
	
	lc_factor = dw_detail.Object.factor.Primary.Current[ll_i]
	lc_factor_old = dw_detail.Object.factor.Primary.Original[ll_i]
	
	ls_description = dw_detail.Object.description.Primary.Current[ll_i]
	ls_description_old = dw_detail.Object.description.Primary.Original[ll_i]
	
	ls_wkcod = dw_detail.Object.wkcod.Primary.Current[ll_i]
	ls_wkcod_old = dw_detail.Object.wkcod.Primary.Original[ll_i]
	
	ls_from_rptcod = dw_detail.Object.from_rptcod.Primary.Current[ll_i]
	ls_from_rptcod_old = dw_detail.Object.from_rptcod.Primary.Original[ll_i]
	
	ls_to_rptcod = dw_detail.Object.to_rptcod.Primary.Current[ll_i]
	ls_to_rptcod_old = dw_detail.Object.to_rptcod.Primary.Original[ll_i]
	
	ls_opcod = dw_detail.Object.opcod.Primary.Current[ll_i]
	ls_opcod_old = dw_detail.Object.opcod.Primary.Original[ll_i]
	
	//기존자료가 수정된다면.....
	If lc_levelno <> lc_levelno_old Or lc_seq <> lc_seq_old Or lc_levelno1 <> lc_levelno1_old  &
	Or lc_levelno2 <> lc_levelno2_old Or lc_factor <> lc_factor_old Or ls_description <> ls_description_old  &
	Or ls_wkcod <> ls_wkcod_old Or ls_codiv <> ls_codiv_old Or ls_from_rptcod <> ls_from_rptcod_old  &
	Or ls_to_rptcod <> ls_to_rptcod_old Or ls_opcod <> ls_opcod_old  Then
		is_modified[ll_i] = "YES"
	Else
		is_modified[ll_i] = "NO"
	End If

//	//dw_detail2의 levelno가 변경될 경우(같은 화면에서 저장후 다시 저장할 경우 발생하는 에러를 막기 위해서 선언...)
//	If lc_levelno <> lc_levelno_old Then
//		is_modify_levelno = "YES"
//		//ic_levelno = lc_levelno 
//	Else
//		is_modify_levelno = "NO"
//	End If

Next

//Save후 포커스처리를 위해.....

/////////////////////////////////////////////////
If Not IsNull(ic_levelno_ue_select) Then   //////저장하지 않고  dw_master의 row를 변경시 save물음에 save를 한 경우..
	ic_levelno = ic_levelno_ue_select       //////
	SetNull(ic_levelno_ue_select) //초기화  //////
Else                                       //////일반적 save의 경우
	ic_levelno = lc_levelno                 ////// 윈도우 오픈후 첫 save에서 좌측의 else문이 성립하려면, 윈도우 오픈시 ic_levelno_ue_select변수를 초기화 해줘야 한다...
End If                                     //////  --->open script
/////////////////////////////////////////////////


end event

event type integer ue_save();// Not extend ancestor script
Int li_return

ii_error_chk = -1

This.Trigger Event ue_extra_save(li_return)

If dw_detail.AcceptText() < 0 Then
//	dw_detail.SetFocus()
	Return -1
End if

//
If li_return < 0 Then
//	dw_detail.SetFocus()
	Return -1
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If
	f_msg_info(3010,This.Title,"Save")
	return -1
end If

//If dw_detail2.Update() < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail2.SetFocus()
//		return -1
//	End If
//	f_msg_info(3010,This.Title,"Save")
//	return -1
//end If

// 저장후 commit 전에 할일 
li_return = 1
Event ue_save_after( li_return )
If li_return < 0 then
	f_msg_info(3010,This.Title,"Save")
	rollback ;
	return -1
End If


//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then

//	dw_detail.SetFocus()
	return -1
End If
f_msg_info(3000,This.Title,"Save")


ii_error_chk = 0
return 1
end event

event ue_save_after(ref integer ai_return);call super::ue_save_after;Long ll_i, ll_rct_detail
DateTime ldt_workdt
DEC lc_levelno

//모두 삭제후 저장하는 경우는 아래의 문을 실행하지 않는다.
If dw_detail.RowCount() = 0 Then	
	Return
End If

ll_rct_detail = dw_detail.RowCount()
lc_levelno = dw_detail2.Object.levelno[1]

//For ll_i = 1 To ll_rct_detail
//	//기존 자료 수정시 Workdt, Wkuser 수정하는 Update SQL Script...
//	If is_modified[ll_i] = "YES" Then
//		
//		ldt_workdt = fdt_get_dbserver_now()
//	
//		UPDATE level_dec
//		SET    workdt = :ldt_workdt, wkuser = :gs_user_id
//		WHERE  levelno = :lc_levelno AND seq = :ll_i ;
//		
//		If SQLCA.SQLCode = 0 Then
//					//MessageBox("LEVEL_DEC update","update complete")
//		Else 
//			MessageBox("LEVEL_DEC update error",sqlca.SQLErrText)
//			ai_return = -1
//			Return 
//		End If
//		
//	End If
//	
//	is_modified[ll_i] = ""   //초기화
//	
//Next

// 다시 저장할 경우 현재의 데이터윈도우의 row와 저장하고자하는 row의 불일치로 인한 에러를 
// 막기 위해서 Save 후 Retireve 한다.

//Retrieve 
Long ll_row_master, ll_rct_master, ll_check_row
Integer li_return

This.Trigger Event ue_ok()
ll_row_master = dw_master.GetRow()
ll_rct_master = dw_master.RowCount()


	//바뀐 levelno가 나오는 행까지 Looping한다.

	ll_check_row = 0
	For ll_i = 1 To ll_rct_master
		ll_check_row = ll_check_row + 1
		lc_levelno = dw_master.Object.levelno[ll_i]
		If lc_levelno = ic_levelno Then  
			EXIT
		End If
	Next
	
	dw_master.SelectRow(1,False)
	dw_master.SelectRow(ll_check_row, True)
	dw_master.ScrollToRow(ll_check_row)
	
	dw_detail.Event ue_retrieve(ll_check_row,li_return)
	If li_return < 0 Then
		Return
	End If
	
	dw_detail2.Event ue_retrieve(ll_check_row,li_return)
	If li_return < 0 Then
		Return
	End If
	
//버튼활성화
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")


//is_modify_levelno = ""
SetNull(ic_levelno)
end event

event ue_reset;call super::ue_reset;Long ll_i, ll_rct_detail

ll_rct_detail = dw_detail.RowCount()

For ll_i = 1 To ll_rct_detail
	is_modified[ll_i] = ""   //초기화
Next
end event

event open;call super::open;//초기화 해줘야 윈도우 오픈후 첫 저장시, ue_extra_save문에서 Else 문의 ic_levelno = lc_levelno가 실행된다.
SetNull(ic_levelno_ue_select)




end event

event ue_ok_after;call super::ue_ok_after;//delete, save버튼 비활성화
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")

//신규입력을 위해서 dw_master의 row가 select되지 않은 상태로 ...
dw_master.SelectRow(0,False)
end event

type dw_cond from w_a_reg_m_m3`dw_cond within rpt0w_reg_level_declare
integer x = 46
integer y = 60
integer width = 2729
integer height = 180
string dataobject = "rpt0dw_cnd_reg_level_declare"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m3`p_ok within rpt0w_reg_level_declare
integer x = 2898
end type

type p_close from w_a_reg_m_m3`p_close within rpt0w_reg_level_declare
integer x = 3195
end type

type gb_cond from w_a_reg_m_m3`gb_cond within rpt0w_reg_level_declare
integer width = 2779
integer height = 248
end type

type dw_master from w_a_reg_m_m3`dw_master within rpt0w_reg_level_declare
integer y = 276
integer width = 3438
integer height = 536
string dataobject = "rpt0dw_master_reg_level_declare"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.levelno_t
uf_init(ldwo_SORT)
end event

event dw_master::retrieveend;call super::retrieveend;//Long ll_i
//DateTime ldt_workdt
//
//// Work Date를 YYYY-MM-DD형식으로 보이게..
//For ll_i = 1 To rowcount
//	ldt_workdt = This.Object.workdt[ll_i]
//	This.Object.workdt[ll_i] = Date(ldt_workdt)
//Next
//





end event

event dw_master::clicked;call super::clicked;Long ll_i, ll_rct_detail

ll_rct_detail = dw_detail.RowCount()

For ll_i = 1 To ll_rct_detail
	is_modified[ll_i] = ""   //초기화
Next
end event

event dw_master::ue_select;// Not extend ancestor script
Long ll_selected_row 
Integer li_return, li_ret



ll_selected_row = GetSelectedRow( 0 )

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			ic_levelno_ue_select = dw_master.Object.levelno[ll_selected_row]
//			MessageBox("ic_levelno_ue_select",ic_levelno_ue_select)
			li_ret = Parent.Event ue_save()
			If isnull( li_ret ) or li_ret < 0 then return
		CASE 2
		CASE ELSE
			Return
	END CHOOSE
		
end If
	
dw_detail.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If

dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If

//버튼활성화
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")

end event

type dw_detail from w_a_reg_m_m3`dw_detail within rpt0w_reg_level_declare
integer y = 1052
integer width = 3438
integer height = 588
string dataobject = "rpt0dw_detail_reg_level_declare"
end type

event dw_detail::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_levelno, ls_seq
Long ll_row
String ls_where

If al_select_row = 0 Then
	Return
Else
	ls_levelno = String(dw_master.Object.levelno[al_select_row])
	If IsNull(ls_levelno) Then ls_levelno = ""
//	ls_seq = String(dw_master.Object.seq[al_select_row])
//	If IsNull(ls_seq) Then ls_seq = ""
END IF 

ls_where = ""

If ls_levelno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.levelno = to_number('" + ls_levelno + "','999999') "
End If

//If ls_seq <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += " level_dec.seq = to_number('" + ls_seq + "','999') "
//End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100,Title,"Retrieve() : dw_detail")
	ai_return = -1
	Return 
End If

end event

event dw_detail::ue_init();call super::ue_init;//// 그룹코드를 선택하면 그 그룹에 해당하는 그룹명을 선택할 수 있게 dddw를 다시 Retrieve 한다.
//
//DataWindowChild gl1c_dddw_syscod2t_glgrcd_with_arg
//Long ll_row
//String ls_groupck, ls_groupcod
//Integer li_rtncode
//
//li_rtncode = dw_detail.GetChild('groupcod', gl1c_dddw_syscod2t_glgrcd_with_arg)
//If li_rtncode = -1 Then MessageBox("Error", "Not a DataWindowChild")
//
//// Establish the connection if not already connected
//CONNECT USING SQLCA;
//
//// Set the transaction object for the child
//gl1c_dddw_syscod2t_glgrcd_with_arg.SetTransObject(SQLCA)
//
//// Populate the child with values
//ls_groupck = ""
//Choose Case ls_groupck
//	Case "1"
//		ll_row = gl1c_dddw_syscod2t_glgrcd_with_arg.Retrieve("GLGRCD1")
//	Case "2"
//		ll_row = gl1c_dddw_syscod2t_glgrcd_with_arg.Retrieve("GLGRCD2")
//	Case "3"
//		ll_row = gl1c_dddw_syscod2t_glgrcd_with_arg.Retrieve("GLGRCD3")
//	Case "4"
//		ll_row = gl1c_dddw_syscod2t_glgrcd_with_arg.Retrieve("GLGRCD4")
//	Case "5"
//		ll_row = gl1c_dddw_syscod2t_glgrcd_with_arg.Retrieve("GLGRCD5")
//End Choose
//
//
//If ll_row = 0 Then
//	gl1c_dddw_syscod2t_glgrcd_with_arg.InsertRow(0)
//End If

//Level HelpWindow 관련
This.idwo_help_col[1] = This.Object.levelno1
This.is_help_win[1] = "rpt0w_hlp_level"
This.is_data[1] = "CloseWithReturn"

This.idwo_help_col[2] = This.Object.levelno2
This.is_help_win[2] = "rpt0w_hlp_level"
This.is_data[2] = "CloseWithReturn"

This.idwo_help_col[3] = This.Object.from_rptcod
This.is_help_win[3] = "rpt0w_hlp_rptcode"
This.is_data[3] = "CloseWithReturn"

This.idwo_help_col[4] = This.Object.to_rptcod
This.is_help_win[4] = "rpt0w_hlp_rptcode"
This.is_data[4] = "CloseWithReturn"

end event

event dw_detail::doubleclicked;// Not extend ancestor script
Int li_i
String ls_type, ls_name
Window lw_help
String ls_wkcod
String ls_groupck

Choose Case dwo.Name
	Case "levelno1", "levelno2", "from_rptcod", "to_rptcod"

		ls_wkcod = Trim(dw_detail.Object.wkcod[row])
		
			If ls_wkcod = "C" Then    //Modify: wkcod(구분)가 Calculate Level인 경우에만....
			
					//ancestor script
			
					iu_cust_help.il_data[1] = row  // clicked row  , value using at w_a_hlp.il_clicked_row
					
					//kenn : 1999-05-25 Modify *******************
					//DW내의 button일 경우를 고려(Column만 Help)
					ls_name = dwo.Name
					If LeftA(Upper(ls_name), 2) = "B_" Then Return
					ls_type = dwo.Type
					If ls_type <> "column" Then Return
					//*********************************************
					
					For li_i = 1 To 2           //ii_help_col_no   ************ Modify **************
						If idwo_help_col[li_i].Name = ls_name Then
							iu_cust_help.idw_data[1] = this
					
							If UpperBound( is_data ) = 0 Then
								iu_cust_help.is_data[1]='' 
							Else			
								iu_cust_help.is_data[] = is_data[]
							End If
						
							iu_cust_help.is_temp[] = is_temp[]	
							
							OpenwithParm(lw_help, iu_cust_help, is_help_win[li_i]  )
					//		is_data[] = iu_cust_help.is_data[]   Absolutely not use for closewithReturn
					//		is_data2[] = iu_cust_help.is_data2[]
					//		is_data3[] = iu_cust_help.is_data3[]		
					//		is_data4[] = iu_cust_help.is_data3[]		
					//		
					//		is_data_nm[] = iu_cust_help.is_data_nm[]
					
							Exit
						End If
					Next
					
			
					// add script
					Choose Case dwo.Name
						
						Case "levelno1"
							If iu_cust_help.ib_data[1] Then
								This.Object.levelno1[row] = iu_cust_help.ic_data[1]
								This.Object.levelno1_name[row] = iu_cust_help.ic_data[1]
							End If
							
						Case "levelno2"
							If iu_cust_help.ib_data[1] Then
								This.Object.levelno2[row] = iu_cust_help.ic_data[1]
								This.Object.levelno2_name[row] = iu_cust_help.ic_data[1]		
							End If
					End Choose
					//
			
			End If              //Modify: If문 끝
		
		If ls_wkcod = "A" Or ls_wkcod = "S" Then    //Modify: wkcod(구분)가 Calculate Level가 아닌 경우에만....
		
				//ancestor script
		
				iu_cust_help.il_data[1] = row  // clicked row  , value using at w_a_hlp.il_clicked_row
				
				//kenn : 1999-05-25 Modify *******************
				//DW내의 button일 경우를 고려(Column만 Help)
				ls_name = dwo.Name
				If LeftA(Upper(ls_name), 2) = "B_" Then Return
				ls_type = dwo.Type
				If ls_type <> "column" Then Return
				//*********************************************
				
				For li_i = 3 To 4    //ii_help_col_no ************ Modify *************
					If idwo_help_col[li_i].Name = ls_name Then
						iu_cust_help.idw_data[1] = this
				
						If UpperBound( is_data ) = 0 Then
							iu_cust_help.is_data[1]='' 
						Else			
							iu_cust_help.is_data[] = is_data[]
						End If
					
						iu_cust_help.is_temp[] = is_temp[]	
						
						OpenwithParm(lw_help, iu_cust_help, is_help_win[li_i]  )
				//		is_data[] = iu_cust_help.is_data[]   Absolutely not use for closewithReturn
				//		is_data2[] = iu_cust_help.is_data2[]
				//		is_data3[] = iu_cust_help.is_data3[]		
				//		is_data4[] = iu_cust_help.is_data3[]		
				//		
				//		is_data_nm[] = iu_cust_help.is_data_nm[]
				
						Exit
					End If
				Next
				
		
				// add script
				Choose Case dwo.Name
					
					Case "from_rptcod"
						If iu_cust_help.ib_data[1] Then
							This.Object.from_rptcod[row] = iu_cust_help.is_data[1]
							This.Object.from_rptname[row] = iu_cust_help.is_data[1]
						End If
						
					Case "to_rptcod"
						If iu_cust_help.ib_data[1] Then
							This.Object.to_rptcod[row] = iu_cust_help.is_data[1]
							This.Object.to_rptname[row] = iu_cust_help.is_data[1]
						End If
				End Choose
				//
		
		End If              //Modify: If문 끝
		
End Choose

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;Long li_rtncode, ll_row
String ls_groupck, ls_groupcod
DEC{0} lc_levelno1, lc_levelno2
dec  lc_factor
String ls_opcod, ls_codiv, ls_from_rptcod, ls_to_rptcod, ls_from_rptname, ls_to_rptname
String ls_levelno1_flag
Boolean lb_from_rptcod, lb_to_rptcod
String ls_groupcod_name, ls_levelno1_name, ls_levelno2_name

//dw_detail의 wkcod(구분)가 A,S에서 C로 상호 바뀔때 protect되는 컬럼의 기존 자료를 삭제(Null값을 준다)..

Choose Case dwo.Name
	Case "wkcod"
		If IsNull(data) Then data = ""
		If data = "A" Or data = "S" Then   //dw_detail의 첫번째 열만 활성화되는 경우
			
			lc_levelno1 = dw_detail.Object.levelno1[row]
			SetNull(lc_levelno1)
			dw_detail.Object.levelno1[row] = lc_levelno1
			dw_detail.Object.levelno1_name[row] = lc_levelno1
			
			ls_opcod = dw_detail.Object.opcod[row]
			SetNull(ls_opcod)
			dw_detail.Object.opcod[row] = ls_opcod
			
			lc_levelno2 = dw_detail.Object.levelno2[row]
			SetNull(lc_levelno2)
			dw_detail.Object.levelno2[row] = lc_levelno2
			dw_detail.Object.levelno2_name[row] = lc_levelno2
			
			lc_factor = dw_detail.Object.factor[row]
			SetNull(lc_factor)
			dw_detail.Object.factor[row] = lc_factor
			
		ElseIf data = "C" Then             //  dw_detail의 두번째 열만 활성화되는 경우
			
			ls_from_rptcod = dw_detail.Object.from_rptcod[row]
			SetNull(ls_from_rptcod)
			dw_detail.Object.from_rptcod[row] = ls_from_rptcod
			dw_detail.Object.from_rptname[row] = ls_from_rptcod
			
			ls_to_rptcod = dw_detail.Object.to_rptcod[row]
			SetNull(ls_to_rptcod)
			dw_detail.Object.to_rptcod[row] = ls_to_rptcod
			dw_detail.Object.to_rptname[row] = ls_to_rptcod
			
		End If
		
End Choose

// Level 1 또는 Level 2를 Edit시 해당 levelno가 존재하는지 체크하고 Level의 Description을 넣어준다.

Choose Case dwo.Name
	Case "levelno1"
		lc_levelno1 = dw_detail.Object.levelno1[row]
		
		If lc_levelno1 = 0 Then //화면상에선 지워지나 내부적으로 0의 값을 가져서....
		
			SetNull(lc_levelno1)                          
			dw_detail.Object.levelno1[row] = lc_levelno1  
			This.Object.levelno1_name[row] = lc_levelno1           
			Return 1   /////////////////
		ElseIf lc_levelno1 > 0 Then
	
			If rpt0fb_levelno_check(lc_levelno1) Then //levelno가 있다면 Description을 보여준다.
				This.Object.levelno1_name[row] = lc_levelno1
			Else  //levelno가 없다면 다시 입력하게한다.
//				f_msg_usr_err(1100,Title,"Level 1에 입력한 Level No(" + String(lc_levelno1) + ")가 존재하지 않습니다.")
				SetNull(lc_levelno1)
				dw_detail.SetFocus()
				dw_detail.SetColumn("levelno1")
				dw_detail.ScrollToRow(row)
				dw_detail.Object.levelno1[row] = lc_levelno1
				This.Object.levelno1_name[row] = lc_levelno1
				Return 1
			End If
			
		End If
		
	Case "levelno2"
		lc_levelno2 = dw_detail.Object.levelno2[row]
		lc_factor = dw_detail.Object.factor[row]
		
		If IsNull(lc_factor) or lc_factor = 0 Then
			
			If lc_levelno2 = 0 Then //화면상에선 안보이나 내부적으로 0의 값을 가져서....
				
				SetNull(lc_levelno2)
				dw_detail.Object.levelno2[row] = lc_levelno2
				This.Object.levelno2_name[row] = lc_levelno2
				Return 1   //////////////////
			ElseIf lc_levelno2 > 0 Then
		
				If rpt0fb_levelno_check(lc_levelno2) Then  //levelno가 있다면 Description을 보여준다.
					This.Object.levelno2_name[row] = lc_levelno2
				Else  //levelno가 없다면 다시 입력하게한다.
//					f_msg_usr_err(1100,Title,"Level 2에 입력한 Level No(" + String(lc_levelno2) + ")가 존재하지 않습니다.")
					dw_detail.SetFocus()
					dw_detail.SetColumn("levelno2")
					dw_detail.ScrollToRow(row)
					SetNull(lc_levelno2)
					dw_detail.Object.levelno2[row] = lc_levelno2
					This.Object.levelno2_name[row] = lc_levelno2
					Return 1
				End If
				
			End If
			
		End If
	
End Choose

//계정코드를 Edit할 때 Erorr Check와 계정명을 바꿔준다.
Choose Case dwo.Name
		
	Case "from_rptcod"
		
		ls_from_rptcod = Trim(dw_detail.Object.from_rptcod[row])
		If IsNull(ls_from_rptcod) Then ls_from_rptcod = ""
		
		If ls_from_rptcod = "" Then
			dw_detail.Object.from_rptname[row] = ""
		Else
			ls_from_rptname = rpt0fs_get_rptcodenm(ls_from_rptcod)
			
			If ls_from_rptname <> "" Then  
				dw_detail.Object.from_rptname[row] = ls_from_rptcod
				
			Else      //만약 존재하지 않는 계정코드라면....
			 
				SetNull(ls_from_rptcod)                             
				dw_detail.Object.from_rptcod[row] = ls_from_rptcod   
				dw_detail.Object.from_rptname[row] = ls_from_rptcod   
				dw_detail.SetColumn("from_rptcod")                  
				dw_detail.ScrollToRow(row)                        
				Return 1
			End If
			
		End If
		
	Case "to_rptcod"
		
		ls_to_rptcod = Trim(dw_detail.Object.to_rptcod[row])
		If IsNull(ls_to_rptcod) Then ls_to_rptcod = ""
		
		If ls_to_rptcod = "" Then
			dw_detail.Object.to_rptname[row] = ""
		Else
			ls_to_rptname = rpt0fs_get_rptcodenm(ls_to_rptcod)
			
			If ls_to_rptname <> "" Then   
				dw_detail.Object.to_rptname[row] = ls_to_rptcod
			Else       //만약 존재하지 않는 계정코드라면....
				
				SetNull(ls_to_rptcod)                              
				dw_detail.Object.to_rptcod[row] = ls_to_rptcod       
				dw_detail.Object.to_rptname[row] = ls_to_rptcod       				
				dw_detail.SetColumn("to_rptcod")                  
				dw_detail.ScrollToRow(row)                      
				Return 1
			End If
			
		End If
		
End Choose
end event

event dw_detail::retrieveend;call super::retrieveend;Long ll_rct_detail, ll_i
String ls_from_rptcod, ls_to_rptcod, ls_from_rptname, ls_to_rptname
DEC lc_levelno1, lc_levelno2
String ls_levelno1_name, ls_levelno2_name
String ls_groupck, ls_groupcod, ls_groupcod_name

ll_rct_detail = dw_detail.RowCount()

////계정코드에 대한 계정명을 Retrieve한다.
//For ll_i = 1 To ll_rct_detail
//	ls_from_rptcod = Trim(dw_detail.Object.from_rptcod[ll_i])
//	ls_to_rptcod = Trim(dw_detail.Object.to_rptcod[ll_i])
//	If IsNull(ls_from_rptcod) Then ls_from_rptcod = ""
//	If IsNull(ls_to_rptcod) Then ls_to_rptcod = ""
//	
//	If ls_from_rptcod <> "" Then 
////		ls_from_rptname = gl1fs_get_rptname(ls_from_rptcod)
//		dw_detail.Object.from_rptname[ll_i] = ls_from_rptname
//		dw_detail.SetItemStatus(ll_i, "from_rptname", Primary!, NotModified!)
//	End If
//	
//	If ls_to_rptcod <> "" Then
////		ls_to_rptname = gl1fs_get_rptname(ls_to_rptcod)
//		dw_detail.Object.to_rptname[ll_i] = ls_to_rptname
//		dw_detail.SetItemStatus(ll_i, "to_rptname", Primary!, NotModified!)
//	End If
//Next

////Level No에 대한 Level Description을 Retrieve한다.
//For ll_i = 1 To ll_rct_detail
//	
//	lc_levelno1 = dw_detail.Object.levelno1[ll_i]
//	lc_levelno2 = dw_detail.Object.levelno2[ll_i]
//	
//	If Not IsNull(lc_levelno1) Then
//		ls_levelno1_name = wfs_get_level_description(lc_levelno1)
//		dw_detail.Object.levelno1_name[ll_i] = ls_levelno1_name
//		dw_detail.SetItemStatus(ll_i, "levelno1_name", Primary!, NotModified!)
//	End If
//	
//	If Not IsNull(lc_levelno2) Then
//		ls_levelno2_name = wfs_get_level_description(lc_levelno2)
//		dw_detail.Object.levelno2_name[ll_i] = ls_levelno2_name
//		dw_detail.SetItemStatus(ll_i, "levelno2_name", Primary!, NotModified!)
//	End If
//
//Next
end event

event dw_detail::getfocus;// Not extend ancestor script
//// ue_init 에서 설정되는 아래의 값에 따라 데이타윈도우별 
//// 추가삭제 처리를 조정케 한다. 
//
//If ib_insert Then
//	p_insert.Event ue_enable()
//else
//	p_insert.Event ue_disable()
//end If
//
//
//If ib_delete Then
//	p_delete.Event ue_enable()
//else
//	p_delete.Event ue_disable()
//end If




end event

event dw_detail::constructor;call super::constructor;//SetRowFocusIndicator(Hand!)
end event

event dw_detail::itemerror;call super::itemerror;Return 1
end event

type p_insert from w_a_reg_m_m3`p_insert within rpt0w_reg_level_declare
integer y = 1668
end type

type p_delete from w_a_reg_m_m3`p_delete within rpt0w_reg_level_declare
integer y = 1668
end type

type p_save from w_a_reg_m_m3`p_save within rpt0w_reg_level_declare
integer y = 1668
end type

type p_reset from w_a_reg_m_m3`p_reset within rpt0w_reg_level_declare
integer y = 1668
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within rpt0w_reg_level_declare
integer y = 844
integer width = 3438
integer height = 176
string dataobject = "rpt0dw_detail2_reg_level_declare"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail2::ue_retrieve;call super::ue_retrieve;String ls_levelno, ls_seq
Long ll_row
String ls_where

If al_select_row = 0 Then
	Return
Else
	ls_levelno = String(dw_master.Object.levelno[al_select_row])
	If IsNull(ls_levelno) Then ls_levelno = ""
//	ls_seq = String(dw_master.Object.seq[al_select_row])
//	If IsNull(ls_seq) Then ls_seq = ""
END IF 


ls_where = ""

If ls_levelno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.levelno = to_number('" + ls_levelno + "','999999') "
End If

//If ls_seq <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += " level_dec.seq = to_number('" + ls_seq + "','999') "
//End If

dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100,Title,"Retrieve() : dw_detail2")
	ai_return = -1
	Return 
End If

end event

event dw_detail2::getfocus;//not extend ancestor script
//// ue_init 에서 설정되는 아래의 값에 따라 데이타윈도우별 
//// 추가삭제 처리를 조정케 한다. 
//
//If ib_insert Then
//	p_insert.Event ue_enable()
//else
//	p_insert.Event ue_disable()
//end If
//
//
//If ib_delete Then
//	p_delete.Event ue_enable()
//else
//	p_delete.Event ue_disable()
//end If
//
//
end event

event dw_detail2::itemchanged;call super::itemchanged;Long ll_i, ll_rct_detail
DEC lc_levelno
String ls_description

ll_rct_detail = dw_detail.RowCount()

Choose Case dwo.Name
		
	Case "levelno"
	
		lc_levelno = dw_detail2.Object.levelno[1]
		
		//dw_detail2의 항목을 dw_detail에서 Update할 수 있도록 준비...
		For ll_i = 1 To ll_rct_detail
			dw_detail.Object.levelno[ll_i] = lc_levelno	
		Next
		
	Case "description"
		
		ls_description = dw_detail2.Object.description[1]
		
		//dw_detail2의 항목을 dw_detail에서 Update할 수 있도록 준비...
		For ll_i = 1 To ll_rct_detail
			dw_detail.Object.description[ll_i] = ls_description	
		Next
		
End Choose
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within rpt0w_reg_level_declare
integer y = 812
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within rpt0w_reg_level_declare
integer y = 1020
end type

