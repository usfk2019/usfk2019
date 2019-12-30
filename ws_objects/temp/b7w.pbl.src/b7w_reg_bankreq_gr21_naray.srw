$PBExportHeader$b7w_reg_bankreq_gr21_naray.srw
$PBExportComments$[jwlee] 자동이체(EDI) 은행신청 파일 반영_naray용
forward
global type b7w_reg_bankreq_gr21_naray from w_a_reg_m_sql
end type
type p_fileread from u_p_fileread within b7w_reg_bankreq_gr21_naray
end type
end forward

global type b7w_reg_bankreq_gr21_naray from w_a_reg_m_sql
integer width = 3232
integer height = 2268
event ue_fileread ( )
event type long ue_open ( )
p_fileread p_fileread
end type
global b7w_reg_bankreq_gr21_naray b7w_reg_bankreq_gr21_naray

type variables
String is_filenames[], is_worktype[], is_filelike, is_status[], is_drawingresult[]
String is_filenm, is_filepath, is_coid, is_coname, is_receipty
Date id_acpdt
end variables

forward prototypes
public function integer wfi_check_filename (string as_filename)
public function integer wfi_check_fileexist (string as_filename)
end prototypes

event ue_fileread();Constant Integer GR21_SIZE = 150, li_MAX_DIR = 255, li_MAX_FILES = 4097
Boolean	lb_return
Integer	li_return, li_filenum
Integer	li_read_bytes, li_holiday
String	ls_buffer
String	ls_curdir
String	ls_title, ls_pathname, ls_filename, ls_filter
Long		ll_rows, ll_return
String ls_ref_desc
String ls_file_name, ls_receiptdt_mmdd, ls_prc_filename
string docname, named, ls_cmsacpdt
Date ld_cmsacpdt
dw_cond.AcceptText()
//디렉토리
ls_pathname = is_filepath

//현재 폴더 설정
u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)
ls_filter = is_filenames[1] + " Files (" + is_filenames[1] + "*.*), " + is_filenames[1] +  "*.*"
ls_filename = ""

//File Open
li_return = GetFileOpenName("Select File", ls_pathname, ls_filename, "", ls_filter)

If li_return <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_info(1001, Title, ls_filename)
	Return
End If

If PosA(ls_filename, ".") > 0  Then
	f_msg_usr_err(9000, Title, "확정자가 없는 파일 선택하셔야 합니다.")
	return 
End if

li_return = wfi_check_fileexist(ls_filename)
If li_return > 0 Then 
	f_msg_usr_err(9000, Title, "이미 처리가 되었습니다.(" + ls_filename + ")")
	Return
ElseIf li_return < 0 Then
	Return
End If

li_return = MessageBox(Title, "신청결과파일 " + ls_filename + "을 처리합니다.", Information!, OKCancel!, 1)
If li_return <> 1 Then
	MessageBox(Title, "취소되었습니다(파일: " + ls_filename + ")", Information!, Ok!)
	Return
End If

SetPointer(Arrow!)
dw_cond.object.bankreqstatus_file_name[1] = ls_filename 

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api


SetPointer(HourGlass!)
ls_pathname = Upper(ls_pathname)
ls_filename = Upper(ls_filename)


b7u_dbmgr3_naray lu_dbmgr
lu_dbmgr = Create b7u_dbmgr3_naray
lu_dbmgr.is_caller = "EDI GR21%Save%Write"
lu_dbmgr.is_title = This.Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = ls_pathname              //GR21파일에 Path    
lu_dbmgr.is_data[2] = ls_filename              //GR21파일
lu_dbmgr.is_data[3] = is_worktype[1]           //은행신청
lu_dbmgr.is_data[4] = is_filepath			     //GR22생성할 path
lu_dbmgr.is_data[5] = is_filenm			        //GR22생성할 파일 이름
//lu_dbmgr.is_data[6] = ls_cmsacpdt			     //처리일자
lu_dbmgr.is_data[7] = is_coid			           //기관식별코드(지로번호)
lu_dbmgr.is_data[8] = is_coname               //이용기간명 
lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no]  //pgmid

lu_dbmgr.uf_prc_db_05()
SetPointer(Arrow!)

Choose Case lu_dbmgr.ii_rc
	Case -3
		f_msg_usr_err(9000, Title, "Error>> " + is_filepath + "은 처리 할 수 없습니다.")
		rollback;
	Case -2
		f_msg_usr_err(9000, Title, "Error>> " + is_filepath + "은 이미 처리가 되었습니다.")
		rollback;
	Case -1
		f_msg_info(3010, This.Title, "Save")
     	rollback;
	Case Else
		COMMIT;
		MessageBox(Title, "처리가 완료되었습니다. " + &
								"(" + is_filenm + " : " + String(lu_dbmgr.ii_rc) + "건)" )
		dw_cond.object.filename[1] = ls_filename //GR22파일						
		dw_cond.object.bankreq_file_name[1] = ls_filename //GR22파일
		//이체연도
		is_receipty = LeftA(lu_dbmgr.is_cmsacpdt,4)
		TriggerEvent('ue_open')
		TriggerEvent('ue_ok')
