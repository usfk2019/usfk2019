$PBExportHeader$b7w_reg_bankreq_gr22.srw
$PBExportComments$[ceusee] 자동이체(EDI) 신청파일 작성(GR22)
forward
global type b7w_reg_bankreq_gr22 from w_a_reg_m_sql
end type
type p_2 from u_p_create within b7w_reg_bankreq_gr22
end type
type hpb_1 from hprogressbar within b7w_reg_bankreq_gr22
end type
type p_filewrite from u_p_filewrite within b7w_reg_bankreq_gr22
end type
end forward

global type b7w_reg_bankreq_gr22 from w_a_reg_m_sql
integer width = 3227
integer height = 1984
event ue_filewrite ( )
p_2 p_2
hpb_1 hpb_1
p_filewrite p_filewrite
end type
global b7w_reg_bankreq_gr22 b7w_reg_bankreq_gr22

type variables
String is_filename[], is_filepath, is_coid, is_coname
String is_worktype[], is_bankreqstatus[], is_dir, is_filenm
String is_receiptcod[], is_drawingresult[], is_filelike
Date id_acpdt
end variables

event ue_filewrite();// MAC 검증값은 Host 접속이용기관에서만 이용
// PC 접속이용기관에서는 모뎀프로그램에서 생성
String ls_file_name, ls_cmsacpdt
String ls_totrecord, ls_newreq, ls_cancelreq
Int li_rc
b7u_dbmgr3 lu_dbmgr 
dw_cond.AcceptText()
//CMS 신청접수일
ls_cmsacpdt = String(dw_cond.Object.cmsacpdt[1], "yyyymmdd")

SetPointer(HourGlass!)

//출금이체신청처리
lu_dbmgr = Create b7u_dbmgr3
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "EDI GR22%FilseWrite"
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = is_filenm			        //filename
lu_dbmgr.is_data[2] = is_filepath			    //filepath
lu_dbmgr.is_data[3] = is_worktype[2]		    //Worktype(작업유형)
lu_dbmgr.is_data[4] = ls_cmsacpdt			    //접수일자
lu_dbmgr.is_data[5] = is_coid			           //기관식별코드
lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
lu_dbmgr.is_data[7] = is_bankreqstatus[2]       //출금이체신청 작업상태(신청)
lu_dbmgr.is_data[8] = is_coname                 //이용기간명
lu_dbmgr.is_data[9] = is_bankreqstatus[3]       //출금이체신청 작업상태(응답확인)
lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]  //pgmid

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

Destroy lu_dbmgr

SetPointer(Arrow!)

Choose Case li_rc
	Case -3
		f_msg_usr_err(9000, Title, "Error>> " + is_filepath + "은 처리 할 수 없습니다.")
		p_filewrite.TriggerEvent("ue_enabled")
	Case -2
		f_msg_usr_err(9000, Title, "Error>> " + is_filepath + "은 이미 처리가 되었습니다.")
		p_filewrite.TriggerEvent("ue_enabled")
	Case -1
      p_filewrite.TriggerEvent("ue_enabled")
	Case Else
		COMMIT;
		MessageBox(Title, "처리가 완료되었습니다. " + &
		                  "(" + ls_file_name + " : " + String(li_rc) + "건)")
		p_filewrite.TriggerEvent("ue_disable")
End Choose

p_save.TriggerEvent("ue_disable")

return
end event

on b7w_reg_bankreq_gr22.create
int iCurrent
call super::create
this.p_2=create p_2
this.hpb_1=create hpb_1
this.p_filewrite=create p_filewrite
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_2
this.Control[iCurrent+2]=this.hpb_1
this.Control[iCurrent+3]=this.p_filewrite
end on

on b7w_reg_bankreq_gr22.destroy
call super::destroy
destroy(this.p_2)
destroy(this.hpb_1)
destroy(this.p_filewrite)
end on

event open;call super::open;String	ls_ref_desc, ls_temp
String   ls_dir
Date ld_sysdt
Int	 li_cnt, li_day

