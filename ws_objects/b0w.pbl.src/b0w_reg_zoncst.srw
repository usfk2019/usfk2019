$PBExportHeader$b0w_reg_zoncst.srw
$PBExportComments$[ceusee] 대역별 요율 등록
forward
global type b0w_reg_zoncst from w_a_reg_m
end type
type cb_load from commandbutton within b0w_reg_zoncst
end type
type p_saveas from u_p_saveas within b0w_reg_zoncst
end type
type p_fileread from u_p_fileread within b0w_reg_zoncst
end type
end forward

global type b0w_reg_zoncst from w_a_reg_m
integer width = 3013
integer height = 1836
event ue_fileread ( )
event ue_saveas ( )
cb_load cb_load
p_saveas p_saveas
p_fileread p_fileread
end type
global b0w_reg_zoncst b0w_reg_zoncst

type variables
String is_priceplan		//Item에 해당하는 Price plan
DataWindowChild idc_itemcod
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
FROM arezoncod
WHERE zoncod like :as_zoncod
  AND pricecod = :as_priceplan;

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

on b0w_reg_zoncst.create
int iCurrent
call super::create
this.cb_load=create cb_load
this.p_saveas=create p_saveas
this.p_fileread=create p_fileread
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_load
this.Control[iCurrent+2]=this.p_saveas
this.Control[iCurrent+3]=this.p_fileread
end on

on b0w_reg_zoncst.destroy
call super::destroy
destroy(this.cb_load)
destroy(this.p_saveas)
destroy(this.p_fileread)
end on

event open;call super::open;/*--------------------------------------------------------------------------
	Name	:	b0w_reg_zoncst
	Desc.	:	대역별 표준요율 등록
	Ver.	: 	1.0
	Date	: 	2002.09.26
	Programer: Choi Bo Ra(ceusee)
----------------------------------------------------------------------------*/
cb_load.enabled = False
end event

event ue_extra_insert;String ls_filter, ls_itemcod
Long ll_row


dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("zoncod")

//Setting
dw_detail.object.itemcod[al_insert_row] = Trim(dw_cond.object.itemcod[1])
dw_detail.object.pricecod[al_insert_row] = Trim(dw_cond.object.priceplan[1])
dw_detail.object.opendt[al_insert_row] = Date(fdt_get_dbserver_now())
dw_detail.object.roundflag[al_insert_row] = "U"