End Choose
destroy lu_dbmgr	

	
Return
end event

event type long ue_open();//은행 신청 파일(GR21)로 Insert 시 GR22파일로 Insert 한다.
//해당 파일상태는 응답확인으로 만든다.

String ls_file_name, ls_worktype, ls_temp,  ls_ref_desc, ls_status[]
Integer li_result, li_cnt, li_day
Date ld_receiptdt, ld_sysdt
String ls_filter, ls_dir
DatawindowChild ldc_filename


//처리일자
ld_sysdt = date(fdt_get_dbserver_now())
li_day = Integer(fs_get_control("B7", "A607", ls_ref_desc))
id_acpdt = fd_date_next(ld_sysdt, Integer(li_day))
dw_cond.Object.cmsacpdt[1] = id_acpdt


//이체신청파일이름(GR22)
ls_temp = fs_get_control("B7", "A605", ls_ref_desc)
If ls_temp = "" Then Return 0
fi_cut_string(ls_temp, ";" , is_filenames[])
If is_filenames[2] = "" Then
	f_msg_usr_err(9000, Title, "이체신청 Filename 정보가 없습니다.(SYSCTL1T:B7:A605)")
	Close(This)
Else
	is_filenm = is_filenames[2]
	//dw_cond.Object.filename[1] = is_filenm
End If

// worktype = 출금이체신청-이용기관
ls_temp = fs_get_control("B7", "A500",ls_ref_desc)
li_result = fi_cut_string(ls_temp, ";", is_worktype) 

If dw_cond.GetChild('bankreq_file_name', ldc_filename) = - 1 Then 
   MessageBox("Error", "Not a DataWindowChild")
End If

ls_filter = "worktype = '" + is_worktype[1] +"'"
ldc_filename.setFilter(ls_filter)
ldc_filename.filter()
ldc_filename.SetTransObject(SQLCA)
ldc_filename.Retrieve()


//은행접수
dw_cond.object.worktype[1] = is_worktype[1]


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
//is_filepath =  fs_get_control("B7", "A400", ls_ref_desc)
//If is_filepath = "" Then
//	f_msg_usr_err(9000, Title, "파일저장 위치에 대한 정보가 없습니다.(SYSCTL1T:B7:A400)")
//	Close(This)
//End If	
//
//dw_cond.Object.browse[1] = is_filepath+is_filenames[2]
//is_filepath = is_filepath + is_filenames[2]
//
//If Right(is_filepath, 1) = "\" Then
//	is_filepath = is_filepath
//Else
//	is_filepath = is_filepath + "\"
//End If

// status = 신청 파일의 상태
ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
li_result = fi_cut_string(ls_temp, ";", is_status)

//출금이체 신청결과(없음;미처리;처리중;처리성공;처리실패;0;1;S;F)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
If ls_temp = "" Then Return 0
fi_cut_string(ls_temp, ";" , is_drawingresult[])


//응답을 주지 않았으면 다른 작업을 할 수 없게 함
//li_cnt = 0
//SELECT NVL(count(*),0)
//INTO :li_cnt
//FROM bankreqstatus
//WHERE status <> :is_status[3];
//
//IF  li_cnt = 0 THEN
//	p_fileread.TriggerEvent("ue_enable")
//	dw_cond.object.msg_1.visible = True
//	dw_cond.object.msg_2.visible = False
//ELSE
//	dw_cond.object.msg_2.visible = True
//	dw_cond.object.msg_1.visible = False
//	p_fileread.TriggerEvent("ue_disable")
//	
//END IF

Return 0
end event

public function integer wfi_check_filename (string as_filename);//파일명 check
// -1 : false
//  0 : True
Integer li_return
String ls_ref_content, ls_ref_desc, ls_result[], ls_gr_prefix
String ls_filename_prefix

ls_filename_prefix = LeftA(as_filename, 4)

//자동이체 신청시 사용되는 파일이름의 prefix
ls_ref_content = fs_get_control("B7", "A605", ls_ref_desc)
If ls_ref_content = "" Then
	li_return = -1
Else
	li_return = fi_cut_string(ls_ref_content, ";", ls_result[])
	ls_gr_prefix = Trim(ls_result[2])
	
	If ls_filename_prefix = ls_gr_prefix Then
		li_return = 0
	Else
		li_return = -1
	End If
End If

Return li_return


end function