ld_sysdt = date(fdt_get_dbserver_now())
dw_cond.Object.cmsreqdt[1] = ld_sysdt

//처리일자
li_day = Integer(fs_get_control("B7", "A607", ls_ref_desc))
id_acpdt = fd_date_next(ld_sysdt, Integer(li_day))
dw_cond.Object.cmsacpdt[1] = id_acpdt

//이체신청파일이름
ls_temp = fs_get_control("B7", "A605", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_filename[])
If is_filename[2] = "" Then
	f_msg_usr_err(9000, Title, "이체신청 Filename 정보가 없습니다.(SYSCTL1T:B7:A605)")
	Close(This)
Else
	is_filenm = is_filename[2] + String(id_acpdt, "mmdd")
	dw_cond.Object.filename[1] = is_filenm
End If



//출금이체신청 지로코드
ls_ref_desc = ""
is_coid = Trim(fs_get_control("B7", "A100", ls_ref_desc))
If is_coid = "" Then
	f_msg_usr_err(9000, Title, "지로 번호 정보 없습니다.(SYSCTL1T:B7:A100)")
	Close(This)
Else
	dw_cond.Object.idtno[1] = is_coid
End If

//출금이체신청 이용기관명
ls_ref_desc = ""
is_coname = Trim(fs_get_control("B7", "A600", ls_ref_desc))
If is_coname = "" Then
	f_msg_usr_err(9000, Title, "이용기관명 정보가 없습니다.(SYSCTL1T:B7:A600)")
	Close(This)
Else
	dw_cond.Object.idtname[1] = is_coname
End If

//파일저장위치
is_filepath =  fs_get_control("B7", "A400", ls_ref_desc)
If is_filepath = "" Then
	f_msg_usr_err(9000, Title, "파일저장 위치에 대한 정보가 없습니다.(SYSCTL1T:B7:A400)")
	Close(This)
End If	

dw_cond.Object.browse[1] = is_filepath

If RightA(is_filepath, 1) = "\" Then
	
Else
	is_filepath = is_filepath + "\"
End If

//작업유형(worktype:은행;이용기관)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A500", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_worktype[])

//출금이체신청처리상태(미처리;신청;응답확인;입금처리;0;1;2;3)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_bankreqstatus[])

//접수처구분(은행;이용기관)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A300", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_receiptcod[])

//출금이체 신청결과(없음;미처리;처리중;처리성공;처리실패;0;1;S;F)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_drawingresult[])

//save 활성화 결정
//GR22파일을 반영했을 경우 해당 응답확인이 아닌 파일이 존재함으로 save 버튼이 활성화 되지 않는다.
li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM bankreqstatus
WHERE status <> :is_bankreqstatus[3];
	
IF  li_cnt = 0 THEN
	p_save.TriggerEvent("ue_enable")
ELSE
	p_save.TriggerEvent("ue_disable")
END IF

//file write 활성화 결정
//미처리파일이 있으면 파일저장 가능
li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM bankreqstatus
WHERE status = :is_bankreqstatus[1];
	
IF (li_cnt = 0) THEN
	p_filewrite.TriggerEvent("ue_disable")
ELSE
	p_filewrite.TriggerEvent("ue_enable")
END IF
end event

event ue_ok();call super::ue_ok;// chargeby : 지로-1, 자동이체-2, 카드-3
//billinginfo에서 drawingresult가 미처리인 고객만 불러온다.
//GR21 파일로 처리한 고객은 처리중으로 Update 되었다.
String ls_where , ls_result , ls_receiptcod
String ls_cmsreqdt, ls_sysdate
Long ll_rows
Int li_rc
Date ld_cmsreqdt
 
// 납입자 신청일자
ld_cmsreqdt = dw_cond.Object.cmsreqdt[1]
ls_cmsreqdt = String(ld_cmsreqdt, "yyyymmdd")
If IsNull(ld_cmsreqdt) Then ls_cmsreqdt = ""
If ls_cmsreqdt = "" Then
	f_msg_usr_err(200, Title, "신청일자")
	dw_cond.SetColumn("cmsreqdt")
	dw_cond.SetFocus()
	Return
