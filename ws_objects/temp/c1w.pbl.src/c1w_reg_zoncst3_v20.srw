﻿$PBExportHeader$c1w_reg_zoncst3_v20.srw
$PBExportComments$[ohj] 홀세일 대역별 요율 등록 v20
forward
global type c1w_reg_zoncst3_v20 from w_a_reg_m
end type
type cb_load from commandbutton within c1w_reg_zoncst3_v20
end type
type p_saveas from u_p_saveas within c1w_reg_zoncst3_v20
end type
type p_fileread from u_p_fileread within c1w_reg_zoncst3_v20
end type
type hpb_1 from hprogressbar within c1w_reg_zoncst3_v20
end type
type cb_enddt from commandbutton within c1w_reg_zoncst3_v20
end type
end forward

global type c1w_reg_zoncst3_v20 from w_a_reg_m
integer width = 3643
integer height = 1828
event ue_fileread ( )
event ue_saveas ( )
cb_load cb_load
p_saveas p_saveas
p_fileread p_fileread
hpb_1 hpb_1
cb_enddt cb_enddt
end type
global c1w_reg_zoncst3_v20 c1w_reg_zoncst3_v20

type variables
String is_priceplan		//Item에 해당하는 Price plan
String is_svccod_control, is_svctype[]
DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wfl_get_arezoncod1 (string as_svccod, string as_priceplan, string as_zoncod, ref string as_arezoncod[])
public function integer wfl_get_arezoncod (string as_svccod, string as_priceplan, string as_zoncod, ref string as_arezoncod[])
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

//dw_detail.Reset()
//ll_row= dw_detail.RowCount()
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