ll_row = dw_detail.GetChild("itemcod", idc_itemcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = "priceplanmst_priceplan = '" + Trim(dw_cond.object.priceplan[1]) + "' "
idc_itemcod.SetFilter(ls_filter)			//Filter정함
idc_itemcod.Filter()
idc_itemcod.SetTransObject(SQLCA)
ll_row =idc_itemcod.Retrieve() 

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
ElseIf ll_row > 0 Then			//첫row의 값을 Setting한다.
	ls_itemcod = idc_itemcod.GetItemString(1, "itemmst_itemcod")
	dw_detail.object.itemcod[al_insert_row] = ls_itemcod
End if

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0

end event

event ue_ok();//조회
String ls_itemcod, ls_priceplan, ls_zoncod, ls_where
Long ll_row

ls_itemcod = Trim(dw_cond.object.itemcod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_zoncod = Trim(dw_cond.object.zoncod[1])
If IsNull(ls_itemcod) Then ls_itemcod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_zoncod) Then ls_zoncod = ""

//필수 항목 Check
If ls_priceplan = "" Then
	f_msg_info(200, Title,"가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
   Return
End If

//retrieve
ls_where = ""
If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "zoncod = '" + ls_zoncod + "' "
End If	

If ls_itemcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "itemcod = '" + ls_itemcod + "' "
End If	


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(ls_priceplan)
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_extra_save;//Save
Long ll_row, ll_rows, ll_findrow
long ll_i, ll_zoncodcnt
String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan
String ls_date, ls_sort
Dec lc_data, lc_frpoint, lc_Ofrpoint

String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt
Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
Boolean lb_addX, lb_notExist
Constant Integer li_MAXTMKIND = 3

If dw_detail.RowCount()  = 0 Then Return 0

//  대역/시간대코드/개시일자
ls_Ozoncod = ""
ls_Otmcod  = ""
ls_tmcodX = ""
li_tmcodcnt = 0
li_cnt_tmkind = 0

//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
ls_priceplan = Trim(dw_cond.Object.priceplan[1])
li_return = wfl_get_arezoncod(ls_priceplan, ls_zoncod, ls_arezoncod[])
If li_return < 0 Then Return -2

ll_rows = dw_detail.RowCount()
If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0


//정리하기 위해서 Sort
dw_detail.SetRedraw(False)
ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

For ll_row = 1 To ll_rows
	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
	If IsNull(ls_zoncod) Then ls_zoncod = ""
	If IsNull(ls_opendt) Then ls_opendt = ""
	If IsNull(ls_tmcod) Then ls_tmcod = ""
    //필수 항목 check 
	If ls_zoncod = "" Then
		f_msg_usr_err(200, Title, "대역")
		dw_detail.SetColumn("zoncod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2
	End If
	
	If ls_opendt = "" Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetColumn("opendt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2
	End If
	
	If ls_tmcod = "" Then
		f_msg_usr_err(200, Title, "시간대")
		dw_detail.SetColumn("tmcod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2
	End If

	//시작Point - khpark 추가 -
//	lc_frpoint = dw_detail.Object.frpoint[ll_row]
//	If IsNull(lc_frpoint) Then dw_detail.Object.frpoint[ll_row] = 0
//
//	If dw_detail.Object.frpoint[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
//		dw_detail.SetColumn("frpoint")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		Return -2
//	End If
	
	//숫자항목은 Null이면 0으로 저장
	//기본료/추가료/기본시간단위/추가시간단위/기본시간범위
	lc_data = dw_detail.Object.basamt[ll_row]
	If IsNull(lc_data) Then dw_detail.Object.basamt[ll_row] = 0
	lc_data = dw_detail.Object.addamt[ll_row]
	If IsNull(lc_data) Then dw_detail.Object.addamt[ll_row] = 0
	lc_data = dw_detail.Object.bassec[ll_row]
	If IsNull(lc_data) Then dw_detail.Object.bassec[ll_row] = 0
	lc_data = dw_detail.Object.addsec[ll_row]
	If IsNull(lc_data) Then dw_detail.Object.addsec[ll_row] = 0
	lc_data = dw_detail.Object.stdsec[ll_row]
	If IsNull(lc_data) Then dw_detail.Object.stdsec[ll_row] = 0
	
	
	If dw_detail.Object.addsec[ll_row] = 0 Then
		f_msg_usr_err(200, Title, "추가시간")
		dw_detail.SetColumn("addsec")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2
	End If

	// 1 zoncod가 같으면 
	If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
		
		//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
		If MidA(ls_tmcod, 2, 1) <> MidA(ls_Otmcod, 2, 1) Then
			f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
			dw_detail.SetColumn("tmcod")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
	
		ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
			li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
		End If	// 2 close						
	
	// 1 else	
	Else
		//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
		If lb_notExist = False Then
			lb_notExist = True
			For ll_i = 1 To UpperBound(ls_arezoncod)
				If ls_arezoncod[ll_i] = ls_zoncod Then 
					lb_notExist = False
					Exit
				End If
			Next
		End If	 // 3 close	
	  If ls_Ozoncod <>  ls_zoncod Then 
	      ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
	   End If
        
		// 4 zonecod가  바뀌었거나 처음 row 일때
		// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
		If ll_row > 1 Then
			
			If ls_tmcodX <> 'X' and LenA(ls_tmcodX) <> li_MAXTMKIND Then
				f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
				dw_detail.SetColumn("tmcod")
				dw_detail.SetRow(ll_row - 1)
				dw_detail.ScrollToRow(ll_row - 1)
				Return -2
			End If 
			
			li_rtmcnt = -1
			//이미 Select됐된 시간대인지 Check
			For li_i = 1 To li_cnt_tmkind
				If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
			Next
		
			// 5 tmcod에 해당 pricecod 별로 tmcod check
			If li_rtmcnt < 0 Then
				li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
				If li_return < 0 Then Return -2
				
				li_cnt_tmkind += 1
				ls_tmkind[li_cnt_tmkind,1] = LeftA(ls_Otmcod, 2)
				ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
			End If // 5 close
			
			//누락된 시간대코드가 없는지 Check
			If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
				f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
				dw_detail.SetColumn("tmcod")
				dw_detail.SetRow(ll_row - 1)
				dw_detail.ScrollToRow(ll_row - 1)
				Return -2
			End If
	
			li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
		    ls_tmcodX = ""
		Else // 4 else	 
			li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
			
		End If // 4 close
	End If // 1 close ls_Ozoncod = ls_zoncod 조건 
	
	// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
	If LeftA(ls_tmcod, 1) = 'X' Then
		If LenA(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
			f_msg_usr_err(9000, Title, "모든 시간대는 다른 시간대랑 같이 사용 할 수 없습니다." )
			dw_detail.SetColumn("tmcod")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		ElseIf LenA(ls_tmcodX) = 0 Then 
			ls_tmcodX += LeftA(ls_tmcod, 1)
		End If
	Else
		lb_addX = True
		For li_i = 1 To LenA(ls_tmcodX)
			If MidA(ls_tmcodX, li_i, 1) = LeftA(ls_tmcod, 1) Then lb_addX = False
		Next
		If lb_addX Then ls_tmcodX += LeftA(ls_tmcod, 1)
	End If				
	
	ll_findrow = 0
//	If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
//		
//		ll_findrow = dw_detail.Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
//		                            "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
//									"' and frpoint = 0", 1, ll_rows)
//
//		If ll_findrow <= 0 Then
//			f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
//			dw_detail.SetColumn("frpoint")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			return -2
//		End IF
//		
//	End IF
		
	ls_Ozoncod = ls_zoncod
	ls_Otmcod  = ls_tmcod
	ls_Oopendt = ls_opendt
Next


// zoncod가 하나만 있을경우 
If LenA(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
	f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
							
	dw_detail.SetFocus()
	Return -2
End If

li_rtmcnt = -1
//이미 Select됐된 시간대인지 Check
For li_i = 1 To li_cnt_tmkind
	If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
Next

//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
If li_rtmcnt < 0 Then
	li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
	If li_return < 0 Then Return -2
End If

//누락된 시간대코드가 없는지 Check
If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
	f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
						
	dw_detail.SetColumn("tmcod")
	dw_detail.SetRow(ll_rows)
	dw_detail.ScrollToRow(ll_rows)
	Return -2
End If

//같은 시간대  code error 처리
ls_Ozoncod = ""
ls_Otmcod  = ""
ls_Oopendt = ""
//lc_Ofrpoint = -1
For ll_row = 1 To ll_rows
	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
	If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod  Then
		f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
//		dw_detail.SetColumn("frpoint")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -2
	End If
	ls_Ozoncod = ls_zoncod
	ls_Oopendt = ls_opendt
	ls_Otmcod = ls_tmcod
Next		

If lb_notExist Then
	f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 대역입니다." )
	//Return -2
End If

If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
	f_msg_info(9000, Title, "정의된 대역에 대해서 요율을 등록해야 합니다.")
	//Return -2
End If


dw_detail.SetRedraw(False)
ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

//Update Log
For ll_row = 1  To ll_rows
	If dw_detail.GetItemStatus(ll_row, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_row] = gs_user_id
		dw_detail.object.updtdt[ll_row] = fdt_get_dbserver_now()
	End If
Next

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1

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

cb_load.Enabled = False
Return 0
end event

event type integer ue_reset();call super::ue_reset;cb_load.Enabled = False
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

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_zoncst
integer x = 41
integer y = 40
integer width = 2235
integer height = 244
string dataobject = "b0dw_cnd_reg_zoncst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Long ll_row
String ls_filter, ls_itemcod
DataWindowChild ldc

If dwo.name = "priceplan" Then
	
	This.object.itemcod[1] = ""
	//해당 priceplan에 대한 itemcod
	ll_row = This.GetChild("itemcod", ldc)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	ls_filter = "priceplanmst_priceplan = '" + data + "' "

	ldc.SetFilter(ls_filter)			//Filter정함
	ldc.Filter()
	ldc.SetTransObject(SQLCA)
	ll_row =ldc.Retrieve() 
	
   If ll_row < 0 Then 				//디비 오류 
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -2
   End If
End If
end event

type p_ok from w_a_reg_m`p_ok within b0w_reg_zoncst
integer x = 2341
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b0w_reg_zoncst
integer x = 2638
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_zoncst
integer x = 23
integer width = 2267
integer height = 304
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_zoncst
integer y = 1600
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_zoncst
integer y = 1600
end type

type p_save from w_a_reg_m`p_save within b0w_reg_zoncst
integer y = 1600
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_zoncst
integer x = 27
integer y = 312
integer width = 2917
integer height = 1248
string dataobject = "b0dw_reg_zoncst"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;DataWindowChild ldc
Long ll_row
String ls_filter

p_saveas.TriggerEvent("ue_enable")
p_fileread.TriggerEvent("ue_enable")

If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
   dw_cond.Enabled = False
	cb_load.Enabled = True
Else							//자료가 있으면 표준대역을 불러올 수 없다.
	cb_load.Enabled = False
End If

//Format 지정
String ls_type, ls_priceplan
Integer li_cnt

ls_priceplan = Trim(dW_cond.object.priceplan[1])

//Format 지정
Select decpoint
Into 	:ls_type
From priceplanmst
where priceplan = :ls_priceplan;

If ls_type = "0" Then
	dw_detail.object.basamt.Format = "#,##0"
	dw_detail.object.addamt.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_detail.object.basamt.Format = "#,##0.0"
	dw_detail.object.addamt.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_detail.object.basamt.Format = "#,##0.00"
	dw_detail.object.addamt.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_detail.object.basamt.Format = "#,##0.000"
	dw_detail.object.addamt.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_detail.object.basamt.Format = "#,##0.0000"
	dw_detail.object.addamt.Format = "#,##0.0000"
End If

//해당 priceplan에 대한 tmcod만 가져오게 
ll_row = dw_detail.GetChild("tmcod", ldc)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = "tmcod_pricecod = '" + ls_priceplan + "' "
ldc.SetFilter(ls_filter)			//Filter정함
ldc.Filter()
ldc.SetTransObject(SQLCA)
ll_row =ldc.Retrieve() 

ll_row = dw_detail.GetChild("itemcod", idc_itemcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = "priceplanmst_priceplan = '" + ls_priceplan + "' "
idc_itemcod.SetFilter(ls_filter)			//Filter정함
idc_itemcod.Filter()
idc_itemcod.SetTransObject(SQLCA)
ll_row =idc_itemcod.Retrieve() 


If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
Else
	dw_detail.SetColumn("tmcod")	//찾았을 경우 적용이 빨리 안되서
	dw_detail.SetColumn("zoncod")
End If
end event

event dw_detail::itemchanged;call super::itemchanged;//기본시간이 변화면 기본시간 범위도 변하기.
If dwo.name = "bassec" Then
	This.object.stdsec[row] = Integer(data)
End If

end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_zoncst
integer x = 1065
integer y = 1600
end type

type cb_load from commandbutton within b0w_reg_zoncst
integer x = 2341
integer y = 184
integer width = 581
integer height = 112
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "요금Copy"
end type

event clicked;//해당 고객의 
String ls_priceplan
Long ll_row


ls_priceplan = Trim(dw_cond.object.priceplan[1])//가격정책

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "표준요금 Load"
iu_cust_msg.is_grp_name = "통화서비스 요율 관리"
iu_cust_msg.is_data[1] = ls_priceplan
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.idw_data[1] = dw_detail

//Open
OpenWithParm(b0w_inq_zoncst_popup, iu_cust_msg)  //청구 윈도우 연다.

Return 0 
end event

type p_saveas from u_p_saveas within b0w_reg_zoncst
integer x = 1467
integer y = 1600
boolean bringtotop = true
boolean originalsize = false
end type

type p_fileread from u_p_fileread within b0w_reg_zoncst
integer x = 1774
integer y = 1600
boolean bringtotop = true
boolean originalsize = false
end type