End If

ls_sysdate = String(fdt_get_dbserver_now(),"YYYY-MM-DD")

//신청일자 < systemdate
IF  (ls_cmsreqdt > ls_sysdate) THEN
	f_msg_usr_err(212, Title + "today:" + ls_sysdate, "신청일자")
	dw_cond.SetColumn("cmsreqdt")
	dw_cond.SetFocus()
	RETURN
END IF

// SQL WHERE Clause
ls_where = "" 
//접수처;이용기관
If ls_where <> "" Then ls_where += " AND "
ls_where += "receiptcod = '" + is_receiptcod[2] + "'"

If ls_cmsreqdt <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(drawingreqdt,'yyyymmdd') <= '" + ls_cmsreqdt + "' "
End If

//신청결과;미처리
If ls_where <> "" Then ls_where += " AND "
ls_where += "drawingresult = '" + is_drawingresult[2] + "'"

dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

event type integer ue_save_sql();call super::ue_save_sql;//Billinginfo에서 미처리인 고객을 처리중으로 Update한다.
//bankreq insert 
//bankstatus insert 한다.

String ls_cmsacpdt
Long ll_rows
Date ld_cmsacpdt
Int li_holiday, li_cnt, li_rc
b7u_dbmgr3  lu_dbmgr
 
This.TriggerEvent("ue_ok")

li_rc = dw_detail.RowCount()
If li_rc = 0 Then Return -3

// 금결원 접수일자
ld_cmsacpdt = dw_cond.Object.cmsacpdt[1]
ls_cmsacpdt = String(ld_cmsacpdt, "yyyymmdd")
If IsNull(ld_cmsacpdt) Then ls_cmsacpdt = ""
If ls_cmsacpdt = "" Then
	f_msg_usr_err(200, Title, "처리일자")
	dw_cond.SetColumn("cmsacpdt")
	dw_cond.SetFocus()
	Return -3
End If

//접수일자 조건1- 오늘날짜 보다 적을 수 없다.
IF(ls_cmsacpdt < String(id_acpdt,"YYYYMMDD")) THEN
		f_msg_usr_err(212, Title + "today:" + String(id_acpdt, 'yyyy-mm-dd'), "처리일자")
	dw_cond.SetColumn("cmsacpdt")
	dw_cond.SetFocus()
	RETURN -3
END IF

//접수일자 조건2- 일요일 혹은 공휴일이면 안된다.
//공휴일조건 체크
SELECT count(*)
INTO :li_holiday
FROM holiday
WHERE to_char(hday,'yyyymmdd') = :ls_cmsacpdt;

//일요일 조건 체크
IF(li_holiday > 0 OR DayName(ld_cmsacpdt) = "Sunday" OR DayName(ld_cmsacpdt) = "Saturday") THEN
	f_msg_usr_err(210, Title, "접수일자는 일(토)요일,공휴일일 수 없습니다.")
	dw_cond.SetColumn("cmsacpdt")
	dw_cond.SetFocus()
	RETURN -3
END IF

//출금이체신청처리
lu_dbmgr = Create b7u_dbmgr3
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "EDI GR22%SAVE"
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = is_filenm			        //filename
lu_dbmgr.is_data[2] = is_filepath			    //filepath
lu_dbmgr.is_data[3] = is_worktype[2]		    //Worktype(작업유형)
lu_dbmgr.is_data[4] = ls_cmsacpdt			    //접수일자
lu_dbmgr.is_data[5] = is_receiptcod[2]          //접수처
lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
lu_dbmgr.is_data[7] = is_drawingresult[3]       //출금이체신청결과(처리중)
lu_dbmgr.is_data[8] = is_coname                 //이용기간명
lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no]  //pgmid

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then 
	Destroy lu_dbmgr
	return li_rc
End If

Destroy lu_dbmgr

return 0
end event

event ue_save();Integer li_return

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If

SetPointer(HourGlass!)