public function integer wfl_get_arezoncod1 (string as_svccod, string as_priceplan, string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE (svccod    = :as_svccod
  AND priceplan  = :as_priceplan)
   OR (svccod    = :as_svccod
  AND priceplan  = 'ALL')
  AND zoncod like :as_zoncod;

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

public function integer wfl_get_arezoncod (string as_svccod, string as_priceplan, string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE svccod    = :as_svccod
   OR priceplan = :as_priceplan
  AND zoncod like :as_zoncod;

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

on c1w_reg_zoncst3_v20.create
int iCurrent
call super::create
this.cb_load=create cb_load
this.p_saveas=create p_saveas
this.p_fileread=create p_fileread
this.hpb_1=create hpb_1
this.cb_enddt=create cb_enddt
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_load
this.Control[iCurrent+2]=this.p_saveas
this.Control[iCurrent+3]=this.p_fileread
this.Control[iCurrent+4]=this.hpb_1
this.Control[iCurrent+5]=this.cb_enddt
end on

on c1w_reg_zoncst3_v20.destroy
call super::destroy
destroy(this.cb_load)
destroy(this.p_saveas)
destroy(this.p_fileread)
destroy(this.hpb_1)
destroy(this.cb_enddt)
end on

event open;call super::open;/*--------------------------------------------------------------------------
	Name	:	c1w_reg_zoncst3_v20
	Desc.	:	대역별 표준요율 등록(wholesale)
	Ver.	: 	1.0
	Date	: 	2006.01.13
	Programer: oh hye jin
----------------------------------------------------------------------------*/
String ls_tmp, ls_desc, ls_ref_desc, ls_temp, ls_filter
Long   li_rc
DataWindowChild ldwc_svccod

cb_load.enabled = False
cb_enddt.enabled = False
dw_cond.Object.parttype[1] = "S"

dw_cond.Object.priceplan.Visible   = 0
dw_cond.Object.priceplan_t.Visible = 0
dw_cond.Object.svccod.Visible      = 1
dw_cond.Object.svccod_t.Visible    = 1		

//홀세일정산:svctype(Inbound;outbound)  3;4
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("C1", "C231", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_svctype[])

//기본요율 소숫점자릿수
ls_tmp = fs_get_control("B1", "Z100" , ls_desc)
is_svccod_control = fs_get_control("00", "Z150" , ls_desc)
hpb_1.position = 0

li_rc = dw_cond.GetChild("svccod", ldwc_svccod)
If li_rc < 0 Then
	f_msg_usr_err(9000, Title, "GetChild : svccod")
	Return
End If

ls_filter = " svctype in ('"+ is_svctype[1]+"','"+is_svctype[2]+"')"
ldwc_svccod.SetFilter(ls_filter)
ldwc_svccod.Filter()

ldwc_svccod.SetTransObject(SQLCA)

li_rc = ldwc_svccod.Retrieve()
If li_rc < 0 Then
	f_msg_usr_err(9000, Title, "svccod Retrieve()")
	Return
End If	




end event

event type integer ue_extra_insert(long al_insert_row);String ls_filter, ls_parttype, ls_priceplan, ls_itemcod, ls_svccod
Long ll_row

dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)

dw_detail.SetReDraw(False)

ls_parttype = Trim(dw_cond.object.parttype[1])

//Setting
//서비스별, 가격정책은 'all'
If ls_parttype = 'S' Then  
	ls_svccod    = fs_snvl(dw_cond.object.svccod[1]   , '')
	ls_priceplan = fs_snvl(dw_cond.object.priceplan[1], '')
	
	dw_detail.object.svccod[al_insert_row]    = ls_svccod
	dw_detail.object.priceplan[al_insert_row] = ls_priceplan

//가격정책, 서비스는  '가격정책에 등록된 서비스
Else  
	ls_priceplan = fs_snvl(dw_cond.object.priceplan[1], '')
	ls_svccod    = fs_snvl(dw_cond.object.svccod[1]   , '')
	 
	dw_detail.object.priceplan[al_insert_row] = ls_priceplan
	dw_detail.object.svccod[al_insert_row]    = ls_svccod
End If

dw_detail.object.opendt[al_insert_row]    = Date(fdt_get_dbserver_now())
dw_detail.object.roundflag[al_insert_row] = "U"

ls_priceplan = Trim(dw_detail.object.priceplan[al_insert_row])

//가격정책별일때 .. 가격정책별 item가져오기
ll_row = dw_detail.GetChild("itemcod", idc_itemcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

If ls_priceplan <> 'ALL' Then
	ls_filter = " priceplan = '" + Trim(dw_cond.object.priceplan[1]) + "' "
	idc_itemcod.SetFilter(ls_filter)			//Filter정함
	idc_itemcod.Filter()
	idc_itemcod.SetTransObject(SQLCA)
	ll_row =idc_itemcod.Retrieve() 

	If ll_row < 0 Then 				//디비 오류 
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -1
	ElseIf ll_row > 0 Then			//첫row의 값을 Setting한다.
		ls_itemcod = idc_itemcod.GetItemString(1, "itemcod")
		dw_detail.object.itemcod[al_insert_row] = ls_itemcod
	End if

//서비스별일때..  서비스별 item가져오기	
Else 
	ls_filter = " svccod = '" + Trim(dw_cond.object.svccod[1]) + "' "
	idc_itemcod.SetFilter(ls_filter)			//Filter정함
	idc_itemcod.Filter()
	idc_itemcod.SetTransObject(SQLCA)
	ll_row =idc_itemcod.Retrieve() 

	If ll_row < 0 Then 				//디비 오류 
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -1
	ElseIf ll_row > 0 Then			//첫row의 값을 Setting한다.
		ls_itemcod = idc_itemcod.GetItemString(1, "itemcod")
		dw_detail.object.itemcod[al_insert_row] = ls_itemcod
	End if
End If

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//dw_detail.object.updt_user[al_insert_row] = gs_user_id
//dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

dw_detail.SetReDraw(True)
dw_detail.SetColumn("zoncod")

Return 0

end event

event ue_ok();//조회
String ls_parttype, ls_priceplan, ls_zoncod, ls_where, ls_svccod, ls_priceplan_zone
Long ll_row, ll_row_1, ll_row_2
DataWindowChild ldc_zoncod, ldc_tmcod, ldc_itemcod

dw_cond.Accepttext()

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
If is_svccod_control = 'Y' Then
	
	ll_row = dw_detail.GetChild("zoncod", ldc_zoncod)
	
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
	ldc_zoncod.SetTransObject(SQLCA)
	
	ls_priceplan_zone = dw_cond.object.priceplan[1]
	
	IF ls_parttype = "S" THEN
		ll_row = ldc_zoncod.Retrieve(ls_svccod,'ALL','%')
	ELSE
		ll_row = ldc_zoncod.Retrieve(ls_svccod,'ALL',ls_priceplan_zone)
	END IF
	
   IF ll_row < 1 Then 
		f_msg_usr_err(9000, Title, "대역코드가 존재하지 않습니다.")
		return
	END IF
	
ElseIf is_svccod_control = 'N' Then
	
	dw_detail.Modify("zoncod.dddw.name=''")
	dw_detail.Modify("zoncod.dddw.DataColumn=''")
	dw_detail.Modify("zoncod.dddw.DisplayColumn=''")

	dw_detail.Modify("zoncod.dddw.name=c1dc_dddw_zoncod")
	dw_detail.Modify("zoncod.dddw.DataColumn='zoncod'")
	dw_detail.Modify("zoncod.dddw.DisplayColumn='zonnm'")	

End If

//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
ll_row = dw_detail.GetChild("tmcod", ldc_tmcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ldc_tmcod.SetTransObject(SQLCA)

IF ls_parttype = "S" THEN
	ll_row = ldc_tmcod.Retrieve(ls_svccod,'ALL','%')
	ELSE
	ll_row = ldc_tmcod.Retrieve(ls_svccod,'ALL',ls_priceplan_zone)
END IF

IF ll_row < 1 Then 
	f_msg_usr_err(9000, Title, "시간대코드가 존재하지 않습니다.")
	return
END IF

//retrieve
If ls_where <> "" Then ls_where += " And "
ls_where += " svccod = '" + ls_svccod + "' "

If ls_where <> "" Then ls_where += " And "
ls_where += " priceplan = '" + ls_priceplan + "' "

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
Long ll_row, ll_rows, ll_findrow, ll_mod, ll_count
long ll_i, ll_zoncodcnt, ll_surrate
String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype, ls_enddt, ls_itemcod
String ls_date, ls_sort, ls_svccod, ls_svccod1, ls_svccod2, ls_are_zoncod
Dec lc_data, lc_frpoint, lc_Ofrpoint

String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt, ls_arezoncod1, ls_arezoncodnm
Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
Boolean lb_addX, lb_notExist
Constant Integer li_MAXTMKIND = 3
Long   ll_tmrange1, ll_unitsec1, ll_tmrange2, ll_unitsec2, ll_tmrange3, ll_unitsec3, ll_tmrange4, ll_unitsec4, ll_tmrange5, ll_unitsec5

String ls_priceplan1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_itemcod1
String ls_priceplan2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_itemcod2
Long   ll_rows1, ll_rows2, i
dw_cond.Accepttext()

If dw_detail.RowCount()  = 0 Then Return 0

//  대역/시간대코드/개시일자
ls_Ozoncod = ""
ls_Otmcod  = ""
ls_tmcodX = ""
li_tmcodcnt = 0
li_cnt_tmkind = 0

//해당 priceplan 찾기
ls_svccod    = dw_cond.object.svccod[1] 
ls_parttype  = Trim(dw_cond.Object.parttype[1])
/////////////////////////////////////////////////////////////////////////
//start 서비스코드와 자격정책에 따라 arecod를 찾음 jwlee - 2005.11.16
If ls_parttype = "S" Then
	ls_priceplan = 'ALL'
//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
   li_return = wfl_get_arezoncod(ls_svccod, ls_priceplan, ls_zoncod, ls_arezoncod[])
Else
	ls_priceplan = Trim(dw_cond.Object.priceplan[1])
//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
   li_return = wfl_get_arezoncod1(ls_svccod, ls_priceplan, ls_zoncod, ls_arezoncod[])
End If
 
If li_return < 0 Then Return -2

ll_rows = dw_detail.RowCount()
If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0


//정리하기 위해서 Sort
dw_detail.SetRedraw(False)
ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()

hpb_1.visible = true
hpb_1.maxposition = ll_rows

For ll_row = 1 To ll_rows
	hpb_1.position = ll_row
	ll_surrate = dw_detail.Object.surrate[ll_row]
	ls_zoncod  = Trim(dw_detail.Object.zoncod[ll_row])
	ls_opendt  = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
	ls_tmcod   = Trim(dw_detail.Object.tmcod[ll_row])
	ls_itemcod = Trim(dw_detail.Object.itemcod[ll_row])
	ls_enddt   = String(dw_detail.object.enddt[ll_row], 'yyyymmdd')
	If IsNull(ls_zoncod) Then ls_zoncod = ""
	If IsNull(ls_opendt) Then ls_opendt = ""
	If IsNull(ls_tmcod) Then ls_tmcod = ""
	If IsNull(ls_itemcod) Then ls_itemcod = ""
	If IsNull(ls_enddt) Then ls_enddt = ""
	
   //필수 항목 check 
	If ls_zoncod = "" Then
		f_msg_usr_err(200, Title, "대역")
		dw_detail.SetColumn("zoncod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If
	
	If ls_opendt = "" Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetColumn("opendt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	//적용종료일 체크
	If ls_enddt <> "" Then
		If ls_opendt > ls_enddt Then
			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
			dw_detail.setColumn("enddt")
			dw_detail.setRow(ll_row)
			dw_detail.scrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			Return -2
		End If
	End If
	
	If ls_tmcod = "" Then
		f_msg_usr_err(200, Title, "시간대")
		dw_detail.SetColumn("tmcod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If

	//시작Point - khpark 추가 -
	lc_frpoint = dw_detail.Object.frpoint[ll_row]
	If IsNull(lc_frpoint) Then dw_detail.Object.frpoint[ll_row] = 0

	If dw_detail.Object.frpoint[ll_row] < 0 Then
		f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
		dw_detail.SetColumn("frpoint")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	If ll_surrate < 0 Then
		f_msg_usr_err(200, Title, "Surcharge(%)")
		dw_detail.SetColumn("surrate")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	If ls_itemcod = "" Then
		f_msg_usr_err(200, Title, "품목")
		dw_detail.SetColumn("itemcod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	If dw_detail.Object.unitsec[ll_row] = 0 Then
		f_msg_usr_err(200, Title, "기본시간")
		dw_detail.SetColumn("unitsec")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	If dw_detail.Object.unitfee[ll_row] < 0 Then
		f_msg_usr_err(200, Title, "기본요금")
		dw_detail.SetColumn("unitfee")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	If dw_detail.Object.munitsec[ll_row] = 0 Then
		f_msg_usr_err(200, Title, "기본시간(멘트)")
		dw_detail.SetColumn("munitsec")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.Object.DataWindow.HorizontalScrollPosition='10000'
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	If dw_detail.Object.munitfee[ll_row] < 0 Then
		f_msg_usr_err(200, Title, "기본요금(멘트)")
		dw_detail.SetColumn("munitfee")	
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)	
 		dw_detail.Object.DataWindow.HorizontalScrollPosition='10000'				
		dw_detail.SetRedraw(True)
      hpb_1.visible = false
		Return -2
	End If
	
	
	// 2003.10.15 김은미 수정
	// 시간범위 나누기 단위시간하여 나머지 값 발생하면 저장안되도록 막는다.
	ll_tmrange1 = dw_detail.object.tmrange1[ll_row]
	ll_unitsec1 = dw_detail.object.unitsec1[ll_row]
	
	If ll_tmrange1 > 0 And ll_unitsec1 > 0 Then
		ll_mod = Mod(ll_tmrange1, ll_unitsec1)
		
		If ll_mod <> 0 Then
			f_msg_usr_err(9000, Title, "시간범위를 단위시간으로 나누었을때 나머지가 있을 수 없습니다.")
			dw_detail.SetColumn("tmrange1")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			Return -2
		End If
	End If
	
	ll_tmrange2 = dw_detail.object.tmrange2[ll_row]
	ll_unitsec2 = dw_detail.object.unitsec2[ll_row]
	
	If ll_tmrange2 > 0 Or ll_unitsec2 > 0 Then
		ll_mod = Mod(ll_tmrange2, ll_unitsec2)
		
		If ll_mod <> 0 Then
			f_msg_usr_err(9000, Title, "시간범위를 단위시간으로 나누었을때 나머지가 있을 수 없습니다.")
			dw_detail.SetColumn("tmrange2")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			Return -2
		End If
	End If
	
	ll_tmrange3 = dw_detail.object.tmrange3[ll_row]
	ll_unitsec3 = dw_detail.object.unitsec3[ll_row]
	
	If ll_tmrange3 > 0 Or ll_unitsec3 > 0 Then
		ll_mod = Mod(ll_tmrange3, ll_unitsec3)
		
		If ll_mod <> 0 Then
			f_msg_usr_err(9000, Title, "시간범위를 단위시간으로 나누었을때 나머지가 있을 수 없습니다.")
			dw_detail.SetColumn("tmrange3")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			Return -2
		End If
	End If
	
	ll_tmrange4 = dw_detail.object.tmrange4[ll_row]
	ll_unitsec4 = dw_detail.object.unitsec4[ll_row]
	
	If ll_tmrange4 > 0 Or ll_unitsec4 > 0 Then
		ll_mod = Mod(ll_tmrange4, ll_unitsec4)
		
		If ll_mod <> 0 Then
			f_msg_usr_err(9000, Title, "시간범위를 단위시간으로 나누었을때 나머지가 있을 수 없습니다.")
			dw_detail.SetColumn("tmrange4")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			Return -2
		End If
	End If
	
	ll_tmrange5 = dw_detail.object.tmrange5[ll_row]
	ll_unitsec5 = dw_detail.object.unitsec5[ll_row]
	
	If ll_tmrange5 > 0 Or ll_unitsec5 > 0 Then
		ll_mod = Mod(ll_tmrange5, ll_unitsec5)
		
		If ll_mod <> 0 Then
			f_msg_usr_err(9000, Title, "시간범위를 단위시간으로 나누었을때 나머지가 있을 수 없습니다.")
			dw_detail.SetColumn("tmrange5")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			Return -2
		End If
	End If
	
	
	// 1 zoncod가 같으면 
	If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
		
		//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
		If MidA(ls_tmcod, 2, 1) <> MidA(ls_Otmcod, 2, 1) Then
			f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
			dw_detail.SetColumn("tmcod")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
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
				Else
					ls_arezoncod1 = ls_zoncod
					ls_arezoncodnm = Trim(dw_detail.object.compute_zone[ll_row])
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
				dw_detail.SetRedraw(True)
            hpb_1.visible = false
				Return -2
			End If 
			
			li_rtmcnt = -1
			//이미 Select됐된 시간대인지 Check
			For li_i = 1 To li_cnt_tmkind
				If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
			Next
		
			// 5 tmcod에 해당 pricecod 별로 tmcod check
			If li_rtmcnt < 0 Then
				li_return = c1fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
				If li_return < 0 Then 
					dw_detail.SetRedraw(True)
               hpb_1.visible = false
					Return -2
				End If
				
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
				dw_detail.SetRedraw(True)
            hpb_1.visible = false
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
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
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
	If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
		
		ll_findrow = dw_detail.Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
		                            "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
									"' and frpoint = 0", 1, ll_rows)

		If ll_findrow <= 0 Then
			f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
			dw_detail.SetColumn("frpoint")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
         hpb_1.visible = false
			return -2
		End IF
		
	End IF
		
	ls_Ozoncod = ls_zoncod
	ls_Otmcod  = ls_tmcod
	ls_Oopendt = ls_opendt
Next

hpb_1.visible = false

// zoncod가 하나만 있을경우 
If LenA(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
	f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
							
	dw_detail.SetFocus()
	dw_detail.SetRedraw(True)
	Return -2
End If

li_rtmcnt = -1
//이미 Select됐된 시간대인지 Check
For li_i = 1 To li_cnt_tmkind
	If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
Next

//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
If li_rtmcnt < 0 Then
	li_return = c1fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
	If li_return < 0 Then
		dw_detail.SetRedraw(True)
		Return -2
	End If
End If

//누락된 시간대코드가 없는지 Check
//If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//	f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
//						
//	dw_detail.SetColumn("tmcod")
//	dw_detail.SetRow(ll_rows)
//	dw_detail.ScrollToRow(ll_rows)
//	dw_detail.SetRedraw(True)
//	Return -2
//End If

//같은 시간대  code error 처리
ls_Ozoncod = ""
ls_Otmcod  = ""
ls_Oopendt = ""
lc_Ofrpoint = -1
For ll_row = 1 To ll_rows
	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
	lc_frpoint = dw_detail.Object.frpoint[ll_row]
	If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
		f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
		dw_detail.SetColumn("frpoint")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	ls_Ozoncod = ls_zoncod
	ls_Oopendt = ls_opendt
	ls_Otmcod = ls_tmcod
	lc_Ofrpoint = lc_frpoint
Next		
If lb_notExist Then
	If ls_arezoncod1 <> ls_arezoncodnm Then
		f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] 대역입니다." )
		//Return -2
	Else
		If ls_arezoncod1 = "ALL" Then
			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] 대역입니다." )
			//Return -2
		Else
			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] 대역입니다." )
			//dw_detail.SetFocus()
			//dw_detail.SetRedraw(True)
			//Return -2
		End If
	End If
End If

If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
	f_msg_info(9000, Title, "정의된 모든 대역에 대해서 요율을 등록해야 합니다.")
	//Return -2
End If


ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows1 = 1 To dw_detail.RowCount()
	ls_svccod1    = Trim(dw_detail.object.svccod[ll_rows1])
	ls_priceplan1 = Trim(dw_detail.object.priceplan[ll_rows1])
	ls_zoncod1    = Trim(dw_detail.object.zoncod[ll_rows1])
	ls_tmcod1     = Trim(dw_detail.object.tmcod[ll_rows1])
	ls_frpoint1   = String(dw_detail.object.frpoint[ll_rows1])
	ls_itemcod1   = Trim(dw_detail.object.itemcod[ll_rows1])
	ls_opendt1    = String(dw_detail.object.opendt[ll_rows1], 'yyyymmdd')
	ls_enddt1     = String(dw_detail.object.enddt[ll_rows1], 'yyyymmdd')
	
	If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		ls_svccod2    = Trim(dw_detail.object.svccod[ll_rows2])
		ls_priceplan2 = Trim(dw_detail.object.priceplan[ll_rows2])
		ls_zoncod2    = Trim(dw_detail.object.zoncod[ll_rows2])
		ls_tmcod2     = Trim(dw_detail.object.tmcod[ll_rows2])
		ls_frpoint2   = String(dw_detail.object.frpoint[ll_rows2])
		ls_itemcod2   = Trim(dw_detail.object.itemcod[ll_rows2])
		ls_opendt2    = String(dw_detail.object.opendt[ll_rows2], 'yyyymmdd')
		ls_enddt2     = String(dw_detail.object.enddt[ll_rows2], 'yyyymmdd')
		
		If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
		
		If (ls_svccod1 = ls_svccod2) And (ls_priceplan1 = ls_priceplan2) And (ls_zoncod1 = ls_zoncod2) And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_itemcod1 = ls_itemcod2) Then
			If ls_enddt1 >= ls_opendt2 Then
				f_msg_info(9000, Title, "같은 대역[ " + ls_zoncod1 + " ], 같은 시간대[ " + ls_tmcod1 + " ], " &
												+ "같은 사용범위[ " + ls_frpoint1 + " ], 같은 품목[ " + ls_itemcod1 + " ]로 적용개시일이 중복됩니다.")
				Return -2
			End If
		End If
		
	Next
	
	//Update Log
	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rows1] = gs_user_id
		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_rows1] = gs_pgm_id[1]
	End If
	