public function integer wfi_check_fileexist (string as_filename);//------------------------------------------------
// 파일의 처리여부 검사
// 선택한 파일이름이 BANKREQ에 있으면 결과처리 불가
// 1 : 처리완료
// 0 : 미처리
// -1 : SQL Error
//------------------------------------------------
Integer li_return
Long ll_count

SELECT count(*) 
INTO :ll_count
FROM bankreq
WHERE file_name = :as_filename;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, ": CHECK existence(GR21mmdd)")
	li_return = -1
End If

If ll_count > 0 Then 
	li_return = 1
Else
	li_return = 0
End If

Return li_return
end function

on b7w_reg_bankreq_gr21_naray.create
int iCurrent
call super::create
this.p_fileread=create p_fileread
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_fileread
end on

on b7w_reg_bankreq_gr21_naray.destroy
call super::destroy
destroy(this.p_fileread)
end on

event ue_ok;call super::ue_ok;String ls_where
String ls_file_name, ls_payid, ls_error_code, ls_receiptdt_fr, ls_receiptdt_to
Date ld_receiptdt_fr, ld_receiptdt_to
Long ll_row
String ls_temp, ls_filenames[], ls_ref_desc

ls_file_name = Trim(dw_cond.object.bankreq_file_name[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_error_code = Trim(dw_cond.object.error_code[1])
ld_receiptdt_fr = dw_cond.object.bankreq_receiptdt_fr[1]
ld_receiptdt_to = dw_cond.object.bankreq_receiptdt_to[1]
ls_receiptdt_fr = Trim(String(ld_receiptdt_fr, 'yyyymmdd'))
ls_receiptdt_to = Trim(String(ld_receiptdt_to, 'yyyymmdd'))

If IsNull(ls_file_name) Then ls_file_name = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_error_code) Then ls_error_Code = ""
If IsNull(ls_receiptdt_fr) Then ls_receiptdt_fr = ""
If IsNull(ls_receiptdt_to) Then ls_receiptdt_to = ""

// Dynamic SQL
ls_where = ""

If ls_file_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " file_name = '" + ls_file_name + "' "
Else
	If ls_where <> "" Then ls_where += " And "
	ls_where += "file_name like '" + is_filenames[2] + "%'"
End If

//이체연도 조건추가 
//If ls_where <> "" Then ls_where += " AND "
//ls_where += " to_char(receiptdt, 'yyyy') = '" + is_receipty + "' "

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " payid = '" + ls_payid + "' "
End If

If ls_error_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " error_code = '" + ls_error_code + "' "
End If

If ls_receiptdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(receiptdt, 'yyyymmdd') >= '" + ls_receiptdt_fr + "' "
End If

If ls_receiptdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(receiptdt, 'yyyymmdd') <= '" + ls_receiptdt_to + "' "
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

event open;call super::open;TriggerEvent('ue_open')
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b7w_reg_bankreq_gr21_naray
integer y = 56
integer width = 2121
integer height = 644
string dataobject = "b7dw_cnd_reg_bankreq_gr21"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b1w_hlp_payid"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;
Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data[1]
		End If
	
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_mmdd
Choose Case dwo.name
Case "cmsacpdt"
		ls_mmdd = MidA(data,6,2) + MidA(data,9,2)
      is_filenm = is_filenames[2] + ls_mmdd
	   dw_cond.Object.filename[1] = is_filenm
End Choose

Return
end event

type p_ok from w_a_reg_m_sql`p_ok within b7w_reg_bankreq_gr21_naray
integer x = 2299
integer y = 60
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b7w_reg_bankreq_gr21_naray
integer x = 2610
integer y = 60
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b7w_reg_bankreq_gr21_naray
integer y = 16
integer width = 2162
integer height = 700
end type

type p_save from w_a_reg_m_sql`p_save within b7w_reg_bankreq_gr21_naray
boolean visible = false
integer x = 2830
integer y = 496
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b7w_reg_bankreq_gr21_naray
integer y = 748
integer width = 3136
integer height = 1396
string dataobject = "b7dw_reg_bankreq_gr21_m"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ib_highlight = True

ldwo_sort = Object.receiptdt_t
uf_init(ldwo_sort)

end event

event dw_detail::retrieveend;call super::retrieveend;//응답을 주지 않았으면 다른 작업을 할 수 없게 함
Integer li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM bankreqstatus
WHERE status <> :is_status[3];


IF  li_cnt = 0 THEN
	p_fileread.TriggerEvent("ue_enable")
	dw_cond.object.msg_1.visible = True
	dw_cond.object.msg_2.visible = False
ELSE
	dw_cond.object.msg_2.visible = True
	dw_cond.object.msg_1.visible = False
	p_fileread.TriggerEvent("ue_disable")
END IF


Return 
end event

type p_fileread from u_p_fileread within b7w_reg_bankreq_gr21_naray
integer x = 2304
integer y = 180
boolean bringtotop = true
end type