li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		SetPointer(Arrow!)
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "Save")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		SetPointer(Arrow!)
		If iu_mdb_app.ii_rc = -1 Then Return
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
		
		This.TriggerEvent("ue_filewrite")		
End Choose

SetPointer(Arrow!)
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b7w_reg_bankreq_gr22
integer x = 32
integer y = 40
integer width = 2062
integer height = 452
string dataobject = "b7dw_cnd_reg_bankreq_gr22"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::buttonclicked;call super::buttonclicked;Constant Integer li_MAX_DIR = 255, li_MAX_FILES = 4097
UnsignedLong lul_hwnd
Boolean	lb_return
String	ls_curdir, ls_filename, ls_title
Integer	li_return
Long ll_len
u_api		lu_extern
		

Choose Case dwo.Name
	Case "b_browse"
		lu_extern =  Create u_api
			
		ls_curdir = Space(li_MAX_DIR)
		lu_extern.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
		ls_curdir = Trim(ls_curdir)
		
		lul_hwnd = Handle(Parent)
		ls_title = "Select Files"
		
		ls_filename = Space(li_MAX_FILES)
		lb_return = lu_extern.PBGetOpenFileNameA(lul_hwnd, ls_title, ls_filename)
		If Not lb_return Then
			Destroy lu_extern
			Return -1
		End If
		
		If IsNull(ls_filename) Then ls_filename = ""
		ls_filename = Upper(Trim(ls_filename))
		ll_len = LenA(ls_filename)
		If ll_len <= 0 Then
			If LenA(ls_curdir) > 0 Then lb_return = lu_extern.SetCurrentDirectoryA(ls_curdir)
			Destroy lu_extern
			Return -1
		End If
		Destroy lu_extern
		
		Object.browse[1] = ls_filename
End Choose
		
end event

event dw_cond::itemchanged;call super::itemchanged;string ls_mmdd

If dwo.name = "cmsacpdt" Then
	
		ls_mmdd = MidA(data,6,2) + MidA(data,9,2)
	
	is_filenm = is_filename[2] + ls_mmdd
	dw_cond.Object.filename[1] = is_filenm
End IF
end event

type p_ok from w_a_reg_m_sql`p_ok within b7w_reg_bankreq_gr22
integer x = 2235
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b7w_reg_bankreq_gr22
integer x = 2542
integer y = 56
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b7w_reg_bankreq_gr22
integer x = 18
integer width = 2094
integer height = 516
end type

type p_save from w_a_reg_m_sql`p_save within b7w_reg_bankreq_gr22
integer x = 2235
integer y = 184
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b7w_reg_bankreq_gr22
integer x = 18
integer y = 536
integer width = 3150
integer height = 1320
string dataobject = "b7dw_inq_reg_bankreq_gr22"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ib_highlight = True

ldwo_sort = Object.customerid_t
uf_init(ldwo_sort)


end event

event dw_detail::retrieveend;call super::retrieveend;INT li_cnt

//save 활성화 결정
li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM bankreqstatus
WHERE status <> :is_bankreqstatus[3];
  	
IF  li_cnt = 0 THEN
	p_save.TriggerEvent("ue_enable")
ELSE
	p_save.TriggerEvent("ue_disable")
END IF

//file write 활성화 결정
li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM bankreqstatus
where status = :is_bankreqstatus[1];
	
IF (li_cnt = 0) THEN
	p_filewrite.TriggerEvent("ue_disable")
ELSE
	p_filewrite.TriggerEvent("ue_enable")
END IF
end event

type p_2 from u_p_create within b7w_reg_bankreq_gr22
boolean visible = false
integer x = 2345
integer y = 80
boolean bringtotop = true
boolean enabled = false
end type

type hpb_1 from hprogressbar within b7w_reg_bankreq_gr22
boolean visible = false
integer x = 1993
integer y = 380
integer width = 800
integer height = 80
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 100
integer setstep = 1
end type

type p_filewrite from u_p_filewrite within b7w_reg_bankreq_gr22
event type integer ue_filewrite ( )
integer x = 2542
integer y = 184
boolean bringtotop = true
boolean originalsize = false
end type