Next


Return 0
end event

event type integer ue_save();String ls_priceplan, ls_sort
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
		//juede 2005.07.28--start
		ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
		dw_detail.SetSort(ls_sort)
		dw_detail.Sort()
		dw_detail.SetRedraw(True)		
		//juede 2005.07.28--end
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

cb_load.Enabled = True
cb_enddt.enabled = True
Return 0
end event

event type integer ue_reset();String ls_tmp, ls_desc
Constant Int LI_ERROR = -1
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
dw_cond.SetFocus()

cb_load.Enabled = False
cb_enddt.enabled = False

p_saveas.TriggerEvent("ue_disable")
p_fileread.TriggerEvent("ue_disable")

//기본요율 소숫점자릿수
ls_tmp = fs_get_control("B1", "Z100" , ls_desc)

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

type dw_cond from w_a_reg_m`dw_cond within c1w_reg_zoncst3_v20
integer x = 41
integer y = 40
integer width = 2464
integer height = 244
string dataobject = "c1dw_cnd_reg_zoncst3_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Long ll_row, li_rc
String ls_filter, ls_itemcod
DataWindowChild ldwc_svccod, ldwc_priceplan


If dwo.name = "parttype" Then
	
	If data = "S" Then
		This.Object.priceplan.Visible = 0
		This.Object.priceplan_t.Visible = 0
		This.Object.svccod.Visible = 1
		This.Object.svccod_t.Visible = 1
		
		dw_cond.SetItem(1, 'priceplan', 'ALL')
		dw_cond.SetItem(1, 'svccod'   , ''   )
		dw_cond.object.zoncod[1] = ''
		
		li_rc = dw_cond.GetChild("svccod", ldwc_svccod)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "GetChild : svccod")
			Return
		End If
		
		ls_filter = " svctype in ('"+ is_svctype[1]+"','"+is_svctype[2]+"')"
		ldwc_svccod.SetFilter(ls_filter)
		ldwc_svccod.Filter()
		
		ldwc_svccod.SetTransObject(SQLCA)
		
		li_rc = ldwc_svccod.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "svccod Retrieve()")
			Return
		End If					
	
	Else
		This.Object.priceplan.Visible = 1
		This.Object.priceplan_t.Visible = 1
		This.Object.svccod.Visible = 0
		This.Object.svccod_t.Visible = 0	
		
		dw_cond.SetItem(1, 'svccod'   , 'ALL')
		dw_cond.SetItem(1, 'priceplan', ''   )
		dw_cond.object.zoncod[1] = ''
		
		li_rc = dw_cond.GetChild("priceplan", ldwc_priceplan)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "GetChild : priceplan")
			Return
		End If
		
		ls_filter = " b.svctype in ('"+ is_svctype[1]+"','"+is_svctype[2]+"')"
		ldwc_priceplan.SetFilter(ls_filter)
		ldwc_priceplan.Filter()
		
		ldwc_priceplan.SetTransObject(SQLCA)
		
		li_rc = ldwc_priceplan.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "priceplan Retrieve()")
			Return
		End If
   End If
End If		
end event

type p_ok from w_a_reg_m`p_ok within c1w_reg_zoncst3_v20
integer x = 2670
integer y = 44
end type

type p_close from w_a_reg_m`p_close within c1w_reg_zoncst3_v20
integer x = 2967
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within c1w_reg_zoncst3_v20
integer x = 23
integer width = 2491
integer height = 304
end type

type p_delete from w_a_reg_m`p_delete within c1w_reg_zoncst3_v20
integer y = 1600
end type

type p_insert from w_a_reg_m`p_insert within c1w_reg_zoncst3_v20
integer y = 1600
end type

type p_save from w_a_reg_m`p_save within c1w_reg_zoncst3_v20
integer y = 1600
end type

type dw_detail from w_a_reg_m`dw_detail within c1w_reg_zoncst3_v20
integer x = 27
integer y = 312
integer width = 3543
integer height = 1248
string dataobject = "c1dw_reg_zoncst3_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;
DataWindowChild ldc, ldc_zoncod
Long ll_row, i
String ls_filter, ls_desc, ls_svccod
Dec lc_data
//Format 지정
String ls_parttype, ls_type, ls_priceplan, ls_sort
Integer li_cnt

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
	cb_enddt.enabled = False
Else							//자료가 있으면 표준대역을 불러올 수 없다.
//	cb_load.Enabled = False
	//2003.10.15 김은미 수정. 자료가 있어도 표준대역을 불러올 수 있다.
	cb_load.Enabled = True
	cb_enddt.enabled = True
End If

ls_parttype  = Trim(dw_cond.Object.parttype[1])
If ls_parttype = "R" Then
	ls_priceplan = Trim(dw_cond.object.priceplan[1])
	
	//Format 지정
	Select decpoint
	  Into 	:ls_type
	  From priceplanmst
	 where priceplan = :ls_priceplan;
Else
	ls_priceplan = 'ALL'
	
	//기본요율 소숫점자릿수
	ls_type = fs_get_control("B1", "Z100" , ls_desc)

End If

If ls_type = "0" Then
//	dw_detail.object.frpoint.Format = "#,##0"
//	dw_detail.object.confee.Format = "#,##0"
	dw_detail.object.unitfee.Format = "#,##0"
//	dw_detail.object.unitfee1.Format = "#,##0"
//	dw_detail.object.unitfee2.Format = "#,##0"
//	dw_detail.object.unitfee3.Format = "#,##0"
//	dw_detail.object.unitfee4.Format = "#,##0"
//	dw_detail.object.unitfee5.Format = "#,##0"
	dw_detail.object.munitfee.Format = "#,##0"
//	dw_detail.object.munitfee1.Format = "#,##0"
//	dw_detail.object.munitfee2.Format = "#,##0"
//	dw_detail.object.munitfee3.Format = "#,##0"
//	dw_detail.object.munitfee4.Format = "#,##0"
//	dw_detail.object.munitfee5.Format = "#,##0"
ElseIf ls_type = "1" Then
//	dw_detail.object.frpoint.Format = "#,##0.0"	
//	dw_detail.object.confee.Format = "#,##0.0"
	dw_detail.object.unitfee.Format = "#,##0.0"
//	dw_detail.object.unitfee1.Format = "#,##0.0"
//	dw_detail.object.unitfee2.Format = "#,##0.0"
//	dw_detail.object.unitfee3.Format = "#,##0.0"
//	dw_detail.object.unitfee4.Format = "#,##0.0"
//	dw_detail.object.unitfee5.Format = "#,##0.0"
//	dw_detail.object.confee.Format = "#,##0.0"
	dw_detail.object.munitfee.Format = "#,##0.0"
//	dw_detail.object.munitfee1.Format = "#,##0.0"
//	dw_detail.object.munitfee2.Format = "#,##0.0"
//	dw_detail.object.munitfee3.Format = "#,##0.0"
//	dw_detail.object.munitfee4.Format = "#,##0.0"
//	dw_detail.object.munitfee5.Format = "#,##0.0"
ElseIf ls_type = "2" Then
//	dw_detail.object.frpoint.Format = "#,##0.00"
//	dw_detail.object.confee.Format = "#,##0.00"
	dw_detail.object.unitfee.Format = "#,##0.00"
//	dw_detail.object.unitfee1.Format = "#,##0.00"
//	dw_detail.object.unitfee2.Format = "#,##0.00"
//	dw_detail.object.unitfee3.Format = "#,##0.00"
//	dw_detail.object.unitfee4.Format = "#,##0.00"
//	dw_detail.object.unitfee5.Format = "#,##0.00"
//	dw_detail.object.confee.Format = "#,##0.00"
	dw_detail.object.munitfee.Format = "#,##0.00"
//	dw_detail.object.munitfee1.Format = "#,##0.00"
//	dw_detail.object.munitfee2.Format = "#,##0.00"
//	dw_detail.object.munitfee3.Format = "#,##0.00"
//	dw_detail.object.munitfee4.Format = "#,##0.00"
//	dw_detail.object.munitfee5.Format = "#,##0.00"
ElseIf ls_type = "3" Then
//	dw_detail.object.frpoint.Format = "#,##0.000"
//	dw_detail.object.confee.Format = "#,##0.000"
	dw_detail.object.unitfee.Format = "#,##0.000"
//	dw_detail.object.unitfee1.Format = "#,##0.000"
//	dw_detail.object.unitfee2.Format = "#,##0.000"
//	dw_detail.object.unitfee3.Format = "#,##0.000"
//	dw_detail.object.unitfee4.Format = "#,##0.000"
//	dw_detail.object.unitfee5.Format = "#,##0.000"
//	dw_detail.object.confee.Format = "#,##0.000"
	dw_detail.object.munitfee.Format = "#,##0.000"
//	dw_detail.object.munitfee1.Format = "#,##0.000"
//	dw_detail.object.munitfee2.Format = "#,##0.000"
//	dw_detail.object.munitfee3.Format = "#,##0.000"
//	dw_detail.object.munitfee4.Format = "#,##0.000"
//	dw_detail.object.munitfee5.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	//dw_detail.object.frpoint.Format = "#,##0.0000"	
	//dw_detail.object.confee.Format = "#,##0.0000"
	dw_detail.object.unitfee.Format = "#,##0.0000"
//	dw_detail.object.unitfee1.Format = "#,##0.0000"
//	dw_detail.object.unitfee2.Format = "#,##0.0000"
//	dw_detail.object.unitfee3.Format = "#,##0.0000"
//	dw_detail.object.unitfee4.Format = "#,##0.0000"
//	dw_detail.object.unitfee5.Format = "#,##0.0000"
//	dw_detail.object.confee.Format = "#,##0.0000"
	dw_detail.object.munitfee.Format = "#,##0.0000"
//	dw_detail.object.munitfee1.Format = "#,##0.0000"
//	dw_detail.object.munitfee2.Format = "#,##0.0000"
//	dw_detail.object.munitfee3.Format = "#,##0.0000"
//	dw_detail.object.munitfee4.Format = "#,##0.0000"
//	dw_detail.object.munitfee5.Format = "#,##0.0000"
End If

//For i =1 To dw_detail.RowCount()
//    lc_data = dw_detail.object.unbilsec[i]
//	 If IsNull(lc_data) Then dw_detail.object.unbilsec[i] = 0
//    lc_data = dw_detail.object.limitsec[i]
//	 If IsNull(lc_data) Then dw_detail.object.limitsec[i] = 0
//	 lc_data = dw_detail.object.confee[i]
//	 If IsNull(lc_data) Then dw_detail.object.confee[i] = 0
//	 lc_data = dw_detail.object.unitfee1[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee1[i] = 0
//	 lc_data = dw_detail.object.tmrange1[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange1[i] = 0
//	 lc_data = dw_detail.object.unitsec1[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec1[i] = 0
//	 lc_data = dw_detail.object.unitfee2[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee2[i] = 0
//	 lc_data = dw_detail.object.tmrange2[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange2[i] = 0
//	 lc_data = dw_detail.object.unitsec2[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec2[i] = 0
//	 lc_data = dw_detail.object.unitfee3[i]

//	 If IsNull(lc_data) Then dw_detail.object.unitfee3[i] = 0
//	 lc_data = dw_detail.object.tmrange3[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange3[i] = 0
//	 lc_data = dw_detail.object.unitsec3[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec3[i] = 0
//	 lc_data = dw_detail.object.unitfee4[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee4[i] = 0
//	 lc_data = dw_detail.object.tmrange4[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange4[i] = 0
//	 lc_data = dw_detail.object.unitsec4[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec4[i] = 0
//	 lc_data = dw_detail.object.unitfee5[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee5[i] = 0
//	 lc_data = dw_detail.object.tmrange5[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange5[i] = 0
//	 lc_data = dw_detail.object.unitsec5[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec5[i] = 0
//	 lc_data = dw_detail.object.munitfee1[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitfee1[i] = 0
//	 lc_data = dw_detail.object.mtmrange1[i]
//	 If IsNull(lc_data) Then dw_detail.object.mtmrange1[i] = 0
//	 lc_data = dw_detail.object.munitsec1[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitsec1[i] = 0
//	 lc_data = dw_detail.object.munitfee2[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitfee2[i] = 0
//	 lc_data = dw_detail.object.mtmrange2[i]
//	 If IsNull(lc_data) Then dw_detail.object.mtmrange2[i] = 0
//	 lc_data = dw_detail.object.munitsec2[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitsec2[i] = 0
//	 lc_data = dw_detail.object.munitfee3[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitfee3[i] = 0
//	 lc_data = dw_detail.object.mtmrange3[i]
//	 If IsNull(lc_data) Then dw_detail.object.mtmrange3[i] = 0
//	 lc_data = dw_detail.object.munitsec3[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitsec3[i] = 0
//	 lc_data = dw_detail.object.munitfee4[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitfee4[i] = 0
//	 lc_data = dw_detail.object.mtmrange4[i]
//	 If IsNull(lc_data) Then dw_detail.object.mtmrange4[i] = 0
//	 lc_data = dw_detail.object.munitsec4[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitsec4[i] = 0
//	 lc_data = dw_detail.object.munitfee5[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitfee5[i] = 0
//	 lc_data = dw_detail.object.mtmrange5[i]
//	 If IsNull(lc_data) Then dw_detail.object.mtmrange5[i] = 0
//	 lc_data = dw_detail.object.munitsec5[i]
//	 If IsNull(lc_data) Then dw_detail.object.munitsec5[i] = 0	 
//	 
//	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//	
//Next

//If is_svccod_control = 'Y' Then
//
//	ls_svccod = dw_cond.object.svccod[1]
//   
//	Modify("zoncod.dddw.name=''")
//	Modify("zoncod.dddw.DataColumn=''")
//	Modify("zoncod.dddw.DisplayColumn=''")
//
//	Modify("zoncod.dddw.name=b0dc_dddw_zoncod_svccod_v20")
//	Modify("zoncod.dddw.DataColumn='zoncod'")
//	Modify("zoncod.dddw.DisplayColumn='zonnm'")	
//
//	ll_row = dw_detail.GetChild("zoncod", ldc_zoncod)
//	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//	
//	ls_filter = " a.svccod = '" + ls_svccod + "' "
//	//juede 2005.07.28 --start
//	If ls_priceplan <> '' Then
//		ls_filter = ls_filter +  " and a.priceplan = '" + ls_priceplan + "' "
//	End If
//	//juede 2005.07.28 ---end
//	ldc_zoncod.SetFilter(ls_filter)			//Filter정함
//	ldc_zoncod.Filter()
//	ldc_zoncod.SetTransObject(SQLCA)
//	ll_row = ldc_zoncod.Retrieve()
//	
//ElseIf is_svccod_control = 'N' Then
//	Modify("zoncod.dddw.name=''")
//	Modify("zoncod.dddw.DataColumn=''")
//	Modify("zoncod.dddw.DisplayColumn=''")
//
//	Modify("zoncod.dddw.name=b0dc_dddw_zoncod")
//	Modify("zoncod.dddw.DataColumn='zoncod'")
//	Modify("zoncod.dddw.DisplayColumn='zonnm'")	
//
//End If
//
//
////해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
//ll_row = dw_detail.GetChild("tmcod", ldc)
//If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//ls_filter = "tmcod_priceplan = '" + ls_priceplan + "' "
//ldc.SetFilter(ls_filter)			//Filter정함
//ldc.Filter()
//ldc.SetTransObject(SQLCA)
//ll_row =ldc.Retrieve()

//작업선택 기본요율, 가격정책별 요율에 따라 dddw를 바꾼다.
If ls_parttype = "R" Then
	//가격정책별 품목
	Modify("itemcod.dddw.name=''")
	Modify("itemcod.dddw.DataColumn=''")
	Modify("itemcod.dddw.DisplayColumn=''")
	Modify("itemcod.dddw.name=c1dc_dddw_item_voice_v20")
	Modify("itemcod.dddw.DataColumn='itemcod'")
	Modify("itemcod.dddw.DisplayColumn='itemnm'")

ElseIf ls_parttype = "S" Then
	//서비스 품목
	Modify("itemcod.dddw.name=''")
	Modify("itemcod.dddw.DataColumn=''")
	Modify("itemcod.dddw.DisplayColumn=''")
	Modify("itemcod.dddw.name=c1dc_dddw_itemcod_voice_v20")
	Modify("itemcod.dddw.DataColumn='itemcod'")
	Modify("itemcod.dddw.DisplayColumn='itemnm'")

End If

//가격정책별일때 .. 가격정책별 item가져오기
ll_row = dw_detail.GetChild("itemcod", idc_itemcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

If ls_parttype = "R" Then
	ls_filter = "priceplan = '" + ls_priceplan + "' "
	idc_itemcod.SetFilter(ls_filter)			//Filter정함
	idc_itemcod.Filter()
	idc_itemcod.SetTransObject(SQLCA)
	ll_row =idc_itemcod.Retrieve()

//서비스별일때..  서비스별 item가져오기	
ElseIf ls_parttype = "S" Then 
	ls_filter = " svccod = '" + Trim(dw_cond.object.svccod[1]) + "' "
	idc_itemcod.SetFilter(ls_filter)			//Filter정함
	idc_itemcod.Filter()
	idc_itemcod.SetTransObject(SQLCA)
	ll_row =idc_itemcod.Retrieve() 

End If

////priceplan이 ALL인 경우의 품목은 정하지 않으므로 음성인 품목을 모두 조회
//If ls_parttype = "R" Then
//	ll_row = dw_detail.GetChild("itemcod", idc_itemcod)
//	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//	ls_filter = "priceplan = '" + ls_priceplan + "' "
//	idc_itemcod.SetFilter(ls_filter)			//Filter정함
//	idc_itemcod.Filter()
//	idc_itemcod.SetTransObject(SQLCA)
//	ll_row =idc_itemcod.Retrieve()
//End If
//
If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
Else
	dw_detail.SetColumn("tmcod")	//찾았을 경우 적용이 빨리 안되서
	dw_detail.SetColumn("zoncod")
End If


//juede 2005.07.28--start
ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)		
dw_detail.SetFocus()
//juede 2005.07.28--end

end event

event dw_detail::itemchanged;call super::itemchanged;String ls_opendt, ls_munitsec
Long ll_range1, ll_range2, ll_range3, ll_range4, ll_range5, ll_mod

If (dw_detail.GetItemStatus(row, 0, Primary!) = New!) Or (This.GetItemStatus(row, 0, Primary!)) = NewModified!	Then
	ls_munitsec = "0"
Else
	ls_munitsec = String(This.object.munitsec[row])
	If IsNull(ls_munitsec) Then ls_munitsec = ""
End If

Choose Case dwo.name
	Case "unitsec"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec[row] > 0)  Then
				This.object.munitsec[row] = Long(data)
			End If
		End If
		
	Case "unitfee"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee[row] > 0)  Then
				This.object.munitfee[row] = Long(data)
			End If
		End If
		
	Case "tmrange1"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange1[row] > 0)  Then
				This.object.mtmrange1[row] = Long(data)
			End If
		End If
		
	Case "unitsec1"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.object.munitsec1[row] > 0) Then
				This.object.munitsec1[row] = Long(data)
			End If
		End If
		
		ll_range1 = This.object.tmrange1[row]
		
		If ll_range1 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range1, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange1")
				Return -1
			End If
		End If
	
	Case "unitfee1"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.object.munitfee1[row] > 0)  Then
				This.object.munitfee1[row] = Long(data)
			End If
		End If
		
	Case "tmrange2"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange2[row] > 0)  Then
				This.object.mtmrange2[row] = Long(data)
			End If
		End If
	
		
	Case "unitsec2"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec2[row] > 0)  Then
				This.object.munitsec2[row] = Long(data)
			End If
		End If
		
		ll_range2 = This.object.tmrange2[row]
		
		If ll_range2 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range2, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange2")
				Return -1
			End If
		End If
		
	Case "unitfee2"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee2[row] > 0)  Then
				This.object.munitfee2[row] = Long(data)
			End If
		End If
		
	Case "tmrange3"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange3[row] > 0)  Then
				This.object.mtmrange3[row] = Long(data)
			End If
		End If
		
	Case "unitsec3"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec3[row] > 0)  Then
				This.object.munitsec3[row] = Long(data)
			End If
		End If
		
		ll_range3 = This.object.tmrange3[row]
		
		If ll_range3 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range3, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange3")
				Return -1
			End If
		End If
		
	Case "unitfee3"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee3[row] > 0)  Then
				This.object.munitfee3[row] = Long(data)
			End If
		End If
		
	Case "tmrange4"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange4[row] > 0)  Then
				This.object.mtmrange4[row] = Long(data)
			End If
		End If
		
	Case "unitsec4"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec4[row] > 0)  Then
				This.object.munitsec4[row] = Long(data)
			End If
		End If
		
		ll_range4 = This.object.tmrange4[row]
		
		If ll_range4 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range4, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange4")
				Return -1
			End If
		End If
		
	Case "unitfee4"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee4[row] > 0)  Then
				This.object.munitfee4[row] = Long(data)
			End If
		End If
		
	Case "tmrange5"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange5[row] > 0)  Then
				This.object.mtmrange5[row] = Long(data)
			End If
		End If
		
	Case "unitsec5"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec5[row] > 0)  Then
				This.object.munitsec5[row] = Long(data)
			End If
		End If
		
		ll_range5 = This.object.tmrange5[row]
		
		If ll_range5 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range5, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange5")
				Return -1
			End If
		End If
		
	Case "unitfee5"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee5[row] > 0)  Then
				This.object.munitfee5[row] = Long(data)
			End If
		End If
		
End Choose

Return 0
end event

type p_reset from w_a_reg_m`p_reset within c1w_reg_zoncst3_v20
integer x = 1097
integer y = 1600
end type

type cb_load from commandbutton within c1w_reg_zoncst3_v20
integer x = 2670
integer y = 184
integer width = 315
integer height = 112
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "요금 Copy"
end type

event clicked;//해당 고객의 
String ls_priceplan, ls_svccod
Long ll_row


ls_priceplan = Trim(dw_cond.object.priceplan[1])//가격정책
ls_svccod    = Trim(dw_cond.object.svccod[1])

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "표준요금 Load"
iu_cust_msg.is_grp_name = "통화서비스 요율 관리"
iu_cust_msg.is_data[1] = ls_priceplan
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.is_data[3] = ls_svccod  
iu_cust_msg.idw_data[1] = dw_detail

//Open
OpenWithParm(c1w_inq_zoncst3_popup_v20, iu_cust_msg)  //청구 윈도우 연다.

Return 0 
end event

type p_saveas from u_p_saveas within c1w_reg_zoncst3_v20
integer x = 1536
integer y = 1600
boolean bringtotop = true
boolean originalsize = false
end type

type p_fileread from u_p_fileread within c1w_reg_zoncst3_v20
integer x = 1842
integer y = 1600
boolean bringtotop = true
boolean originalsize = false
end type

type hpb_1 from hprogressbar within c1w_reg_zoncst3_v20
boolean visible = false
integer x = 50
integer y = 260
integer width = 2469
integer height = 52
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 100
integer setstep = 1
end type

type cb_enddt from commandbutton within c1w_reg_zoncst3_v20
integer x = 2985
integer y = 184
integer width = 576
integer height = 112
integer taborder = 21
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "적용종료일 일괄처리"
end type

event clicked;//해당 고객의 
String ls_priceplan, ls_svccod, ls_zoncod,ls_return
Long ll_row

If dw_detail.rowcount() <= 0 Then Return 0

ls_priceplan = Trim(dw_cond.object.priceplan[1])//가격정책
ls_svccod    = Trim(dw_cond.object.svccod[1])
ls_zoncod    = Trim(dw_cond.object.zoncod[1])

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "표준요금 Load"
iu_cust_msg.is_grp_name = "적용종료일 일괄처리"
iu_cust_msg.is_data[1] = ls_priceplan
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.is_data[3] = ls_svccod  
iu_cust_msg.is_data[4] = ls_zoncod  
iu_cust_msg.idw_data[1] = dw_detail

//Open
OpenWithParm(c1w_inq_zoncst3_enddt_popup_v20, iu_cust_msg)  //청구 윈도우 연다.

ls_return = Message.stringparm
If ls_return  = '1' Then
	Parent.TriggerEvent("ue_ok")
End If

Return 0 
end event

type oleobject_1 from oleobject within c1w_reg_zoncst3_v20 descriptor "pb_nvo" = "true" 
end type

on oleobject_1.create
call super::create
TriggerEvent( this, "constructor" )
end on

on oleobject_1.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

